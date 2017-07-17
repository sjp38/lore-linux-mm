Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDBA6B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 21:12:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y62so6726481pfa.3
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 18:12:20 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id x32si571773pld.52.2017.07.17.18.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jul 2017 18:12:19 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH] mm: Prevent racy access to tlb_flush_pending
Date: Mon, 17 Jul 2017 11:02:46 -0700
Message-ID: <20170717180246.62277-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>

Setting and clearing mm->tlb_flush_pending can be performed by multiple
threads, since mmap_sem may only be acquired for read in task_numa_work.
If this happens, tlb_flush_pending may be cleared while one of the
threads still changes PTEs and batches TLB flushes.

As a result, TLB flushes can be skipped because the indication of
pending TLB flushes is lost, for instance due to race between
migration and change_protection_range (just as in the scenario that
caused the introduction of tlb_flush_pending).

The feasibility of such a scenario was confirmed by adding assertion to
check tlb_flush_pending is not set by two threads, adding artificial
latency in change_protection_range() and using sysctl to reduce
kernel.numa_balancing_scan_delay_ms.

Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
change_protection_range")

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 include/linux/mm_types.h | 8 ++++----
 kernel/fork.c            | 2 +-
 mm/debug.c               | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..36f4ec589544 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -493,7 +493,7 @@ struct mm_struct {
 	 * can move process memory needs to flush the TLB when moving a
 	 * PROT_NONE or PROT_NUMA mapped page.
 	 */
-	bool tlb_flush_pending;
+	atomic_t tlb_flush_pending;
 #endif
 	struct uprobes_state uprobes_state;
 #ifdef CONFIG_HUGETLB_PAGE
@@ -528,11 +528,11 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
 {
 	barrier();
-	return mm->tlb_flush_pending;
+	return atomic_read(&mm->tlb_flush_pending) > 0;
 }
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
 {
-	mm->tlb_flush_pending = true;
+	atomic_inc(&mm->tlb_flush_pending);
 
 	/*
 	 * Guarantee that the tlb_flush_pending store does not leak into the
@@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct mm_struct *mm)
 static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 {
 	barrier();
-	mm->tlb_flush_pending = false;
+	atomic_dec(&mm->tlb_flush_pending);
 }
 #else
 static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
diff --git a/kernel/fork.c b/kernel/fork.c
index e53770d2bf95..5a7ecfbb7420 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -809,7 +809,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
 	mmu_notifier_mm_init(mm);
-	clear_tlb_flush_pending(mm);
+	atomic_set(&mm->tlb_flush_pending, 0);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
diff --git a/mm/debug.c b/mm/debug.c
index db1cd26d8752..d70103bb4731 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -159,7 +159,7 @@ void dump_mm(const struct mm_struct *mm)
 		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
 #endif
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
-		mm->tlb_flush_pending,
+		atomic_read(&mm->tlb_flush_pending),
 #endif
 		mm->def_flags, &mm->def_flags
 	);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
