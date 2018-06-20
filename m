Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDFD6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:09:34 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so516500plf.19
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:09:34 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r10-v6si3395620pfe.121.2018.06.20.15.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 15:09:33 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 2/3] x86/modules: Increase randomization for modules
Date: Wed, 20 Jun 2018 15:09:29 -0700
Message-Id: <1529532570-21765-3-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

This changes the behavior of the KASLR logic for allocating memory for the text
sections of loadable modules. It randomizes the location of each module text
section with about 18 bits of entropy in typical use. This is enabled on X86_64
only. For 32 bit, the behavior is unchanged.

The algorithm evenly breaks the module space in two, a random area and a backup
area. For module text allocations, it first tries to allocate up to 10 randomly
located starting pages inside the random section. If this fails, it will
allocate in the backup area. The backup area base will be offset in the same
way as the current algorithm does for the base area, 1024 possible locations.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/pgtable_64_types.h |  1 +
 arch/x86/kernel/module.c                | 80 ++++++++++++++++++++++++++++++---
 2 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 054765a..a98708a 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -141,6 +141,7 @@ extern unsigned int ptrs_per_p4d;
 /* The module sections ends with the start of the fixmap */
 #define MODULES_END		_AC(0xffffffffff000000, UL)
 #define MODULES_LEN		(MODULES_END - MODULES_VADDR)
+#define MODULES_RAND_LEN	(MODULES_LEN/2)
 
 #define ESPFIX_PGD_ENTRY	_AC(-2, UL)
 #define ESPFIX_BASE_ADDR	(ESPFIX_PGD_ENTRY << P4D_SHIFT)
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index f58336a..833ea81 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -77,6 +77,71 @@ static unsigned long int get_module_load_offset(void)
 }
 #endif
 
+static unsigned long get_module_area_base(void)
+{
+	return MODULES_VADDR + get_module_load_offset();
+}
+
+#if defined(CONFIG_X86_64) && defined(CONFIG_RANDOMIZE_BASE)
+static unsigned long get_module_vmalloc_start(void)
+{
+	if (kaslr_enabled())
+		return MODULES_VADDR + MODULES_RAND_LEN
+						+ get_module_load_offset();
+	else
+		return get_module_area_base();
+}
+
+static void *try_module_alloc(unsigned long addr, unsigned long size)
+{
+	return __vmalloc_node_try_addr(addr, size, GFP_KERNEL,
+						PAGE_KERNEL_EXEC, 0,
+						NUMA_NO_NODE,
+						__builtin_return_address(0));
+}
+
+/*
+ * Try to allocate in 10 random positions starting in the random part of the
+ * module space. If these fail, return NULL.
+ */
+static void *try_module_randomize_each(unsigned long size)
+{
+	void *p = NULL;
+	unsigned int i;
+	unsigned long offset;
+	unsigned long addr;
+	unsigned long end;
+	const unsigned long nr_mod_positions = MODULES_RAND_LEN / MODULE_ALIGN;
+
+	if (!kaslr_enabled())
+		return NULL;
+
+	for (i = 0; i < 10; i++) {
+		offset = (get_random_long() % nr_mod_positions) * MODULE_ALIGN;
+		addr = (unsigned long)MODULES_VADDR + offset;
+		end = addr + size;
+
+		if (end > addr && end < MODULES_END) {
+			p = try_module_alloc(addr, size);
+
+			if (p)
+				return p;
+		}
+	}
+	return NULL;
+}
+#else
+static unsigned long get_module_vmalloc_start(void)
+{
+	return get_module_area_base();
+}
+
+static void *try_module_randomize_each(unsigned long size)
+{
+	return NULL;
+}
+#endif
+
 void *module_alloc(unsigned long size)
 {
 	void *p;
@@ -84,11 +149,16 @@ void *module_alloc(unsigned long size)
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
+						get_module_vmalloc_start(),
+						MODULES_END, GFP_KERNEL,
+						PAGE_KERNEL_EXEC, 0,
+						NUMA_NO_NODE,
+						__builtin_return_address(0));
+
 	if (p && (kasan_module_alloc(p, size) < 0)) {
 		vfree(p);
 		return NULL;
-- 
2.7.4
