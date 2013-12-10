Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 978656B005A
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:51:45 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so2328889ead.22
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 07:51:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id u49si14903127eep.43.2013.12.10.07.51.44
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 07:51:44 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 11/18] mm: fix TLB flush race between migration, and change_protection_range
Date: Tue, 10 Dec 2013 15:51:29 +0000
Message-Id: <1386690695-27380-12-git-send-email-mgorman@suse.de>
In-Reply-To: <1386690695-27380-1-git-send-email-mgorman@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Rik van Riel <riel@redhat.com>

There are a few subtle races, between change_protection_range (used by
mprotect and change_prot_numa) on one side, and NUMA page migration and
compaction on the other side.

The basic race is that there is a time window between when the PTE gets
made non-present (PROT_NONE or NUMA), and the TLB is flushed.

During that time, a CPU may continue writing to the page.

This is fine most of the time, however compaction or the NUMA migration
code may come in, and migrate the page away.

When that happens, the CPU may continue writing, through the cached
translation, to what is no longer the current memory location of the process.

This only affects x86, which has a somewhat optimistic pte_accessible. All
other architectures appear to be safe, and will either always flush,
or flush whenever there is a valid mapping, even with no permissions (SPARC).

The basic race looks like this:

CPU A			CPU B			CPU C

						load TLB entry
make entry PTE/PMD_NUMA
			fault on entry
						read/write old page
			start migrating page
			change PTE/PMD to new page
						read/write old page [*]
flush TLB
						reload TLB from new entry
						read/write new page
						lose data

[*] the old page may belong to a new user at this point!

The obvious fix is to flush remote TLB entries, by making sure that
pte_accessible aware of the fact that PROT_NONE and PROT_NUMA memory may
still be accessible if there is a TLB flush pending for the mm.

This should fix both NUMA migration and compaction.

Cc: stable@vger.kernel.org
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/sparc/include/asm/pgtable_64.h |  4 ++--
 arch/x86/include/asm/pgtable.h      | 11 ++++++++--
 include/asm-generic/pgtable.h       |  2 +-
 include/linux/mm_types.h            | 44 +++++++++++++++++++++++++++++++++++++
 kernel/fork.c                       |  1 +
 mm/huge_memory.c                    |  7 ++++++
 mm/mprotect.c                       |  2 ++
 mm/pgtable-generic.c                |  5 +++--
 8 files changed, 69 insertions(+), 7 deletions(-)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 8358dc1..0f9e945 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -619,7 +619,7 @@ static inline unsigned long pte_present(pte_t pte)
 }
 
 #define pte_accessible pte_accessible
-static inline unsigned long pte_accessible(pte_t a)
+static inline unsigned long pte_accessible(struct mm_struct *mm, pte_t a)
 {
 	return pte_val(a) & _PAGE_VALID;
 }
@@ -847,7 +847,7 @@ static inline void __set_pte_at(struct mm_struct *mm, unsigned long addr,
 	 * SUN4V NOTE: _PAGE_VALID is the same value in both the SUN4U
 	 *             and SUN4V pte layout, so this inline test is fine.
 	 */
-	if (likely(mm != &init_mm) && pte_accessible(orig))
+	if (likely(mm != &init_mm) && pte_accessible(mm, orig))
 		tlb_batch_add(mm, addr, ptep, orig, fullmm);
 }
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 3d19994..48cab4c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -452,9 +452,16 @@ static inline int pte_present(pte_t a)
 }
 
 #define pte_accessible pte_accessible
-static inline int pte_accessible(pte_t a)
+static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 {
-	return pte_flags(a) & _PAGE_PRESENT;
+	if (pte_flags(a) & _PAGE_PRESENT)
+		return true;
+
+	if ((pte_flags(a) & (_PAGE_PROTNONE | _PAGE_NUMA)) &&
+			tlb_flush_pending(mm))
+		return true;
+
+	return false;
 }
 
 static inline int pte_hidden(pte_t pte)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f330d28..b12079a 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -217,7 +217,7 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
 #endif
 
 #ifndef pte_accessible
-# define pte_accessible(pte)		((void)(pte),1)
+# define pte_accessible(mm, pte)	((void)(pte), 1)
 #endif
 
 #ifndef flush_tlb_fix_spurious_fault
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bd29941..c122bb1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -443,6 +443,14 @@ struct mm_struct {
 	/* numa_scan_seq prevents two threads setting pte_numa */
 	int numa_scan_seq;
 #endif
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+	/*
+	 * An operation with batched TLB flushing is going on. Anything that
+	 * can move process memory needs to flush the TLB when moving a
+	 * PROT_NONE or PROT_NUMA mapped page.
+	 */
+	bool tlb_flush_pending;
+#endif
 	struct uprobes_state uprobes_state;
 };
 
@@ -459,4 +467,40 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 	return mm->cpu_vm_mask_var;
 }
 
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+/*
+ * Memory barriers to keep this state in sync are graciously provided by
+ * the page table locks, outside of which no page table modifications happen.
+ * The barriers below prevent the compiler from re-ordering the instructions
+ * around the memory barriers that are already present in the code.
+ */
+static inline bool tlb_flush_pending(struct mm_struct *mm)
+{
+	barrier();
+	return mm->tlb_flush_pending;
+}
+static inline void set_tlb_flush_pending(struct mm_struct *mm)
+{
+	mm->tlb_flush_pending = true;
+	barrier();
+}
+/* Clearing is done after a TLB flush, which also provides a barrier. */
+static inline void clear_tlb_flush_pending(struct mm_struct *mm)
+{
+	barrier();
+	mm->tlb_flush_pending = false;
+}
+#else
+static inline bool tlb_flush_pending(struct mm_struct *mm)
+{
+	return false;
+}
+static inline void set_tlb_flush_pending(struct mm_struct *mm)
+{
+}
+static inline void clear_tlb_flush_pending(struct mm_struct *mm)
+{
+}
+#endif
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/kernel/fork.c b/kernel/fork.c
index 728d5be..5721f0e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -537,6 +537,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	spin_lock_init(&mm->page_table_lock);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
+	clear_tlb_flush_pending(mm);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e3b6a75..e3a5ee2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1377,6 +1377,13 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	/*
+	 * The page_table_lock above provides a memory barrier
+	 * with change_protection_range.
+	 */
+	if (tlb_flush_pending(mm))
+		flush_tlb_range(vma, haddr, haddr + HPAGE_PMD_SIZE);
+
+	/*
 	 * Migrate the THP to the requested node, returns with page unlocked
 	 * and pmd_numa cleared.
 	 */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index eb2f349..9b1be30 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -187,6 +187,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 	BUG_ON(addr >= end);
 	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
+	set_tlb_flush_pending(mm);
 	do {
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
@@ -198,6 +199,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
 	/* Only flush the TLB if we actually modified any entries: */
 	if (pages)
 		flush_tlb_range(vma, start, end);
+	clear_tlb_flush_pending(mm);
 
 	return pages;
 }
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index e84cad2..a8b9199 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -110,9 +110,10 @@ int pmdp_clear_flush_young(struct vm_area_struct *vma,
 pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long address,
 		       pte_t *ptep)
 {
+	struct mm_struct *mm = (vma)->vm_mm;
 	pte_t pte;
-	pte = ptep_get_and_clear((vma)->vm_mm, address, ptep);
-	if (pte_accessible(pte))
+	pte = ptep_get_and_clear(mm, address, ptep);
+	if (pte_accessible(mm, pte))
 		flush_tlb_page(vma, address);
 	return pte;
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
