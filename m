Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id D9A746B000E
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 19:01:58 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id do7so5840174pab.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 16:01:58 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rr5si11046016pab.188.2016.01.06.16.01.17
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 16:01:17 -0800 (PST)
Subject: [PATCH 06/31] x86, pkeys: add PKRU xsave fields and data structure(s)
From: Dave Hansen <dave@sr71.net>
Date: Wed, 06 Jan 2016 16:01:13 -0800
References: <20160107000104.1A105322@viggo.jf.intel.com>
In-Reply-To: <20160107000104.1A105322@viggo.jf.intel.com>
Message-Id: <20160107000113.48B6AE5D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The protection keys register (PKRU) is saved and restored using
xsave.  Define the data structure that we will use to access it
inside the xsave buffer.

Note that we also have to widen the printk of the xsave feature
masks since this is feature 0x200 and we only did two characters
before.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---

 b/arch/x86/include/asm/fpu/types.h  |   11 +++++++++++
 b/arch/x86/include/asm/fpu/xstate.h |    4 +++-
 b/arch/x86/kernel/fpu/xstate.c      |    7 ++++++-
 3 files changed, 20 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pkeys-03-xsave arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pkeys-03-xsave	2016-01-06 15:50:05.206137774 -0800
+++ b/arch/x86/include/asm/fpu/types.h	2016-01-06 15:50:05.212138044 -0800
@@ -109,6 +109,7 @@ enum xfeature {
 	XFEATURE_ZMM_Hi256,
 	XFEATURE_Hi16_ZMM,
 	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
+	XFEATURE_PKRU,
 
 	XFEATURE_MAX,
 };
@@ -121,6 +122,7 @@ enum xfeature {
 #define XFEATURE_MASK_OPMASK		(1 << XFEATURE_OPMASK)
 #define XFEATURE_MASK_ZMM_Hi256		(1 << XFEATURE_ZMM_Hi256)
 #define XFEATURE_MASK_Hi16_ZMM		(1 << XFEATURE_Hi16_ZMM)
+#define XFEATURE_MASK_PKRU		(1 << XFEATURE_PKRU)
 
 #define XFEATURE_MASK_FPSSE		(XFEATURE_MASK_FP | XFEATURE_MASK_SSE)
 #define XFEATURE_MASK_AVX512		(XFEATURE_MASK_OPMASK \
@@ -213,6 +215,15 @@ struct avx_512_hi16_state {
 	struct reg_512_bit		hi16_zmm[16];
 } __packed;
 
+/*
+ * State component 9: 32-bit PKRU register.  The state is
+ * 8 bytes long but only 4 bytes is used currently.
+ */
+struct pkru_state {
+	u32				pkru;
+	u32				pad;
+} __packed;
+
 struct xstate_header {
 	u64				xfeatures;
 	u64				xcomp_bv;
diff -puN arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave arch/x86/include/asm/fpu/xstate.h
--- a/arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave	2016-01-06 15:50:05.208137864 -0800
+++ b/arch/x86/include/asm/fpu/xstate.h	2016-01-06 15:50:05.213138090 -0800
@@ -27,7 +27,9 @@
 				 XFEATURE_MASK_Hi16_ZMM)
 
 /* Supported features which require eager state saving */
-#define XFEATURE_MASK_EAGER	(XFEATURE_MASK_BNDREGS | XFEATURE_MASK_BNDCSR)
+#define XFEATURE_MASK_EAGER	(XFEATURE_MASK_BNDREGS | \
+				 XFEATURE_MASK_BNDCSR | \
+				 XFEATURE_MASK_PKRU)
 
 /* All currently supported features */
 #define XCNTXT_MASK	(XFEATURE_MASK_LAZY | XFEATURE_MASK_EAGER)
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2016-01-06 15:50:05.209137909 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-01-06 15:50:05.213138090 -0800
@@ -29,6 +29,8 @@ static const char *xfeature_names[] =
 	"AVX-512 Hi256"			,
 	"AVX-512 ZMM_Hi256"		,
 	"Processor Trace (unused)"	,
+	"Protection Keys User registers",
+	"unknown xstate feature"	,
 };
 
 /*
@@ -57,6 +59,7 @@ void fpu__xstate_clear_all_cpu_caps(void
 	setup_clear_cpu_cap(X86_FEATURE_AVX512ER);
 	setup_clear_cpu_cap(X86_FEATURE_AVX512CD);
 	setup_clear_cpu_cap(X86_FEATURE_MPX);
+	setup_clear_cpu_cap(X86_FEATURE_PKU);
 }
 
 /*
@@ -235,7 +238,7 @@ static void __init print_xstate_feature(
 	const char *feature_name;
 
 	if (cpu_has_xfeatures(xstate_mask, &feature_name))
-		pr_info("x86/fpu: Supporting XSAVE feature 0x%02Lx: '%s'\n", xstate_mask, feature_name);
+		pr_info("x86/fpu: Supporting XSAVE feature 0x%03Lx: '%s'\n", xstate_mask, feature_name);
 }
 
 /*
@@ -251,6 +254,7 @@ static void __init print_xstate_features
 	print_xstate_feature(XFEATURE_MASK_OPMASK);
 	print_xstate_feature(XFEATURE_MASK_ZMM_Hi256);
 	print_xstate_feature(XFEATURE_MASK_Hi16_ZMM);
+	print_xstate_feature(XFEATURE_MASK_PKRU);
 }
 
 /*
@@ -467,6 +471,7 @@ static void check_xstate_against_struct(
 	XCHECK_SZ(sz, nr, XFEATURE_OPMASK,    struct avx_512_opmask_state);
 	XCHECK_SZ(sz, nr, XFEATURE_ZMM_Hi256, struct avx_512_zmm_uppers_state);
 	XCHECK_SZ(sz, nr, XFEATURE_Hi16_ZMM,  struct avx_512_hi16_state);
+	XCHECK_SZ(sz, nr, XFEATURE_PKRU,      struct pkru_state);
 
 	/*
 	 * Make *SURE* to add any feature numbers in below if
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
