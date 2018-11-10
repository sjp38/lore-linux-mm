Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9BD6B0758
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 20:36:30 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r13so2380659pgb.7
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 17:36:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n32si8099080pgm.439.2018.11.09.17.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 17:36:28 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v9 2/4] x86/modules: Increase randomization for modules
Date: Fri,  9 Nov 2018 17:38:05 -0800
Message-Id: <20181110013807.24903-3-rick.p.edgecombe@intel.com>
In-Reply-To: <20181110013807.24903-1-rick.p.edgecombe@intel.com>
References: <20181110013807.24903-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This changes the behavior of the KASLR logic for allocating memory for the text
sections of loadable modules. It randomizes the location of each module text
section with about 17 bits of entropy in typical use. This is enabled on X86_64
only. For 32 bit, the behavior is unchanged.

It refactors existing code around module randomization somewhat. There are now
three different behaviors for x86 module_alloc depending on config.
RANDOMIZE_BASE=n, and RANDOMIZE_BASE=y ARCH=x86_64, and RANDOMIZE_BASE=y
ARCH=i386. The refactor of the existing code is to try to clearly show what
those behaviors are without having three separate versions or threading the
behaviors in a bunch of little spots. The reason it is not enabled on 32 bit
yet is because the module space is much smaller and simulations haven't been
run to see how it performs.

The new algorithm breaks the module space in two, a random area and a backup
area. It first tries to allocate at a number of randomly located starting pages
inside the random section. If this fails, then it will allocate in the backup
area. The backup area base will be offset in the same way as the current
algorithm does for the base area, 1024 possible locations.

Due to boot_params being defined with different types in different places,
placing the config helpers modules.h or kaslr.h caused conflicts elsewhere, and
so they are placed in a new file, kaslr_modules.h, instead.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/Kconfig                        |   3 +
 arch/x86/include/asm/kaslr_modules.h    |  38 ++++++++
 arch/x86/include/asm/pgtable_64_types.h |   7 ++
 arch/x86/kernel/module.c                | 111 +++++++++++++++++++-----
 4 files changed, 136 insertions(+), 23 deletions(-)
 create mode 100644 arch/x86/include/asm/kaslr_modules.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index ba7e3464ee92..db93cde0528a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2144,6 +2144,9 @@ config RANDOMIZE_BASE
 
 	  If unsure, say Y.
 
+config RANDOMIZE_FINE_MODULE
+	def_bool y if RANDOMIZE_BASE && X86_64 && !CONFIG_UML
+
 # Relocation on x86 needs some additional build support
 config X86_NEED_RELOCS
 	def_bool y
diff --git a/arch/x86/include/asm/kaslr_modules.h b/arch/x86/include/asm/kaslr_modules.h
new file mode 100644
index 000000000000..1da6eced4b47
--- /dev/null
+++ b/arch/x86/include/asm/kaslr_modules.h
@@ -0,0 +1,38 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _ASM_KASLR_MODULES_H_
+#define _ASM_KASLR_MODULES_H_
+
+#ifdef CONFIG_RANDOMIZE_BASE
+/* kaslr_enabled is not always defined */
+static inline int kaslr_mod_randomize_base(void)
+{
+	return kaslr_enabled();
+}
+#else
+static inline int kaslr_mod_randomize_base(void)
+{
+	return 0;
+}
+#endif /* CONFIG_RANDOMIZE_BASE */
+
+#ifdef CONFIG_RANDOMIZE_FINE_MODULE
+/* kaslr_enabled is not always defined */
+static inline int kaslr_mod_randomize_each_module(void)
+{
+	return kaslr_enabled();
+}
+
+static inline unsigned long get_modules_rand_len(void)
+{
+	return MODULES_RAND_LEN;
+}
+#else
+static inline int kaslr_mod_randomize_each_module(void)
+{
+	return 0;
+}
+
+unsigned long get_modules_rand_len(void);
+#endif /* CONFIG_RANDOMIZE_FINE_MODULE */
+
+#endif
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 04edd2d58211..5e26369ab86c 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -143,6 +143,13 @@ extern unsigned int ptrs_per_p4d;
 #define MODULES_END		_AC(0xffffffffff000000, UL)
 #define MODULES_LEN		(MODULES_END - MODULES_VADDR)
 
+/*
+ * Dedicate the first part of the module space to a randomized area when KASLR
+ * is in use.  Leave the remaining part for a fallback if we are unable to
+ * allocate in the random area.
+ */
+#define MODULES_RAND_LEN	PAGE_ALIGN((MODULES_LEN/3)*2)
+
 #define ESPFIX_PGD_ENTRY	_AC(-2, UL)
 #define ESPFIX_BASE_ADDR	(ESPFIX_PGD_ENTRY << P4D_SHIFT)
 
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index b052e883dd8c..35cb912ed1f8 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -36,6 +36,7 @@
 #include <asm/pgtable.h>
 #include <asm/setup.h>
 #include <asm/unwind.h>
+#include <asm/kaslr_modules.h>
 
 #if 0
 #define DEBUGP(fmt, ...)				\
@@ -48,34 +49,96 @@ do {							\
 } while (0)
 #endif
 
-#ifdef CONFIG_RANDOMIZE_BASE
 static unsigned long module_load_offset;
+static const unsigned long NO_TRY_RAND = 10000;
 
 /* Mutex protects the module_load_offset. */
 static DEFINE_MUTEX(module_kaslr_mutex);
 
 static unsigned long int get_module_load_offset(void)
 {
-	if (kaslr_enabled()) {
-		mutex_lock(&module_kaslr_mutex);
-		/*
-		 * Calculate the module_load_offset the first time this
-		 * code is called. Once calculated it stays the same until
-		 * reboot.
-		 */
-		if (module_load_offset == 0)
-			module_load_offset =
-				(get_random_int() % 1024 + 1) * PAGE_SIZE;
-		mutex_unlock(&module_kaslr_mutex);
-	}
+	mutex_lock(&module_kaslr_mutex);
+	/*
+	 * Calculate the module_load_offset the first time this
+	 * code is called. Once calculated it stays the same until
+	 * reboot.
+	 */
+	if (module_load_offset == 0)
+		module_load_offset = (get_random_int() % 1024 + 1) * PAGE_SIZE;
+	mutex_unlock(&module_kaslr_mutex);
+
 	return module_load_offset;
 }
-#else
-static unsigned long int get_module_load_offset(void)
+
+static unsigned long get_module_vmalloc_start(void)
 {
-	return 0;
+	unsigned long addr = MODULES_VADDR;
+
+	if (kaslr_mod_randomize_base())
+		addr += get_module_load_offset();
+
+	if (kaslr_mod_randomize_each_module())
+		addr += get_modules_rand_len();
+
+	return addr;
+}
+
+static void *try_module_alloc(unsigned long addr, unsigned long size)
+{
+	const unsigned long vm_flags = 0;
+
+	return __vmalloc_node_try_addr(addr, size, GFP_KERNEL, PAGE_KERNEL_EXEC,
+					vm_flags, NUMA_NO_NODE,
+					__builtin_return_address(0));
+}
+
+/*
+ * Find a random address to try that won't obviously not fit. Random areas are
+ * allowed to overflow into the backup area
+ */
+static unsigned long get_rand_module_addr(unsigned long size)
+{
+	unsigned long nr_max_pos = (MODULES_LEN - size) / MODULE_ALIGN + 1;
+	unsigned long nr_rnd_pos = get_modules_rand_len() / MODULE_ALIGN;
+	unsigned long nr_pos = min(nr_max_pos, nr_rnd_pos);
+
+	unsigned long module_position_nr = get_random_long() % nr_pos;
+	unsigned long offset = module_position_nr * MODULE_ALIGN;
+
+	return MODULES_VADDR + offset;
+}
+
+/*
+ * Try to allocate in the random area at 10000 random addresses. If these
+ * fail, return NULL.
+ */
+static void *try_module_randomize_each(unsigned long size)
+{
+	void *p = NULL;
+	unsigned int i;
+
+	/* This will have a guard page */
+	unsigned long va_size = PAGE_ALIGN(size) + PAGE_SIZE;
+
+	if (!kaslr_mod_randomize_each_module())
+		return NULL;
+
+	/* Make sure there is at least one address that might fit. */
+	if (va_size < PAGE_ALIGN(size) || va_size > MODULES_LEN)
+		return NULL;
+
+	/* Try to find a spot that doesn't need a lazy purge */
+	for (i = 0; i < NO_TRY_RAND; i++) {
+		unsigned long addr = get_rand_module_addr(va_size);
+
+		p = try_module_alloc(addr, size);
+
+		if (p)
+			return p;
+	}
+
+	return NULL;
 }
-#endif
 
 void *module_alloc(unsigned long size)
 {
@@ -84,16 +147,18 @@ void *module_alloc(unsigned long size)
 	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
 
-	p = __vmalloc_node_range(size, MODULE_ALIGN,
-				    MODULES_VADDR + get_module_load_offset(),
-				    MODULES_END, GFP_KERNEL,
-				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
-				    __builtin_return_address(0));
+	p = try_module_randomize_each(size);
+
+	if (!p)
+		p = __vmalloc_node_range(size, MODULE_ALIGN,
+				get_module_vmalloc_start(), MODULES_END,
+				GFP_KERNEL, PAGE_KERNEL_EXEC, 0,
+				NUMA_NO_NODE, __builtin_return_address(0));
+
 	if (p && (kasan_module_alloc(p, size) < 0)) {
 		vfree(p);
 		return NULL;
 	}
-
 	return p;
 }
 
-- 
2.17.1
