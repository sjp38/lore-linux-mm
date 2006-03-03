Date: Fri, 3 Mar 2006 08:58:35 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: numa_maps update
Message-ID: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, Hugh Dickins <hugh@veritas.com>, ak@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Change the format of numa_maps to be more compact and contain additional
information that is useful for managing and troubleshooting memory on a NUMA
system. Numa_maps can now also support huge pages.

Fixes:

1. More compact format. Only display fields if they contain additional
	information.

2. Always display information for all vmas. The old numa_maps did not display
	vma with no mapped entries. This was a bit confusing because page
	migration removes ptes for file backed vmas. After page migration
	a part of the vmas vanished.

3. Rename maxref to maxmap. This is the maximum mapcount of all the pages
	in a vma and may be used as an indicator as to how many processes
	may be using a certain vma.

4. Include the ability to scan over huge page vmas.

New items shown:

dirty
	Number of pages in a vma that have either the dirty bit set in the
	page_struct or in the pte.

file=<filename>
	The file backing the pages if any

stack
	Stack area

heap
	Heap area

huge
	Huge page area. The number of pages shows is the number of huge
	pages not the regular sized pages.

swapcache
	Number of pages with swap references. Must be >0 in order to
	be shown.

active
	Number of active pages. Only displayed if different from the number
	of pages mapped.

locked
	Number of pages locked. Only displayed if >0.

Sample ouput of a process using huge pages:

00000000 default
2000000000000000 default file=/lib/ld-2.3.90.so mapped=13 mapmax=30 N0=13
2000000000044000 default file=/lib/ld-2.3.90.so anon=2 dirty=2 swapcache=2 N2=2
2000000000064000 default file=/lib/librt-2.3.90.so mapped=2 active=1 N1=1 N3=1
2000000000074000 default file=/lib/librt-2.3.90.so
2000000000080000 default file=/lib/librt-2.3.90.so anon=1 swapcache=1 N2=1
2000000000084000 default
2000000000088000 default file=/lib/libc-2.3.90.so mapped=52 mapmax=32 active=48 N0=52
20000000002bc000 default file=/lib/libc-2.3.90.so
20000000002c8000 default file=/lib/libc-2.3.90.so anon=3 dirty=2 swapcache=3 active=2 N1=1 N2=2
20000000002d4000 default anon=1 swapcache=1 N1=1
20000000002d8000 default file=/lib/libpthread-2.3.90.so mapped=8 mapmax=3 active=7 N2=2 N3=6
20000000002fc000 default file=/lib/libpthread-2.3.90.so
2000000000308000 default file=/lib/libpthread-2.3.90.so anon=1 dirty=1 swapcache=1 N1=1
200000000030c000 default anon=1 dirty=1 swapcache=1 N1=1
2000000000320000 default anon=1 dirty=1 N1=1
200000000071c000 default
2000000000720000 default anon=2 dirty=2 swapcache=1 N1=1 N2=1
2000000000f1c000 default
2000000000f20000 default anon=2 dirty=2 swapcache=1 active=1 N2=1 N3=1
200000000171c000 default
2000000001720000 default anon=1 dirty=1 swapcache=1 N1=1
2000000001b20000 default
2000000001b38000 default file=/lib/libgcc_s.so.1 mapped=2 N1=2
2000000001b48000 default file=/lib/libgcc_s.so.1
2000000001b54000 default file=/lib/libgcc_s.so.1 anon=1 dirty=1 active=0 N1=1
2000000001b58000 default file=/lib/libunwind.so.7.0.0 mapped=2 active=1 N1=2
2000000001b74000 default file=/lib/libunwind.so.7.0.0
2000000001b80000 default file=/lib/libunwind.so.7.0.0
2000000001b84000 default
4000000000000000 default file=/media/huge/test9 mapped=1 N1=1
6000000000000000 default file=/media/huge/test9 anon=1 dirty=1 active=0 N1=1
6000000000004000 default heap
607fffff7fffc000 default anon=1 dirty=1 swapcache=1 N2=1
607fffffff06c000 default stack anon=1 dirty=1 active=0 N1=1
8000000060000000 default file=/mnt/huge/test0 huge dirty=3 N1=3
8000000090000000 default file=/mnt/huge/test1 huge dirty=3 N0=1 N2=2
80000000c0000000 default file=/mnt/huge/test2 huge dirty=3 N1=1 N3=2

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-mm2.orig/mm/mempolicy.c	2006-03-03 07:58:14.000000000 -0800
+++ linux-2.6.16-rc5-mm2/mm/mempolicy.c	2006-03-03 08:53:40.000000000 -0800
@@ -197,7 +197,7 @@ static struct mempolicy *mpol_new(int mo
 	return policy;
 }
 
-static void gather_stats(struct page *, void *);
+static void gather_stats(struct page *, void *, int pte_dirty);
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
 				unsigned long flags);
 
@@ -239,7 +239,7 @@ static int check_pte_range(struct vm_are
 			continue;
 
 		if (flags & MPOL_MF_STATS)
-			gather_stats(page, private);
+			gather_stats(page, private, pte_dirty(*pte));
 		else if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
 			migrate_page_add(page, private, flags);
 		else
@@ -1785,67 +1785,143 @@ static inline int mpol_to_str(char *buff
 struct numa_maps {
 	unsigned long pages;
 	unsigned long anon;
-	unsigned long mapped;
+	unsigned long active;
+	unsigned long locked;
 	unsigned long mapcount_max;
+	unsigned long dirty;
+	unsigned long swapcache;
 	unsigned long node[MAX_NUMNODES];
 };
 
-static void gather_stats(struct page *page, void *private)
+static void gather_stats(struct page *page, void *private, int pte_dirty)
 {
 	struct numa_maps *md = private;
 	int count = page_mapcount(page);
 
-	if (count)
-		md->mapped++;
+	md->pages++;
+	if (pte_dirty || PageDirty(page))
+		md->dirty++;
 
-	if (count > md->mapcount_max)
-		md->mapcount_max = count;
+	if (PageSwapCache(page))
+		md->swapcache++;
 
-	md->pages++;
+	if (PageActive(page))
+		md->active++;
+
+	if (PageLocked(page))
+		md->locked++;
 
 	if (PageAnon(page))
 		md->anon++;
 
+	if (count > md->mapcount_max)
+		md->mapcount_max = count;
+
 	md->node[page_to_nid(page)]++;
 	cond_resched();
 }
 
+static void check_huge_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end,
+		struct numa_maps *md)
+{
+	unsigned long addr;
+	struct page *page;
+
+	for (addr = start; addr < end; addr += HPAGE_SIZE) {
+		pte_t *ptep = huge_pte_offset(vma->vm_mm, addr & HPAGE_MASK);
+		pte_t pte;
+
+		if (!ptep)
+			continue;
+
+		pte = *ptep;
+		if (pte_none(pte))
+			continue;
+
+		page = pte_page(pte);
+		if (!page)
+			continue;
+
+		gather_stats(page, md, pte_dirty(*ptep));
+	}
+}
+
 int show_numa_map(struct seq_file *m, void *v)
 {
 	struct proc_maps_private *priv = m->private;
 	struct vm_area_struct *vma = v;
 	struct numa_maps *md;
+	struct file *file = vma->vm_file;
+	struct mm_struct *mm = vma->vm_mm;
 	int n;
 	char buffer[50];
 
-	if (!vma->vm_mm)
+	if (!mm)
 		return 0;
 
 	md = kzalloc(sizeof(struct numa_maps), GFP_KERNEL);
 	if (!md)
 		return 0;
 
-	if (!is_vm_hugetlb_page(vma))
+	mpol_to_str(buffer, sizeof(buffer),
+			get_vma_policy(priv->task, vma, vma->vm_start));
+
+	seq_printf(m, "%08lx %s", vma->vm_start, buffer);
+
+	if (file) {
+
+		seq_printf(m, " file=");
+		seq_path(m, file->f_vfsmnt, file->f_dentry, "\n\t");
+
+	} else if (vma->vm_start <= mm->brk &&
+		   vma->vm_end >= mm->start_brk)
+
+			seq_printf(m, " heap");
+
+	else if (vma->vm_start <= mm->start_stack &&
+		vma->vm_end >= mm->start_stack)
+
+			seq_printf(m, " stack");
+
+	if (is_vm_hugetlb_page(vma)) {
+
+		check_huge_range(vma, vma->vm_start, vma->vm_end, md);
+		seq_printf(m, " huge");
+
+	} else
 		check_pgd_range(vma, vma->vm_start, vma->vm_end,
 		    &node_online_map, MPOL_MF_STATS, md);
 
-	if (md->pages) {
-		mpol_to_str(buffer, sizeof(buffer),
-			    get_vma_policy(priv->task, vma, vma->vm_start));
-
-		seq_printf(m, "%08lx %s pages=%lu mapped=%lu maxref=%lu",
-			   vma->vm_start, buffer, md->pages,
-			   md->mapped, md->mapcount_max);
-
-		if (md->anon)
-			seq_printf(m," anon=%lu",md->anon);
-
-		for_each_online_node(n)
-			if (md->node[n])
-				seq_printf(m, " N%d=%lu", n, md->node[n]);
+	if (!md->pages)
+		goto out;
 
-		seq_putc(m, '\n');
-	}
+	if (md->anon)
+		seq_printf(m," anon=%lu",md->anon);
+
+	if (md->dirty)
+		seq_printf(m," dirty=%lu",md->dirty);
+
+	if (md->pages != md->anon && md->pages != md->dirty)
+		seq_printf(m, " mapped=%lu", md->pages);
+
+	if (md->mapcount_max > 1)
+		seq_printf(m, " mapmax=%lu", md->mapcount_max);
+
+	if (md->swapcache)
+		seq_printf(m," swapcache=%lu", md->swapcache);
+
+	if (md->active < md->pages && !is_vm_hugetlb_page(vma))
+		seq_printf(m," active=%lu", md->active);
+
+	if (md->locked)
+		seq_printf(m," locked=%lu", md->locked);
+
+	for_each_online_node(n)
+		if (md->node[n])
+			seq_printf(m, " N%d=%lu", n, md->node[n]);
+out:
+	seq_putc(m, '\n');
 	kfree(md);
 
 	if (m->count < m->size)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
