Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 199776B0275
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:16:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z11so10019740pfk.23
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:16:49 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g127si637148pgc.772.2017.10.20.05.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 05:16:47 -0700 (PDT)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/15] perf/ring_buffer: convert ring_buffer.aux_refcount to refcount_t
Date: Fri, 20 Oct 2017 15:15:51 +0300
Message-Id: <1508501757-15784-10-git-send-email-elena.reshetova@intel.com>
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

The variable ring_buffer.aux_refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

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
index 66d7e18..3848480 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5182,7 +5182,7 @@ static void perf_mmap_close(struct vm_area_struct *vma)
 
 		/* this has to be the last one */
 		rb_free_aux(rb);
-		WARN_ON_ONCE(atomic_read(&rb->aux_refcount));
+		WARN_ON_ONCE(refcount_read(&rb->aux_refcount));
 
 		mutex_unlock(&event->mmap_mutex);
 	}
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 1cdd9fa..cc5b545 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -48,7 +48,7 @@ struct ring_buffer {
 	atomic_t			aux_mmap_count;
 	unsigned long			aux_mmap_locked;
 	void				(*free_aux)(void *);
-	atomic_t			aux_refcount;
+	refcount_t			aux_refcount;
 	void				**aux_pages;
 	void				*aux_priv;
 
diff --git a/kernel/events/ring_buffer.c b/kernel/events/ring_buffer.c
index 86e1379..08838cd6 100644
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -357,7 +357,7 @@ void *perf_aux_output_begin(struct perf_output_handle *handle,
 	if (!atomic_read(&rb->aux_mmap_count))
 		goto err;
 
-	if (!atomic_inc_not_zero(&rb->aux_refcount))
+	if (!refcount_inc_not_zero(&rb->aux_refcount))
 		goto err;
 
 	/*
@@ -655,7 +655,7 @@ int rb_alloc_aux(struct ring_buffer *rb, struct perf_event *event,
 	 * we keep a refcount here to make sure either of the two can
 	 * reference them safely.
 	 */
-	atomic_set(&rb->aux_refcount, 1);
+	refcount_set(&rb->aux_refcount, 1);
 
 	rb->aux_overwrite = overwrite;
 	rb->aux_watermark = watermark;
@@ -674,7 +674,7 @@ int rb_alloc_aux(struct ring_buffer *rb, struct perf_event *event,
 
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
