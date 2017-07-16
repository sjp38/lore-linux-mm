Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96E986B063E
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:34 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h15so57261324qte.0
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:34 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id r129si11901893qkd.288.2017.07.15.20.58.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:33 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id w12so14715389qta.2
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:33 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 13/62] powerpc: track allocation status of all pkeys
Date: Sat, 15 Jul 2017 20:56:15 -0700
Message-Id: <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Total 32 keys are supported on powerpc. However pkey 0,1
and 31 are reserved. So effectively we have 29 pkeys.

This patch keeps track of reserved keys, allocated  keys
and keys that are currently free.

Also it  adds  skeletal  functions  and macros, that the
architecture-independent code expects to be available.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |    9 +++
 arch/powerpc/include/asm/mmu_context.h   |    1 +
 arch/powerpc/include/asm/pkeys.h         |   81 ++++++++++++++++++++++++++++--
 arch/powerpc/mm/mmu_context_book3s64.c   |    2 +
 4 files changed, 89 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index 77529a3..104ad72 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -108,6 +108,15 @@ struct patb_entry {
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 	struct list_head iommu_group_mem_list;
 #endif
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+	/*
+	 * Each bit represents one protection key.
+	 * bit set   -> key allocated
+	 * bit unset -> key available for allocation
+	 */
+	u32 pkey_allocation_map;
+#endif
 } mm_context_t;
 
 /*
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 4b93547..4705dab 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -184,6 +184,7 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 
 #ifndef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
 #define pkey_initialize()
+#define pkey_mm_init(mm)
 #endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
 
 #endif /* __KERNEL__ */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 203d7de..09b268e 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -2,21 +2,87 @@
 #define _ASM_PPC64_PKEYS_H
 
 extern bool pkey_inited;
-#define ARCH_VM_PKEY_FLAGS 0
+#define arch_max_pkey()  32
+#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
+				VM_PKEY_BIT3 | VM_PKEY_BIT4)
+/*
+ * Bits are in BE format.
+ * NOTE: key 31, 1, 0 are not used.
+ * key 0 is used by default. It give read/write/execute permission.
+ * key 31 is reserved by the hypervisor.
+ * key 1 is recommended to be not used.
+ * PowerISA(3.0) page 1015, programming note.
+ */
+#define PKEY_INITIAL_ALLOCAION  0xc0000001
+
+#define pkeybit_mask(pkey) (0x1 << (arch_max_pkey() - pkey - 1))
+
+#define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
+
+#define mm_set_pkey_allocated(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) |= pkeybit_mask(pkey); \
+}
+
+#define mm_set_pkey_free(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) &= ~pkeybit_mask(pkey);	\
+}
+
+#define mm_set_pkey_is_allocated(mm, pkey)	\
+	(mm_pkey_allocation_map(mm) & pkeybit_mask(pkey))
+
+#define mm_set_pkey_is_reserved(mm, pkey) (PKEY_INITIAL_ALLOCAION & \
+					pkeybit_mask(pkey))
 
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
-	return (pkey == 0);
+	/* a reserved key is never considered as 'explicitly allocated' */
+	return ((pkey < arch_max_pkey()) &&
+		!mm_set_pkey_is_reserved(mm, pkey) &&
+		mm_set_pkey_is_allocated(mm, pkey));
 }
 
+/*
+ * Returns a positive, 5-bit key on success, or -1 on failure.
+ */
 static inline int mm_pkey_alloc(struct mm_struct *mm)
 {
-	return -1;
+	/*
+	 * Note: this is the one and only place we make sure
+	 * that the pkey is valid as far as the hardware is
+	 * concerned.  The rest of the kernel trusts that
+	 * only good, valid pkeys come out of here.
+	 */
+	u32 all_pkeys_mask = (u32)(~(0x0));
+	int ret;
+
+	if (!pkey_inited)
+		return -1;
+	/*
+	 * Are we out of pkeys?  We must handle this specially
+	 * because ffz() behavior is undefined if there are no
+	 * zeros.
+	 */
+	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
+		return -1;
+
+	ret = arch_max_pkey() -
+		ffz((u32)mm_pkey_allocation_map(mm))
+		- 1;
+	mm_set_pkey_allocated(mm, ret);
+	return ret;
 }
 
 static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
 {
-	return -EINVAL;
+	if (!pkey_inited)
+		return -1;
+
+	if (!mm_pkey_is_allocated(mm, pkey))
+		return -EINVAL;
+
+	mm_set_pkey_free(mm, pkey);
+
+	return 0;
 }
 
 /*
@@ -40,6 +106,13 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	return 0;
 }
 
+static inline void pkey_mm_init(struct mm_struct *mm)
+{
+	if (!pkey_inited)
+		return;
+	mm_pkey_allocation_map(mm) = PKEY_INITIAL_ALLOCAION;
+}
+
 static inline void pkey_initialize(void)
 {
 #ifdef CONFIG_PPC_64K_PAGES
diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index a3edf81..34a16f3 100644
--- a/arch/powerpc/mm/mmu_context_book3s64.c
+++ b/arch/powerpc/mm/mmu_context_book3s64.c
@@ -16,6 +16,7 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/pkeys.h>
 #include <linux/spinlock.h>
 #include <linux/idr.h>
 #include <linux/export.h>
@@ -120,6 +121,7 @@ static int hash__init_new_context(struct mm_struct *mm)
 
 	subpage_prot_init_new_context(mm);
 
+	pkey_mm_init(mm);
 	return index;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
