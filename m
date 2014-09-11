Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5DB6B0089
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 08:28:59 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wp18so5133278obc.28
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:28:59 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id hk2si1480992pdb.19.2014.09.11.05.28.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 05:28:58 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so8608308pab.15
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:28:56 -0700 (PDT)
Date: Thu, 11 Sep 2014 05:27:06 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers
 for scanner thread
In-Reply-To: <20140910081000.GN6758@twins.programming.kicks-ass.net>
Message-ID: <alpine.LSU.2.11.1409110450520.2465@eggly.anvils>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org> <1408536628-29379-2-git-send-email-cpandya@codeaurora.org> <alpine.LSU.2.11.1408272258050.10518@eggly.anvils> <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils> <20140908093949.GZ6758@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1409091225310.8432@eggly.anvils> <20140910081000.GN6758@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>

On Wed, 10 Sep 2014, Peter Zijlstra wrote:
> 
> So if this were switch_to(), we'd see next->mm as before the last
> context switch. And since that switch fully happened, it would also
> already have done the finish_task_switch() -> mmdrop().

Useful words of warning, thank you, which jolted me into realizing
an idiot defect in the patch I posted - and more reason why you're
right to keep me away from context_switch() - though it is still a
very handy place for a quick patch to see if going in this direction
(quiescent KSM rather than idle CPU) will be useful to Chintan.

The problem was my wake_ksm variable on the stack of context_switch():
when we emerge from switch_to() on a different stack, what's in wake_ksm
is whatever was placed there, perhaps years ago, by some earlier task.
It may work well enough most of the time (just as the deferrable timer
did despite its defect), but could sometimes delay KSM for years.

Here's a replacement patch, looks like a replacement will be more
useful to Chintan than an incremental.  No need to worry overmuch
about cachelines and placing mm references close together, if we
won't be going forward with a solution in context_switch() anyway.

[PATCH v2] ksm: avoid periodic wakeup while mergeable mms are quiet

Description yet to be written!

Reported-by: Chintan Pandya <cpandya@codeaurora.org>
Not-Signed-off-by: Hugh Dickins <hughd@google.com>
---

 include/linux/ksm.h   |   11 +++++++++
 include/linux/sched.h |    1 
 kernel/sched/core.c   |    5 ++++
 mm/ksm.c              |   48 +++++++++++++++++++++++++++-------------
 4 files changed, 50 insertions(+), 15 deletions(-)

--- 3.17-rc4/include/linux/ksm.h	2014-03-30 20:40:15.000000000 -0700
+++ linux/include/linux/ksm.h	2014-09-11 04:44:57.884104998 -0700
@@ -21,6 +21,7 @@ int ksm_madvise(struct vm_area_struct *v
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
+void __ksm_switch(struct mm_struct *mm);
 
 static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 {
@@ -35,6 +36,12 @@ static inline void ksm_exit(struct mm_st
 		__ksm_exit(mm);
 }
 
+static inline void ksm_switch(struct mm_struct *mm)
+{
+	if (unlikely(test_bit(MMF_SWITCH_TO_KSM, &mm->flags)))
+		__ksm_switch(mm);
+}
+
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
  * which KSM maps into multiple mms, wherever identical anonymous page content
@@ -87,6 +94,10 @@ static inline void ksm_exit(struct mm_st
 {
 }
 
+static inline void ksm_switch(struct mm_struct *mm)
+{
+}
+
 static inline int PageKsm(struct page *page)
 {
 	return 0;
--- 3.17-rc4/include/linux/sched.h	2014-08-16 16:00:53.909189060 -0700
+++ linux/include/linux/sched.h	2014-09-11 04:44:57.888104998 -0700
@@ -453,6 +453,7 @@ static inline int get_dumpable(struct mm
 
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
+#define MMF_SWITCH_TO_KSM	21	/* notify KSM of switch to this mm */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
--- 3.17-rc4/kernel/sched/core.c	2014-08-16 16:00:54.062189063 -0700
+++ linux/kernel/sched/core.c	2014-09-11 04:44:57.896104998 -0700
@@ -61,6 +61,7 @@
 #include <linux/times.h>
 #include <linux/tsacct_kern.h>
 #include <linux/kprobes.h>
+#include <linux/ksm.h>
 #include <linux/delayacct.h>
 #include <linux/unistd.h>
 #include <linux/pagemap.h>
@@ -2348,6 +2349,10 @@ context_switch(struct rq *rq, struct tas
 	 * frame will be invalid.
 	 */
 	finish_task_switch(this_rq(), prev);
+
+	mm = current->mm;
+	if (mm)
+		ksm_switch(mm);
 }
 
 /*
--- 3.17-rc4/mm/ksm.c	2014-08-16 16:00:54.132189065 -0700
+++ linux/mm/ksm.c	2014-09-11 04:44:57.900104998 -0700
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
@@ -1859,6 +1867,16 @@ void __ksm_exit(struct mm_struct *mm)
 	}
 }
 
+void __ksm_switch(struct mm_struct *mm)
+{
+	/*
+	 * Called by context_switch() to a hitherto inactive mergeable mm.
+	 */
+	if (test_and_clear_bit(MMF_SWITCH_TO_KSM, &mm->flags) &&
+	    atomic_inc_return(&active_mergeable_mms) == 1)
+		wake_up_interruptible(&ksm_thread_wait);
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
