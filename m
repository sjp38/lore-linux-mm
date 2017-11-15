Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A034028025E
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 08:57:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m188so17475162pga.22
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 05:57:33 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id f24si1008888pfk.415.2017.11.16.05.57.29
        for <linux-mm@kvack.org>;
        Thu, 16 Nov 2017 05:57:32 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/16] perf/ring_buffer: convert ring_buffer.aux_refcount to refcount_t
Date: Wed, 15 Nov 2017 16:03:34 +0200
Message-Id: <1510754620-27088-11-git-send-email-elena.reshetova@intel.com>
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

The variable ring_buffer.aux_refcount is used as pure reference counter.
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

For the ring_buffer.aux_refcount it might make a difference
in following places:
 - perf_aux_output_begin(): increment in refcount_inc_not_zero() only
   guarantees control dependency on success vs. fully ordered
   atomic counterpart
 - rb_free_aux(): decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 kernel/events/core.c        | 2 +-
 kernel/events/internal.h    | 2 +-
 kernel/events/ring_buffer.c | 6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 3497c6a..5f087f4 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5095,7 +5095,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 
 		/* this has to be the last one */
 		rb_free_aux(rb);
-		WARN_ON_ONCE(atomic_read(&rb->aux_refcount));
+		WARN_ON_ONCE(refcount_read(&rb->aux_refcount));
 
 		mutex_unlock(&event->mmap_mutex);
 	}
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 86c5c7f..50ecf00 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -49,7 +49,7 @@ struct ring_buffer {
 	atomic_t			aux_mmap_count;
 	unsigned long			aux_mmap_locked;
 	void				(*free_aux)(void *);
-	atomic_t			aux_refcount;
+	refcount_t			aux_refcount;
 	void				**aux_pages;
 	void				*aux_priv;
 
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index de12d36..b29d6ce 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -357,7 +357,7 @@ void *perf_aux_output_begin(struct perf_output_handle *handle,
 	if (!atomic_read(&rb->aux_mmap_count))
 		goto err;
 
-	if (!atomic_inc_not_zero(&rb->aux_refcount))
+	if (!refcount_inc_not_zero(&rb->aux_refcount))
 		goto err;
 
 	/*
@@ -659,7 +659,7 @@ int rb_alloc_aux(struct ring_buffer *rb, struct perf_event *event,
 	 * we keep a refcount here to make sure either of the two can
 	 * reference them safely.
 	 */
-	atomic_set(&rb->aux_refcount, 1);
+	refcount_set(&rb->aux_refcount, 1);
 
 	rb->aux_overwrite = overwrite;
 	rb->aux_watermark = watermark;
@@ -678,7 +678,7 @@ int rb_alloc_aux(struct ring_buffer *rb, struct perf_event *event,
 
 void rb_free_aux(struct ring_buffer *rb)
 {
-	if (atomic_dec_and_test(&rb->aux_refcount))
+	if (refcount_dec_and_test(&rb->aux_refcount))
 		__rb_free_aux(rb);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
