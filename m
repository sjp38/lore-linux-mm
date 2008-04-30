Date: Wed, 30 Apr 2008 07:19:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] more ZERO_PAGE handling ( was 2.6.24 regression: deadlock on coredump of big process)
Message-ID: <20080430051932.GD27652@wotan.suse.de>
References: <4815E932.1040903@cybernetics.com> <20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com> <48172C72.1000501@cybernetics.com> <20080430132516.28f1ee0c.kamezawa.hiroyu@jp.fujitsu.com> <4817FDA5.1040702@kolumbus.fi> <20080430141738.e6b80d4b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20080430141738.e6b80d4b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mika =?iso-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>, Tony Battersby <tonyb@cybernetics.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2008 at 02:17:38PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 30 Apr 2008 08:03:33 +0300
> Mika Penttila <mika.penttila@kolumbus.fi> wrote:
> 
> > > ==
> > > @@ -2252,39 +2158,24 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >         spinlock_t *ptl;
> > >  {
> > > <snip>
> > > -               page_add_new_anon_rmap(page, vma, address);
> > > -       } else {
> > > -               /* Map the ZERO_PAGE - vm_page_prot is readonly */
> > > -               page = ZERO_PAGE(address);
> > > -               page_cache_get(page);
> > > -               entry = mk_pte(page, vma->vm_page_prot);
> > > +       if (unlikely(anon_vma_prepare(vma)))
> > > +               goto oom;
> > > +       page = alloc_zeroed_user_highpage_movable(vma, address);
> > > ==
> > >
> > > above change is for avoiding to use ZERO_PAGE at read-page-fault to anonymous
> > > vma. This is reasonable I think. But at coredump, tons of read-but-never-written 
> > > pages can be allocated.
> > > ==
> > > coredump
> > >   -> get_user_pages()
> > >        -> follow_page() returns NULL
> > >             -> handle mm fault
> > >                  -> do_anonymous page.
> > > ==
> > > follow_page() returns ZERO_PAGE only when page table is not avaiable.
> > >
> > > So, making follow_page() return ZERO_PAGE can be a fix of extra memory
> > > consumpstion at core dump. (Maybe someone can think of other fix.)
> > >
> > > how about this patch ? Could you try ?
> > >
> > > (I'm sorry but I'll not be active for a week because my servers are powered off.)
> > >
> > > -Kame
> > >
> > >   
> > 
> > 
> > But sure we still have to handle the fault for instance swapped pages, 
> > for other uses of get_user_pages();
> > 
> Ah, my bad.....how about this ? I changed !pte_present() to pte_none().
> 
> -Kame
> ==
> follow_page() returns ZERO_PAGE if a page table is not available.
> but returns NULL if a page table exists. If NULL, handle_mm_fault()
> allocates a new page.
> 
> This behavior increases page consumption at coredump, which tend
> to do read-once-but-never-written page fault.  This patch is
> for avoiding this.

I think you still need the pte_present test too, otherwise !present and
!none ptes can slip through and be treated as present.

Something like this should do:
if (!pte_present(pte)) {
	if (pte_none(pte)) {
		pte_unmap_unlock
		goto null_or_zeropage;
	}
	goto unlock;
}


> 
> Changelog:
>   - fixed to check pte_none() not !pte_present().
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
> @@ -947,8 +947,10 @@ struct page *follow_page(struct vm_area_
>  		goto out;
>  
>  	pte = *ptep;
> -	if (!pte_present(pte))
> -		goto unlock;
> +	if (!(flags & FOLL_WRITE) && pte_none(pte)) {
> +		pte_unmap_unlock(ptep, ptl);
> +		goto null_or_zeropage;
> +	}
>  	if ((flags & FOLL_WRITE) && !pte_write(pte))
>  		goto unlock;
>  	page = vm_normal_page(vma, address, pte);
> @@ -968,7 +970,7 @@ unlock:
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
