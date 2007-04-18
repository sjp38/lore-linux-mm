Message-Id: <20070418201606.255808928@chello.nl>
References: <20070418201248.468050288@chello.nl>
Date: Wed, 18 Apr 2007 22:12:54 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 6/6] debug: optimistic lock histogram
Content-Disposition: inline; filename=radix-tree-optimistic-hist.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: npiggin@suse.de, akpm@linux-foundation.org, clameter@sgi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

A simple histogram allowing insight into the efficiency of the optimistic
locking for the subjected workload.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/proc/proc_misc.c |   22 +++++++++++
 lib/radix-tree.c    |  101 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 123 insertions(+)

Index: linux-2.6/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.orig/fs/proc/proc_misc.c	2007-04-18 09:56:42.000000000 +0200
+++ linux-2.6/fs/proc/proc_misc.c	2007-04-18 09:56:50.000000000 +0200
@@ -268,6 +268,25 @@ static const struct file_operations proc
 	.release	= seq_release,
 };
 
+#ifdef CONFIG_RADIX_TREE_OPTIMISTIC
+extern struct seq_operations optimistic_op;
+static int optimistic_open(struct inode *inode, struct file *file)
+{
+	(void)inode;
+	return seq_open(file, &optimistic_op);
+}
+
+extern ssize_t optimistic_write(struct file *, const char __user *, size_t, loff_t *);
+
+static struct file_operations optimistic_file_operations = {
+	.open	= optimistic_open,
+	.read	= seq_read,
+	.llseek	= seq_lseek,
+	.release = seq_release,
+	.write	= optimistic_write,
+};
+#endif
+
 static int devinfo_show(struct seq_file *f, void *v)
 {
 	int i = *(loff_t *) v;
@@ -701,6 +720,9 @@ void __init proc_misc_init(void)
 			entry->proc_fops = &proc_kmsg_operations;
 	}
 #endif
+#ifdef CONFIG_RADIX_TREE_OPTIMISTIC
+	create_seq_entry("radix_optimistic", 0, &optimistic_file_operations);
+#endif
 	create_seq_entry("devices", 0, &proc_devinfo_operations);
 	create_seq_entry("cpuinfo", 0, &proc_cpuinfo_operations);
 #ifdef CONFIG_BLOCK
Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c	2007-04-18 09:56:42.000000000 +0200
+++ linux-2.6/lib/radix-tree.c	2007-04-18 10:11:26.000000000 +0200
@@ -75,6 +75,105 @@ static unsigned long height_to_maxindex[
 static struct lock_class_key radix_node_class[RADIX_TREE_MAX_PATH];
 #endif
 
+#ifdef CONFIG_RADIX_TREE_OPTIMISTIC
+static DEFINE_PER_CPU(unsigned long[RADIX_TREE_MAX_PATH+1], optimistic_histogram);
+
+static void optimistic_hit(unsigned long height)
+{
+	if (height > RADIX_TREE_MAX_PATH)
+		height = RADIX_TREE_MAX_PATH;
+
+	__get_cpu_var(optimistic_histogram)[height]++;
+}
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+#include <linux/uaccess.h>
+
+static void *frag_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos < 0 || *pos > RADIX_TREE_MAX_PATH)
+		return NULL;
+
+	m->private = (void *)(unsigned long)*pos;
+	return pos;
+}
+
+static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	if (*pos < RADIX_TREE_MAX_PATH) {
+		(*pos)++;
+		(*((unsigned long *)&m->private))++;
+		return pos;
+	}
+	return NULL;
+}
+
+static void frag_stop(struct seq_file *m, void *arg)
+{
+}
+
+unsigned long get_optimistic_stat(unsigned long index)
+{
+	unsigned long total = 0;
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		total += per_cpu(optimistic_histogram, cpu)[index];
+	}
+	return total;
+}
+
+static int frag_show(struct seq_file *m, void *arg)
+{
+	unsigned long index = (unsigned long)m->private;
+	unsigned long hits = get_optimistic_stat(index);
+
+	if (index == 0)
+		seq_printf(m, "levels skipped\thits\n");
+
+	if (index < RADIX_TREE_MAX_PATH)
+		seq_printf(m, "%9lu\t%9lu\n", index, hits);
+	else
+		seq_printf(m, "failed\t%9lu\n", hits);
+
+	return 0;
+}
+
+struct seq_operations optimistic_op = {
+	.start = frag_start,
+	.next = frag_next,
+	.stop = frag_stop,
+	.show = frag_show,
+};
+
+static void optimistic_reset(void)
+{
+	int cpu;
+	int height;
+	for_each_possible_cpu(cpu) {
+		for (height = 0; height <= RADIX_TREE_MAX_PATH; height++)
+			per_cpu(optimistic_histogram, cpu)[height] = 0;
+	}
+}
+
+ssize_t optimistic_write(struct file *file, const char __user *buf,
+		size_t count, loff_t *ppos)
+{
+	if (count) {
+		char c;
+		if (get_user(c, buf))
+			return -EFAULT;
+		if (c == '0')
+			optimistic_reset();
+	}
+	return count;
+}
+
+#endif // CONFIG_PROC_FS
+#endif // CONFIG_RADIX_TREE_OPTIMISTIC
+
 /*
  * Radix tree node cache.
  */
@@ -455,7 +554,9 @@ radix_optimistic_lock(struct radix_tree_
 			BUG_ON(context->locked);
 			spin_lock(&context->root->lock);
 			context->locked = &context->root->lock;
-		}
+			optimistic_hit(RADIX_TREE_MAX_PATH);
+		} else
+			optimistic_hit(context->root->height - node->height);
 	}
 	return node;
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
