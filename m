Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7816B0012
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 09:14:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e126so7981546pfh.4
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 06:14:23 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTP id f3si8038929pgu.783.2018.03.18.06.14.21
        for <linux-mm@kvack.org>;
        Sun, 18 Mar 2018 06:14:21 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 2/7] Add TTBR operator for kasan_init
Date: Sun, 18 Mar 2018 20:53:37 +0800
Message-ID: <20180318125342.4278-3-liuwenliang@huawei.com>
In-Reply-To: <20180318125342.4278-1-liuwenliang@huawei.com>
References: <20180318125342.4278-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, marc.zyngier@arm.com, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, f.fainelli@gmail.com, liuwenliang@huawei.com, akpm@linux-foundation.org, afzal.mohd.ma@gmail.com, alexander.levin@verizon.com
Cc: glider@google.com, dvyukov@google.com, christoffer.dall@linaro.org, linux@rasmusvillemoes.dk, mawilcox@microsoft.com, pombredanne@nexb.com, ard.biesheuvel@linaro.org, vladimir.murzin@arm.com, nicolas.pitre@linaro.org, tglx@linutronix.de, thgarnie@google.com, dhowells@redhat.com, keescook@chromium.org, arnd@arndb.de, geert@linux-m68k.org, tixy@linaro.org, mark.rutland@arm.com, james.morse@arm.com, zhichao.huang@linaro.org, jinb.park7@gmail.com, labbott@redhat.com, philip@cog.systems, grygorii.strashko@linaro.org, catalin.marinas@arm.com, opendmb@gmail.com, kirill.shutemov@linux.intel.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, linux-mm@kvack.org

The purpose of this patch is to provide set_ttbr0/get_ttbr0
to kasan_init function. The definitions of cp15 registers
should be in arch/arm/include/asm/cp15.h rather than
arch/arm/include/asm/kvm_hyp.h, so move them.

Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Reviewed-by: Marc Zyngier <marc.zyngier@arm.com>
Reviewed-by: Russell King - ARM Linux <linux@armlinux.org.uk>
Reviewed-by: Christoffer Dall <cdall@linaro.org>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
---
 arch/arm/include/asm/cp15.h    | 104 +++++++++++++++++++++++++++++++++++++++++
 arch/arm/include/asm/kvm_hyp.h |  52 ---------------------
 arch/arm/kvm/hyp/cp15-sr.c     |  12 ++---
 arch/arm/kvm/hyp/switch.c      |   6 +--
 4 files changed, 113 insertions(+), 61 deletions(-)

diff --git a/arch/arm/include/asm/cp15.h b/arch/arm/include/asm/cp15.h
index 4c9fa72..99ebb31 100644
--- a/arch/arm/include/asm/cp15.h
+++ b/arch/arm/include/asm/cp15.h
@@ -3,6 +3,7 @@
 #define __ASM_ARM_CP15_H
 
 #include <asm/barrier.h>
+#include <linux/stringify.h>
 
 /*
  * CR1 bits (CP#15 CR1)
@@ -65,8 +66,111 @@
 #define __write_sysreg(v, r, w, c, t)	asm volatile(w " " c : : "r" ((t)(v)))
 #define write_sysreg(v, ...)		__write_sysreg(v, __VA_ARGS__)
 
+#define TTBR0_32	__ACCESS_CP15(c2, 0, c0, 0)
+#define TTBR1_32	__ACCESS_CP15(c2, 0, c0, 1)
+#define PAR_32		__ACCESS_CP15(c7, 0, c4, 0)
+#define TTBR0_64	__ACCESS_CP15_64(0, c2)
+#define TTBR1_64	__ACCESS_CP15_64(1, c2)
+#define PAR_64		__ACCESS_CP15_64(0, c7)
+#define VTTBR		__ACCESS_CP15_64(6, c2)
+#define CNTV_CVAL	__ACCESS_CP15_64(3, c14)
+#define CNTVOFF		__ACCESS_CP15_64(4, c14)
+
+#define MIDR		__ACCESS_CP15(c0, 0, c0, 0)
+#define CSSELR		__ACCESS_CP15(c0, 2, c0, 0)
+#define VPIDR		__ACCESS_CP15(c0, 4, c0, 0)
+#define VMPIDR		__ACCESS_CP15(c0, 4, c0, 5)
+#define SCTLR		__ACCESS_CP15(c1, 0, c0, 0)
+#define CPACR		__ACCESS_CP15(c1, 0, c0, 2)
+#define HCR		__ACCESS_CP15(c1, 4, c1, 0)
+#define HDCR		__ACCESS_CP15(c1, 4, c1, 1)
+#define HCPTR		__ACCESS_CP15(c1, 4, c1, 2)
+#define HSTR		__ACCESS_CP15(c1, 4, c1, 3)
+#define TTBCR		__ACCESS_CP15(c2, 0, c0, 2)
+#define HTCR		__ACCESS_CP15(c2, 4, c0, 2)
+#define VTCR		__ACCESS_CP15(c2, 4, c1, 2)
+#define DACR		__ACCESS_CP15(c3, 0, c0, 0)
+#define DFSR		__ACCESS_CP15(c5, 0, c0, 0)
+#define IFSR		__ACCESS_CP15(c5, 0, c0, 1)
+#define ADFSR		__ACCESS_CP15(c5, 0, c1, 0)
+#define AIFSR		__ACCESS_CP15(c5, 0, c1, 1)
+#define HSR		__ACCESS_CP15(c5, 4, c2, 0)
+#define DFAR		__ACCESS_CP15(c6, 0, c0, 0)
+#define IFAR		__ACCESS_CP15(c6, 0, c0, 2)
+#define HDFAR		__ACCESS_CP15(c6, 4, c0, 0)
+#define HIFAR		__ACCESS_CP15(c6, 4, c0, 2)
+#define HPFAR		__ACCESS_CP15(c6, 4, c0, 4)
+#define ICIALLUIS	__ACCESS_CP15(c7, 0, c1, 0)
+#define BPIALLIS	__ACCESS_CP15(c7, 0, c1, 6)
+#define ICIMVAU		__ACCESS_CP15(c7, 0, c5, 1)
+#define ATS1CPR		__ACCESS_CP15(c7, 0, c8, 0)
+#define TLBIALLIS	__ACCESS_CP15(c8, 0, c3, 0)
+#define TLBIALL		__ACCESS_CP15(c8, 0, c7, 0)
+#define TLBIALLNSNHIS	__ACCESS_CP15(c8, 4, c3, 4)
+#define PRRR		__ACCESS_CP15(c10, 0, c2, 0)
+#define NMRR		__ACCESS_CP15(c10, 0, c2, 1)
+#define AMAIR0		__ACCESS_CP15(c10, 0, c3, 0)
+#define AMAIR1		__ACCESS_CP15(c10, 0, c3, 1)
+#define VBAR		__ACCESS_CP15(c12, 0, c0, 0)
+#define CID		__ACCESS_CP15(c13, 0, c0, 1)
+#define TID_URW		__ACCESS_CP15(c13, 0, c0, 2)
+#define TID_URO		__ACCESS_CP15(c13, 0, c0, 3)
+#define TID_PRIV	__ACCESS_CP15(c13, 0, c0, 4)
+#define HTPIDR		__ACCESS_CP15(c13, 4, c0, 2)
+#define CNTKCTL		__ACCESS_CP15(c14, 0, c1, 0)
+#define CNTV_CTL	__ACCESS_CP15(c14, 0, c3, 1)
+#define CNTHCTL		__ACCESS_CP15(c14, 4, c1, 0)
+
 extern unsigned long cr_alignment;	/* defined in entry-armv.S */
 
+static inline void set_par(u64 val)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		write_sysreg(val, PAR_64);
+	else
+		write_sysreg(val, PAR_32);
+}
+
+static inline u64 get_par(void)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		return read_sysreg(PAR_64);
+	else
+		return read_sysreg(PAR_32);
+}
+
+static inline void set_ttbr0(u64 val)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		write_sysreg(val, TTBR0_64);
+	else
+		write_sysreg(val, TTBR0_32);
+}
+
+static inline u64 get_ttbr0(void)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		return read_sysreg(TTBR0_64);
+	else
+		return read_sysreg(TTBR0_32);
+}
+
+static inline void set_ttbr1(u64 val)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		write_sysreg(val, TTBR1_64);
+	else
+		write_sysreg(val, TTBR1_32);
+}
+
+static inline u64 get_ttbr1(void)
+{
+	if (IS_ENABLED(CONFIG_ARM_LPAE))
+		return read_sysreg(TTBR1_64);
+	else
+		return read_sysreg(TTBR1_32);
+}
+
 static inline unsigned long get_cr(void)
 {
 	unsigned long val;
diff --git a/arch/arm/include/asm/kvm_hyp.h b/arch/arm/include/asm/kvm_hyp.h
index 1ab8329..8e8592e 100644
--- a/arch/arm/include/asm/kvm_hyp.h
+++ b/arch/arm/include/asm/kvm_hyp.h
@@ -36,58 +36,6 @@
 	__val;							\
 })
 
-#define TTBR0		__ACCESS_CP15_64(0, c2)
-#define TTBR1		__ACCESS_CP15_64(1, c2)
-#define VTTBR		__ACCESS_CP15_64(6, c2)
-#define PAR		__ACCESS_CP15_64(0, c7)
-#define CNTV_CVAL	__ACCESS_CP15_64(3, c14)
-#define CNTVOFF		__ACCESS_CP15_64(4, c14)
-
-#define MIDR		__ACCESS_CP15(c0, 0, c0, 0)
-#define CSSELR		__ACCESS_CP15(c0, 2, c0, 0)
-#define VPIDR		__ACCESS_CP15(c0, 4, c0, 0)
-#define VMPIDR		__ACCESS_CP15(c0, 4, c0, 5)
-#define SCTLR		__ACCESS_CP15(c1, 0, c0, 0)
-#define CPACR		__ACCESS_CP15(c1, 0, c0, 2)
-#define HCR		__ACCESS_CP15(c1, 4, c1, 0)
-#define HDCR		__ACCESS_CP15(c1, 4, c1, 1)
-#define HCPTR		__ACCESS_CP15(c1, 4, c1, 2)
-#define HSTR		__ACCESS_CP15(c1, 4, c1, 3)
-#define TTBCR		__ACCESS_CP15(c2, 0, c0, 2)
-#define HTCR		__ACCESS_CP15(c2, 4, c0, 2)
-#define VTCR		__ACCESS_CP15(c2, 4, c1, 2)
-#define DACR		__ACCESS_CP15(c3, 0, c0, 0)
-#define DFSR		__ACCESS_CP15(c5, 0, c0, 0)
-#define IFSR		__ACCESS_CP15(c5, 0, c0, 1)
-#define ADFSR		__ACCESS_CP15(c5, 0, c1, 0)
-#define AIFSR		__ACCESS_CP15(c5, 0, c1, 1)
-#define HSR		__ACCESS_CP15(c5, 4, c2, 0)
-#define DFAR		__ACCESS_CP15(c6, 0, c0, 0)
-#define IFAR		__ACCESS_CP15(c6, 0, c0, 2)
-#define HDFAR		__ACCESS_CP15(c6, 4, c0, 0)
-#define HIFAR		__ACCESS_CP15(c6, 4, c0, 2)
-#define HPFAR		__ACCESS_CP15(c6, 4, c0, 4)
-#define ICIALLUIS	__ACCESS_CP15(c7, 0, c1, 0)
-#define BPIALLIS	__ACCESS_CP15(c7, 0, c1, 6)
-#define ICIMVAU		__ACCESS_CP15(c7, 0, c5, 1)
-#define ATS1CPR		__ACCESS_CP15(c7, 0, c8, 0)
-#define TLBIALLIS	__ACCESS_CP15(c8, 0, c3, 0)
-#define TLBIALL		__ACCESS_CP15(c8, 0, c7, 0)
-#define TLBIALLNSNHIS	__ACCESS_CP15(c8, 4, c3, 4)
-#define PRRR		__ACCESS_CP15(c10, 0, c2, 0)
-#define NMRR		__ACCESS_CP15(c10, 0, c2, 1)
-#define AMAIR0		__ACCESS_CP15(c10, 0, c3, 0)
-#define AMAIR1		__ACCESS_CP15(c10, 0, c3, 1)
-#define VBAR		__ACCESS_CP15(c12, 0, c0, 0)
-#define CID		__ACCESS_CP15(c13, 0, c0, 1)
-#define TID_URW		__ACCESS_CP15(c13, 0, c0, 2)
-#define TID_URO		__ACCESS_CP15(c13, 0, c0, 3)
-#define TID_PRIV	__ACCESS_CP15(c13, 0, c0, 4)
-#define HTPIDR		__ACCESS_CP15(c13, 4, c0, 2)
-#define CNTKCTL		__ACCESS_CP15(c14, 0, c1, 0)
-#define CNTV_CTL	__ACCESS_CP15(c14, 0, c3, 1)
-#define CNTHCTL		__ACCESS_CP15(c14, 4, c1, 0)
-
 #define VFP_FPEXC	__ACCESS_VFP(FPEXC)
 
 /* AArch64 compatibility macros, only for the timer so far */
diff --git a/arch/arm/kvm/hyp/cp15-sr.c b/arch/arm/kvm/hyp/cp15-sr.c
index c478281..d365e3c 100644
--- a/arch/arm/kvm/hyp/cp15-sr.c
+++ b/arch/arm/kvm/hyp/cp15-sr.c
@@ -31,8 +31,8 @@ void __hyp_text __sysreg_save_state(struct kvm_cpu_context *ctxt)
 	ctxt->cp15[c0_CSSELR]		= read_sysreg(CSSELR);
 	ctxt->cp15[c1_SCTLR]		= read_sysreg(SCTLR);
 	ctxt->cp15[c1_CPACR]		= read_sysreg(CPACR);
-	*cp15_64(ctxt, c2_TTBR0)	= read_sysreg(TTBR0);
-	*cp15_64(ctxt, c2_TTBR1)	= read_sysreg(TTBR1);
+	*cp15_64(ctxt, c2_TTBR0)	= read_sysreg(TTBR0_64);
+	*cp15_64(ctxt, c2_TTBR1)	= read_sysreg(TTBR1_64);
 	ctxt->cp15[c2_TTBCR]		= read_sysreg(TTBCR);
 	ctxt->cp15[c3_DACR]		= read_sysreg(DACR);
 	ctxt->cp15[c5_DFSR]		= read_sysreg(DFSR);
@@ -41,7 +41,7 @@ void __hyp_text __sysreg_save_state(struct kvm_cpu_context *ctxt)
 	ctxt->cp15[c5_AIFSR]		= read_sysreg(AIFSR);
 	ctxt->cp15[c6_DFAR]		= read_sysreg(DFAR);
 	ctxt->cp15[c6_IFAR]		= read_sysreg(IFAR);
-	*cp15_64(ctxt, c7_PAR)		= read_sysreg(PAR);
+	*cp15_64(ctxt, c7_PAR)		= read_sysreg(PAR_64);
 	ctxt->cp15[c10_PRRR]		= read_sysreg(PRRR);
 	ctxt->cp15[c10_NMRR]		= read_sysreg(NMRR);
 	ctxt->cp15[c10_AMAIR0]		= read_sysreg(AMAIR0);
@@ -60,8 +60,8 @@ void __hyp_text __sysreg_restore_state(struct kvm_cpu_context *ctxt)
 	write_sysreg(ctxt->cp15[c0_CSSELR],	CSSELR);
 	write_sysreg(ctxt->cp15[c1_SCTLR],	SCTLR);
 	write_sysreg(ctxt->cp15[c1_CPACR],	CPACR);
-	write_sysreg(*cp15_64(ctxt, c2_TTBR0),	TTBR0);
-	write_sysreg(*cp15_64(ctxt, c2_TTBR1),	TTBR1);
+	write_sysreg(*cp15_64(ctxt, c2_TTBR0),	TTBR0_64);
+	write_sysreg(*cp15_64(ctxt, c2_TTBR1),	TTBR1_64);
 	write_sysreg(ctxt->cp15[c2_TTBCR],	TTBCR);
 	write_sysreg(ctxt->cp15[c3_DACR],	DACR);
 	write_sysreg(ctxt->cp15[c5_DFSR],	DFSR);
@@ -70,7 +70,7 @@ void __hyp_text __sysreg_restore_state(struct kvm_cpu_context *ctxt)
 	write_sysreg(ctxt->cp15[c5_AIFSR],	AIFSR);
 	write_sysreg(ctxt->cp15[c6_DFAR],	DFAR);
 	write_sysreg(ctxt->cp15[c6_IFAR],	IFAR);
-	write_sysreg(*cp15_64(ctxt, c7_PAR),	PAR);
+	write_sysreg(*cp15_64(ctxt, c7_PAR),	PAR_64);
 	write_sysreg(ctxt->cp15[c10_PRRR],	PRRR);
 	write_sysreg(ctxt->cp15[c10_NMRR],	NMRR);
 	write_sysreg(ctxt->cp15[c10_AMAIR0],	AMAIR0);
diff --git a/arch/arm/kvm/hyp/switch.c b/arch/arm/kvm/hyp/switch.c
index ae45ae9..94d5bb9 100644
--- a/arch/arm/kvm/hyp/switch.c
+++ b/arch/arm/kvm/hyp/switch.c
@@ -134,12 +134,12 @@ static bool __hyp_text __populate_fault_info(struct kvm_vcpu *vcpu)
 	if (!(hsr & HSR_DABT_S1PTW) && (hsr & HSR_FSC_TYPE) == FSC_PERM) {
 		u64 par, tmp;
 
-		par = read_sysreg(PAR);
+		par = read_sysreg(PAR_64);
 		write_sysreg(far, ATS1CPR);
 		isb();
 
-		tmp = read_sysreg(PAR);
-		write_sysreg(par, PAR);
+		tmp = read_sysreg(PAR_64);
+		write_sysreg(par, PAR_64);
 
 		if (unlikely(tmp & 1))
 			return false; /* Translation failed, back to guest */
-- 
2.9.0
