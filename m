Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F3256B02A5
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:15 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q187so14955600pga.6
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor10612221plq.68.2017.11.27.23.50.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:14 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 16/18] mm/vchecker: support allocation caller filter
Date: Tue, 28 Nov 2017 16:48:51 +0900
Message-Id: <1511855333-3570-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

kmalloc() is used everywhere in the kernel and it doesn't distiniguish
the callers since it doesn't much help to efficiently manage the memory.

However, there is a difference in the view of the debugging. A bug usually
happens on the objects allocated by specific allocation caller. So,
it is useful to distiniguish them. Let's call it as a same class object.

This patch implements an allocation caller filter to distiniguish
the class. With it, vchecker can be applied only to a specific class
and debugging it could be possible.

Note that it's not easy to distiniguish allocation caller of existing
allocated memory. Therefore, existing allocated memory will not be
included to debugging target if allocation caller filter is enabled.
If it is really required, feel free to ask me. I have a rough idea
to implement it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 lib/Kconfig.kasan   |   1 +
 mm/kasan/vchecker.c | 126 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 126 insertions(+), 1 deletion(-)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index d3552f3..4b8e748 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -63,5 +63,6 @@ config VCHECKER
 	  happens at the area.
 
 	depends on KASAN && DEBUG_FS
+	select KALLSYMS
 
 endif
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 918f05a..9f2b164 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -17,6 +17,7 @@
 #include <linux/kasan.h>
 #include <linux/uaccess.h>
 #include <linux/stackdepot.h>
+#include <linux/kallsyms.h>
 
 #include "vchecker.h"
 #include "../slab.h"
@@ -28,6 +29,7 @@
 struct vchecker {
 	bool enabled;
 	unsigned int callstack_depth;
+	struct list_head alloc_filter_list;
 	struct list_head cb_list;
 };
 
@@ -75,6 +77,12 @@ struct vchecker_callstack_arg {
 	bool enabled;
 };
 
+struct vchecker_alloc_filter {
+	unsigned long begin;
+	unsigned long end;
+	struct list_head list;
+};
+
 static struct dentry *debugfs_root;
 static struct vchecker_type vchecker_types[VCHECKER_TYPE_MAX];
 static DEFINE_MUTEX(vchecker_meta);
@@ -149,6 +157,7 @@ void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 {
 	struct vchecker *checker;
 	struct vchecker_cb *cb;
+	struct vchecker_alloc_filter *af;
 
 	rcu_read_lock();
 	checker = s->vchecker_cache.checker;
@@ -157,6 +166,18 @@ void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size,
 		return;
 	}
 
+	if (list_empty(&checker->alloc_filter_list))
+		goto mark;
+
+	list_for_each_entry(af, &checker->alloc_filter_list, list) {
+		if (af->begin <= ret_ip && ret_ip < af->end)
+			goto mark;
+	}
+
+	rcu_read_unlock();
+	return;
+
+mark:
 	list_for_each_entry(cb, &checker->cb_list, list) {
 		kasan_poison_shadow(object + cb->begin,
 				    round_up(cb->end - cb->begin,
@@ -476,9 +497,13 @@ static ssize_t enable_write(struct file *filp, const char __user *ubuf,
 	/*
 	 * After this operation, it is guaranteed that there is no user
 	 * left that accesses checker's cb list if vchecker is disabled.
+	 * Don't mark the object if alloc_filter is enabled. We cannot
+	 * know the allocation caller at this moment.
 	 */
 	synchronize_sched();
-	vchecker_enable_cache(s, enable);
+	if (!enable ||
+		list_empty(&s->vchecker_cache.checker->alloc_filter_list))
+		vchecker_enable_cache(s, enable);
 	mutex_unlock(&vchecker_meta);
 
 	return cnt;
@@ -556,6 +581,99 @@ static const struct file_operations callstack_depth_fops = {
 	.release	= single_release,
 };
 
+static int alloc_filter_show(struct seq_file *f, void *v)
+{
+	char name[KSYM_NAME_LEN];
+	struct kmem_cache *s = f->private;
+	struct vchecker *checker = s->vchecker_cache.checker;
+	struct vchecker_alloc_filter *af;
+
+	mutex_lock(&vchecker_meta);
+	list_for_each_entry(af, &checker->alloc_filter_list, list) {
+		if (!lookup_symbol_name(af->begin, name))
+			seq_printf(f, "%s: ", name);
+		seq_printf(f, "0x%lx - 0x%lx\n", af->begin, af->end);
+	}
+	mutex_unlock(&vchecker_meta);
+
+	return 0;
+}
+
+static int alloc_filter_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, alloc_filter_show, inode->i_private);
+}
+
+static void remove_alloc_filters(struct vchecker *checker)
+{
+	struct vchecker_alloc_filter *af, *tmp;
+
+	list_for_each_entry_safe(af, tmp, &checker->alloc_filter_list, list) {
+		list_del(&af->list);
+		kfree(af);
+	}
+}
+
+static ssize_t alloc_filter_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos)
+{
+	char filter_chars[KSYM_NAME_LEN];
+	struct kmem_cache *s = file_inode(filp)->i_private;
+	struct vchecker *checker = s->vchecker_cache.checker;
+	unsigned long begin;
+	unsigned long size;
+	struct vchecker_alloc_filter *af = NULL;
+
+	if (cnt >= KSYM_NAME_LEN || cnt == 0)
+		return -EINVAL;
+
+	if (copy_from_user(&filter_chars, ubuf, cnt))
+		return -EFAULT;
+
+	if (isspace(filter_chars[0]))
+		goto change;
+
+	filter_chars[cnt - 1] = '\0';
+	begin = kallsyms_lookup_name(filter_chars);
+	if (!begin)
+		return -EINVAL;
+
+	kallsyms_lookup_size_offset(begin, &size, NULL);
+
+	af = kzalloc(sizeof(*af), GFP_KERNEL);
+	if (!af)
+		return -ENOMEM;
+
+	af->begin = begin;
+	af->end = begin + size;
+
+change:
+	mutex_lock(&vchecker_meta);
+	if (checker->enabled || !list_empty(&checker->cb_list)) {
+		mutex_unlock(&vchecker_meta);
+		kfree(af);
+
+		return -EINVAL;
+	}
+
+	if (af)
+		list_add_tail(&af->list, &checker->alloc_filter_list);
+	else
+		remove_alloc_filters(checker);
+
+	mutex_unlock(&vchecker_meta);
+
+	return cnt;
+}
+
+static const struct file_operations alloc_filter_fops = {
+	.open		= alloc_filter_open,
+	.write		= alloc_filter_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int init_value(struct kmem_cache *s, struct vchecker_cb *cb,
 				char *buf, size_t cnt)
 {
@@ -865,6 +983,7 @@ static void free_vchecker(struct kmem_cache *s)
 	if (!s->vchecker_cache.checker)
 		return;
 
+	remove_alloc_filters(s->vchecker_cache.checker);
 	for (i = 0; i < ARRAY_SIZE(vchecker_types); i++)
 		remove_cbs(s, &vchecker_types[i]);
 	kfree(s->vchecker_cache.checker);
@@ -895,6 +1014,7 @@ static int alloc_vchecker(struct kmem_cache *s)
 		return -ENOMEM;
 
 	checker->callstack_depth = VCHECKER_STACK_DEPTH;
+	INIT_LIST_HEAD(&checker->alloc_filter_list);
 	INIT_LIST_HEAD(&checker->cb_list);
 	s->vchecker_cache.checker = checker;
 
@@ -922,6 +1042,10 @@ static int register_debugfs(struct kmem_cache *s)
 				&callstack_depth_fops))
 		return -ENOMEM;
 
+	if (!debugfs_create_file("alloc_filter", 0600, dir, s,
+				&alloc_filter_fops))
+		return -ENOMEM;
+
 	for (i = 0; i < ARRAY_SIZE(vchecker_types); i++) {
 		t = &vchecker_types[i];
 		if (!debugfs_create_file(t->name, 0600, dir, s, t->fops))
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
