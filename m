Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6B166B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 18:43:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w193so218934725oiw.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:43:27 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d5si6199404itg.77.2016.09.09.15.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 15:43:27 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH] mm: fix the page_swap_info BUG_ON check
Date: Fri,  9 Sep 2016 15:38:38 -0700
Message-Id: <1473460718-31013-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>

'commit 62c230bc1790 ("mm: add support for a filesystem to activate swap
files and use direct_IO for writing swap pages")' replaced swap_aops
dirty hook from __set_page_dirty_no_writeback() to swap_set_page_dirty().
As such for normal cases without these special SWP flags
code path falls back to __set_page_dirty_no_writeback()
so behaviour is expected to be same as before.

But swap_set_page_dirty() makes use of helper page_swap_info() to
get sis(swap_info_struct) to check for the flags like SWP_FILE,
SWP_BLKDEV etc as desired for those features. This helper has
BUG_ON(!PageSwapCache(page)) which is racy and safe only for
set_page_dirty_lock() path. For set_page_dirty() path which is
often needed for cases to be called from irq context, kswapd()
can togele the flag behind the back while the call is
getting executed when system is low on memory and heavy
swapping is ongoing.

This ends up with undesired kernel panic. Patch just moves
the check outside the helper to its users appropriately
to fix kernel panic for the described path. Couple
of users of helpers already take care of SwapCache
condition so I skipped them.

Cc: Mel Gorman <mgorman@suse.de>
Cc: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Jens Axboe <axboe@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 mm/page_io.c  | 3 +++
 mm/swapfile.c | 1 -
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 16bd82fa..eafe5dd 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -264,6 +264,7 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	int ret;
 	struct swap_info_struct *sis = page_swap_info(page);
 
+	BUG_ON(!PageSwapCache(page));
 	if (sis->flags & SWP_FILE) {
 		struct kiocb kiocb;
 		struct file *swap_file = sis->swap_file;
@@ -337,6 +338,7 @@ int swap_readpage(struct page *page)
 	int ret = 0;
 	struct swap_info_struct *sis = page_swap_info(page);
 
+	BUG_ON(!PageSwapCache(page));
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageUptodate(page), page);
 	if (frontswap_load(page) == 0) {
@@ -386,6 +388,7 @@ int swap_set_page_dirty(struct page *page)
 
 	if (sis->flags & SWP_FILE) {
 		struct address_space *mapping = sis->swap_file->f_mapping;
+		BUG_ON(!PageSwapCache(page));
 		return mapping->a_ops->set_page_dirty(page);
 	} else {
 		return __set_page_dirty_no_writeback(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 78cfa29..2657acc 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2724,7 +2724,6 @@ int swapcache_prepare(swp_entry_t entry)
 struct swap_info_struct *page_swap_info(struct page *page)
 {
 	swp_entry_t swap = { .val = page_private(page) };
-	BUG_ON(!PageSwapCache(page));
 	return swap_info[swp_type(swap)];
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
