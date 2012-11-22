Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 26B688D0016
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:51:47 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:51:46 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 29/33] sched, mm, mempolicy: Add per task mempolicy
Date: Thu, 22 Nov 2012 23:49:50 +0100
Message-Id: <1353624594-1118-30-git-send-email-mingo@kernel.org>
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

We are going to make use of it in the NUMA code: each thread will
converge not just to a group of related tasks, but to a specific
group of memory nodes as well.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mempolicy.h | 39 +--------------------------------------
 include/linux/mm_types.h  | 40 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h     |  3 ++-
 kernel/sched/core.c       |  7 +++++++
 mm/mempolicy.c            | 16 +++-------------
 5 files changed, 53 insertions(+), 52 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index c511e25..f44b7f3 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -6,11 +6,11 @@
 #define _LINUX_MEMPOLICY_H 1
 
 
+#include <linux/mm_types.h>
 #include <linux/mmzone.h>
 #include <linux/slab.h>
 #include <linux/rbtree.h>
 #include <linux/spinlock.h>
-#include <linux/nodemask.h>
 #include <linux/pagemap.h>
 #include <uapi/linux/mempolicy.h>
 
@@ -19,43 +19,6 @@ struct mm_struct;
 #ifdef CONFIG_NUMA
 
 /*
- * Describe a memory policy.
- *
- * A mempolicy can be either associated with a process or with a VMA.
- * For VMA related allocations the VMA policy is preferred, otherwise
- * the process policy is used. Interrupts ignore the memory policy
- * of the current process.
- *
- * Locking policy for interlave:
- * In process context there is no locking because only the process accesses
- * its own state. All vma manipulation is somewhat protected by a down_read on
- * mmap_sem.
- *
- * Freeing policy:
- * Mempolicy objects are reference counted.  A mempolicy will be freed when
- * mpol_put() decrements the reference count to zero.
- *
- * Duplicating policy objects:
- * mpol_dup() allocates a new mempolicy and copies the specified mempolicy
- * to the new storage.  The reference count of the new object is initialized
- * to 1, representing the caller of mpol_dup().
- */
-struct mempolicy {
-	atomic_t refcnt;
-	unsigned short mode; 	/* See MPOL_* above */
-	unsigned short flags;	/* See set_mempolicy() MPOL_F_* above */
-	union {
-		short 		 preferred_node; /* preferred */
-		nodemask_t	 nodes;		/* interleave/bind */
-		/* undefined for default */
-	} v;
-	union {
-		nodemask_t cpuset_mems_allowed;	/* relative to these nodes */
-		nodemask_t user_nodemask;	/* nodemask passed by user */
-	} w;
-};
-
-/*
  * Support for managing mempolicy data objects (clone, copy, destroy)
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
  */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5995652..cd2be76 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -13,6 +13,7 @@
 #include <linux/page-debug-flags.h>
 #include <linux/uprobes.h>
 #include <linux/page-flags-layout.h>
+#include <linux/nodemask.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -203,6 +204,45 @@ struct page_frag {
 
 typedef unsigned long __nocast vm_flags_t;
 
+#ifdef CONFIG_NUMA
+/*
+ * Describe a memory policy.
+ *
+ * A mempolicy can be either associated with a process or with a VMA.
+ * For VMA related allocations the VMA policy is preferred, otherwise
+ * the process policy is used. Interrupts ignore the memory policy
+ * of the current process.
+ *
+ * Locking policy for interlave:
+ * In process context there is no locking because only the process accesses
+ * its own state. All vma manipulation is somewhat protected by a down_read on
+ * mmap_sem.
+ *
+ * Freeing policy:
+ * Mempolicy objects are reference counted.  A mempolicy will be freed when
+ * mpol_put() decrements the reference count to zero.
+ *
+ * Duplicating policy objects:
+ * mpol_dup() allocates a new mempolicy and copies the specified mempolicy
+ * to the new storage.  The reference count of the new object is initialized
+ * to 1, representing the caller of mpol_dup().
+ */
+struct mempolicy {
+	atomic_t refcnt;
+	unsigned short mode; 	/* See MPOL_* above */
+	unsigned short flags;	/* See set_mempolicy() MPOL_F_* above */
+	union {
+		short 		 preferred_node; /* preferred */
+		nodemask_t	 nodes;		/* interleave/bind */
+		/* undefined for default */
+	} v;
+	union {
+		nodemask_t cpuset_mems_allowed;	/* relative to these nodes */
+		nodemask_t user_nodemask;	/* nodemask passed by user */
+	} w;
+};
+#endif
+
 /*
  * A region containing a mapping of a non-memory backed file under NOMMU
  * conditions.  These are held in a global tree and are pinned by the VMAs that
diff --git a/include/linux/sched.h b/include/linux/sched.h
index be73297..696492e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1516,7 +1516,8 @@ struct task_struct {
 
 	struct task_struct *shared_buddy, *shared_buddy_curr;
 	unsigned long shared_buddy_faults, shared_buddy_faults_curr;
-	int ideal_cpu, ideal_cpu_curr;
+	int ideal_cpu, ideal_cpu_curr, ideal_cpu_candidate;
+	struct mempolicy numa_policy;
 
 #endif /* CONFIG_NUMA_BALANCING */
 
diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 39cf991..794efa0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -72,6 +72,7 @@
 #include <linux/slab.h>
 #include <linux/init_task.h>
 #include <linux/binfmts.h>
+#include <uapi/linux/mempolicy.h>
 
 #include <asm/switch_to.h>
 #include <asm/tlb.h>
@@ -1563,6 +1564,12 @@ static void __sched_fork(struct task_struct *p)
 	p->shared_buddy_faults = 0;
 	p->ideal_cpu = -1;
 	p->ideal_cpu_curr = -1;
+	atomic_set(&p->numa_policy.refcnt, 1);
+	p->numa_policy.mode = MPOL_INTERLEAVE;
+	p->numa_policy.flags = 0;
+	p->numa_policy.v.preferred_node = 0;
+	p->numa_policy.v.nodes = node_online_map;
+
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 02890f2..d71a93d 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -118,20 +118,12 @@ static struct mempolicy default_policy_local = {
 	.flags		= MPOL_F_LOCAL,
 };
 
-/*
- * .v.nodes is set by numa_policy_init():
- */
-static struct mempolicy default_policy_shared = {
-	.refcnt			= ATOMIC_INIT(1), /* never free it */
-	.mode			= MPOL_INTERLEAVE,
-	.flags			= 0,
-};
-
 static struct mempolicy *default_policy(void)
 {
+#ifdef CONFIG_NUMA_BALANCING
 	if (task_numa_shared(current) == 1)
-		return &default_policy_shared;
-
+		return &current->numa_policy;
+#endif
 	return &default_policy_local;
 }
 
@@ -2518,8 +2510,6 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL);
 
-	default_policy_shared.v.nodes = node_online_map;
-
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
