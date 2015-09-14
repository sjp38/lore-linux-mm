Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A9DAB6B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:32:23 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so146270422wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:23 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id jc9si20668691wjb.143.2015.09.14.12.32.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:32:22 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so156606149wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:22 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v5 3/3] mm: make swapin readahead to improve thp collapse rate
Date: Mon, 14 Sep 2015 22:31:45 +0300
Message-Id: <1442259105-4420-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch makes swapin readahead to improve thp collapse rate.
When khugepaged scanned pages, there can be a few of the pages
in swap area.

With the patch THP can collapse 4kB pages into a THP when
there are up to max_ptes_swap swap ptes in a 2MB range.

The patch was tested with a test program that allocates
400B of memory, writes to it, and then sleeps. I force
the system to swap out all. Afterwards, the test program
touches the area by writing, it skips a page in each
20 pages of the area.

Without the patch, system did not swap in readahead.
THP rate was %65 of the program of the memory, it
did not change over time.

With this patch, after 10 minutes of waiting khugepaged had
collapsed %99 of the program's memory.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
Changes in v2:
 - Use FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT flag
   instead of 0x0 when called do_swap_page from
   __collapse_huge_page_swapin (Rik van Riel)

Changes in v3:
 - Catch VM_FAULT_HWPOISON and VM_FAULT_OOM return cases
   in __collapse_huge_page_swapin (Kirill A. Shutemov)

Changes in v4:
 - Fix broken indentation reverting if (...) statement in
   __collapse_huge_page_swapin (Kirill A. Shutemov)
 - Fix check statement of ret (Kirill A. Shutemov)
 - Use swapped_in name instead of swap_pte

Changes in v5:
 - Export do_swap_page in mm/internal.h instead outside
   of mm (Vlastimil Babka)

Test results:

                        After swapped out
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 90076 kB    | 88064 kB    | 309928 kB |    %99    |
-------------------------------------------------------------------
Without patch | 194068 kB | 192512 kB     | 205936 kB |    %99    |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 201408 kB | 198656 kB     | 198596 kB |    %98    |
-------------------------------------------------------------------
Without patch | 292624 kB | 192512 kB     | 107380 kB |    %65    |
-------------------------------------------------------------------

 include/trace/events/huge_memory.h | 24 +++++++++++++++++++++
 mm/huge_memory.c                   | 43 ++++++++++++++++++++++++++++++++++++++
 mm/internal.h                      |  4 ++++
 mm/memory.c                        |  2 +-
 4 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index 153274c..1efc7f1 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -136,6 +136,30 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
 		__print_symbolic(__entry->status, SCAN_STATUS))
 );
 
+TRACE_EVENT(mm_collapse_huge_page_swapin,
+
+	TP_PROTO(struct mm_struct *mm, int swapped_in, int ret),
+
+	TP_ARGS(mm, swapped_in, ret),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(int, swapped_in)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->swapped_in = swapped_in;
+		__entry->ret = ret;
+	),
+
+	TP_printk("mm=%p, swapped_in=%d, ret=%d",
+		__entry->mm,
+		__entry->swapped_in,
+		__entry->ret)
+);
+
 #endif /* __HUGE_MEMORY_H */
 #include <trace/define_trace.h>
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 049b0db..e83f20a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2584,6 +2584,47 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	return true;
 }
 
+/*
+ * Bring missing pages in from swap, to complete THP collapse.
+ * Only done if khugepaged_scan_pmd believes it is worthwhile.
+ *
+ * Called and returns without pte mapped or spinlocks held,
+ * but with mmap_sem held to protect against vma changes.
+ */
+
+static void __collapse_huge_page_swapin(struct mm_struct *mm,
+					struct vm_area_struct *vma,
+					unsigned long address, pmd_t *pmd,
+					pte_t *pte)
+{
+	unsigned long _address;
+	pte_t pteval = *pte;
+	int swapped_in = 0, ret = 0;
+
+	pte = pte_offset_map(pmd, address);
+	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
+	     pte++, _address += PAGE_SIZE) {
+		pteval = *pte;
+		if (!is_swap_pte(pteval))
+			continue;
+		swapped_in++;
+		ret = do_swap_page(mm, vma, _address, pte, pmd,
+				   FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT,
+				   pteval);
+		if (ret & VM_FAULT_ERROR) {
+			trace_mm_collapse_huge_page_swapin(mm, swapped_in, 0);
+			return;
+		}
+		/* pte is unmapped now, we need to map it */
+		pte = pte_offset_map(pmd, _address);
+	}
+	pte--;
+	pte_unmap(pte);
+	trace_mm_collapse_huge_page_swapin(mm, swapped_in, 1);
+}
+
+
+
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
@@ -2655,6 +2696,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	anon_vma_lock_write(vma->anon_vma);
 
+	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
+
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
diff --git a/mm/internal.h b/mm/internal.h
index bc0fa9a..867ea14 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -14,6 +14,10 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 
+extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *page_table, pmd_t *pmd,
+			unsigned int flags, pte_t orig_pte);
+
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
diff --git a/mm/memory.c b/mm/memory.c
index 9cb2747..caecc64 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2441,7 +2441,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
+int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
