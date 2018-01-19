Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE156B025E
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:51:49 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id u10so354915qtg.5
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:51:49 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor5554079qkh.80.2018.01.18.17.51.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:51:48 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 03/27] powerpc: initial pkey plumbing
Date: Thu, 18 Jan 2018 17:50:24 -0800
Message-Id: <1516326648-22775-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Basic  plumbing  to   initialize  the   pkey  system.
Nothing is enabled yet. A later patch will enable it
once all the infrastructure is in place.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/Kconfig                   |   15 +++++++++
 arch/powerpc/include/asm/mmu_context.h |    1 +
 arch/powerpc/include/asm/pkeys.h       |   55 ++++++++++++++++++++++++++++++++
 arch/powerpc/mm/Makefile               |    1 +
 arch/powerpc/mm/hash_utils_64.c        |    1 +
 arch/powerpc/mm/pkeys.c                |   33 +++++++++++++++++++
 6 files changed, 106 insertions(+), 0 deletions(-)
 create mode 100644 arch/powerpc/include/asm/pkeys.h
 create mode 100644 arch/powerpc/mm/pkeys.c

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index c51e6ce..c9660a1 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -867,6 +867,21 @@ config SECCOMP
 
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
index 6177d43..fb5e6a3 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -192,5 +192,6 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	/* by default, allow everything */
 	return true;
 }
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
new file mode 100644
index 0000000..1280b35
--- /dev/null
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -0,0 +1,55 @@
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
+#endif /*_ASM_POWERPC_KEYS_H */
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 76a6b05..181166d 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 0c802de..8bd841a 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -36,6 +36,7 @@
 #include <linux/memblock.h>
 #include <linux/context_tracking.h>
 #include <linux/libfdt.h>
+#include <linux/pkeys.h>
 
 #include <asm/debugfs.h>
 #include <asm/processor.h>
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
new file mode 100644
index 0000000..de7dc48
--- /dev/null
+++ b/arch/powerpc/mm/pkeys.c
@@ -0,0 +1,33 @@
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
+int pkey_initialize(void)
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
+	return 0;
+}
+
+arch_initcall(pkey_initialize);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
