Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF656B0556
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:19:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j83so38552619pfe.10
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:19:07 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id f11si11871153pln.472.2017.08.02.00.19.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:19:06 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 5/7] mm: make tlb_flush_pending global
Date: Tue, 1 Aug 2017 17:08:16 -0700
Message-ID: <20170802000818.4760-6-namit@vmware.com>
In-Reply-To: <20170802000818.4760-1-namit@vmware.com>
References: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Minchan Kim <minchan@kernel.org>, Nadav Amit <namit@vmware.com>

From: Minchan Kim <minchan@kernel.org>

Currently, tlb_flush_pending is used only for CONFIG_[NUMA_BALANCING|
COMPACTION] but upcoming patches to solve subtle TLB flush batching
problem will use it regardless of compaction/NUMA so this patch
doesn't remove the dependency.

Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mm_types.h | 21 ---------------------
 mm/debug.c               |  2 --
 2 files changed, 23 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 248f4ed1f3e1..fc44315df47a 100644
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
 	struct uprobes_state uprobes_state;
 #ifdef CONFIG_HUGETLB_PAGE
 	atomic_long_t hugetlb_usage;
@@ -524,7 +522,6 @@ extern void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 extern void tlb_finish_mmu(struct mmu_gather *tlb,
 				unsigned long start, unsigned long end);
 
-#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
  * the page table locks, outside of which no page table modifications happen.
@@ -565,24 +562,6 @@ static inline void dec_tlb_flush_pending(struct mm_struct *mm)
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
