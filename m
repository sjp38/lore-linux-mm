Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 435B06B0256
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 16:52:12 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so2862094wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:11 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com. [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id fk20si98147wjc.82.2015.09.03.13.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 13:52:10 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so1593982wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:10 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RESEND RFC v4 2/3] mm: make optimistic check for swapin readahead
Date: Thu,  3 Sep 2015 23:51:47 +0300
Message-Id: <1441313508-4276-3-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch introduces new sysfs integer knob
/sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
which makes optimistic check for swapin readahead to
increase thp collapse rate. Before getting swapped
out pages to memory, checks them and allows up to a
certain number. It also prints out using tracepoints
amount of unmapped ptes.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
Changes in v2:
 - Nothing changed

Changes in v3:
 - Define constant for exact tracepoint result (Vlastimil Babka)

Changes in v4:
 - Add sysfs knob request (Kirill A. Shutemov)

 include/trace/events/huge_memory.h | 10 ++++----
 mm/huge_memory.c                   | 48 ++++++++++++++++++++++++++++++++++----
 2 files changed, 50 insertions(+), 8 deletions(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 36162a9..c2112fd 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -9,9 +9,9 @@
 TRACE_EVENT(mm_khugepaged_scan_pmd,
 
 	TP_PROTO(struct mm_struct *mm, unsigned long pfn, bool writable,
-		 bool referenced, int none_or_zero, int status),
+		 bool referenced, int none_or_zero, int status, int unmapped),
 
-	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status),
+	TP_ARGS(mm, pfn, writable, referenced, none_or_zero, status, unmapped),
 
 	TP_STRUCT__entry(
 		__field(struct mm_struct *, mm)
@@ -20,6 +20,7 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__field(bool, referenced)
 		__field(int, none_or_zero)
 		__field(int, status)
+		__field(int, unmapped)
 	),
 
 	TP_fast_assign(
@@ -31,13 +32,14 @@ TRACE_EVENT(mm_khugepaged_scan_pmd,
 		__entry->status = status;
 	),
 
-	TP_printk("mm=%p, scan_pfn=0x%lx, writable=%d, referenced=%d, none_or_zero=%d, status=%s",
+	TP_printk("mm=%p, scan_pfn=0x%lx, writable=%d, referenced=%d, none_or_zero=%d, status=%s, unmapped=%d",
 		__entry->mm,
 		__entry->pfn,
 		__entry->writable,
 		__entry->referenced,
 		__entry->none_or_zero,
-		khugepaged_status_string[__entry->status])
+		khugepaged_status_string[__entry->status],
+		__entry->unmapped)
 );
 
 TRACE_EVENT(mm_collapse_huge_page,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 71a7c43..cb9ab46 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -23,6 +23,7 @@
 #include <linux/pagemap.h>
 #include <linux/migrate.h>
 #include <linux/hashtable.h>
+#include <linux/swapops.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -49,7 +50,8 @@ static const char *const khugepaged_status_string[] = {
 	"page_swap_cache",
 	"could_not_delete_page_from_lru",
 	"alloc_huge_page_fail",
-	"ccgroup_charge_fail"
+	"ccgroup_charge_fail",
+	"exceed_swap_pte"
 };
 
 enum scan_result {
@@ -73,7 +75,8 @@ enum scan_result {
 	SCAN_SWAP_CACHE_PAGE,
 	SCAN_DEL_PAGE_LRU,
 	SCAN_ALLOC_HUGE_PAGE_FAIL,
-	SCAN_CGROUP_CHARGE_FAIL
+	SCAN_CGROUP_CHARGE_FAIL,
+	MM_EXCEED_SWAP_PTE
 };
 
 #define CREATE_TRACE_POINTS
@@ -115,6 +118,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
  * fault.
  */
 static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
+static unsigned int khugepaged_max_ptes_swap __read_mostly = HPAGE_PMD_NR/8;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
@@ -607,6 +611,33 @@ static struct kobj_attribute khugepaged_max_ptes_none_attr =
 	__ATTR(max_ptes_none, 0644, khugepaged_max_ptes_none_show,
 	       khugepaged_max_ptes_none_store);
 
+static ssize_t khugepaged_max_ptes_swap_show(struct kobject *kobj,
+					     struct kobj_attribute *attr,
+					     char *buf)
+{
+	return sprintf(buf, "%u\n", khugepaged_max_ptes_swap);
+}
+
+static ssize_t khugepaged_max_ptes_swap_store(struct kobject *kobj,
+					      struct kobj_attribute *attr,
+					      const char *buf, size_t count)
+{
+	int err;
+	unsigned long max_ptes_swap;
+
+	err  = kstrtoul(buf, 10, &max_ptes_swap);
+	if (err || max_ptes_swap > HPAGE_PMD_NR-1)
+		return -EINVAL;
+
+	khugepaged_max_ptes_swap = max_ptes_swap;
+
+	return count;
+}
+
+static struct kobj_attribute khugepaged_max_ptes_swap_attr =
+	__ATTR(max_ptes_swap, 0644, khugepaged_max_ptes_swap_show,
+	       khugepaged_max_ptes_swap_store);
+
 static struct attribute *khugepaged_attr[] = {
 	&khugepaged_defrag_attr.attr,
 	&khugepaged_max_ptes_none_attr.attr,
@@ -615,6 +646,7 @@ static struct attribute *khugepaged_attr[] = {
 	&full_scans_attr.attr,
 	&scan_sleep_millisecs_attr.attr,
 	&alloc_sleep_millisecs_attr.attr,
+	&khugepaged_max_ptes_swap_attr.attr,
 	NULL,
 };
 
@@ -2664,7 +2696,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	struct page *page = NULL;
 	unsigned long _address;
 	spinlock_t *ptl;
-	int node = NUMA_NO_NODE;
+	int node = NUMA_NO_NODE, unmapped = 0;
 	bool writable = false, referenced = false;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
@@ -2680,6 +2712,14 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
+		if (is_swap_pte(pteval)) {
+			if (++unmapped <= khugepaged_max_ptes_swap) {
+				continue;
+			} else {
+				result = MM_EXCEED_SWAP_PTE;
+				goto out_unmap;
+			}
+		}
 		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
 			if (++none_or_zero <= khugepaged_max_ptes_none) {
 				continue;
@@ -2757,7 +2797,7 @@ out_unmap:
 	}
 out:
 	trace_mm_khugepaged_scan_pmd(mm, page_to_pfn(page), writable, referenced,
-				     none_or_zero, result);
+				     none_or_zero, result, unmapped);
 	return ret;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
