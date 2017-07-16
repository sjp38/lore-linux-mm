Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id AD4046B063B
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h47so57065814qta.12
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:29 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id r28si728599qta.223.2017.07.15.20.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:28 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id c18so6917449qkb.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:28 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 11/62] powerpc: initial pkey plumbing
Date: Sat, 15 Jul 2017 20:56:13 -0700
Message-Id: <1500177424-13695-12-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

basic setup to initialize the pkey system. Only 64K kernel in HPT
mode, enables the pkey system.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/Kconfig                   |   16 ++++++++++
 arch/powerpc/include/asm/mmu_context.h |    5 +++
 arch/powerpc/include/asm/pkeys.h       |   51 ++++++++++++++++++++++++++++++++
 arch/powerpc/kernel/setup_64.c         |    4 ++
 arch/powerpc/mm/Makefile               |    1 +
 arch/powerpc/mm/hash_utils_64.c        |    1 +
 arch/powerpc/mm/pkeys.c                |   18 +++++++++++
 7 files changed, 96 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index bf4391d..5c60fd6 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -855,6 +855,22 @@ config SECCOMP
 
 	  If unsure, say Y. Only embedded should say N here.
 
+config PPC64_MEMORY_PROTECTION_KEYS
+	prompt "PowerPC Memory Protection Keys"
+	def_bool y
+	# Note: only available in 64-bit mode
+	depends on PPC64 && PPC_64K_PAGES
+	select ARCH_USES_HIGH_VMA_FLAGS
+	select ARCH_HAS_PKEYS
+	---help---
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
index da7e943..4b93547 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -181,5 +181,10 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
+
+#ifndef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+#define pkey_initialize()
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
new file mode 100644
index 0000000..203d7de
--- /dev/null
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -0,0 +1,51 @@
+#ifndef _ASM_PPC64_PKEYS_H
+#define _ASM_PPC64_PKEYS_H
+
+extern bool pkey_inited;
+#define ARCH_VM_PKEY_FLAGS 0
+
+static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
+{
+	return (pkey == 0);
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
+		int prot, int pkey)
+{
+	return 0;
+}
+
+static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	return 0;
+}
+
+static inline void pkey_initialize(void)
+{
+#ifdef CONFIG_PPC_64K_PAGES
+	pkey_inited = !radix_enabled();
+#else
+	pkey_inited = false;
+#endif
+}
+#endif /*_ASM_PPC64_PKEYS_H */
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index 4640f6d..50accab 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -37,6 +37,7 @@
 #include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/nmi.h>
+#include <linux/pkeys.h>
 
 #include <asm/io.h>
 #include <asm/kdump.h>
@@ -316,6 +317,9 @@ void __init early_setup(unsigned long dt_ptr)
 	/* Initialize the hash table or TLB handling */
 	early_init_mmu();
 
+	/* initialize the key subsystem */
+	pkey_initialize();
+
 	/*
 	 * At this point, we can let interrupts switch to virtual mode
 	 * (the MMU has been setup), so adjust the MSR in the PACA to
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 7414034..8cc2ff1 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -45,3 +45,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC64_MEMORY_PROTECTION_KEYS)	+= pkeys.o
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index d863696..f88423b 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -35,6 +35,7 @@
 #include <linux/memblock.h>
 #include <linux/context_tracking.h>
 #include <linux/libfdt.h>
+#include <linux/pkeys.h>
 
 #include <asm/debugfs.h>
 #include <asm/processor.h>
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
new file mode 100644
index 0000000..c3acee1
--- /dev/null
+++ b/arch/powerpc/mm/pkeys.c
@@ -0,0 +1,18 @@
+/*
+ * PowerPC Memory Protection Keys management
+ * Copyright (c) 2015, Intel Corporation.
+ * Copyright (c) 2017, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ */
+#include <uapi/asm-generic/mman-common.h>
+#include <linux/pkeys.h>                /* PKEY_*                       */
+
+bool pkey_inited;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
