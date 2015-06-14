Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 44C736B0070
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 11:05:10 -0400 (EDT)
Received: by wgv5 with SMTP id 5so51726895wgv.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:09 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id s7si13629880wiw.104.2015.06.14.08.05.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 08:05:08 -0700 (PDT)
Received: by wgez8 with SMTP id z8so51803655wge.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:08 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC 3/3] mm: make swapin readahead to improve thp collapse rate
Date: Sun, 14 Jun 2015 18:04:43 +0300
Message-Id: <1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
In-Reply-To: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
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
collapsed %99 of the program's memory.

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
---
I've written down test results:

With the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:        470760 kB
AnonHugePages:    468992 kB
Swap:             329244 kB
Fraction:         %99

After swapped in:
In ten minutes:
cat /proc/pid/smaps:
Anonymous:        769208 kB
AnonHugePages:    765952 kB
Swap:              30796 kB
Fraction:         %99

Without the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:        238160 kB
AnonHugePages:    235520 kB
Swap:             561844 kB
Fraction:         %98

After swapped in:
cat /proc/pid/smaps:
In ten minutes:
Anonymous:        499956 kB
AnonHugePages:    235520 kB
Swap:             300048 kB
Fraction:         %47

 include/linux/mm.h                 |  4 ++++
 include/trace/events/huge_memory.h | 24 ++++++++++++++++++++++++
 mm/huge_memory.c                   | 35 +++++++++++++++++++++++++++++++++++
 mm/memory.c                        |  2 +-
 4 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 7f47178..f66ff8a 100644
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
index 53c9f2e..0117ab9 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -95,5 +95,29 @@ TRACE_EVENT(mm_collapse_huge_page_isolate,
 		__entry->writable)
 );
 
+TRACE_EVENT(mm_collapse_huge_page_swapin,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long vm_start, int swap_pte),
+
+	TP_ARGS(mm, vm_start, swap_pte),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long, vm_start)
+		__field(int, swap_pte)
+	),
+
+	TP_fast_assign(
+		__entry->mm = mm;
+		__entry->vm_start = vm_start;
+		__entry->swap_pte = swap_pte;
+	),
+
+	TP_printk("mm=%p, vm_start=%04lx, swap_pte=%d",
+		__entry->mm,
+		__entry->vm_start,
+		__entry->swap_pte)
+);
+
 #endif /* __HUGE_MEMORY_H */
 #include <trace/define_trace.h>
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 22bc0bf..cb3e82a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2496,6 +2496,39 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
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
+	int swap_pte = 0;
+
+	pte = pte_offset_map(pmd, address);
+	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
+	     pte++, _address += PAGE_SIZE) {
+		pteval = *pte;
+		if (is_swap_pte(pteval)) {
+			swap_pte++;
+			do_swap_page(mm, vma, _address, pte, pmd, 0x0, pteval);
+			/* pte is unmapped now, we need to map it */
+			pte = pte_offset_map(pmd, _address);
+		}
+	}
+	pte--;
+	pte_unmap(pte);
+	trace_mm_collapse_huge_page_swapin(mm, vma->vm_start, swap_pte);
+}
+
 static void collapse_huge_page(struct mm_struct *mm,
 				   unsigned long address,
 				   struct page **hpage,
@@ -2551,6 +2584,8 @@ static void collapse_huge_page(struct mm_struct *mm,
 	if (!pmd)
 		goto out;
 
+	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
+
 	anon_vma_lock_write(vma->anon_vma);
 
 	pte = pte_offset_map(pmd, address);
diff --git a/mm/memory.c b/mm/memory.c
index e1c45d0..d801dc5 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2443,7 +2443,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
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
