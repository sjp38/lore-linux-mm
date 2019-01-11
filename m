Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19C6E8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:58:35 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x18-v6so4005503lji.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:58:35 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id y29si58212219lfj.45.2019.01.11.10.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 10:58:32 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] kasan: Remove use after scope bugs detection.
Date: Fri, 11 Jan 2019 21:58:42 +0300
Message-Id: <20190111185842.13978-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Qian Cai <cai@lca.pw>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

Use after scope bugs detector seems to be almost entirely useless
for the linux kernel. It exists over two years, but I've seen only
one valid bug so far [1]. And the bug was fixed before it has been
reported. There were some other use-after-scope reports, but they
were false-positives due to different reasons like incompatibility
with structleak plugin.

This feature significantly increases stack usage, especially with
GCC < 9 version, and causes a 32K stack overflow. It probably
adds performance penalty too.

Given all that, let's remove use-after-scope detector entirely.

While preparing this patch I've noticed that we mistakenly enable
use-after-scope detection for clang compiler regardless of
CONFIG_KASAN_EXTRA setting. This is also fixed now.

[1] http://lkml.kernel.org/r/<20171129052106.rhgbjhhis53hkgfn@wfg-t540p.sh.intel.com>

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
---
 arch/arm64/include/asm/memory.h |  4 ----
 lib/Kconfig.debug               |  1 -
 lib/Kconfig.kasan               | 10 ----------
 lib/test_kasan.c                | 24 ------------------------
 mm/kasan/generic.c              | 19 -------------------
 mm/kasan/generic_report.c       |  3 ---
 mm/kasan/kasan.h                |  3 ---
 scripts/Makefile.kasan          |  5 -----
 scripts/gcc-plugins/Kconfig     |  4 ----
 9 files changed, 73 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index e1ec947e7c0c..0e236a99b3ef 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -80,11 +80,7 @@
  */
 #ifdef CONFIG_KASAN
 #define KASAN_SHADOW_SIZE	(UL(1) << (VA_BITS - KASAN_SHADOW_SCALE_SHIFT))
-#ifdef CONFIG_KASAN_EXTRA
-#define KASAN_THREAD_SHIFT	2
-#else
 #define KASAN_THREAD_SHIFT	1
-#endif /* CONFIG_KASAN_EXTRA */
 #else
 #define KASAN_SHADOW_SIZE	(0)
 #define KASAN_THREAD_SHIFT	0
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index d4df5b24d75e..a219f3488ad7 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -222,7 +222,6 @@ config ENABLE_MUST_CHECK
 config FRAME_WARN
 	int "Warn for stack frames larger than (needs gcc 4.4)"
 	range 0 8192
-	default 3072 if KASAN_EXTRA
 	default 2048 if GCC_PLUGIN_LATENT_ENTROPY
 	default 1280 if (!64BIT && PARISC)
 	default 1024 if (!64BIT && !PARISC)
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index d8c474b6691e..67d7d1309c52 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -78,16 +78,6 @@ config KASAN_SW_TAGS
 
 endchoice
 
-config KASAN_EXTRA
-	bool "KASAN: extra checks"
-	depends on KASAN_GENERIC && DEBUG_KERNEL && !COMPILE_TEST
-	help
-	  This enables further checks in generic KASAN, for now it only
-	  includes the address-use-after-scope check that can lead to
-	  excessive kernel stack usage, frame size warnings and longer
-	  compile time.
-	  See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81715
-
 choice
 	prompt "Instrumentation type"
 	depends on KASAN
diff --git a/lib/test_kasan.c b/lib/test_kasan.c
index 51b78405bf24..7de2702621dc 100644
--- a/lib/test_kasan.c
+++ b/lib/test_kasan.c
@@ -480,29 +480,6 @@ static noinline void __init copy_user_test(void)
 	kfree(kmem);
 }
 
-static noinline void __init use_after_scope_test(void)
-{
-	volatile char *volatile p;
-
-	pr_info("use-after-scope on int\n");
-	{
-		int local = 0;
-
-		p = (char *)&local;
-	}
-	p[0] = 1;
-	p[3] = 1;
-
-	pr_info("use-after-scope on array\n");
-	{
-		char local[1024] = {0};
-
-		p = local;
-	}
-	p[0] = 1;
-	p[1023] = 1;
-}
-
 static noinline void __init kasan_alloca_oob_left(void)
 {
 	volatile int i = 10;
@@ -682,7 +659,6 @@ static int __init kmalloc_tests_init(void)
 	kasan_alloca_oob_right();
 	ksize_unpoisons_memory();
 	copy_user_test();
-	use_after_scope_test();
 	kmem_cache_double_free();
 	kmem_cache_invalid_free();
 	kasan_memchr();
diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
index ccb6207276e3..504c79363a34 100644
--- a/mm/kasan/generic.c
+++ b/mm/kasan/generic.c
@@ -275,25 +275,6 @@ EXPORT_SYMBOL(__asan_storeN_noabort);
 void __asan_handle_no_return(void) {}
 EXPORT_SYMBOL(__asan_handle_no_return);
 
-/* Emitted by compiler to poison large objects when they go out of scope. */
-void __asan_poison_stack_memory(const void *addr, size_t size)
-{
-	/*
-	 * Addr is KASAN_SHADOW_SCALE_SIZE-aligned and the object is surrounded
-	 * by redzones, so we simply round up size to simplify logic.
-	 */
-	kasan_poison_shadow(addr, round_up(size, KASAN_SHADOW_SCALE_SIZE),
-			    KASAN_USE_AFTER_SCOPE);
-}
-EXPORT_SYMBOL(__asan_poison_stack_memory);
-
-/* Emitted by compiler to unpoison large objects when they go into scope. */
-void __asan_unpoison_stack_memory(const void *addr, size_t size)
-{
-	kasan_unpoison_shadow(addr, size);
-}
-EXPORT_SYMBOL(__asan_unpoison_stack_memory);
-
 /* Emitted by compiler to poison alloca()ed objects. */
 void __asan_alloca_poison(unsigned long addr, size_t size)
 {
diff --git a/mm/kasan/generic_report.c b/mm/kasan/generic_report.c
index 5e12035888f2..36c645939bc9 100644
--- a/mm/kasan/generic_report.c
+++ b/mm/kasan/generic_report.c
@@ -82,9 +82,6 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	case KASAN_KMALLOC_FREE:
 		bug_type = "use-after-free";
 		break;
-	case KASAN_USE_AFTER_SCOPE:
-		bug_type = "use-after-scope";
-		break;
 	case KASAN_ALLOCA_LEFT:
 	case KASAN_ALLOCA_RIGHT:
 		bug_type = "alloca-out-of-bounds";
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index ea51b2d898ec..3e0c11f7d7a1 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -34,7 +34,6 @@
 #define KASAN_STACK_MID         0xF2
 #define KASAN_STACK_RIGHT       0xF3
 #define KASAN_STACK_PARTIAL     0xF4
-#define KASAN_USE_AFTER_SCOPE   0xF8
 
 /*
  * alloca redzone shadow values
@@ -187,8 +186,6 @@ void __asan_unregister_globals(struct kasan_global *globals, size_t size);
 void __asan_loadN(unsigned long addr, size_t size);
 void __asan_storeN(unsigned long addr, size_t size);
 void __asan_handle_no_return(void);
-void __asan_poison_stack_memory(const void *addr, size_t size);
-void __asan_unpoison_stack_memory(const void *addr, size_t size);
 void __asan_alloca_poison(unsigned long addr, size_t size);
 void __asan_allocas_unpoison(const void *stack_top, const void *stack_bottom);
 
diff --git a/scripts/Makefile.kasan b/scripts/Makefile.kasan
index 25c259df8ffa..f1fb8e502657 100644
--- a/scripts/Makefile.kasan
+++ b/scripts/Makefile.kasan
@@ -27,14 +27,9 @@ else
 	 $(call cc-param,asan-globals=1) \
 	 $(call cc-param,asan-instrumentation-with-call-threshold=$(call_threshold)) \
 	 $(call cc-param,asan-stack=1) \
-	 $(call cc-param,asan-use-after-scope=1) \
 	 $(call cc-param,asan-instrument-allocas=1)
 endif
 
-ifdef CONFIG_KASAN_EXTRA
-CFLAGS_KASAN += $(call cc-option, -fsanitize-address-use-after-scope)
-endif
-
 endif # CONFIG_KASAN_GENERIC
 
 ifdef CONFIG_KASAN_SW_TAGS
diff --git a/scripts/gcc-plugins/Kconfig b/scripts/gcc-plugins/Kconfig
index d45f7f36b859..d9fd9988ef27 100644
--- a/scripts/gcc-plugins/Kconfig
+++ b/scripts/gcc-plugins/Kconfig
@@ -68,10 +68,6 @@ config GCC_PLUGIN_LATENT_ENTROPY
 
 config GCC_PLUGIN_STRUCTLEAK
 	bool "Force initialization of variables containing userspace addresses"
-	# Currently STRUCTLEAK inserts initialization out of live scope of
-	# variables from KASAN point of view. This leads to KASAN false
-	# positive reports. Prohibit this combination for now.
-	depends on !KASAN_EXTRA
 	help
 	  This plugin zero-initializes any structures containing a
 	  __user attribute. This can prevent some classes of information
-- 
2.19.2
