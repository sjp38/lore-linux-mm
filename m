Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1605C6B0006
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 17:20:51 -0400 (EDT)
Date: Wed, 27 Mar 2013 14:20:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG root-caused: careless processing of pagevec causes
 "Bad page states"
Message-Id: <20130327142049.9deca3ed9d98a70529805fd6@linux-foundation.org>
In-Reply-To: <CABF3WkkYWvfK8Jv-D=bsHH8GA5HtP4AggANe4EaWJDbmMvDD+w@mail.gmail.com>
References: <CABF3WkkYWvfK8Jv-D=bsHH8GA5HtP4AggANe4EaWJDbmMvDD+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valery Podrezov <pvadop@gmail.com>
Cc: linux-mm@kvack.org

On Wed, 20 Feb 2013 17:16:43 +0300 Valery Podrezov <pvadop@gmail.com> wrote:

> SUMMARY: careless processing of pagevec causes "Bad page states"
> 
> I have the messages "BUG: Bad page state in process.." in SMP mode with two
> cpus (kernel 3.3).
> I have root-caused the problem, see description below.
> I have prepared the temporary workaround, it helps to eliminate the problem
> and demonstrates additionally the essence of the problem.
> 
> The following sections are provided below:
> 
>     DESCRIPTION
>     ENVIRONEMENT
>     OOPS-messages
>     WORKAROUND
> 
> Is it a known issue and is there already the patch properly fixing it?
> Feel free to ask me any questions.
> 
> Best Regards,
>  Valery Podrezov
> 
> 
> 
> DESCRIPTION:
> 
> 
> There is how the problem is generated
> (PFN0 refers the problematical physical page,
> (1) and (2) are successive points of execution):
> 
> 1. cpu 0: ...
>    cpu 1: is running the user process (PROC0)
>           Gets the new page with the PFN0 from free list by alloc_page_vma()
>           Runs page_add_new_anon_rmap(), thus the page PFN0 occurs in
> pagevec of this cpu (it is 5-th): pvec = &get_cpu_var(lru_add_pvecs)[lru];
>           Runs fork (PROC1 - the generated child process)
>           The page PFN0 is present in the page tables of the child process
> PROC1 (it is read-only, to be COWed)
> 
> 2. cpu 0: is running PROC1
>           writes to the virtual address (VA1) translated through its page
> tables to the PFN0
>           do_page_fault (data) on VA1 (physical page is present in the page
> tables of the process, but no write permissions)
> 
>    cpu 1: is running PROC1
>           do_page_fault (data) on some virtual address (no page in page
> tables)
>           Gets the new page from free list by alloc_page_vma()
>           Runs page_add_new_anon_rmap(), then __lru_cache_add()
>           This new page is just 14-th in pagevec of this cpu, so runs
> __pagevec_lru_add(),
>           then pagevec_lru_move_fn() and, finally, __pagevec_lru_add_fn()
> 
> There are no common locks at this point applied for both processes
> simultaneously,
> these locks are applied:
>    core 0: PROC0->mm->mmap_sem
>            PFN0->flags PG_locked (lock_page)
> 
>    core 1: PROC1->mm->mmap_sem (!= PROC0->mm->mmap_sem)
>            PFN0->zone->lru_lock
> 
> The more detailed timing below of point (2) for both cpus
> shows how the bit PG_locked is mistakenly generated for the PFN0.
> 
>    Both cpus are processing do_page_fault() (see above)
>    Both cpus are in the same routine do_wp_page()
> 
>    a) cpu 0: locks the page by trylock_page(old_page) (it is just the page
> with PFN0)
>    b) cpu 1: is processing __pagevec_lru_add_fn()
>              Reads page->flags of its 5-th element of pagevec (it is PFN0
> page, it contains PG_locked set to 1, see (a))
> 
>    c) cpu 0: unlocks the page by unlock_page(old_page) (reset the bit
> PG_locked of PFN0 page)
>    d) cpu 1: executes SetPageLRU(page) in __pagevec_lru_add_fn() and thus
> sets not only PG_lru
>              bit of PFN0 page but, mistakenly, the bit PG_locked too

Here is where I got lost.

: static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
: 				 void *arg)
: {
: 	enum lru_list lru = (enum lru_list)arg;
: 	int file = is_file_lru(lru);
: 	int active = is_active_lru(lru);
: 
: 	VM_BUG_ON(PageActive(page));
: 	VM_BUG_ON(PageUnevictable(page));
: 	VM_BUG_ON(PageLRU(page));
: 
: 	SetPageLRU(page);
: 	if (active)
: 		SetPageActive(page);
: 	add_page_to_lru_list(page, lruvec, lru);
: 	update_page_reclaim_stat(lruvec, file, active);
: }


__pagevec_lru_add_fn() is using atomic bit operations of page->flags,
so how could it unintentionally retain the old PG_locked state?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
