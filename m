Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A31676B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 07:15:48 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so462505wmr.0
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:48 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id g128si115404wmd.84.2016.06.22.04.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jun 2016 04:15:46 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a66so198410wme.2
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 04:15:45 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v2 2/3] mm, thp: convert from optimistic swapin collapsing to conservative
Date: Wed, 22 Jun 2016 14:15:20 +0300
Message-Id: <1466594120-2905-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1466594120-2905-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

To detect whether khugepaged swapin worthwhile, this patch checks
the amount of young pages. There should be at least half of
HPAGE_PMD_NR to swapin.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
---
Changes in v2:
 - Don't change thp design, only notice amount of young
   pages, if khugepaged needs to swapin (Minchan Kim).
 - Print out count of referenced pages in
   __collapse_huge_page_swapin() (Ebru Akagunduz)

 include/trace/events/huge_memory.h | 19 ++++++++++--------
 mm/huge_memory.c                   | 40 +++++++++++++++++++++++---------------
 2 files changed, 35 insertions(+), 24 deletions(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index bda2118..9f69a72 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -13,7 +13,7 @@
 	EM( SCAN_EXCEED_NONE_PTE,	"exceed_none_pte")		\
 	EM( SCAN_PTE_NON_PRESENT,	"pte_non_present")		\
 	EM( SCAN_PAGE_RO,		"no_writable_page")		\
-	EM( SCAN_NO_REFERENCED_PAGE,	"no_referenced_page")		\
+	EM( SCAN_LACK_REFERENCED_PAGE,	"lack_referenced_page")		\
 	EM( SCAN_PAGE_NULL,		"page_null")			\
 	EM( SCAN_SCAN_ABORT,		"scan_aborted")			\
 	EM( SCAN_PAGE_COUNT,		"not_suitable_page_count")	\
@@ -46,7 +46,7 @@ SCAN_STATUS
 TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
-		 bool referenced, int none_or_zero, int status, int unmapped),
+		 int referenced, int none_or_zero, int status, int unmapped),
 
 	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
 
@@ -54,7 +54,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__field(struct mm_struct *, mm)
 		__field(unsigned long, pfn)
 		__field(bool, writable)
-		__field(bool, referenced)
+		__field(int, referenced)
 		__field(int, none_or_zero)
 		__field(int, status)
 		__field(int, unmapped)
@@ -107,14 +107,14 @@ TRACE_EVENT(mm_collapse_huge_page,
 TRACE_EVENT(mm_collapse_huge_page_isolate,
 
 	TP_PROTO(struct page *page, int none_or_zero,
-		 bool referenced, bool  writable, int status),
+		 int referenced, bool  writable, int status),
 
 	TP_ARGS(page, none_or_zero, referenced, writable, status),
 
 	TP_STRUCT__entry(
 		__field(unsigned long, pfn)
 		__field(int, none_or_zero)
-		__field(bool, referenced)
+		__field(int, referenced)
 		__field(bool, writable)
 		__field(int, status)
 	),
@@ -137,25 +137,28 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
 
 TRACE_EVENT(mm_collapse_huge_page_swapin,
 
-	TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
+	TP_PROTO(struct mm_struct *mm, int swapped_in, int referenced, int ret),
 
-	TP_ARGS(mm, swapped_in, ret),
+	TP_ARGS(mm, swapped_in, referenced, ret),
 
 	TP_STRUCT__entry(
 		__field(struct mm_struct *, mm)
 		__field(int, swapped_in)
+		__field(int, referenced)
 		__field(int, ret)
 	),
 
 	TP_fast_assign(
 		__entry->mm = mm;
 		__entry->swapped_in = swapped_in;
+		__entry->referenced = referenced;
 		__entry->ret = ret;
 	),
 
-	TP_printk("mm=%p, swapped_in=%d, ret=%d",
+	TP_printk("mm=%p, swapped_in=%d, referenced=%d, ret=%d",
 		__entry->mm,
 		__entry->swapped_in,
+		__entry->referenced,
 		__entry->ret)
 );
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 34fec1f..ff96765 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -42,7 +42,7 @@ enum scan_result {
 	SCAN_EXCEED_NONE_PTE,
 	SCAN_PTE_NON_PRESENT,
 	SCAN_PAGE_RO,
-	SCAN_NO_REFERENCED_PAGE,
+	SCAN_LACK_REFERENCED_PAGE,
 	SCAN_PAGE_NULL,
 	SCAN_SCAN_ABORT,
 	SCAN_PAGE_COUNT,
@@ -2048,8 +2048,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	pte_t *_pte;
-	int none_or_zero = 0, result = 0;
-	bool referenced = false, writable = false;
+	int none_or_zero = 0, result = 0, referenced = 0;
+	bool writable = false;
 
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
@@ -2128,11 +2128,11 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 		VM_BUG_ON_PAGE(!PageLocked(page), page);
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 
-		/* If there is no mapped pte young don't collapse the page */
+		/* There should be enough young pte to collapse the page */
 		if (pte_young(pteval) ||
 		    page_is_young(page) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
-			referenced = true;
+			referenced++;
 	}
 	if (likely(writable)) {
 		if (likely(referenced)) {
@@ -2416,7 +2416,8 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address)
 
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
-					unsigned long address, pmd_t *pmd)
+					unsigned long address,
+					pmd_t *pmd, int referenced)
 {
 	unsigned long _address;
 	pte_t *pte, pteval;
@@ -2429,6 +2430,11 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		if (!is_swap_pte(pteval))
 			continue;
 		swapped_in++;
+		/* we only decide to swapin, if there is enough young ptes */
+		if (referenced < HPAGE_PMD_NR/2) {
+			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
+			return false;
+		}
 		ret = do_swap_page(mm, vma, _address, pte, pmd,
 				   FAULT_FLAG_ALLOW_RETRY,
 				   pteval);
@@ -2436,11 +2442,13 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
 			/* vma is no longer available, don't continue to swapin */
-			if (hugepage_vma_revalidate(mm, address))
+			if (hugepage_vma_revalidate(mm, address)) {
+				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 				return false;
+			}
 		}
 		if (ret & VM_FAULT_ERROR) {
-			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
+			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 			return false;
 		}
 		/* pte is unmapped now, we need to map it */
@@ -2448,7 +2456,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 	}
 	pte--;
 	pte_unmap(pte);
-	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+	trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 1);
 	return true;
 }
 
@@ -2456,7 +2464,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
 				   struct vm_area_struct *vma,
-				   int node)
+				   int node, int referenced)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -2507,7 +2515,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * locked.  If it fails, release mmap_sem and jump directly
 	 * out.  Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -2615,12 +2623,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, none_or_zero = 0, result = 0;
+	int ret = 0, none_or_zero = 0, result = 0, referenced = 0;
 	struct page *page = NULL;
 	unsigned long _address;
 	spinlock_t *ptl;
 	int node = NUMA_NO_NODE, unmapped = 0;
-	bool writable = false, referenced = false;
+	bool writable = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -2708,14 +2716,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		if (pte_young(pteval) ||
 		    page_is_young(page) || PageReferenced(page) ||
 		    mmu_notifier_test_young(vma->vm_mm, address))
-			referenced = true;
+			referenced++;
 	}
 	if (writable) {
 		if (referenced) {
 			result = SCAN_SUCCEED;
 			ret = 1;
 		} else {
-			result = SCAN_NO_REFERENCED_PAGE;
+			result = SCAN_LACK_REFERENCED_PAGE;
 		}
 	} else {
 		result = SCAN_PAGE_RO;
@@ -2725,7 +2733,7 @@ out_unmap:
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-		collapse_huge_page(mm, address, hpage, vma, node);
+		collapse_huge_page(mm, address, hpage, vma, node, referenced);
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
