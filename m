Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CC2E26B006C
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 19:19:44 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3277745eaa.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 16:19:44 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 4/9] numa, mm, sched: Implement last-CPU+PID hash tracking
Date: Fri,  7 Dec 2012 01:19:21 +0100
Message-Id: <1354839566-15697-5-git-send-email-mingo@kernel.org>
In-Reply-To: <1354839566-15697-1-git-send-email-mingo@kernel.org>
References: <1354839566-15697-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

We rely on the page::last_cpu field (embedded in remaining bits of the
page flags field), to drive NUMA placement: the last_cpu gives us
information about which tasks access memory on what node, and it also
gives us information about which tasks relate to each other, in that
they access the same pages.

There was a constant source of statistics skew resulting out of
last_cpu, in that if a task migrated from one CPU to another, it
would see last_cpu accesses from that last CPU (the pages it
accessed on that CPU), but would account them as a 'shared' memory
access relationship.

So in a sense a phantom task on the previous CPU would haunt our
task, even if this task never ever iteracts with other tasks in
any serious manner.

Anothr skew of the statistics was that of preemption: if a task
ran on another CPU and accessed our pages but descheduled, then
we'd suspect that CPU - and the next task running on it - of being
in a sharing relationship with us.

To solve these skews and to improve the quality of the statistics
hash the last 8 bits of the PID to the last_cpu field. We name
this 'cpupid' because it's cheaper to handle it as a single integer
in most places. Wherever code needs to take an actual look at
the last_cpu and last_pid information embedded, it it can do so
via simple shifting and masking.

Propagate this all way through the code and make use of it.

As a result of this change the sharing/private fault statistics
stabilized and improved very markedly: convergence is faster
and less prone to workload noise. 4x JVM runs come to within
2-3% of the theoretical performance maximum:

 Thu Dec  6 16:10:34 CET 2012
 spec1.txt:           throughput =     190191.50 SPECjbb2005 bops
 spec2.txt:           throughput =     194783.63 SPECjbb2005 bops
 spec3.txt:           throughput =     192812.69 SPECjbb2005 bops
 spec4.txt:           throughput =     193898.09 SPECjbb2005 bops
                                      --------------------------
       SUM:           throughput =     771685.91 SPECjbb2005 bops

The cost is 8 more bits used from the page flags - this space
is still available on 64-bit systems, with a common distro
config (Fedora) compiled.

There is the potential of false sharing if the PIDs of two tasks
are equal modulo 256 - this degrades the statistics somewhat but
does not completely eliminate it. Related tasks are typically
launched close to each other, so I don't expect this to be a
problem in practice - if it is then we can do some better (maybe
wider) PID hashing in the future.

This mechanism is only used on (default-off) CONFIG_NUMA_BALANCING=y
kernels.

Also, while at it, pass the 'migrated' information to the
task_numa_fault() handler consistently.

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/mm.h                | 79 ++++++++++++++++++++++++++-------------
 include/linux/mm_types.h          |  4 +-
 include/linux/page-flags-layout.h | 23 ++++++++----
 include/linux/sched.h             |  4 +-
 kernel/sched/fair.c               | 26 +++++++++++--
 mm/huge_memory.c                  | 23 ++++++------
 mm/memory.c                       | 26 +++++++------
 mm/mempolicy.c                    | 23 ++++++++++--
 mm/migrate.c                      |  4 +-
 mm/page_alloc.c                   |  6 ++-
 10 files changed, 148 insertions(+), 70 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a9454ca..c576b43 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -585,7 +585,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
-#define LAST_CPU_PGOFF		(ZONES_PGOFF - LAST_CPU_WIDTH)
+#define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -595,7 +595,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
-#define LAST_CPU_PGSHIFT	(LAST_CPU_PGOFF * (LAST_CPU_WIDTH != 0))
+#define LAST_CPUPID_PGSHIFT	(LAST_CPUPID_PGOFF * (LAST_CPUPID_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -617,7 +617,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
-#define LAST_CPU_MASK		((1UL << LAST_CPU_WIDTH) - 1)
+#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -657,64 +657,93 @@ static inline int page_to_nid(const struct page *page)
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
-#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
-static inline int page_xchg_last_cpu(struct page *page, int cpu)
+
+static inline int cpupid_to_cpu(int cpupid)
+{
+	return (cpupid >> CPUPID_PID_BITS) & CPUPID_CPU_MASK;
+}
+
+static inline int cpupid_to_pid(int cpupid)
+{
+	return cpupid & CPUPID_PID_MASK;
+}
+
+static inline int cpu_pid_to_cpupid(int cpu, int pid)
+{
+	return ((cpu & CPUPID_CPU_MASK) << CPUPID_CPU_BITS) | (pid & CPUPID_PID_MASK);
+}
+
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+static inline int page_xchg_last_cpupid(struct page *page, int cpupid)
 {
-	return xchg(&page->_last_cpu, cpu);
+	return xchg(&page->_last_cpupid, cpupid);
 }
 
-static inline int page_last_cpu(struct page *page)
+static inline int page_last__cpupid(struct page *page)
 {
-	return page->_last_cpu;
+	return page->_last_cpupid;
 }
 
-static inline void reset_page_last_cpu(struct page *page)
+static inline void reset_page_last_cpupid(struct page *page)
 {
-	page->_last_cpu = -1;
+	page->_last_cpupid = -1;
 }
+
 #else
-static inline int page_xchg_last_cpu(struct page *page, int cpu)
+static inline int page_xchg_last_cpupid(struct page *page, int cpupid)
 {
 	unsigned long old_flags, flags;
-	int last_cpu;
+	int last_cpupid;
 
 	do {
 		old_flags = flags = page->flags;
-		last_cpu = (flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
+		last_cpupid = (flags >> LAST_CPUPID_PGSHIFT) & LAST_CPUPID_MASK;
+
+		flags &= ~(LAST_CPUPID_MASK << LAST_CPUPID_PGSHIFT);
+		flags |= (cpupid & LAST_CPUPID_MASK) << LAST_CPUPID_PGSHIFT;
 
-		flags &= ~(LAST_CPU_MASK << LAST_CPU_PGSHIFT);
-		flags |= (cpu & LAST_CPU_MASK) << LAST_CPU_PGSHIFT;
 	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
 
-	return last_cpu;
+	return last_cpupid;
+}
+
+static inline int page_last__cpupid(struct page *page)
+{
+	return (page->flags >> LAST_CPUPID_PGSHIFT) & LAST_CPUPID_MASK;
+}
+
+static inline void reset_page_last_cpupid(struct page *page)
+{
+	page_xchg_last_cpupid(page, -1);
 }
+#endif /* LAST_CPUPID_NOT_IN_PAGE_FLAGS */
 
-static inline int page_last_cpu(struct page *page)
+static inline int page_last__cpu(struct page *page)
 {
-	return (page->flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
+	return cpupid_to_cpu(page_last__cpupid(page));
 }
 
-static inline void reset_page_last_cpu(struct page *page)
+static inline int page_last__pid(struct page *page)
 {
+	return cpupid_to_pid(page_last__cpupid(page));
 }
 
-#endif /* LAST_CPU_NOT_IN_PAGE_FLAGS */
-#else /* CONFIG_NUMA_BALANCING */
-static inline int page_xchg_last_cpu(struct page *page, int cpu)
+#else /* !CONFIG_NUMA_BALANCING: */
+static inline int page_xchg_last_cpupid(struct page *page, int cpu)
 {
 	return page_to_nid(page);
 }
 
-static inline int page_last_cpu(struct page *page)
+static inline int page_last__cpupid(struct page *page)
 {
 	return page_to_nid(page);
 }
 
-static inline void reset_page_last_cpu(struct page *page)
+static inline void reset_page_last_cpupid(struct page *page)
 {
 }
 
-#endif /* CONFIG_NUMA_BALANCING */
+#endif /* !CONFIG_NUMA_BALANCING */
 
 static inline struct zone *page_zone(const struct page *page)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cd2be76..ba08f34 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -178,8 +178,8 @@ struct page {
 	void *shadow;
 #endif
 
-#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
-	int _last_cpu;
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+	int _last_cpupid;
 #endif
 }
 /*
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index b258132..9435d64 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -56,16 +56,23 @@
 #define NODES_WIDTH		0
 #endif
 
+/* Reduce false sharing: */
+#define CPUPID_PID_BITS		8
+#define CPUPID_PID_MASK		((1 << CPUPID_PID_BITS)-1)
+
+#define CPUPID_CPU_BITS		NR_CPUS_BITS
+#define CPUPID_CPU_MASK		((1 << CPUPID_CPU_BITS)-1)
+
 #ifdef CONFIG_NUMA_BALANCING
-#define LAST_CPU_SHIFT	NR_CPUS_BITS
+# define LAST_CPUPID_SHIFT	(CPUPID_CPU_BITS+CPUPID_PID_BITS)
 #else
-#define LAST_CPU_SHIFT	0
+# define LAST_CPUPID_SHIFT	0
 #endif
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPU_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
-#define LAST_CPU_WIDTH	LAST_CPU_SHIFT
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+# define LAST_CPUPID_WIDTH	LAST_CPUPID_SHIFT
 #else
-#define LAST_CPU_WIDTH	0
+# define LAST_CPUPID_WIDTH	0
 #endif
 
 /*
@@ -73,11 +80,11 @@
  * there.  This includes the case where there is no node, so it is implicit.
  */
 #if !(NODES_WIDTH > 0 || NODES_SHIFT == 0)
-#define NODE_NOT_IN_PAGE_FLAGS
+# define NODE_NOT_IN_PAGE_FLAGS
 #endif
 
-#if defined(CONFIG_NUMA_BALANCING) && LAST_CPU_WIDTH == 0
-#define LAST_CPU_NOT_IN_PAGE_FLAGS
+#if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
+# define LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #endif
 
 #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1c3cc50..1041c0d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1601,9 +1601,9 @@ struct task_struct {
 #define tsk_cpus_allowed(tsk) (&(tsk)->cpus_allowed)
 
 #ifdef CONFIG_NUMA_BALANCING
-extern void task_numa_fault(int node, int cpu, int pages);
+extern void task_numa_fault(unsigned long addr, int node, int cpupid, int pages, bool migrated);
 #else
-static inline void task_numa_fault(int node, int cpu, int pages) { }
+static inline void task_numa_fault(unsigned long addr, int node, int cpupid, int pages, bool migrated) { }
 #endif /* CONFIG_NUMA_BALANCING */
 
 /*
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 8664f39..1547d66 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2267,11 +2267,31 @@ out_hit:
 /*
  * Got a PROT_NONE fault for a page on @node.
  */
-void task_numa_fault(int node, int last_cpu, int pages)
+void task_numa_fault(unsigned long addr, int node, int last_cpupid, int pages, bool migrated)
 {
 	struct task_struct *p = current;
-	int priv = (task_cpu(p) == last_cpu);
-	int idx = 2*node + priv;
+	int this_cpu = raw_smp_processor_id();
+	int last_cpu = cpupid_to_cpu(last_cpupid);
+	int last_pid = cpupid_to_pid(last_cpupid);
+	int this_pid = current->pid & CPUPID_PID_MASK;
+	int priv;
+	int idx;
+
+	if (last_cpupid != cpu_pid_to_cpupid(-1, -1)) {
+		/* Did we access it last time around? */
+		if (last_pid == this_pid) {
+			priv = 1;
+		} else {
+			priv = 0;
+		}
+	} else {
+		/* The default for fresh pages is private: */
+		priv = 1;
+		last_cpu = this_cpu;
+		node = cpu_to_node(this_cpu);
+	}
+
+	idx = 2*node + priv;
 
 	WARN_ON_ONCE(last_cpu == -1 || node == -1);
 	BUG_ON(!p->numa_faults);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 53e08a2..e6820aa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1024,10 +1024,10 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	int last_cpu;
+	int last_cpupid;
 	int target_nid;
-	int current_nid = -1;
-	bool migrated;
+	int page_nid = -1;
+	bool migrated = false;
 	bool page_locked = false;
 
 	spin_lock(&mm->page_table_lock);
@@ -1036,10 +1036,11 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(pmd);
 	get_page(page);
-	current_nid = page_to_nid(page);
-	last_cpu = page_last_cpu(page);
+	page_nid = page_to_nid(page);
+	last_cpupid = page_last__cpupid(page);
+
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	target_nid = mpol_misplaced(page, vma, haddr);
@@ -1067,7 +1068,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				pmdp, pmd, addr,
 				page, target_nid);
 	if (migrated)
-		current_nid = target_nid;
+		page_nid = target_nid;
 	else {
 		spin_lock(&mm->page_table_lock);
 		if (unlikely(!pmd_same(pmd, *pmdp))) {
@@ -1077,7 +1078,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		goto clear_pmdnuma;
 	}
 
-	task_numa_fault(current_nid, last_cpu, HPAGE_PMD_NR);
+	task_numa_fault(addr, page_nid, last_cpupid, HPAGE_PMD_NR, migrated);
 	return 0;
 
 clear_pmdnuma:
@@ -1090,8 +1091,8 @@ clear_pmdnuma:
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	if (current_nid != -1)
-		task_numa_fault(current_nid, last_cpu, HPAGE_PMD_NR);
+	if (page_nid != -1)
+		task_numa_fault(addr, page_nid, last_cpupid, HPAGE_PMD_NR, migrated);
 	return 0;
 }
 
@@ -1384,7 +1385,7 @@ static void __split_huge_page_refcount(struct page *page)
 		page_tail->mapping = page->mapping;
 
 		page_tail->index = page->index + i;
-		page_xchg_last_cpu(page_tail, page_last_cpu(page));
+		page_xchg_last_cpupid(page_tail, page_last__cpupid(page));
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/memory.c b/mm/memory.c
index cca216e..6ebfbbe 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -70,8 +70,8 @@
 
 #include "internal.h"
 
-#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
-#warning Unfortunate NUMA config, growing page-frame for last_cpu.
+#ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
+# warning Large NUMA config, growing page-frame for last_cpu+pid.
 #endif
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
@@ -3472,7 +3472,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	bool migrated = false;
 	spinlock_t *ptl;
 	int target_nid;
-	int last_cpu;
+	int last_cpupid;
 	int page_nid;
 
 	/*
@@ -3505,14 +3505,14 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	WARN_ON_ONCE(page_nid == -1);
 
 	/* Get it before mpol_misplaced() flips it: */
-	last_cpu = page_last_cpu(page);
-	WARN_ON_ONCE(last_cpu == -1);
+	last_cpupid = page_last__cpupid(page);
 
 	target_nid = numa_migration_target(page, vma, addr, page_nid);
 	if (target_nid == -1) {
 		pte_unmap_unlock(ptep, ptl);
 		goto out;
 	}
+	WARN_ON_ONCE(target_nid == page_nid);
 
 	/* Get a reference for migration: */
 	get_page(page);
@@ -3524,7 +3524,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_nid = target_nid;
 out:
 	/* Always account where the page currently is, physically: */
-	task_numa_fault(page_nid, last_cpu, 1);
+	task_numa_fault(addr, page_nid, last_cpupid, 1, migrated);
 
 	return 0;
 }
@@ -3562,7 +3562,7 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct page *page;
 		int page_nid;
 		int target_nid;
-		int last_cpu;
+		int last_cpupid;
 		bool migrated;
 		pte_t pteval;
 
@@ -3592,12 +3592,16 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_nid = page_to_nid(page);
 		WARN_ON_ONCE(page_nid == -1);
 
-		last_cpu = page_last_cpu(page);
-		WARN_ON_ONCE(last_cpu == -1);
+		last_cpupid = page_last__cpupid(page);
 
 		target_nid = numa_migration_target(page, vma, addr, page_nid);
-		if (target_nid == -1)
+		if (target_nid == -1) {
+			/* Always account where the page currently is, physically: */
+			task_numa_fault(addr, page_nid, last_cpupid, 1, 0);
+
 			continue;
+		}
+		WARN_ON_ONCE(target_nid == page_nid);
 
 		/* Get a reference for the migration: */
 		get_page(page);
@@ -3609,7 +3613,7 @@ int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			page_nid = target_nid;
 
 		/* Always account where the page currently is, physically: */
-		task_numa_fault(page_nid, last_cpu, 1);
+		task_numa_fault(addr, page_nid, last_cpupid, 1, migrated);
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 42da0f2..2f2095c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2338,6 +2338,10 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	struct zone *zone;
 	int page_nid = page_to_nid(page);
 	int target_node = page_nid;
+#ifdef CONFIG_NUMA_BALANCING
+	int cpupid_last_access = -1;
+	int cpu_last_access = -1;
+#endif
 
 	BUG_ON(!vma);
 
@@ -2394,15 +2398,18 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		BUG();
 	}
 
+#ifdef CONFIG_NUMA_BALANCING
 	/* Migrate the page towards the node whose CPU is referencing it */
 	if (pol->flags & MPOL_F_MORON) {
-		int cpu_last_access;
+		int this_cpupid;
 		int this_cpu;
 		int this_node;
 
 		this_cpu = raw_smp_processor_id();
 		this_node = numa_node_id();
 
+		this_cpupid = cpu_pid_to_cpupid(this_cpu, current->pid);
+
 		/*
 		 * Multi-stage node selection is used in conjunction
 		 * with a periodic migration fault to build a temporal
@@ -2424,12 +2431,20 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		 * it less likely we act on an unlikely task<->page
 		 * relation.
 		 */
-		cpu_last_access = page_xchg_last_cpu(page, this_cpu);
+		cpupid_last_access = page_xchg_last_cpupid(page, this_cpupid);
 
-		/* Migrate towards us: */
-		if (cpu_last_access == this_cpu)
+		/* Freshly allocated pages not accessed by anyone else yet: */
+		if (cpupid_last_access == cpu_pid_to_cpupid(-1, -1)) {
+			cpu_last_access = this_cpu;
 			target_node = this_node;
+		} else {
+			cpu_last_access = cpupid_to_cpu(cpupid_last_access);
+			/* Migrate towards us in the default policy: */
+			if (cpu_last_access == this_cpu)
+				target_node = this_node;
+		}
 	}
+#endif
 out_keep_page:
 	mpol_cond_put(pol);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 14202e7..9562fa8 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1458,7 +1458,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 					  __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 	if (newpage)
-		page_xchg_last_cpu(newpage, page_last_cpu(page));
+		page_xchg_last_cpupid(newpage, page_last__cpupid(page));
 
 	return newpage;
 }
@@ -1567,7 +1567,7 @@ int migrate_misplaced_transhuge_page_put(struct mm_struct *mm,
 		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 		goto out_dropref;
 	}
-	page_xchg_last_cpu(new_page, page_last_cpu(page));
+	page_xchg_last_cpupid(new_page, page_last__cpupid(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
 	if (!isolated) {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 92e88bd..6d72372 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -608,7 +608,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
-	reset_page_last_cpu(page);
+	reset_page_last_cpupid(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -850,6 +850,8 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
 
+	reset_page_last_cpupid(page);
+
 	if (gfp_flags & __GFP_ZERO)
 		prep_zero_page(page, order, gfp_flags);
 
@@ -3827,7 +3829,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
-		reset_page_last_cpu(page);
+		reset_page_last_cpupid(page);
 		SetPageReserved(page);
 		/*
 		 * Mark the block movable so that blocks are reserved for
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
