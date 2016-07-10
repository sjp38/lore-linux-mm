Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 524346B0005
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 20:11:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x83so30773801wma.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:11:06 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id g5si3235222wje.17.2016.07.09.17.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 17:11:05 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id w75so12195685wmd.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:11:05 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v3 2/2] mm, thp: convert from optimistic swapin collapsing to conservative
Date: Sun, 10 Jul 2016 03:10:51 +0300
Message-Id: <1468109451-1615-1-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
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

Changes in v3:
 - After khugepaged extracted from huge_memory.c,
   changes moved to khugepaged.c

 include/trace/events/huge_memory.h | 19 +++++++++++--------
 mm/khugepaged.c                    | 38 +++++++++++++++++++++++---------------
 2 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 830d47d..04f58ac 100644
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
@@ -47,7 +47,7 @@ SCAN_STATUS
 TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
-		 bool referenced, int none_or_zero, int status, int unmapped),
+		 int referenced, int none_or_zero, int status, int unmapped),
 
 	TP_ARGS(mm, page, writable, referenced, none_or_zero, status, unmapped),
 
@@ -55,7 +55,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__field(struct mm_struct *, mm)
 		__field(unsigned long, pfn)
 		__field(bool, writable)
-		__field(bool, referenced)
+		__field(int, referenced)
 		__field(int, none_or_zero)
 		__field(int, status)
 		__field(int, unmapped)
@@ -108,14 +108,14 @@ TRACE_EVENT(mm_collapse_huge_page,
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
@@ -138,25 +138,28 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
 
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
 
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 5661484..7dbee69 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -27,7 +27,7 @@ enum scan_result {
 	SCAN_EXCEED_NONE_PTE,
 	SCAN_PTE_NON_PRESENT,
 	SCAN_PAGE_RO,
-	SCAN_NO_REFERENCED_PAGE,
+	SCAN_LACK_REFERENCED_PAGE,
 	SCAN_PAGE_NULL,
 	SCAN_SCAN_ABORT,
 	SCAN_PAGE_COUNT,
@@ -500,8 +500,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 {
 	struct page *page = NULL;
 	pte_t *_pte;
-	int none_or_zero = 0, result = 0;
-	bool referenced = false, writable = false;
+	int none_or_zero = 0, result = 0, referenced = 0;
+	bool writable = false;
 
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
@@ -580,11 +580,11 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
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
@@ -869,7 +869,8 @@ static int hugepage_vma_revalidate(struct mm_struct *mm, unsigned long address)
 
 static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					struct vm_area_struct *vma,
-					unsigned long address, pmd_t *pmd)
+					unsigned long address, pmd_t *pmd,
+					int referenced)
 {
 	pte_t pteval;
 	int swapped_in = 0, ret = 0;
@@ -887,12 +888,19 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 		if (!is_swap_pte(pteval))
 			continue;
 		swapped_in++;
+		/* we only decide to swapin, if there is enough young ptes */
+		if (referenced < HPAGE_PMD_NR/2) {
+			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
+			return false;
+		}
 		ret = do_swap_page(&fe, pteval);
+
 		/* do_swap_page returns VM_FAULT_RETRY with released mmap_sem */
 		if (ret & VM_FAULT_RETRY) {
 			down_read(&mm->mmap_sem);
 			if (hugepage_vma_revalidate(mm, address)) {
 				/* vma is no longer available, don't continue to swapin */
+				trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 				return false;
 			}
 			/* check if the pmd is still valid */
@@ -900,7 +908,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 				return false;
 		}
 		if (ret & VM_FAULT_ERROR) {
-			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
+			trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 0);
 			return false;
 		}
 		/* pte is unmapped now, we need to map it */
@@ -908,7 +916,7 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 	}
 	fe.pte--;
 	pte_unmap(fe.pte);
-	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+	trace_mm_collapse_huge_page_swapin(mm, swapped_in, referenced, 1);
 	return true;
 }
 
@@ -916,7 +924,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
 				   struct vm_area_struct *vma,
-				   int node)
+				   int node, int referenced)
 {
 	pmd_t *pmd, _pmd;
 	pte_t *pte;
@@ -973,7 +981,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If it fails, we release mmap_sem and jump out_nolock.
 	 * Continuing to collapse causes inconsistency.
 	 */
-	if (!__collapse_huge_page_swapin(mm, vma, address, pmd)) {
+	if (!__collapse_huge_page_swapin(mm, vma, address, pmd, referenced)) {
 		mem_cgroup_cancel_charge(new_page, memcg, true);
 		up_read(&mm->mmap_sem);
 		goto out_nolock;
@@ -1084,12 +1092,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
 
@@ -1177,14 +1185,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
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
@@ -1194,7 +1202,7 @@ out_unmap:
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
