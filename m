Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id F16406B0036
	for <linux-mm@kvack.org>; Mon, 26 May 2014 11:29:50 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so12219927qgd.27
        for <linux-mm@kvack.org>; Mon, 26 May 2014 08:29:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b4si13881469qat.93.2014.05.26.08.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 May 2014 08:29:50 -0700 (PDT)
Message-Id: <20140526152107.905524235@infradead.org>
Date: Mon, 26 May 2014 16:56:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 2/5] mm,perf: Make use of VM_PINNED
References: <20140526145605.016140154@infradead.org>
Content-Disposition: inline; filename=peterz-mm-pinned-2.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>

Change the perf RLIMIT_MEMLOCK accounting to use VM_PINNED. Because
the way VM_PINNED works (it hard assumes the entire vma length is
accounted) we have to slightly change semantics.

We used to only add to the RLIMIT_MEMLOCK accounting once we were over
the per-user limit, now we'll directly account to both.

XXX: anon_inode_inode->i_mapping doesn't have AS_UNEVICTABLE set,
should it?

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Roland Dreier <roland@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 kernel/events/core.c |   36 ++++++++++++++++--------------------
 1 file changed, 16 insertions(+), 20 deletions(-)

--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -4059,13 +4059,12 @@ static const struct vm_operations_struct
 static int perf_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	struct perf_event *event = file->private_data;
+	unsigned long locked, lock_limit, lock_extra;
 	unsigned long user_locked, user_lock_limit;
 	struct user_struct *user = current_user();
-	unsigned long locked, lock_limit;
-	struct ring_buffer *rb;
 	unsigned long vma_size;
 	unsigned long nr_pages;
-	long user_extra, extra;
+	struct ring_buffer *rb;
 	int ret = 0, flags = 0;
 
 	/*
@@ -4117,26 +4116,22 @@ static int perf_mmap(struct file *file,
 		goto unlock;
 	}
 
-	user_extra = nr_pages + 1;
-	user_lock_limit = sysctl_perf_event_mlock >> (PAGE_SHIFT - 10);
+	lock_extra = nr_pages + 1;
 
 	/*
 	 * Increase the limit linearly with more CPUs:
 	 */
+	user_lock_limit = sysctl_perf_event_mlock >> (PAGE_SHIFT - 10);
 	user_lock_limit *= num_online_cpus();
 
-	user_locked = atomic_long_read(&user->locked_vm) + user_extra;
-
-	extra = 0;
-	if (user_locked > user_lock_limit)
-		extra = user_locked - user_lock_limit;
+	user_locked = atomic_long_read(&user->locked_vm) + lock_extra;
 
 	lock_limit = rlimit(RLIMIT_MEMLOCK);
 	lock_limit >>= PAGE_SHIFT;
-	locked = vma->vm_mm->pinned_vm + extra;
+	locked = mm_locked_pages(vma->vm_mm) + lock_extra;
 
-	if ((locked > lock_limit) && perf_paranoid_tracepoint_raw() &&
-		!capable(CAP_IPC_LOCK)) {
+	if ((user_locked > user_lock_limit && locked > lock_limit) &&
+	    perf_paranoid_tracepoint_raw() && !capable(CAP_IPC_LOCK)) {
 		ret = -EPERM;
 		goto unlock;
 	}
@@ -4146,7 +4141,7 @@ static int perf_mmap(struct file *file,
 	if (vma->vm_flags & VM_WRITE)
 		flags |= RING_BUFFER_WRITABLE;
 
-	rb = rb_alloc(nr_pages, 
+	rb = rb_alloc(nr_pages,
 		event->attr.watermark ? event->attr.wakeup_watermark : 0,
 		event->cpu, flags);
 
@@ -4156,11 +4151,9 @@ static int perf_mmap(struct file *file,
 	}
 
 	atomic_set(&rb->mmap_count, 1);
-	rb->mmap_locked = extra;
 	rb->mmap_user = get_current_user();
 
-	atomic_long_add(user_extra, &user->locked_vm);
-	vma->vm_mm->pinned_vm += extra;
+	atomic_long_add(lock_extra, &user->locked_vm);
 
 	ring_buffer_attach(event, rb);
 
@@ -4173,10 +4166,13 @@ static int perf_mmap(struct file *file,
 	mutex_unlock(&event->mmap_mutex);
 
 	/*
-	 * Since pinned accounting is per vm we cannot allow fork() to copy our
-	 * vma.
+	 * VM_PINNED - this memory is pinned as we need to write to it from
+	 *             pretty much any context and cannot page.
+	 * VM_DONTCOPY - don't share over fork()
+	 * VM_DONTEXPAND - its not stack
+	 * VM_DONTDUMP - ...
 	 */
-	vma->vm_flags |= VM_DONTCOPY | VM_DONTEXPAND | VM_DONTDUMP;
+	vma->vm_flags |= VM_PINNED | VM_DONTCOPY | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &perf_mmap_vmops;
 
 	return ret;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
