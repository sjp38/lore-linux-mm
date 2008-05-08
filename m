Date: Thu, 8 May 2008 09:40:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] more ZERO_PAGE handling in follow_page()
Message-Id: <20080508094057.48df4ce0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080507142539.758d30f6.akpm@linux-foundation.org>
References: <20080507163643.d4da0ed0.kamezawa.hiroyu@jp.fujitsu.com>
	<20080507142539.758d30f6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, tonyb@cybernetics.com, mika.penttila@kolumbus.fi
List-ID: <linux-mm.kvack.org>

On Wed, 7 May 2008 14:25:39 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 7 May 2008 16:36:43 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Rewrote the description of patch. (no changes in the logic.)
> > 
> > Thank you for all help.
> > -Kame
> > ==
> > follow_page() is called from get_user_pages(), which returns specified user page.
> > follow_page() can return 1) a page or 2) NULL or 3)ZERO_PAGE.
> > If NULL, handle_mm_fault() is called.
> > 
> > Now, follow_page() to unused pte returns NULL if page table exists. As a result
> > get_user_pages() calls handle_mm_fault() and allocate new memory.
> > This behavior increases memory consumption at coredump, which does
> > read-once-but-never-written page fault.
> > By returning ZERO_PAGE() against READ/ANON request, we can avoid it.
> > 
> > (Because exec's arguments copy needs to call handle_mm_fault at WRITE/ANON
> >  request, we just handle READ/ANON case here.)
> > 
> > Change log:
> >   - Rewrote patch description and Added comments.
> >   - fixed to check pte_present()/pte_none() in proper way.
> 
> So... how serious is the problem which we're fixing here?
> 
> I can see that if one is core-dumping large sparse address spaces this
> could improve things a lot, but please help us understand the implications
> so we can decide whether we need this in 2.6.26, thanks.
> 
I don't think this is a fix for serious trouble just a improvement.
But not sure on small systems....

a consideration.
== at coredump before patch
  killed by something
     -> generate core dump
           -> allocate "a" page before starting I/O even if a page is empty
                 -> do I/O
A page which is not mapped but there is page tables will be written out.
Here, newly allocated page is mapped_and_used after I/O. So, when we
reclaim this page, we need swap. This means terrible slow down or we cannot
go ahead when we exhaust swap.

A user can avoid this kind ot situation by setting rlimit. (and RLIMIT_CORE
is 0 at default.) or set overcommit memory or set dirty_ratio to very small.
But one terrible thing which I can think of is  that a process in coredump
cannot be killed. So once this happens, a user have to be patient or reboot
system.

It seems this patch can help coredump in following system 
  - swapless or An application which can generate core has some amount of
    ANON memory and it is multi-threaded. (pthread's stack is typical case
    for this memory usage.)
  - RLIMIT_CORE is RLIMIT_INIFINITY
  - core_pattern is file.
  - Don't have enough memory to do buffer I/O at coredump.
  - dirty_ratio is default.

But an application on this kind of system tends to be well controlled.

> 
> > Index: linux-2.6.25/mm/memory.c
> > ===================================================================
> > --- linux-2.6.25.orig/mm/memory.c
> > +++ linux-2.6.25/mm/memory.c
> > @@ -926,15 +926,15 @@ struct page *follow_page(struct vm_area_
> >  	page = NULL;
> >  	pgd = pgd_offset(mm, address);
> >  	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> > -		goto no_page_table;
> > +		goto null_or_zeropage;
> >  
> >  	pud = pud_offset(pgd, address);
> >  	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> > -		goto no_page_table;
> > +		goto null_or_zeropage;
> >  	
> >  	pmd = pmd_offset(pud, address);
> >  	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> 
> The mainline kernel does not have " || unlikely(pmd_bad(*pmd))" here. 
> That got changed yesterday by
> 
> commit aeed5fce37196e09b4dac3a1c00d8b7122e040ce
> Author: Hugh Dickins <hugh@veritas.com>
> Date:   Tue May 6 20:49:23 2008 +0100
> 
>     x86: fix PAE pmd_bad bootup warning
> 
> So please confirm that the patch which I merged is still OK (I'd be
> surprised if it isn't...)
> 
Ok, I'll check and update this against the newest git tree.
(But may took some hours.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
