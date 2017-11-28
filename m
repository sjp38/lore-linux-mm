Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 015D16B029D
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:02 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id i15so26780980pfa.15
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor10464047plu.60.2017.11.27.23.50.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:00 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 12/18] vchecker: fix 'remove' handling on callstack checker
Date: Tue, 28 Nov 2017 16:48:47 +0900
Message-Id: <1511855333-3570-13-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Since stack depot library doesn't support removal operation,
after removing and adding again callstack cb, callstack checker cannot
correctly judge whether this callstack is new or not for current cb
if the same callstack happens for previous cb.

This problem can be fixed by per-user stack depot since
we can create/destroy it when callstack cb is created/destroyed.
With that, is_new always shows correct result for current cb.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index dc3a9a7..acead62 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -68,6 +68,7 @@ struct vchecker_value_arg {
 
 #define CALLSTACK_MAX_HANDLE  (PAGE_SIZE / sizeof(depot_stack_handle_t))
 struct vchecker_callstack_arg {
+	struct stackdepot *s;
 	depot_stack_handle_t *handles;
 	atomic_t count;
 	bool enabled;
@@ -307,8 +308,8 @@ static void filter_vchecker_stacks(struct stack_trace *trace,
 	}
 }
 
-static noinline depot_stack_handle_t save_stack(unsigned long ret_ip,
-						bool *is_new)
+static noinline depot_stack_handle_t save_stack(struct stackdepot *s,
+				unsigned long ret_ip, bool *is_new)
 {
 	unsigned long entries[VCHECKER_STACK_DEPTH];
 	struct stack_trace trace = {
@@ -328,7 +329,7 @@ static noinline depot_stack_handle_t save_stack(unsigned long ret_ip,
 		return 0;
 
 	filter_vchecker_stacks(&trace, ret_ip);
-	handle = depot_save_stack(NULL, &trace, __GFP_ATOMIC, is_new);
+	handle = depot_save_stack(s, &trace, __GFP_ATOMIC, is_new);
 	WARN_ON(!handle);
 
 	return handle;
@@ -570,7 +571,7 @@ static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
 	if (!write)
 		goto check;
 
-	handle = save_stack(ret_ip, NULL);
+	handle = save_stack(NULL, ret_ip, NULL);
 	if (!handle) {
 		pr_err("VCHECKER: %s: fail at addr %p\n", __func__, object);
 		dump_stack();
@@ -637,6 +638,14 @@ static int init_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
 		kfree(arg);
 		return -ENOMEM;
 	}
+
+	arg->s = create_stackdepot();
+	if (!arg->s) {
+		free_page((unsigned long)arg->handles);
+		kfree(arg);
+		return -ENOMEM;
+	}
+
 	atomic_set(&arg->count, 0);
 
 	cb->begin = begin;
@@ -650,6 +659,7 @@ static void fini_callstack(struct vchecker_cb *cb)
 {
 	struct vchecker_callstack_arg *arg = cb->arg;
 
+	destroy_stackdepot(arg->s);
 	free_page((unsigned long)arg->handles);
 	kfree(arg);
 }
@@ -662,7 +672,7 @@ static void show_callstack_handle(struct seq_file *f, int idx,
 
 	seq_printf(f, "callstack #%d\n", idx);
 
-	depot_fetch_stack(NULL, arg->handles[idx], &trace);
+	depot_fetch_stack(arg->s, arg->handles[idx], &trace);
 
 	for (i = 0; i < trace.nr_entries; i++)
 		seq_printf(f, "  %pS\n", (void *)trace.entries[i]);
@@ -705,7 +715,7 @@ static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
 	struct vchecker_callstack_arg *arg = cb->arg;
 	int idx;
 
-	handle = save_stack(ret_ip, &is_new);
+	handle = save_stack(arg->s, ret_ip, &is_new);
 	if (!is_new)
 		return true;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
