Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3A46B0068
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 03:52:15 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id o10so13617263eaj.27
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 00:52:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id p9si37718358eew.13.2013.12.03.00.52.14
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 00:52:14 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 14/15] mm: numa: Flush TLB if NUMA hinting faults race with PTE scan update
Date: Tue,  3 Dec 2013 08:52:01 +0000
Message-Id: <1386060721-3794-15-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-1-git-send-email-mgorman@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

NUMA PTE updates and NUMA PTE hinting faults can race against each other. The
setting of the NUMA bit defers the TLB flush to reduce overhead. NUMA
hinting faults do not flush the TLB as X86 at least does not cache TLB
entries for !present PTEs. However, in the event that the two race a NUMA
hinting fault may return with the TLB in an inconsistent state between
different processors. This patch detects potential for races between the
NUMA PTE scanner and fault handler and will flush the TLB for the affected
range if there is a race.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/migrate.h | 17 +++++++++++++++++
 kernel/sched/fair.c     |  3 +++
 mm/huge_memory.c        |  5 +++++
 mm/memory.c             |  6 ++++++
 mm/migrate.c            | 33 +++++++++++++++++++++++++++++++++
 5 files changed, 64 insertions(+)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 804651c..28aa613 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -94,6 +94,11 @@ extern bool pmd_trans_migrating(pmd_t pmd);
 extern void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd);
 extern int migrate_misplaced_page(struct page *page, int node);
 extern bool migrate_ratelimited(int node);
+extern unsigned long numa_fault_prepare(struct mm_struct *mm);
+extern void numa_fault_commit(struct mm_struct *mm,
+				struct vm_area_struct *vma,
+				unsigned long start_addr, int nr_pages,
+				unsigned long seq);
 #else
 static inline bool pmd_trans_migrating(pmd_t pmd)
 {
@@ -110,6 +115,18 @@ static inline bool migrate_ratelimited(int node)
 {
 	return false;
 }
+static inline unsigned long numa_fault_prepare(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline void numa_fault_commit(struct mm_struct *mm,
+				struct vm_area_struct *vma,
+				unsigned long start_addr, int nr_pages,
+				unsigned long seq)
+{
+	return false;
+}
 #endif /* CONFIG_NUMA_BALANCING */
 
 #if defined(CONFIG_NUMA_BALANCING) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 40d8ea3..af1a710 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -959,6 +959,9 @@ void task_numa_work(struct callback_head *work)
 	if (!pages)
 		return;
 
+	/* Paired with numa_fault_prepare */
+	smp_wmb();
+
 	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, start);
 	if (!vma) {
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4c7abd7..84f9907 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1293,6 +1293,9 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int target_nid;
 	bool page_locked;
 	bool migrated = false;
+	unsigned long scan_seq;
+
+	scan_seq = numa_fault_prepare(mm);
 
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_same(pmd, *pmdp)))
@@ -1387,6 +1390,8 @@ out:
 	if (page_nid != -1)
 		task_numa_fault(page_nid, HPAGE_PMD_NR, migrated);
 
+	numa_fault_commit(mm, vma, haddr, HPAGE_PMD_NR, scan_seq);
+
 	return 0;
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index f453384..6db850f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3540,6 +3540,9 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int page_nid = -1;
 	int target_nid;
 	bool migrated = false;
+	unsigned long scan_seq;
+
+	scan_seq = numa_fault_prepare(mm);
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3583,6 +3586,9 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 out:
 	if (page_nid != -1)
 		task_numa_fault(page_nid, 1, migrated);
+
+	numa_fault_commit(mm, vma, addr, 1, scan_seq);
+
 	return 0;
 }
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 5dfd552..ccc814b 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1662,6 +1662,39 @@ void wait_migrate_huge_page(struct anon_vma *anon_vma, pmd_t *pmd)
 	smp_rmb();
 }
 
+unsigned long numa_fault_prepare(struct mm_struct *mm)
+{
+	/* Paired with task_numa_work */
+	smp_rmb();
+	return mm->numa_next_reset;
+}
+
+/* Returns true if there was a race with the NUMA pte scan update */
+void numa_fault_commit(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			unsigned long start_addr, int nr_pages,
+			unsigned long seq)
+{
+	unsigned current_seq;
+
+	/* Paired with task_numa_work */
+	smp_rmb();
+	current_seq = mm->numa_next_reset;
+
+	if (current_seq == seq)
+		return;
+
+	/*
+	 * Raced with NUMA pte scan update which may be deferring a flush.
+	 * Flush now to avoid CPUs having an inconsistent view
+	 */
+	if (nr_pages == 1)
+		flush_tlb_page(vma, start_addr);
+	else
+		flush_tlb_range(vma, start_addr,
+					start_addr + (nr_pages << PAGE_SHIFT));
+}
+
 /*
  * Attempt to migrate a misplaced page to the specified destination
  * node. Caller is expected to have an elevated reference count on
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
