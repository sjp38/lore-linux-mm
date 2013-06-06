Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 7F3E16B0033
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:10:00 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] memcg: do not sleep on OOM waitqueue with full charge context
Date: Wed,  5 Jun 2013 23:09:53 -0400
Message-Id: <1370488193-4747-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
References: <1370488193-4747-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg OOM handling is incredibly fragile because once a memcg goes
OOM, one task (kernel or userspace) is responsible for resolving the
situation.  Every other task that gets caught trying to charge memory
gets stuck in a waitqueue while potentially holding various filesystem
and mm locks on which the OOM handling task may now deadlock.

Do two things:

1. When OOMing in a system call (buffered IO and friends), invoke the
   OOM killer but just return -ENOMEM, never sleep.  Userspace should
   be able to handle this.

2. When OOMing in a page fault and somebody else is handling the
   situation, do not sleep directly in the charging code.  Instead,
   remember the OOMing memcg in the task struct and then fully unwind
   the page fault stack first before going to sleep.

While reworking the OOM routine, also remove a needless OOM waitqueue
wakeup when invoking the killer.  Only uncharges and limit increases,
things that actually change the memory situation, should do wakeups.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h |  22 +++++++
 include/linux/mm.h         |   1 +
 include/linux/sched.h      |   6 ++
 mm/ksm.c                   |   2 +-
 mm/memcontrol.c            | 146 ++++++++++++++++++++++++++++-----------------
 mm/memory.c                |  40 +++++++++----
 mm/oom_kill.c              |   7 ++-
 7 files changed, 154 insertions(+), 70 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c8b1412..8e0f900 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -124,6 +124,15 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
+static inline void mem_cgroup_set_userfault(struct task_struct *p)
+{
+	p->memcg_oom.in_userfault = 1;
+}
+static inline void mem_cgroup_clear_userfault(struct task_struct *p)
+{
+	p->memcg_oom.in_userfault = 0;
+}
+bool mem_cgroup_oom_synchronize(void);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
@@ -343,6 +352,19 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline void mem_cgroup_set_userfault(struct task_struct *p)
+{
+}
+
+static inline void mem_cgroup_clear_userfault(struct task_struct *p)
+{
+}
+
+static inline bool mem_cgroup_oom_synchronize(void)
+{
+	return false;
+}
+
 static inline void mem_cgroup_begin_update_page_stat(struct page *page,
 					bool *locked, unsigned long *flags)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b87681a..79ee304 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -176,6 +176,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
+#define FAULT_FLAG_KERNEL	0x80	/* kernel-triggered fault (get_user_pages etc.) */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 08090e6..0659277 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1403,6 +1403,12 @@ struct task_struct {
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
 	unsigned int memcg_kmem_skip_account;
+	struct memcg_oom_info {
+		unsigned int in_userfault:1;
+		unsigned int in_memcg_oom:1;
+		int wakeups;
+		struct mem_cgroup *wait_on_memcg;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_UPROBES
 	struct uprobe_task *utask;
diff --git a/mm/ksm.c b/mm/ksm.c
index b6afe0c..9dff93b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -372,7 +372,7 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 			break;
 		if (PageKsm(page))
 			ret = handle_mm_fault(vma->vm_mm, vma, addr,
-							FAULT_FLAG_WRITE);
+					FAULT_FLAG_KERNEL | FAULT_FLAG_WRITE);
 		else
 			ret = VM_FAULT_WRITE;
 		put_page(page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d169a8d..61d3449 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -298,6 +298,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	atomic_t	refcnt;
 
@@ -2305,6 +2306,7 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
 
 static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
+	atomic_inc(&memcg->oom_wakeups);
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
@@ -2316,56 +2318,103 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 }
 
 /*
- * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+ * try to call OOM killer
  */
-static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
-				  int order)
+static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
 {
-	struct oom_wait_info owait;
-	bool locked, need_to_kill;
-
-	owait.memcg = memcg;
-	owait.wait.flags = 0;
-	owait.wait.func = memcg_oom_wake_function;
-	owait.wait.private = current;
-	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
+	bool locked, need_to_kill = true;
 
 	/* At first, try to OOM lock hierarchy under memcg.*/
 	spin_lock(&memcg_oom_lock);
 	locked = mem_cgroup_oom_lock(memcg);
-	/*
-	 * Even if signal_pending(), we can't quit charge() loop without
-	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
-	 * under OOM is always welcomed, use TASK_KILLABLE here.
-	 */
-	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
 	if (!locked || memcg->oom_kill_disable)
 		need_to_kill = false;
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
 	spin_unlock(&memcg_oom_lock);
 
-	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, mask, order);
-	} else {
-		schedule();
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+	/*
+	 * A system call can just return -ENOMEM, but if this is a
+	 * page fault and somebody else is handling the OOM already,
+	 * we need to sleep on the OOM waitqueue for this memcg until
+	 * the situation is resolved.  Which can take some time
+	 * because it might be handled by a userspace task.
+	 *
+	 * However, this is the charge context, which means that we
+	 * may sit on a large call stack and hold various filesystem
+	 * locks, the mmap_sem etc. and we don't want the OOM handler
+	 * to deadlock on them while we sit here and wait.  Store the
+	 * current OOM context in the task_struct, then return
+	 * -ENOMEM.  At the end of the page fault handler, with the
+	 * stack unwound, pagefault_out_of_memory() will check back
+	 * with us by calling mem_cgroup_oom_synchronize(), possibly
+	 * putting the task to sleep.
+	 */
+	if (current->memcg_oom.in_userfault) {
+		current->memcg_oom.in_memcg_oom = 1;
+		/*
+		 * Somebody else is handling the situation.  Make sure
+		 * no wakeups are missed between now and going to
+		 * sleep at the end of the page fault.
+		 */
+		if (!need_to_kill) {
+			mem_cgroup_mark_under_oom(memcg);
+			current->memcg_oom.wakeups =
+				atomic_read(&memcg->oom_wakeups);
+			css_get(&memcg->css);
+			current->memcg_oom.wait_on_memcg = memcg;
+		}
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
+
+	if (need_to_kill)
+		mem_cgroup_out_of_memory(memcg, mask, order);
+
+	if (locked) {
+		spin_lock(&memcg_oom_lock);
 		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
+		spin_unlock(&memcg_oom_lock);
+	}
+}
 
-	mem_cgroup_unmark_under_oom(memcg);
+bool mem_cgroup_oom_synchronize(void)
+{
+	struct oom_wait_info owait;
+	struct mem_cgroup *memcg;
 
-	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+	/* OOM is global, do not handle */
+	if (!current->memcg_oom.in_memcg_oom)
 		return false;
-	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+
+	/*
+	 * We invoked the OOM killer but there is a chance that a kill
+	 * did not free up any charges.  Everybody else might already
+	 * be sleeping, so restart the fault and keep the rampage
+	 * going until some charges are released.
+	 */
+	memcg = current->memcg_oom.wait_on_memcg;
+	if (!memcg)
+		goto out;
+
+	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+		goto out_put;
+
+	owait.memcg = memcg;
+	owait.wait.flags = 0;
+	owait.wait.func = memcg_oom_wake_function;
+	owait.wait.private = current;
+	INIT_LIST_HEAD(&owait.wait.task_list);
+
+	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
+	/* Only sleep if we didn't miss any wakeups since OOM */
+	if (atomic_read(&memcg->oom_wakeups) == current->memcg_oom.wakeups)
+		schedule();
+	finish_wait(&memcg_oom_waitq, &owait.wait);
+out_put:
+	mem_cgroup_unmark_under_oom(memcg);
+	css_put(&memcg->css);
+	current->memcg_oom.wait_on_memcg = NULL;
+out:
+	current->memcg_oom.in_memcg_oom = 0;
 	return true;
 }
 
@@ -2678,12 +2727,11 @@ enum {
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
-	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 				unsigned int nr_pages, unsigned int min_pages,
-				bool oom_check)
+				bool invoke_oom)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
@@ -2740,14 +2788,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check)
-		return CHARGE_NOMEM;
-	/* check OOM */
-	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask, get_order(csize)))
-		return CHARGE_OOM_DIE;
+	if (invoke_oom)
+		mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(csize));
 
-	return CHARGE_RETRY;
+	return CHARGE_NOMEM;
 }
 
 /*
@@ -2850,7 +2894,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2858,14 +2902,8 @@ again:
 			goto bypass;
 		}
 
-		oom_check = false;
-		if (oom && !nr_oom_retries) {
-			oom_check = true;
-			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		}
-
-		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, nr_pages,
-		    oom_check);
+		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch,
+					   nr_pages, invoke_oom);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
@@ -2878,16 +2916,12 @@ again:
 			css_put(&memcg->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom) {
+			if (!oom || invoke_oom) {
 				css_put(&memcg->css);
 				goto nomem;
 			}
-			/* If oom, we never return -ENOMEM */
 			nr_oom_retries--;
 			break;
-		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
-			css_put(&memcg->css);
-			goto bypass;
 		}
 	} while (ret != CHARGE_OK);
 
diff --git a/mm/memory.c b/mm/memory.c
index 2210b21..05f307b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1819,7 +1819,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			while (!(page = follow_page_mask(vma, start,
 						foll_flags, &page_mask))) {
 				int ret;
-				unsigned int fault_flags = 0;
+				unsigned int fault_flags = FAULT_FLAG_KERNEL;
 
 				/* For mlock, just skip the stack guard page. */
 				if (foll_flags & FOLL_MLOCK) {
@@ -1947,6 +1947,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma || address < vma->vm_start)
 		return -EFAULT;
 
+	fault_flags |= FAULT_FLAG_KERNEL;
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -3764,22 +3765,14 @@ unlock:
 /*
  * By the time we get here, we already hold the mm semaphore
  */
-int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, unsigned int flags)
+static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+			     unsigned long address, unsigned int flags)
 {
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte;
 
-	__set_current_state(TASK_RUNNING);
-
-	count_vm_event(PGFAULT);
-	mem_cgroup_count_vm_event(mm, PGFAULT);
-
-	/* do counter updates before entering really critical section. */
-	check_sync_rss_stat(current);
-
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, flags);
 
@@ -3860,6 +3853,31 @@ retry:
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, unsigned int flags)
+{
+	int in_userfault = !(flags & FAULT_FLAG_KERNEL);
+	int ret;
+
+	__set_current_state(TASK_RUNNING);
+
+	count_vm_event(PGFAULT);
+	mem_cgroup_count_vm_event(mm, PGFAULT);
+
+	/* do counter updates before entering really critical section. */
+	check_sync_rss_stat(current);
+
+	if (in_userfault)
+		mem_cgroup_set_userfault(current);
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (in_userfault)
+		mem_cgroup_clear_userfault(current);
+
+	return ret;
+}
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 79e451a..0c9f836 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -678,9 +678,12 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
-	struct zonelist *zonelist = node_zonelist(first_online_node,
-						  GFP_KERNEL);
+	struct zonelist *zonelist;
 
+	if (mem_cgroup_oom_synchronize())
+		return;
+
+	zonelist = node_zonelist(first_online_node, GFP_KERNEL);
 	if (try_set_zonelist_oom(zonelist, GFP_KERNEL)) {
 		out_of_memory(NULL, 0, 0, NULL, false);
 		clear_zonelist_oom(zonelist, GFP_KERNEL);
-- 
1.8.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
