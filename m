Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A44236B0089
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 11:52:58 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id lj1so9663594pab.6
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 08:52:58 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id qt7si9021771pbc.63.2015.01.21.08.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 21 Jan 2015 08:52:39 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIJ00KNSDQH41A0@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 21 Jan 2015 16:56:41 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v9 17/17] kasan: enable instrumentation of global variables
Date: Wed, 21 Jan 2015 19:51:45 +0300
Message-id: <1421859105-25253-18-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Rusty Russell <rusty@rustcorp.com.au>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

This feature let us to detect accesses out of bounds
of global variables.

The idea of this is simple. Compiler increases each global variable
by redzone size and add constructors invoking __asan_register_globals()
function. Information about global variable (address, size,
size with redzone ...) passed to __asan_register_globals() so we could
poison variable's redzone.

This patch also forces module_alloc() to return 8*PAGE_SIZE aligned
address making shadow memory handling ( kasan_module_alloc()/kasan_module_free() )
more simple. Such alignment guarantees that each shadow page backing
modules address space correspond to only one module_alloc() allocation.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 Makefile                      |  5 +++--
 arch/x86/kernel/module.c      | 12 ++++++++++-
 arch/x86/mm/kasan_init_64.c   |  2 +-
 include/linux/compiler-gcc4.h |  4 ++++
 include/linux/compiler-gcc5.h |  2 ++
 include/linux/kasan.h         | 11 ++++++++++
 kernel/module.c               |  2 ++
 lib/Kconfig.kasan             |  1 +
 mm/kasan/kasan.c              | 50 +++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h              | 23 ++++++++++++++++++++
 mm/kasan/report.c             | 22 +++++++++++++++++++
 11 files changed, 130 insertions(+), 4 deletions(-)

diff --git a/Makefile b/Makefile
index 02530fa..0a285fe 100644
--- a/Makefile
+++ b/Makefile
@@ -751,11 +751,12 @@ else
 	call_threshold := 0
 endif
 
-CFLAGS_KASAN_MINIMAL := $(call cc-option, -fsanitize=kernel-address)
+CFLAGS_KASAN_MINIMAL := $(call cc-option, -fsanitize=kernel-address \
+				--param asan-globals=1)
 
 CFLAGS_KASAN := $(call cc-option, -fsanitize=kernel-address \
 		-fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET) \
-		--param asan-stack=1 \
+		--param asan-stack=1 --param asan-globals=1 \
 		--param asan-instrumentation-with-call-threshold=$(call_threshold))
 
 ifeq ($(CFLAGS_KASAN_MINIMAL),)
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index e830e61..d1ac80b 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -24,6 +24,7 @@
 #include <linux/fs.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
+#include <linux/kasan.h>
 #include <linux/bug.h>
 #include <linux/mm.h>
 #include <linux/gfp.h>
@@ -83,13 +84,22 @@ static unsigned long int get_module_load_offset(void)
 
 void *module_alloc(unsigned long size)
 {
+	void *p;
+
 	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
-	return __vmalloc_node_range(size, 1,
+
+	p = __vmalloc_node_range(size, MODULE_ALIGN,
 				    MODULES_VADDR + get_module_load_offset(),
 				    MODULES_END, GFP_KERNEL | __GFP_HIGHMEM,
 				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
+	if (p && (kasan_module_alloc(p, size) < 0)) {
+		vfree(p);
+		return NULL;
+	}
+
+	return p;
 }
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 042f404..112f537 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -213,7 +213,7 @@ void __init kasan_init(void)
 			kasan_mem_to_shadow((unsigned long)_end),
 			NUMA_NO_NODE);
 
-	populate_zero_shadow(kasan_mem_to_shadow(MODULES_VADDR),
+	populate_zero_shadow(kasan_mem_to_shadow(MODULES_END),
 			KASAN_SHADOW_END);
 
 	memset(kasan_poisoned_page, KASAN_SHADOW_GAP, PAGE_SIZE);
diff --git a/include/linux/compiler-gcc4.h b/include/linux/compiler-gcc4.h
index d1a5582..769e198 100644
--- a/include/linux/compiler-gcc4.h
+++ b/include/linux/compiler-gcc4.h
@@ -85,3 +85,7 @@
 #define __HAVE_BUILTIN_BSWAP16__
 #endif
 #endif /* CONFIG_ARCH_USE_BUILTIN_BSWAP */
+
+#if GCC_VERSION >= 40902
+#define KASAN_ABI_VERSION 3
+#endif
diff --git a/include/linux/compiler-gcc5.h b/include/linux/compiler-gcc5.h
index c8c5659..efee493 100644
--- a/include/linux/compiler-gcc5.h
+++ b/include/linux/compiler-gcc5.h
@@ -63,3 +63,5 @@
 #define __HAVE_BUILTIN_BSWAP64__
 #define __HAVE_BUILTIN_BSWAP16__
 #endif /* CONFIG_ARCH_USE_BUILTIN_BSWAP */
+
+#define KASAN_ABI_VERSION 4
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index f8eca6a..5b7debf 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -15,6 +15,7 @@ struct page;
 #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
+#define KASAN_GLOBAL_REDZONE    0xFA  /* redzone for global variable */
 #define KASAN_SHADOW_GAP        0xF9  /* address belongs to shadow memory */
 
 /*
@@ -61,8 +62,15 @@ void kasan_krealloc(const void *object, size_t new_size);
 void kasan_slab_alloc(struct kmem_cache *s, void *object);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
+#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
+
+int kasan_module_alloc(void *addr, size_t size);
+void kasan_module_free(void *addr);
+
 #else /* CONFIG_KASAN */
 
+#define MODULE_ALIGN 1
+
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 
 static inline void kasan_enable_local(void) {}
@@ -86,6 +94,9 @@ static inline void kasan_krealloc(const void *object, size_t new_size) {}
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
 static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
 
+static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
+static inline void kasan_module_free(void *addr) {}
+
 #endif /* CONFIG_KASAN */
 
 #endif /* LINUX_KASAN_H */
diff --git a/kernel/module.c b/kernel/module.c
index 3965511..1689f43 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -56,6 +56,7 @@
 #include <linux/async.h>
 #include <linux/percpu.h>
 #include <linux/kmemleak.h>
+#include <linux/kasan.h>
 #include <linux/jump_label.h>
 #include <linux/pfn.h>
 #include <linux/bsearch.h>
@@ -1798,6 +1799,7 @@ static void unset_module_init_ro_nx(struct module *mod) { }
 void __weak module_free(struct module *mod, void *module_region)
 {
 	vfree(module_region);
+	kasan_module_free(module_region);
 }
 
 void __weak module_arch_cleanup(struct module *mod)
diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index f3bee26..6b00c65 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -7,6 +7,7 @@ config KASAN
 	bool "AddressSanitizer: runtime memory debugger"
 	depends on !MEMORY_HOTPLUG
 	depends on SLUB_DEBUG
+	select CONSTRUCTORS
 	help
 	  Enables address sanitizer - runtime memory debugger,
 	  designed to find out-of-bounds accesses and use-after-free bugs.
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index a59c976..cf26766 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -21,6 +21,7 @@
 #include <linux/kernel.h>
 #include <linux/memblock.h>
 #include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/printk.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -388,6 +389,55 @@ void kasan_kfree_large(const void *ptr)
 			KASAN_FREE_PAGE);
 }
 
+int kasan_module_alloc(void *addr, size_t size)
+{
+
+	size_t shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
+				PAGE_SIZE);
+	unsigned long shadow_start = kasan_mem_to_shadow((unsigned long)addr);
+	void *ret;
+
+	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
+		return -EINVAL;
+
+	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
+			shadow_start + shadow_size,
+			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
+			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
+			__builtin_return_address(0));
+	return ret ? 0 : -ENOMEM;
+}
+
+void kasan_module_free(void *addr)
+{
+	vfree((void *)kasan_mem_to_shadow((unsigned long)addr));
+}
+
+static void register_global(struct kasan_global *global)
+{
+	size_t aligned_size = round_up(global->size, KASAN_SHADOW_SCALE_SIZE);
+
+	kasan_unpoison_shadow(global->beg, global->size);
+
+	kasan_poison_shadow(global->beg + aligned_size,
+		global->size_with_redzone - aligned_size,
+		KASAN_GLOBAL_REDZONE);
+}
+
+void __asan_register_globals(struct kasan_global *globals, size_t size)
+{
+	int i;
+
+	for (i = 0; i < size; i++)
+		register_global(&globals[i]);
+}
+EXPORT_SYMBOL(__asan_register_globals);
+
+void __asan_unregister_globals(struct kasan_global *globals, size_t size)
+{
+}
+EXPORT_SYMBOL(__asan_unregister_globals);
+
 #define DECLARE_ASAN_CHECK(size)				\
 	void __asan_load##size(unsigned long addr)		\
 	{							\
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index da0e53c..e88a143 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -6,6 +6,11 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+/* Don't break randconfig/all*config builds */
+#ifndef KASAN_ABI_VERSION
+#define KASAN_ABI_VERSION 1
+#endif
+
 struct access_info {
 	unsigned long access_addr;
 	unsigned long first_bad_addr;
@@ -14,6 +19,24 @@ struct access_info {
 	unsigned long ip;
 };
 
+struct kasan_source_location {
+	const char *filename;
+	int line_no;
+	int column_no;
+};
+
+struct kasan_global {
+	const void *beg;		/* Address of the beginning of the global variable. */
+	size_t size;			/* Size of the global variable. */
+	size_t size_with_redzone;	/* Size of the variable + size of the red zone. 32 bytes aligned */
+	const void *name;
+	const void *module_name;	/* Name of the module where the global variable is declared. */
+	unsigned long has_dynamic_init;	/* This needed for C++ */
+#if KASAN_ABI_VERSION >= 4
+	struct kasan_source_location *location;
+#endif
+};
+
 void kasan_report_error(struct access_info *info);
 void kasan_report_user_access(struct access_info *info);
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index faa07f0..27f3d95 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -23,6 +23,8 @@
 #include <linux/types.h>
 #include <linux/kasan.h>
 
+#include <asm/sections.h>
+
 #include "kasan.h"
 #include "../slab.h"
 
@@ -61,6 +63,7 @@ static void print_error_description(struct access_info *info)
 		break;
 	case KASAN_PAGE_REDZONE:
 	case KASAN_KMALLOC_REDZONE:
+	case KASAN_GLOBAL_REDZONE:
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		bug_type = "out of bounds access";
 		break;
@@ -83,6 +86,19 @@ static void print_error_description(struct access_info *info)
 		info->access_size, current->comm, task_pid_nr(current));
 }
 
+static inline bool kernel_or_module_addr(unsigned long addr)
+{
+	return (addr >= (unsigned long)_stext && addr < (unsigned long)_end)
+		|| (addr >= MODULES_VADDR  && addr < MODULES_END);
+}
+
+static inline bool init_task_stack_addr(unsigned long addr)
+{
+	return addr >= (unsigned long)&init_thread_union.stack &&
+		(addr <= (unsigned long)&init_thread_union.stack +
+			sizeof(init_thread_union.stack));
+}
+
 static void print_address_description(struct access_info *info)
 {
 	unsigned long addr = info->access_addr;
@@ -111,6 +127,12 @@ static void print_address_description(struct access_info *info)
 		dump_page(page, "kasan: bad access detected");
 	}
 
+	if (kernel_or_module_addr(addr)) {
+		if (!init_task_stack_addr(addr))
+			pr_err("Address belongs to variable %pS\n",
+				(void *)addr);
+	}
+
 	dump_stack();
 }
 
-- 
2.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
