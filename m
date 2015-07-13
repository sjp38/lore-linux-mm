Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 447786B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:28:24 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so39397475wib.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:23 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id k4si4434713wif.101.2015.07.13.13.28.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 13:28:22 -0700 (PDT)
Received: by wgmn9 with SMTP id n9so51998163wgm.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:21 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v3 1/3] mm: add tracepoint for scanning pages
Date: Mon, 13 Jul 2015 23:28:02 +0300
Message-Id: <1436819284-3964-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Using static tracepoints, data of functions is recorded.
It is good to automatize debugging without doing a lot
of changes in the source code.

This patch adds tracepoint for khugepaged_scan_pmd,
collapse_huge_page and __collapse_huge_page_isolate.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
Changes in v2:
 - Nothing changed

Changes in v3:
 - Print page address instead of vm_start (Vlastimil Babka)
 - Define constants to specify exact tracepoint result (Vlastimil Babka)
 

 include/linux/mm.h                 |  18 ++++++
 include/trace/events/huge_memory.h | 100 ++++++++++++++++++++++++++++++++
 mm/huge_memory.c                   | 114 +++++++++++++++++++++++++++----------
 3 files changed, 203 insertions(+), 29 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7f47178..bf341c0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -21,6 +21,24 @@
 #include <linux/resource.h>
 #include <linux/page_ext.h>
 
+#define MM_PMD_NULL		0
+#define MM_EXCEED_NONE_PTE	3
+#define MM_PTE_NON_PRESENT	4
+#define MM_PAGE_NULL		5
+#define MM_SCAN_ABORT		6
+#define MM_PAGE_COUNT		7
+#define MM_PAGE_LRU		8
+#define MM_ANY_PROCESS		0
+#define MM_VMA_NULL		2
+#define MM_VMA_CHECK		3
+#define MM_ADDRESS_RANGE	4
+#define MM_PAGE_LOCK		2
+#define MM_SWAP_CACHE_PAGE	6
+#define MM_ISOLATE_LRU_PAGE	7
+#define MM_ALLOC_HUGE_PAGE_FAIL	6
+#define MM_CGROUP_CHARGE_FAIL	7
+#define MM_COLLAPSE_ISOLATE_FAIL 5
+
 struct mempolicy;
 struct anon_vma;
 struct anon_vma_chain;
diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
new file mode 100644
index 0000000..cbc56fc
--- /dev/null
+++ b/include/trace/events/huge_memory.h
@@ -0,0 +1,100 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM huge_memory
+
+#if !defined(__HUGE_MEMORY_H) || defined(TRACE_HEADER_MULTI_READ)
+#define __HUGE_MEMORY_H
+
+#include  <linux/tracepoint.h>
+
+TRACE_EVENT(mm_khugepaged_scan_pmd,
+
+	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
+		 bool referenced, int none_or_zero, int ret),
+
+	TP_ARGS(mm, page, writable, referenced, none_or_zero, ret),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(struct page *, page)
+		__field(bool, writable)
+		__field(bool, referenced)
+		__field(int, none_or_zero)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->page = page;
+		__entry->writable = writable;
+		__entry->referenced = referenced;
+		__entry->none_or_zero = none_or_zero;
+		__entry->ret = ret;
+	),
+
+	TP_printk("mm=%p, page=%p, writable=%d, referenced=%d, none_or_zero=%d, ret=%d",
+		__entry->mm,
+		__entry->page,
+		__entry->writable,
+		__entry->referenced,
+		__entry->none_or_zero,
+		__entry->ret)
+);
+
+TRACE_EVENT(mm_collapse_huge_page,
+
+	TP_PROTO(struct mm_struct *mm, int isolated, int ret),
+
+	TP_ARGS(mm, isolated, ret),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(int, isolated)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->isolated = isolated;
+		__entry->ret = ret;
+	),
+
+	TP_printk("mm=%p, isolated=%d, ret=%d",
+		__entry->mm,
+		__entry->isolated,
+		__entry->ret)
+);
+
+TRACE_EVENT(mm_collapse_huge_page_isolate,
+
+	TP_PROTO(struct page *page, int none_or_zero,
+		 bool referenced, bool  writable, int ret),
+
+	TP_ARGS(page, none_or_zero, referenced, writable, ret),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(int, none_or_zero)
+		__field(bool, referenced)
+		__field(bool, writable)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->none_or_zero = none_or_zero;
+		__entry->referenced = referenced;
+		__entry->writable = writable;
+		__entry->ret = ret;
+	),
+
+	TP_printk("page=%p, none_or_zero=%d, referenced=%d, writable=%d, ret=%d",
+		__entry->page,
+		__entry->none_or_zero,
+		__entry->referenced,
+		__entry->writable,
+		__entry->ret)
+);
+
+#endif /* __HUGE_MEMORY_H */
+#include <trace/define_trace.h>
+
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9671f51..595edd9 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -29,6 +29,9 @@
 #include <asm/pgalloc.h>
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/huge_memory.h>
+
 /*
  * By default transparent hugepage support is disabled in order that avoid
  * to risk increase the memory footprint of applications without a guaranteed
@@ -2190,25 +2193,32 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 					unsigned long address,
 					pte_t *pte)
 {
-	struct page *page;
+	struct page *page = NULL;
 	pte_t *_pte;
-	int none_or_zero = 0;
+	int none_or_zero = 0, ret = 0;
 	bool referenced = false, writable = false;
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (!userfaultfd_armed(vma) &&
-			    ++none_or_zero <= khugepaged_max_ptes_none)
+			    ++none_or_zero <= khugepaged_max_ptes_none) {
 				continue;
-			else
+			} else {
+				ret = MM_EXCEED_NONE_PTE;
 				goto out;
+			}
 		}
-		if (!pte_present(pteval))
+		if (!pte_present(pteval)) {
+			ret = MM_PTE_NON_PRESENT;
 			goto out;
+		}
+
 		page = vm_normal_page(vma, address, pteval);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			ret = MM_PAGE_NULL;
 			goto out;
+		}
 
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
@@ -2220,8 +2230,10 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 * is needed to serialize against split_huge_page
 		 * when invoked from the VM.
 		 */
-		if (!trylock_page(page))
+		if (!trylock_page(page)) {
+			ret = MM_PAGE_LOCK;
 			goto out;
+		}
 
 		/*
 		 * cannot use mapcount: can't collapse if there's a gup pin.
@@ -2230,6 +2242,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 */
 		if (page_count(page) != 1 + !!PageSwapCache(page)) {
 			unlock_page(page);
+			ret = MM_PAGE_COUNT;
 			goto out;
 		}
 		if (pte_write(pteval)) {
@@ -2237,6 +2250,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		} else {
 			if (PageSwapCache(page) && !reuse_swap_page(page)) {
 				unlock_page(page);
+				ret = MM_SWAP_CACHE_PAGE;
 				goto out;
 			}
 			/*
@@ -2251,6 +2265,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 */
 		if (isolate_lru_page(page)) {
 			unlock_page(page);
+			ret = MM_ISOLATE_LRU_PAGE;
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
@@ -2263,11 +2278,16 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = true;
 	}
-	if (likely(referenced && writable))
+	if (likely(referenced && writable)) {
+		trace_mm_collapse_huge_page_isolate(page, none_or_zero,
+						    referenced, writable, ret);
 		return 1;
+	}
 out:
 	release_pte_pages(pte, _pte);
-	return 0;
+	trace_mm_collapse_huge_page_isolate(page, none_or_zero,
+					    referenced, writable, ret);
+	return ret;
 }
 
 static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
@@ -2501,7 +2521,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
-	int isolated;
+	int isolated = 0, ret = 1;
 	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2516,12 +2536,18 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	/* release the mmap_sem read lock. */
 	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
-	if (!new_page)
+	if (!new_page) {
+		ret = MM_ALLOC_HUGE_PAGE_FAIL;
+		trace_mm_collapse_huge_page(mm, isolated, ret);
 		return;
+	}
 
 	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   gfp, &memcg)))
+					   gfp, &memcg))) {
+		ret = MM_CGROUP_CHARGE_FAIL;
+		trace_mm_collapse_huge_page(mm, isolated, ret);
 		return;
+	}
 
 	/*
 	 * Prevent all access to pagetables with the exception of
@@ -2529,21 +2555,31 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * handled by the anon_vma lock + PG_lock.
 	 */
 	down_write(&mm->mmap_sem);
-	if (unlikely(khugepaged_test_exit(mm)))
+	if (unlikely(khugepaged_test_exit(mm))) {
+		ret = MM_ANY_PROCESS;
 		goto out;
+	}
 
 	vma = find_vma(mm, address);
-	if (!vma)
+	if (!vma) {
+		ret = MM_VMA_NULL;
 		goto out;
+	}
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
-	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
+	if (address < hstart || address + HPAGE_PMD_SIZE > hend) {
+		ret = MM_ADDRESS_RANGE;
 		goto out;
-	if (!hugepage_vma_check(vma))
+	}
+	if (!hugepage_vma_check(vma)) {
+		ret = MM_VMA_CHECK;
 		goto out;
+	}
 	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	if (!pmd) {
+		ret = MM_PMD_NULL;
 		goto out;
+	}
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2568,7 +2604,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	isolated = __collapse_huge_page_isolate(vma, address, pte);
 	spin_unlock(pte_ptl);
 
-	if (unlikely(!isolated)) {
+	if (unlikely(isolated != 1)) {
 		pte_unmap(pte);
 		spin_lock(pmd_ptl);
 		BUG_ON(!pmd_none(*pmd));
@@ -2580,6 +2616,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
+		ret = MM_COLLAPSE_ISOLATE_FAIL;
 		goto out;
 	}
 
@@ -2619,6 +2656,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 out_up_write:
 	up_write(&mm->mmap_sem);
+	trace_mm_collapse_huge_page(mm, isolated, ret);
 	return;
 
 out:
@@ -2634,7 +2672,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
 	int ret = 0, none_or_zero = 0;
-	struct page *page;
+	struct page *page = NULL;
 	unsigned long _address;
 	spinlock_t *ptl;
 	int node = NUMA_NO_NODE;
@@ -2643,8 +2681,10 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	if (!pmd) {
+		ret = MM_PMD_NULL;
 		goto out;
+	}
 
 	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2653,19 +2693,26 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (!userfaultfd_armed(vma) &&
-			    ++none_or_zero <= khugepaged_max_ptes_none)
+			    ++none_or_zero <= khugepaged_max_ptes_none) {
 				continue;
-			else
+			} else {
+				ret = MM_EXCEED_NONE_PTE;
 				goto out_unmap;
+			}
 		}
-		if (!pte_present(pteval))
+		if (!pte_present(pteval)) {
+			ret = MM_PTE_NON_PRESENT;
 			goto out_unmap;
+		}
 		if (pte_write(pteval))
 			writable = true;
 
 		page = vm_normal_page(vma, _address, pteval);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			ret = MM_PAGE_NULL;
 			goto out_unmap;
+		}
+
 		/*
 		 * Record which node the original page is from and save this
 		 * information to khugepaged_node_load[].
@@ -2673,33 +2720,42 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		 * hit record.
 		 */
 		node = page_to_nid(page);
-		if (khugepaged_scan_abort(node))
+		if (khugepaged_scan_abort(node)) {
+			ret = MM_SCAN_ABORT;
 			goto out_unmap;
+		}
 		khugepaged_node_load[node]++;
 		VM_BUG_ON_PAGE(PageCompound(page), page);
-		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
+		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page)) {
+			ret = MM_PAGE_LRU;
 			goto out_unmap;
+		}
 		/*
 		 * cannot use mapcount: can't collapse if there's a gup pin.
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + !!PageSwapCache(page))
+		if (page_count(page) != 1 + !!PageSwapCache(page)) {
+			ret = MM_PAGE_COUNT;
 			goto out_unmap;
+		}
 		if (pte_young(pteval) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = true;
 	}
+	/* only 1 for scan succeed case */
 	if (referenced && writable)
 		ret = 1;
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
-	if (ret) {
+	if (ret == 1) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
 		collapse_huge_page(mm, address, hpage, vma, node);
 	}
 out:
+	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
+				     none_or_zero, ret);
 	return ret;
 }
 
@@ -2795,7 +2851,7 @@ skip:
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
 			progress += HPAGE_PMD_NR;
-			if (ret)
+			if (ret == 1)
 				/* we released mmap_sem so break loop */
 				goto breakouterloop_mmap_sem;
 			if (progress >= pages)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
