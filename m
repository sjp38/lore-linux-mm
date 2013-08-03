Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 446936B0031
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 13:08:39 -0400 (EDT)
Date: Sat, 3 Aug 2013 13:08:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130803170831.GB23319@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hi azur,

here is the x86-only rollup of the series for 3.2.

Thanks!
Johannes
---

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 5db0490..314fe53 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -842,30 +842,22 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 	force_sig_info_fault(SIGBUS, code, address, tsk, fault);
 }
 
-static noinline int
+static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 	       unsigned long address, unsigned int fault)
 {
-	/*
-	 * Pagefault was interrupted by SIGKILL. We have no reason to
-	 * continue pagefault.
-	 */
-	if (fatal_signal_pending(current)) {
-		if (!(fault & VM_FAULT_RETRY))
-			up_read(&current->mm->mmap_sem);
-		if (!(error_code & PF_USER))
-			no_context(regs, error_code, address);
-		return 1;
+	if (fatal_signal_pending(current) && !(error_code & PF_USER)) {
+		up_read(&current->mm->mmap_sem);
+		no_context(regs, error_code, address);
+		return;
 	}
-	if (!(fault & VM_FAULT_ERROR))
-		return 0;
 
 	if (fault & VM_FAULT_OOM) {
 		/* Kernel mode? Handle exceptions or die: */
 		if (!(error_code & PF_USER)) {
 			up_read(&current->mm->mmap_sem);
 			no_context(regs, error_code, address);
-			return 1;
+			return;
 		}
 
 		out_of_memory(regs, error_code, address);
@@ -876,7 +868,6 @@ mm_fault_error(struct pt_regs *regs, unsigned long error_code,
 		else
 			BUG();
 	}
-	return 1;
 }
 
 static int spurious_fault_check(unsigned long error_code, pte_t *pte)
@@ -1070,6 +1061,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	if (user_mode_vm(regs)) {
 		local_irq_enable();
 		error_code |= PF_USER;
+		flags |= FAULT_FLAG_USER;
 	} else {
 		if (regs->flags & X86_EFLAGS_IF)
 			local_irq_enable();
@@ -1167,9 +1159,17 @@ good_area:
 	 */
 	fault = handle_mm_fault(mm, vma, address, flags);
 
-	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
-		if (mm_fault_error(regs, error_code, address, fault))
-			return;
+	/*
+	 * If we need to retry but a fatal signal is pending, handle the
+	 * signal first. We do not need to release the mmap_sem because it
+	 * would already be released in __lock_page_or_retry in mm/filemap.c.
+	 */
+	if (unlikely((fault & VM_FAULT_RETRY) && fatal_signal_pending(current)))
+		return;
+
+	if (unlikely(fault & VM_FAULT_ERROR)) {
+		mm_fault_error(regs, error_code, address, fault);
+		return;
 	}
 
 	/*
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b87068a..b113c0f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -120,6 +120,48 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+/**
+ * mem_cgroup_toggle_oom - toggle the memcg OOM killer for the current task
+ * @new: true to enable, false to disable
+ *
+ * Toggle whether a failed memcg charge should invoke the OOM killer
+ * or just return -ENOMEM.  Returns the previous toggle state.
+ *
+ * NOTE: Any path that enables the OOM killer before charging must
+ *       call mem_cgroup_oom_synchronize() afterward to finalize the
+ *       OOM handling and clean up.
+ */
+static inline bool mem_cgroup_toggle_oom(bool new)
+{
+	bool old;
+
+	old = current->memcg_oom.may_oom;
+	current->memcg_oom.may_oom = new;
+
+	return old;
+}
+
+static inline void mem_cgroup_enable_oom(void)
+{
+	bool old = mem_cgroup_toggle_oom(true);
+
+	WARN_ON(old == true);
+}
+
+static inline void mem_cgroup_disable_oom(void)
+{
+	bool old = mem_cgroup_toggle_oom(false);
+
+	WARN_ON(old == false);
+}
+
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return p->memcg_oom.in_memcg_oom;
+}
+
+bool mem_cgroup_oom_synchronize(void);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -333,6 +375,29 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline bool mem_cgroup_toggle_oom(bool new)
+{
+	return false;
+}
+
+static inline void mem_cgroup_enable_oom(void)
+{
+}
+
+static inline void mem_cgroup_disable_oom(void)
+{
+}
+
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return false;
+}
+
+static inline bool mem_cgroup_oom_synchronize(void)
+{
+	return false;
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_page_stat_item idx)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4baadd1..846b82b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -156,6 +156,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 
 /*
  * This interface is used by x86 PAT code to identify a pfn mapping that is
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1c4f3e9..3f2562c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -91,6 +91,7 @@ struct sched_param {
 #include <linux/latencytop.h>
 #include <linux/cred.h>
 #include <linux/llist.h>
+#include <linux/stacktrace.h>
 
 #include <asm/processor.h>
 
@@ -1568,6 +1569,15 @@ struct task_struct {
 		unsigned long nr_pages;	/* uncharged usage */
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
+	struct memcg_oom_info {
+		unsigned int may_oom:1;
+		unsigned int in_memcg_oom:1;
+		unsigned int oom_locked:1;
+		struct stack_trace trace;
+		unsigned long trace_entries[16];
+		int wakeups;
+		struct mem_cgroup *wait_on_memcg;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
diff --git a/mm/filemap.c b/mm/filemap.c
index 5f0a3c9..030774a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1661,6 +1661,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
 	struct page *page;
+	bool memcg_oom;
 	pgoff_t size;
 	int ret = 0;
 
@@ -1669,7 +1670,11 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		return VM_FAULT_SIGBUS;
 
 	/*
-	 * Do we have something in the page cache already?
+	 * Do we have something in the page cache already?  Either
+	 * way, try readahead, but disable the memcg OOM killer for it
+	 * as readahead is optional and no errors are propagated up
+	 * the fault stack.  The OOM killer is enabled while trying to
+	 * instantiate the faulting page individually below.
 	 */
 	page = find_get_page(mapping, offset);
 	if (likely(page)) {
@@ -1677,10 +1682,14 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		 * We found the page, so try async readahead before
 		 * waiting for the lock.
 		 */
+		memcg_oom = mem_cgroup_toggle_oom(false);
 		do_async_mmap_readahead(vma, ra, file, page, offset);
+		mem_cgroup_toggle_oom(memcg_oom);
 	} else {
 		/* No page in the page cache at all */
+		memcg_oom = mem_cgroup_toggle_oom(false);
 		do_sync_mmap_readahead(vma, ra, file, offset);
+		mem_cgroup_toggle_oom(memcg_oom);
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b63f5f7..83acd11 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/stacktrace.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -249,6 +250,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	atomic_t	refcnt;
 
@@ -1743,16 +1745,19 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
 	return total;
 }
 
+static DEFINE_SPINLOCK(memcg_oom_lock);
+
 /*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
- * Has to be called with memcg_oom_lock
  */
-static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
+static bool mem_cgroup_oom_trylock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter, *failed = NULL;
 	bool cond = true;
 
+	spin_lock(&memcg_oom_lock);
+
 	for_each_mem_cgroup_tree_cond(iter, memcg, cond) {
 		if (iter->oom_lock) {
 			/*
@@ -1765,34 +1770,34 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
 			iter->oom_lock = true;
 	}
 
-	if (!failed)
-		return true;
-
-	/*
-	 * OK, we failed to lock the whole subtree so we have to clean up
-	 * what we set up to the failing subtree
-	 */
-	cond = true;
-	for_each_mem_cgroup_tree_cond(iter, memcg, cond) {
-		if (iter == failed) {
-			cond = false;
-			continue;
+	if (failed) {
+		/*
+		 * OK, we failed to lock the whole subtree so we have
+		 * to clean up what we set up to the failing subtree
+		 */
+		cond = true;
+		for_each_mem_cgroup_tree_cond(iter, memcg, cond) {
+			if (iter == failed) {
+				cond = false;
+				continue;
+			}
+			iter->oom_lock = false;
 		}
-		iter->oom_lock = false;
 	}
-	return false;
+
+	spin_unlock(&memcg_oom_lock);
+
+	return !failed;
 }
 
-/*
- * Has to be called with memcg_oom_lock
- */
-static int mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
+static void mem_cgroup_oom_unlock(struct mem_cgroup *memcg)
 {
 	struct mem_cgroup *iter;
 
+	spin_lock(&memcg_oom_lock);
 	for_each_mem_cgroup_tree(iter, memcg)
 		iter->oom_lock = false;
-	return 0;
+	spin_unlock(&memcg_oom_lock);
 }
 
 static void mem_cgroup_mark_under_oom(struct mem_cgroup *memcg)
@@ -1816,7 +1821,6 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -1846,6 +1850,7 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
 
 static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
+	atomic_inc(&memcg->oom_wakeups);
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
@@ -1857,55 +1862,142 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 }
 
 /*
- * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+ * try to call OOM killer
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
+static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
 {
-	struct oom_wait_info owait;
-	bool locked, need_to_kill;
+	bool locked;
+	int wakeups;
 
-	owait.mem = memcg;
-	owait.wait.flags = 0;
-	owait.wait.func = memcg_oom_wake_function;
-	owait.wait.private = current;
-	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
+	if (!current->memcg_oom.may_oom)
+		return;
+
+	current->memcg_oom.in_memcg_oom = 1;
+
+	current->memcg_oom.trace.nr_entries = 0;
+	current->memcg_oom.trace.max_entries = 16;
+	current->memcg_oom.trace.entries = current->memcg_oom.trace_entries;
+	current->memcg_oom.trace.skip = 1;
+	save_stack_trace(&current->memcg_oom.trace);
 
-	/* At first, try to OOM lock hierarchy under memcg.*/
-	spin_lock(&memcg_oom_lock);
-	locked = mem_cgroup_oom_lock(memcg);
 	/*
-	 * Even if signal_pending(), we can't quit charge() loop without
-	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
-	 * under OOM is always welcomed, use TASK_KILLABLE here.
+	 * As with any blocking lock, a contender needs to start
+	 * listening for wakeups before attempting the trylock,
+	 * otherwise it can miss the wakeup from the unlock and sleep
+	 * indefinitely.  This is just open-coded because our locking
+	 * is so particular to memcg hierarchies.
 	 */
-	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || memcg->oom_kill_disable)
-		need_to_kill = false;
+	wakeups = atomic_read(&memcg->oom_wakeups);
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+	if (locked && !memcg->oom_kill_disable) {
+		mem_cgroup_unmark_under_oom(memcg);
 		mem_cgroup_out_of_memory(memcg, mask);
+		mem_cgroup_oom_unlock(memcg);
+		/*
+		 * There is no guarantee that an OOM-lock contender
+		 * sees the wakeups triggered by the OOM kill
+		 * uncharges.  Wake any sleepers explicitely.
+		 */
+		memcg_oom_recover(memcg);
 	} else {
-		schedule();
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+		/*
+		 * A system call can just return -ENOMEM, but if this
+		 * is a page fault and somebody else is handling the
+		 * OOM already, we need to sleep on the OOM waitqueue
+		 * for this memcg until the situation is resolved.
+		 * Which can take some time because it might be
+		 * handled by a userspace task.
+		 *
+		 * However, this is the charge context, which means
+		 * that we may sit on a large call stack and hold
+		 * various filesystem locks, the mmap_sem etc. and we
+		 * don't want the OOM handler to deadlock on them
+		 * while we sit here and wait.  Store the current OOM
+		 * context in the task_struct, then return -ENOMEM.
+		 * At the end of the page fault handler, with the
+		 * stack unwound, pagefault_out_of_memory() will check
+		 * back with us by calling
+		 * mem_cgroup_oom_synchronize(), possibly putting the
+		 * task to sleep.
+		 */
+		current->memcg_oom.oom_locked = locked;
+		current->memcg_oom.wakeups = wakeups;
+		css_get(&memcg->css);
+		current->memcg_oom.wait_on_memcg = memcg;
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
-		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
+}
 
-	mem_cgroup_unmark_under_oom(memcg);
+/**
+ * mem_cgroup_oom_synchronize - complete memcg OOM handling
+ *
+ * This has to be called at the end of a page fault if the the memcg
+ * OOM handler was enabled and the fault is returning %VM_FAULT_OOM.
+ *
+ * Memcg supports userspace OOM handling, so failed allocations must
+ * sleep on a waitqueue until the userspace task resolves the
+ * situation.  Sleeping directly in the charge context with all kinds
+ * of locks held is not a good idea, instead we remember an OOM state
+ * in the task and mem_cgroup_oom_synchronize() has to be called at
+ * the end of the page fault to put the task to sleep and clean up the
+ * OOM state.
+ *
+ * Returns %true if an ongoing memcg OOM situation was detected and
+ * finalized, %false otherwise.
+ */
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
+		goto out_memcg;
+
+	owait.mem = memcg;
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
+out_memcg:
+	mem_cgroup_unmark_under_oom(memcg);
+	if (current->memcg_oom.oom_locked) {
+		mem_cgroup_oom_unlock(memcg);
+		/*
+		 * There is no guarantee that an OOM-lock contender
+		 * sees the wakeups triggered by the OOM kill
+		 * uncharges.  Wake any sleepers explicitely.
+		 */
+		memcg_oom_recover(memcg);
+	}
+	css_put(&memcg->css);
+	current->memcg_oom.wait_on_memcg = NULL;
+out:
+	current->memcg_oom.in_memcg_oom = 0;
 	return true;
 }
 
@@ -2195,11 +2287,10 @@ enum {
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
-	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				unsigned int nr_pages, bool oom_check)
+				unsigned int nr_pages, bool invoke_oom)
 {
 	unsigned long csize = nr_pages * PAGE_SIZE;
 	struct mem_cgroup *mem_over_limit;
@@ -2257,14 +2348,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check)
-		return CHARGE_NOMEM;
-	/* check OOM */
-	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
-		return CHARGE_OOM_DIE;
+	if (invoke_oom)
+		mem_cgroup_oom(mem_over_limit, gfp_mask);
 
-	return CHARGE_RETRY;
+	return CHARGE_NOMEM;
 }
 
 /*
@@ -2349,7 +2436,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2357,13 +2444,7 @@ again:
 			goto bypass;
 		}
 
-		oom_check = false;
-		if (oom && !nr_oom_retries) {
-			oom_check = true;
-			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		}
-
-		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
+		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, invoke_oom);
 		switch (ret) {
 		case CHARGE_OK:
 			break;
@@ -2376,16 +2457,12 @@ again:
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
index 829d437..cdbe41b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/stacktrace.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3439,22 +3440,14 @@ unlock:
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
 
@@ -3503,6 +3496,40 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		    unsigned long address, unsigned int flags)
+{
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
+	/*
+	 * Enable the memcg OOM handling for faults triggered in user
+	 * space.  Kernel faults are handled more gracefully.
+	 */
+	if (flags & FAULT_FLAG_USER)
+		mem_cgroup_enable_oom();
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (flags & FAULT_FLAG_USER)
+		mem_cgroup_disable_oom();
+
+	if (WARN_ON(task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))) {
+		printk("Fixing unhandled memcg OOM context set up from:\n");
+		print_stack_trace(&current->memcg_oom.trace, 0);
+		mem_cgroup_oom_synchronize();
+	}
+
+	return ret;
+}
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 069b64e..aa60863 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -785,6 +785,8 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	if (mem_cgroup_oom_synchronize())
+		return;
 	if (try_set_system_oom()) {
 		out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
