Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 28D1D6B01AD
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 05:59:34 -0400 (EDT)
Date: Mon, 5 Jul 2010 11:59:28 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 6/7] hugetlb: hugepage migration core
Message-ID: <20100705095927.GC8510@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278049646-29769-7-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 02:47:25PM +0900, Naoya Horiguchi wrote:
> diff --git v2.6.35-rc3-hwpoison/mm/migrate.c v2.6.35-rc3-hwpoison/mm/migrate.c
> index e4a381c..e7af148 100644
> --- v2.6.35-rc3-hwpoison/mm/migrate.c
> +++ v2.6.35-rc3-hwpoison/mm/migrate.c
> @@ -32,6 +32,7 @@
>  #include <linux/security.h>
>  #include <linux/memcontrol.h>
>  #include <linux/syscalls.h>
> +#include <linux/hugetlb.h>
>  #include <linux/gfp.h>
>  
>  #include "internal.h"
> @@ -74,6 +75,8 @@ void putback_lru_pages(struct list_head *l)
>  	struct page *page2;
>  
>  	list_for_each_entry_safe(page, page2, l, lru) {
> +		if (PageHuge(page))
> +			break;

Why is this a break and not a continue? Couldn't you have small and large
pages in the same list?

There's more code that handles LRU in this file. Do they all handle huge pages
correctly?

I also noticed we do not always lock all sub pages in the huge page. Now if
IO happens it will lock on subpages, not the head page. But this code
handles all subpages as a unit. Could this cause locking problems?
Perhaps it would be safer to lock all sub pages always? Or would 
need  to audit other page users to make sure they always lock on the head
and do the same here.

Hmm page reference counts may have the same issue?

> @@ -95,6 +98,12 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>  	pte_t *ptep, pte;
>   	spinlock_t *ptl;
>  
> +	if (unlikely(PageHuge(new))) {
> +		ptep = huge_pte_offset(mm, addr);
> +		ptl = &mm->page_table_lock;
> +		goto check;
> +	}
> +
>   	pgd = pgd_offset(mm, addr);
>  	if (!pgd_present(*pgd))
>  		goto out;
> @@ -115,6 +124,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>   	}
>  
>   	ptl = pte_lockptr(mm, pmd);
> +check:

I think I would prefer a proper if else over a goto here.

The lookup should probably just call a helper to make this function more readable
(like lookup_address(), unfortunately that's x86 specific right now)


> @@ -284,7 +308,17 @@ static int migrate_page_move_mapping(struct address_space *mapping,
>   */
>  static void migrate_page_copy(struct page *newpage, struct page *page)
>  {
> -	copy_highpage(newpage, page);
> +	int i;
> +	struct hstate *h;
> +	if (!PageHuge(newpage))
> +		copy_highpage(newpage, page);
> +	else {
> +		h = page_hstate(newpage);
> +		for (i = 0; i < pages_per_huge_page(h); i++) {
> +			cond_resched();
> +			copy_highpage(newpage + i, page + i);

Better reuse copy_huge_page() instead of open coding.


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
