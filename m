Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 30B816B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 15:58:47 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id uo6so317656pac.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 12:58:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n16si3972145pfa.122.2016.02.02.12.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 12:58:46 -0800 (PST)
Date: Tue, 2 Feb 2016 12:58:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2 2/2] mm: downgrade VM_BUG in isolate_lru_page() to
 warning
Message-Id: <20160202125844.43f23e2f8637b5a304b887dc@linux-foundation.org>
In-Reply-To: <1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1454430061-116955-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1454430061-116955-3-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue,  2 Feb 2016 19:21:01 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Calling isolate_lru_page() is wrong and shouldn't happen, but it not
> nessesary fatal: the page just will not be isolated if it's not on LRU.
> 
> Let's downgrade the VM_BUG_ON_PAGE() to WARN_RATELIMIT().
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/vmscan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eb3dd37ccd7c..71b1c29948db 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
>  	int ret = -EBUSY;
>  
>  	VM_BUG_ON_PAGE(!page_count(page), page);
> -	VM_BUG_ON_PAGE(PageTail(page), page);
> +	WARN_RATELIMIT(PageTail(page), "trying to isolate tail page");
>  
>  	if (PageLRU(page)) {
>  		struct zone *zone = page_zone(page);

Confused.  I thought mm-fix-bogus-vm_bug_on_page-in-isolate_lru_page.patch:

--- a/mm/vmscan.c~mm-fix-bogus-vm_bug_on_page-in-isolate_lru_page
+++ a/mm/vmscan.c
@@ -1443,7 +1443,7 @@ int isolate_lru_page(struct page *page)
 	int ret = -EBUSY;
 
 	VM_BUG_ON_PAGE(!page_count(page), page);
-	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(PageLRU(page) && PageTail(page), page);
 
 	if (PageLRU(page)) {
 		struct zone *zone = page_zone(page);

was better.  We *know* that we sometimes encounter LRU pages here and
we know that we handle them correctly.  So why scare users by blurting
out a warning about something for which we won't be taking any action?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
