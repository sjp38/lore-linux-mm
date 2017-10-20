Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 854346B0273
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d28so10087240pfe.1
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q4si542751plb.719.2017.10.20.05.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:41 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/15] perf/ring_buffer: convert ring_buffer.refcount to refcount_t
Date: Fri, 20 Oct 2017 15:15:50 +0300
Message-Id: <1508501757-15784-9-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com>
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
index 7272b47..66d7e18 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5107,7 +5107,7 @@ struct ring_buffer *ring_buffer_get(struct perf_event *event)
 	rcu_read_lock();
 	rb = rcu_dereference(event->rb);
 	if (rb) {
-		if (!atomic_inc_not_zero(&rb->refcount))
+		if (!refcount_inc_not_zero(&rb->refcount))
 			rb = NULL;
 	}
 	rcu_read_unlock();
@@ -5117,7 +5117,7 @@ struct ring_buffer *ring_buffer_get(struct perf_event *event)
 
 void ring_buffer_put(struct ring_buffer *rb)
 {
-	if (!atomic_dec_and_test(&rb->refcount))
+	if (!refcount_dec_and_test(&rb->refcount))
 		return;
 
 	WARN_ON_ONCE(!list_empty(&rb->event_list));
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 843e970..1cdd9fa 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -3,13 +3,14 @@
 
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
index f684d8e..86e1379 100644
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
