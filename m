Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id DF2D56B0039
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 18:26:02 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/6] mm: memcg: do not trap chargers with full callstack on OOM
Date: Thu, 25 Jul 2013 18:25:38 -0400
Message-Id: <1374791138-15665-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg OOM handling is incredibly fragile and can deadlock.  When a
task fails to charge memory, it invokes the OOM killer and loops right
there in the charge code until it succeeds.  Comparably, any other
task that enters the charge path at this point will go to a waitqueue
right then and there and sleep until the OOM situation is resolved.
The problem is that these tasks may hold filesystem locks and the
mmap_sem; locks that the selected OOM victim may need to exit.

For example, in one reported case, the task invoking the OOM killer
was about to charge a page cache page during a write(), which holds
the i_mutex.  The OOM killer selected a task that was just entering
truncate() and trying to acquire the i_mutex:

OOM invoking task:
[<ffffffff8110a9c1>] mem_cgroup_handle_oom+0x241/0x3b0
[<ffffffff8110b5ab>] T.1146+0x5ab/0x5c0
[<ffffffff8110c22e>] mem_cgroup_cache_charge+0xbe/0xe0
[<ffffffff810ca28c>] add_to_page_cache_locked+0x4c/0x140
[<ffffffff810ca3a2>] add_to_page_cache_lru+0x22/0x50
[<ffffffff810ca45b>] grab_cache_page_write_begin+0x8b/0xe0
[<ffffffff81193a18>] ext3_write_begin+0x88/0x270
[<ffffffff810c8fc6>] generic_file_buffered_write+0x116/0x290
[<ffffffff810cb3cc>] __generic_file_aio_write+0x27c/0x480
[<ffffffff810cb646>] generic_file_aio_write+0x76/0xf0           # takes ->i_mutex
[<ffffffff8111156a>] do_sync_write+0xea/0x130
[<ffffffff81112183>] vfs_write+0xf3/0x1f0
[<ffffffff81112381>] sys_write+0x51/0x90
[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

OOM kill victim:
[<ffffffff811109b8>] do_truncate+0x58/0xa0              # takes i_mutex
[<ffffffff81121c90>] do_last+0x250/0xa30
[<ffffffff81122547>] path_openat+0xd7/0x440
[<ffffffff811229c9>] do_filp_open+0x49/0xa0
[<ffffffff8110f7d6>] do_sys_open+0x106/0x240
[<ffffffff8110f950>] sys_open+0x20/0x30
[<ffffffff815b5926>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

The OOM handling task will retry the charge indefinitely while the OOM
killed task is not releasing any resources.

A similar scenario can happen when the kernel OOM killer for a memcg
is disabled and a userspace task is in charge of resolving OOM
situations.  In this case, ALL tasks that enter the OOM path will be
made to sleep on the OOM waitqueue and wait for userspace to free
resources or increase the group's limit.  But a userspace OOM handler
is prone to deadlock itself on the locks held by the waiting tasks.
For example one of the sleeping tasks may be stuck in a brk() call
with the mmap_sem held for writing but the userspace handler, in order
to pick an optimal victim, may need to read files from /proc/<pid>,
which tries to acquire the same mmap_sem for reading and deadlocks.

This patch changes the way tasks behave after detecting a memcg OOM
and makes sure nobody loops or sleeps with locks held:

1. When OOMing in a user fault, invoke the OOM killer and restart the
   fault instead of looping on the charge attempt.  This way, the OOM
   victim can not get stuck on locks the looping task may hold.

2. When OOMing in a user fault but somebody else is handling it
   (either the kernel OOM killer or a userspace handler), don't go to
   sleep in the charge context.  Instead, remember the OOMing memcg in
   the task struct and then fully unwind the page fault stack with
   -ENOMEM.  pagefault_out_of_memory() will then call back into the
   memcg code to check if the -ENOMEM came from the memcg, and then
   either put the task to sleep on the memcg's OOM waitqueue or just
   restart the fault.  The OOM victim can no longer get stuck on any
   lock a sleeping task may hold.

This relies on the memcg OOM killer only being enabled when an
allocation failure will result in a call to pagefault_out_of_memory().

While reworking the OOM routine, also remove a needless OOM waitqueue
wakeup when invoking the killer.  In addition to the wakeup implied in
the kill signal delivery, only uncharges and limit increases, things
that actually change the memory situation, should poke the waitqueue.

Reported-by: Reported-by: azurIt <azurit@pobox.sk>
Debugged-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |  17 +++++
 include/linux/sched.h      |   3 +
 mm/memcontrol.c            | 156 ++++++++++++++++++++++++++++++---------------
 mm/memory.c                |   3 +
 mm/oom_kill.c              |   7 +-
 5 files changed, 132 insertions(+), 54 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9bb5eeb..2489cb6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -143,6 +143,13 @@ static inline bool mem_cgroup_xchg_may_oom(struct task_struct *p, bool new)
 	return old;
 }
 
+static inline bool task_in_mem_cgroup_oom(struct task_struct *p)
+{
+	return p->memcg_oom.in_memcg_oom;
+}
+
+bool mem_cgroup_oom_synchronize(void);
+
 #ifdef CONFIG_MEMCG_SWAP
 extern int do_swap_account;
 #endif
@@ -371,6 +378,16 @@ static inline bool mem_cgroup_xchg_may_oom(struct task_struct *p, bool new)
 	return !new;
 }
 
+static inline bool task_in_mem_cgroup_oom(struct task_struct *p)
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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4b3effc..eb873fd 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1400,6 +1400,9 @@ struct task_struct {
 	unsigned int memcg_kmem_skip_account;
 	struct memcg_oom_info {
 		unsigned int may_oom:1;
+		unsigned int in_memcg_oom:1;
+		int wakeups;
+		struct mem_cgroup *wait_on_memcg;
 	} memcg_oom;
 #endif
 #ifdef CONFIG_UPROBES
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 30ae46a..029a3a8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -280,6 +280,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	int	swappiness;
 	/* OOM-Killer disable */
@@ -2178,6 +2179,7 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
 
 static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
+	atomic_inc(&memcg->oom_wakeups);
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
@@ -2189,31 +2191,20 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
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
+	bool locked, need_to_kill = true;
 
-	owait.memcg = memcg;
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
@@ -2221,24 +2212,100 @@ static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
 	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask, order);
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
+		mem_cgroup_mark_under_oom(memcg);
+		current->memcg_oom.wakeups = atomic_read(&memcg->oom_wakeups);
+		css_get(&memcg->css);
+		current->memcg_oom.wait_on_memcg = memcg;
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
+
+	if (locked) {
+		spin_lock(&memcg_oom_lock);
 		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
+		/*
+		 * Sleeping tasks might have been killed, make sure
+		 * they get scheduled so they can exit.
+		 */
+		if (need_to_kill)
+			memcg_oom_recover(memcg);
+		spin_unlock(&memcg_oom_lock);
+	}
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
+out_memcg:
+	mem_cgroup_unmark_under_oom(memcg);
+	css_put(&memcg->css);
+	current->memcg_oom.wait_on_memcg = NULL;
+out:
+	current->memcg_oom.in_memcg_oom = 0;
 	return true;
 }
 
@@ -2551,12 +2618,11 @@ enum {
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
@@ -2613,14 +2679,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check || !current->memcg_oom.may_oom)
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
@@ -2723,7 +2785,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2731,14 +2793,8 @@ again:
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
@@ -2751,16 +2807,12 @@ again:
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
index 5ea7b47..fff7dfd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3868,6 +3868,9 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (flags & FAULT_FLAG_USER)
 		WARN_ON(mem_cgroup_xchg_may_oom(current, false) == false);
 
+	if (WARN_ON(task_in_mem_cgroup_oom(current) && !(ret & VM_FAULT_OOM)))
+		mem_cgroup_oom_synchronize();
+
 	return ret;
 }
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 98e75f2..314e9d2 100644
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
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
