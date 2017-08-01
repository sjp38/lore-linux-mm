Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 088F36B04EE
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:56:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so7304395pfj.2
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:56:22 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u6si18607559pld.582.2017.07.31.22.56.20
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 22:56:20 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/4] mm: make tlb_flush_pending global
Date: Tue,  1 Aug 2017 14:56:15 +0900
Message-Id: <1501566977-20293-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1501566977-20293-1-git-send-email-minchan@kernel.org>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Mel Gorman <mgorman@techsingularity.net>

Currently, tlb_flush_pending is used only for CONFIG_[NUMA_BALANCING|
COMPACTION] but upcoming patches to solve subtle TLB flush bacting
problem will use it regardless of compaction/numa so this patch
doesn't remove the dependency.

Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm_types.h | 21 ---------------------
 mm/debug.c               |  2 --
 2 files changed, 23 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c605f2a3a68e..892a7b0196fd 100644
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
@@ -528,7 +526,6 @@ extern void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 extern void tlb_finish_mmu(struct mmu_gather *tlb,
 				unsigned long start, unsigned long end);
 
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
  * the page table locks, outside of which no page table modifications happen.
@@ -569,24 +566,6 @@ static inline void dec_tlb_flush_pending(struct mm_struct *mm)
 	smp_mb__before_atomic();
 	atomic_dec(&mm->tlb_flush_pending);
 }
-#else
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
-{
-	return false;
-}
-
-static inline void init_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-
-static inline void inc_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-
-static inline void dec_tlb_flush_pending(struct mm_struct *mm)
-{
-}
-#endif
 
 struct vm_fault;
 
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
