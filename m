Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C17E6B026E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:27:40 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so32666487wmb.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:27:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j28sor2775301wrd.87.2017.10.10.08.27.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 08:27:37 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v3 1/3] kcov: support comparison operands collection
Date: Tue, 10 Oct 2017 17:27:29 +0200
Message-Id: <20171010152731.26031-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mark.rutland@arm.com, alex.popov@linux.com, aryabinin@virtuozzo.com, quentin.casasnovas@oracle.com, dvyukov@google.com, andreyknvl@google.com, keescook@chromium.org, vegard.nossum@oracle.com
Cc: syzkaller@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
Signed-off-by: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
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

v3: - fix Mark Rutland's comments: drop KCOV_CMP_SIZEx,
      added canonicalize_ip(), other minor changes
v2: - fix wording (as suggested by Mark Rutland)
    - store caller PCs (as suggested by Andrey Konovalov)
---
 include/linux/kcov.h      |  12 ++-
 include/uapi/linux/kcov.h |  24 ++++++
 kernel/kcov.c             | 216 ++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 212 insertions(+), 40 deletions(-)

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
index 574e22ec640d..33b826b9946e 100644
--- a/include/uapi/linux/kcov.h
+++ b/include/uapi/linux/kcov.h
@@ -7,4 +7,28 @@
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
+ * The format for the types of collected comparisons.
+ *
+ * Bit 0 shows whether one of the arguments is a compile-time constant.
+ * Bits 1 & 2 contain log2 of the argument size, up to 8 bytes.
+ */
+#define KCOV_CMP_CONST          (1 << 0)
+#define KCOV_CMP_SIZE(n)        ((n) << 1)
+#define KCOV_CMP_MASK           KCOV_CMP_SIZE(3)
+
 #endif /* _LINUX_KCOV_IOCTLS_H */
diff --git a/kernel/kcov.c b/kernel/kcov.c
index 3f693a0f6f3e..461c55e09c69 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -21,13 +21,21 @@
 #include <linux/kcov.h>
 #include <asm/setup.h>
 
+/* Number of 64-bit words written per one comparison: */
+#define KCOV_WORDS_PER_CMP 4
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
@@ -47,51 +55,176 @@ struct kcov {
 	struct task_struct	*t;
 };
 
-/*
- * Entry point from instrumented code.
- * This is called once per basic-block/edge.
- */
-void notrace __sanitizer_cov_trace_pc(void)
+static bool check_kcov_mode(enum kcov_mode needed_mode, struct task_struct *t)
 {
-	struct task_struct *t;
 	enum kcov_mode mode;
 
-	t = current;
 	/*
 	 * We are interested in code coverage as a function of a syscall inputs,
 	 * so we ignore code executed in interrupts.
 	 */
-	if (!t || !in_task())
-		return;
+	if (!in_task())
+		return false;
 	mode = READ_ONCE(t->kcov_mode);
-	if (mode == KCOV_MODE_TRACE) {
-		unsigned long *area;
-		unsigned long pos;
-		unsigned long ip = _RET_IP_;
+	/*
+	 * There is some code that runs in interrupts but for which
+	 * in_interrupt() returns false (e.g. preempt_schedule_irq()).
+	 * READ_ONCE()/barrier() effectively provides load-acquire wrt
+	 * interrupts, there are paired barrier()/WRITE_ONCE() in
+	 * kcov_ioctl_locked().
+	 */
+	barrier();
+	return mode == needed_mode;
+}
 
+static unsigned long canonicalize_ip(unsigned long ip)
+{
 #ifdef CONFIG_RANDOMIZE_BASE
-		ip -= kaslr_offset();
+	ip -= kaslr_offset();
 #endif
+	return ip;
+}
 
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
+/*
+ * Entry point from instrumented code.
+ * This is called once per basic-block/edge.
+ */
+void notrace __sanitizer_cov_trace_pc(void)
+{
+	struct task_struct *t;
+	unsigned long *area;
+	unsigned long ip = canonicalize_ip(_RET_IP_);
+	unsigned long pos;
+
+	t = current;
+	if (!check_kcov_mode(KCOV_MODE_TRACE_PC, t))
+		return;
+
+	area = t->kcov_area;
+	/* The first 64-bit word is the number of subsequent PCs. */
+	pos = READ_ONCE(area[0]) + 1;
+	if (likely(pos < t->kcov_size)) {
+		area[pos] = ip;
+		WRITE_ONCE(area[0], pos);
 	}
 }
 EXPORT_SYMBOL(__sanitizer_cov_trace_pc);
 
+#ifdef CONFIG_KCOV_ENABLE_COMPARISONS
+static void write_comp_data(u64 type, u64 arg1, u64 arg2, u64 ip)
+{
+	struct task_struct *t;
+	u64 *area;
+	u64 count, start_index, end_pos, max_pos;
+
+	t = current;
+	if (!check_kcov_mode(KCOV_MODE_TRACE_CMP, t))
+		return;
+
+	ip = canonicalize_ip(ip);
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
+	/* Every record is KCOV_WORDS_PER_CMP 64-bit words. */
+	start_index = 1 + count * KCOV_WORDS_PER_CMP;
+	end_pos = (start_index + KCOV_WORDS_PER_CMP) * sizeof(u64);
+	if (likely(end_pos <= max_pos)) {
+		area[start_index] = type;
+		area[start_index + 1] = arg1;
+		area[start_index + 2] = arg2;
+		area[start_index + 3] = ip;
+		WRITE_ONCE(area[0], count + 1);
+	}
+}
+
+void notrace __sanitizer_cov_trace_cmp1(u8 arg1, u8 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(0), arg1, arg2, _RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp1);
+
+void notrace __sanitizer_cov_trace_cmp2(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(1), arg1, arg2, _RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp2);
+
+void notrace __sanitizer_cov_trace_cmp4(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(2), arg1, arg2, _RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp4);
+
+void notrace __sanitizer_cov_trace_cmp8(u64 arg1, u64 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(3), arg1, arg2, _RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_cmp8);
+
+void notrace __sanitizer_cov_trace_const_cmp1(u8 arg1, u8 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(0) | KCOV_CMP_CONST, arg1, arg2,
+			_RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp1);
+
+void notrace __sanitizer_cov_trace_const_cmp2(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(1) | KCOV_CMP_CONST, arg1, arg2,
+			_RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp2);
+
+void notrace __sanitizer_cov_trace_const_cmp4(u16 arg1, u16 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(2) | KCOV_CMP_CONST, arg1, arg2,
+			_RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_const_cmp4);
+
+void notrace __sanitizer_cov_trace_const_cmp8(u64 arg1, u64 arg2)
+{
+	write_comp_data(KCOV_CMP_SIZE(3) | KCOV_CMP_CONST, arg1, arg2,
+			_RET_IP_);
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
+		type |= KCOV_CMP_SIZE(0);
+		break;
+	case 16:
+		type |= KCOV_CMP_SIZE(1);
+		break;
+	case 32:
+		type |= KCOV_CMP_SIZE(2);
+		break;
+	case 64:
+		type |= KCOV_CMP_SIZE(3);
+		break;
+	default:
+		return;
+	}
+	for (i = 0; i < count; i++)
+		write_comp_data(type, cases[i + 2], val, _RET_IP_);
+}
+EXPORT_SYMBOL(__sanitizer_cov_trace_switch);
+#endif /* ifdef CONFIG_KCOV_ENABLE_COMPARISONS */
+
 static void kcov_get(struct kcov *kcov)
 {
 	atomic_inc(&kcov->refcount);
@@ -128,6 +261,7 @@ void kcov_task_exit(struct task_struct *t)
 	/* Just to not leave dangling references behind. */
 	kcov_task_init(t);
 	kcov->t = NULL;
+	kcov->mode = KCOV_MODE_INIT;
 	spin_unlock(&kcov->lock);
 	kcov_put(kcov);
 }
@@ -146,7 +280,7 @@ static int kcov_mmap(struct file *filep, struct vm_area_struct *vma)
 
 	spin_lock(&kcov->lock);
 	size = kcov->size * sizeof(unsigned long);
-	if (kcov->mode == KCOV_MODE_DISABLED || vma->vm_pgoff != 0 ||
+	if (kcov->mode != KCOV_MODE_INIT || vma->vm_pgoff != 0 ||
 	    vma->vm_end - vma->vm_start != size) {
 		res = -EINVAL;
 		goto exit;
@@ -175,6 +309,7 @@ static int kcov_open(struct inode *inode, struct file *filep)
 	kcov = kzalloc(sizeof(*kcov), GFP_KERNEL);
 	if (!kcov)
 		return -ENOMEM;
+	kcov->mode = KCOV_MODE_DISABLED;
 	atomic_set(&kcov->refcount, 1);
 	spin_lock_init(&kcov->lock);
 	filep->private_data = kcov;
@@ -210,7 +345,7 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 		if (size < 2 || size > INT_MAX / sizeof(unsigned long))
 			return -EINVAL;
 		kcov->size = size;
-		kcov->mode = KCOV_MODE_TRACE;
+		kcov->mode = KCOV_MODE_INIT;
 		return 0;
 	case KCOV_ENABLE:
 		/*
@@ -220,17 +355,25 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
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
@@ -248,6 +391,7 @@ static int kcov_ioctl_locked(struct kcov *kcov, unsigned int cmd,
 			return -EINVAL;
 		kcov_task_init(t);
 		kcov->t = NULL;
+		kcov->mode = KCOV_MODE_INIT;
 		kcov_put(kcov);
 		return 0;
 	default:
-- 
2.14.2.920.gcf0c67979c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
