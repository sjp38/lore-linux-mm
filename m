Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DEF4C828E4
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 16:02:12 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x65so53105829pfb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:02:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id d26si22162938pfb.137.2016.02.12.13.02.04
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 13:02:04 -0800 (PST)
Subject: [PATCH 08/33] x86, pkeys: add PKRU xsave fields and data structure(s)
From: Dave Hansen <dave@sr71.net>
Date: Fri, 12 Feb 2016 13:02:04 -0800
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
In-Reply-To: <20160212210152.9CAD15B0@viggo.jf.intel.com>
Message-Id: <20160212210204.56DF8F7B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


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
 b/arch/x86/include/asm/fpu/xstate.h |    3 ++-
 b/arch/x86/kernel/fpu/xstate.c      |    7 ++++++-
 3 files changed, 19 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pkeys-03-xsave arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pkeys-03-xsave	2016-02-12 10:44:17.212291439 -0800
+++ b/arch/x86/include/asm/fpu/types.h	2016-02-12 10:44:17.218291713 -0800
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
--- a/arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave	2016-02-12 10:44:17.213291484 -0800
+++ b/arch/x86/include/asm/fpu/xstate.h	2016-02-12 10:44:17.218291713 -0800
@@ -28,7 +28,8 @@
 				 XFEATURE_MASK_YMM | \
 				 XFEATURE_MASK_OPMASK | \
 				 XFEATURE_MASK_ZMM_Hi256 | \
-				 XFEATURE_MASK_Hi16_ZMM)
+				 XFEATURE_MASK_Hi16_ZMM	 | \
+				 XFEATURE_MASK_PKRU)
 
 /* All currently supported features */
 #define XCNTXT_MASK	(XFEATURE_MASK_LAZY | XFEATURE_MASK_EAGER)
diff -puN arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave arch/x86/kernel/fpu/xstate.c
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2016-02-12 10:44:17.215291576 -0800
+++ b/arch/x86/kernel/fpu/xstate.c	2016-02-12 10:44:17.219291759 -0800
@@ -29,6 +29,8 @@ static const char *xfeature_names[] =
 	"AVX-512 Hi256"			,
 	"AVX-512 ZMM_Hi256"		,
 	"Processor Trace (unused)"	,
+	"Protection Keys User registers",
+	"unknown xstate feature"	,
 };
 
 /*
@@ -58,6 +60,7 @@ void fpu__xstate_clear_all_cpu_caps(void
 	setup_clear_cpu_cap(X86_FEATURE_AVX512CD);
 	setup_clear_cpu_cap(X86_FEATURE_MPX);
 	setup_clear_cpu_cap(X86_FEATURE_XGETBV1);
+	setup_clear_cpu_cap(X86_FEATURE_PKU);
 }
 
 /*
@@ -236,7 +239,7 @@ static void __init print_xstate_feature(
 	const char *feature_name;
 
 	if (cpu_has_xfeatures(xstate_mask, &feature_name))
-		pr_info("x86/fpu: Supporting XSAVE feature 0x%02Lx: '%s'\n", xstate_mask, feature_name);
+		pr_info("x86/fpu: Supporting XSAVE feature 0x%03Lx: '%s'\n", xstate_mask, feature_name);
 }
 
 /*
@@ -252,6 +255,7 @@ static void __init print_xstate_features
 	print_xstate_feature(XFEATURE_MASK_OPMASK);
 	print_xstate_feature(XFEATURE_MASK_ZMM_Hi256);
 	print_xstate_feature(XFEATURE_MASK_Hi16_ZMM);
+	print_xstate_feature(XFEATURE_MASK_PKRU);
 }
 
 /*
@@ -468,6 +472,7 @@ static void check_xstate_against_struct(
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
