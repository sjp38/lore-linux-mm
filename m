Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B93B46B0007
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a13-v6so4641145pfo.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:00 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 88-v6si53306702pla.315.2018.06.07.07.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:39:59 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 4/5] x86/fpu/xstate: Add XSAVES system states for shadow stack
Date: Thu,  7 Jun 2018 07:35:43 -0700
Message-Id: <20180607143544.3477-5-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143544.3477-1-yu-cheng.yu@intel.com>
References: <20180607143544.3477-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Intel Control-flow Enforcement Technology (CET) introduces the
following MSRs into the XSAVES system states.

    IA32_U_CET (user-mode CET settings),
    IA32_PL3_SSP (user-mode shadow stack),
    IA32_PL0_SSP (kernel-mode shadow stack),
    IA32_PL1_SSP (ring-1 shadow stack),
    IA32_PL2_SSP (ring-2 shadow stack).

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/types.h            | 22 ++++++++++++++++++++++
 arch/x86/include/asm/fpu/xstate.h           |  4 +++-
 arch/x86/include/uapi/asm/processor-flags.h |  2 ++
 arch/x86/kernel/fpu/xstate.c                | 10 ++++++++++
 4 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/fpu/types.h b/arch/x86/include/asm/fpu/types.h
index 202c53918ecf..e55d51d172f1 100644
--- a/arch/x86/include/asm/fpu/types.h
+++ b/arch/x86/include/asm/fpu/types.h
@@ -114,6 +114,9 @@ enum xfeature {
 	XFEATURE_Hi16_ZMM,
 	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 	XFEATURE_PKRU,
+	XFEATURE_RESERVED,
+	XFEATURE_SHSTK_USER,
+	XFEATURE_SHSTK_KERNEL,
 
 	XFEATURE_MAX,
 };
@@ -128,6 +131,8 @@ enum xfeature {
 #define XFEATURE_MASK_Hi16_ZMM		(1 << XFEATURE_Hi16_ZMM)
 #define XFEATURE_MASK_PT		(1 << XFEATURE_PT_UNIMPLEMENTED_SO_FAR)
 #define XFEATURE_MASK_PKRU		(1 << XFEATURE_PKRU)
+#define XFEATURE_MASK_SHSTK_USER	(1 << XFEATURE_SHSTK_USER)
+#define XFEATURE_MASK_SHSTK_KERNEL	(1 << XFEATURE_SHSTK_KERNEL)
 
 #define XFEATURE_MASK_FPSSE		(XFEATURE_MASK_FP | XFEATURE_MASK_SSE)
 #define XFEATURE_MASK_AVX512		(XFEATURE_MASK_OPMASK \
@@ -229,6 +234,23 @@ struct pkru_state {
 	u32				pad;
 } __packed;
 
+/*
+ * State component 11 is Control flow Enforcement user states
+ */
+struct cet_user_state {
+	u64 u_cet;	/* user control flow settings */
+	u64 user_ssp;	/* user shadow stack pointer */
+} __packed;
+
+/*
+ * State component 12 is Control flow Enforcement kernel states
+ */
+struct cet_kernel_state {
+	u64 kernel_ssp;	/* kernel shadow stack */
+	u64 pl1_ssp;	/* ring-1 shadow stack */
+	u64 pl2_ssp;	/* ring-2 shadow stack */
+} __packed;
+
 struct xstate_header {
 	u64				xfeatures;
 	u64				xcomp_bv;
diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
index a32dc5f8c963..662562cbafe9 100644
--- a/arch/x86/include/asm/fpu/xstate.h
+++ b/arch/x86/include/asm/fpu/xstate.h
@@ -31,7 +31,9 @@
 				  XFEATURE_MASK_Hi16_ZMM | \
 				  XFEATURE_MASK_PKRU | \
 				  XFEATURE_MASK_BNDREGS | \
-				  XFEATURE_MASK_BNDCSR)
+				  XFEATURE_MASK_BNDCSR | \
+				  XFEATURE_MASK_SHSTK_USER | \
+				  XFEATURE_MASK_SHSTK_KERNEL)
 
 #ifdef CONFIG_X86_64
 #define REX_PREFIX	"0x48, "
diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index bcba3c643e63..25311ec4b731 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -130,6 +130,8 @@
 #define X86_CR4_SMAP		_BITUL(X86_CR4_SMAP_BIT)
 #define X86_CR4_PKE_BIT		22 /* enable Protection Keys support */
 #define X86_CR4_PKE		_BITUL(X86_CR4_PKE_BIT)
+#define X86_CR4_CET_BIT		23 /* enable Control flow Enforcement */
+#define X86_CR4_CET		_BITUL(X86_CR4_CET_BIT)
 
 /*
  * x86-64 Task Priority Register, CR8
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index dd2c561c4544..91c0f665567b 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -35,6 +35,9 @@ static const char *xfeature_names[] =
 	"Processor Trace (unused)"	,
 	"Protection Keys User registers",
 	"unknown xstate feature"	,
+	"Control flow User registers"	,
+	"Control flow Kernel registers"	,
+	"unknown xstate feature"	,
 };
 
 static short xsave_cpuid_features[] __initdata = {
@@ -48,6 +51,9 @@ static short xsave_cpuid_features[] __initdata = {
 	X86_FEATURE_AVX512F,
 	X86_FEATURE_INTEL_PT,
 	X86_FEATURE_PKU,
+	0,		   /* Unused */
+	X86_FEATURE_SHSTK, /* XFEATURE_SHSTK_USER */
+	X86_FEATURE_SHSTK, /* XFEATURE_SHSTK_KERNEL */
 };
 
 /*
@@ -316,6 +322,8 @@ static void __init print_xstate_features(void)
 	print_xstate_feature(XFEATURE_MASK_ZMM_Hi256);
 	print_xstate_feature(XFEATURE_MASK_Hi16_ZMM);
 	print_xstate_feature(XFEATURE_MASK_PKRU);
+	print_xstate_feature(XFEATURE_MASK_SHSTK_USER);
+	print_xstate_feature(XFEATURE_MASK_SHSTK_KERNEL);
 }
 
 /*
@@ -562,6 +570,8 @@ static void check_xstate_against_struct(int nr)
 	XCHECK_SZ(sz, nr, XFEATURE_ZMM_Hi256, struct avx_512_zmm_uppers_state);
 	XCHECK_SZ(sz, nr, XFEATURE_Hi16_ZMM,  struct avx_512_hi16_state);
 	XCHECK_SZ(sz, nr, XFEATURE_PKRU,      struct pkru_state);
+	XCHECK_SZ(sz, nr, XFEATURE_SHSTK_USER,   struct cet_user_state);
+	XCHECK_SZ(sz, nr, XFEATURE_SHSTK_KERNEL, struct cet_kernel_state);
 
 	/*
 	 * Make *SURE* to add any feature numbers in below if
-- 
2.15.1
