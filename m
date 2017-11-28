Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8484F6B029B
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:58 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 62so1840339plc.14
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9sor26999pfa.49.2017.11.27.23.49.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:57 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 11/18] vchecker: consistently exclude vchecker's stacktrace
Date: Tue, 28 Nov 2017 16:48:46 +0900
Message-Id: <1511855333-3570-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Since there is a different callpath even in the vchecker, static skip
value doesn't always exclude vchecker's stacktrace. Fix it through
checking stacktrace dynamically.

v2: skip two depth of stack at default, it's safe!

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 41 +++++++++++++++++++++++++----------------
 1 file changed, 25 insertions(+), 16 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index df480d5..dc3a9a7 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -23,6 +23,7 @@
 #include "kasan.h"
 
 #define VCHECKER_STACK_DEPTH (16)
+#define VCHECKER_SKIP_DEPTH (2)
 
 struct vchecker {
 	bool enabled;
@@ -48,7 +49,7 @@ struct vchecker_type {
 	void (*show)(struct kmem_cache *s, struct seq_file *f,
 			struct vchecker_cb *cb, void *object, bool verbose);
 	bool (*check)(struct kmem_cache *s, struct vchecker_cb *cb,
-			void *object, bool write,
+			void *object, bool write, unsigned long ret_ip,
 			unsigned long begin, unsigned long end);
 };
 
@@ -276,7 +277,7 @@ bool vchecker_check(unsigned long addr, size_t size,
 			continue;
 
 		checked = true;
-		if (cb->type->check(s, cb, object, write, begin, end))
+		if (cb->type->check(s, cb, object, write, ret_ip, begin, end))
 			continue;
 
 		vchecker_report(addr, size, write, ret_ip, s, cb, object);
@@ -292,14 +293,29 @@ bool vchecker_check(unsigned long addr, size_t size,
 	return vchecker_poisoned((void *)addr, size);
 }
 
-static noinline depot_stack_handle_t save_stack(int skip, bool *is_new)
+static void filter_vchecker_stacks(struct stack_trace *trace,
+				unsigned long ret_ip)
+{
+	int i;
+
+	for (i = 0; i < trace->nr_entries; i++) {
+		if (trace->entries[i] == ret_ip) {
+			trace->entries = &trace->entries[i];
+			trace->nr_entries -= i;
+			break;
+		}
+	}
+}
+
+static noinline depot_stack_handle_t save_stack(unsigned long ret_ip,
+						bool *is_new)
 {
 	unsigned long entries[VCHECKER_STACK_DEPTH];
 	struct stack_trace trace = {
 		.nr_entries = 0,
 		.entries = entries,
 		.max_entries = VCHECKER_STACK_DEPTH,
-		.skip = skip,
+		.skip = VCHECKER_SKIP_DEPTH,
 	};
 	depot_stack_handle_t handle;
 
@@ -311,6 +327,7 @@ static noinline depot_stack_handle_t save_stack(int skip, bool *is_new)
 	if (trace.nr_entries == 0)
 		return 0;
 
+	filter_vchecker_stacks(&trace, ret_ip);
 	handle = depot_save_stack(NULL, &trace, __GFP_ATOMIC, is_new);
 	WARN_ON(!handle);
 
@@ -542,7 +559,7 @@ static void show_value(struct kmem_cache *s, struct seq_file *f,
 }
 
 static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
-			void *object, bool write,
+			void *object, bool write, unsigned long ret_ip,
 			unsigned long begin, unsigned long end)
 {
 	struct vchecker_value_arg *arg;
@@ -553,7 +570,7 @@ static bool check_value(struct kmem_cache *s, struct vchecker_cb *cb,
 	if (!write)
 		goto check;
 
-	handle = save_stack(0, NULL);
+	handle = save_stack(ret_ip, NULL);
 	if (!handle) {
 		pr_err("VCHECKER: %s: fail at addr %p\n", __func__, object);
 		dump_stack();
@@ -679,16 +696,8 @@ static void show_callstack(struct kmem_cache *s, struct seq_file *f,
 	}
 }
 
-/*
- * number of stacks to skip (at least).
- *
- *  __asan_loadX -> vchecker_check -> cb->check() -> save_stack
- *    -> save_stack_trace
- */
-#define STACK_SKIP  5
-
 static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
-			    void *object, bool write,
+			    void *object, bool write, unsigned long ret_ip,
 			    unsigned long begin, unsigned long end)
 {
 	u32 handle;
@@ -696,7 +705,7 @@ static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
 	struct vchecker_callstack_arg *arg = cb->arg;
 	int idx;
 
-	handle = save_stack(STACK_SKIP, &is_new);
+	handle = save_stack(ret_ip, &is_new);
 	if (!is_new)
 		return true;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
