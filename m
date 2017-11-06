Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32E1A6B025F
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:30 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id f199so6810361qke.20
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z64sor7284977qtc.145.2017.11.06.00.58.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:29 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 03/51] powerpc: initial pkey plumbing
Date: Mon,  6 Nov 2017 00:56:55 -0800
Message-Id: <1509958663-18737-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Basic  plumbing  to   initialize  the   pkey  system.
Nothing is enabled yet. A later patch will enable it
ones all the infrastructure is in place.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/Kconfig                   |   15 ++++++++
 arch/powerpc/include/asm/mmu_context.h |    5 +++
 arch/powerpc/include/asm/pkeys.h       |   57 ++++++++++++++++++++++++++++++++
 arch/powerpc/mm/Makefile               |    1 +
 arch/powerpc/mm/hash_utils_64.c        |    4 ++
 arch/powerpc/mm/pkeys.c                |   30 +++++++++++++++++
 6 files changed, 112 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index cb782ac..9fd389b 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -865,6 +865,21 @@ config SECCOMP
 
 	  If unsure, say Y. Only embedded should say N here.
 
+config PPC_MEM_KEYS
+	prompt "PowerPC Memory Protection Keys"
+	def_bool y
+	depends on PPC_BOOK3S_64
+	select ARCH_USES_HIGH_VMA_FLAGS
+	select ARCH_HAS_PKEYS
+	help
+	  Memory Protection Keys provides a mechanism for enforcing
+	  page-based protections, but without requiring modification of the
+	  page tables when an application changes protection domains.
+
+	  For details, see Documentation/vm/protection-keys.txt
+
+	  If unsure, say y.
+
 endmenu
 
 config ISA_DMA_API
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 492d814..2c24447 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -142,5 +142,10 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
+
+#ifndef CONFIG_PPC_MEM_KEYS
+#define pkey_initialize()
+#endif /* CONFIG_PPC_MEM_KEYS */
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
new file mode 100644
index 0000000..a54cb39
--- /dev/null
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -0,0 +1,57 @@
+/*
+ * PowerPC Memory Protection Keys management
+ * Copyright (c) 2017, IBM Corporation.
+ * Author: Ram Pai <linuxram@us.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ASM_POWERPC_KEYS_H
+#define _ASM_POWERPC_KEYS_H
+
+#include <linux/jump_label.h>
+
+DECLARE_STATIC_KEY_TRUE(pkey_disabled);
+#define ARCH_VM_PKEY_FLAGS 0
+
+static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
+{
+	return false;
+}
+
+static inline int mm_pkey_alloc(struct mm_struct *mm)
+{
+	return -1;
+}
+
+static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
+{
+	return -EINVAL;
+}
+
+/*
+ * Try to dedicate one of the protection keys to be used as an
+ * execute-only protection key.
+ */
+static inline int execute_only_pkey(struct mm_struct *mm)
+{
+	return 0;
+}
+
+static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
+					      int prot, int pkey)
+{
+	return 0;
+}
+
+static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+					    unsigned long init_val)
+{
+	return 0;
+}
+
+extern void pkey_initialize(void);
+#endif /*_ASM_POWERPC_KEYS_H */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index a0c327d..823b03d 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 578d5a3..1e74590 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -35,6 +35,7 @@
 #include <linux/memblock.h>
 #include <linux/context_tracking.h>
 #include <linux/libfdt.h>
+#include <linux/pkeys.h>
 
 #include <asm/debugfs.h>
 #include <asm/processor.h>
@@ -1050,6 +1051,9 @@ void __init hash__early_init_mmu(void)
 	pr_info("Initializing hash mmu with SLB\n");
 	/* Initialize SLB management */
 	slb_initialize();
+
+	/* initialize the key subsystem */
+	pkey_initialize();
 }
 
 #ifdef CONFIG_SMP
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
new file mode 100644
index 0000000..c97a7a0
--- /dev/null
+++ b/arch/powerpc/mm/pkeys.c
@@ -0,0 +1,30 @@
+/*
+ * PowerPC Memory Protection Keys management
+ * Copyright (c) 2017, IBM Corporation.
+ * Author: Ram Pai <linuxram@us.ibm.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/pkeys.h>
+
+DEFINE_STATIC_KEY_TRUE(pkey_disabled);
+bool pkey_execute_disable_supported;
+
+void __init pkey_initialize(void)
+{
+	/*
+	 * Disable the pkey system till everything is in place. A subsequent
+	 * patch will enable it.
+	 */
+	static_branch_enable(&pkey_disabled);
+
+	/*
+	 * Disable execute_disable support for now. A subsequent patch will
+	 * enable it.
+	 */
+	pkey_execute_disable_supported = false;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
