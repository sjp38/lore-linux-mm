Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C7A2B6B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:42:21 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/4] sl[au]b: move slabinfo processing to slab_common.c
Date: Thu, 27 Sep 2012 18:37:37 +0400
Message-Id: <1348756660-16929-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1348756660-16929-1-git-send-email-glommer@parallels.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@cs.helsinki.fi>

This patch moves all the common machinery to slabinfo processing
to slab_common.c. We can do better by noticing that the output is
heavily common, and having the allocators to just provide finished
information about this. But after this first step, this can be done
easier.

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Christoph Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@cs.helsinki.fi>
CC: David Rientjes <rientjes@google.com>
---
 mm/slab.c        | 72 ++++++++++----------------------------------------------
 mm/slab.h        |  6 +++++
 mm/slab_common.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/slub.c        | 51 ++++-----------------------------------
 4 files changed, 94 insertions(+), 105 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 8524923..9502dfc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4284,7 +4284,7 @@ out:
 
 #ifdef CONFIG_SLABINFO
 
-static void print_slabinfo_header(struct seq_file *m)
+void print_slabinfo_header(struct seq_file *m)
 {
 	/*
 	 * Output format version, so at least we can change it
@@ -4307,28 +4307,7 @@ static void print_slabinfo_header(struct seq_file *m)
 	seq_putc(m, '\n');
 }
 
-static void *s_start(struct seq_file *m, loff_t *pos)
-{
-	loff_t n = *pos;
-
-	mutex_lock(&slab_mutex);
-	if (!n)
-		print_slabinfo_header(m);
-
-	return seq_list_start(&slab_caches, *pos);
-}
-
-static void *s_next(struct seq_file *m, void *p, loff_t *pos)
-{
-	return seq_list_next(p, &slab_caches, pos);
-}
-
-static void s_stop(struct seq_file *m, void *p)
-{
-	mutex_unlock(&slab_mutex);
-}
-
-static int s_show(struct seq_file *m, void *p)
+int slabinfo_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
 	struct slab *slabp;
@@ -4425,27 +4404,6 @@ static int s_show(struct seq_file *m, void *p)
 	return 0;
 }
 
-/*
- * slabinfo_op - iterator that generates /proc/slabinfo
- *
- * Output layout:
- * cache-name
- * num-active-objs
- * total-objs
- * object size
- * num-active-slabs
- * total-slabs
- * num-pages-per-slab
- * + further values on SMP and with statistics enabled
- */
-
-static const struct seq_operations slabinfo_op = {
-	.start = s_start,
-	.next = s_next,
-	.stop = s_stop,
-	.show = s_show,
-};
-
 #define MAX_SLABINFO_WRITE 128
 /**
  * slabinfo_write - Tuning for the slab allocator
@@ -4454,7 +4412,7 @@ static const struct seq_operations slabinfo_op = {
  * @count: data length
  * @ppos: unused
  */
-static ssize_t slabinfo_write(struct file *file, const char __user *buffer,
+ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 		       size_t count, loff_t *ppos)
 {
 	char kbuf[MAX_SLABINFO_WRITE + 1], *tmp;
@@ -4497,19 +4455,6 @@ static ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 	return res;
 }
 
-static int slabinfo_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &slabinfo_op);
-}
-
-static const struct file_operations proc_slabinfo_operations = {
-	.open		= slabinfo_open,
-	.read		= seq_read,
-	.write		= slabinfo_write,
-	.llseek		= seq_lseek,
-	.release	= seq_release,
-};
-
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 
 static void *leaks_start(struct seq_file *m, loff_t *pos)
@@ -4638,6 +4583,16 @@ static int leaks_show(struct seq_file *m, void *p)
 	return 0;
 }
 
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	return seq_list_next(p, &slab_caches, pos);
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&slab_mutex);
+}
+
 static const struct seq_operations slabstats_op = {
 	.start = leaks_start,
 	.next = s_next,
@@ -4672,7 +4627,6 @@ static const struct file_operations proc_slabstats_operations = {
 
 static int __init slab_proc_init(void)
 {
-	proc_create("slabinfo",S_IWUSR|S_IRUSR,NULL,&proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 	proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index 7deeb44..ac0053f6 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -47,4 +47,10 @@ static inline struct kmem_cache *__kmem_cache_alias(const char *name, size_t siz
 
 int __kmem_cache_shutdown(struct kmem_cache *);
 
+void print_slabinfo_header(struct seq_file *m);
+
+int slabinfo_show(struct seq_file *m, void *p);
+
+ssize_t slabinfo_write(struct file *file, const char __user *buffer,
+		       size_t count, loff_t *ppos);
 #endif
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9c21725..2e0061a 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -13,6 +13,8 @@
 #include <linux/module.h>
 #include <linux/cpu.h>
 #include <linux/uaccess.h>
+#include <linux/seq_file.h>
+#include <linux/proc_fs.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 #include <asm/page.h>
@@ -189,3 +191,71 @@ int slab_is_available(void)
 {
 	return slab_state >= UP;
 }
+
+#ifdef CONFIG_SLABINFO
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+	loff_t n = *pos;
+
+	mutex_lock(&slab_mutex);
+	if (!n)
+		print_slabinfo_header(m);
+
+	return seq_list_start(&slab_caches, *pos);
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+	return seq_list_next(p, &slab_caches, pos);
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+	mutex_unlock(&slab_mutex);
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+	return slabinfo_show(m, p);
+}
+
+/*
+ * slabinfo_op - iterator that generates /proc/slabinfo
+ *
+ * Output layout:
+ * cache-name
+ * num-active-objs
+ * total-objs
+ * object size
+ * num-active-slabs
+ * total-slabs
+ * num-pages-per-slab
+ * + further values on SMP and with statistics enabled
+ */
+static const struct seq_operations slabinfo_op = {
+	.start = s_start,
+	.next = s_next,
+	.stop = s_stop,
+	.show = s_show,
+};
+
+static int slabinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &slabinfo_op);
+}
+
+static const struct file_operations proc_slabinfo_operations = {
+	.open		= slabinfo_open,
+	.read		= seq_read,
+	.write          = slabinfo_write,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init slab_proc_init(void)
+{
+	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
+	return 0;
+}
+module_init(slab_proc_init);
+#endif /* CONFIG_SLABINFO */
diff --git a/mm/slub.c b/mm/slub.c
index 2258ed8..6383622 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5392,7 +5392,7 @@ __initcall(slab_sysfs_init);
  * The /proc/slabinfo ABI
  */
 #ifdef CONFIG_SLABINFO
-static void print_slabinfo_header(struct seq_file *m)
+void print_slabinfo_header(struct seq_file *m)
 {
 	seq_puts(m, "slabinfo - version: 2.1\n");
 	seq_puts(m, "# name            <active_objs> <num_objs> <object_size> "
@@ -5402,28 +5402,7 @@ static void print_slabinfo_header(struct seq_file *m)
 	seq_putc(m, '\n');
 }
 
-static void *s_start(struct seq_file *m, loff_t *pos)
-{
-	loff_t n = *pos;
-
-	mutex_lock(&slab_mutex);
-	if (!n)
-		print_slabinfo_header(m);
-
-	return seq_list_start(&slab_caches, *pos);
-}
-
-static void *s_next(struct seq_file *m, void *p, loff_t *pos)
-{
-	return seq_list_next(p, &slab_caches, pos);
-}
-
-static void s_stop(struct seq_file *m, void *p)
-{
-	mutex_unlock(&slab_mutex);
-}
-
-static int s_show(struct seq_file *m, void *p)
+int slabinfo_show(struct seq_file *m, void *p)
 {
 	unsigned long nr_partials = 0;
 	unsigned long nr_slabs = 0;
@@ -5459,29 +5438,9 @@ static int s_show(struct seq_file *m, void *p)
 	return 0;
 }
 
-static const struct seq_operations slabinfo_op = {
-	.start = s_start,
-	.next = s_next,
-	.stop = s_stop,
-	.show = s_show,
-};
-
-static int slabinfo_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &slabinfo_op);
-}
-
-static const struct file_operations proc_slabinfo_operations = {
-	.open		= slabinfo_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release,
-};
-
-static int __init slab_proc_init(void)
+ssize_t slabinfo_write(struct file *file, const char __user *buffer,
+		       size_t count, loff_t *ppos)
 {
-	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
-	return 0;
+	return -EIO;
 }
-module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
