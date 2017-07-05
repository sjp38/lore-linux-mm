Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 343D96B03E1
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n42so599273qtn.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:09 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id d27si97973qtd.341.2017.07.05.14.23.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:08 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id 91so191059qkq.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:08 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 16/38] powerpc: implementation for arch_set_user_pkey_access()
Date: Wed,  5 Jul 2017 14:21:53 -0700
Message-Id: <1499289735-14220-17-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

This patch provides the detailed implementation for
a user to allocate a key and enable it in the hardware.

It provides the plumbing, but it  cannot be  used  yet
till the  system  call  is implemented. The next patch
will do so.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h |    8 ++++-
 arch/powerpc/mm/Makefile         |    1 +
 arch/powerpc/mm/pkeys.c          |   66 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 1 deletions(-)
 create mode 100644 arch/powerpc/mm/pkeys.c

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 9345767..1495342 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -2,6 +2,10 @@
 #define _ASM_PPC64_PKEYS_H
 
 #define arch_max_pkey()  32
+#define AMR_AD_BIT 0x1UL
+#define AMR_WD_BIT 0x2UL
+#define IAMR_EX_BIT 0x1UL
+#define AMR_BITS_PER_PKEY 2
 #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
 				VM_PKEY_BIT3 | VM_PKEY_BIT4)
 /*
@@ -93,10 +97,12 @@ static inline int arch_override_mprotect_pkey(struct vm_area_struct *vma,
 	return 0;
 }
 
+extern int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val);
 static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 		unsigned long init_val)
 {
-	return 0;
+	return __arch_set_user_pkey_access(tsk, pkey, init_val);
 }
 
 static inline void pkey_mm_init(struct mm_struct *mm)
diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
index 7414034..8cc2ff1 100644
--- a/arch/powerpc/mm/Makefile
+++ b/arch/powerpc/mm/Makefile
@@ -45,3 +45,4 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
 obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
 obj-$(CONFIG_PPC_PTDUMP)	+= dump_linuxpagetables.o
 obj-$(CONFIG_PPC_HTDUMP)	+= dump_hashpagetable.o
+obj-$(CONFIG_PPC64_MEMORY_PROTECTION_KEYS)	+= pkeys.o
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
new file mode 100644
index 0000000..d3ba167
--- /dev/null
+++ b/arch/powerpc/mm/pkeys.c
@@ -0,0 +1,66 @@
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
+#include <linux/pkeys.h>                /* PKEY_*                       */
+#include <uapi/asm-generic/mman-common.h>
+
+/*
+ * set the access right in AMR IAMR and UAMOR register
+ * for @pkey to that specified in @init_val.
+ */
+int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
+		unsigned long init_val)
+{
+	u64 old_amr, old_uamor, old_iamr;
+	int pkey_shift = (arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY;
+	u64 new_amr_bits = 0x0ul;
+	u64 new_iamr_bits = 0x0ul;
+	u64 new_uamor_bits = 0x3ul;
+
+	/* Set the bits we need in AMR:  */
+	if (init_val & PKEY_DISABLE_ACCESS)
+		new_amr_bits |= AMR_AD_BIT | AMR_WD_BIT;
+	if (init_val & PKEY_DISABLE_WRITE)
+		new_amr_bits |= AMR_WD_BIT;
+
+	/*
+	 * By default execute is disabled.
+	 * To enable execute, PKEY_ENABLE_EXECUTE
+	 * needs to be specified.
+	 */
+	if ((init_val & PKEY_DISABLE_EXECUTE))
+		new_iamr_bits |= IAMR_EX_BIT;
+
+	/* Shift the bits in to the correct place in AMR for pkey: */
+	new_amr_bits	<<= pkey_shift;
+	new_iamr_bits	<<= pkey_shift;
+	new_uamor_bits	<<= pkey_shift;
+
+	/* Get old AMR and mask off any old bits in place: */
+	old_amr	= read_amr();
+	old_amr	&= ~((u64)(AMR_AD_BIT|AMR_WD_BIT) << pkey_shift);
+
+	old_iamr = read_iamr();
+	old_iamr &= ~(0x3ul << pkey_shift);
+
+	old_uamor = read_uamor();
+	old_uamor &= ~(0x3ul << pkey_shift);
+
+	/* Write old part along with new part: */
+	write_amr(old_amr | new_amr_bits);
+	write_iamr(old_iamr | new_iamr_bits);
+	write_uamor(old_uamor | new_uamor_bits);
+
+	return 0;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
