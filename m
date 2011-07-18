Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9F38F6B00FB
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 14:40:03 -0400 (EDT)
Received: by eyg7 with SMTP id 7so2782919eyg.41
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 11:39:58 -0700 (PDT)
Date: Mon, 18 Jul 2011 22:39:51 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v2] implement SL*B and stack usercopy runtime checks
Message-ID: <20110718183951.GA3748@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

This patch implements 2 additional checks for the data copied from
kernelspace to userspace and vice versa (original PAX_USERCOPY from PaX
patch).  Currently there are some very simple and cheap comparisons of
supplied size and the size of a copied object known at the compile time
in copy_* functions.  This patch enhances these checks to check against
stack frame boundaries and against SL*B object sizes.

More precisely, it checks:

1) if the data touches the stack, checks whether it fully fits in the stack
and whether it fully fits in a single stack frame.  The latter is arch
dependent, currently it is implemented for x86 with CONFIG_FRAME_POINTER=y
only.  It limits infoleaks/overwrites to a single frame and local variables
only, and prevents saved return instruction pointer overwriting.

2) if the data is from the SL*B cache, checks whether it fully fits in a
slab page and whether it overflows a slab object.  E.g. if the memory
was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
bytes, the copy would fail.

The checks are implemented for copy_{to,from}_user() and similar and are
missing for {put,get}_user() and similar because the base pointer might
be a result of any pointer arithmetics, and the correctness of these
arithmetics is almost impossible to check on this stage.  If the
real object size is known at the compile time, the check is reduced to 2
integers comparison.  If the supplied length argument is known at the
compile time, the check is skipped because the only thing that can be
under attacker's control is object pointer and checking for errors as a
result of wrong pointer arithmetic is beyond patch's goals.

/dev/kmem and /dev/mem are fixed to pass this check (e.g. without
STRICT_DEVMEM it should be possible to overflow the stack frame and slab
objects).

The slowdown is negligible for most workflows - for some cases it is
reduced to integer comparison (in fstat, getrlimit, ipc), for some cases
the whole syscall time and the time of a check are not comparable (in
write, path traversal functions), for programs with not intensive
syscalls usage.  One of the most significant slowdowns is gethostname(),
the penalty is 0,9%.  For 'find /usr', 'git log -Sredirect' in kernel
tree, kernel compilation, file copying the slowdown is less than 0,1%
(couldn't measure it more precisely).

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

The patch does nothing with other memory areas like vmalloc'ed areas,
modules' data and code sections, etc.  It can be an area for
improvements.

The patch's goal is similar to StackGuard (-fstack-protector gcc option,
enabled by CONFIG_CC_STACKPROTECTOR): catch buffer oveflows.
However, the design is completely different.  First, SG does nothing
with overreads, it can catch overwrites only.  Second, SG cannot catch
SL*B buffer overflows.  Third, SG checks the canary after a buffer is
overflowed instead of preventing an actual overflow attempt; when an attacker
overflows a stack buffer, he can uncontrolledly wipe some data on the
stack before the function return.  If attacker's actions generate kernel
oops before the return, SG would not get the control and the overflow is
not catched as if SG is disabled.  However, SG can catch oveflows of
memcpy(), strcpy(), sprintf() and other functions working with kernel
data only, which are not caught by RUNTIME_USER_COPY_CHECK.

The checks are implemented for x86, it can be easily extended to other
architectues by including <linux/uaccess-check.h> and adding
kernel_access_ok() checks into {,__}copy_{to,from}_user().

The patch is a forwardport of the PAX_USERCOPY feature from the PaX
patch.  Most code was copied from the PaX patch with minor cosmetic
changes.  Also PaX' version of the patch has additional restrictions:

a) some slab caches has SLAB_USERCOPY flag set and copies to/from the slab
caches without the flag are denied.  Rare cases where some bytes needed
from the caches missing in the white list are handled by copying the
bytes into temporary area on the stack/heap.

b) if a malformed copy request is spotted, the event is logged and
SIGKILL signal is sent to the current task.

Examples of overflows, which become nonexploitable with RUNTIME_USER_COPY_CHECK:
DCCP getsockopt copy_to_user() overflow (fixed in 39ebc0276b),
L2TP memcpy_fromiovec() overflow (fixed in 53eacc070b),
64kb iwconfig infoleak (fixed in 42da2f948d, was found by PAX_USERCOPY).


Questions/thoughts:

Should this code put in action some reacting mechanisms?  Probably it is
a job of userspace monitoring daemon (similar to segvguard), but the
kernel's reaction would be race free and much more timely.

v2: - Moved the checks to kernel_access_ok().
    - If the object size is known at the compilation time, just compare
      length and object size.
    - Check only if length value is not known at the compilation time.
    - Provided performance results.

---
 arch/x86/include/asm/uaccess.h    |   49 ++++++++++++++++++++++++++++++++
 arch/x86/include/asm/uaccess_32.h |   29 +++++++++++++++++--
 arch/x86/include/asm/uaccess_64.h |   36 ++++++++++++++++++++++-
 arch/x86/lib/usercopy_32.c        |    2 +-
 drivers/char/mem.c                |    8 ++--
 include/linux/uaccess-check.h     |   37 ++++++++++++++++++++++++
 lib/Kconfig.debug                 |   22 ++++++++++++++
 mm/maccess.c                      |   56 +++++++++++++++++++++++++++++++++++++
 mm/slab.c                         |   34 ++++++++++++++++++++++
 mm/slob.c                         |   10 ++++++
 mm/slub.c                         |   28 ++++++++++++++++++
 11 files changed, 301 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 99ddd14..96bad6c 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -9,6 +9,7 @@
 #include <linux/string.h>
 #include <asm/asm.h>
 #include <asm/page.h>
+#include <linux/uaccess-check.h>
 
 #define VERIFY_READ 0
 #define VERIFY_WRITE 1
@@ -78,6 +79,54 @@
  */
 #define access_ok(type, addr, size) (likely(__range_not_ok(addr, size) == 0))
 
+#if defined(CONFIG_FRAME_POINTER)
+/*
+ * MUST be always_inline to correctly count stack frame numbers.
+ *
+ * low ----------------------------------------------> high
+ * [saved bp][saved ip][args][local vars][saved bp][saved ip]
+ *		       ^----------------^
+ *		  allow copies only within here
+*/
+#undef arch_check_object_on_stack_frame
+inline static __attribute__((always_inline))
+bool arch_check_object_on_stack_frame(const void *stack,
+	     const void *stackend, const void *obj, unsigned long len)
+{
+	const void *frame = NULL;
+	const void *oldframe;
+
+	/*
+	 * Get the kernel_access_ok() caller frame.
+	 * __builtin_frame_address(0) returns kernel_access_ok() frame
+	 * as arch_ and stack_ are inline and kernel_ is noinline.
+	 */
+	oldframe = __builtin_frame_address(0);
+	if (oldframe)
+		frame = __builtin_frame_address(1);
+
+	while (stack <= frame && frame < stackend) {
+		/*
+		 * If obj + len extends past the last frame, this
+		 * check won't pass and the next frame will be 0,
+		 * causing us to bail out and correctly report
+		 * the copy as invalid.
+		 */
+		if (obj + len <= frame) {
+			/* EBP + EIP */
+			int protected_regs_size = 2*sizeof(void *);
+
+			if (obj >= oldframe + protected_regs_size)
+				return true;
+			return false;
+		}
+		oldframe = frame;
+		frame = *(const void * const *)frame;
+	}
+	return false;
+}
+#endif
+
 /*
  * The exception table consists of pairs of addresses: the first is the
  * address of an instruction that is allowed to fault, and the second is
diff --git a/arch/x86/include/asm/uaccess_32.h b/arch/x86/include/asm/uaccess_32.h
index 566e803..d48fa9c 100644
--- a/arch/x86/include/asm/uaccess_32.h
+++ b/arch/x86/include/asm/uaccess_32.h
@@ -82,6 +82,8 @@ static __always_inline unsigned long __must_check
 __copy_to_user(void __user *to, const void *from, unsigned long n)
 {
 	might_fault();
+	if (!kernel_access_ok(from, n))
+		return n;
 	return __copy_to_user_inatomic(to, from, n);
 }
 
@@ -152,6 +154,8 @@ __copy_from_user(void *to, const void __user *from, unsigned long n)
 			return ret;
 		}
 	}
+	if (!kernel_access_ok(to, n))
+		return n;
 	return __copy_from_user_ll(to, from, n);
 }
 
@@ -205,11 +209,30 @@ static inline unsigned long __must_check copy_from_user(void *to,
 {
 	int sz = __compiletime_object_size(to);
 
-	if (likely(sz == -1 || sz >= n))
-		n = _copy_from_user(to, from, n);
-	else
+	if (likely(sz == -1 || sz >= n)) {
+		if (kernel_access_ok(to, n))
+			n = _copy_from_user(to, from, n);
+	} else {
 		copy_from_user_overflow();
+	}
+
+	return n;
+}
+
+#undef copy_from_user_uncheched
+static inline unsigned long __must_check copy_from_user_uncheched(void *to,
+					  const void __user *from,
+					  unsigned long n)
+{
+	return _copy_from_user(to, from, n);
+}
 
+#undef copy_to_user_uncheched
+static inline unsigned long copy_to_user_unchecked(void __user *to,
+     const void *from, unsigned long n)
+{
+	if (access_ok(VERIFY_WRITE, to, n))
+		n = __copy_to_user(to, from, n);
 	return n;
 }
 
diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index 1c66d30..10c5a0a 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -50,8 +50,10 @@ static inline unsigned long __must_check copy_from_user(void *to,
 	int sz = __compiletime_object_size(to);
 
 	might_fault();
-	if (likely(sz == -1 || sz >= n))
-		n = _copy_from_user(to, from, n);
+	if (likely(sz == -1 || sz >= n)) {
+		if (kernel_access_ok(to, n))
+			n = _copy_from_user(to, from, n);
+	}
 #ifdef CONFIG_DEBUG_VM
 	else
 		WARN(1, "Buffer overflow detected!\n");
@@ -59,11 +61,33 @@ static inline unsigned long __must_check copy_from_user(void *to,
 	return n;
 }
 
+#undef copy_from_user_unchecked
+static inline unsigned long __must_check copy_from_user_unchecked(void *to,
+					  const void __user *from,
+					  unsigned long n)
+{
+	might_fault();
+
+	return _copy_from_user(to, from, n);
+}
+
 static __always_inline __must_check
 int copy_to_user(void __user *dst, const void *src, unsigned size)
 {
 	might_fault();
 
+	if (!kernel_access_ok(src, size))
+		return size;
+
+	return _copy_to_user(dst, src, size);
+}
+
+#undef copy_to_user_unchecked
+static __always_inline __must_check
+int copy_to_user_unchecked(void __user *dst, const void *src, unsigned size)
+{
+	might_fault();
+
 	return _copy_to_user(dst, src, size);
 }
 
@@ -73,8 +97,12 @@ int __copy_from_user(void *dst, const void __user *src, unsigned size)
 	int ret = 0;
 
 	might_fault();
+	if (!kernel_access_ok(dst, size))
+		return size;
+
 	if (!__builtin_constant_p(size))
 		return copy_user_generic(dst, (__force void *)src, size);
+
 	switch (size) {
 	case 1:__get_user_asm(*(u8 *)dst, (u8 __user *)src,
 			      ret, "b", "b", "=q", 1);
@@ -117,8 +145,12 @@ int __copy_to_user(void __user *dst, const void *src, unsigned size)
 	int ret = 0;
 
 	might_fault();
+	if (!kernel_access_ok(dst, size))
+		return size;
+
 	if (!__builtin_constant_p(size))
 		return copy_user_generic((__force void *)dst, src, size);
+
 	switch (size) {
 	case 1:__put_user_asm(*(u8 *)src, (u8 __user *)dst,
 			      ret, "b", "b", "iq", 1);
diff --git a/arch/x86/lib/usercopy_32.c b/arch/x86/lib/usercopy_32.c
index e218d5d..e136309 100644
--- a/arch/x86/lib/usercopy_32.c
+++ b/arch/x86/lib/usercopy_32.c
@@ -851,7 +851,7 @@ EXPORT_SYMBOL(__copy_from_user_ll_nocache_nozero);
 unsigned long
 copy_to_user(void __user *to, const void *from, unsigned long n)
 {
-	if (access_ok(VERIFY_WRITE, to, n))
+	if (access_ok(VERIFY_WRITE, to, n) && kernel_access_ok(from, n))
 		n = __copy_to_user(to, from, n);
 	return n;
 }
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 8fc04b4..77c93d4 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -132,7 +132,7 @@ static ssize_t read_mem(struct file *file, char __user *buf,
 		if (!ptr)
 			return -EFAULT;
 
-		remaining = copy_to_user(buf, ptr, sz);
+		remaining = copy_to_user_unchecked(buf, ptr, sz);
 		unxlate_dev_mem_ptr(p, ptr);
 		if (remaining)
 			return -EFAULT;
@@ -190,7 +190,7 @@ static ssize_t write_mem(struct file *file, const char __user *buf,
 			return -EFAULT;
 		}
 
-		copied = copy_from_user(ptr, buf, sz);
+		copied = copy_from_user_unchecked(ptr, buf, sz);
 		unxlate_dev_mem_ptr(p, ptr);
 		if (copied) {
 			written += sz - copied;
@@ -428,7 +428,7 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
 			 */
 			kbuf = xlate_dev_kmem_ptr((char *)p);
 
-			if (copy_to_user(buf, kbuf, sz))
+			if (copy_to_user_unchecked(buf, kbuf, sz))
 				return -EFAULT;
 			buf += sz;
 			p += sz;
@@ -498,7 +498,7 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
 		 */
 		ptr = xlate_dev_kmem_ptr((char *)p);
 
-		copied = copy_from_user(ptr, buf, sz);
+		copied = copy_from_user_unchecked(ptr, buf, sz);
 		if (copied) {
 			written += sz - copied;
 			if (written)
diff --git a/include/linux/uaccess-check.h b/include/linux/uaccess-check.h
new file mode 100644
index 0000000..5592a3e
--- /dev/null
+++ b/include/linux/uaccess-check.h
@@ -0,0 +1,37 @@
+#ifndef __LINUX_UACCESS_CHECK_H__
+#define __LINUX_UACCESS_CHECK_H__
+
+#ifdef CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS
+extern bool __kernel_access_ok(const void *ptr, unsigned long len);
+static inline bool kernel_access_ok(const void *ptr, unsigned long len)
+{
+	size_t sz = __compiletime_object_size(ptr);
+
+	if (sz != (size_t)-1) {
+		if (sz >= len)
+			return true;
+		pr_alert("kernel_access_ok(static) failed, ptr = %p, length = %lu\n",
+			ptr, len);
+		dump_stack();
+		return false;
+	}
+
+	/* We care about "len" overflows only. */
+	if (__builtin_constant_p(len))
+		return true;
+
+	return __kernel_access_ok(ptr, len);
+}
+#else
+static inline bool kernel_access_ok(const void *ptr, unsigned long len)
+{
+	return true;
+}
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
+
+#define copy_to_user_unchecked copy_to_user
+#define copy_from_user_unchecked copy_from_user
+
+#define arch_check_object_on_stack_frame(s,se,o,len) true
+
+#endif		/* __LINUX_UACCESS_CHECK_H__ */
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index dd373c8..ed266b6 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -679,6 +679,28 @@ config DEBUG_STACK_USAGE
 
 	  This option will slow down process creation somewhat.
 
+config DEBUG_RUNTIME_USER_COPY_CHECKS
+	bool "Runtime usercopy size checks"
+	default n
+	depends on DEBUG_KERNEL && X86
+	---help---
+	  Enabling this option adds additional runtime checks into copy_from_user()
+	  and similar functions.
+
+	  Specifically, if the data touches the stack, it checks whether a copied
+	  memory chunk fully fits in the stack. If CONFIG_FRAME_POINTER=y, also
+	  checks whether it fully fits in a single stack frame. It limits
+	  infoleaks/overwrites to a single frame and local variables
+	  only, and prevents saved return instruction pointer overwriting.
+
+	  If the data is from the SL*B cache, checks whether it fully fits in a
+	  slab page and whether it overflows a slab object.  E.g. if the memory
+	  was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
+	  bytes, the copy would fail.
+
+	  The option has a minimal performance drawback (up to 1% on tiny syscalls
+	  like gethostname).
+
 config DEBUG_KOBJECT
 	bool "kobject debugging"
 	depends on DEBUG_KERNEL
diff --git a/mm/maccess.c b/mm/maccess.c
index 4cee182..af450b8 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -3,8 +3,11 @@
  */
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/sched.h>
 #include <linux/uaccess.h>
 
+extern bool slab_access_ok(const void *ptr, unsigned long len);
+
 /**
  * probe_kernel_read(): safely attempt to read from a location
  * @dst: pointer to the buffer that shall take the data
@@ -60,3 +63,56 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
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
+inline static bool __attribute__((always_inline))
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
+noinline bool __kernel_access_ok(const void *ptr, unsigned long len)
+{
+	if (!slab_access_ok(ptr, len)) {
+		pr_alert("slab_access_ok failed, ptr = %p, length = %lu\n",
+			ptr, len);
+		dump_stack();
+		return false;
+	}
+	if (!stack_access_ok(ptr, len)) {
+		pr_alert("stack_access_ok failed, ptr = %p, length = %lu\n",
+			ptr, len);
+		dump_stack();
+		return false;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(__kernel_access_ok);
+#endif /* CONFIG_DEBUG_RUNTIME_USER_COPY_CHECKS */
diff --git a/mm/slab.c b/mm/slab.c
index d96e223..60e062c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3844,6 +3844,40 @@ unsigned int kmem_cache_size(struct kmem_cache *cachep)
 EXPORT_SYMBOL(kmem_cache_size);
 
 /*
+ * Returns false if and only if [ptr; ptr+len) touches the slab,
+ * but breaks objects boundaries.  It doesn't check whether the
+ * accessed object is actually allocated.
+ */
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	struct page *page;
+	struct kmem_cache *cachep = NULL;
+	struct slab *slabp;
+	unsigned int objnr;
+	unsigned long offset;
+
+	if (!len)
+		return true;
+	if (!virt_addr_valid(ptr))
+		return true;
+	page = virt_to_head_page(ptr);
+	if (!PageSlab(page))
+		return true;
+
+	cachep = page_get_cache(page);
+	slabp = page_get_slab(page);
+	objnr = obj_to_index(cachep, slabp, (void *)ptr);
+	BUG_ON(objnr >= cachep->num);
+	offset = (const char *)ptr - obj_offset(cachep) -
+	    (const char *)index_to_obj(cachep, slabp, objnr);
+	if (offset <= obj_size(cachep) && len <= obj_size(cachep) - offset)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+
+/*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
diff --git a/mm/slob.c b/mm/slob.c
index 46e0aee..2d9bb2b 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -666,6 +666,16 @@ unsigned int kmem_cache_size(struct kmem_cache *c)
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	/*
+	 * TODO: is it worth checking?  We have to gain a lock and
+	 * walk through all chunks.
+	 */
+	return true;
+}
+EXPORT_SYMBOL(slab_access_ok);
+
 int kmem_cache_shrink(struct kmem_cache *d)
 {
 	return 0;
diff --git a/mm/slub.c b/mm/slub.c
index 35f351f..be64e77 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2623,6 +2623,34 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
 }
 EXPORT_SYMBOL(kmem_cache_size);
 
+/*
+ * Returns false if and only if [ptr; ptr+len) touches the slab,
+ * but breaks objects boundaries.  It doesn't check whether the
+ * accessed object is actually allocated.
+ */
+bool slab_access_ok(const void *ptr, unsigned long len)
+{
+	struct page *page;
+	struct kmem_cache *s = NULL;
+	unsigned long offset;
+
+	if (len == 0)
+		return true;
+	if (!virt_addr_valid(ptr))
+		return true;
+	page = virt_to_head_page(ptr);
+	if (!PageSlab(page))
+		return true;
+
+	s = page->slab;
+	offset = ((const char *)ptr - (const char *)page_address(page)) % s->size;
+	if (offset <= s->objsize && len <= s->objsize - offset)
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
