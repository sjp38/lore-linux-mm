Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A202B6B0008
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 17:38:34 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r67-v6so13371706pfd.21
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 14:38:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f4-v6si12830226plo.204.2018.10.01.14.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 14:38:32 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v7 2/4] x86/modules: Increase randomization for modules
Date: Mon,  1 Oct 2018 14:38:45 -0700
Message-Id: <1538429927-17834-3-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1538429927-17834-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1538429927-17834-1-git-send-email-rick.p.edgecombe@intel.com>
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
inside the random section without purging any lazy free vmap areas and
triggering the associated TLB flush. If this fails, it will try again a number
of times allowing for purges if needed. It also saves any position that could
have succeeded if it was allowed to purge, which doubles the chances of finding
a spot that would fit. Finally if those both fail to find a position it will
allocate in the backup area. The backup area base will be offset in the same
way as the current algorithm does for the base area, 1024 possible locations.

Due to boot_params being defined with different types in different places,
placing the config helpers modules.h or kaslr.h caused conflicts elsewhere, and
so they are placed in a new file, kaslr_modules.h, instead.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/Kconfig                        |   3 +
 arch/x86/include/asm/kaslr_modules.h    |  38 +++++++++
 arch/x86/include/asm/pgtable_64_types.h |   7 ++
 arch/x86/kernel/module.c                | 139 ++++++++++++++++++++++++++------
 4 files changed, 164 insertions(+), 23 deletions(-)
 create mode 100644 arch/x86/include/asm/kaslr_modules.h

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 1a0be02..32e1ac2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2137,6 +2137,9 @@ config RANDOMIZE_BASE
 
 	  If unsure, say Y.
 
+config RANDOMIZE_FINE_MODULE
+	def_bool y if RANDOMIZE_BASE && X86_64 && !CONFIG_UML
+
 # Relocation on x86 needs some additional build support
 config X86_NEED_RELOCS
 	def_bool y
diff --git a/arch/x86/include/asm/kaslr_modules.h b/arch/x86/include/asm/kaslr_modules.h
new file mode 100644
index 0000000..1da6ece
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
index 04edd2d..5e26369 100644
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
index f58336a..0614ab9 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -36,6 +36,7 @@
 #include <asm/pgtable.h>
 #include <asm/setup.h>
 #include <asm/unwind.h>
+#include <asm/kaslr_modules.h>
 
 #if 0
 #define DEBUGP(fmt, ...)				\
@@ -48,34 +49,124 @@ do {							\
 } while (0)
 #endif
 
-#ifdef CONFIG_RANDOMIZE_BASE
 static unsigned long module_load_offset;
+static const unsigned long NR_NO_PURGE = 5000;
+static const unsigned long NR_TRY_PURGE = 5000;
 
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
+static void *try_module_alloc(unsigned long addr, unsigned long size,
+					int try_purge)
+{
+	const unsigned long vm_flags = 0;
+
+	return __vmalloc_node_try_addr(addr, size, GFP_KERNEL, PAGE_KERNEL_EXEC,
+					vm_flags, NUMA_NO_NODE, try_purge,
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
+ * Try to allocate in the random area. First 5000 times without purging, then
+ * 5000 times with purging. If these fail, return NULL.
+ */
+static void *try_module_randomize_each(unsigned long size)
+{
+	void *p = NULL;
+	unsigned int i;
+	unsigned long last_lazy_free_blocked = 0;
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
+	for (i = 0; i < NR_NO_PURGE; i++) {
+		unsigned long addr = get_rand_module_addr(va_size);
+
+		/* First try to avoid having to purge */
+		p = try_module_alloc(addr, size, 0);
+
+		/*
+		 * Save the last value that was blocked by a
+		 * lazy purge area.
+		 */
+		if (IS_ERR(p) && PTR_ERR(p) == -EUCLEAN)
+			last_lazy_free_blocked = addr;
+		else if (!IS_ERR(p))
+			return p;
+	}
+
+	/* Try the most recent spot that could be used after a lazy purge */
+	if (last_lazy_free_blocked) {
+		p = try_module_alloc(last_lazy_free_blocked, size, 1);
+
+		if (!IS_ERR(p))
+			return p;
+	}
+
+	/* Look for more spots and allow lazy purges */
+	for (i = 0; i < NR_TRY_PURGE; i++) {
+		unsigned long addr = get_rand_module_addr(va_size);
+
+		/* Give up and allow for purges */
+		p = try_module_alloc(addr, size, 1);
+
+		if (!IS_ERR(p))
+			return p;
+	}
+	return NULL;
 }
-#endif
 
 void *module_alloc(unsigned long size)
 {
@@ -84,16 +175,18 @@ void *module_alloc(unsigned long size)
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
2.7.4
