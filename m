Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B54DD6B0036
	for <linux-mm@kvack.org>; Sat,  1 Jun 2013 02:12:04 -0400 (EDT)
Date: Sat, 1 Jun 2013 02:11:51 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130601061151.GC15576@cmpxchg.org>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, May 31, 2013 at 12:29:17PM -0700, David Rientjes wrote:
> On Fri, 31 May 2013, Michal Hocko wrote:
> > > It's too easy to simply do even a "ps ax" in an oom memcg and make that 
> > > thread completely unresponsive because it allocates memory.
> > 
> > Yes, but we are talking about oom handler and that one has to be really
> > careful about what it does. So doing something that simply allocates is
> > dangerous.
> > 
> 
> Show me a userspace oom handler that doesn't get notified of every fork() 
> in a memcg, causing a performance degradation of its own for a complete 
> and utter slowpath, that will know the entire process tree of its own 
> memcg or a child memcg.
> 
> This discussion is all fine and good from a theoretical point of view 
> until you actually have to implement one of these yourself.  Multiple 
> users are going to be running their own oom notifiers and without some 
> sort of failsafe, such as memory.oom_delay_millisecs, a memcg can too 
> easily deadlock looking for memory.  If that user is constrained to his or 
> her own subtree, as previously stated, there's also no way to login and 
> rectify the situation at that point and requires admin intervention or a 
> reboot.

Memcg OOM killing is fragile, doing it in userspace does not help.
But a userspace OOM handler that is subject to the OOM situation it is
supposed to resolve?  That's kind of... cruel.

However, I agree with your other point: as long as chargers can get
stuck during OOM while sitting on an unpredictable bunch of locks, we
can not claim that there is a right way to write a reliable userspace
OOM handler.  Userspace has no way of knowing which operations are
safe, and it might even vary between kernel versions.

But I would prefer a better solution than the timeout.  Michal in the
past already tried to disable the OOM killer for page cache charges in
general due to deadlock scenarios.  Could we invoke the killer just
the same but make sure we never trap tasks in the charge context?

I'm currently messing around with the below patch.  When a task faults
and charges under OOM, the memcg is remembered in the task struct and
then made to sleep on the memcg's OOM waitqueue only after unwinding
the page fault stack.  With the kernel OOM killer disabled, all tasks
in the OOMing group sit nicely in

  mem_cgroup_oom_synchronize
  pagefault_out_of_memory
  mm_fault_error
  __do_page_fault
  page_fault
  0xffffffffffffffff

regardless of whether they were faulting anon or file.  They do not
even hold the mmap_sem anymore at this point.

[ I kept syscalls really simple for now and just have them return
  -ENOMEM, never trap them at all (just like the global OOM case).
  It would be more work to have them wait from a flatter stack too,
  but it should be doable if necessary. ]

I suggested this at the MM summit and people were essentially asking
if I was feeling well, so maybe I'm still missing a gaping hole in
this idea.

Patch only works on x86 as of now, on other architectures memcg OOM
will invoke the global OOM killer.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] memcg: more robust oom handling

The memcg OOM handling is incredibly fragile because once a memcg goes
OOM, one task (kernel or userspace) is responsible for resolving the
situation.  Every other task that gets caught trying to charge memory
gets stuck in a waitqueue while potentially holding various filesystem
and mm locks on which the OOM handling task may now deadlock.

Do two things to charge attempts under OOM:

1. Do not trap system calls (buffered IO and friends), just return
   -ENOMEM.  Userspace should be able to handle this... right?

2. Do not trap page faults directly in the charging context.  Instead,
   remember the OOMing memcg in the task struct and fully unwind the
   page fault stack first.  Then synchronize the memcg OOM from
   pagefault_out_of_memory()

Not-quite-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/x86/mm/fault.c        |   2 +
 include/linux/memcontrol.h |   6 +++
 include/linux/sched.h      |   6 +++
 mm/memcontrol.c            | 104 +++++++++++++++++++++++++--------------------
 mm/oom_kill.c              |   7 ++-
 5 files changed, 78 insertions(+), 47 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 0e88336..df043a0 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1185,7 +1185,9 @@ good_area:
 	 * make sure we exit gracefully rather than endlessly redo
 	 * the fault:
 	 */
+	current->in_userfault = 1;
 	fault = handle_mm_fault(mm, vma, address, flags);
+	current->in_userfault = 0;
 
 	if (unlikely(fault & (VM_FAULT_RETRY|VM_FAULT_ERROR))) {
 		if (mm_fault_error(regs, error_code, address, fault))
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d6183f0..e1b84ea 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,6 +121,7 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
 void mem_cgroup_update_lru_size(struct lruvec *, enum lru_list, int);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
+bool mem_cgroup_oom_synchronize(void);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
 					struct page *newpage);
 
@@ -337,6 +338,11 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline bool mem_cgroup_oom_synchronize(void)
+{
+	return false;
+}
+
 static inline void mem_cgroup_begin_update_page_stat(struct page *page,
 					bool *locked, unsigned long *flags)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e692a02..cf60aef 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1282,6 +1282,8 @@ struct task_struct {
 				 * execve */
 	unsigned in_iowait:1;
 
+	unsigned in_userfault:1;
+
 	/* task may not gain privileges */
 	unsigned no_new_privs:1;
 
@@ -1570,6 +1572,10 @@ struct task_struct {
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
 	unsigned int memcg_kmem_skip_account;
+	struct memcg_oom_info {
+		struct mem_cgroup *memcg;
+		int wakeups;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cc3026a..6e13ebe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -291,6 +291,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	atomic_t	refcnt;
 
@@ -2076,6 +2077,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
+	atomic_inc(&memcg->oom_wakeups);
 }
 
 static void memcg_oom_recover(struct mem_cgroup *memcg)
@@ -2085,56 +2087,76 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 }
 
 /*
- * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+ * try to call OOM killer
  */
-static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
-				  int order)
+static void mem_cgroup_oom(struct mem_cgroup *memcg,
+			   gfp_t mask, int order,
+			   bool in_userfault)
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
-	if (!locked || memcg->oom_kill_disable)
+	if (!locked || memcg->oom_kill_disable) {
 		need_to_kill = false;
+		if (in_userfault) {
+			/*
+			 * We start sleeping on the OOM waitqueue only
+			 * after unwinding the page fault stack, so
+			 * make sure we detect wakeups that happen
+			 * between now and then.
+			 */
+			mem_cgroup_mark_under_oom(memcg);
+			current->memcg_oom.wakeups =
+				atomic_read(&memcg->oom_wakeups);
+			css_get(&memcg->css);
+			current->memcg_oom.memcg = memcg;
+		}
+	}
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
 	spin_unlock(&memcg_oom_lock);
 
 	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
 		mem_cgroup_out_of_memory(memcg, mask, order);
-	} else {
-		schedule();
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+		memcg_oom_recover(memcg);
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
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
+	memcg = current->memcg_oom.memcg;
+	if (!memcg)
 		return false;
-	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+
+	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
+		goto out;
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
+out:
+	mem_cgroup_unmark_under_oom(memcg);
+	css_put(&memcg->css);
+	current->memcg_oom.memcg = NULL;
 	return true;
 }
 
@@ -2447,7 +2469,6 @@ enum {
 	CHARGE_RETRY,		/* need to retry but retry is not bad */
 	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
 	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
-	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
 };
 
 static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
@@ -2509,14 +2530,11 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check)
-		return CHARGE_NOMEM;
-	/* check OOM */
-	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask, get_order(csize)))
-		return CHARGE_OOM_DIE;
+	if (oom_check)
+		mem_cgroup_oom(mem_over_limit, gfp_mask, get_order(csize),
+			       current->in_userfault);
 
-	return CHARGE_RETRY;
+	return CHARGE_NOMEM;
 }
 
 /*
@@ -2647,16 +2665,12 @@ again:
 			css_put(&memcg->css);
 			goto nomem;
 		case CHARGE_NOMEM: /* OOM routine works */
-			if (!oom) {
+			if (!oom || oom_check) {
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
