Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6C16B00EA
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 08:53:48 -0400 (EDT)
Received: by mail-ew0-f41.google.com with SMTP id 9so1637748ewy.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 05:53:45 -0700 (PDT)
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v3 3/5] mm: implement kernel_access_ok
Date: Thu, 21 Jul 2011 16:53:40 +0400
Message-Id: <1311252820-6781-1-git-send-email-segoon@openwall.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Mike Frysinger <vapier@gentoo.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Howells <dhowells@redhat.com>, Akira Takeuchi <takeuchi.akr@jp.panasonic.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>

Introduce stack_access_ok() which checks whether the supplied buffer
overflows or underflows the stack.  Additionally it calls
arch_check_object_on_stack_frame() which should do architecture specific
check whether the buffer fully fits in a single stack frame.  Otherwise
arch_check_object_on_stack_frame() does nothing and returns true.  This
function will be implemented in the following patch for x86.

The checks should be implemented for copy_{to,from}_user() and similar,
but not for {put,get}_user() and similar because the base pointer might
be a result of any pointer arithmetics, and the correctness of these
arithmetics is almost impossible to check on this stage.  If the
real object size is known at the compile time, the check is reduced to 2
integers comparison.  If the supplied length argument is known at the
compile time, the check is skipped because the only thing that can be
under attacker's control is object pointer and checking for errors as a
result of wrong pointer arithmetic is beyond patch's goals.

The limitations:

The stack check does nothing with local variables overwriting and 
saved registers.  It only limits overflows to a single frame.

The SL*B checks don't validate whether the object is actually allocated.
So, it doesn't prevent infoleaks related to the freed objects.  Also if
the cache's granularity is larger than an actual allocated object size,
an infoleak of padding bytes is possible.  The slob check is missing yet.
Unfortunately, the check for slob would have to (1) walk through the
slob chunks and (2) hold the slob lock, so it would lead to a
significant slowdown.

The patch's goal is similar to StackGuard (-fstack-protector gcc option,
enabled by CONFIG_CC_STACKPROTECTOR): catch buffer oveflows.  However,
the design is completely different.  First, SG does nothing with
overreads, it can catch overwrites only.  Second, SG cannot catch SL*B
buffer overflows.  Third, SG checks the canary after a buffer is
overflowed instead of preventing an actual overflow attempt; when an
attacker overflows a stack buffer, he can uncontrolledly wipe some data
on the stack before the function return.  If attacker's actions generate
kernel oops before the return, SG would not get the control and the
overflow is not catched as if SG is disabled.  However, SG can catch
overflows of memcpy(), strcpy(), sprintf() and other functions working
with kernel data only, which are not caught by RUNTIME_USER_COPY_CHECK.

The checks can be easily implemented by any architecture by including
<linux/uaccess-check.h> and adding kernel_access_ok() checks into
{,__}copy_{to,from}_user().

All users of copy_*_user_unchecked() should explicitly include
<linux/uaccess-check.h> until all arch/*/include/asm/uaccess.h start to
include this header.  mm/maccess.c needs this include for the same
reason.

v3 - Simplified addition of new architectures.
   - Now log the copy direction (from/to user) on overflows.
   - Used __always_inline.
   - Moved "len == 0" check to kernel_access_ok().

v2 - Moved the checks to kernel_access_ok().
   - If the object size is known at the compilation time, just compare
     length and object size.
   - Check only if length value is not known at the compilation time.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/linux/uaccess-check.h |   70 +++++++++++++++++++++++++++++++++++++++++
 mm/maccess.c                  |   48 ++++++++++++++++++++++++++++
 2 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/include/linux/uaccess-check.h b/include/linux/uaccess-check.h
new file mode 100644
index 0000000..9c03b98
--- /dev/null
+++ b/include/linux/uaccess-check.h
@@ -0,0 +1,70 @@
+#ifndef __LINUX_UACCESS_CHECK_H__
+#define __LINUX_UACCESS_CHECK_H__
+
+#include <linux/kernel.h>
+
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+
+static inline void usercopy_alert(const void *ptr, unsigned long len,
+				  bool to_user)
+{
+	pr_err("kernel memory %s attempt detected %s %p (%lu bytes)\n",
+		to_user ? "leak" : "overwrite", to_user ? "from" : "to",
+		ptr, len);
+	dump_stack();
+}
+
+extern bool __kernel_access_ok(const void *ptr, unsigned long len,
+				bool to_user);
+
+static __always_inline
+bool kernel_access_ok(const void *ptr, unsigned long len, bool to_user)
+{
+	size_t sz = __compiletime_object_size(ptr);
+
+	if (sz != (size_t)-1) {
+		if (sz >= len)
+			return true;
+		usercopy_alert(ptr, len, to_user);
+		return false;
+	}
+
+	/* We care about "len" overflows only. */
+	if (__builtin_constant_p(len) || len == 0)
+		return true;
+
+	return __kernel_access_ok(ptr, len, to_user);
+}
+
+#else
+
+static inline
+bool kernel_access_ok(const void *ptr, unsigned long len, bool to_user)
+{
+	return true;
+}
+
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
+
+/*
+ * If some arch wants to implement RUNTIME_USER_COPY_CHECKS
+ * it should redefine these 2 _unchecked symbols for direct
+ * copying for /dev/mem and /dev/kmem.
+ */
+#ifndef copy_to_user_unchecked
+#define copy_to_user_unchecked copy_to_user
+#endif
+
+#ifndef copy_from_user_unchecked
+#define copy_from_user_unchecked copy_from_user
+#endif
+
+/*
+ * If arch has knowledge about stack frames (like x86 without
+ * -fomit-frame-pointers), it should redefine this function.
+ */
+#ifndef arch_check_object_on_stack_frame
+#define arch_check_object_on_stack_frame(s, se, o, len) true
+#endif
+
+#endif		/* __LINUX_UACCESS_CHECK_H__ */
diff --git a/mm/maccess.c b/mm/maccess.c
index 4cee182..6b78f25 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -4,6 +4,9 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 #include <linux/uaccess.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/uaccess-check.h>
 
 /**
  * probe_kernel_read(): safely attempt to read from a location
@@ -60,3 +63,48 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
 	return ret ? -EFAULT : 0;
 }
 EXPORT_SYMBOL_GPL(probe_kernel_write);
+
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+/*
+ * stack_access_ok() checks whether object is on the stack and
+ * whether it fits in a single stack frame (in case arch allows
+ * to learn this information).
+ *
+ * Returns true in cases:
+ * a) object is not a stack object at all
+ * b) object is located on the stack and fits in a single frame
+ *
+ * MUST be inline not to confuse arch_check_object_on_stack_frame.
+ */
+static __always_inline bool
+stack_access_ok(const void *obj, unsigned long len)
+{
+	const void * const stack = task_stack_page(current);
+	const void * const stackend = stack + THREAD_SIZE;
+
+	/* Does obj+len overflow vm space? */
+	if (unlikely(obj + len < obj))
+		return false;
+
+	/* Does [obj; obj+len) at least touch our stack? */
+	if (unlikely(obj + len <= stack || stackend <= obj))
+		return true;
+
+	/* Does [obj; obj+len) overflow/underflow the stack? */
+	if (unlikely(obj < stack || stackend < obj + len))
+		return false;
+
+	return arch_check_object_on_stack_frame(stack, stackend, obj, len);
+}
+
+bool __kernel_access_ok(const void *ptr, unsigned long len, bool to_user)
+{
+	if (!slab_access_ok(ptr, len) || !stack_access_ok(ptr, len)) {
+		usercopy_alert(ptr, len, to_user);
+		return false;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(__kernel_access_ok);
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
