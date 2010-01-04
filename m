Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C87CE600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 22:02:19 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o042r7cx022831
	for <linux-mm@kvack.org>; Sun, 3 Jan 2010 21:53:07 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0432AMh136758
	for <linux-mm@kvack.org>; Sun, 3 Jan 2010 22:02:10 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o04329Id027745
	for <linux-mm@kvack.org>; Sun, 3 Jan 2010 22:02:10 -0500
Date: Sun, 3 Jan 2010 19:02:34 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] asynchronous page fault.
Message-ID: <20100104030234.GF32568@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com> <1261915391.15854.31.camel@laptop> <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com> <1261989047.7135.3.camel@laptop> <27db4d47e5a95e7a85942c0278892467.squirrel@webmail-b.css.fujitsu.com> <1261996258.7135.67.camel@laptop> <1261996841.7135.69.camel@laptop> <1262448844.6408.93.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262448844.6408.93.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jan 02, 2010 at 05:14:04PM +0100, Peter Zijlstra wrote:
> On Mon, 2009-12-28 at 11:40 +0100, Peter Zijlstra wrote:
> 
> > > Right, so acquiring the PTE lock will either instantiate page tables for
> > > a non-existing vma, leaving you with an interesting mess to clean up, or
> > > you can also RCU free the page tables (in the same RCU domain as the
> > > vma) which will mostly[*] avoid that issue.
> > > 
> > > [ To make live really really interesting you could even re-use the
> > >   page-tables and abort the RCU free when the region gets re-mapped
> > >   before the RCU callbacks happen, this will avoid a free/alloc cycle
> > >   for fast remapping workloads. ]
> > > 
> > > Once you hold the PTE lock, you can validate the vma you looked up,
> > > since ->unmap() syncs against it. If at that time you find the
> > > speculative vma is dead, you fail and re-try the fault.
> > > 
> > > [*] there still is the case of faulting on an address that didn't
> > > previously have page-tables hence the unmap page table scan will have
> > > skipped it -- my hacks simply leaked page tables here, but the idea was
> > > to acquire the mmap_sem for reading and cleanup properly.
> > 
> > Alternatively, we could mark vma's dead in some way before we do the
> > unmap, then whenever we hit the page-table alloc path, we check against
> > the speculative vma and bail if it died.
> > 
> > That might just work.. will need to ponder it a bit more.
> 
> Right, so I don't think we need RCU page tables on x86. All we need is
> some extension to the fast_gup() stuff.
> 
> Nor do we need to modify the page-table alloc paths. All we need to do
> is have 2 versions of the page table walks like those in
> handle_mm_fault().
> 
> What we do need is to have call_srcu() for the VMAs since all this fault
> stuff can block in many ways. And we need to tag 'dead' VMAs as such
> (before doing the unmap).
> 
> [ Paul, pretty please? :-) ]

It would not be all that hard for me to make a call_srcu(), but...

1.	How are you avoiding OOM by SRCU callback?  (I am sure you
	have this worked out, but I do have to ask!)

2.	How many srcu_struct data structures are you envisioning?
	One globally?  One per process?  One per struct vma?
	(Not necessary to know this for call_srcu(), but will be needed
	as I work out how to make SRCU scale with large numbers of CPUs.)

							Thanx, Paul

> We also need to introduce FAULT_FLAG_SPECULATIVE to tell the rest of the
> fault code about us not holding mmap_sem. And add a return fault return
> state like VM_FAULT_RETRY to retry the fault holding the mmap_sem.
> 
> Then we need alternative page table walkers, currently things like
> handle_mm_fault() use the p*_alloc*() like routines, but for
> FAULT_FLAG_SPECULATIVE we need to use the p*_offset*() variants like in
> follow_pte(). If that fails to find the pte, we return VM_FAULT_RETRY.
> 
> [ One sad consequence is that this still requires the mmap_sem for
>   every page table alloc, but since a pte can hold lots of pages it
>   should hopefully work out nicely ]
> 
> The above is the tricky bit since that can race with unmap, which is
> where the fast_gup() stuff comes into play. fast_gup() has the exact
> same problem, and already solved it for us. So we need a speculative
> page table walker that does whatever fast_gup() does, which on x86 is
> disable IRQs (powerpc has RCU freed page tables).
> 
> Now all sites where we actually lock the ptl we need to actually redo
> that page table walk, failing to find the pte will again return
> VM_FAULT_RETRY, once we lock the ptl we need to check the VMA's dead
> state, if dead we also bail with VM_FAULT_RETRY, otherwise we're good
> and can continue.
> 
> 
> Something like the below, which 'sometimes' boots on my dual core and
> when it boots seems to survive building a kernel... definitely needs
> more work.
> 
> ---
>  arch/x86/mm/fault.c      |    8 ++
>  arch/x86/mm/gup.c        |   10 ++
>  include/linux/mm.h       |   14 +++
>  include/linux/mm_types.h |    4 +
>  init/Kconfig             |   34 +++---
>  kernel/sched.c           |    9 ++-
>  mm/memory.c              |  293 +++++++++++++++++++++++++++++++--------------
>  mm/mmap.c                |   31 +++++-
>  mm/util.c                |   12 ++-
>  9 files changed, 302 insertions(+), 113 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index f627779..c748529 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -1040,6 +1040,14 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
>  		return;
>  	}
> 
> +	if (error_code & PF_USER) {
> +		fault = handle_speculative_fault(mm, address,
> +				error_code & PF_WRITE ? FAULT_FLAG_WRITE : 0);
> +
> +		if (!(fault & (VM_FAULT_ERROR | VM_FAULT_RETRY)))
> +			return;
> +	}
> +
>  	/*
>  	 * When running in the kernel we expect faults to occur only to
>  	 * addresses in user space.  All other faults represent errors in
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index 71da1bc..6eeaef7 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -373,3 +373,13 @@ slow_irqon:
>  		return ret;
>  	}
>  }
> +
> +void pin_page_tables(void)
> +{
> +	local_irq_disable();
> +}
> +
> +void unpin_page_tables(void)
> +{
> +	local_irq_enable();
> +}
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2265f28..7bc94f9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -136,6 +136,7 @@ extern pgprot_t protection_map[16];
>  #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
>  #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
>  #define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
> +#define FAULT_FLAG_SPECULATIVE	0x08
> 
>  /*
>   * This interface is used by x86 PAT code to identify a pfn mapping that is
> @@ -711,6 +712,7 @@ static inline int page_mapped(struct page *page)
> 
>  #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
>  #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
> +#define VM_FAULT_RETRY  0x0400
> 
>  #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON)
> 
> @@ -763,6 +765,14 @@ unsigned long unmap_vmas(struct mmu_gather **tlb,
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *);
> 
> +static inline int vma_is_dead(struct vm_area_struct *vma, unsigned int sequence)
> +{
> +	int ret = RB_EMPTY_NODE(&vma->vm_rb);
> +	unsigned seq = vma->vm_sequence.sequence;
> +	smp_rmb();
> +	return ret || (seq & 1) || seq != sequence;
> +}
> +
>  /**
>   * mm_walk - callbacks for walk_page_range
>   * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
> @@ -819,6 +829,8 @@ int invalidate_inode_page(struct page *page);
>  #ifdef CONFIG_MMU
>  extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			unsigned long address, unsigned int flags);
> +extern int handle_speculative_fault(struct mm_struct *mm,
> +			unsigned long address, unsigned int flags);
>  #else
>  static inline int handle_mm_fault(struct mm_struct *mm,
>  			struct vm_area_struct *vma, unsigned long address,
> @@ -838,6 +850,8 @@ int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			struct page **pages, struct vm_area_struct **vmas);
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages);
> +void pin_page_tables(void);
> +void unpin_page_tables(void);
>  struct page *get_dump_page(unsigned long addr);
> 
>  extern int try_to_release_page(struct page * page, gfp_t gfp_mask);
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 84a524a..0727300 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -12,6 +12,8 @@
>  #include <linux/completion.h>
>  #include <linux/cpumask.h>
>  #include <linux/page-debug-flags.h>
> +#include <linux/seqlock.h>
> +#include <linux/rcupdate.h>
>  #include <asm/page.h>
>  #include <asm/mmu.h>
> 
> @@ -186,6 +188,8 @@ struct vm_area_struct {
>  #ifdef CONFIG_NUMA
>  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
>  #endif
> +	seqcount_t vm_sequence;
> +	struct rcu_head vm_rcu_head;
>  };
> 
>  struct core_thread {
> diff --git a/init/Kconfig b/init/Kconfig
> index 06dab27..5edae47 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -314,19 +314,19 @@ menu "RCU Subsystem"
> 
>  choice
>  	prompt "RCU Implementation"
> -	default TREE_RCU
> +	default TREE_PREEMPT_RCU
> 
> -config TREE_RCU
> -	bool "Tree-based hierarchical RCU"
> -	help
> -	  This option selects the RCU implementation that is
> -	  designed for very large SMP system with hundreds or
> -	  thousands of CPUs.  It also scales down nicely to
> -	  smaller systems.
> +#config TREE_RCU
> +#	bool "Tree-based hierarchical RCU"
> +#	help
> +#	  This option selects the RCU implementation that is
> +#	  designed for very large SMP system with hundreds or
> +#	  thousands of CPUs.  It also scales down nicely to
> +#	  smaller systems.
> 
>  config TREE_PREEMPT_RCU
>  	bool "Preemptable tree-based hierarchical RCU"
> -	depends on PREEMPT
> +#	depends on PREEMPT
>  	help
>  	  This option selects the RCU implementation that is
>  	  designed for very large SMP systems with hundreds or
> @@ -334,14 +334,14 @@ config TREE_PREEMPT_RCU
>  	  is also required.  It also scales down nicely to
>  	  smaller systems.
> 
> -config TINY_RCU
> -	bool "UP-only small-memory-footprint RCU"
> -	depends on !SMP
> -	help
> -	  This option selects the RCU implementation that is
> -	  designed for UP systems from which real-time response
> -	  is not required.  This option greatly reduces the
> -	  memory footprint of RCU.
> +#config TINY_RCU
> +#	bool "UP-only small-memory-footprint RCU"
> +#	depends on !SMP
> +#	help
> +#	  This option selects the RCU implementation that is
> +#	  designed for UP systems from which real-time response
> +#	  is not required.  This option greatly reduces the
> +#	  memory footprint of RCU.
> 
>  endchoice
> 
> diff --git a/kernel/sched.c b/kernel/sched.c
> index 22c14eb..21cdc52 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -9689,7 +9689,14 @@ void __init sched_init(void)
>  #ifdef CONFIG_DEBUG_SPINLOCK_SLEEP
>  static inline int preempt_count_equals(int preempt_offset)
>  {
> -	int nested = (preempt_count() & ~PREEMPT_ACTIVE) + rcu_preempt_depth();
> +	int nested = (preempt_count() & ~PREEMPT_ACTIVE)
> +		/*
> +		 * remove this for we need preemptible RCU
> +		 * exactly because it needs to sleep..
> +		 *
> +		 + rcu_preempt_depth()
> +		 */
> +		;
> 
>  	return (nested == PREEMPT_INATOMIC_BASE + preempt_offset);
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index 09e4b1b..ace6645 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1919,31 +1919,6 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
>  EXPORT_SYMBOL_GPL(apply_to_page_range);
> 
>  /*
> - * handle_pte_fault chooses page fault handler according to an entry
> - * which was read non-atomically.  Before making any commitment, on
> - * those architectures or configurations (e.g. i386 with PAE) which
> - * might give a mix of unmatched parts, do_swap_page and do_file_page
> - * must check under lock before unmapping the pte and proceeding
> - * (but do_wp_page is only called after already making such a check;
> - * and do_anonymous_page and do_no_page can safely check later on).
> - */
> -static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
> -				pte_t *page_table, pte_t orig_pte)
> -{
> -	int same = 1;
> -#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
> -	if (sizeof(pte_t) > sizeof(unsigned long)) {
> -		spinlock_t *ptl = pte_lockptr(mm, pmd);
> -		spin_lock(ptl);
> -		same = pte_same(*page_table, orig_pte);
> -		spin_unlock(ptl);
> -	}
> -#endif
> -	pte_unmap(page_table);
> -	return same;
> -}
> -
> -/*
>   * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
>   * servicing faults for write access.  In the normal case, do always want
>   * pte_mkwrite.  But get_user_pages can cause write faults for mappings
> @@ -1982,6 +1957,52 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>  		copy_user_highpage(dst, src, va, vma);
>  }
> 
> +static int pte_map_lock(struct mm_struct *mm, struct vm_area_struct *vma,
> +		unsigned long address, pmd_t *pmd, unsigned int flags,
> +		unsigned int seq, pte_t **ptep, spinlock_t **ptlp)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +
> +	if (!(flags & FAULT_FLAG_SPECULATIVE)) {
> +		*ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
> +		return 1;
> +	}
> +
> +	pin_page_tables();
> +
> +	pgd = pgd_offset(mm, address);
> +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> +		goto out;
> +
> +	pud = pud_offset(pgd, address);
> +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> +		goto out;
> +
> +	if (pmd_huge(*pmd))
> +		goto out;
> +
> +	*ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
> +	if (!*ptep)
> +		goto out;
> +
> +	if (vma && vma_is_dead(vma, seq))
> +		goto unlock;
> +
> +	unpin_page_tables();
> +	return 1;
> +
> +unlock:
> +	pte_unmap_unlock(*ptep, *ptlp);
> +out:
> +	unpin_page_tables();
> +	return 0;
> +}
> +
>  /*
>   * This routine handles present pages, when users try to write
>   * to a shared page. It is done by copying the page to a new address
> @@ -2002,7 +2023,8 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>   */
>  static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		spinlock_t *ptl, pte_t orig_pte)
> +		spinlock_t *ptl, unsigned int flags, pte_t orig_pte,
> +		unsigned int seq)
>  {
>  	struct page *old_page, *new_page;
>  	pte_t entry;
> @@ -2034,8 +2056,14 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			page_cache_get(old_page);
>  			pte_unmap_unlock(page_table, ptl);
>  			lock_page(old_page);
> -			page_table = pte_offset_map_lock(mm, pmd, address,
> -							 &ptl);
> +
> +			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
> +						&page_table, &ptl)) {
> +				unlock_page(old_page);
> +				ret = VM_FAULT_RETRY;
> +				goto err;
> +			}
> +
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
>  				page_cache_release(old_page);
> @@ -2077,14 +2105,14 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			if (unlikely(tmp &
>  					(VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
>  				ret = tmp;
> -				goto unwritable_page;
> +				goto err;
>  			}
>  			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
>  				lock_page(old_page);
>  				if (!old_page->mapping) {
>  					ret = 0; /* retry the fault */
>  					unlock_page(old_page);
> -					goto unwritable_page;
> +					goto err;
>  				}
>  			} else
>  				VM_BUG_ON(!PageLocked(old_page));
> @@ -2095,8 +2123,13 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 * they did, we just return, as we can count on the
>  			 * MMU to tell us if they didn't also make it writable.
>  			 */
> -			page_table = pte_offset_map_lock(mm, pmd, address,
> -							 &ptl);
> +			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
> +						&page_table, &ptl)) {
> +				unlock_page(old_page);
> +				ret = VM_FAULT_RETRY;
> +				goto err;
> +			}
> +
>  			if (!pte_same(*page_table, orig_pte)) {
>  				unlock_page(old_page);
>  				page_cache_release(old_page);
> @@ -2128,17 +2161,23 @@ reuse:
>  gotten:
>  	pte_unmap_unlock(page_table, ptl);
> 
> -	if (unlikely(anon_vma_prepare(vma)))
> -		goto oom;
> +	if (unlikely(anon_vma_prepare(vma))) {
> +		ret = VM_FAULT_OOM;
> +		goto err;
> +	}
> 
>  	if (is_zero_pfn(pte_pfn(orig_pte))) {
>  		new_page = alloc_zeroed_user_highpage_movable(vma, address);
> -		if (!new_page)
> -			goto oom;
> +		if (!new_page) {
> +			ret = VM_FAULT_OOM;
> +			goto err;
> +		}
>  	} else {
>  		new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
> -		if (!new_page)
> -			goto oom;
> +		if (!new_page) {
> +			ret = VM_FAULT_OOM;
> +			goto err;
> +		}
>  		cow_user_page(new_page, old_page, address, vma);
>  	}
>  	__SetPageUptodate(new_page);
> @@ -2153,13 +2192,20 @@ gotten:
>  		unlock_page(old_page);
>  	}
> 
> -	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))
> -		goto oom_free_new;
> +	if (mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)) {
> +		ret = VM_FAULT_OOM;
> +		goto err_free_new;
> +	}
> 
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> -	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
> +		mem_cgroup_uncharge_page(new_page);
> +		ret = VM_FAULT_RETRY;
> +		goto err_free_new;
> +	}
> +
>  	if (likely(pte_same(*page_table, orig_pte))) {
>  		if (old_page) {
>  			if (!PageAnon(old_page)) {
> @@ -2258,9 +2304,9 @@ unlock:
>  			file_update_time(vma->vm_file);
>  	}
>  	return ret;
> -oom_free_new:
> +err_free_new:
>  	page_cache_release(new_page);
> -oom:
> +err:
>  	if (old_page) {
>  		if (page_mkwrite) {
>  			unlock_page(old_page);
> @@ -2268,10 +2314,6 @@ oom:
>  		}
>  		page_cache_release(old_page);
>  	}
> -	return VM_FAULT_OOM;
> -
> -unwritable_page:
> -	page_cache_release(old_page);
>  	return ret;
>  }
> 
> @@ -2508,22 +2550,23 @@ int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
>   * We return with mmap_sem still held, but pte unmapped and unlocked.
>   */
>  static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		unsigned int flags, pte_t orig_pte)
> +		unsigned long address, pmd_t *pmd, unsigned int flags,
> +		pte_t orig_pte, unsigned int seq)
>  {
>  	spinlock_t *ptl;
>  	struct page *page;
>  	swp_entry_t entry;
> -	pte_t pte;
> +	pte_t *page_table, pte;
>  	struct mem_cgroup *ptr = NULL;
>  	int ret = 0;
> 
> -	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
> -		goto out;
> -
>  	entry = pte_to_swp_entry(orig_pte);
>  	if (unlikely(non_swap_entry(entry))) {
>  		if (is_migration_entry(entry)) {
> +			if (flags & FAULT_FLAG_SPECULATIVE) {
> +				ret = VM_FAULT_RETRY;
> +				goto out;
> +			}
>  			migration_entry_wait(mm, pmd, address);
>  		} else if (is_hwpoison_entry(entry)) {
>  			ret = VM_FAULT_HWPOISON;
> @@ -2544,7 +2587,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			 * Back out if somebody else faulted in this pte
>  			 * while we released the pte lock.
>  			 */
> -			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +			if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
> +						&page_table, &ptl)) {
> +				ret = VM_FAULT_RETRY;
> +				goto out;
> +			}
>  			if (likely(pte_same(*page_table, orig_pte)))
>  				ret = VM_FAULT_OOM;
>  			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
> @@ -2581,7 +2628,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	/*
>  	 * Back out if somebody else already faulted in this pte.
>  	 */
> -	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
> +		ret = VM_FAULT_RETRY;
> +		goto out_nolock;
> +	}
> +
>  	if (unlikely(!pte_same(*page_table, orig_pte)))
>  		goto out_nomap;
> 
> @@ -2622,7 +2673,8 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	unlock_page(page);
> 
>  	if (flags & FAULT_FLAG_WRITE) {
> -		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> +		ret |= do_wp_page(mm, vma, address, page_table, pmd,
> +				ptl, flags, pte, seq);
>  		if (ret & VM_FAULT_ERROR)
>  			ret &= VM_FAULT_ERROR;
>  		goto out;
> @@ -2635,8 +2687,9 @@ unlock:
>  out:
>  	return ret;
>  out_nomap:
> -	mem_cgroup_cancel_charge_swapin(ptr);
>  	pte_unmap_unlock(page_table, ptl);
> +out_nolock:
> +	mem_cgroup_cancel_charge_swapin(ptr);
>  out_page:
>  	unlock_page(page);
>  out_release:
> @@ -2650,18 +2703,19 @@ out_release:
>   * We return with mmap_sem still held, but pte unmapped and unlocked.
>   */
>  static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		unsigned int flags)
> +		unsigned long address, pmd_t *pmd, unsigned int flags,
> +		unsigned int seq)
>  {
>  	struct page *page;
>  	spinlock_t *ptl;
> -	pte_t entry;
> +	pte_t entry, *page_table;
> 
>  	if (!(flags & FAULT_FLAG_WRITE)) {
>  		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
>  						vma->vm_page_prot));
> -		ptl = pte_lockptr(mm, pmd);
> -		spin_lock(ptl);
> +		if (!pte_map_lock(mm, vma, address, pmd, flags, seq,
> +					&page_table, &ptl))
> +			return VM_FAULT_RETRY;
>  		if (!pte_none(*page_table))
>  			goto unlock;
>  		goto setpte;
> @@ -2684,7 +2738,12 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (vma->vm_flags & VM_WRITE)
>  		entry = pte_mkwrite(pte_mkdirty(entry));
> 
> -	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
> +		mem_cgroup_uncharge_page(page);
> +		page_cache_release(page);
> +		return VM_FAULT_RETRY;
> +	}
> +
>  	if (!pte_none(*page_table))
>  		goto release;
> 
> @@ -2722,8 +2781,8 @@ oom:
>   * We return with mmap_sem still held, but pte unmapped and unlocked.
>   */
>  static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, pmd_t *pmd,
> -		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
> +		unsigned long address, pmd_t *pmd, pgoff_t pgoff,
> +		unsigned int flags, pte_t orig_pte, unsigned int seq)
>  {
>  	pte_t *page_table;
>  	spinlock_t *ptl;
> @@ -2823,7 +2882,10 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 
>  	}
> 
> -	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &page_table, &ptl)) {
> +		ret = VM_FAULT_RETRY;
> +		goto out_uncharge;
> +	}
> 
>  	/*
>  	 * This silly early PAGE_DIRTY setting removes a race
> @@ -2856,7 +2918,10 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 
>  		/* no need to invalidate: a not-present page won't be cached */
>  		update_mmu_cache(vma, address, entry);
> +		pte_unmap_unlock(page_table, ptl);
>  	} else {
> +		pte_unmap_unlock(page_table, ptl);
> +out_uncharge:
>  		if (charged)
>  			mem_cgroup_uncharge_page(page);
>  		if (anon)
> @@ -2865,8 +2930,6 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  			anon = 1; /* no anon but release faulted_page */
>  	}
> 
> -	pte_unmap_unlock(page_table, ptl);
> -
>  out:
>  	if (dirty_page) {
>  		struct address_space *mapping = page->mapping;
> @@ -2900,14 +2963,13 @@ unwritable_page:
>  }
> 
>  static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		unsigned int flags, pte_t orig_pte)
> +		unsigned long address, pmd_t *pmd,
> +		unsigned int flags, pte_t orig_pte, unsigned int seq)
>  {
>  	pgoff_t pgoff = (((address & PAGE_MASK)
>  			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> 
> -	pte_unmap(page_table);
> -	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
> +	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte, seq);
>  }
> 
>  /*
> @@ -2920,16 +2982,13 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   * We return with mmap_sem still held, but pte unmapped and unlocked.
>   */
>  static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, pte_t *page_table, pmd_t *pmd,
> -		unsigned int flags, pte_t orig_pte)
> +		unsigned long address, pmd_t *pmd,
> +		unsigned int flags, pte_t orig_pte, unsigned int seq)
>  {
>  	pgoff_t pgoff;
> 
>  	flags |= FAULT_FLAG_NONLINEAR;
> 
> -	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
> -		return 0;
> -
>  	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
>  		/*
>  		 * Page table corrupted: show pte and kill process.
> @@ -2939,7 +2998,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	}
> 
>  	pgoff = pte_to_pgoff(orig_pte);
> -	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
> +	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte, seq);
>  }
> 
>  /*
> @@ -2957,37 +3016,38 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>   */
>  static inline int handle_pte_fault(struct mm_struct *mm,
>  		struct vm_area_struct *vma, unsigned long address,
> -		pte_t *pte, pmd_t *pmd, unsigned int flags)
> +		pte_t entry, pmd_t *pmd, unsigned int flags,
> +		unsigned int seq)
>  {
> -	pte_t entry;
>  	spinlock_t *ptl;
> +	pte_t *pte;
> 
> -	entry = *pte;
>  	if (!pte_present(entry)) {
>  		if (pte_none(entry)) {
>  			if (vma->vm_ops) {
>  				if (likely(vma->vm_ops->fault))
>  					return do_linear_fault(mm, vma, address,
> -						pte, pmd, flags, entry);
> +						pmd, flags, entry, seq);
>  			}
>  			return do_anonymous_page(mm, vma, address,
> -						 pte, pmd, flags);
> +						 pmd, flags, seq);
>  		}
>  		if (pte_file(entry))
>  			return do_nonlinear_fault(mm, vma, address,
> -					pte, pmd, flags, entry);
> +					pmd, flags, entry, seq);
>  		return do_swap_page(mm, vma, address,
> -					pte, pmd, flags, entry);
> +					pmd, flags, entry, seq);
>  	}
> 
> -	ptl = pte_lockptr(mm, pmd);
> -	spin_lock(ptl);
> +	if (!pte_map_lock(mm, vma, address, pmd, flags, seq, &pte, &ptl))
> +		return VM_FAULT_RETRY;
>  	if (unlikely(!pte_same(*pte, entry)))
>  		goto unlock;
>  	if (flags & FAULT_FLAG_WRITE) {
> -		if (!pte_write(entry))
> +		if (!pte_write(entry)) {
>  			return do_wp_page(mm, vma, address,
> -					pte, pmd, ptl, entry);
> +					pte, pmd, ptl, flags, entry, seq);
> +		}
>  		entry = pte_mkdirty(entry);
>  	}
>  	entry = pte_mkyoung(entry);
> @@ -3017,7 +3077,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pmd_t *pmd;
> -	pte_t *pte;
> +	pte_t *pte, entry;
> 
>  	__set_current_state(TASK_RUNNING);
> 
> @@ -3037,9 +3097,60 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (!pte)
>  		return VM_FAULT_OOM;
> 
> -	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
> +	entry = *pte;
> +
> +	pte_unmap(pte);
> +
> +	return handle_pte_fault(mm, vma, address, entry, pmd, flags, 0);
> +}
> +
> +int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
> +		unsigned int flags)
> +{
> +	pmd_t *pmd = NULL;
> +	pte_t *pte, entry;
> +	spinlock_t *ptl;
> +	struct vm_area_struct *vma;
> +	unsigned int seq;
> +	int ret = VM_FAULT_RETRY;
> +	int dead;
> +
> +	__set_current_state(TASK_RUNNING);
> +	flags |= FAULT_FLAG_SPECULATIVE;
> +
> +	count_vm_event(PGFAULT);
> +
> +	rcu_read_lock();
> +	if (!pte_map_lock(mm, NULL, address, pmd, flags, 0, &pte, &ptl))
> +		goto out_unlock;
> +
> +	vma = find_vma(mm, address);
> +	if (!(vma && vma->vm_end > address && vma->vm_start <= address))
> +		goto out_unmap;
> +
> +	dead = RB_EMPTY_NODE(&vma->vm_rb);
> +	seq = vma->vm_sequence.sequence;
> +	smp_rmb();
> +
> +	if (dead || seq & 1)
> +		goto out_unmap;
> +
> +	entry = *pte;
> +
> +	pte_unmap_unlock(pte, ptl);
> +
> +	ret = handle_pte_fault(mm, vma, address, entry, pmd, flags, seq);
> +
> +out_unlock:
> +	rcu_read_unlock();
> +	return ret;
> +
> +out_unmap:
> +	pte_unmap_unlock(pte, ptl);
> +	goto out_unlock;
>  }
> 
> +
>  #ifndef __PAGETABLE_PUD_FOLDED
>  /*
>   * Allocate page upper directory.
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d9c77b2..024e406 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -222,6 +222,19 @@ void unlink_file_vma(struct vm_area_struct *vma)
>  	}
>  }
> 
> +static void free_vma_rcu(struct rcu_head *head)
> +{
> +	struct vm_area_struct *vma =
> +		container_of(head, struct vm_area_struct, vm_rcu_head);
> +
> +	kmem_cache_free(vm_area_cachep, vma);
> +}
> +
> +static void free_vma(struct vm_area_struct *vma)
> +{
> +	call_rcu(&vma->vm_rcu_head, free_vma_rcu);
> +}
> +
>  /*
>   * Close a vm structure and free it, returning the next.
>   */
> @@ -238,7 +251,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
>  			removed_exe_file_vma(vma->vm_mm);
>  	}
>  	mpol_put(vma_policy(vma));
> -	kmem_cache_free(vm_area_cachep, vma);
> +	free_vma(vma);
>  	return next;
>  }
> 
> @@ -488,6 +501,8 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
>  {
>  	prev->vm_next = vma->vm_next;
>  	rb_erase(&vma->vm_rb, &mm->mm_rb);
> +	smp_wmb();
> +	RB_CLEAR_NODE(&vma->vm_rb);
>  	if (mm->mmap_cache == vma)
>  		mm->mmap_cache = prev;
>  }
> @@ -512,6 +527,10 @@ void vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	long adjust_next = 0;
>  	int remove_next = 0;
> 
> +	write_seqcount_begin(&vma->vm_sequence);
> +	if (next)
> +		write_seqcount_begin(&next->vm_sequence);
> +
>  	if (next && !insert) {
>  		if (end >= next->vm_end) {
>  			/*
> @@ -640,18 +659,24 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  		mm->map_count--;
>  		mpol_put(vma_policy(next));
> -		kmem_cache_free(vm_area_cachep, next);
> +		free_vma(next);
>  		/*
>  		 * In mprotect's case 6 (see comments on vma_merge),
>  		 * we must remove another next too. It would clutter
>  		 * up the code too much to do both in one go.
>  		 */
>  		if (remove_next == 2) {
> +			write_seqcount_end(&next->vm_sequence);
>  			next = vma->vm_next;
> +			write_seqcount_begin(&next->vm_sequence);
>  			goto again;
>  		}
>  	}
> 
> +	if (next)
> +		write_seqcount_end(&next->vm_sequence);
> +	write_seqcount_end(&vma->vm_sequence);
> +
>  	validate_mm(mm);
>  }
> 
> @@ -1808,6 +1833,8 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
>  	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
>  	do {
>  		rb_erase(&vma->vm_rb, &mm->mm_rb);
> +		smp_wmb();
> +		RB_CLEAR_NODE(&vma->vm_rb);
>  		mm->map_count--;
>  		tail_vma = vma;
>  		vma = vma->vm_next;
> diff --git a/mm/util.c b/mm/util.c
> index b377ce4..1f5cfb7 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -257,8 +257,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm)
>   * callers need to carefully consider what to use. On many architectures,
>   * get_user_pages_fast simply falls back to get_user_pages.
>   */
> -int __attribute__((weak)) get_user_pages_fast(unsigned long start,
> -				int nr_pages, int write, struct page **pages)
> +int __weak get_user_pages_fast(unsigned long start,
> +			       int nr_pages, int write, struct page **pages)
>  {
>  	struct mm_struct *mm = current->mm;
>  	int ret;
> @@ -272,6 +272,14 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
>  }
>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
> 
> +void __weak pin_page_tables(void)
> +{
> +}
> +
> +void __weak unpin_page_tables(void)
> +{
> +}
> +
>  SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		unsigned long, prot, unsigned long, flags,
>  		unsigned long, fd, unsigned long, pgoff)
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
