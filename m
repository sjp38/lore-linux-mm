Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D6E0A90010D
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:30 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 7/9] mm: proc: move show_numa_map() to fs/proc/task_mmu.c
Date: Sun, 15 May 2011 18:20:27 -0400
Message-Id: <1305498029-11677-8-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

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
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 fs/proc/task_mmu.c |  184 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 mm/mempolicy.c     |  183 ---------------------------------------------------
 2 files changed, 182 insertions(+), 185 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index cd58813..fbe5ed9 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -859,8 +859,188 @@ const struct file_operations proc_pagemap_operations = {
 #endif /* CONFIG_PROC_PAGE_MONITOR */
 
 #ifdef CONFIG_NUMA
-extern int show_numa_map(struct seq_file *m, void *v);
 
+struct numa_maps {
+	struct vm_area_struct *vma;
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
+	md->vma = vma;
+
+	walk.hugetlb_entry = gather_hugetbl_stats;
+	walk.pmd_entry = gather_pte_stats;
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
@@ -879,4 +1059,4 @@ const struct file_operations proc_numa_maps_operations = {
 	.llseek		= seq_lseek,
 	.release	= seq_release_private,
 };
-#endif
+#endif /* CONFIG_NUMA */
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 231efc8..8b57173 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2541,186 +2541,3 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 	}
 	return p - buffer;
 }
-
-struct numa_maps {
-	struct vm_area_struct *vma;
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
-static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
-		unsigned long end, struct mm_walk *walk)
-{
-	struct numa_maps *md;
-	spinlock_t *ptl;
-	pte_t *orig_pte;
-	pte_t *pte;
-
-	md = walk->private;
-	orig_pte = pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
-	do {
-		struct page *page;
-		int nid;
-
-		if (!pte_present(*pte))
-			continue;
-
-		page = vm_normal_page(md->vma, addr, *pte);
-		if (!page)
-			continue;
-
-		if (PageReserved(page))
-			continue;
-
-		nid = page_to_nid(page);
-		if (!node_isset(nid, node_states[N_HIGH_MEMORY]))
-			continue;
-
-		gather_stats(page, md, pte_dirty(*pte));
-
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(orig_pte, ptl);
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
-	md->vma = vma;
-
-	walk.hugetlb_entry = gather_hugetbl_stats;
-	walk.pmd_entry = gather_pte_stats;
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
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
