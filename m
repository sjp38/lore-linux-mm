Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 85B7B8D003A
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 15:00:32 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 8/8] Add VM counters for transparent hugepages
Date: Thu,  3 Mar 2011 11:59:51 -0800
Message-Id: <1299182391-6061-9-git-send-email-andi@firstfloor.org>
In-Reply-To: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
References: <1299182391-6061-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

I found it difficult to make sense of transparent huge pages without
having any counters for its actions. Add some counters to vmstat
for allocation of transparent hugepages and fallback to smaller
pages.

Optional patch, but useful for development and understanding the system.

Contains improvements from Andrea Arcangeli and Johannes Weiner

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/vmstat.h |    7 +++++++
 mm/huge_memory.c       |   25 +++++++++++++++++++++----
 mm/vmstat.c            |    8 ++++++++
 3 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9b5c63d..074e8fd 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -58,6 +58,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	        THP_FAULT_ALLOC,
+		THP_FAULT_FALLBACK,
+		THP_COLLAPSE_ALLOC,
+		THP_COLLAPSE_ALLOC_FAILED,
+		THP_SPLIT,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8c6c4a7..f13a9a3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -680,8 +680,11 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 					  vma, haddr, numa_node_id(), 0);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			count_vm_event(THP_FAULT_FALLBACK);
 			goto out;
+		}
+		count_vm_event(THP_FAULT_ALLOC);
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 			put_page(page);
 			goto out;
@@ -909,11 +912,13 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
+		count_vm_event(THP_FAULT_FALLBACK);
 		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 						   pmd, orig_pmd, page, haddr);
 		put_page(page);
 		goto out;
 	}
+	count_vm_event(THP_FAULT_ALLOC);
 
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		put_page(new_page);
@@ -1390,6 +1395,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(!PageSwapBacked(page));
 	__split_huge_page(page, anon_vma);
+	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
 out_unlock:
@@ -1780,9 +1786,11 @@ static void collapse_huge_page(struct mm_struct *mm,
 				      node, __GFP_OTHER_NODE);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
+		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
+	count_vm_event(THP_COLLAPSE_ALLOC);
 #endif
 	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
 		up_read(&mm->mmap_sem);
@@ -2147,8 +2155,11 @@ static void khugepaged_do_scan(struct page **hpage)
 #ifndef CONFIG_NUMA
 		if (!*hpage) {
 			*hpage = alloc_hugepage(khugepaged_defrag());
-			if (unlikely(!*hpage))
+			if (unlikely(!*hpage)) {
+				count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 				break;
+			}
+			count_vm_event(THP_COLLAPSE_ALLOC);
 		}
 #else
 		if (IS_ERR(*hpage))
@@ -2188,8 +2199,11 @@ static struct page *khugepaged_alloc_hugepage(void)
 
 	do {
 		hpage = alloc_hugepage(khugepaged_defrag());
-		if (!hpage)
+		if (!hpage) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 			khugepaged_alloc_sleep();
+		} else
+			count_vm_event(THP_COLLAPSE_ALLOC);
 	} while (unlikely(!hpage) &&
 		 likely(khugepaged_enabled()));
 	return hpage;
@@ -2206,8 +2220,11 @@ static void khugepaged_loop(void)
 	while (likely(khugepaged_enabled())) {
 #ifndef CONFIG_NUMA
 		hpage = khugepaged_alloc_hugepage();
-		if (unlikely(!hpage))
+		if (unlikely(!hpage)) {
+			count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
 			break;
+		}
+		count_vm_event(THP_COLLAPSE_ALLOC);
 #else
 		if (IS_ERR(hpage)) {
 			khugepaged_alloc_sleep();
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2b461ed..7b5a6f2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -946,6 +946,14 @@ static const char * const vmstat_text[] = {
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
 #endif
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"thp_fault_alloc",
+	"thp_fault_fallback",
+	"thp_collapse_alloc",
+	"thp_collapse_alloc_failed",
+	"thp_split",
+#endif
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
