Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C91526B0082
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 22:39:43 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n882diOv020410
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 8 Sep 2009 11:39:44 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 349D545DE52
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:39:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4648F45DE92
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:39:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 084281DB803E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:39:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 50B5FE08014
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:39:36 +0900 (JST)
Date: Tue, 8 Sep 2009 11:37:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
Message-Id: <20090908113734.869cdad7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0909072238320.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	<Pine.LNX.4.64.0909072238320.15430@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Sep 2009 22:39:34 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> KAMEZAWA Hiroyuki has observed customers of earlier kernels taking
> advantage of the ZERO_PAGE: which we stopped do_anonymous_page() from
> using in 2.6.24.  And there were a couple of regression reports on LKML.
> 
> Following suggestions from Linus, reinstate do_anonymous_page() use of
> the ZERO_PAGE; but this time avoid dirtying its struct page cacheline
> with (map)count updates - let vm_normal_page() regard it as abnormal.
> 
> Use it only on arches which __HAVE_ARCH_PTE_SPECIAL (x86, s390, sh32,
> most powerpc): that's not essential, but minimizes additional branches
> (keeping them in the unlikely pte_special case); and incidentally
> excludes mips (some models of which needed eight colours of ZERO_PAGE
> to avoid costly exceptions).
> 
> Don't be fanatical about avoiding ZERO_PAGE updates: get_user_pages()
> callers won't want to make exceptions for it, so increment its count
> there.  Changes to mlock and migration? happily seems not needed.
> 
> In most places it's quicker to check pfn than struct page address:
> prepare a __read_mostly zero_pfn for that.  Does get_dump_page()
> still need its ZERO_PAGE check? probably not, but keep it anyway.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

A nitpick but this was a concern you shown, IIUC.

== __get_user_pages()..

                        if (pages) {
                                pages[i] = page;

                                flush_anon_page(vma, page, start);
                                flush_dcache_page(page);
                        }
==

This part will call flush_dcache_page() even when ZERO_PAGE is found.

Don't we need to mask this ?

Thanks,
-Kame




> ---
> I have not studied the performance of this at all: I'd rather it go
> into mmotm where others may decide whether it's a good thing or not.
> 
>  mm/memory.c |   53 +++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 44 insertions(+), 9 deletions(-)
> 
> --- mm6/mm/memory.c	2009-09-07 13:16:53.000000000 +0100
> +++ mm7/mm/memory.c	2009-09-07 13:17:01.000000000 +0100
> @@ -107,6 +107,17 @@ static int __init disable_randmaps(char
>  }
>  __setup("norandmaps", disable_randmaps);
>  
> +static unsigned long zero_pfn __read_mostly;
> +
> +/*
> + * CONFIG_MMU architectures set up ZERO_PAGE in their paging_init()
> + */
> +static int __init init_zero_pfn(void)
> +{
> +	zero_pfn = page_to_pfn(ZERO_PAGE(0));
> +	return 0;
> +}
> +core_initcall(init_zero_pfn);
>  
>  /*
>   * If a p?d_bad entry is found while walking page tables, report
> @@ -499,7 +510,9 @@ struct page *vm_normal_page(struct vm_ar
>  	if (HAVE_PTE_SPECIAL) {
>  		if (likely(!pte_special(pte)))
>  			goto check_pfn;
> -		if (!(vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP)))
> +		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
> +			return NULL;
> +		if (pfn != zero_pfn)
>  			print_bad_pte(vma, addr, pte, NULL);
>  		return NULL;
>  	}
> @@ -1144,9 +1157,14 @@ struct page *follow_page(struct vm_area_
>  		goto no_page;
>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>  		goto unlock;
> +
>  	page = vm_normal_page(vma, address, pte);
> -	if (unlikely(!page))
> -		goto bad_page;
> +	if (unlikely(!page)) {
> +		if ((flags & FOLL_DUMP) ||
> +		    pte_pfn(pte) != zero_pfn)
> +			goto bad_page;
> +		page = pte_page(pte);
> +	}
>  
>  	if (flags & FOLL_GET)
>  		get_page(page);
> @@ -2085,10 +2103,19 @@ gotten:
>  
>  	if (unlikely(anon_vma_prepare(vma)))
>  		goto oom;
> -	VM_BUG_ON(old_page == ZERO_PAGE(0));
> -	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> -	if (!new_page)
> -		goto oom;
> +
> +	if (pte_pfn(orig_pte) == zero_pfn) {
> +		new_page = alloc_zeroed_user_highpage_movable(vma, address);
> +		if (!new_page)
> +			goto oom;
> +	} else {
> +		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> +		if (!new_page)
> +			goto oom;
> +		cow_user_page(new_page, old_page, address, vma);
> +	}
> +	__SetPageUptodate(new_page);
> +
>  	/*
>  	 * Don't let another task, with possibly unlocked vma,
>  	 * keep the mlocked page.
> @@ -2098,8 +2125,6 @@ gotten:
>  		clear_page_mlock(old_page);
>  		unlock_page(old_page);
>  	}
> -	cow_user_page(new_page, old_page, address, vma);
> -	__SetPageUptodate(new_page);
>  
>  	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
>  		goto oom_free_new;
> @@ -2594,6 +2619,15 @@ static int do_anonymous_page(struct mm_s
>  	spinlock_t *ptl;
>  	pte_t entry;
>  
> +	if (HAVE_PTE_SPECIAL && !(flags & FAULT_FLAG_WRITE)) {
> +		entry = pte_mkspecial(pfn_pte(zero_pfn, vma->vm_page_prot));
> +		ptl = pte_lockptr(mm, pmd);
> +		spin_lock(ptl);
> +		if (!pte_none(*page_table))
> +			goto unlock;
> +		goto setpte;
> +	}
> +
>  	/* Allocate our own private page. */
>  	pte_unmap(page_table);
>  
> @@ -2617,6 +2651,7 @@ static int do_anonymous_page(struct mm_s
>  
>  	inc_mm_counter(mm, anon_rss);
>  	page_add_new_anon_rmap(page, vma, address);
> +setpte:
>  	set_pte_at(mm, address, page_table, entry);
>  
>  	/* No need to invalidate - it was non-present before */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
