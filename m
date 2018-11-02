Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 624A36B0266
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 09:33:10 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y144-v6so2723947itc.5
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 06:33:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id b13-v6si23305016ioc.42.2018.11.02.06.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 06:33:07 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v6 1/3] printk: Add line-buffered printk() API.
Date: Fri,  2 Nov 2018 22:31:55 +0900
Message-Id: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Sometimes we want to print a whole line without being disturbed by
concurrent printk() from interrupts and/or other threads, for printk()
which does not end with '\n' can be disturbed.

Since mixed printk() output makes it hard to interpret, this patch
introduces API for line-buffered printk() output (so that we can make
sure that printk() ends with '\n').

Since functions introduced by this patch are merely wrapping
printk()/vprintk() calls in order to minimize possibility of using
"struct cont", it is safe to replace printk()/vprintk() with this API.
Since we want to remove "struct cont" eventually, we will try to remove
both "implicit printk() users who are expecting KERN_CONT behavior" and
"explicit pr_cont()/printk(KERN_CONT) users". Therefore, converting to
this API is recommended.

Details:

  A structure named "struct printk_buffer" is introduced for buffering
  up to LOG_LINE_MAX bytes of printk() output which did not end with '\n'.

  get_printk_buffer() tries to assign a "struct printk_buffer" from
  statically preallocated array. get_printk_buffer() returns NULL if
  all "struct printk_buffer" are in use, but the caller does not need to
  check for NULL.

  put_printk_buffer() flushes and releases the "struct printk_buffer".
  put_printk_buffer() must match corresponding get_printk_buffer() as with
  rcu_read_unlock() must match corresponding rcu_read_lock().

  Three functions vprintk_buffered(), printk_buffered() and
  flush_printk_buffer() are provided for using "struct printk_buffer".
  These are like vfprintf(), fprintf(), fflush() except that these receive
  "struct printk_buffer *" for the first argument.

  vprintk_buffered() and printk_buffered() fall back to vprintk() and
  printk() respectively if "struct printk_buffer *" argument is NULL.
  flush_printk_buffer() and put_printk_buffer() become no-op if
  "struct printk_buffer *" argument is NULL. Therefore, the caller of
  get_printk_buffer() does not need to check for NULL.

How to use this API:

  (1) Call get_printk_buffer() and acquire "struct printk_buffer *".

  (2) Rewrite printk() calls in the following way. The "ptr" is
      "struct printk_buffer *" obtained in step (1).

      printk(fmt, ...)     => printk_buffered(ptr, fmt, ...)
      vprintk(fmt, args)   => vprintk_buffered(ptr, fmt, args)
      pr_emerg(fmt, ...)   => bpr_emerg(ptr, fmt, ...)
      pr_alert(fmt, ...)   => bpr_alert(ptr, fmt, ...)
      pr_crit(fmt, ...)    => bpr_crit(ptr, fmt, ...)
      pr_err(fmt, ...)     => bpr_err(ptr, fmt, ...)
      pr_warning(fmt, ...) => bpr_warning(ptr, fmt, ...)
      pr_warn(fmt, ...)    => bpr_warn(ptr, fmt, ...)
      pr_notice(fmt, ...)  => bpr_notice(ptr, fmt, ...)
      pr_info(fmt, ...)    => bpr_info(ptr, fmt, ...)
      pr_cont(fmt, ...)    => bpr_cont(ptr, fmt, ...)

  (3) Release "struct printk_buffer" by calling put_printk_buffer().

Note that since "struct printk_buffer" buffers only up to one line, there
is no need to rewrite if it is known that the "struct printk_buffer" is
empty and printk() ends with '\n'.

  Good example:

    printk("Hello ");    =>  buf = get_printk_buffer();
    pr_cont("world.\n");     printk_buffered(buf, "Hello ");
                             printk_buffered(buf, "world.\n");
                             put_printk_buffer(buf);

  Pointless example:

    printk("Hello\n");   =>  buf = get_printk_buffer();
    printk("World.\n");      printk_buffered(buf, "Hello\n");
                             printk_buffered(buf, "World.\n");
                             put_printk_buffer(buf);

Note that bpr_devel() and bpr_debug() are not defined. This is
because pr_devel()/pr_debug() should not be followed by pr_cont()
because pr_devel()/pr_debug() are conditionally enabled; output from
pr_devel()/pr_debug() should always end with '\n'.

Previous version was proposed at
https://lkml.kernel.org/r/1540375870-6235-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp .

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/printk.h          |  43 ++++++++++
 kernel/printk/Makefile          |   2 +-
 kernel/printk/internal.h        |   3 +
 kernel/printk/printk.c          |   3 -
 kernel/printk/printk_buffered.c | 179 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 226 insertions(+), 4 deletions(-)
 create mode 100644 kernel/printk/printk_buffered.c

diff --git a/include/linux/printk.h b/include/linux/printk.h
index cf3eccf..92af345 100644
--- a/include/linux/printk.h
+++ b/include/linux/printk.h
@@ -157,6 +157,7 @@ static inline void printk_nmi_direct_enter(void) { }
 static inline void printk_nmi_direct_exit(void) { }
 #endif /* PRINTK_NMI */
 
+struct printk_buffer;
 #ifdef CONFIG_PRINTK
 asmlinkage __printf(5, 0)
 int vprintk_emit(int facility, int level,
@@ -173,6 +174,20 @@ int printk_emit(int facility, int level,
 
 asmlinkage __printf(1, 2) __cold
 int printk(const char *fmt, ...);
+struct printk_buffer *get_printk_buffer(void);
+bool flush_printk_buffer(struct printk_buffer *ptr);
+__printf(2, 3)
+int printk_buffered(struct printk_buffer *ptr, const char *fmt, ...);
+__printf(2, 0)
+int vprintk_buffered(struct printk_buffer *ptr, const char *fmt, va_list args);
+/*
+ * In order to avoid accidentally reusing "ptr" after put_printk_buffer("ptr"),
+ * put_printk_buffer() is defined as a macro which explicitly resets "ptr" to
+ * NULL.
+ */
+void __put_printk_buffer(struct printk_buffer *ptr);
+#define put_printk_buffer(ptr)					\
+	do { __put_printk_buffer(ptr); ptr = NULL; } while (0)
 
 /*
  * Special printk facility for scheduler/timekeeping use only, _DO_NOT_USE_ !
@@ -220,6 +235,17 @@ int printk(const char *s, ...)
 {
 	return 0;
 }
+static inline struct printk_buffer *get_printk_buffer(void)
+{
+	return NULL;
+}
+static inline bool flush_printk_buffer(struct printk_buffer *ptr)
+{
+	return false;
+}
+#define printk_buffered(ptr, fmt, ...) printk(fmt, ##__VA_ARGS__)
+#define vprintk_buffered(ptr, fmt, args) vprintk(fmt, args)
+#define put_printk_buffer(ptr) do { ptr = NULL; } while (0)
 static inline __printf(1, 2) __cold
 int printk_deferred(const char *s, ...)
 {
@@ -330,6 +356,23 @@ static inline void printk_safe_flush_on_panic(void)
 	no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
 #endif
 
+#define bpr_emerg(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_alert(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_ALERT pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_crit(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_CRIT pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_err(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_ERR pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_warning(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_WARNING pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_warn bpr_warning
+#define bpr_notice(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_NOTICE pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_info(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
+#define bpr_cont(ptr, fmt, ...) \
+	printk_buffered(ptr, KERN_CONT fmt, ##__VA_ARGS__)
 
 /* If you are writing a driver, please use dev_dbg instead */
 #if defined(CONFIG_DYNAMIC_DEBUG)
diff --git a/kernel/printk/Makefile b/kernel/printk/Makefile
index 4a2ffc3..23b1547 100644
--- a/kernel/printk/Makefile
+++ b/kernel/printk/Makefile
@@ -1,3 +1,3 @@
 obj-y	= printk.o
-obj-$(CONFIG_PRINTK)	+= printk_safe.o
+obj-$(CONFIG_PRINTK)	+= printk_safe.o printk_buffered.o
 obj-$(CONFIG_A11Y_BRAILLE_CONSOLE)	+= braille.o
diff --git a/kernel/printk/internal.h b/kernel/printk/internal.h
index 0f18988..5e8c048 100644
--- a/kernel/printk/internal.h
+++ b/kernel/printk/internal.h
@@ -22,6 +22,9 @@
 #define PRINTK_NMI_DIRECT_CONTEXT_MASK	 0x40000000
 #define PRINTK_NMI_CONTEXT_MASK		 0x80000000
 
+#define PREFIX_MAX		32
+#define LOG_LINE_MAX		(1024 - PREFIX_MAX)
+
 extern raw_spinlock_t logbuf_lock;
 
 __printf(5, 0)
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 1b2a029..0b06211 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -421,9 +421,6 @@ __packed __aligned(4)
 static u64 clear_seq;
 static u32 clear_idx;
 
-#define PREFIX_MAX		32
-#define LOG_LINE_MAX		(1024 - PREFIX_MAX)
-
 #define LOG_LEVEL(v)		((v) & 0x07)
 #define LOG_FACILITY(v)		((v) >> 3 & 0xff)
 
diff --git a/kernel/printk/printk_buffered.c b/kernel/printk/printk_buffered.c
new file mode 100644
index 0000000..d181d31
--- /dev/null
+++ b/kernel/printk/printk_buffered.c
@@ -0,0 +1,179 @@
+/* SPDX-License-Identifier: GPL-2.0+ */
+
+#include <linux/types.h> /* DECLARE_BITMAP() */
+#include <linux/printk.h>
+#include "internal.h"
+
+/* A structure for line-buffered printk() output. */
+struct printk_buffer {
+	unsigned short int len; /* Valid bytes in buf[]. */
+	char buf[LOG_LINE_MAX];
+} __aligned(1024);
+
+/*
+ * Number of statically preallocated buffers.
+ *
+ * We can introduce a kernel config option if someone wants to tune this value.
+ * But since "struct printk_buffer" makes difference only when there are
+ * multiple threads concurrently calling printk() which does not end with '\n',
+ * and this API will fallback to normal printk() when all buffers are in use,
+ * it is possible that nobody needs to tune this value.
+ */
+#define NUM_LINE_BUFFERS 16
+
+static struct printk_buffer printk_buffers[NUM_LINE_BUFFERS];
+static DECLARE_BITMAP(printk_buffers_in_use, NUM_LINE_BUFFERS);
+
+/**
+ * get_printk_buffer - Try to get printk_buffer.
+ *
+ * Returns pointer to "struct printk_buffer" on success, NULL otherwise.
+ *
+ * If this function returned "struct printk_buffer", the caller is responsible
+ * for passing it to put_printk_buffer() so that "struct printk_buffer" can be
+ * reused in the future.
+ *
+ * Even if this function returned NULL, the caller does not need to check for
+ * NULL, for passing NULL to printk_buffered() simply acts like normal printk()
+ * and passing NULL to flush_printk_buffer()/put_printk_buffer() is a no-op.
+ */
+struct printk_buffer *get_printk_buffer(void)
+{
+	long i;
+
+	for (i = 0; i < NUM_LINE_BUFFERS; i++) {
+		if (test_and_set_bit_lock(i, printk_buffers_in_use))
+			continue;
+		printk_buffers[i].len = 0;
+		return &printk_buffers[i];
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(get_printk_buffer);
+
+/**
+ * vprintk_buffered - Try to vprintk() in line buffered mode.
+ *
+ * @ptr:  Pointer to "struct printk_buffer". It can be NULL.
+ * @fmt:  printk() format string.
+ * @args: va_list structure.
+ *
+ * Returns the return value of vprintk().
+ *
+ * Try to store to @ptr first. If it fails, flush @ptr and then try to store to
+ * @ptr again. If it still fails, use unbuffered printing.
+ */
+int vprintk_buffered(struct printk_buffer *ptr, const char *fmt, va_list args)
+{
+	va_list tmp_args;
+	int r;
+	int pos;
+
+	if (!ptr)
+		return vprintk(fmt, args);
+	/*
+	 * Skip KERN_CONT here based on an assumption that KERN_CONT will be
+	 * given via "fmt" argument when KERN_CONT is given.
+	 */
+	pos = (printk_get_level(fmt) == 'c') ? 2 : 0;
+	while (true) {
+		va_copy(tmp_args, args);
+		r = vsnprintf(ptr->buf + ptr->len, sizeof(ptr->buf) - ptr->len,
+			      fmt + pos, tmp_args);
+		va_end(tmp_args);
+		if (likely(r + ptr->len < sizeof(ptr->buf)))
+			break;
+		if (!flush_printk_buffer(ptr))
+			return vprintk(fmt, args);
+	}
+	ptr->len += r;
+	/* Flush already completed lines if any. */
+	for (pos = ptr->len - 1; pos >= 0; pos--) {
+		if (ptr->buf[pos] != '\n')
+			continue;
+		ptr->buf[pos++] = '\0';
+		printk("%s\n", ptr->buf);
+		ptr->len -= pos;
+		memmove(ptr->buf, ptr->buf + pos, ptr->len);
+		/* This '\0' will be overwritten by next vsnprintf() above. */
+		ptr->buf[ptr->len] = '\0';
+		break;
+	}
+	return r;
+}
+
+/**
+ * printk_buffered - Try to printk() in line buffered mode.
+ *
+ * @ptr: Pointer to "struct printk_buffer". It can be NULL.
+ * @fmt: printk() format string, followed by arguments.
+ *
+ * Returns the return value of printk().
+ *
+ * Try to store to @ptr first. If it fails, flush @ptr and then try to store to
+ * @ptr again. If it still fails, use unbuffered printing.
+ */
+int printk_buffered(struct printk_buffer *ptr, const char *fmt, ...)
+{
+	va_list args;
+	int r;
+
+	va_start(args, fmt);
+	r = vprintk_buffered(ptr, fmt, args);
+	va_end(args);
+	return r;
+}
+EXPORT_SYMBOL(printk_buffered);
+
+/**
+ * flush_printk_buffer - Flush incomplete line in printk_buffer.
+ *
+ * @ptr: Pointer to "struct printk_buffer". It can be NULL.
+ *
+ * Returns true if flushed something, false otherwise.
+ *
+ * Flush if @ptr contains partial data. But usually there is no need to call
+ * this function because @ptr is flushed by put_printk_buffer().
+ */
+bool flush_printk_buffer(struct printk_buffer *ptr)
+{
+	if (!ptr || !ptr->len)
+		return false;
+	/*
+	 * vprintk_buffered() keeps 0 <= ptr->len < sizeof(ptr->buf) true.
+	 * But ptr->buf[ptr->len] != '\0' if this function is called due to
+	 * vsnprintf() + ptr->len >= sizeof(ptr->buf).
+	 */
+	ptr->buf[ptr->len] = '\0';
+	printk("%s", ptr->buf);
+	ptr->len = 0;
+	return true;
+}
+EXPORT_SYMBOL(flush_printk_buffer);
+
+/**
+ * __put_printk_buffer - Release printk_buffer.
+ *
+ * @ptr: Pointer to "struct printk_buffer". It can be NULL.
+ *
+ * Returns nothing.
+ *
+ * Flush and release @ptr.
+ * Please use put_printk_buffer() in order to catch use-after-free bugs.
+ */
+void __put_printk_buffer(struct printk_buffer *ptr)
+{
+	long i = (unsigned long) ptr - (unsigned long) printk_buffers;
+
+	if (!ptr)
+		return;
+	if (WARN_ON_ONCE(i % sizeof(struct printk_buffer)))
+		return;
+	i /= sizeof(struct printk_buffer);
+	if (WARN_ON_ONCE(i < 0 || i >= NUM_LINE_BUFFERS))
+		return;
+	if (ptr->len)
+		flush_printk_buffer(ptr);
+	clear_bit_unlock(i, printk_buffers_in_use);
+}
+EXPORT_SYMBOL(__put_printk_buffer);
-- 
1.8.3.1
