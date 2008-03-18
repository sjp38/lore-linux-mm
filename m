Message-Id: <20080318222827.291587297@sgi.com>
References: <20080318222701.788442216@sgi.com>
Date: Tue, 18 Mar 2008 15:27:02 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [1/2] vmalloc: Show vmalloced areas via /proc/vmallocinfo
Content-Disposition: inline; filename=vmalloc_status
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Implement a new proc file that allows the display of the currently allocated vmalloc
memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/proc/proc_misc.c     |   14 ++++++++
 include/linux/vmalloc.h |    2 +
 mm/vmalloc.c            |   76 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 91 insertions(+), 1 deletion(-)

Index: linux-2.6.25-rc5-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/fs/proc/proc_misc.c	2008-03-17 15:42:00.731811666 -0700
+++ linux-2.6.25-rc5-mm1/fs/proc/proc_misc.c	2008-03-18 12:11:19.104438620 -0700
@@ -456,6 +456,18 @@ static const struct file_operations proc
 #endif
 #endif
 
+static int vmalloc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &vmalloc_op);
+}
+
+static const struct file_operations proc_vmalloc_operations = {
+	.open		= vmalloc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static int show_stat(struct seq_file *p, void *v)
 {
 	int i;
@@ -990,6 +1002,8 @@ void __init proc_misc_init(void)
 	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
 #endif
 #endif
+	proc_create("vmallocinfo",S_IWUSR|S_IRUGO, NULL,
+						&proc_vmalloc_operations);
 	proc_create("buddyinfo", S_IRUGO, NULL, &fragmentation_file_operations);
 	proc_create("pagetypeinfo", S_IRUGO, NULL, &pagetypeinfo_file_ops);
 	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
Index: linux-2.6.25-rc5-mm1/include/linux/vmalloc.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/vmalloc.h	2008-03-09 22:22:27.000000000 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/vmalloc.h	2008-03-18 12:08:41.507241390 -0700
@@ -87,4 +87,6 @@ extern void free_vm_area(struct vm_struc
 extern rwlock_t vmlist_lock;
 extern struct vm_struct *vmlist;
 
+extern const struct seq_operations vmalloc_op;
+
 #endif /* _LINUX_VMALLOC_H */
Index: linux-2.6.25-rc5-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.25-rc5-mm1.orig/mm/vmalloc.c	2008-03-09 22:22:27.000000000 -0700
+++ linux-2.6.25-rc5-mm1/mm/vmalloc.c	2008-03-18 12:10:15.995956807 -0700
@@ -14,7 +14,7 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
-
+#include <linux/seq_file.h>
 #include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
@@ -871,3 +871,77 @@ void free_vm_area(struct vm_struct *area
 	kfree(area);
 }
 EXPORT_SYMBOL_GPL(free_vm_area);
+
+
+#ifdef CONFIG_PROC_FS
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+	struct vm_struct *v;
+
+	read_lock(&vmlist_lock);
+	v = vmlist;
+	while (n > 0 && v) {
+		n--;
+		v = v->next;
+	}
+	if (!n)
+		return v;
+
+	return NULL;
+
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	struct vm_struct *v = p;
+
+	++*pos;
+	return v->next;
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+	read_unlock(&vmlist_lock);
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+	struct vm_struct *v = p;
+
+	seq_printf(m, "0x%p-0x%p %7ld",
+		v->addr, v->addr + v->size, v->size);
+
+	if (v->nr_pages)
+		seq_printf(m, " pages=%d", v->nr_pages);
+
+	if (v->phys_addr)
+		seq_printf(m, " phys=%lx", v->phys_addr);
+
+	if (v->flags & VM_IOREMAP)
+		seq_printf(m, " ioremap");
+
+	if (v->flags & VM_ALLOC)
+		seq_printf(m, " vmalloc");
+
+	if (v->flags & VM_MAP)
+		seq_printf(m, " vmap");
+
+	if (v->flags & VM_USERMAP)
+		seq_printf(m, " user");
+
+	if (v->flags & VM_VPAGES)
+		seq_printf(m, " vpages");
+
+	seq_putc(m, '\n');
+	return 0;
+}
+
+const struct seq_operations vmalloc_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+#endif
+

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
