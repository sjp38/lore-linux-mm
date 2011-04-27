Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EE3EC6B0022
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:37:47 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 6/8] mm: proc: move show_numa_map() to fs/proc/task_mmu.c
Date: Wed, 27 Apr 2011 19:35:47 -0400
Message-Id: <1303947349-3620-7-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Moving show_numa_map() from mempolicy.c to task_mmu.c solves several
issues.

  - Having the show() operation "miles away" from the corresponding
    seq_file iteration operations is a maintenance burden.

  - The need to export ad hoc info like struct proc_maps_private is
    eliminated.

  - The implementation of show_numa_map() can be improved in a simple
    manner by cooperating with the other seq_file operations (start,
    stop, etc) -- something that would be messy to do without this
    change.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 fs/proc/task_mmu.c |  170 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/mempolicy.c     |  168 ---------------------------------------------------
 2 files changed, 168 insertions(+), 170 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2e7addf..9f069d2 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -856,8 +856,174 @@ const struct file_operations proc_pagemap_operations = {
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA
-extern int show_numa_map(struct seq_file *m, void *v);
 
+struct numa_maps {
+	unsigned long pages;
+	unsigned long anon;
+	unsigned long active;
+	unsigned long writeback;
+	unsigned long mapcount_max;
+	unsigned long dirty;
+	unsigned long swapcache;
+	unsigned long node[MAX_NUMNODES];
+};
+
+static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty)
+{
+	int count = page_mapcount(page);
+
+	md->pages++;
+	if (pte_dirty || PageDirty(page))
+		md->dirty++;
+
+	if (PageSwapCache(page))
+		md->swapcache++;
+
+	if (PageActive(page) || PageUnevictable(page))
+		md->active++;
+
+	if (PageWriteback(page))
+		md->writeback++;
+
+	if (PageAnon(page))
+		md->anon++;
+
+	if (count > md->mapcount_max)
+		md->mapcount_max = count;
+
+	md->node[page_to_nid(page)]++;
+}
+
+static int gather_pte_stats(pte_t *pte, unsigned long addr,
+		unsigned long pte_size, struct mm_walk *walk)
+{
+	struct numa_maps *md;
+	struct page *page;
+	int nid;
+
+	if (pte_none(*pte))
+		return 0;
+
+	page = pte_page(*pte);
+	if (!page)
+		return 0;
+
+	nid = page_to_nid(page);
+	if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
+		return 0;
+
+	md = walk->private;
+	gather_stats(page, md, pte_dirty(*pte));
+	return 0;
+}
+
+#ifdef CONFIG_HUGETLB_PAGE
+static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+		unsigned long addr, unsigned long end, struct mm_walk *walk)
+{
+	struct numa_maps *md;
+	struct page *page;
+
+	if (pte_none(*pte))
+		return 0;
+
+	page = pte_page(*pte);
+	if (!page)
+		return 0;
+
+	md = walk->private;
+	gather_stats(page, md, pte_dirty(*pte));
+	return 0;
+}
+
+#else
+static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
+		unsigned long addr, unsigned long end, struct mm_walk *walk)
+{
+	return 0;
+}
+#endif
+
+/*
+ * Display pages allocated per node and memory policy via /proc.
+ */
+static int show_numa_map(struct seq_file *m, void *v)
+{
+	struct proc_maps_private *priv = m->private;
+	struct vm_area_struct *vma = v;
+	struct numa_maps *md;
+	struct file *file = vma->vm_file;
+	struct mm_struct *mm = vma->vm_mm;
+	struct mm_walk walk = {};
+	struct mempolicy *pol;
+	int n;
+	char buffer[50];
+
+	if (!mm)
+		return 0;
+
+	md = kzalloc(sizeof(struct numa_maps), GFP_KERNEL);
+	if (!md)
+		return 0;
+
+	walk.hugetlb_entry = gather_hugetbl_stats;
+	walk.pte_entry = gather_pte_stats;
+	walk.private = md;
+	walk.mm = mm;
+
+	pol = get_vma_policy(priv->task, vma, vma->vm_start);
+	mpol_to_str(buffer, sizeof(buffer), pol, 0);
+	mpol_cond_put(pol);
+
+	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
+
+	if (file) {
+		seq_printf(m, " file=");
+		seq_path(m, &file->f_path, "\n\t= ");
+	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
+		seq_printf(m, " heap");
+	} else if (vma->vm_start <= mm->start_stack &&
+			vma->vm_end >= mm->start_stack) {
+		seq_printf(m, " stack");
+	}
+
+	walk_page_range(vma->vm_start, vma->vm_end, &walk);
+
+	if (!md->pages)
+		goto out;
+
+	if (md->anon)
+		seq_printf(m, " anon=%lu", md->anon);
+
+	if (md->dirty)
+		seq_printf(m, " dirty=%lu", md->dirty);
+
+	if (md->pages != md->anon && md->pages != md->dirty)
+		seq_printf(m, " mapped=%lu", md->pages);
+
+	if (md->mapcount_max > 1)
+		seq_printf(m, " mapmax=%lu", md->mapcount_max);
+
+	if (md->swapcache)
+		seq_printf(m, " swapcache=%lu", md->swapcache);
+
+	if (md->active < md->pages && !is_vm_hugetlb_page(vma))
+		seq_printf(m, " active=%lu", md->active);
+
+	if (md->writeback)
+		seq_printf(m, " writeback=%lu", md->writeback);
+
+	for_each_node_state(n, N_HIGH_MEMORY)
+		if (md->node[n])
+			seq_printf(m, " N%d=%lu", n, md->node[n]);
+out:
+	seq_putc(m, '\n');
+	kfree(md);
+
+	if (m->count < m->size)
+		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
+	return 0;
+}
 static const struct seq_operations proc_pid_numa_maps_op = {
         .start  = m_start,
         .next   = m_next,
@@ -876,4 +1042,4 @@ const struct file_operations proc_numa_maps_operations = {
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
 };
-#endif
+#endif /* CONFIG_NUMA */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index c5a4342..e7fb9d2 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2525,171 +2525,3 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 	}
 	return p - buffer;
 }
-
-struct numa_maps {
-	unsigned long pages;
-	unsigned long anon;
-	unsigned long active;
-	unsigned long writeback;
-	unsigned long mapcount_max;
-	unsigned long dirty;
-	unsigned long swapcache;
-	unsigned long node[MAX_NUMNODES];
-};
-
-static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty)
-{
-	int count = page_mapcount(page);
-
-	md->pages++;
-	if (pte_dirty || PageDirty(page))
-		md->dirty++;
-
-	if (PageSwapCache(page))
-		md->swapcache++;
-
-	if (PageActive(page) || PageUnevictable(page))
-		md->active++;
-
-	if (PageWriteback(page))
-		md->writeback++;
-
-	if (PageAnon(page))
-		md->anon++;
-
-	if (count > md->mapcount_max)
-		md->mapcount_max = count;
-
-	md->node[page_to_nid(page)]++;
-}
-
-static int gather_pte_stats(pte_t *pte, unsigned long addr,
-		unsigned long pte_size, struct mm_walk *walk)
-{
-	struct numa_maps *md;
-	struct page *page;
-	int nid;
-
-	if (pte_none(*pte))
-		return 0;
-
-	page = pte_page(*pte);
-	if (!page)
-		return 0;
-
-	nid = page_to_nid(page);
-	if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
-		return 0;
-
-	md = walk->private;
-	gather_stats(page, md, pte_dirty(*pte));
-	return 0;
-}
-
-#ifdef CONFIG_HUGETLB_PAGE
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
-		unsigned long addr, unsigned long end, struct mm_walk *walk)
-{
-	struct numa_maps *md;
-	struct page *page;
-
-	if (pte_none(*pte))
-		return 0;
-
-	page = pte_page(*pte);
-	if (!page)
-		return 0;
-
-	md = walk->private;
-	gather_stats(page, md, pte_dirty(*pte));
-	return 0;
-}
-
-#else
-static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
-		unsigned long addr, unsigned long end, struct mm_walk *walk)
-{
-	return 0;
-}
-#endif
-
-/*
- * Display pages allocated per node and memory policy via /proc.
- */
-int show_numa_map(struct seq_file *m, void *v)
-{
-	struct proc_maps_private *priv = m->private;
-	struct vm_area_struct *vma = v;
-	struct numa_maps *md;
-	struct file *file = vma->vm_file;
-	struct mm_struct *mm = vma->vm_mm;
-	struct mm_walk walk = {};
-	struct mempolicy *pol;
-	int n;
-	char buffer[50];
-
-	if (!mm)
-		return 0;
-
-	md = kzalloc(sizeof(struct numa_maps), GFP_KERNEL);
-	if (!md)
-		return 0;
-
-	walk.hugetlb_entry = gather_hugetbl_stats;
-	walk.pte_entry = gather_pte_stats;
-	walk.private = md;
-	walk.mm = mm;
-
-	pol = get_vma_policy(priv->task, vma, vma->vm_start);
-	mpol_to_str(buffer, sizeof(buffer), pol, 0);
-	mpol_cond_put(pol);
-
-	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
-
-	if (file) {
-		seq_printf(m, " file=");
-		seq_path(m, &file->f_path, "\n\t= ");
-	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
-		seq_printf(m, " heap");
-	} else if (vma->vm_start <= mm->start_stack &&
-			vma->vm_end >= mm->start_stack) {
-		seq_printf(m, " stack");
-	}
-
-	walk_page_range(vma->vm_start, vma->vm_end, &walk);
-
-	if (!md->pages)
-		goto out;
-
-	if (md->anon)
-		seq_printf(m," anon=%lu",md->anon);
-
-	if (md->dirty)
-		seq_printf(m," dirty=%lu",md->dirty);
-
-	if (md->pages != md->anon && md->pages != md->dirty)
-		seq_printf(m, " mapped=%lu", md->pages);
-
-	if (md->mapcount_max > 1)
-		seq_printf(m, " mapmax=%lu", md->mapcount_max);
-
-	if (md->swapcache)
-		seq_printf(m," swapcache=%lu", md->swapcache);
-
-	if (md->active < md->pages && !is_vm_hugetlb_page(vma))
-		seq_printf(m," active=%lu", md->active);
-
-	if (md->writeback)
-		seq_printf(m," writeback=%lu", md->writeback);
-
-	for_each_node_state(n, N_HIGH_MEMORY)
-		if (md->node[n])
-			seq_printf(m, " N%d=%lu", n, md->node[n]);
-out:
-	seq_putc(m, '\n');
-	kfree(md);
-
-	if (m->count < m->size)
-		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
-	return 0;
-}
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
