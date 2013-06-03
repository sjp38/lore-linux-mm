Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B84A56B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 14:30:30 -0400 (EDT)
Date: Mon, 3 Jun 2013 14:30:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130603183018.GJ15576@cmpxchg.org>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
 <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603153432.GC18588@dhcp22.suse.cz>
 <20130603164839.GG15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603164839.GG15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, Jun 03, 2013 at 12:48:39PM -0400, Johannes Weiner wrote:
> On Mon, Jun 03, 2013 at 05:34:32PM +0200, Michal Hocko wrote:
> > On Sat 01-06-13 02:11:51, Johannes Weiner wrote:
> > [...]
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Subject: [PATCH] memcg: more robust oom handling
> > > 
> > > The memcg OOM handling is incredibly fragile because once a memcg goes
> > > OOM, one task (kernel or userspace) is responsible for resolving the
> > > situation.  Every other task that gets caught trying to charge memory
> > > gets stuck in a waitqueue while potentially holding various filesystem
> > > and mm locks on which the OOM handling task may now deadlock.
> > > 
> > > Do two things to charge attempts under OOM:
> > > 
> > > 1. Do not trap system calls (buffered IO and friends), just return
> > >    -ENOMEM.  Userspace should be able to handle this... right?
> > > 
> > > 2. Do not trap page faults directly in the charging context.  Instead,
> > >    remember the OOMing memcg in the task struct and fully unwind the
> > >    page fault stack first.  Then synchronize the memcg OOM from
> > >    pagefault_out_of_memory()
> > 
> > I think this should work and I really like it! Nice work Johannes, I
> > never dared to go that deep and my opposite approach was also much more
> > fragile.
> > 
> > I am just afraid about all the other archs that do not support (from
> > quick grep it looks like: blackfin, c6x, h8300, metag, mn10300,
> > openrisc, score and tile). What would be an alternative for them?
> > #ifdefs for the old code (something like ARCH_HAS_FAULT_OOM_RETRY)? This
> > would be acceptable for me.
> 
> blackfin is NOMMU but I guess the others should be converted to the
> proper OOM protocol anyway and not just kill the faulting task.  I can
> update them in the next version of the patch (series).

It's no longer necessary since I remove the arch-specific flag
setting, but I converted them anyway while I was at it.  Will send
them as a separate patch.

> > > Not-quite-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  arch/x86/mm/fault.c        |   2 +
> > >  include/linux/memcontrol.h |   6 +++
> > >  include/linux/sched.h      |   6 +++
> > >  mm/memcontrol.c            | 104 +++++++++++++++++++++++++--------------------
> > >  mm/oom_kill.c              |   7 ++-
> > >  5 files changed, 78 insertions(+), 47 deletions(-)
> > > 
> > [...]
> > > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > > index e692a02..cf60aef 100644
> > > --- a/include/linux/sched.h
> > > +++ b/include/linux/sched.h
> > > @@ -1282,6 +1282,8 @@ struct task_struct {
> > >  				 * execve */
> > >  	unsigned in_iowait:1;
> > >  
> > > +	unsigned in_userfault:1;
> > > +
> > 
> > [This is more a nit pick but before I forget while I am reading through
> > the rest of the patch.]
> > 
> > OK there is a lot of room around those bit fields but as this is only
> > for memcg and you are enlarging the structure by the pointer then you
> > can reuse bottom bit of memcg pointer.
> 
> I just didn't want to put anything in the arch code that looks too
> memcgish, even though it's the only user right now.  But granted, it
> will also probably remain the only user for a while.

I tried a couple of variants, including using the lowest memcg bit,
but it all turned into more ugliness.  So that .in_userfault is still
there in v2, but it's now set in handle_mm_fault() in a generic manner
depending on a fault flag, please reconsider if you can live with it.

> > > @@ -2085,56 +2087,76 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> > >  }
> > >  
> > >  /*
> > > - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > > + * try to call OOM killer
> > >   */
> > > -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> > > -				  int order)
> > > +static void mem_cgroup_oom(struct mem_cgroup *memcg,
> > > +			   gfp_t mask, int order,
> > > +			   bool in_userfault)
> > >  {
> > > -	struct oom_wait_info owait;
> > > -	bool locked, need_to_kill;
> > > -
> > > -	owait.memcg = memcg;
> > > -	owait.wait.flags = 0;
> > > -	owait.wait.func = memcg_oom_wake_function;
> > > -	owait.wait.private = current;
> > > -	INIT_LIST_HEAD(&owait.wait.task_list);
> > > -	need_to_kill = true;
> > > -	mem_cgroup_mark_under_oom(memcg);
> > > +	bool locked, need_to_kill = true;
> > >  
> > >  	/* At first, try to OOM lock hierarchy under memcg.*/
> > >  	spin_lock(&memcg_oom_lock);
> > >  	locked = mem_cgroup_oom_lock(memcg);
> > > -	/*
> > > -	 * Even if signal_pending(), we can't quit charge() loop without
> > > -	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
> > > -	 * under OOM is always welcomed, use TASK_KILLABLE here.
> > > -	 */
> > > -	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> > > -	if (!locked || memcg->oom_kill_disable)
> > > +	if (!locked || memcg->oom_kill_disable) {
> > >  		need_to_kill = false;
> > > +		if (in_userfault) {
> > > +			/*
> > > +			 * We start sleeping on the OOM waitqueue only
> > > +			 * after unwinding the page fault stack, so
> > > +			 * make sure we detect wakeups that happen
> > > +			 * between now and then.
> > > +			 */
> > > +			mem_cgroup_mark_under_oom(memcg);
> > > +			current->memcg_oom.wakeups =
> > > +				atomic_read(&memcg->oom_wakeups);
> > > +			css_get(&memcg->css);
> > > +			current->memcg_oom.memcg = memcg;
> > > +		}
> > > +	}
> > >  	if (locked)
> > >  		mem_cgroup_oom_notify(memcg);
> > >  	spin_unlock(&memcg_oom_lock);
> > >  
> > >  	if (need_to_kill) {
> > > -		finish_wait(&memcg_oom_waitq, &owait.wait);
> > >  		mem_cgroup_out_of_memory(memcg, mask, order);
> > > -	} else {
> > > -		schedule();
> > > -		finish_wait(&memcg_oom_waitq, &owait.wait);
> > > +		memcg_oom_recover(memcg);
> > 
> > Why do we need to call memcg_oom_recover here? We do not know that any
> > charges have been released. Say mem_cgroup_out_of_memory selected a task
> > which migrated to our group (without its charges) so we would kill the
> > poor guy and free no memory from this group.
> > Now you wake up oom waiters to refault but they will end up in the same
> > situation. I think it should be sufficient to wait for memcg_oom_recover
> > until the memory is uncharged (which we do already).
> 
> It's a leftover from how it was before (see the memcg_wakeup_oom
> below), but you are right, we can get rid of it.

Removed it.

> > > @@ -2647,16 +2665,12 @@ again:
> > >  			css_put(&memcg->css);
> > >  			goto nomem;
> > >  		case CHARGE_NOMEM: /* OOM routine works */
> > > -			if (!oom) {
> > > +			if (!oom || oom_check) {
> > 
> > OK, this allows us to remove the confusing nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES
> > from the branch where oom_check is set to true
> 
> Oops, will update.

I removed it and also renamed oom_check to invoke_oom, which makes
more sense IMO.

The wakeup race is also fixed.  Here is version 2:

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
   OOM killer but do not trap other tasks and just return -ENOMEM for
   everyone.  Userspace should be able to handle this... right?

2. When OOMing in a page fault, invoke the OOM killer but do not trap
   other chargers directly in the charging code.  Instead, remember
   the OOMing memcg in the task struct and then fully unwind the page
   fault stack first.  Then synchronize the memcg OOM from
   pagefault_out_of_memory().

While reworking the OOM routine, also remove a needless OOM waitqueue
wakeup when invoking the killer.  Only uncharges and limit increases,
things that actually change the memory situation, should do wakeups.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h |   6 +++
 include/linux/mm.h         |   1 +
 include/linux/sched.h      |   6 +++
 mm/ksm.c                   |   2 +-
 mm/memcontrol.c            | 117 +++++++++++++++++++++++----------------------
 mm/memory.c                |  40 +++++++++++-----
 mm/oom_kill.c              |   7 ++-
 7 files changed, 108 insertions(+), 71 deletions(-)

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
index 178a8d9..639bfc9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1117,6 +1117,8 @@ struct task_struct {
 				 * execve */
 	unsigned in_iowait:1;
 
+	unsigned in_userfault:1;
+
 	/* task may not gain privileges */
 	unsigned no_new_privs:1;
 
@@ -1405,6 +1407,10 @@ struct task_struct {
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
index de22292..97cf32b 100644
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
@@ -2179,56 +2181,72 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
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
-	if (!locked || memcg->oom_kill_disable)
+	if (!locked || memcg->oom_kill_disable) {
 		need_to_kill = false;
+		if (current->in_userfault) {
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
 
-	if (need_to_kill) {
-		finish_wait(&memcg_oom_waitq, &owait.wait);
+	if (need_to_kill)
 		mem_cgroup_out_of_memory(memcg, mask, order);
-	} else {
-		schedule();
-		finish_wait(&memcg_oom_waitq, &owait.wait);
-	}
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
 
@@ -2541,12 +2559,11 @@ enum {
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
@@ -2603,14 +2620,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
@@ -2713,7 +2726,7 @@ again:
 	}
 
 	do {
-		bool oom_check;
+		bool invoke_oom = oom && !nr_oom_retries;
 
 		/* If killed, bypass charge */
 		if (fatal_signal_pending(current)) {
@@ -2721,14 +2734,8 @@ again:
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
@@ -2741,16 +2748,12 @@ again:
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
index 6dc1882..ff5e2d7 100644
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
+		current->in_userfault = 1;
+
+	ret = __handle_mm_fault(mm, vma, address, flags);
+
+	if (in_userfault)
+		current->in_userfault = 0;
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
