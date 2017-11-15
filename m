Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBBB6B0268
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:08:32 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x7so20990687pfa.19
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:08:32 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v39si12472195pgn.809.2017.11.15.06.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:08:31 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/16] perf: convert perf_event_context.refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:32 +0200
Message-Id: <1510754620-27088-9-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable perf_event_context.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the perf_event_context.refcount it might make a difference
in following places:
 - get_ctx(), perf_event_ctx_lock_nested(), perf_lock_task_context()
   and __perf_event_ctx_lock_double(): increment in
   refcount_inc_not_zero() only guarantees control dependency
   on success vs. fully ordered atomic counterpart
 - put_ctx(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/perf_event.h |  3 ++-
 kernel/events/core.c       | 12 ++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 2c9c87d..6a78705 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -54,6 +54,7 @@ struct perf_guest_info_callbacks {
 #include <linux/perf_regs.h>
 #include <linux/workqueue.h>
 #include <linux/cgroup.h>
+#include <linux/refcount.h>
 #include <asm/local.h>
 
 struct perf_callchain_entry {
@@ -718,7 +719,7 @@ struct perf_event_context {
 	int				nr_stat;
 	int				nr_freq;
 	int				rotate_disable;
-	atomic_t			refcount;
+	refcount_t			refcount;
 	struct task_struct		*task;
 
 	/*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index d084a97..29c381f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -1148,7 +1148,7 @@ static void perf_event_ctx_deactivate(struct perf_event_context *ctx)
 
 static void get_ctx(struct perf_event_context *ctx)
 {
-	WARN_ON(!atomic_inc_not_zero(&ctx->refcount));
+	WARN_ON(!refcount_inc_not_zero(&ctx->refcount));
 }
 
 static void free_ctx(struct rcu_head *head)
@@ -1162,7 +1162,7 @@ static void free_ctx(struct rcu_head *head)
 
 static void put_ctx(struct perf_event_context *ctx)
 {
-	if (atomic_dec_and_test(&ctx->refcount)) {
+	if (refcount_dec_and_test(&ctx->refcount)) {
 		if (ctx->parent_ctx)
 			put_ctx(ctx->parent_ctx);
 		if (ctx->task && ctx->task != TASK_TOMBSTONE)
@@ -1240,7 +1240,7 @@ perf_event_ctx_lock_nested(struct perf_event *event, int nesting)
 again:
 	rcu_read_lock();
 	ctx = READ_ONCE(event->ctx);
-	if (!atomic_inc_not_zero(&ctx->refcount)) {
+	if (!refcount_inc_not_zero(&ctx->refcount)) {
 		rcu_read_unlock();
 		goto again;
 	}
@@ -1373,7 +1373,7 @@ perf_lock_task_context(struct task_struct *task, int ctxn, unsigned long *flags)
 		}
 
 		if (ctx->task == TASK_TOMBSTONE ||
-		    !atomic_inc_not_zero(&ctx->refcount)) {
+		    !refcount_inc_not_zero(&ctx->refcount)) {
 			raw_spin_unlock(&ctx->lock);
 			ctx = NULL;
 		} else {
@@ -3715,7 +3715,7 @@ static void __perf_event_init_context(struct perf_event_context *ctx)
 	INIT_LIST_HEAD(&ctx->pinned_groups);
 	INIT_LIST_HEAD(&ctx->flexible_groups);
 	INIT_LIST_HEAD(&ctx->event_list);
-	atomic_set(&ctx->refcount, 1);
+	refcount_set(&ctx->refcount, 1);
 }
 
 static struct perf_event_context *
@@ -9793,7 +9793,7 @@ __perf_event_ctx_lock_double(struct perf_event *group_leader,
 again:
 	rcu_read_lock();
 	gctx = READ_ONCE(group_leader->ctx);
-	if (!atomic_inc_not_zero(&gctx->refcount)) {
+	if (!refcount_inc_not_zero(&gctx->refcount)) {
 		rcu_read_unlock();
 		goto again;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
