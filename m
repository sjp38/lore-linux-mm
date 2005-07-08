Date: Fri, 8 Jul 2005 14:11:55 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [NUMA] /proc/<pid>/numa_maps to show on which nodes pages reside
Message-ID: <Pine.LNX.4.62.0507081410520.16934@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

I inherited a large code base from Ray for page migration. There was a
small patch in there that I find to be very useful since it allows the display
of the locality of the pages in use by a process. I reworked that patch and came
up with a /proc/<pid>/numa_maps that gives more information about the vma's of
a process. numa_maps is indexes by the start address found in /proc/<pid>/maps.
F.e. with this patch you can see the page use of the "getty" process:

margin:/proc/12008 # cat maps
00000000-00004000 r--p 00000000 00:00 0
2000000000000000-200000000002c000 r-xp 00000000 08:04 516                /lib/ld-2.3.3.so
2000000000038000-2000000000040000 rw-p 00028000 08:04 516                /lib/ld-2.3.3.so
2000000000040000-2000000000044000 rw-p 2000000000040000 00:00 0
2000000000058000-2000000000260000 r-xp 00000000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000260000-2000000000268000 ---p 00208000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000268000-2000000000274000 rw-p 00200000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000274000-2000000000280000 rw-p 2000000000274000 00:00 0
2000000000280000-20000000002b4000 r--p 00000000 08:04 9126923            /usr/lib/locale/en_US.utf8/LC_CTYPE
2000000000300000-2000000000308000 r--s 00000000 08:04 60071467           /usr/lib/gconv/gconv-modules.cache
2000000000318000-2000000000328000 rw-p 2000000000318000 00:00 0
4000000000000000-4000000000008000 r-xp 00000000 08:04 29576399           /sbin/mingetty
6000000000004000-6000000000008000 rw-p 00004000 08:04 29576399           /sbin/mingetty
6000000000008000-600000000002c000 rw-p 6000000000008000 00:00 0          [heap]
60000fff7fffc000-60000fff80000000 rw-p 60000fff7fffc000 00:00 0
60000ffffff44000-60000ffffff98000 rw-p 60000ffffff44000 00:00 0          [stack]
a000000000000000-a000000000020000 ---p 00000000 00:00 0                  [vdso]

cat numa_maps
2000000000000000 default MaxRef=43 Pages=11 Mapped=11 N0=4 N1=3 N2=2 N3=2
2000000000038000 default MaxRef=1 Pages=2 Mapped=2 Anon=2 N0=2
2000000000040000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N0=1
2000000000058000 default MaxRef=43 Pages=61 Mapped=61 N0=14 N1=15 N2=16 N3=16
2000000000268000 default MaxRef=1 Pages=2 Mapped=2 Anon=2 N0=2
2000000000274000 default MaxRef=1 Pages=3 Mapped=3 Anon=3 N0=3
2000000000280000 default MaxRef=8 Pages=3 Mapped=3 N0=3
2000000000300000 default MaxRef=8 Pages=2 Mapped=2 N0=2
2000000000318000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N2=1
4000000000000000 default MaxRef=6 Pages=2 Mapped=2 N1=2
6000000000004000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N0=1
6000000000008000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N0=1
60000fff7fffc000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N0=1
60000ffffff44000 default MaxRef=1 Pages=1 Mapped=1 Anon=1 N0=1

getty uses ld.so. The first vma is the code segment which is used by 43 other processes and the
pages are evenly distributed over the 4 nodes.

The second vma is the process specific data portion for ld.so. This is only one page.

The display format is:

<startaddress>	 Links to information in /proc/<pid>/map
<memory policy>  This can be "default" "interleave={}", "prefer=<node>" or "bind={<zones>}"
MaxRef=		<maximum reference to a page in this vma>
Pages=		<Nr of pages in use>
Mapped=		<Nr of pages with mapcount >
Anon=		<nr of anonymous pages>
Nx=		<Nr of pages on Node x>

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc2/fs/proc/base.c
===================================================================
--- linux-2.6.13-rc2.orig/fs/proc/base.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/fs/proc/base.c	2005-07-08 14:06:16.000000000 -0700
@@ -65,6 +65,7 @@ enum pid_directory_inos {
 	PROC_TGID_STAT,
 	PROC_TGID_STATM,
 	PROC_TGID_MAPS,
+	PROC_TGID_NUMA_MAPS,
 	PROC_TGID_MOUNTS,
 	PROC_TGID_WCHAN,
 #ifdef CONFIG_SCHEDSTATS
@@ -102,6 +103,7 @@ enum pid_directory_inos {
 	PROC_TID_STAT,
 	PROC_TID_STATM,
 	PROC_TID_MAPS,
+	PROC_TID_NUMA_MAPS,
 	PROC_TID_MOUNTS,
 	PROC_TID_WCHAN,
 #ifdef CONFIG_SCHEDSTATS
@@ -144,6 +146,9 @@ static struct pid_entry tgid_base_stuff[
 	E(PROC_TGID_STAT,      "stat",    S_IFREG|S_IRUGO),
 	E(PROC_TGID_STATM,     "statm",   S_IFREG|S_IRUGO),
 	E(PROC_TGID_MAPS,      "maps",    S_IFREG|S_IRUGO),
+#ifdef CONFIG_NUMA
+	E(PROC_TGID_NUMA_MAPS, "numa_maps", S_IFREG|S_IRUGO),
+#endif
 	E(PROC_TGID_MEM,       "mem",     S_IFREG|S_IRUSR|S_IWUSR),
 #ifdef CONFIG_SECCOMP
 	E(PROC_TGID_SECCOMP,   "seccomp", S_IFREG|S_IRUSR|S_IWUSR),
@@ -180,6 +185,9 @@ static struct pid_entry tid_base_stuff[]
 	E(PROC_TID_STAT,       "stat",    S_IFREG|S_IRUGO),
 	E(PROC_TID_STATM,      "statm",   S_IFREG|S_IRUGO),
 	E(PROC_TID_MAPS,       "maps",    S_IFREG|S_IRUGO),
+#ifdef CONFIG_NUMA
+	E(PROC_TID_NUMA_MAPS,  "numa_maps",    S_IFREG|S_IRUGO),
+#endif
 	E(PROC_TID_MEM,        "mem",     S_IFREG|S_IRUSR|S_IWUSR),
 #ifdef CONFIG_SECCOMP
 	E(PROC_TID_SECCOMP,    "seccomp", S_IFREG|S_IRUSR|S_IWUSR),
@@ -515,6 +523,27 @@ static struct file_operations proc_maps_
 	.release	= seq_release,
 };
 
+#ifdef CONFIG_NUMA
+extern struct seq_operations proc_pid_numa_maps_op;
+static int numa_maps_open(struct inode *inode, struct file *file)
+{
+	struct task_struct *task = proc_task(inode);
+	int ret = seq_open(file, &proc_pid_numa_maps_op);
+	if (!ret) {
+		struct seq_file *m = file->private_data;
+		m->private = task;
+	}
+	return ret;
+}
+
+static struct file_operations proc_numa_maps_operations = {
+	.open		= numa_maps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+#endif
+
 extern struct seq_operations mounts_op;
 static int mounts_open(struct inode *inode, struct file *file)
 {
@@ -1524,6 +1553,12 @@ static struct dentry *proc_pident_lookup
 		case PROC_TGID_MAPS:
 			inode->i_fop = &proc_maps_operations;
 			break;
+#ifdef CONFIG_NUMA
+		case PROC_TID_NUMA_MAPS:
+		case PROC_TGID_NUMA_MAPS:
+			inode->i_fop = &proc_numa_maps_operations;
+			break;
+#endif
 		case PROC_TID_MEM:
 		case PROC_TGID_MEM:
 			inode->i_op = &proc_mem_inode_operations;
Index: linux-2.6.13-rc2/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.13-rc2.orig/fs/proc/task_mmu.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/fs/proc/task_mmu.c	2005-07-08 14:07:05.000000000 -0700
@@ -2,6 +2,8 @@
 #include <linux/hugetlb.h>
 #include <linux/mount.h>
 #include <linux/seq_file.h>
+#include <linux/pagemap.h>
+#include <linux/mempolicy.h>
 #include <asm/elf.h>
 #include <asm/uaccess.h>
 #include "internal.h"
@@ -233,3 +235,134 @@ struct seq_operations proc_pid_maps_op =
 	.stop	= m_stop,
 	.show	= show_map
 };
+
+#ifdef CONFIG_NUMA
+
+struct numa_maps {
+	unsigned long pages;
+	unsigned long anon;
+	unsigned long mapped;
+	unsigned long mapcount_max;
+	unsigned long node[MAX_NUMNODES];
+};
+
+/*
+ * Calculate numa node maps for a vma
+ */
+static inline struct numa_maps *get_numa_maps(const struct vm_area_struct *vma)
+{
+	struct page *page;
+	unsigned long vaddr;
+	struct mm_struct *mm = vma->vm_mm;
+	int i;
+	struct numa_maps *md = kmalloc(sizeof(struct numa_maps), GFP_KERNEL);
+
+	if (!md)
+		return NULL;
+	md->pages = 0;
+	md->anon = 0;
+	md->mapped = 0;
+	md->mapcount_max = 0;
+	for_each_node(i)
+		md->node[i] =0;
+
+	spin_lock(&mm->page_table_lock);
+ 	for (vaddr = vma->vm_start; vaddr < vma->vm_end; vaddr += PAGE_SIZE) {
+		page = follow_page(mm, vaddr, 0);
+		if (page) {
+			int count = page_mapcount(page);
+
+			if (count)
+				md->mapped++;
+			if (count > md->mapcount_max)
+				md->mapcount_max = count;
+			md->pages++;
+			if (PageAnon(page))
+				md->anon++;
+			md->node[page_to_nid(page)]++;
+		}
+	}
+	spin_unlock(&mm->page_table_lock);
+	return md;
+}
+
+static int show_numa_map(struct seq_file *m, void *v)
+{
+	struct task_struct *task = m->private;
+	struct vm_area_struct *map = v;
+	struct mempolicy *pol;
+	struct numa_maps *md;
+	struct zone **z;
+	int n;
+	int first;
+
+	if (!map->vm_mm)
+		return 0;
+
+	md = get_numa_maps(map);
+	if (!md)
+		return 0;
+
+	seq_printf(m, "%08lx", map->vm_start);
+	pol = get_vma_policy(map, map->vm_start);
+	/* Print policy */
+	switch (pol->policy) {
+		case MPOL_PREFERRED:
+			seq_printf(m, " prefer=%d", pol->v.preferred_node);
+			break;
+		case MPOL_BIND:
+		{
+
+			seq_printf(m, " bind={");
+			first = 1;
+			for(z = pol->v.zonelist->zones; *z; z++) {
+
+				if (!first)
+					seq_putc(m, ',');
+				else
+					first = 0;
+				seq_printf(m, "%d/%s", (*z)->zone_pgdat->node_id, (*z)->name);
+
+			}
+			seq_putc(m, '}');
+		}
+		break;
+		case MPOL_INTERLEAVE:
+			seq_printf(m, " interleave={");
+			first = 1;
+			for_each_node(n)
+				if (test_bit(n, pol->v.nodes)) {
+					if (!first)
+						seq_putc(m,',');
+					else
+						first = 0;
+					seq_printf(m, "%d",n);
+				}
+			seq_putc(m, '}');
+			break;
+		default:
+			seq_printf(m," default");
+			break;
+	}
+	seq_printf(m, " MaxRef=%lu Pages=%lu Mapped=%lu",
+			md->mapcount_max, md->pages, md->mapped);
+	if (md->anon)
+		seq_printf(m," Anon=%lu",md->anon);
+
+	for_each_online_node(n)
+		if (md->node[n])
+			seq_printf(m, " N%d=%lu", n, md->node[n]);
+	seq_putc(m, '\n');
+	kfree(md);
+	if (m->count < m->size)  /* map is copied successfully */
+		m->version = (map != get_gate_vma(task))? map->vm_start: 0;
+	return 0;
+}
+
+struct seq_operations proc_pid_numa_maps_op = {
+	.start	= m_start,
+	.next	= m_next,
+	.stop	= m_stop,
+	.show	= show_numa_map
+};
+#endif
Index: linux-2.6.13-rc2/mm/mempolicy.c
===================================================================
--- linux-2.6.13-rc2.orig/mm/mempolicy.c	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/mm/mempolicy.c	2005-07-08 14:06:16.000000000 -0700
@@ -664,7 +664,7 @@ asmlinkage long compat_sys_mbind(compat_
 #endif
 
 /* Return effective policy for a VMA */
-static struct mempolicy *
+struct mempolicy *
 get_vma_policy(struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = current->mempolicy;
Index: linux-2.6.13-rc2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.13-rc2.orig/include/linux/mempolicy.h	2005-07-05 20:46:33.000000000 -0700
+++ linux-2.6.13-rc2/include/linux/mempolicy.h	2005-07-08 14:06:16.000000000 -0700
@@ -150,6 +150,8 @@ void mpol_free_shared_policy(struct shar
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
+struct mempolicy *get_vma_policy(struct vm_area_struct *vma, unsigned long addr);
+
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
