Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 744F36B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 07:10:37 -0400 (EDT)
Received: by bwd14 with SMTP id 14so5213074bwd.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 04:10:33 -0700 (PDT)
Date: Sun, 3 Jul 2011 15:10:28 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [RFC v1] implement SL*B and stack usercopy runtime checks
Message-ID: <20110703111028.GA2862@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

This patch implements 2 additional checks for the data copied from
kernelspace to userspace and vice versa.  Currently there are some
very simple and cheap comparisons of supplied size and the size of
a copied object known at the compile time in copy_* functions.  This
patch enhances these checks to check against stack frame boundaries and
against SL*B object sizes.

More precisely, it checks:

1) if the data touches the stack, checks whether it fully fits in the stack
and whether it fully fits in a single stack frame.  The latter is arch
dependent, currently it is implemented for x86 with CONFIG_FRAME_POINTER=y only.
It limits infoleaks/overwrites to a single frame and arguments/local
variables only, and prevents saved return instruction pointer
overwriting.

2) if the data is from the SL*B cache, checks whether it fully fits in a
slab page and whether it overflows a slab object.  E.g. if the memory
was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
bytes, the copy would fail.


The checks are implemented for copy_{to,from}_user() and similar and are
missing for {put,get}_user() and similar because the base pointer might
be a result of any pointer arithmetics, and the correctness of these
arithmetics is almost impossible to check on this stage.

/dev/kmem and /dev/mem are fixed to pass this check (e.g. without
STRICT_DEVMEM it should be possible to overflow the stack frame and slab
objects).


The limitations:

The stack check does nothing with local variables overwriting and 
saved registers.  It only limits overflows to a single frame.

The SL*B checks don't validate whether the object is actually allocated.
So, it doesn't prevent infoleaks related to the freed objects.  Also if
the cache's granularity is larger than an actual allocated object size,
an infoleak of padding bytes is possible.

The slob check is missing yet.  Unfortunately, the check for slob
would have to (1) walk through the slob chunks and (2) hold the slob
lock, so it would lead to a significant slowdown.

The patch does nothing with other memory areas like vmalloc'ed areas,
modules' data and code sections, etc.  It could be an area for the
improvements.


The patch is a forwardport of the PAX_USERCOPY feature from the PaX
patch.  Most code was copied from the PaX patch with minor cosmetic
changes.  Also PaX' version of the patch has additional restrictions:

a) some slab caches has SLAB_USERCOPY flag set and copies to/from the slab
caches without the flag are denied.  Rare cases where some bytes needed
from the caches missing in the white list are handled by copying the
bytes into temporary area on the stack/heap.

b) if a malformed copy request is spotted, the event is logged and
SIGKILL signal is sent to the current task.


Questions/thoughts:

1) Is it possible to leave these checks unconditionally?  Or maybe
guarded by DEBUG_STRICT_USER_COPY_CHECKS or a new configure option?

2) Should this code put in action some monitoring/reacting mechanisms?
It makes sense to at least log the event because such overflow almost
surely is a result of a deliberate kernel bug exploitation attempt.
Whether active reactions on the event like killing is needed by default
is less obvious.

3) Maybe *_access_ok() checks should be moved to smth like
kernel_access_ok() for a more abstraction level and more comfortable
CONFIG_* guarding?  Then (2) and similar changes would be more simple.


If the patch will be ACK'ed by the maintainers, there will be separate
patches for the stack check, each of SL*Bs, x86, and /dev/*mem.  For
RFCv1 it is left as a one big blob.


Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---

 arch/x86/include/asm/uaccess.h    |   51 +++++++++++++++++++++++++++++++++++++
 arch/x86/include/asm/uaccess_32.h |   21 ++++++++++++++-
 arch/x86/include/asm/uaccess_64.h |   47 +++++++++++++++++++++++++++++++++-
 arch/x86/kernel/crash_dump_32.c   |    2 +-
 arch/x86/kernel/crash_dump_64.c   |    2 +-
 arch/x86/lib/usercopy_64.c        |    4 +++
 drivers/char/mem.c                |    8 +++---
 include/asm-generic/uaccess.h     |   19 +++++++++++++
 include/linux/slab.h              |    9 ++++++
 mm/maccess.c                      |   41 +++++++++++++++++++++++++++++
 mm/slab.c                         |   35 +++++++++++++++++++++++++
 mm/slub.c                         |   29 +++++++++++++++++++++
 12 files changed, 260 insertions(+), 8 deletions(-)
---
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index 99ddd14..a1d6b91 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -10,6 +10,9 @@
 #include <asm/asm.h>
 #include <asm/page.h>
 
+extern bool slab_access_ok(const void *ptr, unsigned long len);
+extern bool stack_access_ok(const void *ptr, unsigned long len);
+
 #define VERIFY_READ 0
 #define VERIFY_WRITE 1
 
@@ -78,6 +81,54 @@
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
+inline static __attribute__((always_inline))
+bool arch_check_object_on_stack_frame(const void *stack,
+	     const void *stackend, const void *obj, unsigned long len)
+{
+	const void *frame = NULL;
+	const void *oldframe;
+
+	/*
+	 * Get the stack_access_ok() caller frame.
+	 * __builtin_frame_address(0) returns stack_access_ok() frame
+	 * as arch_ is inline and stack_ is noinline.
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
+#define arch_check_object_on_stack_frame arch_check_object_on_stack_frame
+#endif
+
 /*
  * The exception table consists of pairs of addresses: the first is the
  * address of an instruction that is allowed to fault, and the second is
diff --git a/arch/x86/include/asm/uaccess_32.h b/arch/x86/include/asm/uaccess_32.h
index 566e803..9a9df71 100644
--- a/arch/x86/include/asm/uaccess_32.h
+++ b/arch/x86/include/asm/uaccess_32.h
@@ -61,6 +61,10 @@ __copy_to_user_inatomic(void __user *to, const void *from, unsigned long n)
 			return ret;
 		}
 	}
+
+	if (!slab_access_ok(from, n) || !stack_access_ok(from, n))
+		return n;
+
 	return __copy_to_user_ll(to, from, n);
 }
 
@@ -108,6 +112,10 @@ __copy_from_user_inatomic(void *to, const void __user *from, unsigned long n)
 			return ret;
 		}
 	}
+
+	if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+		return n;
+
 	return __copy_from_user_ll_nozero(to, from, n);
 }
 
@@ -152,6 +160,10 @@ __copy_from_user(void *to, const void __user *from, unsigned long n)
 			return ret;
 		}
 	}
+
+	if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+		return n;
+
 	return __copy_from_user_ll(to, from, n);
 }
 
@@ -174,6 +186,10 @@ static __always_inline unsigned long __copy_from_user_nocache(void *to,
 			return ret;
 		}
 	}
+
+	if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+		return n;
+
 	return __copy_from_user_ll_nocache(to, from, n);
 }
 
@@ -181,7 +197,10 @@ static __always_inline unsigned long
 __copy_from_user_inatomic_nocache(void *to, const void __user *from,
 				  unsigned long n)
 {
-       return __copy_from_user_ll_nocache_nozero(to, from, n);
+	if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+		return n;
+
+	return __copy_from_user_ll_nocache_nozero(to, from, n);
 }
 
 unsigned long __must_check copy_to_user(void __user *to,
diff --git a/arch/x86/include/asm/uaccess_64.h b/arch/x86/include/asm/uaccess_64.h
index 1c66d30..c25dcc7 100644
--- a/arch/x86/include/asm/uaccess_64.h
+++ b/arch/x86/include/asm/uaccess_64.h
@@ -50,6 +50,26 @@ static inline unsigned long __must_check copy_from_user(void *to,
 	int sz = __compiletime_object_size(to);
 
 	might_fault();
+	if (likely(sz == -1 || sz >= n)) {
+		if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+			return n;
+		n = _copy_from_user(to, from, n);
+	}
+#ifdef CONFIG_DEBUG_VM
+	else {
+		WARN(1, "Buffer overflow detected!\n");
+	}
+#endif
+	return n;
+}
+
+static inline unsigned long __must_check copy_from_user_nocheck(void *to,
+					  const void __user *from,
+					  unsigned long n)
+{
+	int sz = __compiletime_object_size(to);
+
+	might_fault();
 	if (likely(sz == -1 || sz >= n))
 		n = _copy_from_user(to, from, n);
 #ifdef CONFIG_DEBUG_VM
@@ -60,7 +80,7 @@ static inline unsigned long __must_check copy_from_user(void *to,
 }
 
 static __always_inline __must_check
-int copy_to_user(void __user *dst, const void *src, unsigned size)
+int copy_to_user_nocheck(void __user *dst, const void *src, unsigned size)
 {
 	might_fault();
 
@@ -68,11 +88,26 @@ int copy_to_user(void __user *dst, const void *src, unsigned size)
 }
 
 static __always_inline __must_check
+int copy_to_user(void __user *dst, const void *src, unsigned size)
+{
+	might_fault();
+
+	if (!slab_access_ok(src, size) || !stack_access_ok(src, size))
+		return size;
+
+	return copy_to_user_nocheck(dst, src, size);
+}
+
+static __always_inline __must_check
 int __copy_from_user(void *dst, const void __user *src, unsigned size)
 {
 	int ret = 0;
 
 	might_fault();
+
+	if (!slab_access_ok(dst, size) || !stack_access_ok(dst, size))
+		return size;
+
 	if (!__builtin_constant_p(size))
 		return copy_user_generic(dst, (__force void *)src, size);
 	switch (size) {
@@ -117,6 +152,10 @@ int __copy_to_user(void __user *dst, const void *src, unsigned size)
 	int ret = 0;
 
 	might_fault();
+
+	if (!slab_access_ok(src, size) || !stack_access_ok(src, size))
+		return size;
+
 	if (!__builtin_constant_p(size))
 		return copy_user_generic((__force void *)dst, src, size);
 	switch (size) {
@@ -221,12 +260,18 @@ __must_check unsigned long __clear_user(void __user *mem, unsigned long len);
 static __must_check __always_inline int
 __copy_from_user_inatomic(void *dst, const void __user *src, unsigned size)
 {
+	if (!slab_access_ok(dst, size) || !stack_access_ok(dst, size))
+		return size;
+
 	return copy_user_generic(dst, (__force const void *)src, size);
 }
 
 static __must_check __always_inline int
 __copy_to_user_inatomic(void __user *dst, const void *src, unsigned size)
 {
+	if (!slab_access_ok(src, size) || !stack_access_ok(src, size))
+		return size;
+
 	return copy_user_generic((__force void *)dst, src, size);
 }
 
diff --git a/arch/x86/kernel/crash_dump_32.c b/arch/x86/kernel/crash_dump_32.c
index 642f75a..6d3f36d 100644
--- a/arch/x86/kernel/crash_dump_32.c
+++ b/arch/x86/kernel/crash_dump_32.c
@@ -72,7 +72,7 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 		}
 		copy_page(kdump_buf_page, vaddr);
 		kunmap_atomic(vaddr, KM_PTE0);
-		if (copy_to_user(buf, (kdump_buf_page + offset), csize))
+		if (copy_to_user_nocheck(buf, (kdump_buf_page + offset), csize))
 			return -EFAULT;
 	}
 
diff --git a/arch/x86/kernel/crash_dump_64.c b/arch/x86/kernel/crash_dump_64.c
index afa64ad..c241ab8 100644
--- a/arch/x86/kernel/crash_dump_64.c
+++ b/arch/x86/kernel/crash_dump_64.c
@@ -36,7 +36,7 @@ ssize_t copy_oldmem_page(unsigned long pfn, char *buf,
 		return -ENOMEM;
 
 	if (userbuf) {
-		if (copy_to_user(buf, vaddr + offset, csize)) {
+		if (copy_to_user_nocheck(buf, vaddr + offset, csize)) {
 			iounmap(vaddr);
 			return -EFAULT;
 		}
diff --git a/arch/x86/lib/usercopy_64.c b/arch/x86/lib/usercopy_64.c
index b7c2849..699f45b 100644
--- a/arch/x86/lib/usercopy_64.c
+++ b/arch/x86/lib/usercopy_64.c
@@ -42,6 +42,10 @@ long
 __strncpy_from_user(char *dst, const char __user *src, long count)
 {
 	long res;
+
+	if (!slab_access_ok(dst, count) || !stack_access_ok(dst, count))
+		return count;
+
 	__do_strncpy_from_user(dst, src, count, res);
 	return res;
 }
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 8fc04b4..0c506cb 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -132,7 +132,7 @@ static ssize_t read_mem(struct file *file, char __user *buf,
 		if (!ptr)
 			return -EFAULT;
 
-		remaining = copy_to_user(buf, ptr, sz);
+		remaining = copy_to_user_nocheck(buf, ptr, sz);
 		unxlate_dev_mem_ptr(p, ptr);
 		if (remaining)
 			return -EFAULT;
@@ -190,7 +190,7 @@ static ssize_t write_mem(struct file *file, const char __user *buf,
 			return -EFAULT;
 		}
 
-		copied = copy_from_user(ptr, buf, sz);
+		copied = copy_from_user_nocheck(ptr, buf, sz);
 		unxlate_dev_mem_ptr(p, ptr);
 		if (copied) {
 			written += sz - copied;
@@ -428,7 +428,7 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
 			 */
 			kbuf = xlate_dev_kmem_ptr((char *)p);
 
-			if (copy_to_user(buf, kbuf, sz))
+			if (copy_to_user_nocheck(buf, kbuf, sz))
 				return -EFAULT;
 			buf += sz;
 			p += sz;
@@ -498,7 +498,7 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
 		 */
 		ptr = xlate_dev_kmem_ptr((char *)p);
 
-		copied = copy_from_user(ptr, buf, sz);
+		copied = copy_from_user_nocheck(ptr, buf, sz);
 		if (copied) {
 			written += sz - copied;
 			if (written)
diff --git a/include/asm-generic/uaccess.h b/include/asm-generic/uaccess.h
index ac68c99..7124db6 100644
--- a/include/asm-generic/uaccess.h
+++ b/include/asm-generic/uaccess.h
@@ -50,6 +50,15 @@ static inline int __access_ok(unsigned long addr, unsigned long size)
 }
 #endif
 
+#ifndef arch_check_object_on_stack_frame
+static inline bool arch_check_object_on_stack_frame(const void *stack,
+	     const void *stackend, const void *obj, unsigned long len)
+{
+	return true;
+}
+#define arch_check_object_on_stack_frame arch_check_object_on_stack_frame
+#endif /* arch_check_object_on_stack_frame */
+
 /*
  * The exception table consists of pairs of addresses: the first is the
  * address of an instruction that is allowed to fault, and the second is
@@ -99,6 +108,9 @@ static inline __must_check long __copy_from_user(void *to,
 		}
 	}
 
+	if (!slab_access_ok(to, n) || !stack_access_ok(to, n))
+		return n;
+
 	memcpy(to, (const void __force *)from, n);
 	return 0;
 }
@@ -129,6 +141,9 @@ static inline __must_check long __copy_to_user(void __user *to,
 		}
 	}
 
+	if (!slab_access_ok(from, n) || !stack_access_ok(from, n))
+		return n;
+
 	memcpy((void __force *)to, from, n);
 	return 0;
 }
@@ -268,6 +283,10 @@ static inline long
 __strncpy_from_user(char *dst, const char __user *src, long count)
 {
 	char *tmp;
+
+	if (!slab_access_ok(dst, count) || !stack_access_ok(dst, count))
+		return count;
+
 	strncpy(dst, (const char __force *)src, count);
 	for (tmp = dst; *tmp && count > 0; tmp++, count--)
 		;
diff --git a/include/linux/slab.h b/include/linux/slab.h
index ad4dd1c..8e564bb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -333,4 +333,13 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
 
 void __init kmem_cache_init_late(void);
 
+/*
+ * slab_access_ok() checks whether ptr belongs to the slab cache and whether
+ * it fits in a single allocated area.
+ *
+ * Returns false only if ptr belongs to a slab cache and overflows allocated
+ * slab area.
+ */
+extern bool slab_access_ok(const void *ptr, unsigned long len);
+
 #endif	/* _LINUX_SLAB_H */
diff --git a/mm/maccess.c b/mm/maccess.c
index 4cee182..0b8f3eb 100644
--- a/mm/maccess.c
+++ b/mm/maccess.c
@@ -3,6 +3,7 @@
  */
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/sched.h>
 #include <linux/uaccess.h>
 
 /**
@@ -60,3 +61,43 @@ long __probe_kernel_write(void *dst, const void *src, size_t size)
 	return ret ? -EFAULT : 0;
 }
 EXPORT_SYMBOL_GPL(probe_kernel_write);
+
+/*
+ * stack_access_ok() checks whether object is on the stack and
+ * whether it fits in a single stack frame (in case arch allows
+ * to learn this information).
+ *
+ * Returns true in cases:
+ * a) object is not a stack object at all
+ * b) object is located on the stack and fits in a single frame
+ *
+ * MUST be noinline not to confuse arch_check_object_on_stack_frame.
+ */
+bool noinline stack_access_ok(const void *obj, unsigned long len)
+{
+	const void * const stack = task_stack_page(current);
+	const void * const stackend = stack + THREAD_SIZE;
+	bool rc = false;
+
+	/* Does obj+len overflow vm space? */
+	if (unlikely(obj + len < obj))
+		goto exit;
+
+	/* Does [obj; obj+len) at least touch our stack? */
+	if (unlikely(obj + len <= stack || stackend <= obj)) {
+		rc = true;
+		goto exit;
+	}
+
+	/* Does [obj; obj+len) overflow/underflow the stack? */
+	if (unlikely(obj < stack || stackend < obj + len))
+		goto exit;
+
+	rc = arch_check_object_on_stack_frame(stack, stackend, obj, len);
+
+exit:
+	if (!rc)
+		pr_err("stack_access_ok failed (ptr = %p, len = %lu)\n", obj, len);
+	return rc;
+}
+EXPORT_SYMBOL(stack_access_ok);
diff --git a/mm/slab.c b/mm/slab.c
index d96e223..4ec5681 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3844,6 +3844,41 @@ unsigned int kmem_cache_size(struct kmem_cache *cachep)
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
+	pr_err("slab_access_ok failed (addr %p, len %lu)\n", ptr, len);
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+
+/*
  * This initializes kmem_list3 or resizes various caches for all nodes.
  */
 static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
diff --git a/mm/slub.c b/mm/slub.c
index 35f351f..169349b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2623,6 +2623,35 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
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
+	pr_err("slab_access_ok failed (addr %p, len %lu)\n", ptr, len);
+	return false;
+}
+EXPORT_SYMBOL(slab_access_ok);
+
 static void list_slab_objects(struct kmem_cache *s, struct page *page,
 							const char *text)
 {
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
