Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 906416B000D
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:03 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m130so1488725wma.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 39sor3384464wry.5.2018.03.02.11.45.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:01 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 03/14] khwasan: add CONFIG_KASAN_CLASSIC and CONFIG_KASAN_TAGS
Date: Fri,  2 Mar 2018 20:44:22 +0100
Message-Id: <445719222820121c51225ca075f9fc57efb58265.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This commit splits the current CONFIG_KASAN config option into two:
1. CONFIG_KASAN_CLASSIC, that enables the classic KASAN version (the one
   that exists now);
2. CONFIG_KASAN_TAGS, that enables KHWASAN.

With CONFIG_KASAN_TAGS enabled, compiler options are changed to instrument
kernel files wiht -fsantize=hwaddress (except the ones for which
KASAN_SANITIZE := n is set).

Both CONFIG_KASAN_CLASSIC and CONFIG_KASAN_CLASSIC support both
CONFIG_KASAN_INLINE and CONFIG_KASAN_OUTLINE instrumentation modes.

This commit also adds empty placeholder (for now) KHWASAN implementation
of KASAN hooks (which KHWASAN reuses) and placeholder implementation
of KHWASAN specific hooks inserted by the compiler.
---
 arch/arm64/Kconfig             |   1 +
 include/linux/compiler-clang.h |   7 +-
 include/linux/compiler-gcc.h   |   4 ++
 include/linux/compiler.h       |   3 +-
 include/linux/kasan.h          |  16 +++--
 lib/Kconfig.kasan              |  68 +++++++++++++-----
 mm/kasan/Makefile              |   6 +-
 mm/kasan/khwasan.c             | 127 +++++++++++++++++++++++++++++++++
 mm/slub.c                      |   2 +-
 scripts/Makefile.kasan         |  32 ++++++++-
 10 files changed, 241 insertions(+), 25 deletions(-)
 create mode 100644 mm/kasan/khwasan.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7381eeb7ef8e..759871510f87 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -88,6 +88,7 @@ config ARM64
 	select HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
+	select HAVE_ARCH_KASAN_TAGS if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index d3f264a5b04d..16e49f6b6645 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -24,10 +24,15 @@
 #define KASAN_ABI_VERSION 5
 
 /* emulate gcc's __SANITIZE_ADDRESS__ flag */
-#if __has_feature(address_sanitizer)
+#if __has_feature(address_sanitizer) || __has_feature(hwaddress_sanitizer)
 #define __SANITIZE_ADDRESS__
 #endif
 
+#ifdef CONFIG_KASAN_TAGS
+#undef __no_sanitize_hwaddress
+#define __no_sanitize_hwaddress __attribute__((no_sanitize("hwaddress")))
+#endif
+
 /* Clang doesn't have a way to turn it off per-function, yet. */
 #ifdef __noretpoline
 #undef __noretpoline
diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index e2c7f4369eff..e9bc985c1227 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -344,6 +344,10 @@
 #define __no_sanitize_address
 #endif
 
+#if !defined(__no_sanitize_hwaddress)
+#define __no_sanitize_hwaddress	/* gcc doesn't support KHWASAN */
+#endif
+
 /*
  * A trick to suppress uninitialized variable warning without generating any
  * code
diff --git a/include/linux/compiler.h b/include/linux/compiler.h
index ab4711c63601..6142bae513e8 100644
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -195,7 +195,8 @@ void __read_once_size(const volatile void *p, void *res, int size)
  * 	https://gcc.gnu.org/bugzilla/show_bug.cgi?id=67368
  * '__maybe_unused' allows us to avoid defined-but-not-used warnings.
  */
-# define __no_kasan_or_inline __no_sanitize_address __maybe_unused
+# define __no_kasan_or_inline __no_sanitize_address __no_sanitize_hwaddress \
+			      __maybe_unused
 #else
 # define __no_kasan_or_inline __always_inline
 #endif
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 3bfebcf7ad2b..3c45e273a936 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -45,8 +45,6 @@ void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, size_t *size,
 			slab_flags_t *flags);
-void kasan_cache_shrink(struct kmem_cache *cache);
-void kasan_cache_shutdown(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
@@ -94,8 +92,6 @@ static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      size_t *size,
 				      slab_flags_t *flags) {}
-static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
-static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
@@ -141,4 +137,16 @@ static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
 
 #endif /* CONFIG_KASAN */
 
+#ifdef CONFIG_KASAN_CLASSIC
+
+void kasan_cache_shrink(struct kmem_cache *cache);
+void kasan_cache_shutdown(struct kmem_cache *cache);
+
+#else /* CONFIG_KASAN_CLASSIC */
+
+static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
+static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
+
+#endif /* CONFIG_KASAN_CLASSIC */
+
 #endif /* LINUX_KASAN_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 3d35d062970d..ab34e7d7d3a7 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -1,33 +1,69 @@
 config HAVE_ARCH_KASAN
 	bool
 
+config HAVE_ARCH_KASAN_TAGS
+	bool
+
 if HAVE_ARCH_KASAN
 
 config KASAN
-	bool "KASan: runtime memory debugger"
+	bool "KASAN: runtime memory debugger"
+	help
+	  Enables KASAN (KernelAddressSANitizer) - runtime memory debugger,
+	  designed to find out-of-bounds accesses and use-after-free bugs.
+	  KASAN has two modes: KASAN (a classic version, similar to userspace
+	  ASan, enabled with CONFIG_KASAN_CLASSIC) and KHWASAN (a version
+	  based on pointer tagging, only for arm64, similar to userspace
+	  HWASan, enabled with CONFIG_KASAN_TAGS).
+
+choice
+	prompt "KASAN mode"
+	depends on KASAN
+	default KASAN_CLASSIC
+
+config KASAN_CLASSIC
+	bool "KASAN: the classic mode"
 	depends on SLUB || (SLAB && !DEBUG_SLAB)
 	select CONSTRUCTORS
 	select STACKDEPOT
 	help
-	  Enables kernel address sanitizer - runtime memory debugger,
-	  designed to find out-of-bounds accesses and use-after-free bugs.
-	  This is strictly a debugging feature and it requires a gcc version
-	  of 4.9.2 or later. Detection of out of bounds accesses to stack or
-	  global variables requires gcc 5.0 or later.
+	  Enables the classic mode of KASAN.
+	  This is strictly a debugging feature and it requires a GCC version
+	  of 4.9.2 or later. Detection of out-of-bounds accesses to stack or
+	  global variables requires GCC 5.0 or later.
 	  This feature consumes about 1/8 of available memory and brings about
 	  ~x3 performance slowdown.
 	  For better error detection enable CONFIG_STACKTRACE.
-	  Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
+	  Currently CONFIG_KASAN_CLASSIC doesn't work with CONFIG_DEBUG_SLAB
 	  (the resulting kernel does not boot).
 
+if HAVE_ARCH_KASAN_TAGS
+
+config KASAN_TAGS
+	bool "KHWASAN: the tagged pointers mode"
+	depends on SLUB || (SLAB && !DEBUG_SLAB)
+	select CONSTRUCTORS
+	select STACKDEPOT
+	help
+	  Enabled KHWASAN (KASAN mode based on pointer tagging).
+	  This mode requires Top Byte Ignore support by the CPU and therefore
+	  only supported for arm64.
+	  TODO: clang version, slowdown, memory usage
+	  For better error detection enable CONFIG_STACKTRACE.
+	  Currently CONFIG_KASAN_TAGS doesn't work with CONFIG_DEBUG_SLAB
+	  (the resulting kernel does not boot).
+
+endif
+
+endchoice
+
 config KASAN_EXTRA
-	bool "KAsan: extra checks"
-	depends on KASAN && DEBUG_KERNEL && !COMPILE_TEST
+	bool "KASAN: extra checks"
+	depends on KASAN_CLASSIC && DEBUG_KERNEL && !COMPILE_TEST
 	help
-	  This enables further checks in the kernel address sanitizer, for now
-	  it only includes the address-use-after-scope check that can lead
-	  to excessive kernel stack usage, frame size warnings and longer
-	  compile time.
+	  This enables further checks in KASAN, for now it only includes the
+	  address-use-after-scope check that can lead to excessive kernel
+	  stack usage, frame size warnings and longer compile time.
 	  https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715 has more
 
 
@@ -52,16 +88,16 @@ config KASAN_INLINE
 	  memory accesses. This is faster than outline (in some workloads
 	  it gives about x2 boost over outline instrumentation), but
 	  make kernel's .text size much bigger.
-	  This requires a gcc version of 5.0 or later.
+	  For CONFIG_KASAN_CLASSIC this requires GCC 5.0 or later.
 
 endchoice
 
 config TEST_KASAN
-	tristate "Module for testing kasan for bug detection"
+	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
 	help
 	  This is a test module doing various nasty things like
 	  out of bounds accesses, use after free. It is useful for testing
-	  kernel debugging features like kernel address sanitizer.
+	  kernel debugging features like KASAN.
 
 endif
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index a6df14bffb6b..d930575e6d55 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -2,6 +2,7 @@
 KASAN_SANITIZE := n
 UBSAN_SANITIZE_common.o := n
 UBSAN_SANITIZE_kasan.o := n
+UBSAN_SANITIZE_khwasan.o := n
 KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_kasan.o = -pg
@@ -10,5 +11,8 @@ CFLAGS_REMOVE_kasan.o = -pg
 
 CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
+CFLAGS_khwasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := common.o kasan.o report.o kasan_init.o quarantine.o
+obj-$(CONFIG_KASAN) := common.o kasan_init.o report.o
+obj-$(CONFIG_KASAN_CLASSIC) += kasan.o quarantine.o
+obj-$(CONFIG_KASAN_TAGS) += khwasan.o
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
new file mode 100644
index 000000000000..24d75245e9d0
--- /dev/null
+++ b/mm/kasan/khwasan.c
@@ -0,0 +1,127 @@
+/*
+ * This file contains core KHWASAN code, including shadow memory manipulation
+ * code, implementation of KHWASAN hooks and compiler inserted callbacks, etc.
+ *
+ * Copyright (c) 2018 Google, Inc.
+ * Author: Andrey Konovalov <andreyknvl@google.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/export.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/kmemleak.h>
+#include <linux/linkage.h>
+#include <linux/memblock.h>
+#include <linux/memory.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/random.h>
+#include <linux/sched.h>
+#include <linux/sched/task_stack.h>
+#include <linux/slab.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/vmalloc.h>
+#include <linux/bug.h>
+
+#include "kasan.h"
+#include "../slab.h"
+
+void kasan_unpoison_shadow(const void *address, size_t size)
+{
+}
+
+void check_memory_region(unsigned long addr, size_t size, bool write,
+				unsigned long ret_ip)
+{
+}
+
+void kasan_free_pages(struct page *page, unsigned int order)
+{
+}
+
+void kasan_cache_create(struct kmem_cache *cache, size_t *size,
+		slab_flags_t *flags)
+{
+}
+
+void kasan_poison_slab(struct page *page)
+{
+}
+
+void kasan_poison_object_data(struct kmem_cache *cache, void *object)
+{
+}
+
+void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
+{
+	return object;
+}
+
+bool kasan_slab_free(struct kmem_cache *cache, void *object, unsigned long ip)
+{
+	return false;
+}
+
+void *kasan_kmalloc(struct kmem_cache *cache, const void *object,
+			size_t size, gfp_t flags)
+{
+	return (void *)object;
+}
+EXPORT_SYMBOL(kasan_kmalloc);
+
+void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
+{
+	return (void *)ptr;
+}
+
+void kasan_poison_kfree(void *ptr, unsigned long ip)
+{
+}
+
+void kasan_kfree_large(void *ptr, unsigned long ip)
+{
+}
+
+#define DEFINE_HWASAN_LOAD_STORE(size)					\
+	void __hwasan_load##size##_noabort(unsigned long addr)		\
+	{								\
+	}								\
+	EXPORT_SYMBOL(__hwasan_load##size##_noabort);			\
+	void __hwasan_store##size##_noabort(unsigned long addr)		\
+	{								\
+	}								\
+	EXPORT_SYMBOL(__hwasan_store##size##_noabort)
+
+DEFINE_HWASAN_LOAD_STORE(1);
+DEFINE_HWASAN_LOAD_STORE(2);
+DEFINE_HWASAN_LOAD_STORE(4);
+DEFINE_HWASAN_LOAD_STORE(8);
+DEFINE_HWASAN_LOAD_STORE(16);
+
+void __hwasan_loadN_noabort(unsigned long addr, unsigned long size)
+{
+}
+EXPORT_SYMBOL(__hwasan_loadN_noabort);
+
+void __hwasan_storeN_noabort(unsigned long addr, unsigned long size)
+{
+}
+EXPORT_SYMBOL(__hwasan_storeN_noabort);
+
+void __hwasan_tag_memory(unsigned long addr, u8 tag, unsigned long size)
+{
+}
+EXPORT_SYMBOL(__hwasan_tag_memory);
diff --git a/mm/slub.c b/mm/slub.c
index 4a856512f225..a00bf24d668e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2983,7 +2983,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 		do_slab_free(s, page, head, tail, cnt, addr);
 }
 
-#ifdef CONFIG_KASAN
+#ifdef CONFIG_KASAN_CLASSIC
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
 {
 	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 69552a39951d..7661ee46ee15 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -1,5 +1,5 @@
 # SPDX-License-Identifier: GPL-2.0
-ifdef CONFIG_KASAN
+ifdef CONFIG_KASAN_CLASSIC
 ifdef CONFIG_KASAN_INLINE
 	call_threshold := 10000
 else
@@ -45,3 +45,33 @@ endif
 CFLAGS_KASAN_NOSANITIZE := -fno-builtin
 
 endif
+
+ifdef CONFIG_KASAN_TAGS
+
+ifdef CONFIG_KASAN_INLINE
+    instrumentation_flags := -mllvm -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
+else
+    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
+endif
+
+CFLAGS_KASAN_MINIMAL := -fsanitize=hwaddress
+
+# TODO: implement in clang and use -fsanitize=kernel-hwaddress
+# TODO: fix stack intrumentation and remove -hwasan-instrument-stack=0
+
+ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
+    ifneq ($(CONFIG_COMPILE_TEST),y)
+        $(warning Cannot use CONFIG_KASAN_TAGS: \
+            -fsanitize=hwaddress is not supported by compiler)
+    endif
+else
+    CFLAGS_KASAN := $(call cc-option, -fsanitize=hwaddress \
+        -mllvm -hwasan-kernel=1 \
+        -mllvm -hwasan-instrument-stack=0 \
+        -mllvm -hwasan-recover=1 \
+        $(instrumentation_flags))
+endif
+
+CFLAGS_KASAN_NOSANITIZE := -fno-builtin
+
+endif
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
