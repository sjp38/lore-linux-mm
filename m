Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id D1AAD6B00AC
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:35 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 22/49] mm: mempolicy: Add MPOL_MF_LAZY
Date: Fri,  7 Dec 2012 10:23:25 +0000
Message-Id: <1354875832-9700-23-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Lee Schermerhorn <lee.schermerhorn@hp.com>

NOTE: Once again there is a lot of patch stealing and the end result
	is sufficiently different that I had to drop the signed-offs.
	Will re-add if the original authors are ok with that.

This patch adds another mbind() flag to request "lazy migration".  The
flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
pages are marked PROT_NONE. The pages will be migrated in the fault
path on "first touch", if the policy dictates at that time.

"Lazy Migration" will allow testing of migrate-on-fault via mbind().
Also allows applications to specify that only subsequently touched
pages be migrated to obey new policy, instead of all pages in range.
This can be useful for multi-threaded applications working on a
large shared data area that is initialized by an initial thread
resulting in all pages on one [or a few, if overflowed] nodes.
After PROT_NONE, the pages in regions assigned to the worker threads
will be automatically migrated local to the threads on 1st touch.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mm.h             |    5 ++
 include/uapi/linux/mempolicy.h |   13 ++-
 mm/mempolicy.c                 |  185 ++++++++++++++++++++++++++++++++++++----
 3 files changed, 185 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fa16152..471185e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1551,6 +1551,11 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
+#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
+void change_prot_numa(struct vm_area_struct *vma,
+			unsigned long start, unsigned long end);
+#endif
+
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 472de8a..6a1baae 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -49,9 +49,16 @@ enum mpol_rebind_step {
 
 /* Flags for mbind */
 #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
-#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform to mapping */
-#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to mapping */
-#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
+#define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
+				   to policy */
+#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
+#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
+#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
+
+#define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
+			 MPOL_MF_MOVE     | 	\
+			 MPOL_MF_MOVE_ALL |	\
+			 MPOL_MF_LAZY)
 
 /*
  * Internal flags that share the struct mempolicy flags word with
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index df1466d..51d3ebd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -90,6 +90,7 @@
 #include <linux/syscalls.h>
 #include <linux/ctype.h>
 #include <linux/mm_inline.h>
+#include <linux/mmu_notifier.h>
 
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
@@ -565,6 +566,145 @@ static inline int check_pgd_range(struct vm_area_struct *vma,
 	return 0;
 }
 
+#ifdef CONFIG_ARCH_USES_NUMA_PROT_NONE
+/*
+ * Here we search for not shared page mappings (mapcount == 1) and we
+ * set up the pmd/pte_numa on those mappings so the very next access
+ * will fire a NUMA hinting page fault.
+ */
+static int
+change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte, *_pte;
+	struct page *page;
+	unsigned long _address, end;
+	spinlock_t *ptl;
+	int ret = 0;
+
+	VM_BUG_ON(address & ~PAGE_MASK);
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none(*pmd))
+		goto out;
+
+	if (pmd_trans_huge_lock(pmd, vma) == 1) {
+		int page_nid;
+		ret = HPAGE_PMD_NR;
+
+		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
+
+		if (pmd_numa(*pmd)) {
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+
+		page = pmd_page(*pmd);
+
+		/* only check non-shared pages */
+		if (page_mapcount(page) != 1) {
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+
+		page_nid = page_to_nid(page);
+
+		if (pmd_numa(*pmd)) {
+			spin_unlock(&mm->page_table_lock);
+			goto out;
+		}
+
+		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
+		ret += HPAGE_PMD_NR;
+		/* defer TLB flush to lower the overhead */
+		spin_unlock(&mm->page_table_lock);
+		goto out;
+	}
+
+	if (pmd_trans_unstable(pmd))
+		goto out;
+	VM_BUG_ON(!pmd_present(*pmd));
+
+	end = min(vma->vm_end, (address + PMD_SIZE) & PMD_MASK);
+	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	for (_address = address, _pte = pte; _address < end;
+	     _pte++, _address += PAGE_SIZE) {
+		pte_t pteval = *_pte;
+		if (!pte_present(pteval))
+			continue;
+		if (pte_numa(pteval))
+			continue;
+		page = vm_normal_page(vma, _address, pteval);
+		if (unlikely(!page))
+			continue;
+		/* only check non-shared pages */
+		if (page_mapcount(page) != 1)
+			continue;
+
+		set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
+
+		/* defer TLB flush to lower the overhead */
+		ret++;
+	}
+	pte_unmap_unlock(pte, ptl);
+
+	if (ret && !pmd_numa(*pmd)) {
+		spin_lock(&mm->page_table_lock);
+		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
+		spin_unlock(&mm->page_table_lock);
+		/* defer TLB flush to lower the overhead */
+	}
+
+out:
+	return ret;
+}
+
+/* Assumes mmap_sem is held */
+void
+change_prot_numa(struct vm_area_struct *vma,
+			unsigned long address, unsigned long end)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int progress = 0;
+
+	while (address < end) {
+		VM_BUG_ON(address < vma->vm_start ||
+			  address + PAGE_SIZE > vma->vm_end);
+
+		progress += change_prot_numa_range(mm, vma, address);
+		address = (address + PMD_SIZE) & PMD_MASK;
+	}
+
+	/*
+	 * Flush the TLB for the mm to start the NUMA hinting
+	 * page faults after we finish scanning this vma part
+	 * if there were any PTE updates
+	 */
+	if (progress) {
+		mmu_notifier_invalidate_range_start(vma->vm_mm, address, end);
+		flush_tlb_range(vma, address, end);
+		mmu_notifier_invalidate_range_end(vma->vm_mm, address, end);
+	}
+}
+#else
+static unsigned long change_prot_numa(struct vm_area_struct *vma,
+			unsigned long addr, unsigned long end)
+{
+	return 0;
+}
+#endif /* CONFIG_ARCH_USES_NUMA_PROT_NONE */
+
 /*
  * Check if all pages in a range are on a set of nodes.
  * If pagelist != NULL then isolate pages from the LRU and
@@ -583,22 +723,32 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		return ERR_PTR(-EFAULT);
 	prev = NULL;
 	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+		unsigned long endvma = vma->vm_end;
+
+		if (endvma > end)
+			endvma = end;
+		if (vma->vm_start > start)
+			start = vma->vm_start;
+
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
 			if (!vma->vm_next && vma->vm_end < end)
 				return ERR_PTR(-EFAULT);
 			if (prev && prev->vm_end < vma->vm_start)
 				return ERR_PTR(-EFAULT);
 		}
-		if (!is_vm_hugetlb_page(vma) &&
-		    ((flags & MPOL_MF_STRICT) ||
+
+		if (is_vm_hugetlb_page(vma))
+			goto next;
+
+		if (flags & MPOL_MF_LAZY) {
+			change_prot_numa(vma, start, endvma);
+			goto next;
+		}
+
+		if ((flags & MPOL_MF_STRICT) ||
 		     ((flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) &&
-				vma_migratable(vma)))) {
-			unsigned long endvma = vma->vm_end;
+		      vma_migratable(vma))) {
 
-			if (endvma > end)
-				endvma = end;
-			if (vma->vm_start > start)
-				start = vma->vm_start;
 			err = check_pgd_range(vma, start, endvma, nodes,
 						flags, private);
 			if (err) {
@@ -606,6 +756,7 @@ check_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 				break;
 			}
 		}
+next:
 		prev = vma;
 	}
 	return first;
@@ -1138,8 +1289,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 	int err;
 	LIST_HEAD(pagelist);
 
-	if (flags & ~(unsigned long)(MPOL_MF_STRICT |
-				     MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+	if (flags & ~(unsigned long)MPOL_MF_VALID)
 		return -EINVAL;
 	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
 		return -EPERM;
@@ -1162,6 +1312,9 @@ static long do_mbind(unsigned long start, unsigned long len,
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
+	if (flags & MPOL_MF_LAZY)
+		new->flags |= MPOL_F_MOF;
+
 	/*
 	 * If we are using the default policy then operation
 	 * on discontinuous address spaces is okay after all
@@ -1198,13 +1351,15 @@ static long do_mbind(unsigned long start, unsigned long len,
 	vma = check_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
 
-	err = PTR_ERR(vma);
-	if (!IS_ERR(vma)) {
-		int nr_failed = 0;
-
+	err = PTR_ERR(vma);	/* maybe ... */
+	if (!IS_ERR(vma) && mode != MPOL_NOOP)
 		err = mbind_range(mm, start, end, new);
 
+	if (!err) {
+		int nr_failed = 0;
+
 		if (!list_empty(&pagelist)) {
+			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
 			nr_failed = migrate_pages(&pagelist, new_vma_page,
 						(unsigned long)vma,
 						false, MIGRATE_SYNC,
@@ -1213,7 +1368,7 @@ static long do_mbind(unsigned long start, unsigned long len,
 				putback_lru_pages(&pagelist);
 		}
 
-		if (!err && nr_failed && (flags & MPOL_MF_STRICT))
+		if (nr_failed && (flags & MPOL_MF_STRICT))
 			err = -EIO;
 	} else
 		putback_lru_pages(&pagelist);
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
