Date: Tue, 8 Nov 2005 15:25:58 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH 2/2] Fold numa_maps into mempolicy.c
In-Reply-To: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

- Use the page table iterator in mempolicy.c to gather the statistics.

- Improve the code and fix some comments.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-mm1.orig/mm/mempolicy.c	2005-11-08 14:59:31.000000000 -0800
+++ linux-2.6.14-mm1/mm/mempolicy.c	2005-11-08 15:16:33.000000000 -0800
@@ -84,12 +84,15 @@
 #include <linux/compat.h>
 #include <linux/mempolicy.h>
 #include <linux/swap.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
 #include <asm/tlbflush.h>
 #include <asm/uaccess.h>
 
 /* Internal flags */
 #define MPOL_MF_DISCONTIG_OK (1<<20)	/* Skip checks for continuous vmas */
 #define MPOL_MF_INVERT (1<<21)		/* Invert check for nodemask */
+#define MPOL_MF_STATS (1<<22)		/* Gather statistics */
 
 static kmem_cache_t *policy_cache;
 static kmem_cache_t *sn_cache;
@@ -235,6 +238,8 @@ static void migrate_page_add(struct vm_a
 	}
 }
 
+static void gather_stats(struct page *, void *);
+
 /* Scan through pages checking if pages follow certain conditions. */
 static int check_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end,
@@ -263,7 +268,9 @@ static int check_pte_range(struct vm_are
 		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
 			continue;
 
-		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+		if (flags & MPOL_MF_STATS)
+			gather_stats(page, private);
+		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(vma, page, private, flags);
 		else
 			break;
@@ -932,9 +939,15 @@ asmlinkage long compat_sys_mbind(compat_
 
 #endif
 
-/* Return effective policy for a VMA */
-struct mempolicy *
-get_vma_policy(struct task_struct *task, struct vm_area_struct *vma, unsigned long addr)
+/*
+ * Return effective policy for a VMA
+ *
+ * Must hold mmap_sem until memory pointer is no longer in use
+ * or be called from the current task.
+ */
+struct mempolicy *get_vma_policy(struct task_struct *task,
+				 struct vm_area_struct *vma,
+				 unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
 
@@ -1504,3 +1517,132 @@ void numa_policy_rebind(const nodemask_t
 	}
 	rebind_policy(current->mempolicy, old, new);
 }
+
+/*
+ * Display pages allocated per node and memory policy via /proc.
+ */
+
+static const char *policy_types[] = { "default", "prefer", "bind",
+				      "interleave" };
+
+/*
+ * Convert a mempolicy into a string.
+ * Returns the number of characters in buffer (if positive)
+ * or an error (negative)
+ */
+static inline int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
+{
+	char *p = buffer;
+	int l;
+	nodemask_t nodes;
+	int mode = pol ? pol->policy : MPOL_DEFAULT;
+
+	switch (mode) {
+	case MPOL_DEFAULT:
+		nodes_clear(nodes);
+		break;
+
+	case MPOL_PREFERRED:
+		nodes_clear(nodes);
+		node_set(pol->v.preferred_node, nodes);
+		break;
+
+	case MPOL_BIND:
+		get_zonemask(pol, &nodes);
+		break;
+
+	case MPOL_INTERLEAVE:
+		nodes = pol->v.nodes;
+		break;
+
+	default:
+		BUG();
+		return -EFAULT;
+	}
+
+	l = strlen(policy_types[mode]);
+ 	if (buffer + maxlen < p + l + 1)
+ 		return -ENOSPC;
+
+	strcpy(p, policy_types[mode]);
+	p += l;
+
+	if (!nodes_empty(nodes)) {
+		if (buffer + maxlen < p + 2)
+			return -ENOSPC;
+		*p++ = '=';
+	 	p += nodelist_scnprintf(p, buffer + maxlen - p, nodes);
+	}
+	return p - buffer;
+}
+
+struct numa_maps {
+	unsigned long pages;
+	unsigned long anon;
+	unsigned long mapped;
+	unsigned long mapcount_max;
+	unsigned long node[MAX_NUMNODES];
+};
+
+static void gather_stats(struct page *page, void *private)
+{
+	struct numa_maps *md = private;
+	int count = page_mapcount(page);
+
+	if (count)
+		md->mapped++;
+
+	if (count > md->mapcount_max)
+		md->mapcount_max = count;
+
+	md->pages++;
+
+	if (PageAnon(page))
+		md->anon++;
+
+	md->node[page_to_nid(page)]++;
+	cond_resched();
+}
+
+int show_numa_map(struct seq_file *m, void *v)
+{
+	struct task_struct *task = m->private;
+	struct vm_area_struct *vma = v;
+	struct numa_maps *md;
+	int n;
+	char buffer[50];
+
+	if (!vma->vm_mm)
+		return 0;
+
+	md = kzalloc(sizeof(struct numa_maps), GFP_KERNEL);
+	if (!md)
+		return 0;
+
+	check_pgd_range(vma, vma->vm_start, vma->vm_end,
+		    &node_online_map, MPOL_MF_STATS, md);
+
+	if (md->pages) {
+		mpol_to_str(buffer, sizeof(buffer),
+			    get_vma_policy(task, vma, vma->vm_start));
+
+		seq_printf(m, "%08lx %s pages=%lu mapped=%lu maxref=%lu",
+			   vma->vm_start, buffer, md->pages,
+			   md->mapped, md->mapcount_max);
+
+		if (md->anon)
+			seq_printf(m," anon=%lu",md->anon);
+
+		for_each_online_node(n)
+			if (md->node[n])
+				seq_printf(m, " N%d=%lu", n, md->node[n]);
+
+		seq_putc(m, '\n');
+	}
+	kfree(md);
+
+	if (m->count < m->size)
+		m->version = (vma != get_gate_vma(task)) ? vma->vm_start : 0;
+	return 0;
+}
+
Index: linux-2.6.14-mm1/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.14-mm1.orig/fs/proc/task_mmu.c	2005-11-07 11:48:07.000000000 -0800
+++ linux-2.6.14-mm1/fs/proc/task_mmu.c	2005-11-08 15:15:47.000000000 -0800
@@ -390,130 +390,12 @@ struct seq_operations proc_pid_smaps_op 
 };
 
 #ifdef CONFIG_NUMA
-
-struct numa_maps {
-	unsigned long pages;
-	unsigned long anon;
-	unsigned long mapped;
-	unsigned long mapcount_max;
-	unsigned long node[MAX_NUMNODES];
-};
-
-/*
- * Calculate numa node maps for a vma
- */
-static struct numa_maps *get_numa_maps(const struct vm_area_struct *vma)
-{
-	struct page *page;
-	unsigned long vaddr;
-	struct mm_struct *mm = vma->vm_mm;
-	int i;
-	struct numa_maps *md = kmalloc(sizeof(struct numa_maps), GFP_KERNEL);
-
-	if (!md)
-		return NULL;
-	md->pages = 0;
-	md->anon = 0;
-	md->mapped = 0;
-	md->mapcount_max = 0;
-	for_each_node(i)
-		md->node[i] =0;
-
- 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
-		page = follow_page(mm, vaddr, 0);
-		if (page) {
-			int count = page_mapcount(page);
-
-			if (count)
-				md->mapped++;
-			if (count > md->mapcount_max)
-				md->mapcount_max = count;
-			md->pages++;
-			if (PageAnon(page))
-				md->anon++;
-			md->node[page_to_nid(page)]++;
-		}
-		cond_resched();
-	}
-	return md;
-}
-
-static int show_numa_map(struct seq_file *m, void *v)
-{
-	struct task_struct *task = m->private;
-	struct vm_area_struct *vma = v;
-	struct mempolicy *pol;
-	struct numa_maps *md;
-	struct zone **z;
-	int n;
-	int first;
-
-	if (!vma->vm_mm)
-		return 0;
-
-	md = get_numa_maps(vma);
-	if (!md)
-		return 0;
-
-	seq_printf(m, "%08lx", vma->vm_start);
-	pol = get_vma_policy(task, vma, vma->vm_start);
-	/* Print policy */
-	switch (pol->policy) {
-	case MPOL_PREFERRED:
-		seq_printf(m, " prefer=%d", pol->v.preferred_node);
-		break;
-	case MPOL_BIND:
-		seq_printf(m, " bind={");
-		first = 1;
-		for (z = pol->v.zonelist->zones; *z; z++) {
-
-			if (!first)
-				seq_putc(m, ',');
-			else
-				first = 0;
-			seq_printf(m, "%d/%s", (*z)->zone_pgdat->node_id,
-					(*z)->name);
-		}
-		seq_putc(m, '}');
-		break;
-	case MPOL_INTERLEAVE:
-		seq_printf(m, " interleave={");
-		first = 1;
-		for_each_node(n) {
-			if (node_isset(n, pol->v.nodes)) {
-				if (!first)
-					seq_putc(m,',');
-				else
-					first = 0;
-				seq_printf(m, "%d",n);
-			}
-		}
-		seq_putc(m, '}');
-		break;
-	default:
-		seq_printf(m," default");
-		break;
-	}
-	seq_printf(m, " MaxRef=%lu Pages=%lu Mapped=%lu",
-			md->mapcount_max, md->pages, md->mapped);
-	if (md->anon)
-		seq_printf(m," Anon=%lu",md->anon);
-
-	for_each_online_node(n) {
-		if (md->node[n])
-			seq_printf(m, " N%d=%lu", n, md->node[n]);
-	}
-	seq_putc(m, '\n');
-	kfree(md);
-	if (m->count < m->size)  /* vma is copied successfully */
-		m->version = (vma != get_gate_vma(task)) ? vma->vm_start : 0;
-	return 0;
-}
+extern int show_numa_map(struct seq_file *m, void *v);
 
 struct seq_operations proc_pid_numa_maps_op = {
-	.start	= m_start,
-	.next	= m_next,
-	.stop	= m_stop,
-	.show	= show_numa_map
+        .start  = m_start,
+        .next   = m_next,
+        .stop   = m_stop,
+        .show   = show_numa_map
 };
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
