Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 60B1E6B0256
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 13:49:14 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so215092668pad.3
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 10:49:14 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tc9si42275497pbc.232.2015.09.16.10.49.06
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 10:49:06 -0700 (PDT)
Subject: [PATCH 05/26] x86, pkey: add PKRU xsave fields and data structure(s)
From: Dave Hansen <dave@sr71.net>
Date: Wed, 16 Sep 2015 10:49:05 -0700
References: <20150916174903.E112E464@viggo.jf.intel.com>
In-Reply-To: <20150916174903.E112E464@viggo.jf.intel.com>
Message-Id: <20150916174905.0ECA529B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


The protection keys register (PKRU) is saved and restored using
xsave.  Define the data structure that we will use to access it
inside the xsave buffer.

Note that we also have to widen the printk of the xsave feature
masks since this is feature 0x200 and we only did two characters
before.

---

 b/arch/x86/include/asm/fpu/types.h  |   16 ++++++++++++++++
 b/arch/x86/include/asm/fpu/xstate.h |    4 +++-
 b/arch/x86/kernel/fpu/xstate.c      |    7 ++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pkeys-03-xsave arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pkeys-03-xsave	2015-09-16 10:48:13.337059990 -0700
+++ b/arch/x86/include/asm/fpu/types.h	2015-09-16 10:48:13.344060307 -0700
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
@@ -213,6 +215,20 @@ struct avx_512_hi16_state {
 	struct reg_512_bit		hi16_zmm[16];
 } __packed;
 
+/*
+ * State component 9: 32-bit PKRU register.
+ */
+struct pkru {
+	u32 pkru;
+} __packed;
+
+struct pkru_state {
+	union {
+		struct pkru		pkru;
+		u8			pad_to_8_bytes[8];
+	};
+} __packed;
+
 struct xstate_header {
 	u64				xfeatures;
 	u64				xcomp_bv;
diff -puN arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave arch/x86/include/asm/fpu/xstate.h
--- a/arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave	2015-09-16 10:48:13.339060081 -0700
+++ b/arch/x86/include/asm/fpu/xstate.h	2015-09-16 10:48:13.344060307 -0700
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
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2015-09-16 10:48:13.340060126 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2015-09-16 10:48:13.344060307 -0700
@@ -23,6 +23,8 @@ static const char *xfeature_names[] =
 	"AVX-512 opmask"		,
 	"AVX-512 Hi256"			,
 	"AVX-512 ZMM_Hi256"		,
+	"unknown xstate feature (8)"	,
+	"Protection Keys User registers",
 	"unknown xstate feature"	,
 };
 
@@ -52,6 +54,7 @@ void fpu__xstate_clear_all_cpu_caps(void
 	setup_clear_cpu_cap(X86_FEATURE_AVX512ER);
 	setup_clear_cpu_cap(X86_FEATURE_AVX512CD);
 	setup_clear_cpu_cap(X86_FEATURE_MPX);
+	setup_clear_cpu_cap(X86_FEATURE_PKU);
 }
 
 /*
@@ -230,7 +233,7 @@ static void __init print_xstate_feature(
 	const char *feature_name;
 
 	if (cpu_has_xfeatures(xstate_mask, &feature_name))
-		pr_info("x86/fpu: Supporting XSAVE feature 0x%02Lx: '%s'\n", xstate_mask, feature_name);
+		pr_info("x86/fpu: Supporting XSAVE feature 0x%03Lx: '%s'\n", xstate_mask, feature_name);
 }
 
 /*
@@ -246,6 +249,7 @@ static void __init print_xstate_features
 	print_xstate_feature(XFEATURE_MASK_OPMASK);
 	print_xstate_feature(XFEATURE_MASK_ZMM_Hi256);
 	print_xstate_feature(XFEATURE_MASK_Hi16_ZMM);
+	print_xstate_feature(XFEATURE_MASK_PKRU);
 }
 
 /*
@@ -462,6 +466,7 @@ static void check_xstate_against_struct(
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
