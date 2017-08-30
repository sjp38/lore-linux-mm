Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BC3AA6B02F4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:23:40 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t82so2918764wmd.10
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:40 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id f42si6067046ede.336.2017.08.30.09.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 09:23:38 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id a80so13313845wma.0
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:38 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 1/3] kcov: support comparison operands collection
Date: Wed, 30 Aug 2017 18:23:29 +0200
Message-Id: <663c2a30de845dd13cf3cf64c3dfd437295d5ce2.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
In-Reply-To: <cover.1504109849.git.dvyukov@google.com>
References: <cover.1504109849.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: tchibo@google.com, Mark Rutland <mark.rutland@arm.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org

From: Victor Chibotaru <tchibo@google.com>

Enables kcov to collect comparison operands from instrumented code.
This is done by using Clang's -fsanitize=trace-cmp instrumentation
(currently not available for GCC).

The comparison operands help a lot in fuzz testing. E.g. they are
used in Syzkaller to cover the interiors of conditional statements
with way less attempts and thus make previously unreachable code
reachable.

To allow separate collection of coverage and comparison operands two
different work modes are implemented. Mode selection is now done via
a KCOV_ENABLE ioctl call with corresponding argument value.

Signed-off-by: Victor Chibotaru <tchibo@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Cc: syzkaller@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
Clang instrumentation:
https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
Syzkaller:
https://github.com/google/syzkaller
---
 include/linux/kcov.h      |  12 ++-
 include/uapi/linux/kcov.h |  32 ++++++++
 kernel/kcov.c             | 203 ++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 209 insertions(+), 38 deletions(-)

diff --git a/include/linux/kcov.h b/include/linux/kcov.h
index 2883ac98c280..87e2a44f1bab 100644
--- a/include/linux/kcov.h
+++ b/include/linux/kcov.h
@@ -7,19 +7,23 @@ struct task_struct;
 
 #ifdef CONFIG_KCOV
 
-void kcov_task_init(struct task_struct *t);
-void kcov_task_exit(struct task_struct *t);
-
 enum kcov_mode {
 	/* Coverage collection is not enabled yet. */
 	KCOV_MODE_DISABLED = 0,
+	/* KCOV was initialized, but tracing mode hasn't been chosen yet. */
+	KCOV_MODE_INIT = 1,
 	/*
 	 * Tracing coverage collection mode.
 	 * Covered PCs are collected in a per-task buffer.
 	 */
-	KCOV_MODE_TRACE = 1,
+	KCOV_MODE_TRACE_PC = 2,
+	/* Collecting comparison operands mode. */
+	KCOV_MODE_TRACE_CMP = 3,
 };
 
+void kcov_task_init(struct task_struct *t);
+void kcov_task_exit(struct task_struct *t);
+
 #else
 
 static inline void kcov_task_init(struct task_struct *t) {}
diff --git a/include/uapi/linux/kcov.h b/include/uapi/linux/kcov.h
index 574e22ec640d..a0bc3e6a5ff7 100644
--- a/include/uapi/linux/kcov.h
+++ b/include/uapi/linux/kcov.h
@@ -7,4 +7,36 @@
 #define KCOV_ENABLE			_IO('c', 100)
 #define KCOV_DISABLE			_IO('c', 101)
 
+enum {
+	/*
+	 * Tracing coverage collection mode.
+	 * Covered PCs are collected in a per-task buffer.
+	 * In new KCOV version the mode is chosen by calling
+	 * ioctl(fd, KCOV_ENABLE, mode). In older versions the mode argument
+	 * was supposed to be 0 in such a call. So, for reasons of backward
+	 * compatibility, we have chosen the value KCOV_TRACE_PC to be 0.
+	 */
+	KCOV_TRACE_PC = 0,
+	/* Collecting comparison operands mode. */
+	KCOV_TRACE_CMP = 1,
+};
+
+/*
+ * Defines the format for the types of collected comparisons.
+ */
+enum kcov_cmp_type {
+	/*
+	 * LSB shows whether one of the arguments is a compile-time constant.
+	 */
+	KCOV_CMP_CONST = 1,
+	/*
+	 * Second and third LSBs contain the size of arguments (1/2/4/8 bytes).
+	 */
+	KCOV_CMP_SIZE1 = 0,
+	KCOV_CMP_SIZE2 = 2,
+	KCOV_CMP_SIZE4 = 4,
+	KCOV_CMP_SIZE8 = 6,
+	KCOV_CMP_SIZE_MASK = 6,
+};
+
 #endif /* _LINUX_KCOV_IOCTLS_H */
diff --git a/kernel/kcov.c b/kernel/kcov.c
index cd771993f96f..2abce5dfa2df 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -21,13 +21,21 @@
 #include <linux/kcov.h>
 #include <asm/setup.h>
 
+/* Number of words written per one comparison. */
+#define KCOV_WORDS_PER_CMP 3
+
 /*
  * kcov descriptor (one per opened debugfs file).
  * State transitions of the descriptor:
  *  - initial state after open()
  *  - then there must be a single ioctl(KCOV_INIT_TRACE) call
  *  - then, mmap() call (several calls are allowed but not useful)
- *  - then, repeated enable/disable for a task (only one task a time allowed)
+ *  - then, ioctl(KCOV_ENABLE, arg), where arg is
+ *	KCOV_TRACE_PC - to trace only the PCs
+ *	or
+ *	KCOV_TRACE_CMP - to trace only the comparison operands
+ *  - then, ioctl(KCOV_DISABLE) to disable the task.
+ * Enabling/disabling ioctls can be repeated (only one task a time allowed).
  */
 struct kcov {
 	/*
@@ -47,6 +55,30 @@ struct kcov {
 	struct task_struct	*t;
 };
 
+static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_struct *t)
+{
+	enum kcov_mode mode;
+
+	/*
+	 * We are interested in code coverage as a function of a syscall inputs,
+	 * so we ignore code executed in interrupts.
+	 */
+	if (!t || !in_task())
+		return false;
+	mode = READ_ONCE(t->kcov_mode);
+	/*
+	 * There is some code that runs in interrupts but for which
+	 * in_interrupt() returns false (e.g. preempt_schedule_irq()).
+	 * READ_ONCE()/barrier() effectively provides load-acquire wrt
+	 * interrupts, there are paired barrier()/WRITE_ONCE() in
+	 * kcov_ioctl_locked().
+	 */
+	barrier();
+	if (mode != needed_mode)
+		return false;
+	return true;
+}
+
 /*
  * Entry point from instrumented code.
  * This is called once per basic-block/edge.
@@ -54,44 +86,136 @@ struct kcov {
 void notrace __sanitizer_cov_trace_pc(void)
 {
 	struct task_struct *t;
-	enum kcov_mode mode;
+	unsigned long *area;
+	unsigned long ip = _RET_IP_;
+	unsigned long pos;
 
 	t = current;
-	/*
-	 * We are interested in code coverage as a function of a syscall inputs,
-	 * so we ignore code executed in interrupts.
-	 */
-	if (!t || !in_task())
+	if (!check_kcov_mode(KCOV_MODE_TRACE_PC, t))
 		return;
-	mode = READ_ONCE(t->kcov_mode);
-	if (mode == KCOV_MODE_TRACE) {
-		unsigned long *area;
-		unsigned long pos;
-		unsigned long ip = _RET_IP_;
 
 #ifdef CONFIG_RANDOMIZE_BASE
-		ip -= kaslr_offset();
+	ip -= kaslr_offset();
 #endif
 
-		/*
-		 * There is some code that runs in interrupts but for which
-		 * in_interrupt() returns false (e.g. preempt_schedule_irq()).
-		 * READ_ONCE()/barrier() effectively provides load-acquire wrt
-		 * interrupts, there are paired barrier()/WRITE_ONCE() in
-		 * kcov_ioctl_locked().
-		 */
-		barrier();
-		area = t->kcov_area;
-		/* The first word is number of subsequent PCs. */
-		pos = READ_ONCE(area[0]) + 1;
-		if (likely(pos < t->kcov_size)) {
-			area[pos] = ip;
-			WRITE_ONCE(area[0], pos);
-		}
+	area = t->kcov_area;
+	/* The first word is number of subsequent PCs. */
+	pos = READ_ONCE(area[0]) + 1;
+	if (likely(pos < t->kcov_size)) {
+		area[pos] = ip;
+		WRITE_ONCE(area[0], pos);
 	}
 }
 EXPORT_SYMBOL(__sanitizer_cov_trace_pc);
 
+#ifdef CONFIG_KCOV_ENABLE_COMPARISONS
+static void write_comp_data(u64 type, u64 arg1, u64 arg2)
+{
+	struct task_struct *t;
+	u64 *area;
+	u64 count, start_index, end_pos, max_pos;
+
+	t = current;
+	if (!check_kcov_mode(KCOV_MODE_TRACE_CMP, t))
+		return;
+
+	/*
+	 * We write all comparison arguments and types as u64.
+	 * The buffer was allocated for t->kcov_size unsigned longs.
+	 */
+	area = (u64 *)t->kcov_area;
+	max_pos = t->kcov_size * sizeof(unsigned long);
+
+	count = READ_ONCE(area[0]);
+
+	/* Every record is KCOV_WORDS_PER_CMP words. */
+	start_index = 1 + count * KCOV_WORDS_PER_CMP;
+	end_pos = (start_index + KCOV_WORDS_PER_CMP) * sizeof(u64);
+	if (likely(end_pos <= max_pos)) {
+		area[start_index] = type;
+		area[start_index + 1] = arg1;
+		area[start_index + 2] = arg2;
+		WRITE_ONCE(area[0], count + 1);
+	}
+}
+
+void notrace __sanitizer_cov_trace_cmp1(u8 arg1, u8 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE1, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp1);
+
+void notrace __sanitizer_cov_trace_cmp2(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE2, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp2);
+
+void notrace __sanitizer_cov_trace_cmp4(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE4, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp4);
+
+void notrace __sanitizer_cov_trace_cmp8(u64 arg1, u64 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE8, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp8);
+
+void notrace __sanitizer_cov_trace_const_cmp1(u8 arg1, u8 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE1 | KCOV_CMP_CONST, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp1);
+
+void notrace __sanitizer_cov_trace_const_cmp2(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE2 | KCOV_CMP_CONST, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp2);
+
+void notrace __sanitizer_cov_trace_const_cmp4(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE4 | KCOV_CMP_CONST, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp4);
+
+void notrace __sanitizer_cov_trace_const_cmp8(u64 arg1, u64 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE8 | KCOV_CMP_CONST, arg1, arg2);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp8);
+
+void notrace __sanitizer_cov_trace_switch(u64 val, u64 *cases)
+{
+	u64 i;
+	u64 count = cases[0];
+	u64 size = cases[1];
+	u64 type = KCOV_CMP_CONST;
+
+	switch (size) {
+	case 8:
+		type |= KCOV_CMP_SIZE1;
+		break;
+	case 16:
+		type |= KCOV_CMP_SIZE2;
+		break;
+	case 32:
+		type |= KCOV_CMP_SIZE4;
+		break;
+	case 64:
+		type |= KCOV_CMP_SIZE8;
+		break;
+	default:
+		return;
+	}
+	for (i = 0; i < count; i++)
+		write_comp_data(type, cases[i + 2], val);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_switch);
+#endif /* ifdef CONFIG_KCOV_ENABLE_COMPARISONS */
+
 static void kcov_get(struct kcov *kcov)
 {
 	atomic_inc(&kcov->refcount);
@@ -128,6 +252,7 @@ void kcov_task_exit(struct task_struct *t)
 	/* Just to not leave dangling references behind. */
 	kcov_task_init(t);
 	kcov->t = NULL;
+	kcov->mode = KCOV_MODE_INIT;
 	spin_unlock(&kcov->lock);
 	kcov_put(kcov);
 }
@@ -146,7 +271,7 @@ static int kcov_mmap(struct file *filep, struct vm_area_struct *vma)
 
 	spin_lock(&kcov->lock);
 	size = kcov->size * sizeof(unsigned long);
-	if (kcov->mode == KCOV_MODE_DISABLED || vma->vm_pgoff != 0 ||
+	if (kcov->mode != KCOV_MODE_INIT || vma->vm_pgoff != 0 ||
 	    vma->vm_end - vma->vm_start != size) {
 		res = -EINVAL;
 		goto exit;
@@ -175,6 +300,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
 	kcov = kzalloc(sizeof(*kcov), GFP_KERNEL);
 	if (!kcov)
 		return -ENOMEM;
+	kcov->mode = KCOV_MODE_DISABLED;
 	atomic_set(&kcov->refcount, 1);
 	spin_lock_init(&kcov->lock);
 	filep->private_data = kcov;
@@ -210,7 +336,7 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		if (size < 2 || size > INT_MAX / sizeof(unsigned long))
 			return -EINVAL;
 		kcov->size = size;
-		kcov->mode = KCOV_MODE_TRACE;
+		kcov->mode = KCOV_MODE_INIT;
 		return 0;
 	case KCOV_ENABLE:
 		/*
@@ -220,17 +346,25 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		 * at task exit or voluntary by KCOV_DISABLE. After that it can
 		 * be enabled for another task.
 		 */
-		unused = arg;
-		if (unused != 0 || kcov->mode == KCOV_MODE_DISABLED ||
-		    kcov->area == NULL)
+		if (kcov->mode != KCOV_MODE_INIT || !kcov->area)
 			return -EINVAL;
 		if (kcov->t != NULL)
 			return -EBUSY;
+		if (arg == KCOV_TRACE_PC)
+			kcov->mode = KCOV_MODE_TRACE_PC;
+		else if (arg == KCOV_TRACE_CMP)
+#ifdef CONFIG_KCOV_ENABLE_COMPARISONS
+			kcov->mode = KCOV_MODE_TRACE_CMP;
+#else
+		return -ENOTSUPP;
+#endif
+		else
+			return -EINVAL;
 		t = current;
 		/* Cache in task struct for performance. */
 		t->kcov_size = kcov->size;
 		t->kcov_area = kcov->area;
-		/* See comment in __sanitizer_cov_trace_pc(). */
+		/* See comment in check_kcov_mode(). */
 		barrier();
 		WRITE_ONCE(t->kcov_mode, kcov->mode);
 		t->kcov = kcov;
@@ -248,6 +382,7 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 			return -EINVAL;
 		kcov_task_init(t);
 		kcov->t = NULL;
+		kcov->mode = KCOV_MODE_INIT;
 		kcov_put(kcov);
 		return 0;
 	default:
-- 
2.14.1.581.gf28d330327-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
