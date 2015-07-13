Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 92CC8280244
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:28:27 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so71662389wic.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:27 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id j10si642289wjf.167.2015.07.13.13.28.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 13:28:26 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so71661931wic.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:25 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v3 2/3] mm: make optimistic check for swapin readahead
Date: Mon, 13 Jul 2015 23:28:03 +0300
Message-Id: <1436819284-3964-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
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
Changes in v2:
 - Nothing changed

Changes in v3:
 - Define constant to specify exact tracepoint result (Vlastimil Babka)

 include/linux/mm.h                 |  1 +
 include/trace/events/huge_memory.h | 11 +++++++----
 mm/huge_memory.c                   | 15 ++++++++++++---
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf341c0..eacf348 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -38,6 +38,7 @@
 #define MM_ALLOC_HUGE_PAGE_FAIL	6
 #define MM_CGROUP_CHARGE_FAIL	7
 #define MM_COLLAPSE_ISOLATE_FAIL 5
+#define MM_EXCEED_SWAP_PTE	2
 
 struct mempolicy;
 struct anon_vma;
diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index cbc56fc..b6bdcc4 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -9,9 +9,9 @@
 TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_PROTO(struct mm_struct *mm, struct page *page, bool writable,
-		 bool referenced, int none_or_zero, int ret),
+		 bool referenced, int none_or_zero, int ret, int unmapped),
 
-	TP_ARGS(mm, page, writable, referenced, none_or_zero, ret),
+	TP_ARGS(mm, page, writable, referenced, none_or_zero, ret, unmapped),
 
 	TP_STRUCT__entry(
 		__field(struct mm_struct *, mm)
@@ -20,6 +20,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__field(bool, referenced)
 		__field(int, none_or_zero)
 		__field(int, ret)
+		__field(int, unmapped)
 	),
 
 	TP_fast_assign(
@@ -29,15 +30,17 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__entry->referenced = referenced;
 		__entry->none_or_zero = none_or_zero;
 		__entry->ret = ret;
+		__entry->unmapped = unmapped;
 	),
 
-	TP_printk("mm=%p, page=%p, writable=%d, referenced=%d, none_or_zero=%d, ret=%d",
+	TP_printk("mm=%p, page=%p, writable=%d, referenced=%d, none_or_zero=%d, ret=%d, unmapped=%d",
 		__entry->mm,
 		__entry->page,
 		__entry->writable,
 		__entry->referenced,
 		__entry->none_or_zero,
-		__entry->ret)
+		__entry->ret,
+		__entry->unmapped)
 );
 
 TRACE_EVENT(mm_collapse_huge_page,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 595edd9..b4cef9d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -24,6 +24,7 @@
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2671,11 +2672,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 {
 	pmd_t *pmd;
 	pte_t *pte, *_pte;
-	int ret = 0, none_or_zero = 0;
+	int ret = 0, none_or_zero = 0, unmapped = 0;
 	struct page *page = NULL;
 	unsigned long _address;
 	spinlock_t *ptl;
-	int node = NUMA_NO_NODE;
+	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;
 	bool writable = false, referenced = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -2691,6 +2692,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
+		if (is_swap_pte(pteval)) {
+			if (++unmapped <= max_ptes_swap) {
+				continue;
+			} else {
+				ret = MM_EXCEED_SWAP_PTE;
+				goto out_unmap;
+			}
+		}
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (!userfaultfd_armed(vma) &&
 			    ++none_or_zero <= khugepaged_max_ptes_none) {
@@ -2755,7 +2764,7 @@ out_unmap:
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page, writable, referenced,
-				     none_or_zero, ret);
+				     none_or_zero, ret, unmapped);
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
