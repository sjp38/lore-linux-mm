Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE4756B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 17:28:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so156518119pfb.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 14:28:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dc7si23412428pad.212.2016.09.12.14.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 14:28:29 -0700 (PDT)
Date: Mon, 12 Sep 2016 14:28:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix the page_swap_info BUG_ON check
Message-Id: <20160912142827.1a20f7cdb830e44ddafd275f@linux-foundation.org>
In-Reply-To: <1473460718-31013-1-git-send-email-santosh.shilimkar@oracle.com>
References: <1473460718-31013-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>

On Fri,  9 Sep 2016 15:38:38 -0700 Santosh Shilimkar <santosh.shilimkar@oracle.com> wrote:

> 'commit 62c230bc1790 ("mm: add support for a filesystem to activate swap
> files and use direct_IO for writing swap pages")' replaced swap_aops
> dirty hook from __set_page_dirty_no_writeback() to swap_set_page_dirty().
> As such for normal cases without these special SWP flags
> code path falls back to __set_page_dirty_no_writeback()
> so behaviour is expected to be same as before.
> 
> But swap_set_page_dirty() makes use of helper page_swap_info() to
> get sis(swap_info_struct) to check for the flags like SWP_FILE,
> SWP_BLKDEV etc as desired for those features. This helper has
> BUG_ON(!PageSwapCache(page)) which is racy and safe only for
> set_page_dirty_lock() path. For set_page_dirty() path which is
> often needed for cases to be called from irq context, kswapd()
> can togele the flag behind the back while the call is
> getting executed when system is low on memory and heavy
> swapping is ongoing.
> 
> This ends up with undesired kernel panic. Patch just moves
> the check outside the helper to its users appropriately
> to fix kernel panic for the described path. Couple
> of users of helpers already take care of SwapCache
> condition so I skipped them.
> 
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Joe Perches <joe@perches.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jens Axboe <axboe@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>

I'll add

Cc: <stable@vger.kernel.org>	[4.7.x]

> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -264,6 +264,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
>  	int ret;
>  	struct swap_info_struct *sis = page_swap_info(page);
>  
> +	BUG_ON(!PageSwapCache(page));
>  	if (sis->flags & SWP_FILE) {
>  		struct kiocb kiocb;
>  		struct file *swap_file = sis->swap_file;
> @@ -337,6 +338,7 @@ int swap_readpage(struct page *page)
>  	int ret = 0;
>  	struct swap_info_struct *sis = page_swap_info(page);
>  
> +	BUG_ON(!PageSwapCache(page));
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(PageUptodate(page), page);
>  	if (frontswap_load(page) == 0) {
> @@ -386,6 +388,7 @@ int swap_set_page_dirty(struct page *page)
>  
>  	if (sis->flags & SWP_FILE) {
>  		struct address_space *mapping = sis->swap_file->f_mapping;
> +		BUG_ON(!PageSwapCache(page));
>  		return mapping->a_ops->set_page_dirty(page);
>  	} else {
>  		return __set_page_dirty_no_writeback(page);

I guess this is OK for 4.8 but for later kernels, let's quieten it down
a bit?

From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/page_io.c: replace some BUG_ON()s with VM_BUG_ON_PAGE()

So they are CONFIG_DEBUG_VM-only and more informative.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David S. Miller <davem@davemloft.net>
Cc: Hugh Dickins <hughd@google.com>
Cc: Jens Axboe <axboe@fb.com>
Cc: Joe Perches <joe@perches.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_io.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN mm/page_io.c~mm-fix-the-page_swap_info-bug_on-check-fix mm/page_io.c
--- a/mm/page_io.c~mm-fix-the-page_swap_info-bug_on-check-fix
+++ a/mm/page_io.c
@@ -264,7 +264,7 @@ int __swap_writepage(struct page *page,
 	int ret;
 	struct swap_info_struct *sis = page_swap_info(page);
 
-	BUG_ON(!PageSwapCache(page));
+	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
@@ -338,7 +338,7 @@ int swap_readpage(struct page *page)
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
 
-	BUG_ON(!PageSwapCache(page));
+	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageUptodate(page), page);
 	if (frontswap_load(page) == 0) {
@@ -388,7 +388,8 @@ int swap_set_page_dirty(struct page *pag
 
 	if (sis->flags & SWP_FILE) {
 		struct address_space *mapping = sis->swap_file->f_mapping;
-		BUG_ON(!PageSwapCache(page));
+
+		VM_BUG_ON_PAGE(!PageSwapCache(page), page);
 		return mapping->a_ops->set_page_dirty(page);
 	} else {
 		return __set_page_dirty_no_writeback(page);
diff -puN mm/swapfile.c~mm-fix-the-page_swap_info-bug_on-check-fix mm/swapfile.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
