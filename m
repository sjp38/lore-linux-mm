Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5BA828E4
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 17:44:39 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so206373527pap.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:39 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id k4si4939308pfj.91.2016.07.15.14.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 14:44:34 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id dx3so42814785pab.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 14:44:34 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 02/11] mm: Hardened usercopy
Date: Fri, 15 Jul 2016 14:44:16 -0700
Message-Id: <1468619065-3222-3-git-send-email-keescook@chromium.org>
In-Reply-To: <1468619065-3222-1-git-send-email-keescook@chromium.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

This is the start of porting PAX_USERCOPY into the mainline kernel. This
is the first set of features, controlled by CONFIG_HARDENED_USERCOPY. The
work is based on code by PaX Team and Brad Spengler, and an earlier port
from Casey Schaufler. Additional non-slab page tests are from Rik van Riel.

This patch contains the logic for validating several conditions when
performing copy_to_user() and copy_from_user() on the kernel object
being copied to/from:
- address range doesn't wrap around
- address range isn't NULL or zero-allocated (with a non-zero copy size)
- if on the slab allocator:
  - object size must be less than or equal to copy size (when check is
    implemented in the allocator, which appear in subsequent patches)
- otherwise, object must not span page allocations
- if on the stack
  - object must not extend before/after the current process task
  - object must be contained by the current stack frame (when there is
    arch/build support for identifying stack frames)
- object must not overlap with kernel text

Signed-off-by: Kees Cook <keescook@chromium.org>
Tested-By: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Tested-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/Kconfig                |   7 ++
 include/linux/slab.h        |  12 +++
 include/linux/thread_info.h |  15 +++
 mm/Makefile                 |   4 +
 mm/usercopy.c               | 234 ++++++++++++++++++++++++++++++++++++++++++++
 security/Kconfig            |  28 ++++++
 6 files changed, 300 insertions(+)
 create mode 100644 mm/usercopy.c

diff --git a/arch/Kconfig b/arch/Kconfig
index 5e2776562035..195ee4cc939a 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -433,6 +433,13 @@ config HAVE_ARCH_WITHIN_STACK_FRAMES
 	  and similar) by implementing an inline arch_within_stack_frames(),
 	  which is used by CONFIG_HARDENED_USERCOPY.
 
+config HAVE_ARCH_LINEAR_KERNEL_MAPPING
+	bool
+	help
+	  An architecture should select this if it has a secondary linear
+	  mapping of the kernel text. This is used to verify that kernel
+	  text exposures are not visible under CONFIG_HARDENED_USERCOPY.
+
 config HAVE_CONTEXT_TRACKING
 	bool
 	help
diff --git a/include/linux/slab.h b/include/linux/slab.h
index aeb3e6d00a66..96a16a3fb7cb 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -155,6 +155,18 @@ void kfree(const void *);
 void kzfree(const void *);
 size_t ksize(const void *);
 
+#ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
+const char *__check_heap_object(const void *ptr, unsigned long n,
+				struct page *page);
+#else
+static inline const char *__check_heap_object(const void *ptr,
+					      unsigned long n,
+					      struct page *page)
+{
+	return NULL;
+}
+#endif
+
 /*
  * Some archs want to perform DMA into kmalloc caches and need a guaranteed
  * alignment larger than the alignment of a 64-bit integer.
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index 3d5c80b4391d..f24b99eac969 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -155,6 +155,21 @@ static inline int arch_within_stack_frames(const void * const stack,
 }
 #endif
 
+#ifdef CONFIG_HARDENED_USERCOPY
+extern void __check_object_size(const void *ptr, unsigned long n,
+					bool to_user);
+
+static inline void check_object_size(const void *ptr, unsigned long n,
+				     bool to_user)
+{
+	__check_object_size(ptr, n, to_user);
+}
+#else
+static inline void check_object_size(const void *ptr, unsigned long n,
+				     bool to_user)
+{ }
+#endif /* CONFIG_HARDENED_USERCOPY */
+
 #endif	/* __KERNEL__ */
 
 #endif /* _LINUX_THREAD_INFO_H */
diff --git a/mm/Makefile b/mm/Makefile
index 78c6f7dedb83..32d37247c7e5 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o := n
 KCOV_INSTRUMENT_mmzone.o := n
 KCOV_INSTRUMENT_vmstat.o := n
 
+# Since __builtin_frame_address does work as used, disable the warning.
+CFLAGS_usercopy.o += $(call cc-disable-warning, frame-address)
+
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
@@ -99,3 +102,4 @@ obj-$(CONFIG_USERFAULTFD) += userfaultfd.o
 obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
+obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
diff --git a/mm/usercopy.c b/mm/usercopy.c
new file mode 100644
index 000000000000..e4bf4e7ccdf6
--- /dev/null
+++ b/mm/usercopy.c
@@ -0,0 +1,234 @@
+/*
+ * This implements the various checks for CONFIG_HARDENED_USERCOPY*,
+ * which are designed to protect kernel memory from needless exposure
+ * and overwrite under many unintended conditions. This code is based
+ * on PAX_USERCOPY, which is:
+ *
+ * Copyright (C) 2001-2016 PaX Team, Bradley Spengler, Open Source
+ * Security Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <asm/sections.h>
+
+enum {
+	BAD_STACK = -1,
+	NOT_STACK = 0,
+	GOOD_FRAME,
+	GOOD_STACK,
+};
+
+/*
+ * Checks if a given pointer and length is contained by the current
+ * stack frame (if possible).
+ *
+ *	0: not at all on the stack
+ *	1: fully within a valid stack frame
+ *	2: fully on the stack (when can't do frame-checking)
+ *	-1: error condition (invalid stack position or bad stack frame)
+ */
+static noinline int check_stack_object(const void *obj, unsigned long len)
+{
+	const void * const stack = task_stack_page(current);
+	const void * const stackend = stack + THREAD_SIZE;
+	int ret;
+
+	/* Object is not on the stack at all. */
+	if (obj + len <= stack || stackend <= obj)
+		return NOT_STACK;
+
+	/*
+	 * Reject: object partially overlaps the stack (passing the
+	 * the check above means at least one end is within the stack,
+	 * so if this check fails, the other end is outside the stack).
+	 */
+	if (obj < stack || stackend < obj + len)
+		return BAD_STACK;
+
+	/* Check if object is safely within a valid frame. */
+	ret = arch_within_stack_frames(stack, stackend, obj, len);
+	if (ret)
+		return ret;
+
+	return GOOD_STACK;
+}
+
+static void report_usercopy(const void *ptr, unsigned long len,
+			    bool to_user, const char *type)
+{
+	pr_emerg("kernel memory %s attempt detected %s %p (%s) (%lu bytes)\n",
+		to_user ? "exposure" : "overwrite",
+		to_user ? "from" : "to", ptr, type ? : "unknown", len);
+	/*
+	 * For greater effect, it would be nice to do do_group_exit(),
+	 * but BUG() actually hooks all the lock-breaking and per-arch
+	 * Oops code, so that is used here instead.
+	 */
+	BUG();
+}
+
+/* Returns true if any portion of [ptr,ptr+n) over laps with [low,high). */
+static bool overlaps(const void *ptr, unsigned long n, unsigned long low,
+		     unsigned long high)
+{
+	unsigned long check_low = (uintptr_t)ptr;
+	unsigned long check_high = check_low + n;
+
+	/* Does not overlap if entirely above or entirely below. */
+	if (check_low >= high || check_high < low)
+		return false;
+
+	return true;
+}
+
+/* Is this address range in the kernel text area? */
+static inline const char *check_kernel_text_object(const void *ptr,
+						   unsigned long n)
+{
+	unsigned long textlow = (unsigned long)_stext;
+	unsigned long texthigh = (unsigned long)_etext;
+
+	if (overlaps(ptr, n, textlow, texthigh))
+		return "<kernel text>";
+
+#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
+	/* Check against linear mapping as well. */
+	if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
+		     (unsigned long)__va(__pa(texthigh))))
+		return "<linear kernel text>";
+#endif
+
+	return NULL;
+}
+
+static inline const char *check_bogus_address(const void *ptr, unsigned long n)
+{
+	/* Reject if object wraps past end of memory. */
+	if (ptr + n < ptr)
+		return "<wrapped address>";
+
+	/* Reject if NULL or ZERO-allocation. */
+	if (ZERO_OR_NULL_PTR(ptr))
+		return "<null>";
+
+	return NULL;
+}
+
+static inline const char *check_heap_object(const void *ptr, unsigned long n,
+					    bool to_user)
+{
+	struct page *page, *endpage;
+	const void *end = ptr + n - 1;
+
+	if (!virt_addr_valid(ptr))
+		return NULL;
+
+	page = virt_to_head_page(ptr);
+
+	/* Check slab allocator for flags and size. */
+	if (PageSlab(page))
+		return __check_heap_object(ptr, n, page);
+
+	/*
+	 * Sometimes the kernel data regions are not marked Reserved (see
+	 * check below). And sometimes [_sdata,_edata) does not cover
+	 * rodata and/or bss, so check each range explicitly.
+	 */
+
+	/* Allow reads of kernel rodata region (if not marked as Reserved). */
+	if (ptr >= (const void *)__start_rodata &&
+	    end <= (const void *)__end_rodata) {
+		if (!to_user)
+			return "<rodata>";
+		return NULL;
+	}
+
+	/* Allow kernel data region (if not marked as Reserved). */
+	if (ptr >= (const void *)_sdata && end <= (const void *)_edata)
+		return NULL;
+
+	/* Allow kernel bss region (if not marked as Reserved). */
+	if (ptr >= (const void *)__bss_start &&
+	    end <= (const void *)__bss_stop)
+		return NULL;
+
+	/* Is the object wholly within one base page? */
+	if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK) ==
+		   ((unsigned long)end & (unsigned long)PAGE_MASK)))
+		return NULL;
+
+	/* Allow if start and end are inside the same compound page. */
+	endpage = virt_to_head_page(end);
+	if (likely(endpage == page))
+		return NULL;
+
+	/*
+	 * Reject if range is not Reserved (i.e. special or device memory),
+	 * since then the object spans several independently allocated pages.
+	 */
+	for (; ptr <= end ; ptr += PAGE_SIZE, page = virt_to_head_page(ptr)) {
+		if (!PageReserved(page))
+			return "<spans multiple pages>";
+	}
+
+	return NULL;
+}
+
+/*
+ * Validates that the given object is one of:
+ * - known safe heap object
+ * - known safe stack object
+ * - not in kernel text
+ */
+void __check_object_size(const void *ptr, unsigned long n, bool to_user)
+{
+	const char *err;
+
+	/* Skip all tests if size is zero. */
+	if (!n)
+		return;
+
+	/* Check for invalid addresses. */
+	err = check_bogus_address(ptr, n);
+	if (err)
+		goto report;
+
+	/* Check for bad heap object. */
+	err = check_heap_object(ptr, n, to_user);
+	if (err)
+		goto report;
+
+	/* Check for bad stack object. */
+	switch (check_stack_object(ptr, n)) {
+	case NOT_STACK:
+		/* Object is not touching the current process stack. */
+		break;
+	case GOOD_FRAME:
+	case GOOD_STACK:
+		/*
+		 * Object is either in the correct frame (when it
+		 * is possible to check) or just generally on the
+		 * process stack (when frame checking not available).
+		 */
+		return;
+	default:
+		err = "<process stack>";
+		goto report;
+	}
+
+	/* Check for object in kernel to avoid text exposure. */
+	err = check_kernel_text_object(ptr, n);
+	if (!err)
+		return;
+
+report:
+	report_usercopy(ptr, n, to_user, err);
+}
+EXPORT_SYMBOL(__check_object_size);
diff --git a/security/Kconfig b/security/Kconfig
index 176758cdfa57..df28f2b6f3e1 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -118,6 +118,34 @@ config LSM_MMAP_MIN_ADDR
 	  this low address space will need the permission specific to the
 	  systems running LSM.
 
+config HAVE_HARDENED_USERCOPY_ALLOCATOR
+	bool
+	help
+	  The heap allocator implements __check_heap_object() for
+	  validating memory ranges against heap object sizes in
+	  support of CONFIG_HARDENED_USERCOPY.
+
+config HAVE_ARCH_HARDENED_USERCOPY
+	bool
+	help
+	  The architecture supports CONFIG_HARDENED_USERCOPY by
+	  calling check_object_size() just before performing the
+	  userspace copies in the low level implementation of
+	  copy_to_user() and copy_from_user().
+
+config HARDENED_USERCOPY
+	bool "Harden memory copies between kernel and userspace"
+	depends on HAVE_ARCH_HARDENED_USERCOPY
+	select BUG
+	help
+	  This option checks for obviously wrong memory regions when
+	  copying memory to/from the kernel (via copy_to_user() and
+	  copy_from_user() functions) by rejecting memory ranges that
+	  are larger than the specified heap object, span multiple
+	  separately allocates pages, are not on the process stack,
+	  or are part of the kernel text. This kills entire classes
+	  of heap overflow exploits and similar kernel memory exposures.
+
 source security/selinux/Kconfig
 source security/smack/Kconfig
 source security/tomoyo/Kconfig
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
