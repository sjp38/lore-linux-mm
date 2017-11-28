Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81A366B0295
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id v15so1841764plk.17
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 78sor8714862pfr.16.2017.11.27.23.49.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:47 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 08/18] vchecker: Add 'callstack' checker
Date: Tue, 28 Nov 2017 16:48:43 +0900
Message-Id: <1511855333-3570-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Namhyung Kim <namhyung@kernel.org>

The callstack checker is to find invalid code paths accessing to a
certain field in an object.  Currently it only saves all stack traces at
the given offset.  Reporting will be added in the next patch.

The below example checks callstack of anon_vma:

  # cd /sys/kernel/debug/vchecker
  # echo 0 8 > anon_vma/callstack  # offset 0, size 8
  # echo 1 > anon_vma/enable

  # cat anon_vma/callstack        # show saved callstacks
  0x0 0x8 callstack
  total: 42
  callstack #0
    anon_vma_fork+0x101/0x280
    copy_process.part.10+0x15ff/0x2a40
    _do_fork+0x155/0x7d0
    SyS_clone+0x19/0x20
    do_syscall_64+0xdf/0x460
    return_from_SYSCALL_64+0x0/0x7a
  ...

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 172 ++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 161 insertions(+), 11 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 15a1b18..0c9a4fc 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -31,6 +31,7 @@ struct vchecker {
 
 enum vchecker_type_num {
 	VCHECKER_TYPE_VALUE = 0,
+	VCHECKER_TYPE_CALLSTACK,
 	VCHECKER_TYPE_MAX,
 };
 
@@ -45,7 +46,7 @@ struct vchecker_type {
 			char *buf, size_t cnt);
 	void (*fini)(struct vchecker_cb *cb);
 	void (*show)(struct kmem_cache *s, struct seq_file *f,
-			struct vchecker_cb *cb, void *object);
+			struct vchecker_cb *cb, void *object, bool verbose);
 	bool (*check)(struct kmem_cache *s, struct vchecker_cb *cb,
 			void *object, bool write,
 			unsigned long begin, unsigned long end);
@@ -64,6 +65,12 @@ struct vchecker_value_arg {
 	u64 value;
 };
 
+#define CALLSTACK_MAX_HANDLE  (PAGE_SIZE / sizeof(depot_stack_handle_t))
+struct vchecker_callstack_arg {
+	depot_stack_handle_t *handles;
+	atomic_t count;
+};
+
 static struct dentry *debugfs_root;
 static struct vchecker_type vchecker_types[VCHECKER_TYPE_MAX];
 static DEFINE_MUTEX(vchecker_meta);
@@ -82,7 +89,7 @@ static bool need_check(struct vchecker_cb *cb,
 }
 
 static void show_cb(struct kmem_cache *s, struct seq_file *f,
-			struct vchecker_cb *cb, void *object)
+			struct vchecker_cb *cb, void *object, bool verbose)
 {
 	if (f) {
 		seq_printf(f, "%s checker for offset %ld ~ %ld\n",
@@ -92,7 +99,7 @@ static void show_cb(struct kmem_cache *s, struct seq_file *f,
 			cb->type->name, cb->begin, cb->end, object);
 	}
 
-	cb->type->show(s, f, cb, object);
+	cb->type->show(s, f, cb, object, verbose);
 }
 
 static void add_cb(struct kmem_cache *s, struct vchecker_cb *cb)
@@ -189,7 +196,7 @@ static void vchecker_report(unsigned long addr, size_t size, bool write,
 	pr_err("%s of size %zu by task %s/%d\n",
 		write ? "Write" : "Read", size,
 		current->comm, task_pid_nr(current));
-	show_cb(s, NULL, cb, object);
+	show_cb(s, NULL, cb, object, true);
 
 	describe_object(s, object, (const void *)addr);
 	pr_err("==================================================================\n");
@@ -284,14 +291,14 @@ bool vchecker_check(unsigned long addr, size_t size,
 	return vchecker_poisoned((void *)addr, size);
 }
 
-static noinline depot_stack_handle_t save_stack(void)
+static noinline depot_stack_handle_t save_stack(int skip, bool *is_new)
 {
 	unsigned long entries[VCHECKER_STACK_DEPTH];
 	struct stack_trace trace = {
 		.nr_entries = 0,
 		.entries = entries,
 		.max_entries = VCHECKER_STACK_DEPTH,
-		.skip = 0
+		.skip = skip,
 	};
 
 	save_stack_trace(&trace);
@@ -299,7 +306,7 @@ static noinline depot_stack_handle_t save_stack(void)
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(NULL, &trace, GFP_NOWAIT, NULL);
+	return depot_save_stack(NULL, &trace, GFP_NOWAIT, is_new);
 }
 
 static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
@@ -381,7 +388,7 @@ static int vchecker_type_show(struct seq_file *f, enum vchecker_type_num type)
 		if (cb->type != &vchecker_types[type])
 			continue;
 
-		show_cb(s, f, cb, NULL);
+		show_cb(s, f, cb, NULL, true);
 	}
 	mutex_unlock(&vchecker_meta);
 
@@ -398,7 +405,7 @@ static int enable_show(struct seq_file *f, void *v)
 
 	seq_printf(f, "%s\n", checker->enabled ? "1" : "0");
 	list_for_each_entry(cb, &checker->cb_list, list)
-		show_cb(s, f, cb, NULL);
+		show_cb(s, f, cb, NULL, false);
 
 	mutex_unlock(&vchecker_meta);
 
@@ -509,7 +516,7 @@ static void show_value_stack(struct vchecker_data *data)
 }
 
 static void show_value(struct kmem_cache *s, struct seq_file *f,
-			struct vchecker_cb *cb, void *object)
+			struct vchecker_cb *cb, void *object, bool verbose)
 {
 	struct vchecker_value_arg *arg = cb->arg;
 	struct vchecker_data *data;
@@ -538,7 +545,7 @@ static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
 	if (!write)
 		goto check;
 
-	handle = save_stack();
+	handle = save_stack(0, NULL);
 	if (!handle) {
 		pr_err("VCHECKER: %s: fail at addr %p\n", __func__, object);
 		dump_stack();
@@ -581,9 +588,152 @@ static const struct file_operations fops_value = {
 	.release	= single_release,
 };
 
+static int init_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
+			  char *buf, size_t cnt)
+{
+	unsigned long begin, len;
+	struct vchecker_callstack_arg *arg;
+	unsigned long max_size = round_up(s->object_size, sizeof(u64));
+
+	BUILD_BUG_ON(sizeof(u64) != KASAN_SHADOW_SCALE_SIZE);
+
+	if (sscanf(buf, "%lu %lu", &begin, &len) != 2)
+		return -EINVAL;
+
+	if (len > max_size || begin > max_size - len)
+		return -EINVAL;
+
+	arg = kzalloc(sizeof(struct vchecker_callstack_arg), GFP_KERNEL);
+	if (!arg)
+		return -ENOMEM;
+
+	arg->handles = (void *)get_zeroed_page(GFP_KERNEL);
+	if (!arg->handles) {
+		kfree(arg);
+		return -ENOMEM;
+	}
+	atomic_set(&arg->count, 0);
+
+	cb->begin = begin;
+	cb->end = begin + len;
+	cb->arg = arg;
+
+	return 0;
+}
+
+static void fini_callstack(struct vchecker_cb *cb)
+{
+	struct vchecker_callstack_arg *arg = cb->arg;
+
+	free_page((unsigned long)arg->handles);
+	kfree(arg);
+}
+
+static void show_callstack_handle(struct seq_file *f, int idx,
+				  struct vchecker_callstack_arg *arg)
+{
+	struct stack_trace trace;
+	unsigned int i;
+
+	seq_printf(f, "callstack #%d\n", idx);
+
+	depot_fetch_stack(NULL, arg->handles[idx], &trace);
+
+	for (i = 0; i < trace.nr_entries; i++)
+		seq_printf(f, "  %pS\n", (void *)trace.entries[i]);
+	seq_putc(f, '\n');
+}
+
+static void show_callstack(struct kmem_cache *s, struct seq_file *f,
+			   struct vchecker_cb *cb, void *object, bool verbose)
+{
+	struct vchecker_callstack_arg *arg = cb->arg;
+	int count = atomic_read(&arg->count);
+	int i;
+
+	if (f) {
+		seq_printf(f, "total: %d\n", count);
+
+		if (!verbose)
+			return;
+
+		if (count > CALLSTACK_MAX_HANDLE) {
+			seq_printf(f, "callstack is overflowed: (%d / %ld)\n",
+				count, CALLSTACK_MAX_HANDLE);
+			count = CALLSTACK_MAX_HANDLE;
+		}
+
+		for (i = 0; i < count; i++)
+			show_callstack_handle(f, i, arg);
+	} else {
+		pr_err("invalid callstack found #%d\n", count - 1);
+		/* current stack trace will be shown by kasan_object_err() */
+	}
+}
+
+/*
+ * number of stacks to skip (at least).
+ *
+ *  __asan_loadX -> vchecker_check -> cb->check() -> save_stack
+ *    -> save_stack_trace
+ */
+#define STACK_SKIP  5
+
+static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
+			    void *object, bool write,
+			    unsigned long begin, unsigned long end)
+{
+	u32 handle;
+	bool is_new = false;
+	struct vchecker_callstack_arg *arg = cb->arg;
+	int idx;
+
+	handle = save_stack(STACK_SKIP, &is_new);
+	if (!is_new)
+		return true;
+
+	idx = atomic_fetch_inc(&arg->count);
+
+	/* TODO: support handle table in multiple pages */
+	if (idx < CALLSTACK_MAX_HANDLE)
+		arg->handles[idx] = handle;
+
+	/* TODO: support reporting new callstack */
+	return true;
+}
+
+static int callstack_show(struct seq_file *f, void *v)
+{
+	return vchecker_type_show(f, VCHECKER_TYPE_CALLSTACK);
+}
+
+static int callstack_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, callstack_show, inode->i_private);
+}
+
+static ssize_t callstack_write(struct file *filp, const char __user *ubuf,
+			       size_t cnt, loff_t *ppos)
+{
+	/* add a new (disabled) callstack checker at the given offset */
+	return vchecker_type_write(filp, ubuf, cnt, ppos,
+				   VCHECKER_TYPE_CALLSTACK);
+}
+
+static const struct file_operations fops_callstack = {
+	.open		= callstack_open,
+	.write		= callstack_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+/* also need to update enum VCHECKER_TYPE_XXX */
 static struct vchecker_type vchecker_types[VCHECKER_TYPE_MAX] = {
 	{ "value", &fops_value, init_value, fini_value,
 		show_value, check_value },
+	{ "callstack", &fops_callstack, init_callstack, fini_callstack,
+		show_callstack, check_callstack },
 };
 
 static void free_vchecker(struct kmem_cache *s)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
