Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8E57B6B0022
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:36:42 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 2/8] mm: use walk_page_range() instead of custom page table walking code
Date: Wed, 27 Apr 2011 19:35:43 -0400
Message-Id: <1303947349-3620-3-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In the specific case of show_numa_map(), the custom page table walking
logic implemented in mempolicy.c does not provide any special service
beyond that provided by walk_page_range().

Also, converting show_numa_map() to use the generic routine decouples
the function from mempolicy.c, allowing it to be moved out of the mm
subsystem and into fs/proc.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/mempolicy.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 46 insertions(+), 7 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 5bfb03e..dfe27e3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2568,6 +2568,22 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
 	md->node[page_to_nid(page)]++;
 }
 
+static int gather_pte_stats(pte_t *pte, unsigned long addr,
+		unsigned long pte_size, struct mm_walk *walk)
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
 #ifdef CONFIG_HUGETLB_PAGE
 static void check_huge_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end,
@@ -2597,12 +2613,35 @@ static void check_huge_range(struct vm_area_struct *vma,
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
@@ -2615,6 +2654,7 @@ int show_numa_map(struct seq_file *m, void *v)
 	struct numa_maps *md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
+	struct mm_walk walk = {};
 	struct mempolicy *pol;
 	int n;
 	char buffer[50];
@@ -2626,6 +2666,11 @@ int show_numa_map(struct seq_file *m, void *v)
 	if (!md)
 		return 0;
 
+	walk.hugetlb_entry = gather_hugetbl_stats;
+	walk.pte_entry = gather_pte_stats;
+	walk.private = md;
+	walk.mm = mm;
+
 	pol = get_vma_policy(priv->task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 	mpol_cond_put(pol);
@@ -2642,13 +2687,7 @@ int show_numa_map(struct seq_file *m, void *v)
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
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
