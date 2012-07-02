Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CCB4C6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 00:08:01 -0400 (EDT)
Message-ID: <4FF11E7F.50708@redhat.com>
Date: Mon, 02 Jul 2012 00:07:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 24/40] autonuma: core
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-25-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-25-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On 06/28/2012 08:56 AM, Andrea Arcangeli wrote:

> +unsigned long autonuma_flags __read_mostly =
> +	(1<<AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG)|
> +	(1<<AUTONUMA_SCHED_CLONE_RESET_FLAG)|
> +	(1<<AUTONUMA_SCHED_FORK_RESET_FLAG)|
> +#ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
> +	(1<<AUTONUMA_FLAG)|
> +#endif
> +	(1<<AUTONUMA_SCAN_PMD_FLAG);

Please document what the flags mean.

> +static DEFINE_MUTEX(knumad_mm_mutex);

Wait, you are working on a patch to increase performance on
(large) NUMA systems, but you are introducing a new GLOBAL
LOCK that needs to be taken for a task to be added on the
knumad_scan list?

Can you change the locking of that list, so fork and exit
are not serialized on knumad_mm_mutex?  Maybe RCU?

> +static inline bool autonuma_impossible(void)
> +{
> +	return num_possible_nodes()<= 1 ||
> +		test_bit(AUTONUMA_IMPOSSIBLE_FLAG,&autonuma_flags);
> +}

This seems to test whether autonuma is enabled or
disabled, and is called from a few hot paths.

Would it be better to turn this into a variable,
so this can be tested with one single compare?

Also, something like autonuma_enabled or
autonuma_disabled could be a clearer name.

> +/* caller already holds the compound_lock */
> +void autonuma_migrate_split_huge_page(struct page *page,
> +				      struct page *page_tail)
> +{
> +	int nid, last_nid;
> +
> +	nid = page->autonuma_migrate_nid;
> +	VM_BUG_ON(nid>= MAX_NUMNODES);
> +	VM_BUG_ON(nid<  -1);
> +	VM_BUG_ON(page_tail->autonuma_migrate_nid != -1);
> +	if (nid>= 0) {
> +		VM_BUG_ON(page_to_nid(page) != page_to_nid(page_tail));
> +
> +		compound_lock(page_tail);

The comment above the function says that the caller already
holds the compound lock, yet we try to grab it again here?

Is this a deadlock, or simply an out of date comment?

Either way, it needs to be fixed.

A comment telling us what this function is supposed to
do would not hurt, either.

> +void __autonuma_migrate_page_remove(struct page *page)
> +{
> +	unsigned long flags;
> +	int nid;

In fact, every function larger than about 5 lines could use
a short comment describing what its purpose is.

> +static void __autonuma_migrate_page_add(struct page *page, int dst_nid,
> +					int page_nid)
> +{

I wonder if _enqueue and _rmqueue (for the previous function)
would make more sense, since we are adding and removing the
page from a queue?

> +	VM_BUG_ON(dst_nid>= MAX_NUMNODES);
> +	VM_BUG_ON(dst_nid<  -1);
> +	VM_BUG_ON(page_nid>= MAX_NUMNODES);
> +	VM_BUG_ON(page_nid<  -1);
> +
> +	VM_BUG_ON(page_nid == dst_nid);
> +	VM_BUG_ON(page_to_nid(page) != page_nid);
> +
> +	flags = compound_lock_irqsave(page);

What does this lock protect against?

Should we check that those things are still true, after we
have acquired the lock?

> +static void autonuma_migrate_page_add(struct page *page, int dst_nid,
> +				      int page_nid)
> +{
> +	int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
> +	if (migrate_nid != dst_nid)
> +		__autonuma_migrate_page_add(page, dst_nid, page_nid);
> +}

Wait, how are three three nids involved with the migration
of one page?

What is going on here, and why is there no comment explaining it?

> +static bool balance_pgdat(struct pglist_data *pgdat,
> +			  int nr_migrate_pages)
> +{
> +	/* FIXME: this only check the wmarks, make it move
> +	 * "unused" memory or pagecache by queuing it to
> +	 * pgdat->autonuma_migrate_head[pgdat->node_id].
> +	 */

vmscan.c also has a function called balance_pgdat, which does
something very different.

This function seems to check whether a node has enough free
memory. Maybe the name could reflect that?

> +static void cpu_follow_memory_pass(struct task_struct *p,
> +				   struct task_autonuma *task_autonuma,
> +				   unsigned long *task_numa_fault)
> +{
> +	int nid;
> +	for_each_node(nid)
> +		task_numa_fault[nid]>>= 1;
> +	task_autonuma->task_numa_fault_tot>>= 1;
> +}

This seems to age the statistic.  From the name I guess
it is called every pass, but something like numa_age_faults
might be a better name.

It could also use a short comment explaining why the statistics
are aged after each round, instead of zeroed out.

> +static void numa_hinting_fault_cpu_follow_memory(struct task_struct *p,
> +						 int access_nid,
> +						 int numpages,
> +						 bool pass)
> +{
> +	struct task_autonuma *task_autonuma = p->task_autonuma;
> +	unsigned long *task_numa_fault = task_autonuma->task_numa_fault;
> +	if (unlikely(pass))
> +		cpu_follow_memory_pass(p, task_autonuma, task_numa_fault);
> +	task_numa_fault[access_nid] += numpages;
> +	task_autonuma->task_numa_fault_tot += numpages;
> +}

Function name seems to have no bearing on what the function
actually does, which appears to be some kind of statistics
update...

There is no explanation of when pass would be true (or false).

> +static inline bool last_nid_set(struct task_struct *p,
> +				struct page *page, int cpu_nid)
> +{
> +	bool ret = true;
> +	int autonuma_last_nid = ACCESS_ONCE(page->autonuma_last_nid);
> +	VM_BUG_ON(cpu_nid<  0);
> +	VM_BUG_ON(cpu_nid>= MAX_NUMNODES);
> +	if (autonuma_last_nid>= 0&&  autonuma_last_nid != cpu_nid) {
> +		int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
> +		if (migrate_nid>= 0&&  migrate_nid != cpu_nid)
> +			__autonuma_migrate_page_remove(page);
> +		ret = false;
> +	}
> +	if (autonuma_last_nid != cpu_nid)
> +		ACCESS_ONCE(page->autonuma_last_nid) = cpu_nid;
> +	return ret;
> +}

This function confuses me. Why is there an ACCESS_ONCE
around something that is accessed three times?

It looks like it is trying to set some info on a page,
possibly where the page should be migrated to, and cancel
any migration if the page already has a destination other
than our destination?

It does not help that I have no idea what last_nid means,
because that was not documented in the earlier patches.
The function could use a comment regarding its purpose.

> +static int __page_migrate_nid(struct page *page, int page_nid)
> +{
> +	int migrate_nid = ACCESS_ONCE(page->autonuma_migrate_nid);
> +	if (migrate_nid<  0)
> +		migrate_nid = page_nid;
> +#if 0
> +	return page_nid;
> +#endif
> +	return migrate_nid;
> +}
> +
> +static int page_migrate_nid(struct page *page)
> +{
> +	return __page_migrate_nid(page, page_to_nid(page));
> +}

Why are there two functions that do the same thing?

Could this be collapsed into one function?

The #if 0 block could probably be removed, too.

> +static int knumad_scan_pmd(struct mm_struct *mm,
> +			   struct vm_area_struct *vma,
> +			   unsigned long address)

Like every other function, this one could use a comment
informing us of the general idea this function is supposed
to do.

> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte, *_pte;
> +	struct page *page;
> +	unsigned long _address, end;
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	VM_BUG_ON(address&  ~PAGE_MASK);
> +
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd))
> +		goto out;
> +	if (pmd_trans_huge(*pmd)) {

This is a very large function.  Would it make sense to split the
pmd_trans_huge stuff into its own function?

> +		spin_lock(&mm->page_table_lock);
> +		if (pmd_trans_huge(*pmd)) {
> +			VM_BUG_ON(address&  ~HPAGE_PMD_MASK);
> +			if (unlikely(pmd_trans_splitting(*pmd))) {
> +				spin_unlock(&mm->page_table_lock);
> +				wait_split_huge_page(vma->anon_vma, pmd);
> +			} else {
> +				int page_nid;
> +				unsigned long *numa_fault_tmp;
> +				ret = HPAGE_PMD_NR;
> +
> +				if (autonuma_scan_use_working_set()&&
> +				    pmd_numa(*pmd)) {
> +					spin_unlock(&mm->page_table_lock);
> +					goto out;
> +				}
> +
> +				page = pmd_page(*pmd);
> +
> +				/* only check non-shared pages */
> +				if (page_mapcount(page) != 1) {
> +					spin_unlock(&mm->page_table_lock);
> +					goto out;
> +				}
> +
> +				page_nid = page_migrate_nid(page);
> +				numa_fault_tmp = mm_autonuma_numa_fault_tmp(mm);
> +				numa_fault_tmp[page_nid] += ret;
> +
> +				if (pmd_numa(*pmd)) {
> +					spin_unlock(&mm->page_table_lock);
> +					goto out;
> +				}
> +
> +				set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
> +				/* defer TLB flush to lower the overhead */
> +				spin_unlock(&mm->page_table_lock);
> +				goto out;
> +			}
> +		} else
> +			spin_unlock(&mm->page_table_lock);
> +	}
> +
> +	VM_BUG_ON(!pmd_present(*pmd));
> +
> +	end = min(vma->vm_end, (address + PMD_SIZE)&  PMD_MASK);
> +	pte = pte_offset_map_lock(mm, pmd, address,&ptl);
> +	for (_address = address, _pte = pte; _address<  end;
> +	     _pte++, _address += PAGE_SIZE) {
> +		unsigned long *numa_fault_tmp;
> +		pte_t pteval = *_pte;
> +		if (!pte_present(pteval))
> +			continue;
> +		if (autonuma_scan_use_working_set()&&
> +		    pte_numa(pteval))
> +			continue;

What is autonuma_scan_use_working_set supposed to do exactly?

This looks like a subtle piece of code, but without any explanation
of what it should do, I cannot verify whether it actually does that.

> +		page = vm_normal_page(vma, _address, pteval);
> +		if (unlikely(!page))
> +			continue;
> +		/* only check non-shared pages */
> +		if (page_mapcount(page) != 1)
> +			continue;
> +
> +		numa_fault_tmp = mm_autonuma_numa_fault_tmp(mm);
> +		numa_fault_tmp[page_migrate_nid(page)]++;

> +		if (pte_numa(pteval))
> +			continue;

Wait, so we count all pages, even the ones that are PTE_NUMA
as if they incurred faults, even when they did not?

pte_present seems to return true for a numa pte...

> +		if (!autonuma_scan_pmd())
> +			set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
> +
> +		/* defer TLB flush to lower the overhead */
> +		ret++;
> +	}
> +	pte_unmap_unlock(pte, ptl);
> +
> +	if (ret&&  !pmd_numa(*pmd)&&  autonuma_scan_pmd()) {
> +		spin_lock(&mm->page_table_lock);
> +		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
> +		spin_unlock(&mm->page_table_lock);
> +		/* defer TLB flush to lower the overhead */
> +	}

So depending on whether autonuma_scan_pmd is true or false,
we behave differently.  That wants some documenting, near
both the !autonuma_scan_pmd code and the code below...

> +static void mm_numa_fault_flush(struct mm_struct *mm)
> +{
> +	int nid;
> +	struct mm_autonuma *mma = mm->mm_autonuma;
> +	unsigned long *numa_fault_tmp = mm_autonuma_numa_fault_tmp(mm);
> +	unsigned long tot = 0;
> +	/* FIXME: protect this with seqlock against autonuma_balance() */

Yes, please do.

> +static int knumad_do_scan(void)
> +{
> +	struct mm_struct *mm;
> +	struct mm_autonuma *mm_autonuma;
> +	unsigned long address;
> +	struct vm_area_struct *vma;
> +	int progress = 0;
> +
> +	mm = knumad_scan.mm;
> +	if (!mm) {
> +		if (unlikely(list_empty(&knumad_scan.mm_head)))
> +			return pages_to_scan;

Wait a moment, in knuma_scand() you have this line:

		_progress = knumad_do_scan();

Why are you pretending you made progress, when you did not
scan anything?

This is nothing a comment cannot illuminate :)

> +	down_read(&mm->mmap_sem);
> +	if (unlikely(knumad_test_exit(mm)))

This could use a short comment.

		/* The process is exiting */
> +		vma = NULL;
> +	else
> +		vma = find_vma(mm, address);

This loop could use some comments:

> +	for (; vma&&  progress<  pages_to_scan; vma = vma->vm_next) {
> +		unsigned long start_addr, end_addr;
> +		cond_resched();
		/* process is exiting */
> +		if (unlikely(knumad_test_exit(mm))) {
> +			progress++;
> +			break;
> +		}
		/* only do anonymous memory without explicit numa placement */
> +		if (!vma->anon_vma || vma_policy(vma)) {
> +			progress++;
> +			continue;
> +		}
> +		if (vma->vm_flags&  (VM_PFNMAP | VM_MIXEDMAP)) {
> +			progress++;
> +			continue;
> +		}
> +		if (is_vma_temporary_stack(vma)) {
> +			progress++;
> +			continue;
> +		}
> +
> +		VM_BUG_ON(address&  ~PAGE_MASK);
> +		if (address<  vma->vm_start)
> +			address = vma->vm_start;

How can this happen, when we did a find_vma above?

> +		flush_tlb_range(vma, start_addr, end_addr);
> +		mmu_notifier_invalidate_range_end(vma->vm_mm, start_addr,
> +						  end_addr);
> +	}
> +	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */

That does not seem like a certainty.  The process might not
exit for hours, or even days.

Also, mmap_sem protects against many more things than just
exit_mmap. It could also be mprotect, munmap or exec.

This may be the one comment in the series so far that is
best removed :)

> +static int knuma_scand(void *none)
> +{
> +	struct mm_struct *mm = NULL;
> +	int progress = 0, _progress;
> +	unsigned long total_progress = 0;
> +
> +	set_freezable();
> +
> +	knuma_scand_disabled();
> +
> +	mutex_lock(&knumad_mm_mutex);
> +
> +	for (;;) {
> +		if (unlikely(kthread_should_stop()))
> +			break;
> +		_progress = knumad_do_scan();
> +		progress += _progress;
> +		total_progress += _progress;

Huh?  Tracking both progress and total_progress?

There is no explanation of what the difference between these
two is, or why you need them.

> +	mm = knumad_scan.mm;
> +	knumad_scan.mm = NULL;
> +	if (mm&&  knumad_test_exit(mm)) {
> +		list_del(&mm->mm_autonuma->mm_node);
> +		/* tell autonuma_exit not to list_del */
> +		VM_BUG_ON(mm->mm_autonuma->mm != mm);
> +		mm->mm_autonuma->mm = NULL;
> +	}
> +	mutex_unlock(&knumad_mm_mutex);
> +
> +	if (mm)
> +		mmdrop(mm);
> +

Why doesn't knumad_do_scan take care of the mmdrop?

Doing this in the calling function is somewhat confusing.

I see that knumad_scan can hold the refcount of an mm
elevated in-between scans, for however long it sleeps.
Is that really something we want?

In the days where we did virtual scanning, the code in
vmscan.c simply moved a process to the end of the mm_list
once it was done with it, and the currently to-scan process
was always at the head of the list.

> +static int isolate_migratepages(struct list_head *migratepages,
> +				struct pglist_data *pgdat)

The kernel already has another function called isolate_migratepages.

Would be nice if this function could at least be documented to
state its purpose. Maybe renamed to make it clear this is the NUMA
specific version.

> +{
> +	int nr = 0, nid;
> +	struct list_head *heads = pgdat->autonuma_migrate_head;
> +
> +	/* FIXME: THP balancing, restart from last nid */

I guess a static variable in the pgdat struct could take care
of that?

> +		if (PageTransHuge(page)) {
> +			VM_BUG_ON(!PageAnon(page));
> +			/* FIXME: remove split_huge_page */

Fair enough. Other people are working on that code :)

> +		if (!__isolate_lru_page(page, 0)) {
> +			VM_BUG_ON(PageTransCompound(page));
> +			del_page_from_lru_list(page, lruvec, page_lru(page));
> +			inc_zone_state(zone, page_is_file_cache(page) ?
> +				       NR_ISOLATED_FILE : NR_ISOLATED_ANON);
> +			spin_unlock_irq(&zone->lru_lock);
> +			/*
> +			 * hold the page pin at least until
> +			 * __isolate_lru_page succeeds
> +			 * (__isolate_lru_page takes a second pin when
> +			 * it succeeds). If we release the pin before
> +			 * __isolate_lru_page returns, the page could
> +			 * have been freed and reallocated from under
> +			 * us, so rendering worthless our previous
> +			 * checks on the page including the
> +			 * split_huge_page call.
> +			 */
> +			put_page(page);
> +
> +			list_add(&page->lru, migratepages);
> +			nr += hpage_nr_pages(page);
> +		} else {
> +			/* FIXME: losing page, safest and simplest for now */

Losing page?  As in a memory leak?

Or as in	/* Something happened. Skip migrating the page. */ ?

> +static void knumad_do_migrate(struct pglist_data *pgdat)
> +{
> +	int nr_migrate_pages = 0;
> +	LIST_HEAD(migratepages);
> +
> +	autonuma_printk("nr_migrate_pages %lu to node %d\n",
> +			pgdat->autonuma_nr_migrate_pages, pgdat->node_id);
> +	do {
> +		int isolated = 0;
> +		if (balance_pgdat(pgdat, nr_migrate_pages))
> +			isolated = isolate_migratepages(&migratepages, pgdat);
> +		/* FIXME: might need to check too many isolated */

Would it help to have isolate_migratepages exit after it has
isolated a large enough number of pages?

I may be tired, but it looks like it is simply putting ALL
the to be migrated pages on the list, even if the number
is unreasonably large to migrate all at once.

> +		if (!isolated)
> +			break;
> +		nr_migrate_pages += isolated;
> +	} while (nr_migrate_pages<  pages_to_migrate);
> +
> +	if (nr_migrate_pages) {
> +		int err;
> +		autonuma_printk("migrate %d to node %d\n", nr_migrate_pages,
> +				pgdat->node_id);
> +		pages_migrated += nr_migrate_pages; /* FIXME: per node */
> +		err = migrate_pages(&migratepages, alloc_migrate_dst_page,
> +				    pgdat->node_id, false, true);
> +		if (err)
> +			/* FIXME: requeue failed pages */
> +			putback_lru_pages(&migratepages);

How about you add a parameter to your (renamed) isolate_migratepages
function to tell it how many pages you want at a time?

Then you could limit it to no more than the number of pages you have
available on the destination node.

> +void autonuma_enter(struct mm_struct *mm)
> +{
> +	if (autonuma_impossible())
> +		return;
> +
> +	mutex_lock(&knumad_mm_mutex);
> +	list_add_tail(&mm->mm_autonuma->mm_node,&knumad_scan.mm_head);
> +	mutex_unlock(&knumad_mm_mutex);
> +}

Adding a global lock to every fork seems like a really bad
idea. Please make this NUMA code more SMP friendly.

> +void autonuma_exit(struct mm_struct *mm)
> +{
> +	bool serialize;
> +
> +	if (autonuma_impossible())
> +		return;

And if you implement the "have the autonuma scanning
daemon allocate the mm_autonuma and task_autonuma
structures" idea, short lived processes can bail out
of autonuma_exit right here, without ever taking the
lock.

> +	serialize = false;
> +	mutex_lock(&knumad_mm_mutex);
> +	if (knumad_scan.mm == mm)
> +		serialize = true;
> +	else if (mm->mm_autonuma->mm) {
> +		VM_BUG_ON(mm->mm_autonuma->mm != mm);
> +		mm->mm_autonuma->mm = NULL; /* debug */
> +		list_del(&mm->mm_autonuma->mm_node);
> +	}
> +	mutex_unlock(&knumad_mm_mutex);
> +
> +	if (serialize) {
> +		/* prevent the mm to go away under knumad_do_scan main loop */
> +		down_write(&mm->mmap_sem);
> +		up_write(&mm->mmap_sem);

This is rather subtle.  A longer explanation could be good.

> +SYSFS_ENTRY(debug, AUTONUMA_DEBUG_FLAG);
> +SYSFS_ENTRY(pmd, AUTONUMA_SCAN_PMD_FLAG);
> +SYSFS_ENTRY(working_set, AUTONUMA_SCAN_USE_WORKING_SET_FLAG);
> +SYSFS_ENTRY(defer, AUTONUMA_MIGRATE_DEFER_FLAG);
> +SYSFS_ENTRY(load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
> +SYSFS_ENTRY(clone_reset, AUTONUMA_SCHED_CLONE_RESET_FLAG);
> +SYSFS_ENTRY(fork_reset, AUTONUMA_SCHED_FORK_RESET_FLAG);

> +#undef SYSFS_ENTRY
> +
> +enum {
> +	SYSFS_KNUMA_SCAND_SLEEP_ENTRY,
> +	SYSFS_KNUMA_SCAND_PAGES_ENTRY,
> +	SYSFS_KNUMA_MIGRATED_SLEEP_ENTRY,
> +	SYSFS_KNUMA_MIGRATED_PAGES_ENTRY,
> +};

Oh goodie, more magic flags.

Please document what they all mean.


> +SYSFS_ENTRY(scan_sleep_millisecs, SYSFS_KNUMA_SCAND_SLEEP_ENTRY);
> +SYSFS_ENTRY(scan_sleep_pass_millisecs, SYSFS_KNUMA_SCAND_SLEEP_ENTRY);
> +SYSFS_ENTRY(pages_to_scan, SYSFS_KNUMA_SCAND_PAGES_ENTRY);
> +
> +SYSFS_ENTRY(migrate_sleep_millisecs, SYSFS_KNUMA_MIGRATED_SLEEP_ENTRY);
> +SYSFS_ENTRY(pages_to_migrate, SYSFS_KNUMA_MIGRATED_PAGES_ENTRY);

These as well.

> +SYSFS_ENTRY(full_scans);
> +SYSFS_ENTRY(pages_scanned);
> +SYSFS_ENTRY(pages_migrated);

The same goes for the statistics.

Documentation, documentation, documentation.

And please don't tell me "full scans" in autonuma means
the same thing it means in KSM, because I still do not
know what it means in KSM...


> +static inline void autonuma_exit_sysfs(struct kobject *autonuma_kobj)
> +{
> +}
> +#endif /* CONFIG_SYSFS */
> +
> +static int __init noautonuma_setup(char *str)
> +{
> +	if (!autonuma_impossible()) {
> +		printk("AutoNUMA permanently disabled\n");
> +		set_bit(AUTONUMA_IMPOSSIBLE_FLAG,&autonuma_flags);

Ohhh, my guess was right.  autonuma_impossible really does
mean autonuma_disabled :)

> +int alloc_task_autonuma(struct task_struct *tsk, struct task_struct *orig,
> +			 int node)
> +{

This looks like something that can be done by the
numa scanning daemon.

> +void free_task_autonuma(struct task_struct *tsk)
> +{
> +	if (autonuma_impossible()) {
> +		BUG_ON(tsk->task_autonuma);
> +		return;
> +	}
> +
> +	BUG_ON(!tsk->task_autonuma);

And this looks like a desired thing, for short lived tasks :)

> +	kmem_cache_free(task_autonuma_cachep, tsk->task_autonuma);
> +	tsk->task_autonuma = NULL;
> +}

> +void free_mm_autonuma(struct mm_struct *mm)
> +{
> +	if (autonuma_impossible()) {
> +		BUG_ON(mm->mm_autonuma);
> +		return;
> +	}
> +
> +	BUG_ON(!mm->mm_autonuma);

Ditto for mm_autonuma

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
