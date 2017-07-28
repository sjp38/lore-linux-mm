Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8073D6B04F6
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 02:42:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id k72so129433222pfj.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 23:42:03 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l9si11925829pfb.551.2017.07.27.23.42.01
        for <linux-mm@kvack.org>;
        Thu, 27 Jul 2017 23:42:02 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/3] mm: make tlb_flush_pending global
Date: Fri, 28 Jul 2017 15:41:50 +0900
Message-Id: <1501224112-23656-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1501224112-23656-1-git-send-email-minchan@kernel.org>
References: <1501224112-23656-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team <kernel-team@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>

Currently, tlb_flush_pending is used only for CONFIG_[NUMA_BALANCING|
COMPACTION] but upcoming patches to solve subtle TLB flush bacting
problem will use it regardless of compaction/numa so this patch
doesn't remove the dependency.

Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_types.h | 15 ---------------
 kernel/fork.c            |  2 --
 mm/debug.c               |  2 --
 3 files changed, 19 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4b9a625c370c..6953d2c706fe 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -487,14 +487,12 @@ struct mm_struct {
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
 #endif
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 	/*
 	 * An operation with batched TLB flushing is going on. Anything that
 	 * can move process memory needs to flush the TLB when moving a
 	 * PROT_NONE or PROT_NUMA mapped page.
 	 */
 	atomic_t tlb_flush_pending;
-#endif
 #ifdef CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH
 	/* See flush_tlb_batched_pending() */
 	bool tlb_flush_batched;
@@ -522,7 +520,6 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
  * the page table locks, outside of which no page table modifications happen.
@@ -565,18 +562,6 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 	smp_mb__before_atomic();
 	atomic_dec(&mm->tlb_flush_pending);
 }
-#else
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
-{
-	return false;
-}
-static inline void set_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-static inline void clear_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-#endif
 
 struct vm_fault;
 
diff --git a/kernel/fork.c b/kernel/fork.c
index aaf4d70afd8b..7e9f42060976 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -807,9 +807,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 	atomic_set(&mm->tlb_flush_pending, 0);
-#endif
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
diff --git a/mm/debug.c b/mm/debug.c
index d70103bb4731..18a9b15b1e37 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -158,9 +158,7 @@ void dump_mm(const struct mm_struct *mm)
 #ifdef CONFIG_NUMA_BALANCING
 		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
 #endif
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 		atomic_read(&mm->tlb_flush_pending),
-#endif
 		mm->def_flags, &mm->def_flags
 	);
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
