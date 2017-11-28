Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEB46B028F
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i123so31263374pgd.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189sor7087726pgb.235.2017.11.27.23.49.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:36 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 05/18] vchecker: store/report callstack of value writer
Date: Tue, 28 Nov 2017 16:48:40 +0900
Message-Id: <1511855333-3570-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

The purpose of the value checker is finding invalid user writing
invalid value at the moment that the value is written. However, there is
not enough infrastructure so that we cannot easily detect this case
in time.

However, by following way, we can emulate similar effect.

1. Store callstack when memory is written.
2. If check is failed when next access happen due to invalid written
value from previous write, report previous write-access callstack

It will caught offending user properly.

Following output "Invalid writer:" part is the result of this patch.
We find the invalid value writer at workfn_old_obj+0x14/0x50.

[   49.400673] ==================================================================
[   49.402297] BUG: VCHECKER: invalid access in workfn_old_obj+0x14/0x50 [vchecker_test] at addr ffff88002e9dc000
[   49.403899] Write of size 8 by task kworker/0:2/465
[   49.404538] value checker for offset 0 ~ 8 at ffff88002e9dc000
[   49.405374] (mask 0xffff value 7) invalid value 7

[   49.406016] Invalid writer:
[   49.406302]  workfn_old_obj+0x14/0x50 [vchecker_test]
[   49.406973]  process_one_work+0x3b5/0x9f0
[   49.407463]  worker_thread+0x87/0x750
[   49.407895]  kthread+0x1b2/0x200
[   49.408252]  ret_from_fork+0x24/0x30

[   49.408723] Allocated by task 1326:
[   49.409126]  kasan_kmalloc+0xb9/0xe0
[   49.409571]  kmem_cache_alloc+0xd1/0x250
[   49.410046]  0xffffffffa00c8157
[   49.410389]  do_one_initcall+0x82/0x1cf
[   49.410851]  do_init_module+0xe7/0x333
[   49.411296]  load_module+0x406b/0x4b40
[   49.411745]  SYSC_finit_module+0x14d/0x180
[   49.412247]  do_syscall_64+0xf0/0x340
[   49.412674]  return_from_SYSCALL_64+0x0/0x75

[   49.413276] Freed by task 0:
[   49.413566] (stack is not available)

[   49.414034] The buggy address belongs to the object at ffff88002e9dc000
                which belongs to the cache vchecker_test of size 8
[   49.415708] The buggy address is located 0 bytes inside of
                8-byte region [ffff88002e9dc000, ffff88002e9dc008)
[   49.417148] ==================================================================

Correct implementation needs more modifications to various layers
so it is postponed until feasibility is proved.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 59 insertions(+), 5 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index be0f0cd..2e9f461 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -16,11 +16,14 @@
 #include <linux/mutex.h>
 #include <linux/kasan.h>
 #include <linux/uaccess.h>
+#include <linux/stackdepot.h>
 
 #include "vchecker.h"
 #include "../slab.h"
 #include "kasan.h"
 
+#define VCHECKER_STACK_DEPTH (16)
+
 struct vchecker {
 	bool enabled;
 	struct list_head cb_list;
@@ -32,7 +35,7 @@ enum vchecker_type_num {
 };
 
 struct vchecker_data {
-	void *dummy;
+	depot_stack_handle_t write_handle;
 };
 
 struct vchecker_type {
@@ -281,6 +284,24 @@ bool vchecker_check(unsigned long addr, size_t size,
 	return vchecker_poisoned((void *)addr, size);
 }
 
+static noinline depot_stack_handle_t save_stack(void)
+{
+	unsigned long entries[VCHECKER_STACK_DEPTH];
+	struct stack_trace trace = {
+		.nr_entries = 0,
+		.entries = entries,
+		.max_entries = VCHECKER_STACK_DEPTH,
+		.skip = 0
+	};
+
+	save_stack_trace(&trace);
+	if (trace.nr_entries != 0 &&
+	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
+		trace.nr_entries--;
+
+	return depot_save_stack(&trace, GFP_NOWAIT);
+}
+
 static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
 			size_t cnt, loff_t *ppos,
 			enum vchecker_type_num type)
@@ -474,17 +495,35 @@ static void fini_value(struct vchecker_cb *cb)
 	kfree(cb->arg);
 }
 
+static void show_value_stack(struct vchecker_data *data)
+{
+	struct stack_trace trace;
+
+	if (!data->write_handle)
+		return;
+
+	pr_err("Invalid writer:\n");
+	depot_fetch_stack(data->write_handle, &trace);
+	print_stack_trace(&trace, 0);
+	pr_err("\n");
+}
+
 static void show_value(struct kmem_cache *s, struct seq_file *f,
 			struct vchecker_cb *cb, void *object)
 {
 	struct vchecker_value_arg *arg = cb->arg;
+	struct vchecker_data *data;
 
 	if (f)
 		seq_printf(f, "(mask 0x%llx value %llu) invalid value %llu\n\n",
 			arg->mask, arg->value, arg->value & arg->mask);
-	else
+	else {
+		data = (void *)object + s->vchecker_cache.data_offset;
+
 		pr_err("(mask 0x%llx value %llu) invalid value %llu\n\n",
 			arg->mask, arg->value, arg->value & arg->mask);
+		show_value_stack(data);
+	}
 }
 
 static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
@@ -492,14 +531,29 @@ static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
 			unsigned long begin, unsigned long end)
 {
 	struct vchecker_value_arg *arg;
+	struct vchecker_data *data;
 	u64 value;
+	depot_stack_handle_t handle;
+
+	if (!write)
+		goto check;
+
+	handle = save_stack();
+	if (!handle) {
+		pr_err("VCHECKER: %s: fail at addr %p\n", __func__, object);
+		dump_stack();
+	}
 
+	data = (void *)object + s->vchecker_cache.data_offset;
+	data->write_handle = handle;
+
+check:
 	arg = cb->arg;
 	value = *(u64 *)(object + begin);
-	if ((value & arg->mask) != (arg->value & arg->mask))
-		return true;
+	if ((value & arg->mask) == (arg->value & arg->mask))
+		return false;
 
-	return false;
+	return true;
 }
 
 static int value_show(struct seq_file *f, void *v)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
