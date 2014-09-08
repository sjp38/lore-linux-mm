Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 236EB6B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 04:27:28 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id r10so20147784pdi.22
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 01:27:27 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id u10si16334732pds.201.2014.09.08.01.27.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 01:27:26 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so7297790pde.31
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 01:27:26 -0700 (PDT)
Date: Mon, 8 Sep 2014 01:25:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <20140903095815.GK4783@worktop.ger.corp.intel.com>
Message-ID: <alpine.LSU.2.11.1409080023100.1610@eggly.anvils>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>

On Wed, 3 Sep 2014, Peter Zijlstra wrote:
> On Wed, Aug 27, 2014 at 11:02:20PM -0700, Hugh Dickins wrote:
> > On Wed, 20 Aug 2014, Chintan Pandya wrote:
> > 
> > > KSM thread to scan pages is scheduled on definite timeout. That wakes up
> > > CPU from idle state and hence may affect the power consumption. Provide
> > > an optional support to use deferrable timer which suites low-power
> > > use-cases.
> > > 
> > > Typically, on our setup we observed, 10% less power consumption with some
> > > use-cases in which CPU goes to power collapse frequently. For example,
> > > playing audio on Soc which has HW based Audio encoder/decoder, CPU
> > > remains idle for longer duration of time. This idle state will save
> > > significant CPU power consumption if KSM don't wakes them up
> > > periodically.
> > > 
> > > Note that, deferrable timers won't be deferred if any CPU is active and
> > > not in IDLE state.
> > > 
> > > By default, deferrable timers is enabled. To disable deferrable timers,
> > > $ echo 0 > /sys/kernel/mm/ksm/deferrable_timer
> > 
> > I have now experimented.  And, much as I wanted to eliminate the
> > tunable, and just have deferrable timers on, I have come right back
> > to your original position.
> > 
> > I was impressed by how quiet ksmd goes when there's nothing much
> > happening on the machine; but equally, disappointed in how slow
> > it then is to fulfil the outstanding merge work.  I agree with your
> > original assessment, that not everybody will want deferrable timer,
> > the way it is working at present.
> > 
> > I expect that can be fixed, partly by doing more work on wakeup from
> > a deferred timer, according to how long it has been deferred; and
> > partly by not deferring on idle until two passes of the list have been
> > completed.  But that's easier said than done, and might turn out to
> 
> So why not have the timer cancel itself when there is no more work to do
> and start itself up again when there's work added?

Well, yes, but... how do we know when there is no more work to do?
Further down I said:

> > But fixing that might require ksm hooks in hot locations where nobody
> > else would want them: I'm rather hoping we can strike a good enough
> > balance with your deferrable timer, that nobody will need any better.

Thomas has given reason why KSM might simply fail to do its job if we
rely on the deferrable timer.  So I've tried another approach, patch
below; but I do not expect you to jump for joy at the sight of it!

I've tried to minimize the offensive KSM hook in context_switch().
Why place it there, rather than do something near profile_tick() or
account_process_tick()?  Because KSM is aware of mms not tasks, and
context_switch() should have the next mm cachelines hot (if not, a
slight regrouping in mm_struct should do it); whereas I can find
no reference whatever to mm_struct in kernel/time, so hooking to
KSM from there would drag in another few cachelines every tick.

(Another approach would be to set up KSM hint faulting, along the
lines of NUMA hint faulting.  Not a path I'm keen to go down.)

I'm not thrilled with this patch, I think it's somewhat defective
in several ways.  But maybe in practice it will prove good enough,
and if so then I'd rather not waste effort on complicating it.

My own testing is not realistic, nor representative of real KSM users;
and I have no idea what values of pages_to_scan and sleep_millisecs
people really use (and those may make quite a difference to how
well it works).

Chintan, even if the scheduler guys turn out to hate it, please would
you give the patch below a try, to see how well it works in your
environment, whether it seems to go better or worse than your own patch.

If it works well enough for you, maybe we can come up with ideas to
make it more palatable.  I do think your issue is an important one
to fix, one way or another.

Thanks,
Hugh

[PATCH] ksm: avoid periodic wakeup while mergeable mms are quiet

Description yet to be written!

Reported-by: Chintan Pandya <cpandya@codeaurora.org>
Not-Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/ksm.h   |   14 +++++++++++
 include/linux/sched.h |    1 
 kernel/sched/core.c   |    9 ++++++-
 mm/ksm.c              |   50 ++++++++++++++++++++++++++++------------
 4 files changed, 58 insertions(+), 16 deletions(-)

--- 3.17-rc4/include/linux/ksm.h	2014-03-30 20:40:15.000000000 -0700
+++ linux/include/linux/ksm.h	2014-09-07 11:54:41.528003316 -0700
@@ -12,6 +12,7 @@
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/sched.h>
+#include <linux/wait.h>
 
 struct stable_node;
 struct mem_cgroup;
@@ -21,6 +22,7 @@ int ksm_madvise(struct vm_area_struct *v
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
+wait_queue_head_t *__ksm_switch(struct mm_struct *mm);
 
 static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
@@ -35,6 +37,13 @@ static inline void ksm_exit(struct mm_st
 		__ksm_exit(mm);
 }
 
+static inline wait_queue_head_t *ksm_switch(struct mm_struct *mm)
+{
+	if (unlikely(test_bit(MMF_SWITCH_TO_KSM, &mm->flags)))
+		return __ksm_switch(mm);
+	return NULL;
+}
+
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
  * which KSM maps into multiple mms, wherever identical anonymous page content
@@ -87,6 +96,11 @@ static inline void ksm_exit(struct mm_st
 {
 }
 
+static inline wait_queue_head_t *ksm_switch(struct mm_struct *mm)
+{
+	return NULL;
+}
+
 static inline int PageKsm(struct page *page)
 {
 	return 0;
--- 3.17-rc4/include/linux/sched.h	2014-08-16 16:00:53.909189060 -0700
+++ linux/include/linux/sched.h	2014-09-07 11:54:41.528003316 -0700
@@ -453,6 +453,7 @@ static inline int get_dumpable(struct mm
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_SWITCH_TO_KSM	21	/* notify KSM of switch to this mm */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
--- 3.17-rc4/kernel/sched/core.c	2014-08-16 16:00:54.062189063 -0700
+++ linux/kernel/sched/core.c	2014-09-07 11:54:41.528003316 -0700
@@ -61,6 +61,7 @@
 #include <linux/times.h>
 #include <linux/tsacct_kern.h>
 #include <linux/kprobes.h>
+#include <linux/ksm.h>
 #include <linux/delayacct.h>
 #include <linux/unistd.h>
 #include <linux/pagemap.h>
@@ -2304,6 +2305,7 @@ context_switch(struct rq *rq, struct tas
 	       struct task_struct *next)
 {
 	struct mm_struct *mm, *oldmm;
+	wait_queue_head_t *wake_ksm = NULL;
 
 	prepare_task_switch(rq, prev, next);
 
@@ -2320,8 +2322,10 @@ context_switch(struct rq *rq, struct tas
 		next->active_mm = oldmm;
 		atomic_inc(&oldmm->mm_count);
 		enter_lazy_tlb(oldmm, next);
-	} else
+	} else {
 		switch_mm(oldmm, mm, next);
+		wake_ksm = ksm_switch(mm);
+	}
 
 	if (!prev->mm) {
 		prev->active_mm = NULL;
@@ -2348,6 +2352,9 @@ context_switch(struct rq *rq, struct tas
 	 * frame will be invalid.
 	 */
 	finish_task_switch(this_rq(), prev);
+
+	if (wake_ksm)
+		wake_up_interruptible(wake_ksm);
 }
 
 /*
--- 3.17-rc4/mm/ksm.c	2014-08-16 16:00:54.132189065 -0700
+++ linux/mm/ksm.c	2014-09-07 11:54:41.528003316 -0700
@@ -205,6 +205,9 @@ static struct kmem_cache *rmap_item_cach
 static struct kmem_cache *stable_node_cache;
 static struct kmem_cache *mm_slot_cache;
 
+/* The number of mergeable mms which have recently run */
+static atomic_t active_mergeable_mms = ATOMIC_INIT(0);
+
 /* The number of nodes in the stable tree */
 static unsigned long ksm_pages_shared;
 
@@ -313,9 +316,13 @@ static inline struct mm_slot *alloc_mm_s
 	return kmem_cache_zalloc(mm_slot_cache, GFP_KERNEL);
 }
 
-static inline void free_mm_slot(struct mm_slot *mm_slot)
+static void free_mm_slot(struct mm_struct *mm, struct mm_slot *mm_slot)
 {
 	kmem_cache_free(mm_slot_cache, mm_slot);
+
+	clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+	if (!test_and_clear_bit(MMF_SWITCH_TO_KSM, &mm->flags))
+		atomic_dec(&active_mergeable_mms);
 }
 
 static struct mm_slot *get_mm_slot(struct mm_struct *mm)
@@ -801,8 +808,7 @@ static int unmerge_and_remove_all_rmap_i
 			list_del(&mm_slot->mm_list);
 			spin_unlock(&ksm_mmlist_lock);
 
-			free_mm_slot(mm_slot);
-			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+			free_mm_slot(mm, mm_slot);
 			up_read(&mm->mmap_sem);
 			mmdrop(mm);
 		} else {
@@ -1668,12 +1674,20 @@ next_mm:
 		list_del(&slot->mm_list);
 		spin_unlock(&ksm_mmlist_lock);
 
-		free_mm_slot(slot);
-		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+		free_mm_slot(mm, slot);
 		up_read(&mm->mmap_sem);
 		mmdrop(mm);
 	} else {
 		spin_unlock(&ksm_mmlist_lock);
+		/*
+		 * After completing its scan, assume this mm to be inactive,
+		 * but set a flag for context_switch() to notify us as soon
+		 * as it is used again: see ksm_switch().  If the number of
+		 * active_mergeable_mms goes down to zero, ksmd will sleep
+		 * to save power, until awoken by mergeable context_switch().
+		 */
+		if (!test_and_set_bit(MMF_SWITCH_TO_KSM, &mm->flags))
+			atomic_dec(&active_mergeable_mms);
 		up_read(&mm->mmap_sem);
 	}
 
@@ -1707,7 +1721,7 @@ static void ksm_do_scan(unsigned int sca
 
 static int ksmd_should_run(void)
 {
-	return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_list);
+	return (ksm_run & KSM_RUN_MERGE) && atomic_read(&active_mergeable_mms);
 }
 
 static int ksm_scan_thread(void *nothing)
@@ -1785,15 +1799,11 @@ int ksm_madvise(struct vm_area_struct *v
 int __ksm_enter(struct mm_struct *mm)
 {
 	struct mm_slot *mm_slot;
-	int needs_wakeup;
 
 	mm_slot = alloc_mm_slot();
 	if (!mm_slot)
 		return -ENOMEM;
 
-	/* Check ksm_run too?  Would need tighter locking */
-	needs_wakeup = list_empty(&ksm_mm_head.mm_list);
-
 	spin_lock(&ksm_mmlist_lock);
 	insert_to_mm_slots_hash(mm, mm_slot);
 	/*
@@ -1812,10 +1822,9 @@ int __ksm_enter(struct mm_struct *mm)
 		list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
 	spin_unlock(&ksm_mmlist_lock);
 
-	set_bit(MMF_VM_MERGEABLE, &mm->flags);
 	atomic_inc(&mm->mm_count);
-
-	if (needs_wakeup)
+	set_bit(MMF_VM_MERGEABLE, &mm->flags);
+	if (atomic_inc_return(&active_mergeable_mms) == 1)
 		wake_up_interruptible(&ksm_thread_wait);
 
 	return 0;
@@ -1850,8 +1859,7 @@ void __ksm_exit(struct mm_struct *mm)
 	spin_unlock(&ksm_mmlist_lock);
 
 	if (easy_to_free) {
-		free_mm_slot(mm_slot);
-		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
+		free_mm_slot(mm, mm_slot);
 		mmdrop(mm);
 	} else if (mm_slot) {
 		down_write(&mm->mmap_sem);
@@ -1859,6 +1867,18 @@ void __ksm_exit(struct mm_struct *mm)
 	}
 }
 
+wait_queue_head_t *__ksm_switch(struct mm_struct *mm)
+{
+	/*
+	 * Called by context_switch() to a hitherto inactive mergeable mm:
+	 * scheduler locks forbid immediate wakeup so leave that to caller.
+	 */
+	if (test_and_clear_bit(MMF_SWITCH_TO_KSM, &mm->flags) &&
+	    atomic_inc_return(&active_mergeable_mms) == 1)
+		return &ksm_thread_wait;
+	return NULL;
+}
+
 struct page *ksm_might_need_to_copy(struct page *page,
 			struct vm_area_struct *vma, unsigned long address)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
