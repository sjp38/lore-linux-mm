Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id D65956B0072
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 07:59:30 -0500 (EST)
Received: by wevm14 with SMTP id m14so17852058wev.8
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 04:59:30 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ff5si17558448wib.13.2015.02.23.04.59.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 04:59:21 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 4/6] mm, thp: move collapsing from khugepaged to task_work context
Date: Mon, 23 Feb 2015 13:58:40 +0100
Message-Id: <1424696322-21952-5-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

Moving the THP scanning and collapsing work to task_work context allows us to
balance and account for the effort per each task, and get rid of the mm_slot
infrastructure needed for khugepaged, among other things.

This patch implements the scanning from task_work context by essentially
copying the way that the automatic NUMA balancing is performed. It's currently
missing some details such as atomatically adjusting the delay between scan
attempts based on recent collapse success rates, etc.

After this patch, khugepaged remains to perform just the expensive hugepage
allocation attempts, which could easily offset the benefits of THP for the
process, if it was to perfom them in its context. The allocation attempts from
process context do not use sync compaction, and the previously introduced
per-node hugepage availability tracking should further reduce failed collapse
attemps. The next patch will improve the coordination between collapsers and
khugepaged.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/khugepaged.h |   5 +
 include/linux/mm_types.h   |   4 +
 include/linux/sched.h      |   5 +
 kernel/sched/core.c        |  12 +++
 kernel/sched/fair.c        | 124 ++++++++++++++++++++++++-
 mm/huge_memory.c           | 225 +++++++++++++--------------------------------
 6 files changed, 210 insertions(+), 165 deletions(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index eeb3079..51b2cc5 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -4,10 +4,15 @@
 #include <linux/sched.h> /* MMF_VM_HUGEPAGE */
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern unsigned int khugepaged_pages_to_scan;
+extern unsigned int khugepaged_scan_sleep_millisecs;
 extern int __khugepaged_enter(struct mm_struct *mm);
 extern void __khugepaged_exit(struct mm_struct *mm);
 extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 				      unsigned long vm_flags);
+extern bool khugepaged_scan_mm(struct mm_struct *mm,
+			       unsigned long *start,
+			       long pages);
 
 #define khugepaged_enabled()					       \
 	(transparent_hugepage_flags &				       \
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03a..b3587e6 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -451,6 +451,10 @@ struct mm_struct {
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	unsigned long thp_next_scan;
+	unsigned long thp_scan_address;
+#endif
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 	/*
 	 * An operation with batched TLB flushing is going on. Anything that
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d77432..22a59fe 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1633,6 +1633,11 @@ struct task_struct {
 
 	unsigned long numa_pages_migrated;
 #endif /* CONFIG_NUMA_BALANCING */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	u64 thp_scan_last;
+	unsigned int thp_scan_period;
+	struct callback_head thp_work;
+#endif
 
 	struct rcu_head rcu;
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index f0f831e..9389d13 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -32,6 +32,7 @@
 #include <linux/init.h>
 #include <linux/uaccess.h>
 #include <linux/highmem.h>
+#include <linux/khugepaged.h>
 #include <asm/mmu_context.h>
 #include <linux/interrupt.h>
 #include <linux/capability.h>
@@ -1823,6 +1824,17 @@ static void __sched_fork(unsigned long clone_flags, struct task_struct *p)
 
 	p->numa_group = NULL;
 #endif /* CONFIG_NUMA_BALANCING */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	if (p->mm && atomic_read(&p->mm->mm_users) == 1) {
+		//TODO: have separate initial delay like NUMA_BALANCING?
+		p->mm->thp_next_scan = jiffies +
+					khugepaged_scan_sleep_millisecs;
+		p->mm->thp_scan_address = 0;
+	}
+	p->thp_scan_last = 0ULL;
+	p->thp_scan_period = khugepaged_scan_sleep_millisecs; //TODO: ditto
+	p->thp_work.next = &p->thp_work;
+#endif
 }
 
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 7ce18f3..551cbde 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -30,6 +30,7 @@
 #include <linux/mempolicy.h>
 #include <linux/migrate.h>
 #include <linux/task_work.h>
+#include <linux/khugepaged.h>
 
 #include <trace/events/sched.h>
 
@@ -2220,7 +2221,7 @@ out:
 /*
  * Drive the periodic memory faults..
  */
-void task_tick_numa(struct rq *rq, struct task_struct *curr)
+static bool task_tick_numa(struct rq *rq, struct task_struct *curr)
 {
 	struct callback_head *work = &curr->numa_work;
 	u64 period, now;
@@ -2229,7 +2230,7 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 	 * We don't care about NUMA placement if we don't have memory.
 	 */
 	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
-		return;
+		return false;
 
 	/*
 	 * Using runtime rather than walltime has the dual advantage that
@@ -2248,12 +2249,15 @@ void task_tick_numa(struct rq *rq, struct task_struct *curr)
 		if (!time_before(jiffies, curr->mm->numa_next_scan)) {
 			init_task_work(work, task_numa_work); /* TODO: move this into sched_fork() */
 			task_work_add(curr, work, true);
+			return true;
 		}
 	}
+	return false;
 }
 #else
-static void task_tick_numa(struct rq *rq, struct task_struct *curr)
+static bool task_tick_numa(struct rq *rq, struct task_struct *curr)
 {
+	return false;
 }
 
 static inline void account_numa_enqueue(struct rq *rq, struct task_struct *p)
@@ -2265,6 +2269,109 @@ static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * Entry point for THP collapse scanning
+ */
+void task_thp_work(struct callback_head *work)
+{
+	unsigned long now = jiffies;
+	struct task_struct *p = current;
+	unsigned long current_scan, next_scan;
+	struct mm_struct *mm = current->mm;
+	unsigned long start;
+	long pages;
+
+	WARN_ON_ONCE(p != container_of(work, struct task_struct, thp_work));
+
+	work->next = work; /* allows the work item to be scheduled again */
+	/*
+	 * Who cares about THP's when they're dying.
+	 *
+	 * NOTE: make sure not to dereference p->mm before this check,
+	 * exit_task_work() happens _after_ exit_mm() so we could be called
+	 * without p->mm even though we still had it when we enqueued this
+	 * work.
+	 */
+	if (p->flags & PF_EXITING)
+		return;
+
+	//TODO: separate initial delay like NUMA_BALANCING has?
+	if (!mm->thp_next_scan) {
+		mm->thp_next_scan = now +
+			msecs_to_jiffies(khugepaged_scan_sleep_millisecs);
+	}
+
+	//TODO automatic tuning of scan frequency?
+	current_scan = mm->thp_next_scan;
+
+	/*
+	 * Set the moment of the next THP scan. This should generally rule out
+	 * that other thread executes task_thp_work at the same time as us,
+	 * but it's not guaranteed. It's not a safety issue though, just
+	 * efficiency.
+	 */
+	if (time_before(now, current_scan))
+		return;
+
+	next_scan = now + msecs_to_jiffies(p->thp_scan_period);
+	if (cmpxchg(&mm->thp_next_scan, current_scan, next_scan)
+							!= current_scan)
+		return;
+
+	/*
+	 * Delay this task enough that another task of this mm will likely win
+	 * the next time around.
+	 */
+	p->thp_scan_last += 2*TICK_NSEC;
+
+	start = mm->thp_scan_address;
+	pages = khugepaged_pages_to_scan;
+
+	khugepaged_scan_mm(mm, &start, pages);
+
+	mm->thp_scan_address = start;
+}
+/*
+ * Drive the periodic scanning for THP collapses
+ */
+void task_tick_thp(struct rq *rq, struct task_struct *curr)
+{
+	struct callback_head *work = &curr->thp_work;
+	u64 period, now;
+
+	/*
+	 * We don't care about THP collapses if we don't have memory.
+	 */
+	if (!curr->mm || (curr->flags & PF_EXITING) || work->next != work)
+		return;
+
+	/* We don't care bout MM with no eligible VMAs */
+	if (!test_bit(MMF_VM_HUGEPAGE, &curr->mm->flags))
+		return;
+
+	/*
+	 * Using runtime rather than walltime has the dual advantage that
+	 * we (mostly) drive the scanning from busy threads and that the
+	 * task needs to have done some actual work before we bother with
+	 * THP collapses.
+	 */
+	now = curr->se.sum_exec_runtime;
+	period = (u64)curr->thp_scan_period * NSEC_PER_MSEC;
+
+	if (now - curr->thp_scan_last > period) {
+		if (!curr->thp_scan_last)
+			curr->thp_scan_period = khugepaged_scan_sleep_millisecs;
+		curr->thp_scan_last += period;
+
+		if (!time_before(jiffies, curr->mm->thp_next_scan)) {
+			init_task_work(work, task_thp_work); /* TODO: move this into sched_fork() */
+			task_work_add(curr, work, true);
+		}
+	}
+}
+#endif
+
 static void
 account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
@@ -7713,8 +7820,15 @@ static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
 		entity_tick(cfs_rq, se, queued);
 	}
 
-	if (numabalancing_enabled)
-		task_tick_numa(rq, curr);
+	/*
+	 * For latency considerations, don't schedule the THP work together
+	 * with NUMA work. NUMA has higher priority, assuming remote accesses
+	 * have worse penalty than TLB misses.
+	 */
+	if (!(numabalancing_enabled && task_tick_numa(rq, curr))
+						&& khugepaged_enabled())
+		task_tick_thp(rq, curr);
+
 
 	update_rq_runnable_avg(rq, 1);
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1eec1a6..1c92edc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -48,10 +48,10 @@ unsigned long transparent_hugepage_flags __read_mostly =
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
-static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
+unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
 static unsigned int khugepaged_pages_collapsed;
 static unsigned int khugepaged_full_scans;
-static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
+unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
 static struct task_struct *khugepaged_thread __read_mostly;
@@ -2258,9 +2258,7 @@ static void khugepaged_alloc_sleep(void)
 			msecs_to_jiffies(khugepaged_alloc_sleep_millisecs));
 }
 
-static int khugepaged_node_load[MAX_NUMNODES];
-
-static bool khugepaged_scan_abort(int nid)
+static bool khugepaged_scan_abort(int nid, int *node_load)
 {
 	int i;
 
@@ -2268,7 +2266,7 @@ static bool khugepaged_scan_abort(int nid)
 	 * If it's clear that we are going to select a node where THP
 	 * allocation is unlikely to succeed, abort
 	 */
-	if (khugepaged_node_load[nid] == (HPAGE_PMD_NR) / 2 &&
+	if (node_load[nid] == (HPAGE_PMD_NR) / 2 &&
 				!node_isset(nid, thp_avail_nodes))
 		return true;
 
@@ -2280,11 +2278,11 @@ static bool khugepaged_scan_abort(int nid)
 		return false;
 
 	/* If there is a count for this node already, it must be acceptable */
-	if (khugepaged_node_load[nid])
+	if (node_load[nid])
 		return false;
 
 	for (i = 0; i < MAX_NUMNODES; i++) {
-		if (!khugepaged_node_load[i])
+		if (!node_load[i])
 			continue;
 		if (node_distance(nid, i) > RECLAIM_DISTANCE)
 			return true;
@@ -2293,15 +2291,15 @@ static bool khugepaged_scan_abort(int nid)
 }
 
 #ifdef CONFIG_NUMA
-static int khugepaged_find_target_node(void)
+static int khugepaged_find_target_node(int *node_load)
 {
 	static int last_khugepaged_target_node = NUMA_NO_NODE;
 	int nid, target_node = 0, max_value = 0;
 
 	/* find first node with max normal pages hit */
 	for (nid = 0; nid < MAX_NUMNODES; nid++)
-		if (khugepaged_node_load[nid] > max_value) {
-			max_value = khugepaged_node_load[nid];
+		if (node_load[nid] > max_value) {
+			max_value = node_load[nid];
 			target_node = nid;
 		}
 
@@ -2309,7 +2307,7 @@ static int khugepaged_find_target_node(void)
 	if (target_node <= last_khugepaged_target_node)
 		for (nid = last_khugepaged_target_node + 1; nid < MAX_NUMNODES;
 				nid++)
-			if (max_value == khugepaged_node_load[nid]) {
+			if (max_value == node_load[nid]) {
 				target_node = nid;
 				break;
 			}
@@ -2324,7 +2322,7 @@ static inline struct page *alloc_hugepage_node(gfp_t gfp, int node)
 							HPAGE_PMD_ORDER);
 }
 #else
-static int khugepaged_find_target_node(void)
+static int khugepaged_find_target_node(int *node_load)
 {
 	return 0;
 }
@@ -2368,7 +2366,7 @@ static struct page
 }
 
 /* Return true, if THP should be allocatable on at least one node */
-static bool khugepaged_check_nodes(struct page **hpage)
+static bool khugepaged_check_nodes(void)
 {
 	bool ret = false;
 	int nid;
@@ -2386,18 +2384,10 @@ static bool khugepaged_check_nodes(struct page **hpage)
 		if (newpage) {
 			node_set(nid, thp_avail_nodes);
 			ret = true;
-			/*
-			 * Heuristic - try to hold on to the page for collapse
-			 * scanning, if we don't hold any yet.
-			 */
-			if (IS_ERR_OR_NULL(*hpage)) {
-				*hpage = newpage;
-				//NIXME: should we count all/no allocations?
-				count_vm_event(THP_COLLAPSE_ALLOC);
-			} else {
-				put_page(newpage);
-			}
+			put_page(newpage);
 		}
+		if (unlikely(kthread_should_stop() || freezing(current)))
+			break;
 	}
 
 	return ret;
@@ -2544,6 +2534,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	*hpage = NULL;
 
+	//FIXME: this is racy
 	khugepaged_pages_collapsed++;
 out_up_write:
 	up_write(&mm->mmap_sem);
@@ -2557,7 +2548,8 @@ out:
 static int khugepaged_scan_pmd(struct mm_struct *mm,
 			       struct vm_area_struct *vma,
 			       unsigned long address,
-			       struct page **hpage)
+			       struct page **hpage,
+			       int *node_load)
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
@@ -2574,7 +2566,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	if (!pmd)
 		goto out;
 
-	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
+	memset(node_load, 0, sizeof(int) * MAX_NUMNODES);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
@@ -2595,14 +2587,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 			goto out_unmap;
 		/*
 		 * Record which node the original page is from and save this
-		 * information to khugepaged_node_load[].
+		 * information to node_load[].
 		 * Khupaged will allocate hugepage from the node has the max
 		 * hit record.
 		 */
 		node = page_to_nid(page);
-		if (khugepaged_scan_abort(node))
+		if (khugepaged_scan_abort(node, node_load))
 			goto out_unmap;
-		khugepaged_node_load[node]++;
+		node_load[node]++;
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
 			goto out_unmap;
@@ -2622,7 +2614,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret) {
-		node = khugepaged_find_target_node();
+		node = khugepaged_find_target_node(node_load);
 		if (!node_isset(node, thp_avail_nodes)) {
 			ret = 0;
 			goto out;
@@ -2657,112 +2649,61 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 	}
 }
 
-static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
-					    struct page **hpage)
-	__releases(&khugepaged_mm_lock)
-	__acquires(&khugepaged_mm_lock)
+bool khugepaged_scan_mm(struct mm_struct *mm, unsigned long *start, long pages)
 {
-	struct mm_slot *mm_slot;
-	struct mm_struct *mm;
 	struct vm_area_struct *vma;
-	int progress = 0;
-
-	VM_BUG_ON(!pages);
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
+	struct page *hpage = NULL;
+	int ret;
+	int *node_load;
 
-	if (khugepaged_scan.mm_slot)
-		mm_slot = khugepaged_scan.mm_slot;
-	else {
-		mm_slot = list_entry(khugepaged_scan.mm_head.next,
-				     struct mm_slot, mm_node);
-		khugepaged_scan.address = 0;
-		khugepaged_scan.mm_slot = mm_slot;
-	}
-	spin_unlock(&khugepaged_mm_lock);
+	//TODO: #ifdef this for NUMA only
+	node_load = kmalloc(sizeof(int) * MAX_NUMNODES,
+						GFP_KERNEL | GFP_NOWAIT);
+	if (!node_load)
+		return false;
 
-	mm = mm_slot->mm;
 	down_read(&mm->mmap_sem);
-	if (unlikely(khugepaged_test_exit(mm)))
-		vma = NULL;
-	else
-		vma = find_vma(mm, khugepaged_scan.address);
-
-	progress++;
+	vma = find_vma(mm, *start);
 	for (; vma; vma = vma->vm_next) {
 		unsigned long hstart, hend;
 
-		cond_resched();
-		if (unlikely(khugepaged_test_exit(mm))) {
-			progress++;
-			break;
-		}
-		if (!hugepage_vma_check(vma)) {
-skip:
-			progress++;
+		if (!hugepage_vma_check(vma))
 			continue;
-		}
-		hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
+
+		hstart = ALIGN(vma->vm_start, HPAGE_PMD_SIZE);
 		hend = vma->vm_end & HPAGE_PMD_MASK;
+
 		if (hstart >= hend)
-			goto skip;
-		if (khugepaged_scan.address > hend)
-			goto skip;
-		if (khugepaged_scan.address < hstart)
-			khugepaged_scan.address = hstart;
-		VM_BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
-
-		while (khugepaged_scan.address < hend) {
-			int ret;
-			cond_resched();
-			if (unlikely(khugepaged_test_exit(mm)))
-				goto breakouterloop;
-
-			VM_BUG_ON(khugepaged_scan.address < hstart ||
-				  khugepaged_scan.address + HPAGE_PMD_SIZE >
-				  hend);
-			ret = khugepaged_scan_pmd(mm, vma,
-						  khugepaged_scan.address,
-						  hpage);
-			/* move to next address */
-			khugepaged_scan.address += HPAGE_PMD_SIZE;
-			progress += HPAGE_PMD_NR;
+			continue;
+		if (*start < hstart)
+			*start = hstart;
+		VM_BUG_ON(*start & ~HPAGE_PMD_MASK);
+
+		while (*start < hend) {
+			ret = khugepaged_scan_pmd(mm, vma, *start, &hpage,
+								node_load);
+			*start += HPAGE_PMD_SIZE;
+			pages -= HPAGE_PMD_NR;
+
 			if (ret)
-				/* we released mmap_sem so break loop */
-				goto breakouterloop_mmap_sem;
-			if (progress >= pages)
-				goto breakouterloop;
+				goto out;
+
+			if (pages <= 0)
+				goto out_unlock;
 		}
 	}
-breakouterloop:
-	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
-breakouterloop_mmap_sem:
+out_unlock:
+	up_read(&mm->mmap_sem);
+out:
+	if (!vma)
+		*start = 0;
 
-	spin_lock(&khugepaged_mm_lock);
-	VM_BUG_ON(khugepaged_scan.mm_slot != mm_slot);
-	/*
-	 * Release the current mm_slot if this mm is about to die, or
-	 * if we scanned all vmas of this mm.
-	 */
-	if (khugepaged_test_exit(mm) || !vma) {
-		/*
-		 * Make sure that if mm_users is reaching zero while
-		 * khugepaged runs here, khugepaged_exit will find
-		 * mm_slot not pointing to the exiting mm.
-		 */
-		if (mm_slot->mm_node.next != &khugepaged_scan.mm_head) {
-			khugepaged_scan.mm_slot = list_entry(
-				mm_slot->mm_node.next,
-				struct mm_slot, mm_node);
-			khugepaged_scan.address = 0;
-		} else {
-			khugepaged_scan.mm_slot = NULL;
-			khugepaged_full_scans++;
-		}
+	if (!IS_ERR_OR_NULL(hpage))
+		put_page(hpage);
 
-		collect_mm_slot(mm_slot);
-	}
+	kfree(node_load);
 
-	return progress;
+	return true;
 }
 
 static int khugepaged_has_work(void)
@@ -2777,44 +2718,6 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }
 
-static void khugepaged_do_scan(void)
-{
-	struct page *hpage = NULL;
-	unsigned int progress = 0, pass_through_head = 0;
-	unsigned int pages = READ_ONCE(khugepaged_pages_to_scan);
-
-	if (!khugepaged_check_nodes(&hpage)) {
-		khugepaged_alloc_sleep();
-		return;
-	}
-
-	while (progress < pages) {
-		cond_resched();
-
-		if (unlikely(kthread_should_stop() || freezing(current)))
-			break;
-
-		spin_lock(&khugepaged_mm_lock);
-		if (!khugepaged_scan.mm_slot)
-			pass_through_head++;
-		if (khugepaged_has_work() &&
-		    pass_through_head < 2)
-			progress += khugepaged_scan_mm_slot(pages - progress,
-							    &hpage);
-		else
-			progress = pages;
-		spin_unlock(&khugepaged_mm_lock);
-
-		if (IS_ERR(hpage)) {
-			khugepaged_alloc_sleep();
-			break;
-		}
-	}
-
-	if (!IS_ERR_OR_NULL(hpage))
-		put_page(hpage);
-}
-
 static void khugepaged_wait_work(void)
 {
 	try_to_freeze();
@@ -2841,8 +2744,10 @@ static int khugepaged(void *none)
 	set_user_nice(current, MAX_NICE);
 
 	while (!kthread_should_stop()) {
-		khugepaged_do_scan();
-		khugepaged_wait_work();
+		if (khugepaged_check_nodes())
+			khugepaged_wait_work();
+		else
+			khugepaged_alloc_sleep();
 	}
 
 	spin_lock(&khugepaged_mm_lock);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
