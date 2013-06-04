Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7E3236B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 14:49:07 -0400 (EDT)
Date: Tue, 4 Jun 2013 14:48:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130604184852.GO15576@cmpxchg.org>
References: <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603153432.GC18588@dhcp22.suse.cz>
 <20130603164839.GG15576@cmpxchg.org>
 <20130603183018.GJ15576@cmpxchg.org>
 <20130604091749.GB31242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604091749.GB31242@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, Jun 04, 2013 at 11:17:49AM +0200, Michal Hocko wrote:
> On Mon 03-06-13 14:30:18, Johannes Weiner wrote:
> > On Mon, Jun 03, 2013 at 12:48:39PM -0400, Johannes Weiner wrote:
> > > On Mon, Jun 03, 2013 at 05:34:32PM +0200, Michal Hocko wrote:
> [...]
> > > > I am just afraid about all the other archs that do not support (from
> > > > quick grep it looks like: blackfin, c6x, h8300, metag, mn10300,
> > > > openrisc, score and tile). What would be an alternative for them?
> > > > #ifdefs for the old code (something like ARCH_HAS_FAULT_OOM_RETRY)? This
> > > > would be acceptable for me.
> > > 
> > > blackfin is NOMMU but I guess the others should be converted to the
> > > proper OOM protocol anyway and not just kill the faulting task.  I can
> > > update them in the next version of the patch (series).
> > 
> > It's no longer necessary since I remove the arch-specific flag
> > setting, but I converted them anyway while I was at it.  Will send
> > them as a separate patch.
> 
> I am still not sure doing this unconditionally is the right way. Say
> that a new arch will be added. How the poor implementer knows that memcg
> oom handling requires an arch specific code to work properly?

It doesn't.  All that's required is that it follows the generic OOM
killer protocol and calls pagefault_out_of_memory().  Killing the
faulting task right there in the page fault handler is simply a bug
and needs to be fixed so I don't think that any extra care from our
side is necessary.

> > @@ -2179,56 +2181,72 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> >  }
> >  
> >  /*
> > - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > + * try to call OOM killer
> >   */
> > -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> > -				  int order)
> > +static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  {
> > -	struct oom_wait_info owait;
> > -	bool locked, need_to_kill;
> > -
> > -	owait.memcg = memcg;
> > -	owait.wait.flags = 0;
> > -	owait.wait.func = memcg_oom_wake_function;
> > -	owait.wait.private = current;
> > -	INIT_LIST_HEAD(&owait.wait.task_list);
> > -	need_to_kill = true;
> > -	mem_cgroup_mark_under_oom(memcg);
> > +	bool locked, need_to_kill = true;
> >  
> >  	/* At first, try to OOM lock hierarchy under memcg.*/
> >  	spin_lock(&memcg_oom_lock);
> >  	locked = mem_cgroup_oom_lock(memcg);
> > -	/*
> > -	 * Even if signal_pending(), we can't quit charge() loop without
> > -	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
> > -	 * under OOM is always welcomed, use TASK_KILLABLE here.
> > -	 */
> > -	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> > -	if (!locked || memcg->oom_kill_disable)
> > +	if (!locked || memcg->oom_kill_disable) {
> >  		need_to_kill = false;
> > +		if (current->in_userfault) {
> > +			/*
> > +			 * We start sleeping on the OOM waitqueue only
> > +			 * after unwinding the page fault stack, so
> > +			 * make sure we detect wakeups that happen
> > +			 * between now and then.
> > +			 */
> > +			mem_cgroup_mark_under_oom(memcg);
> > +			current->memcg_oom.wakeups =
> > +				atomic_read(&memcg->oom_wakeups);
> > +			css_get(&memcg->css);
> > +			current->memcg_oom.memcg = memcg;
> > +		}
> > +	}
> >  	if (locked)
> >  		mem_cgroup_oom_notify(memcg);
> >  	spin_unlock(&memcg_oom_lock);
> >  
> > -	if (need_to_kill) {
> > -		finish_wait(&memcg_oom_waitq, &owait.wait);
> > +	if (need_to_kill)
> >  		mem_cgroup_out_of_memory(memcg, mask, order);
> 
> Now that I am looking at this again I've realized that this
> is not correct. The task which triggers memcg OOM will not
> have memcg_oom.memcg set so it would trigger a global OOM in
> pagefault_out_of_memory. Either we should return CHARGE_RETRY (and
> propagate it via mem_cgroup_do_charge) for need_to_kill or set up
> current->memcg_oom also for need_to_kill.

You are absolutely right!  I fixed it with a separate bit, like so:

+       struct memcg_oom_info {
+               unsigned int in_userfault:1;
+               unsigned int in_memcg_oom:1;
+               int wakeups;
+               struct mem_cgroup *wait_on_memcg;
+       } memcg_oom;

in_memcg_oom signals mem_cgroup_oom_synchronize() that it's a memcg
OOM and that it should always return true to not invoke the global
killer.  But wait_on_memcg might or might not be set, depending if the
task needs to sleep.

So the task invoking the memcg OOM killer won't sleep but retry the
fault instead (everybody else might be sleeping and the first OOM
killer invocation might not have freed anything).

> > diff --git a/mm/memory.c b/mm/memory.c
> > index 6dc1882..ff5e2d7 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1815,7 +1815,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >  			while (!(page = follow_page_mask(vma, start,
> >  						foll_flags, &page_mask))) {
> >  				int ret;
> > -				unsigned int fault_flags = 0;
> > +				unsigned int fault_flags = FAULT_FLAG_KERNEL;
> >  
> >  				/* For mlock, just skip the stack guard page. */
> >  				if (foll_flags & FOLL_MLOCK) {
> 
> This is also a bit tricky. Say there is an unlikely situation when a
> task fails to charge because of memcg OOM, it couldn't lock the oom
> so it ended up with current->memcg_oom set and __get_user_pages will
> turn VM_FAULT_OOM into ENOMEM but memcg_oom is still there. Then the
> following global OOM condition gets confused (well the oom will be
> triggered by somebody else so it shouldn't end up in the endless loop
> but still...), doesn't it?

But current->memcg_oom is not set up unless current->in_userfault.
And get_user_pages does not set this flag.

> > @@ -3760,22 +3761,14 @@ unlock:
> >  /*
> >   * By the time we get here, we already hold the mm semaphore
> >   */
> > -int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > -		unsigned long address, unsigned int flags)
> > +static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > +			     unsigned long address, unsigned int flags)
> 
> Is this reusable? Who would call this helper or is it just for the code
> readability? I would probably prefer a smaller patch but I do not have a
> strong opinion on this.

I just figured I'd move all the task-specific setup into the outer
function and leave this inner one with the actual page table stuff.

The function is not called from somewhere else, but I don't see a
problem with splitting it into logical parts and have the individual
parts more readable.  The alternative would have been to make every
return in handle_mm_fault() a { ret = -EFOO; goto out }, and that
would have been harder to follow.

> > @@ -3856,6 +3849,31 @@ retry:
> >  	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
> >  }
> >  
> > +int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > +		    unsigned long address, unsigned int flags)
> > +{
> > +	int in_userfault = !(flags & FAULT_FLAG_KERNEL);
> > +	int ret;
> > +
> > +	__set_current_state(TASK_RUNNING);
> > +
> > +	count_vm_event(PGFAULT);
> > +	mem_cgroup_count_vm_event(mm, PGFAULT);
> > +
> > +	/* do counter updates before entering really critical section. */
> > +	check_sync_rss_stat(current);
> > +
> > +	if (in_userfault)
> > +		current->in_userfault = 1;
> 
> If this is just memcg thing (although you envision future usage outside
> of memcg) then would it make more sense to use a memcg helper here which
> would be noop for !CONFIG_MEMCG and disabled for mem_cgroup_disabled.

Fair enough.  I made it conditional on CONFIG_MEMCG, but an extra
branch to set the bit seems a little elaborate, don't you think?

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] memcg: do not sleep on OOM waitqueue with full charge context

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
index d6183f0..b8ec9d1 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,6 +121,15 @@ unsigned long mem_cgroup_get_lru_size(struct lruvec *lruvec, enum lru_list);
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
 
@@ -337,6 +346,19 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
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
index e0c8528..93b29ed 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -167,6 +167,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
+#define FAULT_FLAG_KERNEL	0x80	/* kernel-triggered fault (get_user_pages etc.) */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 178a8d9..270420a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1405,6 +1405,12 @@ struct task_struct {
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
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
 	atomic_t ptrace_bp_refcnt;
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
index de22292..537b74b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -298,6 +298,7 @@ struct mem_cgroup {
 
 	bool		oom_lock;
 	atomic_t	under_oom;
+	atomic_t	oom_wakeups;
 
 	atomic_t	refcnt;
 
@@ -2168,6 +2169,7 @@ static int memcg_oom_wake_function(wait_queue_t *wait,
 
 static void memcg_wakeup_oom(struct mem_cgroup *memcg)
 {
+	atomic_inc(&memcg->oom_wakeups);
 	/* for filtering, pass "memcg" as argument. */
 	__wake_up(&memcg_oom_waitq, TASK_NORMAL, 0, memcg);
 }
@@ -2179,56 +2181,103 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
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
+	 * the situation is resolved.  Which can take some time,
+	 * because it might be handled by a userspace task.
+	 *
+	 * However, this is the charge context, which means that we
+	 * may sit on a large call stack and hold various filesystem
+	 * locks, the mmap_sem etc., and we don't want the OOM handler
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
 
@@ -2541,12 +2590,11 @@ enum {
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
@@ -2603,14 +2651,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2713,7 +2757,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2721,14 +2765,8 @@ again:
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
@@ -2741,16 +2779,12 @@ again:
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
index 6dc1882..6d3d8c3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1815,7 +1815,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			while (!(page = follow_page_mask(vma, start,
 						foll_flags, &page_mask))) {
 				int ret;
-				unsigned int fault_flags = 0;
+				unsigned int fault_flags = FAULT_FLAG_KERNEL;
 
 				/* For mlock, just skip the stack guard page. */
 				if (foll_flags & FOLL_MLOCK) {
@@ -1943,6 +1943,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	if (!vma || address < vma->vm_start)
 		return -EFAULT;
 
+	fault_flags |= FAULT_FLAG_KERNEL;
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {
 		if (ret & VM_FAULT_OOM)
@@ -3760,22 +3761,14 @@ unlock:
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
 
@@ -3856,6 +3849,31 @@ retry:
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
