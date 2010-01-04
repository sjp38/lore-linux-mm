Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 01BAF600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 15:49:24 -0500 (EST)
Message-Id: <20100104182813.479668508@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Mon, 04 Jan 2010 19:24:33 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 4/8] mm: RCU free vmas
Content-Disposition: inline; filename=mm-foo-3.patch
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

TODO:
 - should be SRCU, lack of call_srcu()

In order to allow speculative vma lookups, RCU free the struct
vm_area_struct.

We use two means of detecting a vma is still valid:
 - firstly, we set RB_CLEAR_NODE once we remove a vma from the tree.
 - secondly, we check the vma sequence number.

These two things combined will guarantee that 1) the vma is still
present and two, it still covers the same range from when we looked it
up.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/mm.h       |   12 ++++++++++++
 include/linux/mm_types.h |    2 ++
 init/Kconfig             |   34 +++++++++++++++++-----------------
 kernel/sched.c           |    9 ++++++++-
 mm/mmap.c                |   33 +++++++++++++++++++++++++++++++--
 5 files changed, 70 insertions(+), 20 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -765,6 +765,18 @@ unsigned long unmap_vmas(struct mmu_gath
 		unsigned long end_addr, unsigned long *nr_accounted,
 		struct zap_details *);
 
+static inline int vma_is_dead(struct vm_area_struct *vma, unsigned int sequence)
+{
+	int ret = RB_EMPTY_NODE(&vma->vm_rb);
+	unsigned seq = vma->vm_sequence.sequence;
+	/*
+	 * Matches both the wmb in write_seqlock_begin/end() and
+	 * the wmb in detach_vmas_to_be_unmapped()/__unlink_vma().
+	 */
+	smp_rmb();
+	return ret || seq != sequence;
+}
+
 /**
  * mm_walk - callbacks for walk_page_range
  * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
 #include <linux/seqlock.h>
+#include <linux/rcupdate.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -188,6 +189,7 @@ struct vm_area_struct {
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
 	seqcount_t vm_sequence;
+	struct rcu_head vm_rcu_head;
 };
 
 struct core_thread {
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -222,6 +222,19 @@ void unlink_file_vma(struct vm_area_stru
 	}
 }
 
+static void free_vma_rcu(struct rcu_head *head)
+{
+	struct vm_area_struct *vma =
+		container_of(head, struct vm_area_struct, vm_rcu_head);
+
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+static void free_vma(struct vm_area_struct *vma)
+{
+	call_rcu(&vma->vm_rcu_head, free_vma_rcu);
+}
+
 /*
  * Close a vm structure and free it, returning the next.
  */
@@ -238,7 +251,7 @@ static struct vm_area_struct *remove_vma
 			removed_exe_file_vma(vma->vm_mm);
 	}
 	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma(vma);
 	return next;
 }
 
@@ -488,6 +501,14 @@ __vma_unlink(struct mm_struct *mm, struc
 {
 	prev->vm_next = vma->vm_next;
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
+	/*
+	 * Ensure the removal is completely comitted to memory
+	 * before clearing the node.
+	 *
+	 * Matched by vma_is_dead()/handle_speculative_fault().
+	 */
+	smp_wmb();
+	RB_CLEAR_NODE(&vma->vm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
 }
@@ -644,7 +665,7 @@ again:			remove_next = 1 + (end > next->
 		}
 		mm->map_count--;
 		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -1858,6 +1879,14 @@ detach_vmas_to_be_unmapped(struct mm_str
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		/*
+		 * Ensure the removal is completely comitted to memory
+		 * before clearing the node.
+		 *
+		 * Matched by vma_is_dead()/handle_speculative_fault().
+		 */
+		smp_wmb();
+		RB_CLEAR_NODE(&vma->vm_rb);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -314,19 +314,19 @@ menu "RCU Subsystem"
 
 choice
 	prompt "RCU Implementation"
-	default TREE_RCU
+	default TREE_PREEMPT_RCU
 
-config TREE_RCU
-	bool "Tree-based hierarchical RCU"
-	help
-	  This option selects the RCU implementation that is
-	  designed for very large SMP system with hundreds or
-	  thousands of CPUs.  It also scales down nicely to
-	  smaller systems.
+#config TREE_RCU
+#	bool "Tree-based hierarchical RCU"
+#	help
+#	  This option selects the RCU implementation that is
+#	  designed for very large SMP system with hundreds or
+#	  thousands of CPUs.  It also scales down nicely to
+#	  smaller systems.
 
 config TREE_PREEMPT_RCU
 	bool "Preemptable tree-based hierarchical RCU"
-	depends on PREEMPT
+#	depends on PREEMPT
 	help
 	  This option selects the RCU implementation that is
 	  designed for very large SMP systems with hundreds or
@@ -334,14 +334,14 @@ config TREE_PREEMPT_RCU
 	  is also required.  It also scales down nicely to
 	  smaller systems.
 
-config TINY_RCU
-	bool "UP-only small-memory-footprint RCU"
-	depends on !SMP
-	help
-	  This option selects the RCU implementation that is
-	  designed for UP systems from which real-time response
-	  is not required.  This option greatly reduces the
-	  memory footprint of RCU.
+#config TINY_RCU
+#	bool "UP-only small-memory-footprint RCU"
+#	depends on !SMP
+#	help
+#	  This option selects the RCU implementation that is
+#	  designed for UP systems from which real-time response
+#	  is not required.  This option greatly reduces the
+#	  memory footprint of RCU.
 
 endchoice
 
Index: linux-2.6/kernel/sched.c
===================================================================
--- linux-2.6.orig/kernel/sched.c
+++ linux-2.6/kernel/sched.c
@@ -9689,7 +9689,14 @@ void __init sched_init(void)
 #ifdef CONFIG_DEBUG_SPINLOCK_SLEEP
 static inline int preempt_count_equals(int preempt_offset)
 {
-	int nested = (preempt_count() & ~PREEMPT_ACTIVE) + rcu_preempt_depth();
+	int nested = (preempt_count() & ~PREEMPT_ACTIVE)
+		/*
+		 * remove this for we need preemptible RCU
+		 * exactly because it needs to sleep..
+		 *
+		 + rcu_preempt_depth()
+		 */
+		;
 
 	return (nested == PREEMPT_INATOMIC_BASE + preempt_offset);
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
