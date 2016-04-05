Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id D0DE06B0298
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 18:05:57 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id c20so19112055pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:05:57 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id fo1si10210964pad.118.2016.04.05.15.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 15:05:56 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id n1so19069972pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 15:05:56 -0700 (PDT)
Date: Tue, 5 Apr 2016 15:05:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 30/31] huge tmpfs: shmem_huge_gfpmask and
 shmem_recovery_gfpmask
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051503590.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We know that compaction latencies can be a problem for transparent
hugepage allocation; and there has been a history of tweaking the
gfpmask used for anon THP allocation at fault time and by khugepaged.
Plus we keep on changing our minds as to whether local smallpages
are generally preferable to remote hugepages, or not.

Anon THP has at least /sys/kernel/mm/transparent_hugepage/defrag and
/sys/kernel/mm/transparent_hugepage/khugepaged/defrag to play with
__GFP_RECLAIM bits in its gfpmasks; but so far there's been nothing
at all in huge tmpfs to experiment with these issues, and doubts
looming on whether we've made the right choices.

Add /proc/sys/vm/{shmem_huge_gfpmask,shmem_recovery_gfpmask} to
override the defaults we've been using for its synchronous and
asynchronous hugepage allocations so far: make these tunable now,
but no thought yet given to what values worth experimenting with.
Only numeric validation of the input: root must just take care.

Three things make this a more awkward patch than you might expect:

1. We shall want to play with __GFP_THISNODE, but that got added
   down inside alloc_pages_vma(): change huge_memory.c to supply it
   for anon THP, then alloc_pages_vma() remove it when unsuitable.

2. It took some time to work out how a global gfpmask template should
   modulate a non-standard incoming gfpmask, different bits having
   different effects: shmem_huge_gfp() helper added for that.

3. __alloc_pages_slowpath() compared gfpmask with GFP_TRANSHUGE
   in a couple of places: which is appropriate for anonymous THP,
   but needed a little rework to extend it to huge tmpfs usage,
   when we're hoping to be able to tune behavior with these sysctls.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/tmpfs.txt |   19 ++++++++
 Documentation/sysctl/vm.txt         |   23 +++++++++-
 include/linux/shmem_fs.h            |    2 
 kernel/sysctl.c                     |   14 ++++++
 mm/huge_memory.c                    |    2 
 mm/mempolicy.c                      |   13 +++--
 mm/page_alloc.c                     |   34 ++++++++-------
 mm/shmem.c                          |   58 +++++++++++++++++++++++---
 8 files changed, 134 insertions(+), 31 deletions(-)

--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -192,11 +192,28 @@ In addition to 0 and 1, it also accepts
 automatically on for all tmpfs mounts (intended for testing), or -1
 to force huge off for all (intended for safety if bugs appeared).
 
+/proc/sys/vm/shmem_huge_gfpmask (intended for experimentation only):
+
+Default 38146762, that is 0x24612ca:
+GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY.
+Write a gfpmask built from __GFP flags in include/linux/gfp.h, to experiment
+with better alternatives for the synchronous huge tmpfs allocation used
+when faulting or writing.
+
 /proc/sys/vm/shmem_huge_recoveries:
 
 Default 8, allows up to 8 concurrent workitems, recovering hugepages
 after fragmentation prevented or reclaim disbanded; write 0 to disable
-huge recoveries, or a higher number to allow more concurrent recoveries.
+huge recoveries, or a higher number to allow more concurrent recoveries
+(or a negative number to disable both retry after shrinking, and recovery).
+
+/proc/sys/vm/shmem_recovery_gfpmask (intended for experimentation only):
+
+Default 38142666, that is 0x24602ca:
+GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE.
+Write a gfpmask built from __GFP flags in include/linux/gfp.h, to experiment
+with alternatives for the asynchronous huge tmpfs allocation used in recovery
+from fragmentation or swapping.
 
 /proc/<pid>/smaps shows:
 
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -57,7 +57,9 @@ Currently, these files are in /proc/sys/
 - panic_on_oom
 - percpu_pagelist_fraction
 - shmem_huge
+- shmem_huge_gfpmask
 - shmem_huge_recoveries
+- shmem_recovery_gfpmask
 - stat_interval
 - stat_refresh
 - swappiness
@@ -765,11 +767,30 @@ See Documentation/filesystems/tmpfs.txt
 
 ==============================================================
 
+shmem_huge_gfpmask
+
+Write a gfpmask built from __GFP flags in include/linux/gfp.h, to experiment
+with better alternatives for the synchronous huge tmpfs allocation used
+when faulting or writing.  See Documentation/filesystems/tmpfs.txt.
+/proc/sys/vm/shmem_huge_gfpmask is intended for experimentation only.
+
+==============================================================
+
 shmem_huge_recoveries
 
 Default 8, allows up to 8 concurrent workitems, recovering hugepages
 after fragmentation prevented or reclaim disbanded; write 0 to disable
-huge recoveries, or a higher number to allow more concurrent recoveries.
+huge recoveries, or a higher number to allow more concurrent recoveries
+(or a negative number to disable both retry after shrinking, and recovery).
+
+==============================================================
+
+shmem_recovery_gfpmask
+
+Write a gfpmask built from __GFP flags in include/linux/gfp.h, to experiment
+with alternatives for the asynchronous huge tmpfs allocation used in recovery
+from fragmentation or swapping.  See Documentation/filesystems/tmpfs.txt.
+/proc/sys/vm/shmem_recovery_gfpmask is intended for experimentation only.
 
 ==============================================================
 
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -89,7 +89,7 @@ extern bool shmem_recovery_migrate_page(
 # ifdef CONFIG_SYSCTL
 struct ctl_table;
 extern int shmem_huge, shmem_huge_min, shmem_huge_max;
-extern int shmem_huge_recoveries;
+extern int shmem_huge_recoveries, shmem_huge_gfpmask, shmem_recovery_gfpmask;
 extern int shmem_huge_sysctl(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos);
 # endif /* CONFIG_SYSCTL */
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1325,12 +1325,26 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &shmem_huge_max,
 	},
 	{
+		.procname	= "shmem_huge_gfpmask",
+		.data		= &shmem_huge_gfpmask,
+		.maxlen		= sizeof(shmem_huge_gfpmask),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
 		.procname	= "shmem_huge_recoveries",
 		.data		= &shmem_huge_recoveries,
 		.maxlen		= sizeof(shmem_huge_recoveries),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "shmem_recovery_gfpmask",
+		.data		= &shmem_recovery_gfpmask,
+		.maxlen		= sizeof(shmem_recovery_gfpmask),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 #ifdef CONFIG_HUGETLB_PAGE
 	{
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -883,7 +883,7 @@ static inline gfp_t alloc_hugepage_direc
 	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
 		reclaim_flags = __GFP_DIRECT_RECLAIM;
 
-	return GFP_TRANSHUGE | reclaim_flags;
+	return GFP_TRANSHUGE | __GFP_THISNODE | reclaim_flags;
 }
 
 /* Defrag for khugepaged will enter direct reclaim/compaction if necessary */
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2007,11 +2007,14 @@ retry_cpuset:
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
+		if (hugepage)
+			gfp &= ~__GFP_THISNODE;
 		page = alloc_page_interleave(gfp, order, nid);
 		goto out;
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage)) {
+	if (unlikely(IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) && hugepage &&
+	    (gfp & __GFP_THISNODE))) {
 		int hpage_node = node;
 
 		/*
@@ -2024,17 +2027,17 @@ retry_cpuset:
 		 * If the policy is interleave, or does not allow the current
 		 * node in its nodemask, we allocate the standard way.
 		 */
-		if (pol->mode == MPOL_PREFERRED &&
-						!(pol->flags & MPOL_F_LOCAL))
+		if (pol->mode == MPOL_PREFERRED && !(pol->flags & MPOL_F_LOCAL))
 			hpage_node = pol->v.preferred_node;
 
 		nmask = policy_nodemask(gfp, pol);
 		if (!nmask || node_isset(hpage_node, *nmask)) {
 			mpol_cond_put(pol);
-			page = __alloc_pages_node(hpage_node,
-						gfp | __GFP_THISNODE, order);
+			page = __alloc_pages_node(hpage_node, gfp, order);
 			goto out;
 		}
+
+		gfp &= ~__GFP_THISNODE;
 	}
 
 	nmask = policy_nodemask(gfp, pol);
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3105,9 +3105,15 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_ma
 	return !!(gfp_to_alloc_flags(gfp_mask) & ALLOC_NO_WATERMARKS);
 }
 
-static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
+static inline bool is_thp_allocation(gfp_t gfp_mask, unsigned int order)
 {
-	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
+	/*
+	 * !__GFP_KSWAPD_RECLAIM is an unusual choice, and no harm is done if a
+	 * similar high order allocation is occasionally misinterpreted as THP.
+	 */
+	return IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+		!(gfp_mask & __GFP_KSWAPD_RECLAIM) &&
+		(order == HPAGE_PMD_ORDER);
 }
 
 static inline struct page *
@@ -3225,7 +3231,7 @@ retry:
 		goto got_pg;
 
 	/* Checks for THP-specific high-order allocations */
-	if (is_thp_gfp_mask(gfp_mask)) {
+	if (is_thp_allocation(gfp_mask, order)) {
 		/*
 		 * If compaction is deferred for high-order allocations, it is
 		 * because sync compaction recently failed. If this is the case
@@ -3247,20 +3253,16 @@ retry:
 
 		/*
 		 * If compaction was aborted due to need_resched(), we do not
-		 * want to further increase allocation latency, unless it is
-		 * khugepaged trying to collapse.
-		 */
-		if (contended_compaction == COMPACT_CONTENDED_SCHED
-			&& !(current->flags & PF_KTHREAD))
+		 * want to further increase allocation latency at fault.
+		 * If continuing, still use asynchronous memory compaction
+		 * for THP, unless it is khugepaged trying to collapse,
+		 * or an asynchronous huge tmpfs recovery work item.
+		 */
+		if (current->flags & PF_KTHREAD)
+			migration_mode = MIGRATE_SYNC_LIGHT;
+		else if (contended_compaction == COMPACT_CONTENDED_SCHED)
 			goto nopage;
-	}
-
-	/*
-	 * It can become very expensive to allocate transparent hugepages at
-	 * fault, so use asynchronous memory compaction for THP unless it is
-	 * khugepaged trying to collapse.
-	 */
-	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
+	} else
 		migration_mode = MIGRATE_SYNC_LIGHT;
 
 	/* Try direct reclaim and then allocating */
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -323,6 +323,43 @@ static DEFINE_SPINLOCK(shmem_shrinklist_
 int shmem_huge __read_mostly;
 int shmem_huge_recoveries __read_mostly = 8;	/* concurrent recovery limit */
 
+int shmem_huge_gfpmask __read_mostly =
+	(int)(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE|__GFP_NORETRY);
+int shmem_recovery_gfpmask __read_mostly =
+	(int)(GFP_HIGHUSER_MOVABLE|__GFP_NOWARN|__GFP_THISNODE);
+
+/*
+ * Compose the requested_gfp for a small page together with the tunable
+ * template above, to construct a suitable gfpmask for a huge allocation.
+ */
+static gfp_t shmem_huge_gfp(int tunable_template, gfp_t requested_gfp)
+{
+	gfp_t huge_gfpmask = (gfp_t)tunable_template;
+	gfp_t relaxants;
+
+	/*
+	 * Relaxants must only be applied when they are permitted in both.
+	 * GFP_KERNEL happens to be the name for
+	 * __GFP_IO|__GFP_FS|__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM.
+	 */
+	relaxants = huge_gfpmask & requested_gfp & GFP_KERNEL;
+
+	/*
+	 * Zone bits must be taken exclusively from the requested gfp mask.
+	 * __GFP_COMP would be a disaster: make sure the sysctl cannot add it.
+	 */
+	huge_gfpmask &= __GFP_BITS_MASK & ~(GFP_ZONEMASK|__GFP_COMP|GFP_KERNEL);
+
+	/*
+	 * These might be right for a small page, but unsuitable for the huge.
+	 * REPEAT and NOFAIL very likely wrong in huge_gfpmask, but permitted.
+	 */
+	requested_gfp &= ~(__GFP_REPEAT|__GFP_NOFAIL|__GFP_COMP|GFP_KERNEL);
+
+	/* Beyond that, we can simply use the union, sensible or not */
+	return huge_gfpmask | requested_gfp | relaxants;
+}
+
 static struct page *shmem_hugeteam_lookup(struct address_space *mapping,
 					  pgoff_t index, bool speculative)
 {
@@ -1395,8 +1432,9 @@ static void shmem_recovery_work(struct w
 		 * often choose an unsuitable NUMA node: something to fix soon,
 		 * but not an immediate blocker.
 		 */
+		gfp = shmem_huge_gfp(shmem_recovery_gfpmask, gfp);
 		head = __alloc_pages_node(page_to_nid(page),
-			gfp | __GFP_NOWARN | __GFP_THISNODE, HPAGE_PMD_ORDER);
+					  gfp, HPAGE_PMD_ORDER);
 		if (!head) {
 			shr_stats(huge_failed);
 			error = -ENOMEM;
@@ -1732,9 +1770,15 @@ static struct shrinker shmem_hugehole_sh
 #else /* !CONFIG_TRANSPARENT_HUGEPAGE */
 
 #define shmem_huge SHMEM_HUGE_DENY
+#define shmem_huge_gfpmask GFP_HIGHUSER_MOVABLE
 #define shmem_huge_recoveries 0
 #define shr_stats(x) do {} while (0)
 
+static inline gfp_t shmem_huge_gfp(int tunable_template, gfp_t requested_gfp)
+{
+	return requested_gfp;
+}
+
 static inline struct page *shmem_hugeteam_lookup(struct address_space *mapping,
 					pgoff_t index, bool speculative)
 {
@@ -2626,14 +2670,16 @@ static struct page *shmem_alloc_page(gfp
 		rcu_read_unlock();
 
 		if (*hugehint == SHMEM_ALLOC_HUGE_PAGE) {
-			head = alloc_pages_vma(gfp|__GFP_NORETRY|__GFP_NOWARN,
-				HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(),
-				true);
+			gfp_t huge_gfp;
+
+			huge_gfp = shmem_huge_gfp(shmem_huge_gfpmask, gfp);
+			head = alloc_pages_vma(huge_gfp,
+					HPAGE_PMD_ORDER, &pvma, 0,
+					numa_node_id(), true);
 			/* Shrink and retry? Or leave it to recovery worker */
 			if (!head && !shmem_huge_recoveries &&
 			    shmem_shrink_hugehole(NULL, NULL) != SHRINK_STOP) {
-				head = alloc_pages_vma(
-					gfp|__GFP_NORETRY|__GFP_NOWARN,
+				head = alloc_pages_vma(huge_gfp,
 					HPAGE_PMD_ORDER, &pvma, 0,
 					numa_node_id(), true);
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
