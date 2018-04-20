Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B17F96B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:47:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v11-v6so9091898wri.13
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:47:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 41-v6sor2832799wrc.3.2018.04.20.07.47.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Apr 2018 07:47:02 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH v3 02/15] khwasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW
Date: Fri, 20 Apr 2018 16:46:40 +0200
Message-Id: <b7bd30c77a785f7c757420ba63da9a786619b52b.1524235387.git.andreyknvl@google.com>
In-Reply-To: <cover.1524235387.git.andreyknvl@google.com>
References: <cover.1524235387.git.andreyknvl@google.com>
In-Reply-To: <cover.1524235387.git.andreyknvl@google.com>
References: <cover.1524235387.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, "GitAuthor : Andrey Konovalov" <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, Michael Weiser <michael.weiser@gmx.de>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Steve Capper <steve.capper@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, David Woodhouse <dwmw@amazon.co.uk>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, Herbert Xu <herbert@gondor.apana.org.au>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

This commit splits the current CONFIG_KASAN config option into two:
1. CONFIG_KASAN_GENERIC, that enables the generic software-only KASAN
   version (the one that exists now);
2. CONFIG_KASAN_HW, that enables KHWASAN.

With CONFIG_KASAN_HW enabled, compiler options are changed to instrument
kernel files wiht -fsantize=hwaddress (except the ones for which
KASAN_SANITIZE := n is set).

Both CONFIG_KASAN_GENERIC and CONFIG_KASAN_HW support both
CONFIG_KASAN_INLINE and CONFIG_KASAN_OUTLINE instrumentation modes.

This commit also adds empty placeholder (for now) implementation of
KHWASAN specific hooks inserted by the compiler and adjusts common hooks
implementation to compile correctly with each of the config options.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/Kconfig             |  1 +
 include/linux/compiler-clang.h |  5 ++-
 include/linux/compiler-gcc.h   |  4 ++
 include/linux/compiler.h       |  3 +-
 include/linux/kasan.h          | 16 ++++++--
 lib/Kconfig.kasan              | 68 ++++++++++++++++++++++--------
 mm/kasan/Makefile              |  6 ++-
 mm/kasan/kasan.h               | 11 ++++-
 mm/kasan/khwasan.c             | 75 ++++++++++++++++++++++++++++++++++
 mm/slub.c                      |  2 +-
 scripts/Makefile.kasan         | 27 +++++++++++-
 11 files changed, 192 insertions(+), 26 deletions(-)
 create mode 100644 mm/kasan/khwasan.c

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index eb2cf4938f6d..6553aaa61e6a 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -88,6 +88,7 @@ config ARM64
 	select HAVE_ARCH_HUGE_VMAP
 	select HAVE_ARCH_JUMP_LABEL
 	select HAVE_ARCH_KASAN if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
+	select HAVE_ARCH_KASAN_HW if !(ARM64_16K_PAGES && ARM64_VA_BITS_48)
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_MMAP_RND_BITS
 	select HAVE_ARCH_MMAP_RND_COMPAT_BITS if COMPAT
diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index 7d98e263e048..72681c6fd418 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -21,13 +21,16 @@
 #define KASAN_ABI_VERSION 5
 
 /* emulate gcc's __SANITIZE_ADDRESS__ flag */
-#if __has_feature(address_sanitizer)
+#if __has_feature(address_sanitizer) || __has_feature(hwaddress_sanitizer)
 #define __SANITIZE_ADDRESS__
 #endif
 
 #undef __no_sanitize_address
 #define __no_sanitize_address __attribute__((no_sanitize("address")))
 
+#undef __no_sanitize_hwaddress
+#define __no_sanitize_hwaddress __attribute__((no_sanitize("hwaddress")))
+
 /* Clang doesn't have a way to turn it off per-function, yet. */
 #ifdef __noretpoline
 #undef __noretpoline
diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index b4bf73f5e38f..00a51feb786d 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -338,6 +338,10 @@
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
index cbdc54543803..6608aa9b35ac 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -45,8 +45,6 @@ void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags);
-void kasan_cache_shrink(struct kmem_cache *cache);
-void kasan_cache_shutdown(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
@@ -94,8 +92,6 @@ static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      unsigned int *size,
 				      slab_flags_t *flags) {}
-static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
-static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
@@ -141,4 +137,16 @@ static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
 
 #endif /* CONFIG_KASAN */
 
+#ifdef CONFIG_KASAN_GENERIC
+
+void kasan_cache_shrink(struct kmem_cache *cache);
+void kasan_cache_shutdown(struct kmem_cache *cache);
+
+#else /* CONFIG_KASAN_GENERIC */
+
+static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
+static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
+
+#endif /* CONFIG_KASAN_GENERIC */
+
 #endif /* LINUX_KASAN_H */
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 3d35d062970d..2f14056f1003 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -1,33 +1,69 @@
 config HAVE_ARCH_KASAN
 	bool
 
+config HAVE_ARCH_KASAN_HW
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
+	  ASan, enabled with CONFIG_KASAN_GENERIC) and KHWASAN (a version
+	  based on pointer tagging, only for arm64, similar to userspace
+	  HWASan, enabled with CONFIG_KASAN_HW).
+
+choice
+	prompt "KASAN mode"
+	depends on KASAN
+	default KASAN_GENERIC
+
+config KASAN_GENERIC
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
+	  Currently CONFIG_KASAN_GENERIC doesn't work with CONFIG_DEBUG_SLAB
 	  (the resulting kernel does not boot).
 
+if HAVE_ARCH_KASAN_HW
+
+config KASAN_HW
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
+	  Currently CONFIG_KASAN_HW doesn't work with CONFIG_DEBUG_SLAB
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
+	depends on KASAN_GENERIC && DEBUG_KERNEL && !COMPILE_TEST
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
+	  For CONFIG_KASAN_GENERIC this requires GCC 5.0 or later.
 
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
index a6df14bffb6b..14955add96d3 100644
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
+obj-$(CONFIG_KASAN_GENERIC) += kasan.o quarantine.o
+obj-$(CONFIG_KASAN_HW) += khwasan.o
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c39039308b98..5091a433f266 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -98,7 +98,15 @@ struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object);
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 					const void *object);
+
+#ifdef CONFIG_KASAN_GENERIC
 unsigned int optimal_redzone(unsigned int object_size);
+#else
+static inline unsigned int optimal_redzone(unsigned int object_size)
+{
+	return 0;
+}
+#endif
 
 static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 {
@@ -115,7 +123,8 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
 
-#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_KASAN_GENERIC) && \
+	(defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
 void quarantine_remove_cache(struct kmem_cache *cache);
diff --git a/mm/kasan/khwasan.c b/mm/kasan/khwasan.c
new file mode 100644
index 000000000000..e2c3a7f7fd1f
--- /dev/null
+++ b/mm/kasan/khwasan.c
@@ -0,0 +1,75 @@
+/*
+ * This file contains core KHWASAN code.
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
+void check_memory_region(unsigned long addr, size_t size, bool write,
+				unsigned long ret_ip)
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
index 4fcd1442a761..b3118f7ea92a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2989,7 +2989,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 		do_slab_free(s, page, head, tail, cnt, addr);
 }
 
-#ifdef CONFIG_KASAN
+#ifdef CONFIG_KASAN_GENERIC
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
 {
 	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 69552a39951d..47023daf5606 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -1,5 +1,5 @@
 # SPDX-License-Identifier: GPL-2.0
-ifdef CONFIG_KASAN
+ifdef CONFIG_KASAN_GENERIC
 ifdef CONFIG_KASAN_INLINE
 	call_threshold := 10000
 else
@@ -45,3 +45,28 @@ endif
 CFLAGS_KASAN_NOSANITIZE := -fno-builtin
 
 endif
+
+ifdef CONFIG_KASAN_HW
+
+ifdef CONFIG_KASAN_INLINE
+    instrumentation_flags := -mllvm -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
+else
+    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
+endif
+
+CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-hwaddress
+
+ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
+    ifneq ($(CONFIG_COMPILE_TEST),y)
+        $(warning Cannot use CONFIG_KASAN_HW: \
+            -fsanitize=hwaddress is not supported by compiler)
+    endif
+else
+    CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-hwaddress \
+        -mllvm -hwasan-instrument-stack=0 \
+        $(instrumentation_flags))
+endif
+
+CFLAGS_KASAN_NOSANITIZE := -fno-builtin
+
+endif
-- 
2.17.0.484.g0c8726318c-goog
