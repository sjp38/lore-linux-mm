Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CDFA090010B
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:00 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 2/9] mm: use walk_page_range() instead of custom page table walking code
Date: Sun, 15 May 2011 18:20:22 -0400
Message-Id: <1305498029-11677-3-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

Converting show_numa_map() to use the generic routine decouples
the function from mempolicy.c, allowing it to be moved out of the mm
subsystem and into fs/proc.

Also, include KSM pages in /proc/pid/numa_maps statistics.  The pagewalk
logic implemented by check_pte_range() failed to account for such pages
as they were not applicable to the page migration case.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/mempolicy.c |   75 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 68 insertions(+), 7 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6cc997d..c894671 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2547,6 +2547,7 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 }
 
 struct numa_maps {
+	struct vm_area_struct *vma;
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
@@ -2584,6 +2585,41 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
 	md->node[page_to_nid(page)]++;
 }
 
+static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
+		unsigned long end, struct mm_walk *walk)
+{
+	struct numa_maps *md;
+	spinlock_t *ptl;
+	pte_t *orig_pte;
+	pte_t *pte;
+
+	md = walk->private;
+	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
+	do {
+		struct page *page;
+		int nid;
+
+		if (!pte_present(*pte))
+			continue;
+
+		page = vm_normal_page(md->vma, addr, *pte);
+		if (!page)
+			continue;
+
+		if (PageReserved(page))
+			continue;
+
+		nid = page_to_nid(page);
+		if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
+			continue;
+
+		gather_stats(page, md, pte_dirty(*pte));
+
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(orig_pte, ptl);
+	return 0;
+}
+
 #ifdef CONFIG_HUGETLB_PAGE
 static void check_huge_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
@@ -2613,12 +2649,35 @@ static void check_huge_range(struct vm_area_struct *vma,
 		gather_stats(page, md, pte_dirty(*ptep));
 	}
 }
+
+static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+		unsigned long addr, unsigned long end, struct mm_walk *walk)
+{
+	struct page *page;
+
+	if (pte_none(*pte))
+		return 0;
+
+	page = pte_page(*pte);
+	if (!page)
+		return 0;
+
+	gather_stats(page, walk->private, pte_dirty(*pte));
+	return 0;
+}
+
 #else
 static inline void check_huge_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
 		struct numa_maps *md)
 {
 }
+
+static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+		unsigned long addr, unsigned long end, struct mm_walk *walk)
+{
+	return 0;
+}
 #endif
 
 /*
@@ -2631,6 +2690,7 @@ int show_numa_map(struct seq_file *m, void *v)
 	struct numa_maps *md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
+	struct mm_walk walk = {};
 	struct mempolicy *pol;
 	int n;
 	char buffer[50];
@@ -2642,6 +2702,13 @@ int show_numa_map(struct seq_file *m, void *v)
 	if (!md)
 		return 0;
 
+	md->vma = vma;
+
+	walk.hugetlb_entry = gather_hugetbl_stats;
+	walk.pmd_entry = gather_pte_stats;
+	walk.private = md;
+	walk.mm = mm;
+
 	pol = get_vma_policy(priv->task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 	mpol_cond_put(pol);
@@ -2658,13 +2725,7 @@ int show_numa_map(struct seq_file *m, void *v)
 		seq_printf(m, " stack");
 	}
 
-	if (is_vm_hugetlb_page(vma)) {
-		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
-		seq_printf(m, " huge");
-	} else {
-		check_pgd_range(vma, vma->vm_start, vma->vm_end,
-			&node_states[N_HIGH_MEMORY], MPOL_MF_STATS, md);
-	}
+	walk_page_range(vma->vm_start, vma->vm_end, &walk);
 
 	if (!md->pages)
 		goto out;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
