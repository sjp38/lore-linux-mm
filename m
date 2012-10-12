Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7BF916B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 20:52:26 -0400 (EDT)
Date: Fri, 12 Oct 2012 02:52:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 07/33] autonuma: mm_autonuma and task_autonuma data
 structures
Message-ID: <20121012005200.GA1818@redhat.com>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-8-git-send-email-aarcange@redhat.com>
 <20121011122827.GT3317@csn.ul.ie>
 <5076E4B2.2040301@redhat.com>
 <0000013a525a8739-2b4049fa-1cb3-4b8f-b3a7-1fa77b181590-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013a525a8739-2b4049fa-1cb3-4b8f-b3a7-1fa77b181590-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Hi Christoph,

On Fri, Oct 12, 2012 at 12:23:17AM +0000, Christoph Lameter wrote:
> On Thu, 11 Oct 2012, Rik van Riel wrote:
> 
> > These statistics are updated at page fault time, I
> > believe while holding the page table lock.
> >
> > In other words, they are in code paths where updating
> > the stats should not cause issues.
> 
> The per cpu counters in the VM were introduced because of
> counter contention caused at page fault time. This is the same code path
> where you think that there cannot be contention.

There's no contention at all in autonuma27.

I changed it in autonuma28, to get real time updates in mm_autonuma
from migration events.

There is no lock taken though (the spinlock below is taken once every
pass, very rarely). It's a few liner change shown in detail below. The
only contention point is this:

+	ACCESS_ONCE(mm_numa_fault[access_nid]) += numpages;
+	ACCESS_ONCE(mm_autonuma->mm_numa_fault_tot) += numpages;

autonuma28 is much more experimental than autonuma27 :)

I wouldn't focus on >1024 CPU systems for this though. The bigger the
system the more costly any automatic placement logic will become, no
matter which algorithm and which computation complexity the algorithm
has, and chances are those will use NUMA hard bindings anyway
considering how much they're expensive to setup and maintain.

The diff looks like this, I can consider undoing it. Comments
welcome. (but real time stats updates, converge faster in autonuma28)

--- a/mm/autonuma.c
+++ b/mm/autonuma.c
 
 static struct knuma_scand_data {
 	struct list_head mm_head; /* entry: mm->mm_autonuma->mm_node */
 	struct mm_struct *mm;
 	unsigned long address;
-	unsigned long *mm_numa_fault_tmp;
 } knuma_scand_data = {
 	.mm_head = LIST_HEAD_INIT(knuma_scand_data.mm_head),
 };






+	unsigned long tot;
+
+	/*
+	 * Set the task's fault_pass equal to the new
+	 * mm's fault_pass, so new_pass will be false
+	 * on the next fault by this thread in this
+	 * same pass.
+	 */
+	p->task_autonuma->task_numa_fault_pass = mm_numa_fault_pass;
+
 	/* If a new pass started, degrade the stats by a factor of 2 */
 	for_each_node(nid)
 		task_numa_fault[nid] >>= 1;
 	task_autonuma->task_numa_fault_tot >>= 1;
+
+	if (mm_numa_fault_pass ==
+	    ACCESS_ONCE(mm_autonuma->mm_numa_fault_last_pass))
+		return;
+
+	spin_lock(&mm_autonuma->mm_numa_fault_lock);
+	if (unlikely(mm_numa_fault_pass ==
+		     mm_autonuma->mm_numa_fault_last_pass)) {
+		spin_unlock(&mm_autonuma->mm_numa_fault_lock);
+		return;
+	}
+	mm_autonuma->mm_numa_fault_last_pass = mm_numa_fault_pass;
+
+	tot = 0;
+	for_each_node(nid) {
+		unsigned long fault = ACCESS_ONCE(mm_numa_fault[nid]);
+		fault >>= 1;
+		ACCESS_ONCE(mm_numa_fault[nid]) = fault;
+		tot += fault;
+	}
+	mm_autonuma->mm_numa_fault_tot = tot;
+	spin_unlock(&mm_autonuma->mm_numa_fault_lock);
 }






 	task_numa_fault[access_nid] += numpages;
 	task_autonuma->task_numa_fault_tot += numpages;
 
+	ACCESS_ONCE(mm_numa_fault[access_nid]) += numpages;
+	ACCESS_ONCE(mm_autonuma->mm_numa_fault_tot) += numpages;
+
 	local_bh_enable();
 }
 
@@ -310,28 +355,35 @@ static void numa_hinting_fault_cpu_follow_memory(struct task_struct *p,
@@ -593,35 +628,26 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		goto out;
 
 	if (pmd_trans_huge_lock(pmd, vma) == 1) {
-		int page_nid;
-		unsigned long *fault_tmp;
 		ret = HPAGE_PMD_NR;
 
 		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
-		if (autonuma_mm_working_set() && pmd_numa(*pmd)) {
+		if (pmd_numa(*pmd)) {
 			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
-
 		page = pmd_page(*pmd);
-
 		/* only check non-shared pages */
 		if (page_mapcount(page) != 1) {
 			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
-
-		page_nid = page_to_nid(page);
-		fault_tmp = knuma_scand_data.mm_numa_fault_tmp;
-		fault_tmp[page_nid] += ret;
-
 		if (pmd_numa(*pmd)) {
 			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
-
 		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
+
 		/* defer TLB flush to lower the overhead */
 		spin_unlock(&mm->page_table_lock);
 		goto out;
@@ -636,10 +662,9 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _address < end;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
-		unsigned long *fault_tmp;
 		if (!pte_present(pteval))
 			continue;
-		if (autonuma_mm_working_set() && pte_numa(pteval))
+		if (pte_numa(pteval))
 			continue;
 		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
@@ -647,13 +672,8 @@ static int knuma_scand_pmd(struct mm_struct *mm,
 		/* only check non-shared pages */
 		if (page_mapcount(page) != 1)
 			continue;
-
-		fault_tmp = knuma_scand_data.mm_numa_fault_tmp;
-		fault_tmp[page_to_nid(page)]++;
-
 		if (pte_numa(pteval))
 			continue;
-
 		if (!autonuma_scan_pmd())
 			set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
 
@@ -677,56 +697,6 @@ out:
 	return ret;
 }
 
-static void mm_numa_fault_tmp_flush(struct mm_struct *mm)
-{
-	int nid;
-	struct mm_autonuma *mma = mm->mm_autonuma;
-	unsigned long tot;
-	unsigned long *fault_tmp = knuma_scand_data.mm_numa_fault_tmp;
-
-	if (autonuma_mm_working_set()) {
-		for_each_node(nid) {
-			tot = fault_tmp[nid];
-			if (tot)
-				break;
-		}
-		if (!tot)
-			/* process was idle, keep the old data */
-			return;
-	}
-
-	/* FIXME: would be better protected with write_seqlock_bh() */
-	local_bh_disable();
-
-	tot = 0;
-	for_each_node(nid) {
-		unsigned long faults = fault_tmp[nid];
-		fault_tmp[nid] = 0;
-		mma->mm_numa_fault[nid] = faults;
-		tot += faults;
-	}
-	mma->mm_numa_fault_tot = tot;
-
-	local_bh_enable();
-}
-
-static void mm_numa_fault_tmp_reset(void)
-{
-	memset(knuma_scand_data.mm_numa_fault_tmp, 0,
-	       mm_autonuma_fault_size());
-}
-
-static inline void validate_mm_numa_fault_tmp(unsigned long address)
-{
-#ifdef CONFIG_DEBUG_VM
-	int nid;
-	if (address)
-		return;
-	for_each_node(nid)
-		BUG_ON(knuma_scand_data.mm_numa_fault_tmp[nid]);
-#endif
-}
-
 /*
  * Scan the next part of the mm. Keep track of the progress made and
  * return it.
@@ -758,8 +728,6 @@ static int knumad_do_scan(void)
 	}
 	address = knuma_scand_data.address;
 
-	validate_mm_numa_fault_tmp(address);
-
 	mutex_unlock(&knumad_mm_mutex);
 
 	down_read(&mm->mmap_sem);
@@ -855,9 +824,7 @@ static int knumad_do_scan(void)
 			/* tell autonuma_exit not to list_del */
 			VM_BUG_ON(mm->mm_autonuma->mm != mm);
 			mm->mm_autonuma->mm = NULL;
-			mm_numa_fault_tmp_reset();
-		} else
-			mm_numa_fault_tmp_flush(mm);
+		}
 
 		mmdrop(mm);
 	}
@@ -942,7 +916,6 @@ static int knuma_scand(void *none)
 
 	if (mm)
 		mmdrop(mm);
-	mm_numa_fault_tmp_reset();
 
 	return 0;
 }
@@ -987,11 +960,6 @@ static int start_knuma_scand(void)
 	int err = 0;
 	struct task_struct *knumad_thread;
 
-	knuma_scand_data.mm_numa_fault_tmp = kzalloc(mm_autonuma_fault_size(),
-						     GFP_KERNEL);
-	if (!knuma_scand_data.mm_numa_fault_tmp)
-		return -ENOMEM;
-
 	knumad_thread = kthread_run(knuma_scand, NULL, "knuma_scand");
 	if (unlikely(IS_ERR(knumad_thread))) {
 		autonuma_printk(KERN_ERR

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
