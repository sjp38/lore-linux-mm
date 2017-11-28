Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C84386B0289
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f6so9892397pfe.16
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor8960737pld.20.2017.11.27.23.49.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:27 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 02/18] vchecker: introduce the valid access checker
Date: Tue, 28 Nov 2017 16:48:37 +0900
Message-Id: <1511855333-3570-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Vchecker is a dynamic memory error detector. It provides a new debug
feature that can find out an un-intended access to valid area. Valid
area here means the memory which is allocated and allowed to be
accessed by memory owner and un-intended access means the read/write
that is initiated by non-owner. Usual problem of this class is
memory overwritten.

Most of debug feature focused on finding out un-intended access to
in-valid area, for example, out-of-bound access and use-after-free, and,
there are many good tools for it. But, as far as I know, there is
no good tool to find out un-intended access to valid area. This kind
of problem is really hard to solve so this tool would be very useful.

Idea to implement this feature is so simple. Thanks to compile-time
instrumentation, we can audit all the accesses to memory. However,
since almost accesses to valid area are usually valid, we need a way
to distinguish an in-valid access. What this patch provides is
the interface to describe the information about the address that
user are interested on and the judgement criteria for in-valid access.
With this information, we can easily detect in-valid access to valid area.

For now, two kinds of criteria are supported. One is the value checker
that checks written value to the designated address. The other is the
callstack checker that checks in-valid callstack when read/write happens.
It is more than welcome if someone introduces more checkers.

Note that this patch itself just provides infrastructure of the vchecker
and sample checker. Proper checker implementation will be implemented
in the following patches.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab_def.h |   3 +
 include/linux/slub_def.h |   3 +
 lib/Kconfig.kasan        |  12 +
 mm/kasan/Makefile        |   1 +
 mm/kasan/kasan.c         |  11 +-
 mm/kasan/kasan.h         |   1 +
 mm/kasan/vchecker.c      | 592 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/vchecker.h      |  31 +++
 mm/slab.h                |   6 +
 mm/slab_common.c         |  19 ++
 10 files changed, 677 insertions(+), 2 deletions(-)
 create mode 100644 mm/kasan/vchecker.c
 create mode 100644 mm/kasan/vchecker.h

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 7385547..34e2ea7 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -80,6 +80,9 @@ struct kmem_cache {
 #ifdef CONFIG_KASAN
 	struct kasan_cache kasan_info;
 #endif
+#ifdef CONFIG_VCHECKER
+	struct vchecker_cache vchecker_cache;
+#endif
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
 	unsigned int *random_seq;
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 8ad99c4..8a9deac 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -134,6 +134,9 @@ struct kmem_cache {
 #ifdef CONFIG_KASAN
 	struct kasan_cache kasan_info;
 #endif
+#ifdef CONFIG_VCHECKER
+	struct vchecker_cache vchecker_cache;
+#endif
 
 	size_t useroffset;		/* Usercopy region offset */
 	size_t usersize;		/* Usercopy region size */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index bd38aab..51c0a05 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -53,4 +53,16 @@ config TEST_KASAN
 	  out of bounds accesses, use after free. It is useful for testing
 	  kernel debugging features like kernel address sanitizer.
 
+config VCHECKER
+	bool "Valid access checker"
+	help
+	  Enables valid access checker - runtime memory debugger,
+	  designed to find un-intended accesses to valid (allocated) area.
+	  To debug something, you need to specify concrete area to be
+	  debugged and register checker you'd like to check when access
+	  happens at the area.
+
+	depends on KASAN && DEBUG_FS
+	select KASAN_OUTLINE
+
 endif
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 3289db3..f02ba99 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -9,3 +9,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o quarantine.o
+obj-$(CONFIG_VCHECKER) += vchecker.o
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 2bcbdbd..8fc4ad8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -39,6 +39,7 @@
 
 #include "kasan.h"
 #include "../slab.h"
+#include "vchecker.h"
 
 void kasan_enable_current(void)
 {
@@ -257,6 +258,9 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (likely(!memory_is_poisoned(addr, size)))
 		return;
 
+	if (vchecker_check(addr, size, write, ret_ip))
+		return;
+
 	kasan_report(addr, size, write, ret_ip);
 }
 
@@ -511,9 +515,11 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_double_free(cache, object,
+		if ((u8)shadow_byte != KASAN_VCHECKER_GRAYZONE) {
+			kasan_report_double_free(cache, object,
 				__builtin_return_address(1));
-		return true;
+			return true;
+		}
 	}
 
 	kasan_poison_slab_free(cache, object);
@@ -546,6 +552,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 	kasan_unpoison_shadow(object, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
 		KASAN_KMALLOC_REDZONE);
+	vchecker_kmalloc(cache, object, size);
 
 	if (cache->flags & SLAB_KASAN)
 		set_track(&get_alloc_info(cache, object)->alloc_track, flags);
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index b5d086d..485a2c0 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -13,6 +13,7 @@
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
 #define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
+#define KASAN_VCHECKER_GRAYZONE	0xF0  /* area that should be checked when access */
 
 /*
  * Stack redzone shadow values
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
new file mode 100644
index 0000000..0ac031c
--- /dev/null
+++ b/mm/kasan/vchecker.c
@@ -0,0 +1,592 @@
+/*
+ * Valid access checker
+ *
+ * Copyright (c) 2016-2017 Joonsoo Kim <iamjoonsoo.kim@lge.com>
+ */
+
+
+#include <linux/kernel.h>
+#include <linux/ctype.h>
+#include <linux/debugfs.h>
+#include <linux/list.h>
+#include <linux/rculist.h>
+#include <linux/mm.h>
+#include <linux/mm_types.h>
+#include <linux/slab.h>
+#include <linux/mutex.h>
+#include <linux/kasan.h>
+#include <linux/uaccess.h>
+
+#include "vchecker.h"
+#include "../slab.h"
+#include "kasan.h"
+
+struct vchecker {
+	bool enabled;
+	struct list_head cb_list;
+};
+
+enum vchecker_type_num {
+	VCHECKER_TYPE_VALUE = 0,
+	VCHECKER_TYPE_MAX,
+};
+
+struct vchecker_type {
+	char *name;
+	const struct file_operations *fops;
+	int (*init)(struct kmem_cache *s, struct vchecker_cb *cb,
+			char *buf, size_t cnt);
+	void (*fini)(struct vchecker_cb *cb);
+	void (*show)(struct kmem_cache *s, struct seq_file *f,
+			struct vchecker_cb *cb, void *object);
+	bool (*check)(struct kmem_cache *s, struct vchecker_cb *cb,
+			void *object, bool write,
+			unsigned long begin, unsigned long end);
+};
+
+struct vchecker_cb {
+	unsigned long begin;
+	unsigned long end;
+	void *arg;
+	struct vchecker_type *type;
+	struct list_head list;
+};
+
+struct vchecker_value_arg {
+	u64 mask;
+	u64 value;
+};
+
+static struct dentry *debugfs_root;
+static struct vchecker_type vchecker_types[VCHECKER_TYPE_MAX];
+static DEFINE_MUTEX(vchecker_meta);
+static DEFINE_SPINLOCK(report_lock);
+
+static bool need_check(struct vchecker_cb *cb,
+		unsigned long begin, unsigned long end)
+{
+	if (cb->end <= begin)
+		return false;
+
+	if (cb->begin >= end)
+		return false;
+
+	return true;
+}
+
+static void show_cb(struct kmem_cache *s, struct seq_file *f,
+			struct vchecker_cb *cb, void *object)
+{
+	if (f) {
+		seq_printf(f, "%s checker for offset %ld ~ %ld\n",
+			cb->type->name, cb->begin, cb->end);
+	} else {
+		pr_err("%s checker for offset %ld ~ %ld at %p\n",
+			cb->type->name, cb->begin, cb->end, object);
+	}
+
+	cb->type->show(s, f, cb, object);
+}
+
+static void add_cb(struct kmem_cache *s, struct vchecker_cb *cb)
+{
+	list_add_tail(&cb->list, &s->vchecker_cache.checker->cb_list);
+}
+
+static int remove_cbs(struct kmem_cache *s, struct vchecker_type *t)
+{
+	struct vchecker *checker = s->vchecker_cache.checker;
+	struct vchecker_cb *cb, *tmp;
+
+	list_for_each_entry_safe(cb, tmp, &checker->cb_list, list) {
+		if (cb->type == t) {
+			list_del(&cb->list);
+			t->fini(cb);
+			kfree(cb);
+		}
+	}
+
+	return 0;
+}
+
+void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size)
+{
+	struct vchecker *checker;
+	struct vchecker_cb *cb;
+
+	rcu_read_lock();
+	checker = s->vchecker_cache.checker;
+	if (!checker || !checker->enabled) {
+		rcu_read_unlock();
+		return;
+	}
+
+	list_for_each_entry(cb, &checker->cb_list, list) {
+		kasan_poison_shadow(object + cb->begin,
+				    round_up(cb->end - cb->begin,
+					     KASAN_SHADOW_SCALE_SIZE),
+				    KASAN_VCHECKER_GRAYZONE);
+	}
+	rcu_read_unlock();
+}
+
+static void vchecker_report(unsigned long addr, size_t size, bool write,
+			unsigned long ret_ip, struct kmem_cache *s,
+			struct vchecker_cb *cb, void *object)
+{
+	unsigned long flags;
+	const char *bug_type = "invalid access";
+
+	kasan_disable_current();
+	spin_lock_irqsave(&report_lock, flags);
+	pr_err("==================================================================\n");
+	pr_err("BUG: VCHECKER: %s in %pS at addr %p\n",
+		bug_type, (void *)ret_ip, (void *)addr);
+	pr_err("%s of size %zu by task %s/%d\n",
+		write ? "Write" : "Read", size,
+		current->comm, task_pid_nr(current));
+	show_cb(s, NULL, cb, object);
+
+	describe_object(s, object, (const void *)addr);
+	pr_err("==================================================================\n");
+	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
+	spin_unlock_irqrestore(&report_lock, flags);
+	if (panic_on_warn)
+		panic("panic_on_warn set ...\n");
+	kasan_enable_current();
+}
+
+static bool vchecker_poisoned(void *addr, size_t size)
+{
+	s8 shadow_val;
+	s8 *shadow_addr = kasan_mem_to_shadow(addr);
+	size_t shadow_size = kasan_mem_to_shadow(addr + size - 1) -
+				(void *)shadow_addr + 1;
+
+	while (shadow_size) {
+		shadow_val = *shadow_addr;
+		shadow_size--;
+		shadow_addr++;
+
+		if (shadow_val == 0)
+			continue;
+
+		if (shadow_val == (s8)KASAN_VCHECKER_GRAYZONE)
+			continue;
+
+		if (shadow_val < 0)
+			return false;
+
+		if (shadow_size)
+			return false;
+
+		/* last byte check */
+		if ((((unsigned long)addr + size - 1) & KASAN_SHADOW_MASK) >=
+			shadow_val)
+			return false;
+	}
+
+	return true;
+}
+
+bool vchecker_check(unsigned long addr, size_t size,
+			bool write, unsigned long ret_ip)
+{
+	struct page *page;
+	struct kmem_cache *s;
+	void *object;
+	struct vchecker *checker;
+	struct vchecker_cb *cb;
+	unsigned long begin, end;
+	bool checked = false;
+
+	if (current->kasan_depth)
+		return false;
+
+	page = virt_to_head_page((void *)addr);
+	if (!PageSlab(page))
+		return false;
+
+	s = page->slab_cache;
+	object = nearest_obj(s, page, (void *)addr);
+	begin = addr - (unsigned long)object;
+	end = begin + size;
+
+	rcu_read_lock();
+	checker = s->vchecker_cache.checker;
+	if (!checker->enabled) {
+		rcu_read_unlock();
+		goto check_shadow;
+	}
+
+	list_for_each_entry(cb, &checker->cb_list, list) {
+		if (!need_check(cb, begin, end))
+			continue;
+
+		checked = true;
+		if (cb->type->check(s, cb, object, write, begin, end))
+			continue;
+
+		vchecker_report(addr, size, write, ret_ip, s, cb, object);
+		rcu_read_unlock();
+		return true;
+	}
+	rcu_read_unlock();
+
+	if (checked)
+		return true;
+
+check_shadow:
+	return vchecker_poisoned((void *)addr, size);
+}
+
+static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos,
+			enum vchecker_type_num type)
+{
+	char *buf;
+	struct kmem_cache *s = file_inode(filp)->i_private;
+	struct vchecker_type *t = NULL;
+	struct vchecker_cb *cb = NULL;
+	bool remove = false;
+	int ret = -EINVAL;
+
+	if (cnt >= PAGE_SIZE)
+		return -EINVAL;
+
+	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	if (copy_from_user(buf, ubuf, cnt)) {
+		kfree(buf);
+		return -EFAULT;
+	}
+
+	if (isspace(buf[0]))
+		remove = true;
+	buf[cnt - 1] = '\0';
+
+	mutex_lock(&vchecker_meta);
+	if (s->vchecker_cache.checker->enabled)
+		goto err;
+
+	t = &vchecker_types[type];
+
+	if (remove) {
+		remove_cbs(s, t);
+		goto out;
+	}
+
+	cb = kzalloc(sizeof(*cb), GFP_KERNEL);
+	if (!cb) {
+		ret = -ENOMEM;
+		goto err;
+	}
+
+	cb->type = t;
+	INIT_LIST_HEAD(&cb->list);
+
+	ret = t->init(s, cb, buf, cnt);
+	if (ret)
+		goto err;
+
+	add_cb(s, cb);
+
+out:
+	mutex_unlock(&vchecker_meta);
+	kfree(buf);
+
+	return cnt;
+
+err:
+	mutex_unlock(&vchecker_meta);
+	kfree(buf);
+	kfree(cb);
+
+	return ret;
+}
+
+static int vchecker_type_show(struct seq_file *f, enum vchecker_type_num type)
+{
+	struct kmem_cache *s = f->private;
+	struct vchecker *checker;
+	struct vchecker_cb *cb;
+
+	mutex_lock(&vchecker_meta);
+	checker = s->vchecker_cache.checker;
+	list_for_each_entry(cb, &checker->cb_list, list) {
+		if (cb->type != &vchecker_types[type])
+			continue;
+
+		show_cb(s, f, cb, NULL);
+	}
+	mutex_unlock(&vchecker_meta);
+
+	return 0;
+}
+
+static int enable_show(struct seq_file *f, void *v)
+{
+	struct kmem_cache *s = f->private;
+	struct vchecker *checker = s->vchecker_cache.checker;
+	struct vchecker_cb *cb;
+
+	mutex_lock(&vchecker_meta);
+
+	seq_printf(f, "%s\n", checker->enabled ? "1" : "0");
+	list_for_each_entry(cb, &checker->cb_list, list)
+		show_cb(s, f, cb, NULL);
+
+	mutex_unlock(&vchecker_meta);
+
+	return 0;
+}
+
+static int enable_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, enable_show, inode->i_private);
+}
+
+static ssize_t enable_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos)
+{
+	char enable_char;
+	bool enable;
+	struct kmem_cache *s = file_inode(filp)->i_private;
+
+	if (cnt >= PAGE_SIZE || cnt == 0)
+		return -EINVAL;
+
+	if (copy_from_user(&enable_char, ubuf, 1))
+		return -EFAULT;
+
+	if (enable_char == '0')
+		enable = false;
+	else if (enable_char == '1')
+		enable = true;
+	else
+		return -EINVAL;
+
+	mutex_lock(&vchecker_meta);
+	if (enable && list_empty(&s->vchecker_cache.checker->cb_list)) {
+		mutex_unlock(&vchecker_meta);
+		return -EINVAL;
+	}
+	s->vchecker_cache.checker->enabled = enable;
+
+	/*
+	 * After this operation, it is guaranteed that there is no user
+	 * left that accesses checker's cb list if vchecker is disabled.
+	 */
+	synchronize_sched();
+	mutex_unlock(&vchecker_meta);
+
+	return cnt;
+}
+
+static const struct file_operations enable_fops = {
+	.open		= enable_open,
+	.write		= enable_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int init_value(struct kmem_cache *s, struct vchecker_cb *cb,
+				char *buf, size_t cnt)
+{
+	unsigned long begin;
+	u64 mask;
+	u64 value;
+	struct vchecker_value_arg *arg;
+	unsigned long max_size = round_up(s->object_size, sizeof(u64));
+
+	BUILD_BUG_ON(sizeof(u64) != KASAN_SHADOW_SCALE_SIZE);
+
+	if (sscanf(buf, "%lu %llx %llu", &begin, &mask, &value) != 3)
+		return -EINVAL;
+
+	if (!IS_ALIGNED(begin, KASAN_SHADOW_SCALE_SIZE))
+		return -EINVAL;
+
+	if (begin > max_size - sizeof(value))
+		return -EINVAL;
+
+	arg = kzalloc(sizeof(struct vchecker_value_arg), GFP_KERNEL);
+	if (!arg)
+		return -ENOMEM;
+
+	arg->mask = mask;
+	arg->value = value;
+
+	cb->begin = begin;
+	cb->end = begin + sizeof(value);
+	cb->arg = arg;
+
+	return 0;
+}
+
+static void fini_value(struct vchecker_cb *cb)
+{
+	kfree(cb->arg);
+}
+
+static void show_value(struct kmem_cache *s, struct seq_file *f,
+			struct vchecker_cb *cb, void *object)
+{
+	struct vchecker_value_arg *arg = cb->arg;
+
+	if (f)
+		seq_printf(f, "(mask 0x%llx value %llu) invalid value %llu\n\n",
+			arg->mask, arg->value, arg->value & arg->mask);
+	else
+		pr_err("(mask 0x%llx value %llu) invalid value %llu\n\n",
+			arg->mask, arg->value, arg->value & arg->mask);
+}
+
+static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
+			void *object, bool write,
+			unsigned long begin, unsigned long end)
+{
+	struct vchecker_value_arg *arg;
+	u64 value;
+
+	arg = cb->arg;
+	value = *(u64 *)(object + begin);
+	if ((value & arg->mask) != (arg->value & arg->mask))
+		return true;
+
+	return false;
+}
+
+static int value_show(struct seq_file *f, void *v)
+{
+	return vchecker_type_show(f, VCHECKER_TYPE_VALUE);
+}
+
+static int value_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, value_show, inode->i_private);
+}
+
+static ssize_t value_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos)
+{
+	return vchecker_type_write(filp, ubuf, cnt, ppos,
+				VCHECKER_TYPE_VALUE);
+}
+
+static const struct file_operations fops_value = {
+	.open		= value_open,
+	.write		= value_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct vchecker_type vchecker_types[VCHECKER_TYPE_MAX] = {
+	{ "value", &fops_value, init_value, fini_value,
+		show_value, check_value },
+};
+
+static void free_vchecker(struct kmem_cache *s)
+{
+	int i;
+
+	if (!s->vchecker_cache.checker)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(vchecker_types); i++)
+		remove_cbs(s, &vchecker_types[i]);
+	kfree(s->vchecker_cache.checker);
+}
+
+static void __fini_vchecker(struct kmem_cache *s)
+{
+	debugfs_remove_recursive(s->vchecker_cache.dir);
+	free_vchecker(s);
+}
+
+void fini_vchecker(struct kmem_cache *s)
+{
+	mutex_lock(&vchecker_meta);
+	__fini_vchecker(s);
+	mutex_unlock(&vchecker_meta);
+}
+
+static int alloc_vchecker(struct kmem_cache *s)
+{
+	struct vchecker *checker;
+
+	if (s->vchecker_cache.checker)
+		return 0;
+
+	checker = kzalloc(sizeof(*checker), GFP_KERNEL);
+	if (!checker)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&checker->cb_list);
+	s->vchecker_cache.checker = checker;
+
+	return 0;
+}
+
+static int register_debugfs(struct kmem_cache *s)
+{
+	int i;
+	struct dentry *dir;
+	struct vchecker_type *t;
+
+	if (s->vchecker_cache.dir)
+		return 0;
+
+	dir = debugfs_create_dir(s->name, debugfs_root);
+	if (!dir)
+		return -ENOMEM;
+
+	s->vchecker_cache.dir = dir;
+	if (!debugfs_create_file("enable", 0600, dir, s, &enable_fops))
+		return -ENOMEM;
+
+	for (i = 0; i < ARRAY_SIZE(vchecker_types); i++) {
+		t = &vchecker_types[i];
+		if (!debugfs_create_file(t->name, 0600, dir, s, t->fops))
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+int init_vchecker(struct kmem_cache *s)
+{
+	if (!debugfs_root || !s->name)
+		return 0;
+
+	mutex_lock(&vchecker_meta);
+	if (alloc_vchecker(s)) {
+		mutex_unlock(&vchecker_meta);
+		return -ENOMEM;
+	}
+
+	if (register_debugfs(s)) {
+		__fini_vchecker(s);
+		mutex_unlock(&vchecker_meta);
+		return -ENOMEM;
+	}
+	mutex_unlock(&vchecker_meta);
+
+	return 0;
+}
+
+static int __init vchecker_debugfs_init(void)
+{
+	debugfs_root = debugfs_create_dir("vchecker", NULL);
+	if (!debugfs_root)
+		return -ENOMEM;
+
+	init_vcheckers();
+
+	return 0;
+}
+core_initcall(vchecker_debugfs_init);
diff --git a/mm/kasan/vchecker.h b/mm/kasan/vchecker.h
new file mode 100644
index 0000000..77ba07d
--- /dev/null
+++ b/mm/kasan/vchecker.h
@@ -0,0 +1,31 @@
+#ifndef __MM_KASAN_VCHECKER_H
+#define __MM_KASAN_VCHECKER_H
+
+struct vchecker;
+struct vchecker_cb;
+
+struct vchecker_cache {
+	struct vchecker *checker;
+	struct dentry *dir;
+};
+
+
+#ifdef CONFIG_VCHECKER
+void vchecker_kmalloc(struct kmem_cache *s, const void *object, size_t size);
+bool vchecker_check(unsigned long addr, size_t size,
+			bool write, unsigned long ret_ip);
+int init_vchecker(struct kmem_cache *s);
+void fini_vchecker(struct kmem_cache *s);
+
+#else
+static inline void vchecker_kmalloc(struct kmem_cache *s,
+	const void *object, size_t size) { }
+static inline bool vchecker_check(unsigned long addr, size_t size,
+			bool write, unsigned long ret_ip) { return false; }
+static inline int init_vchecker(struct kmem_cache *s) { return 0; }
+static inline void fini_vchecker(struct kmem_cache *s) { }
+
+#endif
+
+
+#endif
diff --git a/mm/slab.h b/mm/slab.h
index 1f013f7..d054da8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -32,6 +32,8 @@ struct kmem_cache {
 
 #endif /* CONFIG_SLOB */
 
+#include "kasan/vchecker.h"
+
 #ifdef CONFIG_SLAB
 #include <linux/slab_def.h>
 #endif
@@ -530,4 +532,8 @@ static inline int cache_random_seq_create(struct kmem_cache *cachep,
 static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifdef CONFIG_VCHECKER
+void init_vcheckers(void);
+#endif
+
 #endif /* MM_SLAB_H */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index e96fb23d..6f700f3 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -25,6 +25,7 @@
 #include <trace/events/kmem.h>
 
 #include "slab.h"
+#include "kasan/vchecker.h"
 
 enum slab_state slab_state;
 LIST_HEAD(slab_caches);
@@ -396,6 +397,10 @@ static struct kmem_cache *create_cache(const char *name,
 	if (err)
 		goto out_free_cache;
 
+	err = init_vchecker(s);
+	if (err)
+		goto out_free_cache;
+
 	err = __kmem_cache_create(s, flags);
 	if (err)
 		goto out_free_cache;
@@ -409,6 +414,7 @@ static struct kmem_cache *create_cache(const char *name,
 	return s;
 
 out_free_cache:
+	fini_vchecker(s);
 	destroy_memcg_params(s);
 	kmem_cache_free(kmem_cache, s);
 	goto out;
@@ -841,6 +847,7 @@ void slab_kmem_cache_release(struct kmem_cache *s)
 {
 	__kmem_cache_release(s);
 	destroy_memcg_params(s);
+	fini_vchecker(s);
 	kfree_const(s->name);
 	kmem_cache_free(kmem_cache, s);
 }
@@ -1216,6 +1223,18 @@ void cache_random_seq_destroy(struct kmem_cache *cachep)
 }
 #endif /* CONFIG_SLAB_FREELIST_RANDOM */
 
+#ifdef CONFIG_VCHECKER
+void __init init_vcheckers(void)
+{
+	struct kmem_cache *s;
+
+	mutex_lock(&slab_mutex);
+	list_for_each_entry(s, &slab_caches, list)
+		init_vchecker(s);
+	mutex_unlock(&slab_mutex);
+}
+#endif
+
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB_DEBUG)
 #ifdef CONFIG_SLAB
 #define SLABINFO_RIGHTS (S_IWUSR | S_IRUSR)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
