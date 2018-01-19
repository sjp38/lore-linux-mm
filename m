Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 493786B025F
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:51:52 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h32so345503qtb.9
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:51:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s53sor6339022qtj.70.2018.01.18.17.51.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:51:51 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 04/27] powerpc: track allocation status of all pkeys
Date: Thu, 18 Jan 2018 17:50:25 -0800
Message-Id: <1516326648-22775-5-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Total 32 keys are available on power7 and above. However
pkey 0,1 are reserved. So effectively we  have  30 pkeys.

On 4K kernels, we do not  have  5  bits  in  the  PTE to
represent  all the keys; we only have 3bits.Two of those
keys are reserved; pkey 0 and pkey 1. So effectively  we
have 6 pkeys.

This patch keeps track of reserved keys, allocated  keys
and keys that are currently free.

Also it  adds  skeletal  functions  and macros, that the
architecture-independent code expects to be available.

Reviewed-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/mmu.h |    9 +++
 arch/powerpc/include/asm/mmu_context.h   |    4 +
 arch/powerpc/include/asm/pkeys.h         |   90 ++++++++++++++++++++++++++++-
 arch/powerpc/mm/mmu_context_book3s64.c   |    2 +
 arch/powerpc/mm/pkeys.c                  |   40 +++++++++++++
 5 files changed, 141 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/mmu.h b/arch/powerpc/include/asm/book3s/64/mmu.h
index c9448e1..37ef23c 100644
--- a/arch/powerpc/include/asm/book3s/64/mmu.h
+++ b/arch/powerpc/include/asm/book3s/64/mmu.h
@@ -108,6 +108,15 @@ struct patb_entry {
 #ifdef CONFIG_SPAPR_TCE_IOMMU
 	struct list_head iommu_group_mem_list;
 #endif
+
+#ifdef CONFIG_PPC_MEM_KEYS
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
index fb5e6a3..7d0f2d0 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -193,5 +193,9 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 	return true;
 }
 
+#ifndef CONFIG_PPC_MEM_KEYS
+#define pkey_mm_init(mm)
+#endif /* CONFIG_PPC_MEM_KEYS */
+
 #endif /* __KERNEL__ */
 #endif /* __ASM_POWERPC_MMU_CONTEXT_H */
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 1280b35..1e8cef2 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -15,21 +15,101 @@
 #include <linux/jump_label.h>
 
 DECLARE_STATIC_KEY_TRUE(pkey_disabled);
-#define ARCH_VM_PKEY_FLAGS 0
+extern int pkeys_total; /* total pkeys as per device tree */
+extern u32 initial_allocation_mask; /* bits set for reserved keys */
+
+/*
+ * powerpc needs VM_PKEY_BIT* bit to enable pkey system.
+ * Without them, at least compilation needs to succeed.
+ */
+#ifndef VM_PKEY_BIT0
+#define VM_PKEY_SHIFT 0
+#define VM_PKEY_BIT0 0
+#define VM_PKEY_BIT1 0
+#define VM_PKEY_BIT2 0
+#define VM_PKEY_BIT3 0
+#endif
+
+/*
+ * powerpc needs an additional vma bit to support 32 keys. Till the additional
+ * vma bit lands in include/linux/mm.h we can only support 16 keys.
+ */
+#ifndef VM_PKEY_BIT4
+#define VM_PKEY_BIT4 0
+#endif
+
+#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
+			    VM_PKEY_BIT3 | VM_PKEY_BIT4)
+
+#define arch_max_pkey() pkeys_total
+
+#define pkey_alloc_mask(pkey) (0x1 << pkey)
+
+#define mm_pkey_allocation_map(mm) (mm->context.pkey_allocation_map)
+
+#define __mm_pkey_allocated(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) |= pkey_alloc_mask(pkey); \
+}
+
+#define __mm_pkey_free(mm, pkey) {	\
+	mm_pkey_allocation_map(mm) &= ~pkey_alloc_mask(pkey);	\
+}
+
+#define __mm_pkey_is_allocated(mm, pkey)	\
+	(mm_pkey_allocation_map(mm) & pkey_alloc_mask(pkey))
+
+#define __mm_pkey_is_reserved(pkey) (initial_allocation_mask & \
+				       pkey_alloc_mask(pkey))
 
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
-	return false;
+	/* A reserved key is never considered as 'explicitly allocated' */
+	return ((pkey < arch_max_pkey()) &&
+		!__mm_pkey_is_reserved(pkey) &&
+		__mm_pkey_is_allocated(mm, pkey));
 }
 
+/*
+ * Returns a positive, 5-bit key on success, or -1 on failure.
+ * Relies on the mmap_sem to protect against concurrency in mm_pkey_alloc() and
+ * mm_pkey_free().
+ */
 static inline int mm_pkey_alloc(struct mm_struct *mm)
 {
-	return -1;
+	/*
+	 * Note: this is the one and only place we make sure that the pkey is
+	 * valid as far as the hardware is concerned. The rest of the kernel
+	 * trusts that only good, valid pkeys come out of here.
+	 */
+	u32 all_pkeys_mask = (u32)(~(0x0));
+	int ret;
+
+	if (static_branch_likely(&pkey_disabled))
+		return -1;
+
+	/*
+	 * Are we out of pkeys? We must handle this specially because ffz()
+	 * behavior is undefined if there are no zeros.
+	 */
+	if (mm_pkey_allocation_map(mm) == all_pkeys_mask)
+		return -1;
+
+	ret = ffz((u32)mm_pkey_allocation_map(mm));
+	__mm_pkey_allocated(mm, ret);
+	return ret;
 }
 
 static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
 {
-	return -EINVAL;
+	if (static_branch_likely(&pkey_disabled))
+		return -1;
+
+	if (!mm_pkey_is_allocated(mm, pkey))
+		return -EINVAL;
+
+	__mm_pkey_free(mm, pkey);
+
+	return 0;
 }
 
 /*
@@ -52,4 +132,6 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 {
 	return 0;
 }
+
+extern void pkey_mm_init(struct mm_struct *mm);
 #endif /*_ASM_POWERPC_KEYS_H */
diff --git a/arch/powerpc/mm/mmu_context_book3s64.c b/arch/powerpc/mm/mmu_context_book3s64.c
index 59c0766..929d9ef 100644
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
@@ -118,6 +119,7 @@ static int hash__init_new_context(struct mm_struct *mm)
 
 	subpage_prot_init_new_context(mm);
 
+	pkey_mm_init(mm);
 	return index;
 }
 
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index de7dc48..e2f3992 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -13,21 +13,61 @@
 
 DEFINE_STATIC_KEY_TRUE(pkey_disabled);
 bool pkey_execute_disable_supported;
+int  pkeys_total;		/* Total pkeys as per device tree */
+u32  initial_allocation_mask;	/* Bits set for reserved keys */
 
 int pkey_initialize(void)
 {
+	int os_reserved, i;
+
 	/*
 	 * Disable the pkey system till everything is in place. A subsequent
 	 * patch will enable it.
 	 */
 	static_branch_enable(&pkey_disabled);
 
+	/* Lets assume 32 keys */
+	pkeys_total = 32;
+
+	/*
+	 * Adjust the upper limit, based on the number of bits supported by
+	 * arch-neutral code.
+	 */
+	pkeys_total = min_t(int, pkeys_total,
+			(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT));
+
 	/*
 	 * Disable execute_disable support for now. A subsequent patch will
 	 * enable it.
 	 */
 	pkey_execute_disable_supported = false;
+
+#ifdef CONFIG_PPC_4K_PAGES
+	/*
+	 * The OS can manage only 8 pkeys due to its inability to represent them
+	 * in the Linux 4K PTE.
+	 */
+	os_reserved = pkeys_total - 8;
+#else
+	os_reserved = 0;
+#endif
+	/*
+	 * Bits are in LE format. NOTE: 1, 0 are reserved.
+	 * key 0 is the default key, which allows read/write/execute.
+	 * key 1 is recommended not to be used. PowerISA(3.0) page 1015,
+	 * programming note.
+	 */
+	initial_allocation_mask = ~0x0;
+	for (i = 2; i < (pkeys_total - os_reserved); i++)
+		initial_allocation_mask &= ~(0x1 << i);
 	return 0;
 }
 
 arch_initcall(pkey_initialize);
+
+void pkey_mm_init(struct mm_struct *mm)
+{
+	if (static_branch_likely(&pkey_disabled))
+		return;
+	mm_pkey_allocation_map(mm) = initial_allocation_mask;
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
