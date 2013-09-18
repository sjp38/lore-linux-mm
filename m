Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f205.google.com (mail-ie0-f205.google.com [209.85.223.205])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6536B0044
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 12:46:11 -0400 (EDT)
Received: by mail-ie0-f205.google.com with SMTP id x13so653ief.0
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 09:46:11 -0700 (PDT)
Date: Wed, 18 Sep 2013 15:55:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130918195504.GF856@cmpxchg.org>
References: <20130916145744.GE3674@dhcp22.suse.cz>
 <20130916170543.77F1ECB4@pobox.sk>
 <20130916152548.GF3674@dhcp22.suse.cz>
 <20130916225246.A633145B@pobox.sk>
 <20130917000244.GD3278@cmpxchg.org>
 <20130917131535.94E0A843@pobox.sk>
 <20130917141013.GA30838@dhcp22.suse.cz>
 <20130918160304.6EDF2729@pobox.sk>
 <20130918180455.GD856@cmpxchg.org>
 <20130918181946.GE856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130918181946.GE856@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 18, 2013 at 02:19:46PM -0400, Johannes Weiner wrote:
> On Wed, Sep 18, 2013 at 02:04:55PM -0400, Johannes Weiner wrote:
> > On Wed, Sep 18, 2013 at 04:03:04PM +0200, azurIt wrote:
> > > > CC: "Johannes Weiner" <hannes@cmpxchg.org>, "Andrew Morton" <akpm@linux-foundation.org>, "David Rientjes" <rientjes@google.com>, "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>, "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
> > > >On Tue 17-09-13 13:15:35, azurIt wrote:
> > > >[...]
> > > >> Is something unusual on this stack?
> > > >> 
> > > >> 
> > > >> [<ffffffff810d1a5e>] dump_header+0x7e/0x1e0
> > > >> [<ffffffff810d195f>] ? find_lock_task_mm+0x2f/0x70
> > > >> [<ffffffff810d1f25>] oom_kill_process+0x85/0x2a0
> > > >> [<ffffffff810d24a8>] mem_cgroup_out_of_memory+0xa8/0xf0
> > > >> [<ffffffff8110fb76>] mem_cgroup_oom_synchronize+0x2e6/0x310
> > > >> [<ffffffff8110efc0>] ? mem_cgroup_uncharge_page+0x40/0x40
> > > >> [<ffffffff810d2703>] pagefault_out_of_memory+0x13/0x130
> > > >> [<ffffffff81026f6e>] mm_fault_error+0x9e/0x150
> > > >> [<ffffffff81027424>] do_page_fault+0x404/0x490
> > > >> [<ffffffff810f952c>] ? do_mmap_pgoff+0x3dc/0x430
> > > >> [<ffffffff815cb87f>] page_fault+0x1f/0x30
> > > >
> > > >This is a regular memcg OOM killer. Which dumps messages about what is
> > > >going to do. So no, nothing unusual, except if it was like that for ever
> > > >which would mean that oom_kill_process is in the endless loop. But a
> > > >single stack doesn't tell us much.
> > > >
> > > >Just a note. When you see something hogging a cpu and you are not sure
> > > >whether it might be in an endless loop inside the kernel it makes sense
> > > >to take several snaphosts of the stack trace and see if it changes. If
> > > >not and the process is not sleeping (there is no schedule on the trace)
> > > >then it might be looping somewhere waiting for Godot. If it is sleeping
> > > >then it is slightly harder because you would have to identify what it is
> > > >waiting for which requires to know a deeper context.
> > > >-- 
> > > >Michal Hocko
> > > >SUSE Labs
> > > 
> > > 
> > > 
> > > I was finally able to get stack of problematic process :) I saved it two times from the same process, as Michal suggested (i wasn't able to take more). Here it is:
> > > 
> > > First (doesn't look very helpfull):
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > 
> > > Second:
> > > [<ffffffff810e17d1>] shrink_zone+0x481/0x650
> > > [<ffffffff810e2ade>] do_try_to_free_pages+0xde/0x550
> > > [<ffffffff810e310b>] try_to_free_pages+0x9b/0x120
> > > [<ffffffff81148ccd>] free_more_memory+0x5d/0x60
> > > [<ffffffff8114931d>] __getblk+0x14d/0x2c0
> > > [<ffffffff8114c973>] __bread+0x13/0xc0
> > > [<ffffffff811968a8>] ext3_get_branch+0x98/0x140
> > > [<ffffffff81197497>] ext3_get_blocks_handle+0xd7/0xdc0
> > > [<ffffffff81198244>] ext3_get_block+0xc4/0x120
> > > [<ffffffff81155b8a>] do_mpage_readpage+0x38a/0x690
> > > [<ffffffff81155ffb>] mpage_readpages+0xfb/0x160
> > > [<ffffffff811972bd>] ext3_readpages+0x1d/0x20
> > > [<ffffffff810d9345>] __do_page_cache_readahead+0x1c5/0x270
> > > [<ffffffff810d9411>] ra_submit+0x21/0x30
> > > [<ffffffff810cfb90>] filemap_fault+0x380/0x4f0
> > > [<ffffffff810ef908>] __do_fault+0x78/0x5a0
> > > [<ffffffff810f2b24>] handle_pte_fault+0x84/0x940
> > > [<ffffffff810f354a>] handle_mm_fault+0x16a/0x320
> > > [<ffffffff8102715b>] do_page_fault+0x13b/0x490
> > > [<ffffffff815cb87f>] page_fault+0x1f/0x30
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > 
> > Ah, crap.  I'm sorry.  You even showed us this exact trace before in
> > another context, but I did not fully realize what __getblk() is doing.
> > 
> > My subsequent patches made a charge attempt return -ENOMEM without
> > reclaim if the memcg is under OOM.  And so the reason you have these
> > reclaim livelocks is because __getblk never fails on -ENOMEM.  When
> > the allocation returns -ENOMEM, it invokes GLOBAL DIRECT RECLAIM and
> > tries again in an endless loop.  The memcg code would previously just
> > loop inside the charge, reclaiming and killing, until the allocation
> > succeeded.  But the new code relies on the fault stack being unwound
> > to complete the OOM kill.  And since the stack is not unwound with
> > __getblk() looping around the allocation there is no more memcg
> > reclaim AND no memcg OOM kill, thus no chance of exiting.
> > 
> > That code is weird but really old, so it may take a while to evaluate
> > all the callers as to whether this can be changed.
> > 
> > In the meantime, I would just allow __getblk to bypass the memcg limit
> > when it still can't charge after reclaim.  Does the below get your
> > machine back on track?
> 
> Scratch that.  The idea is reasonable but the implementation is not
> fully cooked yet.  I'll send you an update.

Here is an update.  Full replacement on top of 3.2 since we tried a
dead end and it would be more painful to revert individual changes.

The first bug you had was the same task entering OOM repeatedly and
leaking the memcg reference, thus creating undeletable memcgs.  My
fixup added a condition that if the task already set up an OOM context
in that fault, another charge attempt would immediately return -ENOMEM
without even trying reclaim anymore.  This dropped __getblk() into an
endless loop of waking the flushers and performing global reclaim and
memcg returning -ENOMEM regardless of free memory.

The update now basically only changes this -ENOMEM to bypass, so that
the memory is not accounted and the limit ignored.  OOM killed tasks
are granted the same right, so that they can exit quickly and release
memory.  Likewise, we want a task that hit the OOM condition also to
finish the fault quickly so that it can invoke the OOM killer.

Does the following work for you, azur?

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
index b87068a..1b29ac5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -120,6 +120,25 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+static inline void mem_cgroup_oom_enable(void)
+{
+	WARN_ON(current->memcg_oom.may_oom);
+	current->memcg_oom.may_oom = 1;
+}
+
+static inline void mem_cgroup_oom_disable(void)
+{
+	WARN_ON(!current->memcg_oom.may_oom);
+	current->memcg_oom.may_oom = 0;
+}
+
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return p->memcg_oom.memcg;
+}
+
+bool mem_cgroup_oom_synchronize(bool handle);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -333,6 +352,24 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
 
+static inline void mem_cgroup_oom_enable(void)
+{
+}
+
+static inline void mem_cgroup_oom_disable(void)
+{
+}
+
+static inline bool task_in_memcg_oom(struct task_struct *p)
+{
+	return false;
+}
+
+static inline bool mem_cgroup_oom_synchronize(bool handle)
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
index 1c4f3e9..fb1f145 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1568,6 +1568,11 @@ struct task_struct {
 		unsigned long nr_pages;	/* uncharged usage */
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
 	} memcg_batch;
+	struct memcg_oom_info {
+		struct mem_cgroup *memcg;
+		gfp_t gfp_mask;
+		unsigned int may_oom:1;
+	} memcg_oom;
 #endif
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b63f5f7..66cc373 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1743,16 +1743,19 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_memcg,
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
@@ -1765,34 +1768,34 @@ static bool mem_cgroup_oom_lock(struct mem_cgroup *memcg)
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
@@ -1816,7 +1819,6 @@ static void mem_cgroup_unmark_under_oom(struct mem_cgroup *memcg)
 		atomic_add_unless(&iter->under_oom, -1, 0);
 }
 
-static DEFINE_SPINLOCK(memcg_oom_lock);
 static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
 
 struct oom_wait_info {
@@ -1856,56 +1858,95 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
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
-	bool locked, need_to_kill;
+	bool locked;
+
+	/* OOM is global, do not handle */
+	if (!memcg)
+		return false;
+
+	if (!handle)
+		goto cleanup;
 
 	owait.mem = memcg;
 	owait.wait.flags = 0;
 	owait.wait.func = memcg_oom_wake_function;
 	owait.wait.private = current;
 	INIT_LIST_HEAD(&owait.wait.task_list);
-	need_to_kill = true;
-	mem_cgroup_mark_under_oom(memcg);
 
-	/* At first, try to OOM lock hierarchy under memcg.*/
-	spin_lock(&memcg_oom_lock);
-	locked = mem_cgroup_oom_lock(memcg);
-	/*
-	 * Even if signal_pending(), we can't quit charge() loop without
-	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
-	 * under OOM is always welcomed, use TASK_KILLABLE here.
-	 */
 	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
-	if (!locked || memcg->oom_kill_disable)
-		need_to_kill = false;
+	mem_cgroup_mark_under_oom(memcg);
+
+	locked = mem_cgroup_oom_trylock(memcg);
+
 	if (locked)
 		mem_cgroup_oom_notify(memcg);
-	spin_unlock(&memcg_oom_lock);
 
-	if (need_to_kill) {
+	if (locked && !memcg->oom_kill_disable) {
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
-		mem_cgroup_out_of_memory(memcg, mask);
+		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask);
 	} else {
 		schedule();
+		mem_cgroup_unmark_under_oom(memcg);
 		finish_wait(&memcg_oom_waitq, &owait.wait);
 	}
-	spin_lock(&memcg_oom_lock);
-	if (locked)
-		mem_cgroup_oom_unlock(memcg);
-	memcg_wakeup_oom(memcg);
-	spin_unlock(&memcg_oom_lock);
-
-	mem_cgroup_unmark_under_oom(memcg);
 
-	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
-		return false;
-	/* Give chance to dying process */
-	schedule_timeout_uninterruptible(1);
+	if (locked) {
+		mem_cgroup_oom_unlock(memcg);
+		/*
+		 * There is no guarantee that an OOM-lock contender
+		 * sees the wakeups triggered by the OOM kill
+		 * uncharges.  Wake any sleepers explicitely.
+		 */
+		memcg_oom_recover(memcg);
+	}
+cleanup:
+	current->memcg_oom.memcg = NULL;
+	css_put(&memcg->css);
 	return true;
 }
 
@@ -2195,11 +2236,10 @@ enum {
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
@@ -2257,14 +2297,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2292,6 +2328,12 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		goto bypass;
 
 	/*
+	 * Task already OOMed, let it finish quickly.
+	 */
+	if (unlikely(current->memcg_oom.memcg))
+		goto bypass;
+
+	/*
 	 * We always charge the cgroup the mm_struct belongs to.
 	 * The mm_struct's mem_cgroup changes on task migration if the
 	 * thread group leader migrates. It's possible that mm is not
@@ -2349,7 +2391,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2357,13 +2399,7 @@ again:
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
@@ -2376,16 +2412,12 @@ again:
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
index 829d437..3d82ef9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3439,22 +3439,14 @@ unlock:
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
 
@@ -3503,6 +3495,43 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+		mem_cgroup_oom_enable();
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (flags & FAULT_FLAG_USER) {
+		mem_cgroup_oom_disable();
+		/*
+		 * The task may have entered a memcg OOM situation but
+		 * if the allocation error was handled gracefully (no
+		 * VM_FAULT_OOM), there is no need to kill anything.
+		 * Just clean up the OOM state peacefully.
+		 */
+		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
+			mem_cgroup_oom_synchronize(false);
+	}
+
+	return ret;
+}
+
 #ifndef __PAGETABLE_PUD_FOLDED
 /*
  * Allocate page upper directory.
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
