Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7E46B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 22:49:36 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id rd3so193952pab.13
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 19:49:36 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id cq3si359327pbb.193.2014.10.22.19.49.34
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 19:49:35 -0700 (PDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 3/4] Convert khugepaged scan functions to work with task_work
Date: Wed, 22 Oct 2014 21:49:26 -0500
Message-Id: <1414032567-109765-4-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, athorlton@sgi.com

This patch implements the actual functionality changes that I'm proposing.  For
now I've just repurposed the existing khugepaged functions to do what we need.
Evenrtually they'll need to be completely separated, probably using a config
option to pick which method we want.  We might also want to change the way that
we decide when to put the task_pgcollapse_work function to the task_works list.
I have some ideas to try for that, but haven't implemented any yet.

---
 include/linux/khugepaged.h |  10 +++-
 include/linux/sched.h      |   3 +
 kernel/sched/fair.c        |  19 ++++++
 mm/huge_memory.c           | 143 +++++++++++++++++----------------------------
 4 files changed, 82 insertions(+), 93 deletions(-)

diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
index 6b394f0..27e0ff4 100644
--- a/include/linux/khugepaged.h
+++ b/include/linux/khugepaged.h
@@ -2,11 +2,14 @@
 #define _LINUX_KHUGEPAGED_H
 
 #include <linux/sched.h> /* MMF_VM_HUGEPAGE */
+#include <linux/task_work.h>
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-extern int __khugepaged_enter(struct mm_struct *mm);
+extern int __khugepaged_enter(void);
 extern void __khugepaged_exit(struct mm_struct *mm);
 extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma);
+extern void task_pgcollapse_work(struct callback_head *);
+extern void khugepaged_do_scan(void);
 
 #define khugepaged_enabled()					       \
 	(transparent_hugepage_flags &				       \
@@ -24,8 +27,9 @@ extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma);
 
 static inline int khugepaged_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
+	/* this will add task_pgcollapse_work to task_works */
 	if (test_bit(MMF_VM_HUGEPAGE, &oldmm->flags))
-		return __khugepaged_enter(mm);
+		return __khugepaged_enter();
 	return 0;
 }
 
@@ -42,7 +46,7 @@ static inline int khugepaged_enter(struct vm_area_struct *vma)
 		     (khugepaged_req_madv() &&
 		      vma->vm_flags & VM_HUGEPAGE)) &&
 		    !(vma->vm_flags & VM_NOHUGEPAGE))
-			if (__khugepaged_enter(vma->vm_mm))
+			if (__khugepaged_enter())
 				return -ENOMEM;
 	return 0;
 }
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 109be66..1855570 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -3044,3 +3044,6 @@ static inline unsigned long rlimit_max(unsigned int limit)
 }
 
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+extern void task_pgcollapse_work(struct callback_head *);
+#endif
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index b78280c..cd1cd6c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -30,6 +30,8 @@
 #include <linux/mempolicy.h>
 #include <linux/migrate.h>
 #include <linux/task_work.h>
+#include <linux/types.h>
+#include <linux/khugepaged.h>
 
 #include <trace/events/sched.h>
 
@@ -2060,6 +2062,23 @@ static inline void account_numa_dequeue(struct rq *rq, struct task_struct *p)
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+void task_pgcollapse_work(struct callback_head *work)
+{
+	WARN_ON_ONCE(current != container_of(work, struct task_struct, pgcollapse_work));
+
+	work->next = work; /* protect against double add */
+
+	pr_info("!!! debug - INFO: task: %s/%d in task_pgcollapse_work\n",
+		current->comm, (int) current->pid);
+	khugepaged_do_scan();
+}
+#else
+void task_pgcollapse_work(struct callback_head *work)
+{
+}
+#endif
+
 static void
 account_entity_enqueue(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 63abf52..c43ca99 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -786,6 +786,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
+	/* this will add task_pgcollapse_work to task_works */
 	if (unlikely(khugepaged_enter(vma)))
 		return VM_FAULT_OOM;
 	if (!(flags & FAULT_FLAG_WRITE) &&
@@ -2021,35 +2022,27 @@ static inline int khugepaged_test_exit(struct mm_struct *mm)
 	return atomic_read(&mm->mm_users) == 0;
 }
 
-int __khugepaged_enter(struct mm_struct *mm)
+int __khugepaged_enter(void)
 {
-	struct mm_slot *mm_slot;
-	int wakeup;
+	unsigned long period = msecs_to_jiffies(current->pgcollapse_scan_sleep_millisecs);
 
-	mm_slot = alloc_mm_slot();
-	if (!mm_slot)
-		return -ENOMEM;
+	pr_info("!!! debug - INFO: task: %s/%d jiffies: %lu period: %lu last_scan: %lu\n",
+		current->comm, (int) current->pid, jiffies, period, current->pgcollapse_last_scan);
 
-	/* __khugepaged_exit() must not run from under us */
-	VM_BUG_ON_MM(khugepaged_test_exit(mm), mm);
-	if (unlikely(test_and_set_bit(MMF_VM_HUGEPAGE, &mm->flags))) {
-		free_mm_slot(mm_slot);
-		return 0;
-	}
+	/* may want to move this up to where we actually do the scan... */
+	if (time_after(jiffies, current->pgcollapse_last_scan + period)) {
+		current->pgcollapse_last_scan = jiffies;
 
-	spin_lock(&khugepaged_mm_lock);
-	insert_to_mm_slots_hash(mm, mm_slot);
-	/*
-	 * Insert just behind the scanning cursor, to let the area settle
-	 * down a little.
-	 */
-	wakeup = list_empty(&khugepaged_scan.mm_head);
-	list_add_tail(&mm_slot->mm_node, &khugepaged_scan.mm_head);
-	spin_unlock(&khugepaged_mm_lock);
+		pr_info("!!! debug - INFO: task: %s/%d adding pgcollapse work\n",
+			current->comm, (int) current->pid);
 
-	atomic_inc(&mm->mm_count);
-	if (wakeup)
-		wake_up_interruptible(&khugepaged_wait);
+		/* debug - actual new code */
+		init_task_work(&current->pgcollapse_work, task_pgcollapse_work);
+		task_work_add(current, &current->pgcollapse_work, true);
+	} else {
+		pr_info("!!! debug - INFO: task: %s/%d skipping pgcollapse_scan\n",
+			current->comm, (int) current->pid);
+	}
 
 	return 0;
 }
@@ -2069,6 +2062,8 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	VM_BUG_ON_VMA(vma->vm_flags & VM_NO_THP, vma);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
+
+	/* this will add task_pgcollapse_work to task_works */
 	if (hstart < hend)
 		return khugepaged_enter(vma);
 	return 0;
@@ -2417,6 +2412,9 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!new_page)
 		return;
 
+	pr_info("!!! debug - INFO: task: %s/%d pgcollapse alloc: %lx on node %d\n",
+		current->comm, (int) current->pid, address, node);
+
 	if (unlikely(mem_cgroup_try_charge(new_page, mm,
 					   GFP_TRANSHUGE, &memcg)))
 		return;
@@ -2514,7 +2512,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	*hpage = NULL;
 
-	khugepaged_pages_collapsed++;
+	current->pgcollapse_pages_collapsed++;
 out_up_write:
 	up_write(&mm->mmap_sem);
 	return;
@@ -2616,44 +2614,34 @@ static void collect_mm_slot(struct mm_slot *mm_slot)
 }
 
 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
-					    struct page **hpage)
-	__releases(&khugepaged_mm_lock)
-	__acquires(&khugepaged_mm_lock)
+					   struct page **hpage)
 {
-	struct mm_slot *mm_slot;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int progress = 0;
+	/* 
+	 * grab this pointer here to avoid dereferencing
+	 * the task struct multiple times later
+	 */
+	unsigned long * scan_addr_p = &current->pgcollapse_scan_address;
 
 	VM_BUG_ON(!pages);
-	VM_BUG_ON(NR_CPUS != 1 && !spin_is_locked(&khugepaged_mm_lock));
 
-	if (khugepaged_scan.mm_slot)
-		mm_slot = khugepaged_scan.mm_slot;
-	else {
-		mm_slot = list_entry(khugepaged_scan.mm_head.next,
-				     struct mm_slot, mm_node);
-		khugepaged_scan.address = 0;
-		khugepaged_scan.mm_slot = mm_slot;
-	}
-	spin_unlock(&khugepaged_mm_lock);
+	pr_info("!!! debug - task: %s/%d starting scan at %lx\n",
+		current->comm, (int) current->pid, *scan_addr_p);
 
-	mm = mm_slot->mm;
+	mm = current->mm;
 	down_read(&mm->mmap_sem);
 	if (unlikely(khugepaged_test_exit(mm)))
 		vma = NULL;
 	else
-		vma = find_vma(mm, khugepaged_scan.address);
+		vma = find_vma(mm, *scan_addr_p);
 
 	progress++;
 	for (; vma; vma = vma->vm_next) {
 		unsigned long hstart, hend;
 
 		cond_resched();
-		if (unlikely(khugepaged_test_exit(mm))) {
-			progress++;
-			break;
-		}
 		if (!hugepage_vma_check(vma)) {
 skip:
 			progress++;
@@ -2663,26 +2651,24 @@ skip:
 		hend = vma->vm_end & HPAGE_PMD_MASK;
 		if (hstart >= hend)
 			goto skip;
-		if (khugepaged_scan.address > hend)
+		if (*scan_addr_p > hend)
 			goto skip;
-		if (khugepaged_scan.address < hstart)
-			khugepaged_scan.address = hstart;
-		VM_BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
+		if (*scan_addr_p < hstart)
+			*scan_addr_p = hstart;
+		VM_BUG_ON(*scan_addr_p & ~HPAGE_PMD_MASK);
 
-		while (khugepaged_scan.address < hend) {
+		while (*scan_addr_p < hend) {
 			int ret;
 			cond_resched();
 			if (unlikely(khugepaged_test_exit(mm)))
 				goto breakouterloop;
 
-			VM_BUG_ON(khugepaged_scan.address < hstart ||
-				  khugepaged_scan.address + HPAGE_PMD_SIZE >
-				  hend);
-			ret = khugepaged_scan_pmd(mm, vma,
-						  khugepaged_scan.address,
+			VM_BUG_ON(*scan_addr_p < hstart ||
+				  *scan_addr_p + HPAGE_PMD_SIZE > hend);
+			ret = khugepaged_scan_pmd(mm, vma,*scan_addr_p,
 						  hpage);
 			/* move to next address */
-			khugepaged_scan.address += HPAGE_PMD_SIZE;
+			*scan_addr_p += HPAGE_PMD_SIZE;
 			progress += HPAGE_PMD_NR;
 			if (ret)
 				/* we released mmap_sem so break loop */
@@ -2694,30 +2680,14 @@ skip:
 breakouterloop:
 	up_read(&mm->mmap_sem); /* exit_mmap will destroy ptes after this */
 breakouterloop_mmap_sem:
-
-	spin_lock(&khugepaged_mm_lock);
-	VM_BUG_ON(khugepaged_scan.mm_slot != mm_slot);
 	/*
 	 * Release the current mm_slot if this mm is about to die, or
-	 * if we scanned all vmas of this mm.
+	 * if we scanned all vmas of this mm.  Don't think we need the
+	 * khugepaged_test_exit for the task_work style scan...
 	 */
 	if (khugepaged_test_exit(mm) || !vma) {
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
-
-		collect_mm_slot(mm_slot);
+		*scan_addr_p = 0;
+		current->pgcollapse_full_scans++;
 	}
 
 	return progress;
@@ -2735,11 +2705,11 @@ static int khugepaged_wait_event(void)
 		kthread_should_stop();
 }
 
-static void khugepaged_do_scan(void)
+void khugepaged_do_scan(void)
 {
 	struct page *hpage = NULL;
-	unsigned int progress = 0, pass_through_head = 0;
-	unsigned int pages = khugepaged_pages_to_scan;
+	unsigned int progress = 0;
+	unsigned int pages = current->pgcollapse_pages_to_scan;
 	bool wait = true;
 
 	barrier(); /* write khugepaged_pages_to_scan to local stack */
@@ -2750,19 +2720,12 @@ static void khugepaged_do_scan(void)
 
 		cond_resched();
 
-		if (unlikely(kthread_should_stop() || freezing(current)))
+		if (unlikely(freezing(current)))
 			break;
 
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
+		progress += khugepaged_scan_mm_slot(pages - progress, &hpage);
+		pr_info("!!! debug - INFO: task: %s/%d scan iteration progress %u\n",
+			current->comm, (int) current->pid, progress);
 	}
 
 	if (!IS_ERR_OR_NULL(hpage))
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
