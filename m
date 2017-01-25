Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D57F86B0277
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:28:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so279216757pfy.2
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:28:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 130si24154114pgb.319.2017.01.25.10.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 02/12] mm: introduce page_vma_mapped_walk()
Date: Wed, 25 Jan 2017 21:25:28 +0300
Message-Id: <20170125182538.86249-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch introduces new interface to check if a page is mapped into a vma.
It aims to address shortcomings of page_check_address{,_transhuge}.

Existing interface is not able to handle PTE-mapped THPs: it only finds
the first PTE. The rest lefted unnoticed.

page_vma_mapped_walk() iterates over all possible mapping of the page in the
vma.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  26 ++++++++
 mm/Makefile          |   6 +-
 mm/huge_memory.c     |   9 ++-
 mm/page_vma_mapped.c | 181 +++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 217 insertions(+), 5 deletions(-)
 create mode 100644 mm/page_vma_mapped.c

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 15321fb1df6b..b76343610653 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/rwsem.h>
 #include <linux/memcontrol.h>
+#include <linux/highmem.h>
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -232,6 +233,31 @@ static inline bool page_check_address_transhuge(struct page *page,
 }
 #endif
 
+/* Avoid racy checks */
+#define PVMW_SYNC		(1 << 0)
+/* Look for migarion entries rather than present PTEs */
+#define PVMW_MIGRATION		(1 << 1)
+
+struct page_vma_mapped_walk {
+	struct page *page;
+	struct vm_area_struct *vma;
+	unsigned long address;
+	pmd_t *pmd;
+	pte_t *pte;
+	spinlock_t *ptl;
+	unsigned int flags;
+};
+
+static inline void page_vma_mapped_walk_done(struct page_vma_mapped_walk *pvmw)
+{
+	if (pvmw->pte)
+		pte_unmap(pvmw->pte);
+	if (pvmw->ptl)
+		spin_unlock(pvmw->ptl);
+}
+
+bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw);
+
 /*
  * Used by swapoff to help locate where page is expected in vma.
  */
diff --git a/mm/Makefile b/mm/Makefile
index 295bd7a9f76b..e375745a88a5 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -23,8 +23,10 @@ KCOV_INSTRUMENT_vmstat.o := n
 
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
-			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   mlock.o mmap.o mprotect.o mremap.o msync.o \
+			   page_vma_mapped.o pagewalk.o pgtable-generic.o \
+			   rmap.o vmalloc.o
+
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9a6bd6c8d55a..16820e001d79 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1862,9 +1862,12 @@ static void freeze_page(struct page *page)
 static void unfreeze_page(struct page *page)
 {
 	int i;
-
-	for (i = 0; i < HPAGE_PMD_NR; i++)
-		remove_migration_ptes(page + i, page + i, true);
+	if (PageTransHuge(page)) {
+		remove_migration_ptes(page, page, true);
+	} else {
+		for (i = 0; i < HPAGE_PMD_NR; i++)
+			remove_migration_ptes(page + i, page + i, true);
+	}
 }
 
 static void __split_huge_page_tail(struct page *head, int tail,
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
new file mode 100644
index 000000000000..63168b4baf19
--- /dev/null
+++ b/mm/page_vma_mapped.c
@@ -0,0 +1,181 @@
+#include <linux/mm.h>
+#include <linux/rmap.h>
+#include <linux/hugetlb.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+
+#include "internal.h"
+
+static inline bool check_pmd(struct page_vma_mapped_walk *pvmw)
+{
+	pmd_t pmde;
+	/*
+	 * Make sure we don't re-load pmd between present and !trans_huge check.
+	 * We need a consistent view.
+	 */
+	pmde = READ_ONCE(*pvmw->pmd);
+	return pmd_present(pmde) && !pmd_trans_huge(pmde);
+}
+
+static inline bool not_found(struct page_vma_mapped_walk *pvmw)
+{
+	page_vma_mapped_walk_done(pvmw);
+	return false;
+}
+
+static bool map_pte(struct page_vma_mapped_walk *pvmw)
+{
+	pvmw->pte = pte_offset_map(pvmw->pmd, pvmw->address);
+	if (!(pvmw->flags & PVMW_SYNC)) {
+		if (pvmw->flags & PVMW_MIGRATION) {
+			if (!is_swap_pte(*pvmw->pte))
+				return false;
+		} else {
+			if (!pte_present(*pvmw->pte))
+				return false;
+		}
+	}
+	pvmw->ptl = pte_lockptr(pvmw->vma->vm_mm, pvmw->pmd);
+	spin_lock(pvmw->ptl);
+	return true;
+}
+
+static bool check_pte(struct page_vma_mapped_walk *pvmw)
+{
+	if (pvmw->flags & PVMW_MIGRATION) {
+#ifdef CONFIG_MIGRATION
+		swp_entry_t entry;
+		if (!is_swap_pte(*pvmw->pte))
+			return false;
+		entry = pte_to_swp_entry(*pvmw->pte);
+		if (!is_migration_entry(entry))
+			return false;
+		if (migration_entry_to_page(entry) - pvmw->page >=
+				hpage_nr_pages(pvmw->page)) {
+			return false;
+		}
+		if (migration_entry_to_page(entry) < pvmw->page)
+			return false;
+#else
+		WARN_ON_ONCE(1);
+#endif
+	} else {
+		if (!pte_present(*pvmw->pte))
+			return false;
+
+		/* THP can be referenced by any subpage */
+		if (pte_page(*pvmw->pte) - pvmw->page >=
+				hpage_nr_pages(pvmw->page)) {
+			return false;
+		}
+		if (pte_page(*pvmw->pte) < pvmw->page)
+			return false;
+	}
+
+	return true;
+}
+
+/**
+ * page_vma_mapped_walk - check if @pvmw->page is mapped in @pvmw->vma at
+ * @pvmw->address
+ * @pvmw: pointer to struct page_vma_mapped_walk. page, vma, address and flags
+ * must be set. pmd, pte and ptl must be NULL.
+ *
+ * Returns true if the page is mapped in the vma. @pvmw->pmd and @pvmw->pte point
+ * to relevant page table entries. @pvmw->ptl is locked. @pvmw->address is
+ * adjusted if needed (for PTE-mapped THPs).
+ *
+ * If @pvmw->pmd is set but @pvmw->pte is not, you have found PMD-mapped page
+ * (usually THP). For PTE-mapped THP, you should run page_vma_mapped_walk() in 
+ * a loop to find all PTEs that map the THP.
+ *
+ * For HugeTLB pages, @pvmw->pte is set to the relevant page table entry
+ * regardless of which page table level the page is mapped at. @pvmw->pmd is
+ * NULL.
+ *
+ * Retruns false if there are no more page table entries for the page in
+ * the vma. @pvmw->ptl is unlocked and @pvmw->pte is unmapped.
+ *
+ * If you need to stop the walk before page_vma_mapped_walk() returned false,
+ * use page_vma_mapped_walk_done(). It will do the housekeeping.
+ */
+bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
+{
+	struct mm_struct *mm = pvmw->vma->vm_mm;
+	struct page *page = pvmw->page;
+	pgd_t *pgd;
+	pud_t *pud;
+
+	/* For THP, seek to next pte entry */
+	if (pvmw->pte)
+		goto next_pte;
+
+	if (unlikely(PageHuge(pvmw->page))) {
+		/* when pud is not present, pte will be NULL */
+		pvmw->pte = huge_pte_offset(mm, pvmw->address);
+		if (!pvmw->pte)
+			return false;
+
+		pvmw->ptl = huge_pte_lockptr(page_hstate(page), mm, pvmw->pte);
+		spin_lock(pvmw->ptl);
+		if (!check_pte(pvmw))
+			return not_found(pvmw);
+		return true;
+	}
+restart:
+	pgd = pgd_offset(mm, pvmw->address);
+	if (!pgd_present(*pgd))
+		return false;
+	pud = pud_offset(pgd, pvmw->address);
+	if (!pud_present(*pud))
+		return false;
+	pvmw->pmd = pmd_offset(pud, pvmw->address);
+	if (pmd_trans_huge(*pvmw->pmd)) {
+		pvmw->ptl = pmd_lock(mm, pvmw->pmd);
+		if (!pmd_present(*pvmw->pmd))
+			return not_found(pvmw);
+		if (likely(pmd_trans_huge(*pvmw->pmd))) {
+			if (pvmw->flags & PVMW_MIGRATION)
+				return not_found(pvmw);
+			if (pmd_page(*pvmw->pmd) != page)
+				return not_found(pvmw);
+			return true;
+		} else {
+			/* THP pmd was split under us: handle on pte level */
+			spin_unlock(pvmw->ptl);
+			pvmw->ptl = NULL;
+		}
+	} else {
+		if (!check_pmd(pvmw))
+			return false;
+	}
+	if (!map_pte(pvmw))
+		goto next_pte;
+	while (1) {
+		if (check_pte(pvmw))
+			return true;
+next_pte:	do {
+			pvmw->address += PAGE_SIZE;
+			if (pvmw->address >=
+					__vma_address(pvmw->page, pvmw->vma) +
+					hpage_nr_pages(pvmw->page) * PAGE_SIZE)
+				return not_found(pvmw);
+			/* Did we cross page table boundary? */
+			if (pvmw->address % PMD_SIZE == 0) {
+				pte_unmap(pvmw->pte);
+				if (pvmw->ptl) {
+					spin_unlock(pvmw->ptl);
+					pvmw->ptl = NULL;
+				}
+				goto restart;
+			} else {
+				pvmw->pte++;
+			}
+		} while (pte_none(*pvmw->pte));
+
+		if (!pvmw->ptl) {
+			pvmw->ptl = pte_lockptr(mm, pvmw->pmd);
+			spin_lock(pvmw->ptl);
+		}
+	}
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
