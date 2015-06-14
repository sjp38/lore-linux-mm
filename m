Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EDB356B006C
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 11:05:03 -0400 (EDT)
Received: by wgzl5 with SMTP id l5so26828934wgz.3
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:03 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id hg2si4218179wib.50.2015.06.14.08.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 08:05:02 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so54694520wib.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:02 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC 1/3] mm: add tracepoint for scanning pages
Date: Sun, 14 Jun 2015 18:04:41 +0300
Message-Id: <1434294283-8699-2-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
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
---
 include/trace/events/huge_memory.h | 96 ++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                   | 10 +++-
 2 files changed, 105 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/events/huge_memory.h

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
new file mode 100644
index 0000000..4b9049b
--- /dev/null
+++ b/include/trace/events/huge_memory.h
@@ -0,0 +1,96 @@
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
+	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, bool writable,
+		bool referenced, int none_or_zero, int collapse),
+
+	TP_ARGS(mm, vm_start, writable, referenced, none_or_zero, collapse),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, vm_start)
+		__field(bool, writable)
+		__field(bool, referenced)
+		__field(int, none_or_zero)
+		__field(int, collapse)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->vm_start = vm_start;
+		__entry->writable = writable;
+		__entry->referenced = referenced;
+		__entry->none_or_zero = none_or_zero;
+		__entry->collapse = collapse;
+	),
+
+	TP_printk("mm=%p, vm_start=%04lx, writable=%d, referenced=%d, none_or_zero=%d, collapse=%d",
+		__entry->mm,
+		__entry->vm_start,
+		__entry->writable,
+		__entry->referenced,
+		__entry->none_or_zero,
+		__entry->collapse)
+);
+
+TRACE_EVENT(mm_collapse_huge_page,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, int isolated),
+
+	TP_ARGS(mm, vm_start, isolated),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, vm_start)
+		__field(int, isolated)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->vm_start = vm_start;
+		__entry->isolated = isolated;
+	),
+
+	TP_printk("mm=%p, vm_start=%04lx, isolated=%d",
+		__entry->mm,
+		__entry->vm_start,
+		__entry->isolated)
+);
+
+TRACE_EVENT(mm_collapse_huge_page_isolate,
+
+	TP_PROTO(unsigned long vm_start, int none_or_zero,
+		bool referenced, bool  writable),
+
+	TP_ARGS(vm_start, none_or_zero, referenced, writable),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, vm_start)
+		__field(int, none_or_zero)
+		__field(bool, referenced)
+		__field(bool, writable)
+	),
+
+	TP_fast_assign(
+		__entry->vm_start = vm_start;
+		__entry->none_or_zero = none_or_zero;
+		__entry->referenced = referenced;
+		__entry->writable = writable;
+	),
+
+	TP_printk("vm_start=%04lx, none_or_zero=%d, referenced=%d, writable=%d",
+		__entry->vm_start,
+		__entry->none_or_zero,
+		__entry->referenced,
+		__entry->writable)
+);
+
+#endif /* __HUGE_MEMORY_H */
+#include <trace/define_trace.h>
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9671f51..9bb97fc 100644
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
@@ -2266,6 +2269,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	if (likely(referenced && writable))
 		return 1;
 out:
+	trace_mm_collapse_huge_page_isolate(vma->vm_start, none_or_zero,
+					    referenced, writable);
 	release_pte_pages(pte, _pte);
 	return 0;
 }
@@ -2501,7 +2506,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	pgtable_t pgtable;
 	struct page *new_page;
 	spinlock_t *pmd_ptl, *pte_ptl;
-	int isolated;
+	int isolated = 0;
 	unsigned long hstart, hend;
 	struct mem_cgroup *memcg;
 	unsigned long mmun_start;	/* For mmu_notifiers */
@@ -2619,6 +2624,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	khugepaged_pages_collapsed++;
 out_up_write:
 	up_write(&mm->mmap_sem);
+	trace_mm_collapse_huge_page(mm, vma->vm_start, isolated);
 	return;
 
 out:
@@ -2694,6 +2700,8 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 		ret = 1;
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	trace_mm_khugepaged_scan_pmd(mm, vma->vm_start, writable, referenced,
+				     none_or_zero, ret);
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
