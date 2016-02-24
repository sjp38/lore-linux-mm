Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D8B746B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 06:07:10 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so238697663wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 03:07:10 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id pi3si2972411wjb.134.2016.02.24.03.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 03:07:09 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id a4so24359743wme.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 03:07:09 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kcov: clean up code
Date: Wed, 24 Feb 2016 12:07:03 +0100
Message-Id: <1456312023-142713-1-git-send-email-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: drysdale@google.com, glider@google.com, jslaby@suse.cz, kcc@google.com, keescook@google.com, quentin.casasnovas@oracle.com, ryabinin.a.a@gmail.com, sasha.levin@oracle.com, syzkaller@googlegroups.com, vegard.nossum@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

Address several issues in the original kcov submission
(based on Andrew comments):

1. Introduce KCOV_MODE_DISABLED, use it instead of 0.
2. Rename kcov.rc to kcov.refcount (rc can be confused with
   'return code').
3. Give name to ioctl argument (size/unused instead of arg).
4. Check that trace buffer size does not overflow on 32-bit
   arches (preventive since currently only x86_64 is supported).
5. Return ENOTTY instead of EINVAL for unknown ioctls.
6. Add comments to struct kcov fields.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
---
 include/linux/kcov.h |  2 ++
 kernel/kcov.c        | 38 +++++++++++++++++++++++++-------------
 2 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/include/linux/kcov.h b/include/linux/kcov.h
index 01b4845..2883ac9 100644
--- a/include/linux/kcov.h
+++ b/include/linux/kcov.h
@@ -11,6 +11,8 @@ void kcov_task_init(struct task_struct *t);
 void kcov_task_exit(struct task_struct *t);
 
 enum kcov_mode {
+	/* Coverage collection is not enabled yet. */
+	KCOV_MODE_DISABLED = 0,
 	/*
 	 * Tracing coverage collection mode.
 	 * Covered PCs are collected in a per-task buffer.
diff --git a/kernel/kcov.c b/kernel/kcov.c
index 230279c..3efbee0 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -27,12 +27,15 @@ struct kcov {
 	 *  - opened file descriptor
 	 *  - task with enabled coverage (we can't unwire it from another task)
 	 */
-	atomic_t		rc;
+	atomic_t		refcount;
 	/* The lock protects mode, size, area and t. */
 	spinlock_t		lock;
 	enum kcov_mode		mode;
+	/* Size of arena (in long's for KCOV_MODE_TRACE). */
 	unsigned		size;
+	/* Coverage buffer shared with user space. */
 	void			*area;
+	/* Task for which we collect coverage, or NULL. */
 	struct task_struct	*t;
 };
 
@@ -78,12 +81,12 @@ EXPORT_SYMBOL(__sanitizer_cov_trace_pc);
 
 static void kcov_get(struct kcov *kcov)
 {
-	atomic_inc(&kcov->rc);
+	atomic_inc(&kcov->refcount);
 }
 
 static void kcov_put(struct kcov *kcov)
 {
-	if (atomic_dec_and_test(&kcov->rc)) {
+	if (atomic_dec_and_test(&kcov->refcount)) {
 		vfree(kcov->area);
 		kfree(kcov);
 	}
@@ -91,7 +94,7 @@ static void kcov_put(struct kcov *kcov)
 
 void kcov_task_init(struct task_struct *t)
 {
-	t->kcov_mode = 0;
+	t->kcov_mode = KCOV_MODE_DISABLED;
 	t->kcov_size = 0;
 	t->kcov_area = NULL;
 	t->kcov = NULL;
@@ -130,7 +133,7 @@ static int kcov_mmap(struct file *filep, struct vm_area_struct *vma)
 
 	spin_lock(&kcov->lock);
 	size = kcov->size * sizeof(unsigned long);
-	if (kcov->mode == 0 || vma->vm_pgoff != 0 ||
+	if (kcov->mode == KCOV_MODE_DISABLED || vma->vm_pgoff != 0 ||
 	    vma->vm_end - vma->vm_start != size) {
 		res = -EINVAL;
 		goto exit;
@@ -159,7 +162,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
 	kcov = kzalloc(sizeof(*kcov), GFP_KERNEL);
 	if (!kcov)
 		return -ENOMEM;
-	atomic_set(&kcov->rc, 1);
+	atomic_set(&kcov->refcount, 1);
 	spin_lock_init(&kcov->lock);
 	filep->private_data = kcov;
 	return nonseekable_open(inode, filep);
@@ -175,20 +178,26 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 			     unsigned long arg)
 {
 	struct task_struct *t;
+	unsigned long size, unused;
 
 	switch (cmd) {
 	case KCOV_INIT_TRACE:
 		/*
 		 * Enable kcov in trace mode and setup buffer size.
 		 * Must happen before anything else.
+		 */
+		if (kcov->mode != KCOV_MODE_DISABLED)
+			return -EBUSY;
+		/*
 		 * Size must be at least 2 to hold current position and one PC.
+		 * Later we allocate size * sizeof(unsigned long) memory,
+		 * that must not overflow.
 		 */
-		if (arg < 2 || arg > INT_MAX)
+		size = arg;
+		if (size < 2 || size > INT_MAX / sizeof(unsigned long))
 			return -EINVAL;
-		if (kcov->mode != 0)
-			return -EBUSY;
+		kcov->size = size;
 		kcov->mode = KCOV_MODE_TRACE;
-		kcov->size = arg;
 		return 0;
 	case KCOV_ENABLE:
 		/*
@@ -198,7 +207,9 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		 * at task exit or voluntary by KCOV_DISABLE. After that it can
 		 * be enabled for another task.
 		 */
-		if (arg != 0 || kcov->mode == 0 || kcov->area == NULL)
+		unused = arg;
+		if (unused != 0 || kcov->mode == KCOV_MODE_DISABLED ||
+		    kcov->area == NULL)
 			return -EINVAL;
 		if (kcov->t != NULL)
 			return -EBUSY;
@@ -216,7 +227,8 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		return 0;
 	case KCOV_DISABLE:
 		/* Disable coverage for the current task. */
-		if (arg != 0 || current->kcov != kcov)
+		unused = arg;
+		if (unused != 0 || current->kcov != kcov)
 			return -EINVAL;
 		t = current;
 		if (WARN_ON(kcov->t != t))
@@ -226,7 +238,7 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		kcov_put(kcov);
 		return 0;
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 }
 
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
