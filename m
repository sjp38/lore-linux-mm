Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D96F28025E
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:57:30 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id t10so27321019pgo.20
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:57:30 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id i185si915807pgc.294.2017.11.16.05.57.26
        for <linux-mm@kvack.org>;
        Thu, 16 Nov 2017 05:57:29 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/16] perf/ring_buffer: convert ring_buffer.refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:33 +0200
Message-Id: <1510754620-27088-10-git-send-email-elena.reshetova@intel.com>
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

The variable ring_buffer.refcount is used as pure reference counter.
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

For the ring_buffer.refcount it might make a difference
in following places:
 - ring_buffer_get(): increment in refcount_inc_not_zero() only
   guarantees control dependency on success vs. fully ordered
   atomic counterpart
 - ring_buffer_put(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/events/core.c        | 4 ++--
 kernel/events/internal.h    | 3 ++-
 kernel/events/ring_buffer.c | 2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 29c381f..3497c6a 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5020,7 +5020,7 @@ struct ring_buffer *ring_buffer_get(struct perf_event *event)
 	rcu_read_lock();
 	rb = rcu_dereference(event->rb);
 	if (rb) {
-		if (!atomic_inc_not_zero(&rb->refcount))
+		if (!refcount_inc_not_zero(&rb->refcount))
 			rb = NULL;
 	}
 	rcu_read_unlock();
@@ -5030,7 +5030,7 @@ struct ring_buffer *ring_buffer_get(struct perf_event *event)
 
 void ring_buffer_put(struct ring_buffer *rb)
 {
-	if (!atomic_dec_and_test(&rb->refcount))
+	if (!refcount_dec_and_test(&rb->refcount))
 		return;
 
 	WARN_ON_ONCE(!list_empty(&rb->event_list));
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 09b1537..86c5c7f 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -4,13 +4,14 @@
 
 #include <linux/hardirq.h>
 #include <linux/uaccess.h>
+#include <linux/refcount.h>
 
 /* Buffer handling */
 
 #define RING_BUFFER_WRITABLE		0x01
 
 struct ring_buffer {
-	atomic_t			refcount;
+	refcount_t			refcount;
 	struct rcu_head			rcu_head;
 #ifdef CONFIG_PERF_USE_VMALLOC
 	struct work_struct		work;
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index 141aa2c..de12d36 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -284,7 +284,7 @@ ring_buffer_init(struct ring_buffer *rb, long watermark, int flags)
 	else
 		rb->overwrite = 1;
 
-	atomic_set(&rb->refcount, 1);
+	refcount_set(&rb->refcount, 1);
 
 	INIT_LIST_HEAD(&rb->event_list);
 	spin_lock_init(&rb->event_lock);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
