Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4E53F6B493C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:56:00 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so6896947wrd.23
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:56:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor3134187wre.39.2018.11.27.08.55.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:55:58 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v12 05/25] kasan: add CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS
Date: Tue, 27 Nov 2018 17:55:23 +0100
Message-Id: <20728567aae93b5eb88a6636c94c1af73db7cdbc.1543337629.git.andreyknvl@google.com>
In-Reply-To: <cover.1543337629.git.andreyknvl@google.com>
References: <cover.1543337629.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

This commit splits the current CONFIG_KASAN config option into two:
1. CONFIG_KASAN_GENERIC, that enables the generic KASAN mode (the one
   that exists now);
2. CONFIG_KASAN_SW_TAGS, that enables the software tag-based KASAN mode.

The name CONFIG_KASAN_SW_TAGS is chosen as in the future we will have
another hardware tag-based KASAN mode, that will rely on hardware memory
tagging support in arm64.

With CONFIG_KASAN_SW_TAGS enabled, compiler options are changed to
instrument kernel files with -fsantize=kernel-hwaddress (except the ones
for which KASAN_SANITIZE := n is set).

Both CONFIG_KASAN_GENERIC and CONFIG_KASAN_SW_TAGS support both
CONFIG_KASAN_INLINE and CONFIG_KASAN_OUTLINE instrumentation modes.

This commit also adds empty placeholder (for now) implementation of
tag-based KASAN specific hooks inserted by the compiler and adjusts
common hooks implementation.

While this commit adds the CONFIG_KASAN_SW_TAGS config option, this option
is not selectable, as it depends on HAVE_ARCH_KASAN_SW_TAGS, which we will
enable once all the infrastracture code has been added.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/compiler-clang.h      |  6 +-
 include/linux/compiler-gcc.h        |  6 ++
 include/linux/compiler_attributes.h | 13 ----
 include/linux/kasan.h               | 16 +++--
 lib/Kconfig.kasan                   | 96 +++++++++++++++++++++++------
 mm/kasan/Makefile                   |  6 +-
 mm/kasan/generic.c                  |  2 +-
 mm/kasan/kasan.h                    |  3 +-
 mm/kasan/tags.c                     | 75 ++++++++++++++++++++++
 mm/slub.c                           |  2 +-
 scripts/Makefile.kasan              | 53 +++++++++-------
 11 files changed, 216 insertions(+), 62 deletions(-)
 create mode 100644 mm/kasan/tags.c

diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
index 3e7dafb3ea80..39f668d5066b 100644
--- a/include/linux/compiler-clang.h
+++ b/include/linux/compiler-clang.h
@@ -16,9 +16,13 @@
 /* all clang versions usable with the kernel support KASAN ABI version 5 */
 #define KASAN_ABI_VERSION 5
 
+#if __has_feature(address_sanitizer) || __has_feature(hwaddress_sanitizer)
 /* emulate gcc's __SANITIZE_ADDRESS__ flag */
-#if __has_feature(address_sanitizer)
 #define __SANITIZE_ADDRESS__
+#define __no_sanitize_address \
+		__attribute__((no_sanitize("address", "hwaddress")))
+#else
+#define __no_sanitize_address
 #endif
 
 /*
diff --git a/include/linux/compiler-gcc.h b/include/linux/compiler-gcc.h
index 2010493e1040..5776da43da97 100644
--- a/include/linux/compiler-gcc.h
+++ b/include/linux/compiler-gcc.h
@@ -143,6 +143,12 @@
 #define KASAN_ABI_VERSION 3
 #endif
 
+#if __has_attribute(__no_sanitize_address__)
+#define __no_sanitize_address __attribute__((no_sanitize_address))
+#else
+#define __no_sanitize_address
+#endif
+
 #if GCC_VERSION >= 50100
 #define COMPILER_HAS_GENERIC_BUILTIN_OVERFLOW 1
 #endif
diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
index f8c400ba1929..7bceb9469197 100644
--- a/include/linux/compiler_attributes.h
+++ b/include/linux/compiler_attributes.h
@@ -206,19 +206,6 @@
  */
 #define __noreturn                      __attribute__((__noreturn__))
 
-/*
- * Optional: only supported since gcc >= 4.8
- * Optional: not supported by icc
- *
- *   gcc: https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#index-no_005fsanitize_005faddress-function-attribute
- * clang: https://clang.llvm.org/docs/AttributeReference.html#no-sanitize-address-no-address-safety-analysis
- */
-#if __has_attribute(__no_sanitize_address__)
-# define __no_sanitize_address          __attribute__((__no_sanitize_address__))
-#else
-# define __no_sanitize_address
-#endif
-
 /*
  *   gcc: https://gcc.gnu.org/onlinedocs/gcc/Common-Type-Attributes.html#index-packed-type-attribute
  * clang: https://gcc.gnu.org/onlinedocs/gcc/Common-Variable-Attributes.html#index-packed-variable-attribute
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 52c86a568a4e..b66fdf5ea7ab 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -45,8 +45,6 @@ void kasan_free_pages(struct page *page, unsigned int order);
 
 void kasan_cache_create(struct kmem_cache *cache, unsigned int *size,
 			slab_flags_t *flags);
-void kasan_cache_shrink(struct kmem_cache *cache);
-void kasan_cache_shutdown(struct kmem_cache *cache);
 
 void kasan_poison_slab(struct page *page);
 void kasan_unpoison_object_data(struct kmem_cache *cache, void *object);
@@ -97,8 +95,6 @@ static inline void kasan_free_pages(struct page *page, unsigned int order) {}
 static inline void kasan_cache_create(struct kmem_cache *cache,
 				      unsigned int *size,
 				      slab_flags_t *flags) {}
-static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
-static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
 
 static inline void kasan_poison_slab(struct page *page) {}
 static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
@@ -155,4 +151,16 @@ static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
 
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
index d0bad1bd9a2b..b5d0cbfce4a1 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -1,35 +1,95 @@
+# This config refers to the generic KASAN mode.
 config HAVE_ARCH_KASAN
 	bool
 
+config HAVE_ARCH_KASAN_SW_TAGS
+	bool
+
+config CC_HAS_KASAN_GENERIC
+	def_bool $(cc-option, -fsanitize=kernel-address)
+
+config CC_HAS_KASAN_SW_TAGS
+	def_bool $(cc-option, -fsanitize=kernel-hwaddress)
+
 if HAVE_ARCH_KASAN
 
 config KASAN
-	bool "KASan: runtime memory debugger"
+	bool "KASAN: runtime memory debugger"
+	help
+	  Enables KASAN (KernelAddressSANitizer) - runtime memory debugger,
+	  designed to find out-of-bounds accesses and use-after-free bugs.
+	  See Documentation/dev-tools/kasan.rst for details.
+
+choice
+	prompt "KASAN mode"
+	depends on KASAN
+	default KASAN_GENERIC
+	help
+	  KASAN has two modes: generic KASAN (similar to userspace ASan,
+	  x86_64/arm64/xtensa, enabled with CONFIG_KASAN_GENERIC) and
+	  software tag-based KASAN (a version based on software memory
+	  tagging, arm64 only, similar to userspace HWASan, enabled with
+	  CONFIG_KASAN_SW_TAGS).
+	  Both generic and tag-based KASAN are strictly debugging features.
+
+config KASAN_GENERIC
+	bool "Generic mode"
+	depends on CC_HAS_KASAN_GENERIC
 	depends on (SLUB && SYSFS) || (SLAB && !DEBUG_SLAB)
 	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
 	help
-	  Enables kernel address sanitizer - runtime memory debugger,
-	  designed to find out-of-bounds accesses and use-after-free bugs.
-	  This is strictly a debugging feature and it requires a gcc version
-	  of 4.9.2 or later. Detection of out of bounds accesses to stack or
-	  global variables requires gcc 5.0 or later.
-	  This feature consumes about 1/8 of available memory and brings about
-	  ~x3 performance slowdown.
+	  Enables generic KASAN mode.
+	  Supported in both GCC and Clang. With GCC it requires version 4.9.2
+	  or later for basic support and version 5.0 or later for detection of
+	  out-of-bounds accesses for stack and global variables and for inline
+	  instrumentation mode (CONFIG_KASAN_INLINE). With Clang it requires
+	  version 3.7.0 or later and it doesn't support detection of
+	  out-of-bounds accesses for global variables yet.
+	  This mode consumes about 1/8th of available memory at kernel start
+	  and introduces an overhead of ~x1.5 for the rest of the allocations.
+	  The performance slowdown is ~x3.
 	  For better error detection enable CONFIG_STACKTRACE.
-	  Currently CONFIG_KASAN doesn't work with CONFIG_DEBUG_SLAB
+	  Currently CONFIG_KASAN_GENERIC doesn't work with CONFIG_DEBUG_SLAB
 	  (the resulting kernel does not boot).
 
+if HAVE_ARCH_KASAN_SW_TAGS
+
+config KASAN_SW_TAGS
+	bool "Software tag-based mode"
+	depends on CC_HAS_KASAN_SW_TAGS
+	depends on (SLUB && SYSFS) || (SLAB && !DEBUG_SLAB)
+	select SLUB_DEBUG if SLUB
+	select CONSTRUCTORS
+	select STACKDEPOT
+	help
+	  Enables software tag-based KASAN mode.
+	  This mode requires Top Byte Ignore support by the CPU and therefore
+	  is only supported for arm64.
+	  This mode requires Clang version 7.0.0 or later.
+	  This mode consumes about 1/16th of available memory at kernel start
+	  and introduces an overhead of ~20% for the rest of the allocations.
+	  This mode may potentially introduce problems relating to pointer
+	  casting and comparison, as it embeds tags into the top byte of each
+	  pointer.
+	  For better error detection enable CONFIG_STACKTRACE.
+	  Currently CONFIG_KASAN_SW_TAGS doesn't work with CONFIG_DEBUG_SLAB
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
+	  This enables further checks in generic KASAN, for now it only
+	  includes the address-use-after-scope check that can lead to
+	  excessive kernel stack usage, frame size warnings and longer
 	  compile time.
-	  https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715 has more
+	  See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
 
 
 choice
@@ -53,7 +113,7 @@ config KASAN_INLINE
 	  memory accesses. This is faster than outline (in some workloads
 	  it gives about x2 boost over outline instrumentation), but
 	  make kernel's .text size much bigger.
-	  This requires a gcc version of 5.0 or later.
+	  For CONFIG_KASAN_GENERIC this requires GCC 5.0 or later.
 
 endchoice
 
@@ -67,11 +127,11 @@ config KASAN_S390_4_LEVEL_PAGING
 	  4-level paging instead.
 
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
index d643530b24aa..68ba1822f003 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -2,6 +2,7 @@
 KASAN_SANITIZE := n
 UBSAN_SANITIZE_common.o := n
 UBSAN_SANITIZE_generic.o := n
+UBSAN_SANITIZE_tags.o := n
 KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_generic.o = -pg
@@ -10,5 +11,8 @@ CFLAGS_REMOVE_generic.o = -pg
 
 CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_generic.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
+CFLAGS_tags.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := common.o generic.o report.o init.o quarantine.o
+obj-$(CONFIG_KASAN) := common.o init.o report.o
+obj-$(CONFIG_KASAN_GENERIC) += generic.o quarantine.o
+obj-$(CONFIG_KASAN_SW_TAGS) += tags.o
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index 44ec228de0a2..b8de6d33c55c 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -1,5 +1,5 @@
 /*
- * This file contains core KASAN code.
+ * This file contains core generic KASAN code.
  *
  * Copyright (c) 2014 Samsung Electronics Co., Ltd.
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 659463800f10..19b950eaccff 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -114,7 +114,8 @@ void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
 
-#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+#if defined(CONFIG_KASAN_GENERIC) && \
+	(defined(CONFIG_SLAB) || defined(CONFIG_SLUB))
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
 void quarantine_reduce(void);
 void quarantine_remove_cache(struct kmem_cache *cache);
diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
new file mode 100644
index 000000000000..04194923c543
--- /dev/null
+++ b/mm/kasan/tags.c
@@ -0,0 +1,75 @@
+/*
+ * This file contains core tag-based KASAN code.
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
index 8561a32910dd..e739d46600b9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2992,7 +2992,7 @@ static __always_inline void slab_free(struct kmem_cache *s, struct page *page,
 		do_slab_free(s, page, head, tail, cnt, addr);
 }
 
-#ifdef CONFIG_KASAN
+#ifdef CONFIG_KASAN_GENERIC
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr)
 {
 	do_slab_free(cache, virt_to_head_page(x), x, NULL, 1, addr);
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 69552a39951d..25c259df8ffa 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -1,5 +1,6 @@
 # SPDX-License-Identifier: GPL-2.0
-ifdef CONFIG_KASAN
+ifdef CONFIG_KASAN_GENERIC
+
 ifdef CONFIG_KASAN_INLINE
 	call_threshold := 10000
 else
@@ -12,36 +13,44 @@ CFLAGS_KASAN_MINIMAL := -fsanitize=kernel-address
 
 cc-param = $(call cc-option, -mllvm -$(1), $(call cc-option, --param $(1)))
 
-ifeq ($(call cc-option, $(CFLAGS_KASAN_MINIMAL) -Werror),)
-   ifneq ($(CONFIG_COMPILE_TEST),y)
-        $(warning Cannot use CONFIG_KASAN: \
-            -fsanitize=kernel-address is not supported by compiler)
-   endif
-else
-   # -fasan-shadow-offset fails without -fsanitize
-   CFLAGS_KASAN_SHADOW := $(call cc-option, -fsanitize=kernel-address \
+# -fasan-shadow-offset fails without -fsanitize
+CFLAGS_KASAN_SHADOW := $(call cc-option, -fsanitize=kernel-address \
 			-fasan-shadow-offset=$(KASAN_SHADOW_OFFSET), \
 			$(call cc-option, -fsanitize=kernel-address \
 			-mllvm -asan-mapping-offset=$(KASAN_SHADOW_OFFSET)))
 
-   ifeq ($(strip $(CFLAGS_KASAN_SHADOW)),)
-      CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
-   else
-      # Now add all the compiler specific options that are valid standalone
-      CFLAGS_KASAN := $(CFLAGS_KASAN_SHADOW) \
-	$(call cc-param,asan-globals=1) \
-	$(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
-	$(call cc-param,asan-stack=1) \
-	$(call cc-param,asan-use-after-scope=1) \
-	$(call cc-param,asan-instrument-allocas=1)
-   endif
-
+ifeq ($(strip $(CFLAGS_KASAN_SHADOW)),)
+	CFLAGS_KASAN := $(CFLAGS_KASAN_MINIMAL)
+else
+	# Now add all the compiler specific options that are valid standalone
+	CFLAGS_KASAN := $(CFLAGS_KASAN_SHADOW) \
+	 $(call cc-param,asan-globals=1) \
+	 $(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
+	 $(call cc-param,asan-stack=1) \
+	 $(call cc-param,asan-use-after-scope=1) \
+	 $(call cc-param,asan-instrument-allocas=1)
 endif
 
 ifdef CONFIG_KASAN_EXTRA
 CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
 endif
 
-CFLAGS_KASAN_NOSANITIZE := -fno-builtin
+endif # CONFIG_KASAN_GENERIC
 
+ifdef CONFIG_KASAN_SW_TAGS
+
+ifdef CONFIG_KASAN_INLINE
+    instrumentation_flags := -mllvm -hwasan-mapping-offset=$(KASAN_SHADOW_OFFSET)
+else
+    instrumentation_flags := -mllvm -hwasan-instrument-with-calls=1
+endif
+
+CFLAGS_KASAN := -fsanitize=kernel-hwaddress \
+		-mllvm -hwasan-instrument-stack=0 \
+		$(instrumentation_flags)
+
+endif # CONFIG_KASAN_SW_TAGS
+
+ifdef CONFIG_KASAN
+CFLAGS_KASAN_NOSANITIZE := -fno-builtin
 endif
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
