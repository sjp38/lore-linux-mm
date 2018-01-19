Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 163026B0288
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:50 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id e20so345174qtg.8
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o62sor2602762qke.55.2018.01.18.17.52.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:52:48 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 23/27] powerpc: Enable pkey subsystem
Date: Thu, 18 Jan 2018 17:50:44 -0800
Message-Id: <1516326648-22775-24-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

PAPR defines 'ibm,processor-storage-keys' property. It exports two
values. The first value holds the number of data-access keys and the
second holds the number of instruction-access keys.  Due to a bug in
the  firmware, instruction-access  keys is  always  reported  as zero.
However any key can be configured to disable data-access and/or disable
execution-access. The inavailablity of the second value is not a
big handicap, though it could have been used to determine if the
platform supported disable-execution-access.

Non-PAPR platforms do not define this property in the device tree yet.
Fortunately power8 is the only released Non-PAPR platform that is
supported.  Here, we hardcode the number of supported pkey to 32, by
consulting the PowerISA3.0

This patch calculates the number of keys supported by the platform.
Also it determines the platform support for read/write/execution access
support for pkeys.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/cputable.h |   16 ++++++---
 arch/powerpc/include/asm/pkeys.h    |    3 ++
 arch/powerpc/mm/pkeys.c             |   61 +++++++++++++++++++++++++++++-----
 3 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/include/asm/cputable.h b/arch/powerpc/include/asm/cputable.h
index 0546663..5b54337 100644
--- a/arch/powerpc/include/asm/cputable.h
+++ b/arch/powerpc/include/asm/cputable.h
@@ -207,7 +207,7 @@ enum {
 #define CPU_FTR_STCX_CHECKS_ADDRESS	LONG_ASM_CONST(0x0004000000000000)
 #define CPU_FTR_POPCNTB			LONG_ASM_CONST(0x0008000000000000)
 #define CPU_FTR_POPCNTD			LONG_ASM_CONST(0x0010000000000000)
-/* Free					LONG_ASM_CONST(0x0020000000000000) */
+#define CPU_FTR_PKEY			LONG_ASM_CONST(0x0020000000000000)
 #define CPU_FTR_VMX_COPY		LONG_ASM_CONST(0x0040000000000000)
 #define CPU_FTR_TM			LONG_ASM_CONST(0x0080000000000000)
 #define CPU_FTR_CFAR			LONG_ASM_CONST(0x0100000000000000)
@@ -215,6 +215,7 @@ enum {
 #define CPU_FTR_DAWR			LONG_ASM_CONST(0x0400000000000000)
 #define CPU_FTR_DABRX			LONG_ASM_CONST(0x0800000000000000)
 #define CPU_FTR_PMAO_BUG		LONG_ASM_CONST(0x1000000000000000)
+#define CPU_FTR_PKEY_EXECUTE		LONG_ASM_CONST(0x2000000000000000)
 #define CPU_FTR_POWER9_DD1		LONG_ASM_CONST(0x4000000000000000)
 #define CPU_FTR_POWER9_DD2_1		LONG_ASM_CONST(0x8000000000000000)
 
@@ -437,7 +438,8 @@ enum {
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | \
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
 	    CPU_FTR_COHERENT_ICACHE | CPU_FTR_PURR | \
-	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_DABRX)
+	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_DABRX | \
+	    CPU_FTR_PKEY)
 #define CPU_FTRS_POWER6 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | \
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -445,7 +447,7 @@ enum {
 	    CPU_FTR_PURR | CPU_FTR_SPURR | CPU_FTR_REAL_LE | \
 	    CPU_FTR_DSCR | CPU_FTR_UNALIGNED_LD_STD | \
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_CFAR | \
-	    CPU_FTR_DABRX)
+	    CPU_FTR_DABRX | CPU_FTR_PKEY)
 #define CPU_FTRS_POWER7 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | CPU_FTR_ARCH_206 |\
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -454,7 +456,7 @@ enum {
 	    CPU_FTR_DSCR | CPU_FTR_SAO  | CPU_FTR_ASYM_SMT | \
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_CFAR | CPU_FTR_HVMODE | \
-	    CPU_FTR_VMX_COPY | CPU_FTR_HAS_PPR | CPU_FTR_DABRX)
+	    CPU_FTR_VMX_COPY | CPU_FTR_HAS_PPR | CPU_FTR_DABRX | CPU_FTR_PKEY)
 #define CPU_FTRS_POWER8 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | CPU_FTR_ARCH_206 |\
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -464,7 +466,8 @@ enum {
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_CFAR | CPU_FTR_HVMODE | CPU_FTR_VMX_COPY | \
 	    CPU_FTR_DBELL | CPU_FTR_HAS_PPR | CPU_FTR_DAWR | \
-	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP)
+	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_PKEY |\
+	    CPU_FTR_PKEY_EXECUTE)
 #define CPU_FTRS_POWER8E (CPU_FTRS_POWER8 | CPU_FTR_PMAO_BUG)
 #define CPU_FTRS_POWER8_DD1 (CPU_FTRS_POWER8 & ~CPU_FTR_DBELL)
 #define CPU_FTRS_POWER9 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
@@ -476,7 +479,8 @@ enum {
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_CFAR | CPU_FTR_HVMODE | CPU_FTR_VMX_COPY | \
 	    CPU_FTR_DBELL | CPU_FTR_HAS_PPR | CPU_FTR_DAWR | \
-	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_ARCH_300)
+	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_ARCH_300 | \
+	    CPU_FTR_PKEY | CPU_FTR_PKEY_EXECUTE)
 #define CPU_FTRS_POWER9_DD1 ((CPU_FTRS_POWER9 | CPU_FTR_POWER9_DD1) & \
 			     (~CPU_FTR_SAO))
 #define CPU_FTRS_POWER9_DD2_0 CPU_FTRS_POWER9
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 0c480b2..92b6776 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -13,6 +13,7 @@
 #define _ASM_POWERPC_KEYS_H
 
 #include <linux/jump_label.h>
+#include <asm/firmware.h>
 
 DECLARE_STATIC_KEY_TRUE(pkey_disabled);
 extern int pkeys_total; /* total pkeys as per device tree */
@@ -219,6 +220,8 @@ static inline bool arch_pkeys_enabled(void)
 }
 
 extern void pkey_mm_init(struct mm_struct *mm);
+extern bool arch_supports_pkeys(int cap);
+extern unsigned int arch_usable_pkeys(void);
 extern void thread_pkey_regs_save(struct thread_struct *thread);
 extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
 				     struct thread_struct *old_thread);
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 0701aa3..66a1091 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -10,11 +10,14 @@
  */
 
 #include <asm/mman.h>
+#include <asm/setup.h>
 #include <linux/pkeys.h>
+#include <linux/of_device.h>
 
 DEFINE_STATIC_KEY_TRUE(pkey_disabled);
 bool pkey_execute_disable_supported;
 int  pkeys_total;		/* Total pkeys as per device tree */
+bool pkeys_devtree_defined;	/* pkey property exported by device tree */
 u32  initial_allocation_mask;	/* Bits set for reserved keys */
 u64  pkey_amr_uamor_mask;	/* Bits in AMR/UMOR not to be touched */
 u64  pkey_iamr_mask;		/* Bits in AMR not to be touched */
@@ -26,6 +29,35 @@
 #define PKEY_REG_BITS (sizeof(u64)*8)
 #define pkeyshift(pkey) (PKEY_REG_BITS - ((pkey+1) * AMR_BITS_PER_PKEY))
 
+static void scan_pkey_feature(void)
+{
+	u32 vals[2];
+	struct device_node *cpu;
+
+	cpu = of_find_node_by_type(NULL, "cpu");
+	if (!cpu)
+		return;
+
+	if (of_property_read_u32_array(cpu,
+			"ibm,processor-storage-keys", vals, 2))
+		return;
+
+	/*
+	 * Since any pkey can be used for data or execute, we will just treat
+	 * all keys as equal and track them as one entity.
+	 */
+	pkeys_total = be32_to_cpu(vals[0]);
+	pkeys_devtree_defined = true;
+}
+
+static inline bool pkey_mmu_enabled(void)
+{
+	if (firmware_has_feature(FW_FEATURE_LPAR))
+		return pkeys_total;
+	else
+		return cpu_has_feature(CPU_FTR_PKEY);
+}
+
 int pkey_initialize(void)
 {
 	int os_reserved, i;
@@ -46,14 +78,17 @@ int pkey_initialize(void)
 		     __builtin_popcountl(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT)
 				!= (sizeof(u64) * BITS_PER_BYTE));
 
+	/* scan the device tree for pkey feature */
+	scan_pkey_feature();
+
 	/*
-	 * Disable the pkey system till everything is in place. A subsequent
-	 * patch will enable it.
+	 * Let's assume 32 pkeys on P8 bare metal, if its not defined by device
+	 * tree. We make this exception since skiboot forgot to expose this
+	 * property on power8.
 	 */
-	static_branch_enable(&pkey_disabled);
-
-	/* Lets assume 32 keys */
-	pkeys_total = 32;
+	if (!pkeys_devtree_defined && !firmware_has_feature(FW_FEATURE_LPAR) &&
+			cpu_has_feature(CPU_FTRS_POWER8))
+		pkeys_total = 32;
 
 	/*
 	 * Adjust the upper limit, based on the number of bits supported by
@@ -62,11 +97,19 @@ int pkey_initialize(void)
 	pkeys_total = min_t(int, pkeys_total,
 			(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT));
 
+	if (!pkey_mmu_enabled() || radix_enabled() || !pkeys_total)
+		static_branch_enable(&pkey_disabled);
+	else
+		static_branch_disable(&pkey_disabled);
+
+	if (static_branch_likely(&pkey_disabled))
+		return 0;
+
 	/*
-	 * Disable execute_disable support for now. A subsequent patch will
-	 * enable it.
+	 * The device tree cannot be relied on for execute_disable support.
+	 * Hence we depend on CPU FTR.
 	 */
-	pkey_execute_disable_supported = false;
+	pkey_execute_disable_supported = cpu_has_feature(CPU_FTR_PKEY_EXECUTE);
 
 #ifdef CONFIG_PPC_4K_PAGES
 	/*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
