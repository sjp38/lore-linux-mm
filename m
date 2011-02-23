Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 42CC58D0040
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 20:52:38 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 8/8] Add VM counters for transparent hugepages
Date: Tue, 22 Feb 2011 17:52:02 -0800
Message-Id: <1298425922-23630-9-git-send-email-andi@firstfloor.org>
In-Reply-To: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, aarcange@redhat.com

From: Andi Kleen <ak@linux.intel.com>

I found it difficult to make sense of transparent huge pages without
having any counters for its actions. Add some counters to vmstat
for allocation of transparent hugepages and fallback to smaller
pages.

Optional patch, but useful for development and understanding the system.

Cc: aarcange@redhat.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/vmstat.h |    7 +++++++
 mm/huge_memory.c       |   13 ++++++++++---
 mm/vmstat.c            |    8 ++++++++
 3 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 9b5c63d..7794d1a7 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -58,6 +58,13 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	        THP_DIRECT_ALLOC,
+		THP_DAEMON_ALLOC,	
+		THP_DIRECT_FALLBACK,	
+		THP_DAEMON_ALLOC_FAILED,
+		THP_SPLIT,
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 877756e..4ef8c32 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -680,13 +680,15 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 					  vma, haddr, numa_node_id(), 0);
-		if (unlikely(!page))
+		if (unlikely(!page)) {
+			count_vm_event(THP_DIRECT_FALLBACK);
 			goto out;
+		}
 		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 			put_page(page);
 			goto out;
 		}
-
+		count_vm_event(THP_DIRECT_ALLOC);
 		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
 	}
 out:
@@ -909,6 +911,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		new_page = NULL;
 
 	if (unlikely(!new_page)) {
+		count_vm_event(THP_DIRECT_FALLBACK);
 		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
 						   pmd, orig_pmd, page, haddr);
 		put_page(page);
@@ -921,7 +924,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		ret |= VM_FAULT_OOM;
 		goto out;
 	}
-
+	count_vm_event(THP_DIRECT_ALLOC);
 	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
@@ -1780,6 +1783,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 				      node, __GFP_OTHER_NODE);
 	if (unlikely(!new_page)) {
 		up_read(&mm->mmap_sem);
+		count_vm_event(THP_DAEMON_ALLOC_FAILED);
 		*hpage = ERR_PTR(-ENOMEM);
 		return;
 	}
@@ -2286,6 +2290,9 @@ void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
 		spin_unlock(&mm->page_table_lock);
 		return;
 	}
+
+	count_vm_event(THP_SPLIT);
+
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2b461ed..f3ab7e9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -946,6 +946,14 @@ static const char * const vmstat_text[] = {
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
 #endif
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"thp_direct_alloc",
+	"thp_daemon_alloc",
+	"thp_direct_fallback",
+	"thp_daemon_alloc_failed",
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
