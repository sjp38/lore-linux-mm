Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 40D816B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 12:18:37 -0400 (EDT)
Date: Thu, 5 Sep 2013 12:18:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130905161817.GD856@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904101852.58E70042@pobox.sk>
 <20130905115430.GB856@cmpxchg.org>
 <20130905124352.GB13666@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130905124352.GB13666@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: azurIt <azurit@pobox.sk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Sep 05, 2013 at 02:43:52PM +0200, Michal Hocko wrote:
> On Thu 05-09-13 07:54:30, Johannes Weiner wrote:
> > There are a few more find_or_create() sites that do not propagate an
> > error and it's incredibly hard to find out whether they are even taken
> > during a page fault.  It's not practical to annotate them all with
> > memcg OOM toggles, so let's just catch all OOM contexts at the end of
> > handle_mm_fault() and clear them if !VM_FAULT_OOM instead of treating
> > this like an error.
> > 
> > azur, here is a patch on top of your modified 3.2.  Note that Michal
> > might be onto something and we are looking at multiple issues here,
> > but the log excert above suggests this fix is required either way.
> > 
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] mm: memcg: handle non-error OOM situations more gracefully
> > 
> > Many places that can trigger a memcg OOM situation return gracefully
> > and don't propagate VM_FAULT_OOM up the fault stack.
> > 
> > It's not practical to annotate all of them to disable the memcg OOM
> > killer.  Instead, just clean up any set OOM state without warning in
> > case the fault is not returning VM_FAULT_OOM.
> > 
> > Also fail charges immediately when the current task already is in an
> > OOM context.  Otherwise, the previous context gets overwritten and the
> > memcg reference is leaked.
> 
> This is getting way more trickier than I've expected and hoped for. The
> above should work although I cannot say I love it. I am afraid we do not
> have many choices left without polluting the every single place which
> can charge, though :/

I thought it was less tricky, actually, since we don't need to mess
around with the selective nested OOM toggling anymore.

Thinking more about it, the whole thing can be made even simpler.

The series currently keeps the locking & killing in the direct charge
path and then only waits in the synchronize path, which requires quite
a bit of state communication.  Wouldn't it be simpler to just do
everything in the unwind path?  We would only have to remember the
memcg and the gfp_mask, and then the synchronize path would decide
whether to kill, wait, or just clean up (!VM_FAULT_OOM case).  This
would also have the benefit that we really don't invoke the OOM killer
when the fault is overall successful.  I'm attaching a draft below.

> >  include/linux/memcontrol.h | 40 ++++++----------------------------------
> >  include/linux/sched.h      |  3 ---
> >  mm/filemap.c               | 11 +----------
> >  mm/memcontrol.c            | 15 ++++++++-------
> >  mm/memory.c                |  8 ++------
> >  mm/oom_kill.c              |  2 +-
> >  6 files changed, 18 insertions(+), 61 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index b113c0f..7c43903 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -120,39 +120,16 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> >  extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> >  					struct task_struct *p);
> >  
> > -/**
> > - * mem_cgroup_toggle_oom - toggle the memcg OOM killer for the current task
> > - * @new: true to enable, false to disable
> > - *
> > - * Toggle whether a failed memcg charge should invoke the OOM killer
> > - * or just return -ENOMEM.  Returns the previous toggle state.
> > - *
> > - * NOTE: Any path that enables the OOM killer before charging must
> > - *       call mem_cgroup_oom_synchronize() afterward to finalize the
> > - *       OOM handling and clean up.
> > - */
> > -static inline bool mem_cgroup_toggle_oom(bool new)
> > -{
> > -	bool old;
> > -
> > -	old = current->memcg_oom.may_oom;
> > -	current->memcg_oom.may_oom = new;
> > -
> > -	return old;
> > -}
> 
> I will not miss this guy.

Me neither!

> > diff --git a/mm/memory.c b/mm/memory.c
> > index cdbe41b..cdad471 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -57,7 +57,6 @@
> >  #include <linux/swapops.h>
> >  #include <linux/elf.h>
> >  #include <linux/gfp.h>
> > -#include <linux/stacktrace.h>
> >  
> >  #include <asm/io.h>
> >  #include <asm/pgalloc.h>
> > @@ -3521,11 +3520,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	if (flags & FAULT_FLAG_USER)
> >  		mem_cgroup_disable_oom();
> >  
> > -	if (WARN_ON(task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))) {
> > -		printk("Fixing unhandled memcg OOM context set up from:\n");
> > -		print_stack_trace(&current->memcg_oom.trace, 0);
> > -		mem_cgroup_oom_synchronize();
> > -	}
> > +	if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> > +		mem_cgroup_oom_synchronize(false);
> 
> This deserves a fat comment /me thinks

Yes.  As per your other email, I also folded it into the
FAULT_FLAG_USER branch.

Here is an updated draft.  Things changed slightly throughout the
series, so I'm sending a complete replacement of the last patch.  It's
a much simpler change at this point, IMO and keeps the (cleaned up)
OOM handling code as it was (mem_cgroup_handle_oom is basically just
renamed to mem_cgroup_oom_synchronize)

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcg: do not trap chargers with full callstack on OOM

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

To fix this, never do any OOM handling directly in the charge context.
When an OOM situation is detected, let the task remember the memcg and
then handle the OOM (kill or wait) only after the page fault stack is
unwound and about to return to userspace.

Reported-by: Reported-by: azurIt <azurit@pobox.sk>
Debugged-by: Michal Hocko <mhocko@suse.cz>
Not-yet-Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 17 ++++++++
 include/linux/sched.h      |  2 +
 mm/memcontrol.c            | 96 +++++++++++++++++++++++++++++++---------------
 mm/memory.c                | 11 +++++-
 mm/oom_kill.c              |  2 +
 5 files changed, 96 insertions(+), 32 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index b344b3a..325da07 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -132,6 +132,13 @@ static inline void mem_cgroup_disable_oom(void)
 	current->memcg_oom.may_oom = 0;
 }
 
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return p->memcg_oom.memcg;
+}
+
+bool mem_cgroup_oom_synchronize(bool wait);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -353,6 +360,16 @@ static inline void mem_cgroup_disable_oom(void)
 {
 }
 
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return false;
+}
+
+static inline bool mem_cgroup_oom_synchronize(bool wait)
+{
+	return false;
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_page_stat_item idx)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 21834a9..fb1f145 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1569,6 +1569,8 @@ struct task_struct {
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
 	struct memcg_oom_info {
+		struct mem_cgroup *memcg;
+		gfp_t gfp_mask;
 		unsigned int may_oom:1;
 	} memcg_oom;
 #endif
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 36bb58f..56643fe 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1858,14 +1858,59 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 		memcg_wakeup_oom(memcg);
 }
 
-/*
- * try to call OOM killer. returns false if we should exit memory-reclaim loop.
+static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
+{
+	if (!current->memcg_oom.may_oom)
+		return;
+	/*
+	 * We are in the middle of the charge context here, so we
+	 * don't want to block when potentially sitting on a callstack
+	 * that holds all kinds of filesystem and mm locks.
+	 *
+	 * Also, the caller may handle a failed allocation gracefully
+	 * (like optional page cache readahead) and so an OOM killer
+	 * invocation might not even be necessary.
+	 *
+	 * That's why we don't do anything here except remember the
+	 * OOM context and then deal with it at the end of the page
+	 * fault when the stack is unwound, the locks are released,
+	 * and when we know whether the fault was overall successful.
+	 */
+	css_get(&memcg->css);
+	current->memcg_oom.memcg = memcg;
+	current->memcg_oom.gfp_mask = mask;
+}
+
+/**
+ * mem_cgroup_oom_synchronize - complete memcg OOM handling
+ * @handle: actually kill/wait or just clean up the OOM state
+ *
+ * This has to be called at the end of a page fault if the memcg OOM
+ * handler was enabled.
+ *
+ * Memcg supports userspace OOM handling where failed allocations must
+ * sleep on a waitqueue until the userspace task resolves the
+ * situation.  Sleeping directly in the charge context with all kinds
+ * of locks held is not a good idea, instead we remember an OOM state
+ * in the task and mem_cgroup_oom_synchronize() has to be called at
+ * the end of the page fault to complete the OOM handling.
+ *
+ * Returns %true if an ongoing memcg OOM situation was detected and
+ * completed, %false otherwise.
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
+bool mem_cgroup_oom_synchronize(bool handle)
 {
+	struct mem_cgroup *memcg = current->memcg_oom.memcg;
 	struct oom_wait_info owait;
 	bool locked;
 
+	/* OOM is global, do not handle */
+	if (!memcg)
+		return false;
+
+	if (!handle)
+		goto cleanup;
+
 	owait.mem = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
@@ -1894,7 +1939,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 	if (locked && !memcg->oom_kill_disable) {
 		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, mask);
+		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask);
 	} else {
 		schedule();
 		mem_cgroup_unmark_under_oom(memcg);
@@ -1910,11 +1955,9 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 		 */
 		memcg_oom_recover(memcg);
 	}
-
-	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
-		return false;
-	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+cleanup:
+	current->memcg_oom.memcg = NULL;
+	css_put(&memcg->css);
 	return true;
 }
 
@@ -2204,11 +2247,10 @@ enum {
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
@@ -2266,14 +2308,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (mem_cgroup_wait_acct_move(mem_over_limit))
 		return CHARGE_RETRY;
 
-	/* If we don't need to call oom-killer at el, return immediately */
-	if (!oom_check || !current->memcg_oom.may_oom)
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
@@ -2301,6 +2339,12 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		goto bypass;
 
 	/*
+	 * Task already OOMed, just get out of here.
+	 */
+	if (unlikely(current->memcg_oom.memcg))
+		goto nomem;
+
+	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
 	 * thread group leader migrates. It's possible that mm is not
@@ -2358,7 +2402,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2366,13 +2410,7 @@ again:
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
@@ -2385,16 +2423,12 @@ again:
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
index 7b66056..20c43a0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3517,8 +3517,17 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	ret = __handle_mm_fault(mm, vma, address, flags);
 
-	if (flags & FAULT_FLAG_USER)
+	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_disable_oom();
+		/*
+		 * The task may have entered a memcg OOM situation but
+		 * if the allocation error was handled gracefully (no
+		 * VM_FAULT_OOM), there is no need to kill anything.
+		 * Just clean up the OOM state peacefully.
+		 */
+		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
+			mem_cgroup_oom_synchronize(false);
+	}
 
 	return ret;
 }
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 069b64e..3bf664c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -785,6 +785,8 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	if (mem_cgroup_oom_synchronize(true))
+		return;
 	if (try_set_system_oom()) {
 		out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
