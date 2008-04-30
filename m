Message-ID: <48187AE5.4090807@cybernetics.com>
Date: Wed, 30 Apr 2008 09:57:57 -0400
From: Tony Battersby <tonyb@cybernetics.com>
MIME-Version: 1.0
Subject: Re: [PATCH] more ZERO_PAGE handling ( was 2.6.24 regression: deadlock
 on coredump of big process)
References: <4815E932.1040903@cybernetics.com>	<20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>	<48172C72.1000501@cybernetics.com>	<20080430132516.28f1ee0c.kamezawa.hiroyu@jp.fujitsu.com>	<4817FDA5.1040702@kolumbus.fi>	<20080430141738.e6b80d4b.kamezawa.hiroyu@jp.fujitsu.com>	<20080430051932.GD27652@wotan.suse.de> <20080430143542.2dcf745a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080430143542.2dcf745a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <npiggin@suse.de>, =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> follow_page() returns ZERO_PAGE if a page table is not available.
> but returns NULL if a page table exists. If NULL, handle_mm_fault()
> allocates a new page.
>
> This behavior increases page consumption at coredump, which tend
> to do read-once-but-never-written page fault.  This patch is
> for avoiding this.
>
> Changelog:
>   - fixed to check pte_present()/pte_none() in proper way.
>
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Index: linux-2.6.25/mm/memory.c
> ===================================================================
> --- linux-2.6.25.orig/mm/memory.c
> +++ linux-2.6.25/mm/memory.c
> @@ -926,15 +926,15 @@ struct page *follow_page(struct vm_area_
>  	page = NULL;
>  	pgd = pgd_offset(mm, address);
>  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> -		goto no_page_table;
> +		goto null_or_zeropage;
>  
>  	pud = pud_offset(pgd, address);
>  	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> -		goto no_page_table;
> +		goto null_or_zeropage;
>  	
>  	pmd = pmd_offset(pud, address);
>  	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> -		goto no_page_table;
> +		goto null_or_zeropage;
>  
>  	if (pmd_huge(*pmd)) {
>  		BUG_ON(flags & FOLL_GET);
> @@ -947,8 +947,13 @@ struct page *follow_page(struct vm_area_
>  		goto out;
>  
>  	pte = *ptep;
> -	if (!pte_present(pte))
> +	if (!pte_present(pte)) {
> +		if (!(flags & FOLL_WRITE) && pte_none(pte)) {
> +			pte_unmap_unlock(ptep, ptl);
> +			goto null_or_zeropage;
> +		}
>  		goto unlock;
> +	}
>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>  		goto unlock;
>  	page = vm_normal_page(vma, address, pte);
> @@ -968,7 +973,7 @@ unlock:
>  out:
>  	return page;
>  
> -no_page_table:
> +null_or_zeropage:
>  	/*
>  	 * When core dumping an enormous anonymous area that nobody
>  	 * has touched so far, we don't want to allocate page tables.
>
>
>   
This patch fixes the deadlock.  Tested on 2.6.24.5.  Thanks!

Tested-by: Tony Battersby <tonyb@cybernetics.com>

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
