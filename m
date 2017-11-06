Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29228280257
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:59:26 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id d9so6531001qtd.8
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:59:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t2sor8240870qkd.28.2017.11.06.00.59.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:59:24 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 23/51] powerpc: Enable pkey subsystem
Date: Mon,  6 Nov 2017 00:57:15 -0800
Message-Id: <1509958663-18737-24-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
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

Non PAPR platforms do not define this property   in the device tree yet.
Here, we   hardcode   CPUs   that   support  pkey by consulting
PowerISA3.0

This patch calculates the number of keys supported by the platform.
Alsi it determines the platform support for read/write/execution access
support for pkeys.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/cputable.h    |   15 +++++++++----
 arch/powerpc/include/asm/mmu_context.h |    1 +
 arch/powerpc/include/asm/pkeys.h       |   10 +++++++++
 arch/powerpc/kernel/prom.c             |   18 +++++++++++++++++
 arch/powerpc/mm/pkeys.c                |   33 +++++++++++++++++++++----------
 5 files changed, 61 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/include/asm/cputable.h b/arch/powerpc/include/asm/cputable.h
index 53b31c2..b288735 100644
--- a/arch/powerpc/include/asm/cputable.h
+++ b/arch/powerpc/include/asm/cputable.h
@@ -215,7 +215,9 @@ enum {
 #define CPU_FTR_DAWR			LONG_ASM_CONST(0x0400000000000000)
 #define CPU_FTR_DABRX			LONG_ASM_CONST(0x0800000000000000)
 #define CPU_FTR_PMAO_BUG		LONG_ASM_CONST(0x1000000000000000)
+#define CPU_FTR_PKEY			LONG_ASM_CONST(0x2000000000000000)
 #define CPU_FTR_POWER9_DD1		LONG_ASM_CONST(0x4000000000000000)
+#define CPU_FTR_PKEY_EXECUTE		LONG_ASM_CONST(0x8000000000000000)
 
 #ifndef __ASSEMBLY__
 
@@ -436,7 +438,8 @@ enum {
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | \
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
 	    CPU_FTR_COHERENT_ICACHE | CPU_FTR_PURR | \
-	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_DABRX)
+	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_DABRX | \
+	    CPU_FTR_PKEY)
 #define CPU_FTRS_POWER6 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | \
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -444,7 +447,7 @@ enum {
 	    CPU_FTR_PURR | CPU_FTR_SPURR | CPU_FTR_REAL_LE | \
 	    CPU_FTR_DSCR | CPU_FTR_UNALIGNED_LD_STD | \
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_CFAR | \
-	    CPU_FTR_DABRX)
+	    CPU_FTR_DABRX | CPU_FTR_PKEY)
 #define CPU_FTRS_POWER7 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | CPU_FTR_ARCH_206 |\
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -453,7 +456,7 @@ enum {
 	    CPU_FTR_DSCR | CPU_FTR_SAO  | CPU_FTR_ASYM_SMT | \
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_ICSWX | CPU_FTR_CFAR | CPU_FTR_HVMODE | \
-	    CPU_FTR_VMX_COPY | CPU_FTR_HAS_PPR | CPU_FTR_DABRX)
+	    CPU_FTR_VMX_COPY | CPU_FTR_HAS_PPR | CPU_FTR_DABRX | CPU_FTR_PKEY)
 #define CPU_FTRS_POWER8 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
 	    CPU_FTR_PPCAS_ARCH_V2 | CPU_FTR_CTRL | CPU_FTR_ARCH_206 |\
 	    CPU_FTR_MMCRA | CPU_FTR_SMT | \
@@ -463,7 +466,8 @@ enum {
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_ICSWX | CPU_FTR_CFAR | CPU_FTR_HVMODE | CPU_FTR_VMX_COPY | \
 	    CPU_FTR_DBELL | CPU_FTR_HAS_PPR | CPU_FTR_DAWR | \
-	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP)
+	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_PKEY |\
+	    CPU_FTR_PKEY_EXECUTE)
 #define CPU_FTRS_POWER8E (CPU_FTRS_POWER8 | CPU_FTR_PMAO_BUG)
 #define CPU_FTRS_POWER8_DD1 (CPU_FTRS_POWER8 & ~CPU_FTR_DBELL)
 #define CPU_FTRS_POWER9 (CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
@@ -475,7 +479,8 @@ enum {
 	    CPU_FTR_STCX_CHECKS_ADDRESS | CPU_FTR_POPCNTB | CPU_FTR_POPCNTD | \
 	    CPU_FTR_CFAR | CPU_FTR_HVMODE | CPU_FTR_VMX_COPY | \
 	    CPU_FTR_DBELL | CPU_FTR_HAS_PPR | CPU_FTR_DAWR | \
-	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_ARCH_300)
+	    CPU_FTR_ARCH_207S | CPU_FTR_TM_COMP | CPU_FTR_ARCH_300 | \
+	    CPU_FTR_PKEY | CPU_FTR_PKEY_EXECUTE)
 #define CPU_FTRS_POWER9_DD1 ((CPU_FTRS_POWER9 | CPU_FTR_POWER9_DD1) & \
 			     (~CPU_FTR_SAO))
 #define CPU_FTRS_CELL	(CPU_FTR_USE_TB | CPU_FTR_LWSYNC | \
diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
index 95a3288..5a15d37 100644
--- a/arch/powerpc/include/asm/mmu_context.h
+++ b/arch/powerpc/include/asm/mmu_context.h
@@ -152,6 +152,7 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 #define thread_pkey_regs_save(thread)
 #define thread_pkey_regs_restore(new_thread, old_thread)
 #define thread_pkey_regs_init(thread)
+#define pkey_mmu_values(total_data, total_execute)
 
 static inline int vma_pkey(struct vm_area_struct *vma)
 {
diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 9ee4731..333fb28 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -13,6 +13,7 @@
 #define _ASM_POWERPC_KEYS_H
 
 #include <linux/jump_label.h>
+#include <asm/firmware.h>
 
 DECLARE_STATIC_KEY_TRUE(pkey_disabled);
 extern int pkeys_total; /* total pkeys as per device tree */
@@ -227,6 +228,15 @@ static inline void pkey_mm_init(struct mm_struct *mm)
 	mm->context.execute_only_pkey = -1;
 }
 
+static inline void pkey_mmu_values(int total_data, int total_execute)
+{
+	/*
+	 * Since any pkey can be used for data or execute, we will just treat
+	 * all keys as equal and track them as one entity.
+	 */
+	pkeys_total = total_data;
+}
+
 extern void thread_pkey_regs_save(struct thread_struct *thread);
 extern void thread_pkey_regs_restore(struct thread_struct *new_thread,
 				     struct thread_struct *old_thread);
diff --git a/arch/powerpc/kernel/prom.c b/arch/powerpc/kernel/prom.c
index f830562..8b75e9b 100644
--- a/arch/powerpc/kernel/prom.c
+++ b/arch/powerpc/kernel/prom.c
@@ -35,6 +35,7 @@
 #include <linux/of_fdt.h>
 #include <linux/libfdt.h>
 #include <linux/cpu.h>
+#include <linux/pkeys.h>
 
 #include <asm/prom.h>
 #include <asm/rtas.h>
@@ -228,6 +229,22 @@ static void __init check_cpu_pa_features(unsigned long node)
 		      ibm_pa_features, ARRAY_SIZE(ibm_pa_features));
 }
 
+static void __init check_cpu_pkey_feature(unsigned long node)
+{
+	const __be32 *ftrs;
+	int len, total_data, total_execute;
+
+	ftrs = of_get_flat_dt_prop(node, "ibm,processor-storage-keys", &len);
+	if (ftrs == NULL)
+		return;
+
+	len /= sizeof(int);
+	total_execute = (len >= 2) ? be32_to_cpu(ftrs[1]) : 0;
+	total_data = (len >= 1) ? be32_to_cpu(ftrs[0]) : 0;
+	pkey_mmu_values(total_data, total_execute);
+}
+
+
 #ifdef CONFIG_PPC_STD_MMU_64
 static void __init init_mmu_slb_size(unsigned long node)
 {
@@ -391,6 +408,7 @@ static int __init early_init_dt_scan_cpus(unsigned long node,
 
 		check_cpu_feature_properties(node);
 		check_cpu_pa_features(node);
+		check_cpu_pkey_feature(node);
 	}
 
 	identical_pvr_fixup(node);
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 3b221bd..5047371 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -26,6 +26,14 @@
 #define PKEY_REG_BITS (sizeof(u64)*8)
 #define pkeyshift(pkey) (PKEY_REG_BITS - ((pkey+1) * AMR_BITS_PER_PKEY))
 
+static inline bool pkey_mmu_enabled(void)
+{
+	if (firmware_has_feature(FW_FEATURE_LPAR))
+		return pkeys_total;
+	else
+		return cpu_has_feature(CPU_FTR_PKEY);
+}
+
 void __init pkey_initialize(void)
 {
 	int os_reserved, i;
@@ -46,14 +54,9 @@ void __init pkey_initialize(void)
 		     __builtin_popcountl(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT)
 				!= (sizeof(u64) * BITS_PER_BYTE));
 
-	/*
-	 * Disable the pkey system till everything is in place. A subsequent
-	 * patch will enable it.
-	 */
-	static_branch_enable(&pkey_disabled);
-
-	/* Lets assume 32 keys */
-	pkeys_total = 32;
+	/* Let's assume 32 keys if we are not told the number of pkeys. */
+	if (!pkeys_total)
+		pkeys_total = 32;
 
 	/*
 	 * Adjust the upper limit, based on the number of bits supported by
@@ -62,11 +65,19 @@ void __init pkey_initialize(void)
 	pkeys_total = min_t(int, pkeys_total,
 			(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT));
 
+	if (!pkey_mmu_enabled() || radix_enabled() || !pkeys_total)
+		static_branch_enable(&pkey_disabled);
+	else
+		static_branch_disable(&pkey_disabled);
+
+	if (static_branch_likely(&pkey_disabled))
+		return;
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
