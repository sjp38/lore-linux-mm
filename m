Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 145216B0257
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 16:52:14 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so759242wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:13 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id i19si75643wjr.127.2015.09.03.13.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 13:52:12 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so2862342wic.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:12 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RESEND RFC v4 3/3] mm: make swapin readahead to improve thp collapse rate
Date: Thu,  3 Sep 2015 23:51:48 +0300
Message-Id: <1441313508-4276-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
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
800MB of memory, writes to it, and then sleeps. I force
the system to swap out all. Afterwards, the test program
touches the area by writing, it skips a page in each
20 pages of the area.

Without the patch, system did not swap in readahead.
THP rate was %47 of the program of the memory, it
did not change over time.

With this patch, after 10 minutes of waiting khugepaged had
collapsed %90 of the program's memory.

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

			After swapped out
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 253720 kB | 251904 kB     | 546284 kB |    %99    |
-------------------------------------------------------------------
Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 533532 kB | 528384 kB     | 266472 kB |    %90    |
-------------------------------------------------------------------
Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
-------------------------------------------------------------------


 include/linux/mm.h                 |  4 ++++
 include/trace/events/huge_memory.h | 24 +++++++++++++++++++++
 mm/huge_memory.c                   | 43 ++++++++++++++++++++++++++++++++++++++
 mm/memory.c                        |  2 +-
 4 files changed, 72 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bf6f117..f28d98a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -29,6 +29,10 @@ struct user_struct;
 struct writeback_control;
 struct bdi_writeback;
 
+extern int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *page_table, pmd_t *pmd,
+			unsigned int flags, pte_t orig_pte);
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES	/* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
 
diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index c2112fd..e530210 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -97,6 +97,30 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
 		khugepaged_status_string[__entry->status])
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
index cb9ab46..f420ef8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2529,6 +2529,47 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
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
@@ -2600,6 +2641,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 
 	anon_vma_lock_write(vma->anon_vma);
 
+	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
+
 	pte = pte_offset_map(pmd, address);
 	pte_ptl = pte_lockptr(mm, pmd);
 
diff --git a/mm/memory.c b/mm/memory.c
index 388dcf9..d3a446c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2442,7 +2442,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
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
