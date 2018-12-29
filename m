Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59AA98E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:40:20 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so22226182pgd.0
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:40:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ca6si12733870plb.141.2018.12.29.13.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 13:40:19 -0800 (PST)
Date: Sat, 29 Dec 2018 13:40:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Reuse only-pte-mapped KSM page in do_wp_page()
Message-Id: <20181229134017.0264b5cab7e3ebb483b49f65@linux-foundation.org>
In-Reply-To: <154471491016.31352.1168978849911555609.stgit@localhost.localdomain>
References: <154471491016.31352.1168978849911555609.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: kirill@shutemov.name, hughd@google.com, aarcange@redhat.com, christian.koenig@amd.com, imbrenda@linux.vnet.ibm.com, yang.shi@linux.alibaba.com, riel@surriel.com, ying.huang@intel.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 13 Dec 2018 18:29:08 +0300 Kirill Tkhai <ktkhai@virtuozzo.com> wrote:

> This patch adds an optimization for KSM pages almost
> in the same way, that we have for ordinary anonymous
> pages. If there is a write fault in a page, which is
> mapped to an only pte, and it is not related to swap
> cache; the page may be reused without copying its
> content.
> 
> [Note, that we do not consider PageSwapCache() pages
>  at least for now, since we don't want to complicate
>  __get_ksm_page(), which has nice optimization based
>  on this (for the migration case). Currenly it is
>  spinning on PageSwapCache() pages, waiting for when
>  they have unfreezed counters (i.e., for the migration
>  finish). But we don't want to make it also spinning
>  on swap cache pages, which we try to reuse, since
>  there is not a very high probability to reuse them.
>  So, for now we do not consider PageSwapCache() pages
>  at all.]
> 
> So, in reuse_ksm_page() we check for 1)PageSwapCache()
> and 2)page_stable_node(), to skip a page, which KSM
> is currently trying to link to stable tree. Then we
> do page_ref_freeze() to prohibit KSM to merge one more
> page into the page, we are reusing. After that, nobody
> can refer to the reusing page: KSM skips !PageSwapCache()
> pages with zero refcount; and the protection against
> of all other participants is the same as for reused
> ordinary anon pages pte lock, page lock and mmap_sem.
> 
> ...
>
> +bool reuse_ksm_page(struct page *page,
> +		    struct vm_area_struct *vma,
> +		    unsigned long address)
> +{
> +	VM_BUG_ON_PAGE(is_zero_pfn(page_to_pfn(page)), page);
> +	VM_BUG_ON_PAGE(!page_mapped(page), page);
> +	VM_BUG_ON_PAGE(!PageLocked(page), page);
> +
> +	if (PageSwapCache(page) || !page_stable_node(page))
> +		return false;
> +	/* Prohibit parallel get_ksm_page() */
> +	if (!page_ref_freeze(page, 1))
> +		return false;
> +
> +	page_move_anon_rmap(page, vma);
> +	page->index = linear_page_index(vma, address);
> +	page_ref_unfreeze(page, 1);
> +
> +	return true;
> +}

Can we avoid those BUG_ON()s?

Something like this:

--- a/mm/ksm.c~mm-reuse-only-pte-mapped-ksm-page-in-do_wp_page-fix
+++ a/mm/ksm.c
@@ -2649,9 +2649,14 @@ bool reuse_ksm_page(struct page *page,
 		    struct vm_area_struct *vma,
 		    unsigned long address)
 {
-	VM_BUG_ON_PAGE(is_zero_pfn(page_to_pfn(page)), page);
-	VM_BUG_ON_PAGE(!page_mapped(page), page);
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
+#ifdef CONFIG_DEBUG_VM
+	if (WARN_ON(is_zero_pfn(page_to_pfn(page))) ||
+			WARN_ON(!page_mapped(page)) ||
+			WARN_ON(!PageLocked(page))) {
+		dump_page(page, "reuse_ksm_page");
+		return false;
+	}
+#endif
 
 	if (PageSwapCache(page) || !page_stable_node(page))
 		return false;

We don't have a VM_WARN_ON_PAGE() and we can't provide one because the
VM_foo() macros don't return a value.  It's irritating and I keep
forgetting why we ended up doing them this way.
