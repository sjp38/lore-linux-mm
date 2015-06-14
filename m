Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id CEC796B006E
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 11:05:06 -0400 (EDT)
Received: by wgzl5 with SMTP id l5so26829483wgz.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:06 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id sb18si17397705wjb.120.2015.06.14.08.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 08:05:05 -0700 (PDT)
Received: by wigg3 with SMTP id g3so54439971wig.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:04 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC 2/3] mm: make optimistic check for swapin readahead
Date: Sun, 14 Jun 2015 18:04:42 +0300
Message-Id: <1434294283-8699-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch makes optimistic check for swapin readahead
to increase thp collapse rate. Before getting swapped
out pages to memory, checks them and allows up to a
certain number. It also prints out using tracepoints
amount of unmapped ptes.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
 include/trace/events/huge_memory.h | 11 +++++++----
 mm/huge_memory.c                   | 13 ++++++++++---
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 4b9049b..53c9f2e 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -9,9 +9,9 @@
 TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, bool writable,
-		bool referenced, int none_or_zero, int collapse),
+		bool referenced, int none_or_zero, int collapse, int unmapped),
 
-	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse),
+	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse, unmapped),
 
 	TP_STRUCT__entry(
 		__field(struct mm_struct *, mm)
@@ -20,6 +20,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__field(bool, referenced)
 		__field(int, none_or_zero)
 		__field(int, collapse)
+		__field(int, unmapped)
 	),
 
 	TP_fast_assign(
@@ -29,15 +30,17 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__entry->referenced = referenced;
 		__entry->none_or_zero = none_or_zero;
 		__entry->collapse = collapse;
+		__entry->unmapped = unmapped;
 	),
 
-	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d",
+	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d, unmapped=%d",
 		__entry->mm,
 		__entry->vm_start,
 		__entry->writable,
 		__entry->referenced,
 		__entry->none_or_zero,
-		__entry->collapse)
+		__entry->collapse,
+		__entry->unmapped)
 );
 
 TRACE_EVENT(mm_collapse_huge_page,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9bb97fc..22bc0bf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2639,11 +2640,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, none_or_zero = 0;
+	int ret = 0, none_or_zero = 0, unmapped = 0;
 	struct page *page;
 	unsigned long _address;
 	spinlock_t *ptl;
-	int node = NUMA_NO_NODE;
+	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
 	bool writable = false, referenced = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -2657,6 +2658,12 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
+		if (is_swap_pte(pteval)) {
+			if (++unmapped <= max_ptes_swap)
+				continue;
+			else
+				goto out_unmap;
+		}
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (!userfaultfd_armed(vma) &&
 			    ++none_or_zero <= khugepaged_max_ptes_none)
@@ -2701,7 +2708,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
 	trace_mm_khugepaged_scan_pmd(mm, vma->vm_start, writable, referenced,
-				     none_or_zero, ret);
+				     none_or_zero, ret, unmapped);
 	if (ret) {
 		node = khugepaged_find_target_node();
 		/* collapse_huge_page will return with the mmap_sem released */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
