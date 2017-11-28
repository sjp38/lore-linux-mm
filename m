Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B76566B02A1
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id q84so26619931pfl.12
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u65sor557769pgc.27.2017.11.27.23.50.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:07 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 14/18] mm/vchecker: make callstack depth configurable
Date: Tue, 28 Nov 2017 16:48:49 +0900
Message-Id: <1511855333-3570-15-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Getting full callstack is heavy job so it's sometimes better to
reduce this overhead by limiting callstack depth. So, this patch
makes the callstack depth configurable by using debugfs interface.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 77 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index acead62..4d140e7 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -27,6 +27,7 @@
 
 struct vchecker {
 	bool enabled;
+	unsigned int callstack_depth;
 	struct list_head cb_list;
 };
 
@@ -309,13 +310,14 @@ static void filter_vchecker_stacks(struct stack_trace *trace,
 }
 
 static noinline depot_stack_handle_t save_stack(struct stackdepot *s,
-				unsigned long ret_ip, bool *is_new)
+				unsigned long ret_ip, unsigned int max_entries,
+				bool *is_new)
 {
 	unsigned long entries[VCHECKER_STACK_DEPTH];
 	struct stack_trace trace = {
 		.nr_entries = 0,
 		.entries = entries,
-		.max_entries = VCHECKER_STACK_DEPTH,
+		.max_entries = max_entries,
 		.skip = VCHECKER_SKIP_DEPTH,
 	};
 	depot_stack_handle_t handle;
@@ -489,6 +491,70 @@ static const struct file_operations enable_fops = {
 	.release	= single_release,
 };
 
+static int callstack_depth_show(struct seq_file *f, void *v)
+{
+	struct kmem_cache *s = f->private;
+	struct vchecker *checker = s->vchecker_cache.checker;
+
+	mutex_lock(&vchecker_meta);
+	seq_printf(f, "%u\n", checker->callstack_depth);
+	mutex_unlock(&vchecker_meta);
+
+	return 0;
+}
+
+static int callstack_depth_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, callstack_depth_show, inode->i_private);
+}
+
+static ssize_t callstack_depth_write(struct file *filp, const char __user *ubuf,
+			size_t cnt, loff_t *ppos)
+{
+	char callstack_depth_chars[32];
+	unsigned int callstack_depth;
+	struct kmem_cache *s = file_inode(filp)->i_private;
+
+	if (cnt >= 32 || cnt == 0)
+		return -EINVAL;
+
+	if (copy_from_user(&callstack_depth_chars, ubuf, cnt))
+		return -EFAULT;
+
+	if (isspace(callstack_depth_chars[0])) {
+		callstack_depth = VCHECKER_STACK_DEPTH;
+		goto setup;
+	}
+
+	callstack_depth_chars[cnt - 1] = '\0';
+	if (kstrtouint(callstack_depth_chars, 10, &callstack_depth))
+		return -EINVAL;
+
+	if (callstack_depth > VCHECKER_STACK_DEPTH)
+		callstack_depth = VCHECKER_STACK_DEPTH;
+
+setup:
+	mutex_lock(&vchecker_meta);
+	if (s->vchecker_cache.checker->enabled ||
+		!list_empty(&s->vchecker_cache.checker->cb_list)) {
+		mutex_unlock(&vchecker_meta);
+		return -EINVAL;
+	}
+
+	s->vchecker_cache.checker->callstack_depth = callstack_depth;
+	mutex_unlock(&vchecker_meta);
+
+	return cnt;
+}
+
+static const struct file_operations callstack_depth_fops = {
+	.open		= callstack_depth_open,
+	.write		= callstack_depth_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int init_value(struct kmem_cache *s, struct vchecker_cb *cb,
 				char *buf, size_t cnt)
 {
@@ -571,7 +637,8 @@ static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
 	if (!write)
 		goto check;
 
-	handle = save_stack(NULL, ret_ip, NULL);
+	handle = save_stack(NULL, ret_ip,
+			s->vchecker_cache.checker->callstack_depth,  NULL);
 	if (!handle) {
 		pr_err("VCHECKER: %s: fail at addr %p\n", __func__, object);
 		dump_stack();
@@ -715,7 +782,8 @@ static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
 	struct vchecker_callstack_arg *arg = cb->arg;
 	int idx;
 
-	handle = save_stack(arg->s, ret_ip, &is_new);
+	handle = save_stack(arg->s, ret_ip,
+			s->vchecker_cache.checker->callstack_depth, &is_new);
 	if (!is_new)
 		return true;
 
@@ -825,6 +893,7 @@ static int alloc_vchecker(struct kmem_cache *s)
 	if (!checker)
 		return -ENOMEM;
 
+	checker->callstack_depth = VCHECKER_STACK_DEPTH;
 	INIT_LIST_HEAD(&checker->cb_list);
 	s->vchecker_cache.checker = checker;
 
@@ -848,6 +917,10 @@ static int register_debugfs(struct kmem_cache *s)
 	if (!debugfs_create_file("enable", 0600, dir, s, &enable_fops))
 		return -ENOMEM;
 
+	if (!debugfs_create_file("callstack_depth", 0600, dir, s,
+				&callstack_depth_fops))
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
