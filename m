Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 729886B0254
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:32:19 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so7164wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:18 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id hk6si19612376wjb.202.2015.09.14.12.32.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:32:17 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so155550749wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:17 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v5 1/3] mm: add tracepoint for scanning pages
Date: Mon, 14 Sep 2015 22:31:43 +0300
Message-Id: <1442259105-4420-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
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

Changes in v4:
 - Change the constant prefix with SCAN_ instead of MM_ (Vlastimil Babka)
 - Move the constants into the enum (Vlastimil Babka)
 - Move the constants from mm.h to huge_memory.c
   (because only will be used in huge_memory.c) (Vlastimil Babka)
 - Print pfn in tracepoints (Vlastimil Babka)
 - Print scan result as string in tracepoint (Vlastimil Babka)
   (I tried to make same things to print string like mm/compaction.c.
    My patch does not print string, I skip something but could not see why)

 - Do not change function return values for success and failure,
   leave them original agreed with Doc/CodingStyle (Vlastimil Babka)
 - Define scan_result to specify tracepoint result (Ebru Akagunduz)
 - Add out_nolock label to avoid multiple tracepoints (Vlastimil Babka)

Changes in v5:
 - Use tracepoint macros to print string in userspace
   (fixes printing string problem) (Vlastimil Babka)

 include/trace/events/huge_memory.h | 137 +++++++++++++++++++++++++++++++
 mm/huge_memory.c                   | 164 ++++++++++++++++++++++++++++++-------
 2 files changed, 270 insertions(+), 31 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
new file mode 100644
index 0000000..1df9bf5
--- /dev/null
+++ b/include/trace/events/huge_memory.h
@@ -0,0 +1,137 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM huge_memory
+
+#if !defined(__HUGE_MEMORY_H) || defined(TRACE_HEADER_MULTI_READ)
+#define __HUGE_MEMORY_H
+
+#include  <linux/tracepoint.h>
+
+#include <trace/events/gfpflags.h>
+
+#define SCAN_STATUS							\
+	EM( SCAN_FAIL,			"failed")			\
+	EM( SCAN_SUCCEED,		"succeeded")			\
+	EM( SCAN_PMD_NULL,		"pmd_null")			\
+	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
+	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
+	EM( SCAN_PAGE_RO,		"no_writable_page")		\
+	EM( SCAN_NO_REFERENCED_PAGE,	"no_referenced_page")		\
+	EM( SCAN_PAGE_NULL,		"page_null")			\
+	EM( SCAN_SCAN_ABORT,		"scan_aborted")			\
+	EM( SCAN_PAGE_COUNT,		"not_suitable_page_count")	\
+	EM( SCAN_PAGE_LRU,		"page_not_in_lru")		\
+	EM( SCAN_PAGE_LOCK,		"page_locked")			\
+	EM( SCAN_PAGE_ANON,		"page_not_anon")		\
+	EM( SCAN_ANY_PROCESS,		"no_process_for_page")		\
+	EM( SCAN_VMA_NULL,		"vma_null")			\
+	EM( SCAN_VMA_CHECK,		"vma_check_failed")		\
+	EM( SCAN_ADDRESS_RANGE,		"not_suitable_address_range")	\
+	EM( SCAN_SWAP_CACHE_PAGE,	"page_swap_cache")		\
+	EM( SCAN_DEL_PAGE_LRU,		"could_not_delete_page_from_lru")\
+	EM( SCAN_ALLOC_HUGE_PAGE_FAIL,	"alloc_huge_page_failed")	\
+	EMe( SCAN_CGROUP_CHARGE_FAIL,	"ccgroup_charge_failed")
+
+#undef EM
+#undef EMe
+#define EM(a, b)	TRACE_DEFINE_ENUM(a);
+#define EMe(a, b)	TRACE_DEFINE_ENUM(a);
+
+SCAN_STATUS
+
+#undef EM
+#undef EMe
+#define EM(a, b)	{a, b},
+#define EMe(a, b)	{a, b}
+
+TRACE_EVENT(mm_khugepaged_scan_pmd,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
+		 bool referenced, int none_or_zero, int status),
+
+	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, pfn)
+		__field(bool, writable)
+		__field(bool, referenced)
+		__field(int, none_or_zero)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->pfn = pfn;
+		__entry->writable = writable;
+		__entry->referenced = referenced;
+		__entry->none_or_zero = none_or_zero;
+		__entry->status = status;
+	),
+
+	TP_printk("mm=%p, scan_pfn=0x%lx, writable=%d, referenced=%d, none_or_zero=%d, status=%s",
+		__entry->mm,
+		__entry->pfn,
+		__entry->writable,
+		__entry->referenced,
+		__entry->none_or_zero,
+		__print_symbolic(__entry->status, SCAN_STATUS))
+);
+
+TRACE_EVENT(mm_collapse_huge_page,
+
+	TP_PROTO(struct mm_struct *mm, int isolated, int status),
+
+	TP_ARGS(mm, isolated, status),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(int, isolated)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->isolated = isolated;
+		__entry->status = status;
+	),
+
+	TP_printk("mm=%p, isolated=%d, status=%s",
+		__entry->mm,
+		__entry->isolated,
+		__print_symbolic(__entry->status, SCAN_STATUS))
+);
+
+TRACE_EVENT(mm_collapse_huge_page_isolate,
+
+	TP_PROTO(unsigned long pfn, int none_or_zero,
+		 bool referenced, bool  writable, int status),
+
+	TP_ARGS(pfn, none_or_zero, referenced, writable, status),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, none_or_zero)
+		__field(bool, referenced)
+		__field(bool, writable)
+		__field(int, status)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->none_or_zero = none_or_zero;
+		__entry->referenced = referenced;
+		__entry->writable = writable;
+		__entry->status = status;
+	),
+
+	TP_printk("scan_pfn=0x%lx, none_or_zero=%d, referenced=%d, writable=%d, status=%s",
+		__entry->pfn,
+		__entry->none_or_zero,
+		__entry->referenced,
+		__entry->writable,
+		__print_symbolic(__entry->status, SCAN_STATUS))
+);
+
+#endif /* __HUGE_MEMORY_H */
+#include <trace/define_trace.h>
+
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8d..4215cee 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -31,6 +31,33 @@
 #include <asm/pgalloc.h>
 #include "internal.h"
 
+enum scan_result {
+	SCAN_FAIL,
+	SCAN_SUCCEED,
+	SCAN_PMD_NULL,
+	SCAN_EXCEED_NONE_PTE,
+	SCAN_PTE_NON_PRESENT,
+	SCAN_PAGE_RO,
+	SCAN_NO_REFERENCED_PAGE,
+	SCAN_PAGE_NULL,
+	SCAN_SCAN_ABORT,
+	SCAN_PAGE_COUNT,
+	SCAN_PAGE_LRU,
+	SCAN_PAGE_LOCK,
+	SCAN_PAGE_ANON,
+	SCAN_ANY_PROCESS,
+	SCAN_VMA_NULL,
+	SCAN_VMA_CHECK,
+	SCAN_ADDRESS_RANGE,
+	SCAN_SWAP_CACHE_PAGE,
+	SCAN_DEL_PAGE_LRU,
+	SCAN_ALLOC_HUGE_PAGE_FAIL,
+	SCAN_CGROUP_CHARGE_FAIL
+};
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/huge_memory.h>
+
 /*
  * By default transparent hugepage support is disabled in order that avoid
  * to risk increase the memory footprint of applications without a guaranteed
@@ -2199,25 +2226,31 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 					unsigned long address,
 					pte_t *pte)
 {
-	struct page *page;
+	struct page *page = NULL;
 	pte_t *_pte;
-	int none_or_zero = 0;
+	int none_or_zero = 0, result = 0;
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
+				result = SCAN_EXCEED_NONE_PTE;
 				goto out;
+			}
 		}
-		if (!pte_present(pteval))
+		if (!pte_present(pteval)) {
+			result = SCAN_PTE_NON_PRESENT;
 			goto out;
+		}
 		page = vm_normal_page(vma, address, pteval);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			result = SCAN_PAGE_NULL;
 			goto out;
+		}
 
 		VM_BUG_ON_PAGE(PageCompound(page), page);
 		VM_BUG_ON_PAGE(!PageAnon(page), page);
@@ -2229,8 +2262,10 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 * is needed to serialize against split_huge_page
 		 * when invoked from the VM.
 		 */
-		if (!trylock_page(page))
+		if (!trylock_page(page)) {
+			result = SCAN_PAGE_LOCK;
 			goto out;
+		}
 
 		/*
 		 * cannot use mapcount: can't collapse if there's a gup pin.
@@ -2239,6 +2274,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 */
 		if (page_count(page) != 1 + !!PageSwapCache(page)) {
 			unlock_page(page);
+			result = SCAN_PAGE_COUNT;
 			goto out;
 		}
 		if (pte_write(pteval)) {
@@ -2246,6 +2282,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		} else {
 			if (PageSwapCache(page) && !reuse_swap_page(page)) {
 				unlock_page(page);
+				result = SCAN_SWAP_CACHE_PAGE;
 				goto out;
 			}
 			/*
@@ -2260,6 +2297,7 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		 */
 		if (isolate_lru_page(page)) {
 			unlock_page(page);
+			result = SCAN_DEL_PAGE_LRU;
 			goto out;
 		}
 		/* 0 stands for page_is_file_cache(page) == false */
@@ -2273,10 +2311,21 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = true;
 	}
-	if (likely(referenced && writable))
-		return 1;
+	if (likely(writable)) {
+		if (likely(referenced)) {
+			result = SCAN_SUCCEED;
+			trace_mm_collapse_huge_page_isolate(page_to_pfn(page), none_or_zero,
+							    referenced, writable, result);
+			return 1;
+		}
+	} else {
+		result = SCAN_PAGE_RO;
+	}
+
 out:
 	release_pte_pages(pte, _pte);
+	trace_mm_collapse_huge_page_isolate(page_to_pfn(page), none_or_zero,
+					    referenced, writable, result);
 	return 0;
 }
 
@@ -2515,7 +2564,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
-	int isolated;
+	int isolated, result = 0;
 	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2530,12 +2579,16 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	/* release the mmap_sem read lock. */
 	new_page = khugepaged_alloc_page(hpage, gfp, mm, vma, address, node);
-	if (!new_page)
-		return;
+	if (!new_page) {
+		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
+		goto out_nolock;
+	}
 
 	if (unlikely(mem_cgroup_try_charge(new_page, mm,
-					   gfp, &memcg)))
-		return;
+					   gfp, &memcg))) {
+		result = SCAN_CGROUP_CHARGE_FAIL;
+		goto out_nolock;
+	}
 
 	/*
 	 * Prevent all access to pagetables with the exception of
@@ -2543,21 +2596,31 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * handled by the anon_vma lock + PG_lock.
 	 */
 	down_write(&mm->mmap_sem);
-	if (unlikely(khugepaged_test_exit(mm)))
+	if (unlikely(khugepaged_test_exit(mm))) {
+		result = SCAN_ANY_PROCESS;
 		goto out;
+	}
 
 	vma = find_vma(mm, address);
-	if (!vma)
+	if (!vma) {
+		result = SCAN_VMA_NULL;
 		goto out;
+	}
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
-	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
+	if (address < hstart || address + HPAGE_PMD_SIZE > hend) {
+		result = SCAN_ADDRESS_RANGE;
 		goto out;
-	if (!hugepage_vma_check(vma))
+	}
+	if (!hugepage_vma_check(vma)) {
+		result = SCAN_VMA_CHECK;
 		goto out;
+	}
 	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	if (!pmd) {
+		result = SCAN_PMD_NULL;
 		goto out;
+	}
 
 	anon_vma_lock_write(vma->anon_vma);
 
@@ -2594,6 +2657,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
 		spin_unlock(pmd_ptl);
 		anon_vma_unlock_write(vma->anon_vma);
+		result = SCAN_FAIL;
 		goto out;
 	}
 
@@ -2631,10 +2695,15 @@ static void collapse_huge_page(struct mm_struct *mm,
 	*hpage = NULL;
 
 	khugepaged_pages_collapsed++;
+	result = SCAN_SUCCEED;
 out_up_write:
 	up_write(&mm->mmap_sem);
+	trace_mm_collapse_huge_page(mm, isolated, result);
 	return;
 
+out_nolock:
+	trace_mm_collapse_huge_page(mm, isolated, result);
+	return;
 out:
 	mem_cgroup_cancel_charge(new_page, memcg);
 	goto out_up_write;
@@ -2647,8 +2716,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, none_or_zero = 0;
-	struct page *page;
+	int ret = 0, none_or_zero = 0, result = 0;
+	struct page *page = NULL;
 	unsigned long _address;
 	spinlock_t *ptl;
 	int node = NUMA_NO_NODE;
@@ -2657,8 +2726,10 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
 	pmd = mm_find_pmd(mm, address);
-	if (!pmd)
+	if (!pmd) {
+		result = SCAN_PMD_NULL;
 		goto out;
+	}
 
 	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2667,19 +2738,25 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		pte_t pteval = *_pte;
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (!userfaultfd_armed(vma) &&
-			    ++none_or_zero <= khugepaged_max_ptes_none)
+			    ++none_or_zero <= khugepaged_max_ptes_none) {
 				continue;
-			else
+			} else {
+				result = SCAN_EXCEED_NONE_PTE;
 				goto out_unmap;
+			}
 		}
-		if (!pte_present(pteval))
+		if (!pte_present(pteval)) {
+			result = SCAN_PTE_NON_PRESENT;
 			goto out_unmap;
+		}
 		if (pte_write(pteval))
 			writable = true;
 
 		page = vm_normal_page(vma, _address, pteval);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			result = SCAN_PAGE_NULL;
 			goto out_unmap;
+		}
 		/*
 		 * Record which node the original page is from and save this
 		 * information to khugepaged_node_load[].
@@ -2687,26 +2764,49 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		 * hit record.
 		 */
 		node = page_to_nid(page);
-		if (khugepaged_scan_abort(node))
+		if (khugepaged_scan_abort(node)) {
+			result = SCAN_SCAN_ABORT;
 			goto out_unmap;
+		}
 		khugepaged_node_load[node]++;
 		VM_BUG_ON_PAGE(PageCompound(page), page);
-		if (!PageLRU(page) || PageLocked(page) || !PageAnon(page))
+		if (!PageLRU(page)) {
+		result = SCAN_SCAN_ABORT;
+			goto out_unmap;
+		}
+		if (PageLocked(page)) {
+			result = SCAN_PAGE_LOCK;
 			goto out_unmap;
+		}
+		if (!PageAnon(page)) {
+			result = SCAN_PAGE_ANON;
+			goto out_unmap;
+		}
+
 		/*
 		 * cannot use mapcount: can't collapse if there's a gup pin.
 		 * The page must only be referenced by the scanned process
 		 * and page swap cache.
 		 */
-		if (page_count(page) != 1 + !!PageSwapCache(page))
+		if (page_count(page) != 1 + !!PageSwapCache(page)) {
+			result = SCAN_PAGE_COUNT;
 			goto out_unmap;
+		}
 		if (pte_young(pteval) ||
 		    page_is_young(page) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
 			referenced = true;
 	}
-	if (referenced && writable)
-		ret = 1;
+	if (writable) {
+		if (referenced) {
+			result = SCAN_SUCCEED;
+			ret = 1;
+		} else {
+			result = SCAN_NO_REFERENCED_PAGE;
+		}
+	} else {
+		result = SCAN_PAGE_RO;
+	}
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	if (ret) {
@@ -2715,6 +2815,8 @@ out_unmap:
 		collapse_huge_page(mm, address, hpage, vma, node);
 	}
 out:
+	trace_mm_khugepaged_scan_pmd(mm, page_to_pfn(page), writable, referenced,
+				     none_or_zero, result);
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
