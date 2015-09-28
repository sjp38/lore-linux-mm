Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id C32E86B0259
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:18:23 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so182214318pac.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:18:23 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id wf3si30681170pab.166.2015.09.28.12.18.20
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:18:20 -0700 (PDT)
Subject: [PATCH 05/25] x86, pkey: add PKRU xsave fields and data structure(s)
From: Dave Hansen <dave@sr71.net>
Date: Mon, 28 Sep 2015 12:18:19 -0700
References: <20150928191817.035A64E2@viggo.jf.intel.com>
In-Reply-To: <20150928191817.035A64E2@viggo.jf.intel.com>
Message-Id: <20150928191819.925D0BD3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@sr71.net
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The protection keys register (PKRU) is saved and restored using
xsave.  Define the data structure that we will use to access it
inside the xsave buffer.

Note that we also have to widen the printk of the xsave feature
masks since this is feature 0x200 and we only did two characters
before.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/fpu/types.h  |   16 ++++++++++++++++
 b/arch/x86/include/asm/fpu/xstate.h |    4 +++-
 b/arch/x86/kernel/fpu/xstate.c      |    7 ++++++-
 3 files changed, 25 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/fpu/types.h~pkeys-03-xsave arch/x86/include/asm/fpu/types.h
--- a/arch/x86/include/asm/fpu/types.h~pkeys-03-xsave	2015-09-28 11:39:43.198057761 -0700
+++ b/arch/x86/include/asm/fpu/types.h	2015-09-28 11:39:43.205058079 -0700
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
--- a/arch/x86/include/asm/fpu/xstate.h~pkeys-03-xsave	2015-09-28 11:39:43.200057851 -0700
+++ b/arch/x86/include/asm/fpu/xstate.h	2015-09-28 11:39:43.205058079 -0700
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
--- a/arch/x86/kernel/fpu/xstate.c~pkeys-03-xsave	2015-09-28 11:39:43.201057897 -0700
+++ b/arch/x86/kernel/fpu/xstate.c	2015-09-28 11:39:43.205058079 -0700
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
