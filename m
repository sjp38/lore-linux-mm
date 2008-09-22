From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] Report the pagesize backing a VMA in /proc/pid/maps
Date: Mon, 22 Sep 2008 02:38:12 +0100
Message-Id: <1222047492-27622-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
References: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds a new field for hugepage-backed memory regions to show the
pagesize in /proc/pid/maps.  While the information is available in smaps,
maps is more human-readable and does not incur the significant cost of
calculating Pss. An example of a /proc/self/maps output for an application
using hugepages with this patch applied is;

08048000-0804c000 r-xp 00000000 03:01 49135      /bin/cat
0804c000-0804d000 rw-p 00003000 03:01 49135      /bin/cat
08400000-08800000 rw-p 00000000 00:10 4055       /mnt/libhugetlbfs.tmp.QzPPTJ (deleted) (hpagesize=4096kB)
b7daa000-b7dab000 rw-p b7daa000 00:00 0
b7dab000-b7ed2000 r-xp 00000000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
b7ed2000-b7ed7000 r--p 00127000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
b7ed7000-b7ed9000 rw-p 0012c000 03:01 116846     /lib/tls/i686/cmov/libc-2.3.6.so
b7ed9000-b7edd000 rw-p b7ed9000 00:00 0
b7ee1000-b7ee8000 r-xp 00000000 03:01 49262      /root/libhugetlbfs-git/obj32/libhugetlbfs.so
b7ee8000-b7ee9000 rw-p 00006000 03:01 49262      /root/libhugetlbfs-git/obj32/libhugetlbfs.so
b7ee9000-b7eed000 rw-p b7ee9000 00:00 0
b7eed000-b7f02000 r-xp 00000000 03:01 119345     /lib/ld-2.3.6.so
b7f02000-b7f04000 rw-p 00014000 03:01 119345     /lib/ld-2.3.6.so
bf8ef000-bf903000 rwxp bffeb000 00:00 0          [stack]
bf903000-bf904000 rw-p bffff000 00:00 0
ffffe000-fffff000 r-xp 00000000 00:00 0          [vdso]

To be predictable for parsers, the patch adds the notion of reporting
VMA attributes by adding fields that look like "(attribute[=value])". This
already happens when a file is deleted and the user sees (deleted) after the
filename. The expectation is that existing parsers will not break as those
that read the filename should be reading forward after the inode number
and stopping when it sees something that is not part of the filename.
Parsers that assume everything after / is a filename will get confused by
(hpagesize=XkB) but are already broken due to (deleted).

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/proc/task_mmu.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 81a3f91..80233e6 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -198,7 +198,7 @@ static int do_maps_open(struct inode *inode, struct file *file,
 	return ret;
 }
 
-static int show_map(struct seq_file *m, void *v)
+static int __show_map(struct seq_file *m, void *v, int showattributes)
 {
 	struct proc_maps_private *priv = m->private;
 	struct task_struct *task = priv->task;
@@ -233,8 +233,8 @@ static int show_map(struct seq_file *m, void *v)
 	 * Print the dentry name for named mappings, and a
 	 * special [heap] marker for the heap:
 	 */
+	pad_len_spaces(m, len);
 	if (file) {
-		pad_len_spaces(m, len);
 		seq_path(m, &file->f_path, "\n");
 	} else {
 		const char *name = arch_vma_name(vma);
@@ -251,11 +251,17 @@ static int show_map(struct seq_file *m, void *v)
 				name = "[vdso]";
 			}
 		}
-		if (name) {
-			pad_len_spaces(m, len);
+		if (name)
 			seq_puts(m, name);
-		}
 	}
+
+	/*
+	 * Print additional attributes of the VMA of interest
+	 * - hugepage size if hugepage-backed
+	 */
+	if (showattributes && vma->vm_flags & VM_HUGETLB)
+		seq_printf(m, " (hpagesize=%lukB)", vma_page_size(vma) >> 10);
+
 	seq_putc(m, '\n');
 
 	if (m->count < m->size)  /* vma is copied successfully */
@@ -263,6 +269,11 @@ static int show_map(struct seq_file *m, void *v)
 	return 0;
 }
 
+static int show_map(struct seq_file *m, void *v)
+{
+	return __show_map(m, v, 1);
+}
+
 static const struct seq_operations proc_pid_maps_op = {
 	.start	= m_start,
 	.next	= m_next,
@@ -381,7 +392,7 @@ static int show_smap(struct seq_file *m, void *v)
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
 		walk_page_range(vma->vm_start, vma->vm_end, &smaps_walk);
 
-	ret = show_map(m, v);
+	ret = __show_map(m, v, 0);
 	if (ret)
 		return ret;
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
