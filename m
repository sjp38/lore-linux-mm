Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0AA6B0005
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 05:12:18 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id 20so12647002wmh.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 02:12:17 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id jo7si35949488wjc.179.2016.04.05.02.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 02:12:16 -0700 (PDT)
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 5 Apr 2016 10:12:16 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6468117D8068
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 10:12:53 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u359CCCS4522378
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 09:12:12 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u359CBFP016664
	for <linux-mm@kvack.org>; Tue, 5 Apr 2016 03:12:12 -0600
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [PATCH v2] numa: fix /proc/<pid>/numa_maps for THP
Date: Tue,  5 Apr 2016 11:11:57 +0200
Message-Id: <1459847517-96892-1-git-send-email-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Dan Williams <dan.j.williams@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

In gather_pte_stats() a THP pmd is cast into a pte, which is wrong because the
layouts may differ depending on the architecture. On s390 this will lead to
inaccurate numap_maps accounting in /proc because of misguided pte_present()
and pte_dirty() checks on the fake pte.

On other architectures pte_present() and pte_dirty() may work by chance, but
there may be an issue with direct-access (dax) mappings w/o underlying struct
pages when HAVE_PTE_SPECIAL is set and THP is available. In vm_normal_page()
the fake pte will be checked with pte_special() and because there is no
"special" bit in a pmd, this will always return false and the VM_PFNMAP |
VM_MIXEDMAP checking will be skipped. On dax mappings w/o struct pages, an
invalid struct page pointer would then be returned that can crash the kernel.

This patch fixes the numa_maps THP handling by introducing new "_pmd" variants
of the can_gather_numa_stats() and vm_normal_page() functions.

Cc: <stable@vger.kernel.org> # v4.3+
Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
Changes in v2:
  - Fixed compile error on some archs when CONFIG_TRANSPARENT_HUGEPAGE
    is not defined.

 fs/proc/task_mmu.c | 33 ++++++++++++++++++++++++++++++---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 40 ++++++++++++++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+), 3 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 9df4316..f2ded210 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1518,6 +1518,32 @@ static struct page *can_gather_numa_stats(pte_t pte, struct vm_area_struct *vma,
 	return page;
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static struct page *can_gather_numa_stats_pmd(pmd_t pmd,
+					      struct vm_area_struct *vma,
+					      unsigned long addr)
+{
+	struct page *page;
+	int nid;
+
+	if (!pmd_present(pmd))
+		return NULL;
+
+	page = vm_normal_page_pmd(vma, addr, pmd);
+	if (!page)
+		return NULL;
+
+	if (PageReserved(page))
+		return NULL;
+
+	nid = page_to_nid(page);
+	if (!node_isset(nid, node_states[N_MEMORY]))
+		return NULL;
+
+	return page;
+}
+#endif
+
 static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 		unsigned long end, struct mm_walk *walk)
 {
@@ -1527,14 +1553,14 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 	pte_t *orig_pte;
 	pte_t *pte;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (ptl) {
-		pte_t huge_pte = *(pte_t *)pmd;
 		struct page *page;
 
-		page = can_gather_numa_stats(huge_pte, vma, addr);
+		page = can_gather_numa_stats_pmd(*pmd, vma, addr);
 		if (page)
-			gather_stats(page, md, pte_dirty(huge_pte),
+			gather_stats(page, md, pmd_dirty(*pmd),
 				     HPAGE_PMD_SIZE/PAGE_SIZE);
 		spin_unlock(ptl);
 		return 0;
@@ -1542,6 +1568,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 
 	if (pmd_trans_unstable(pmd))
 		return 0;
+#endif
 	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
 	do {
 		struct page *page = can_gather_numa_stats(*pte, vma, addr);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6bff79a..c5b8efc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1121,6 +1121,8 @@ struct zap_details {
 
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		pte_t pte);
+struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
+				pmd_t pmd);
 
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
diff --git a/mm/memory.c b/mm/memory.c
index 288a508..b73b833 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -789,6 +789,46 @@ out:
 	return pfn_to_page(pfn);
 }
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *vm_normal_page_pmd(struct vm_area_struct *vma, unsigned long addr,
+				pmd_t pmd)
+{
+	unsigned long pfn = pmd_pfn(pmd);
+
+	/*
+	 * There is no pmd_special() but there may be special pmds, e.g.
+	 * in a direct-access (dax) mapping, so let's just replicate the
+	 * !HAVE_PTE_SPECIAL case from vm_normal_page() here.
+	 */
+	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
+		if (vma->vm_flags & VM_MIXEDMAP) {
+			if (!pfn_valid(pfn))
+				return NULL;
+			goto out;
+		} else {
+			unsigned long off;
+			off = (addr - vma->vm_start) >> PAGE_SHIFT;
+			if (pfn == vma->vm_pgoff + off)
+				return NULL;
+			if (!is_cow_mapping(vma->vm_flags))
+				return NULL;
+		}
+	}
+
+	if (is_zero_pfn(pfn))
+		return NULL;
+	if (unlikely(pfn > highest_memmap_pfn))
+		return NULL;
+
+	/*
+	 * NOTE! We still have PageReserved() pages in the page tables.
+	 * eg. VDSO mappings can cause them to exist.
+	 */
+out:
+	return pfn_to_page(pfn);
+}
+#endif
+
 /*
  * copy one vm_area from one task to the other. Assumes the page tables
  * already present in the new task to be cleared in the whole range
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
