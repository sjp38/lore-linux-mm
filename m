Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6228E000E
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:08:51 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g12-v6so6322881plo.1
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:08:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z1-v6si5733063pfc.97.2018.09.21.08.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:08:48 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 02/27] x86/fpu/xstate: Change some names to separate XSAVES system and user states
Date: Fri, 21 Sep 2018 08:03:26 -0700
Message-Id: <20180921150351.20898-3-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

To support XSAVES system states, change some names to distinguish
user and system states.

Change:
  supervisor to system
  copy_init_fpstate_to_fpregs() to copy_init_user_fpstate_to_fpregs()
  xfeatures_mask to xfeatures_mask_user
  XCNTXT_MASK to SUPPORTED_XFEATURES_MASK (states supported)

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/internal.h |  5 +-
 arch/x86/include/asm/fpu/xstate.h   | 24 ++++----
 arch/x86/kernel/fpu/core.c          |  4 +-
 arch/x86/kernel/fpu/init.c          |  2 +-
 arch/x86/kernel/fpu/signal.c        |  6 +-
 arch/x86/kernel/fpu/xstate.c        | 88 +++++++++++++++--------------
 6 files changed, 66 insertions(+), 63 deletions(-)

diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index a38bf5a1e37a..f1f9bf91a0ab 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -93,7 +93,8 @@ static inline void fpstate_init_xstate(struct xregs_state *xsave)
 	 * XRSTORS requires these bits set in xcomp_bv, or it will
 	 * trigger #GP:
 	 */
-	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask;
+	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT |
+			xfeatures_mask_user;
 }
 
 static inline void fpstate_init_fxstate(struct fxregs_state *fx)
@@ -233,7 +234,7 @@ static inline void copy_fxregs_to_kernel(struct fpu *fpu)
 
 /*
  * If XSAVES is enabled, it replaces XSAVEOPT because it supports a compact
- * format and supervisor states in addition to modified optimization in
+ * format and system states in addition to modified optimization in
  * XSAVEOPT.
  *
  * Otherwise, if XSAVEOPT is enabled, XSAVEOPT replaces XSAVE because XSAVEOPT
diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
index 48581988d78c..9b382e5157ed 100644
--- a/arch/x86/include/asm/fpu/xstate.h
+++ b/arch/x86/include/asm/fpu/xstate.h
@@ -19,19 +19,19 @@
 #define XSAVE_YMM_SIZE	    256
 #define XSAVE_YMM_OFFSET    (XSAVE_HDR_SIZE + XSAVE_HDR_OFFSET)
 
-/* Supervisor features */
-#define XFEATURE_MASK_SUPERVISOR (XFEATURE_MASK_PT)
+/* System features */
+#define XFEATURE_MASK_SYSTEM (XFEATURE_MASK_PT)
 
 /* All currently supported features */
-#define XCNTXT_MASK		(XFEATURE_MASK_FP | \
-				 XFEATURE_MASK_SSE | \
-				 XFEATURE_MASK_YMM | \
-				 XFEATURE_MASK_OPMASK | \
-				 XFEATURE_MASK_ZMM_Hi256 | \
-				 XFEATURE_MASK_Hi16_ZMM	 | \
-				 XFEATURE_MASK_PKRU | \
-				 XFEATURE_MASK_BNDREGS | \
-				 XFEATURE_MASK_BNDCSR)
+#define SUPPORTED_XFEATURES_MASK (XFEATURE_MASK_FP | \
+				  XFEATURE_MASK_SSE | \
+				  XFEATURE_MASK_YMM | \
+				  XFEATURE_MASK_OPMASK | \
+				  XFEATURE_MASK_ZMM_Hi256 | \
+				  XFEATURE_MASK_Hi16_ZMM | \
+				  XFEATURE_MASK_PKRU | \
+				  XFEATURE_MASK_BNDREGS | \
+				  XFEATURE_MASK_BNDCSR)
 
 #ifdef CONFIG_X86_64
 #define REX_PREFIX	"0x48, "
@@ -39,7 +39,7 @@
 #define REX_PREFIX
 #endif
 
-extern u64 xfeatures_mask;
+extern u64 xfeatures_mask_user;
 extern u64 xstate_fx_sw_bytes[USER_XSTATE_FX_SW_WORDS];
 
 extern void __init update_regset_xstate_info(unsigned int size,
diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
index 2ea85b32421a..4bd56079048f 100644
--- a/arch/x86/kernel/fpu/core.c
+++ b/arch/x86/kernel/fpu/core.c
@@ -363,7 +363,7 @@ void fpu__drop(struct fpu *fpu)
  * Clear FPU registers by setting them up from
  * the init fpstate:
  */
-static inline void copy_init_fpstate_to_fpregs(void)
+static inline void copy_init_user_fpstate_to_fpregs(void)
 {
 	if (use_xsave())
 		copy_kernel_to_xregs(&init_fpstate.xsave, -1);
@@ -395,7 +395,7 @@ void fpu__clear(struct fpu *fpu)
 		preempt_disable();
 		fpu__initialize(fpu);
 		user_fpu_begin();
-		copy_init_fpstate_to_fpregs();
+		copy_init_user_fpstate_to_fpregs();
 		preempt_enable();
 	}
 }
diff --git a/arch/x86/kernel/fpu/init.c b/arch/x86/kernel/fpu/init.c
index 6abd83572b01..761c3a5a9e07 100644
--- a/arch/x86/kernel/fpu/init.c
+++ b/arch/x86/kernel/fpu/init.c
@@ -229,7 +229,7 @@ static void __init fpu__init_system_xstate_size_legacy(void)
  */
 u64 __init fpu__get_supported_xfeatures_mask(void)
 {
-	return XCNTXT_MASK;
+	return SUPPORTED_XFEATURES_MASK;
 }
 
 /* Legacy code to initialize eager fpu mode. */
diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 23f1691670b6..f77aa76ba675 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -249,11 +249,11 @@ static inline int copy_user_to_fpregs_zeroing(void __user *buf, u64 xbv, int fx_
 {
 	if (use_xsave()) {
 		if ((unsigned long)buf % 64 || fx_only) {
-			u64 init_bv = xfeatures_mask & ~XFEATURE_MASK_FPSSE;
+			u64 init_bv = xfeatures_mask_user & ~XFEATURE_MASK_FPSSE;
 			copy_kernel_to_xregs(&init_fpstate.xsave, init_bv);
 			return copy_user_to_fxregs(buf);
 		} else {
-			u64 init_bv = xfeatures_mask & ~xbv;
+			u64 init_bv = xfeatures_mask_user & ~xbv;
 			if (unlikely(init_bv))
 				copy_kernel_to_xregs(&init_fpstate.xsave, init_bv);
 			return copy_user_to_xregs(buf, xbv);
@@ -417,7 +417,7 @@ void fpu__init_prepare_fx_sw_frame(void)
 
 	fx_sw_reserved.magic1 = FP_XSTATE_MAGIC1;
 	fx_sw_reserved.extended_size = size;
-	fx_sw_reserved.xfeatures = xfeatures_mask;
+	fx_sw_reserved.xfeatures = xfeatures_mask_user;
 	fx_sw_reserved.xstate_size = fpu_user_xstate_size;
 
 	if (IS_ENABLED(CONFIG_IA32_EMULATION) ||
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index 87a57b7642d3..19f8df54c72a 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -53,11 +53,11 @@ static short xsave_cpuid_features[] __initdata = {
 /*
  * Mask of xstate features supported by the CPU and the kernel:
  */
-u64 xfeatures_mask __read_mostly;
+u64 xfeatures_mask_user __read_mostly;
 
 static unsigned int xstate_offsets[XFEATURE_MAX] = { [ 0 ... XFEATURE_MAX - 1] = -1};
 static unsigned int xstate_sizes[XFEATURE_MAX]   = { [ 0 ... XFEATURE_MAX - 1] = -1};
-static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask)*8];
+static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask_user)*8];
 
 /*
  * The XSAVE area of kernel can be in standard or compacted format;
@@ -82,7 +82,7 @@ void fpu__xstate_clear_all_cpu_caps(void)
  */
 int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
 {
-	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask;
+	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask_user;
 
 	if (unlikely(feature_name)) {
 		long xfeature_idx, max_idx;
@@ -113,14 +113,14 @@ int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
 }
 EXPORT_SYMBOL_GPL(cpu_has_xfeatures);
 
-static int xfeature_is_supervisor(int xfeature_nr)
+static int xfeature_is_system(int xfeature_nr)
 {
 	/*
-	 * We currently do not support supervisor states, but if
+	 * We currently do not support system states, but if
 	 * we did, we could find out like this.
 	 *
 	 * SDM says: If state component 'i' is a user state component,
-	 * ECX[0] return 0; if state component i is a supervisor
+	 * ECX[0] return 0; if state component i is a system
 	 * state component, ECX[0] returns 1.
 	 */
 	u32 eax, ebx, ecx, edx;
@@ -131,7 +131,7 @@ static int xfeature_is_supervisor(int xfeature_nr)
 
 static int xfeature_is_user(int xfeature_nr)
 {
-	return !xfeature_is_supervisor(xfeature_nr);
+	return !xfeature_is_system(xfeature_nr);
 }
 
 /*
@@ -164,7 +164,7 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
 	 * None of the feature bits are in init state. So nothing else
 	 * to do for us, as the memory layout is up to date.
 	 */
-	if ((xfeatures & xfeatures_mask) == xfeatures_mask)
+	if ((xfeatures & xfeatures_mask_user) == xfeatures_mask_user)
 		return;
 
 	/*
@@ -191,7 +191,7 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
 	 * in a special way already:
 	 */
 	feature_bit = 0x2;
-	xfeatures = (xfeatures_mask & ~xfeatures) >> 2;
+	xfeatures = (xfeatures_mask_user & ~xfeatures) >> 2;
 
 	/*
 	 * Update all the remaining memory layouts according to their
@@ -219,20 +219,20 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
  */
 void fpu__init_cpu_xstate(void)
 {
-	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask)
+	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask_user)
 		return;
 	/*
-	 * Make it clear that XSAVES supervisor states are not yet
+	 * Make it clear that XSAVES system states are not yet
 	 * implemented should anyone expect it to work by changing
 	 * bits in XFEATURE_MASK_* macros and XCR0.
 	 */
-	WARN_ONCE((xfeatures_mask & XFEATURE_MASK_SUPERVISOR),
-		"x86/fpu: XSAVES supervisor states are not yet implemented.\n");
+	WARN_ONCE((xfeatures_mask_user & XFEATURE_MASK_SYSTEM),
+		"x86/fpu: XSAVES system states are not yet implemented.\n");
 
-	xfeatures_mask &= ~XFEATURE_MASK_SUPERVISOR;
+	xfeatures_mask_user &= ~XFEATURE_MASK_SYSTEM;
 
 	cr4_set_bits(X86_CR4_OSXSAVE);
-	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask);
+	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
 }
 
 /*
@@ -242,7 +242,7 @@ void fpu__init_cpu_xstate(void)
  */
 static int xfeature_enabled(enum xfeature xfeature)
 {
-	return !!(xfeatures_mask & (1UL << xfeature));
+	return !!(xfeatures_mask_user & BIT_ULL(xfeature));
 }
 
 /*
@@ -272,7 +272,7 @@ static void __init setup_xstate_features(void)
 		cpuid_count(XSTATE_CPUID, i, &eax, &ebx, &ecx, &edx);
 
 		/*
-		 * If an xfeature is supervisor state, the offset
+		 * If an xfeature is system state, the offset
 		 * in EBX is invalid. We leave it to -1.
 		 */
 		if (xfeature_is_user(i))
@@ -348,7 +348,7 @@ static int xfeature_is_aligned(int xfeature_nr)
  */
 static void __init setup_xstate_comp(void)
 {
-	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask)*8];
+	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask_user)*8];
 	int i;
 
 	/*
@@ -421,7 +421,8 @@ static void __init setup_init_fpu_buf(void)
 	print_xstate_features();
 
 	if (boot_cpu_has(X86_FEATURE_XSAVES))
-		init_fpstate.xsave.header.xcomp_bv = (u64)1 << 63 | xfeatures_mask;
+		init_fpstate.xsave.header.xcomp_bv =
+			BIT_ULL(63) | xfeatures_mask_user;
 
 	/*
 	 * Init all the features state with header.xfeatures being 0x0
@@ -440,11 +441,11 @@ static int xfeature_uncompacted_offset(int xfeature_nr)
 	u32 eax, ebx, ecx, edx;
 
 	/*
-	 * Only XSAVES supports supervisor states and it uses compacted
-	 * format. Checking a supervisor state's uncompacted offset is
+	 * Only XSAVES supports system states and it uses compacted
+	 * format. Checking a system state's uncompacted offset is
 	 * an error.
 	 */
-	if (XFEATURE_MASK_SUPERVISOR & (1 << xfeature_nr)) {
+	if (XFEATURE_MASK_SYSTEM & (1 << xfeature_nr)) {
 		WARN_ONCE(1, "No fixed offset for xstate %d\n", xfeature_nr);
 		return -1;
 	}
@@ -465,7 +466,7 @@ static int xfeature_size(int xfeature_nr)
 
 /*
  * 'XSAVES' implies two different things:
- * 1. saving of supervisor/system state
+ * 1. saving of system state
  * 2. using the compacted format
  *
  * Use this function when dealing with the compacted format so
@@ -480,8 +481,8 @@ int using_compacted_format(void)
 /* Validate an xstate header supplied by userspace (ptrace or sigreturn) */
 int validate_xstate_header(const struct xstate_header *hdr)
 {
-	/* No unknown or supervisor features may be set */
-	if (hdr->xfeatures & (~xfeatures_mask | XFEATURE_MASK_SUPERVISOR))
+	/* No unknown or system features may be set */
+	if (hdr->xfeatures & (~xfeatures_mask_user | XFEATURE_MASK_SYSTEM))
 		return -EINVAL;
 
 	/* Userspace must use the uncompacted format */
@@ -588,11 +589,11 @@ static void do_extra_xstate_size_checks(void)
 
 		check_xstate_against_struct(i);
 		/*
-		 * Supervisor state components can be managed only by
+		 * System state components can be managed only by
 		 * XSAVES, which is compacted-format only.
 		 */
 		if (!using_compacted_format())
-			XSTATE_WARN_ON(xfeature_is_supervisor(i));
+			XSTATE_WARN_ON(xfeature_is_system(i));
 
 		/* Align from the end of the previous feature */
 		if (xfeature_is_aligned(i))
@@ -616,7 +617,7 @@ static void do_extra_xstate_size_checks(void)
 
 
 /*
- * Get total size of enabled xstates in XCR0/xfeatures_mask.
+ * Get total size of enabled xstates in XCR0/xfeatures_mask_user.
  *
  * Note the SDM's wording here.  "sub-function 0" only enumerates
  * the size of the *user* states.  If we use it to size a buffer
@@ -706,7 +707,7 @@ static int init_xstate_size(void)
  */
 static void fpu__init_disable_system_xstate(void)
 {
-	xfeatures_mask = 0;
+	xfeatures_mask_user = 0;
 	cr4_clear_bits(X86_CR4_OSXSAVE);
 	fpu__xstate_clear_all_cpu_caps();
 }
@@ -742,15 +743,15 @@ void __init fpu__init_system_xstate(void)
 	}
 
 	cpuid_count(XSTATE_CPUID, 0, &eax, &ebx, &ecx, &edx);
-	xfeatures_mask = eax + ((u64)edx << 32);
+	xfeatures_mask_user = eax + ((u64)edx << 32);
 
-	if ((xfeatures_mask & XFEATURE_MASK_FPSSE) != XFEATURE_MASK_FPSSE) {
+	if ((xfeatures_mask_user & XFEATURE_MASK_FPSSE) != XFEATURE_MASK_FPSSE) {
 		/*
 		 * This indicates that something really unexpected happened
 		 * with the enumeration.  Disable XSAVE and try to continue
 		 * booting without it.  This is too early to BUG().
 		 */
-		pr_err("x86/fpu: FP/SSE not present amongst the CPU's xstate features: 0x%llx.\n", xfeatures_mask);
+		pr_err("x86/fpu: FP/SSE not present amongst the CPU's xstate features: 0x%llx.\n", xfeatures_mask_user);
 		goto out_disable;
 	}
 
@@ -759,10 +760,10 @@ void __init fpu__init_system_xstate(void)
 	 */
 	for (i = 0; i < ARRAY_SIZE(xsave_cpuid_features); i++) {
 		if (!boot_cpu_has(xsave_cpuid_features[i]))
-			xfeatures_mask &= ~BIT(i);
+			xfeatures_mask_user &= ~BIT_ULL(i);
 	}
 
-	xfeatures_mask &= fpu__get_supported_xfeatures_mask();
+	xfeatures_mask_user &= fpu__get_supported_xfeatures_mask();
 
 	/* Enable xstate instructions to be able to continue with initialization: */
 	fpu__init_cpu_xstate();
@@ -772,9 +773,10 @@ void __init fpu__init_system_xstate(void)
 
 	/*
 	 * Update info used for ptrace frames; use standard-format size and no
-	 * supervisor xstates:
+	 * system xstates:
 	 */
-	update_regset_xstate_info(fpu_user_xstate_size,	xfeatures_mask & ~XFEATURE_MASK_SUPERVISOR);
+	update_regset_xstate_info(fpu_user_xstate_size,
+				  xfeatures_mask_user & ~XFEATURE_MASK_SYSTEM);
 
 	fpu__init_prepare_fx_sw_frame();
 	setup_init_fpu_buf();
@@ -782,7 +784,7 @@ void __init fpu__init_system_xstate(void)
 	print_xstate_offset_size();
 
 	pr_info("x86/fpu: Enabled xstate features 0x%llx, context size is %d bytes, using '%s' format.\n",
-		xfeatures_mask,
+		xfeatures_mask_user,
 		fpu_kernel_xstate_size,
 		boot_cpu_has(X86_FEATURE_XSAVES) ? "compacted" : "standard");
 	return;
@@ -801,7 +803,7 @@ void fpu__resume_cpu(void)
 	 * Restore XCR0 on xsave capable CPUs:
 	 */
 	if (boot_cpu_has(X86_FEATURE_XSAVE))
-		xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask);
+		xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
 }
 
 /*
@@ -853,7 +855,7 @@ void *get_xsave_addr(struct xregs_state *xsave, int xstate_feature)
 	 * have not enabled.  Remember that pcntxt_mask is
 	 * what we write to the XCR0 register.
 	 */
-	WARN_ONCE(!(xfeatures_mask & xstate_feature),
+	WARN_ONCE(!(xfeatures_mask_user & xstate_feature),
 		  "get of unsupported state");
 	/*
 	 * This assumes the last 'xsave*' instruction to
@@ -1003,7 +1005,7 @@ int copy_xstate_to_kernel(void *kbuf, struct xregs_state *xsave, unsigned int of
 	 */
 	memset(&header, 0, sizeof(header));
 	header.xfeatures = xsave->header.xfeatures;
-	header.xfeatures &= ~XFEATURE_MASK_SUPERVISOR;
+	header.xfeatures &= ~XFEATURE_MASK_SYSTEM;
 
 	/*
 	 * Copy xregs_state->header:
@@ -1087,7 +1089,7 @@ int copy_xstate_to_user(void __user *ubuf, struct xregs_state *xsave, unsigned i
 	 */
 	memset(&header, 0, sizeof(header));
 	header.xfeatures = xsave->header.xfeatures;
-	header.xfeatures &= ~XFEATURE_MASK_SUPERVISOR;
+	header.xfeatures &= ~XFEATURE_MASK_SYSTEM;
 
 	/*
 	 * Copy xregs_state->header:
@@ -1180,7 +1182,7 @@ int copy_kernel_to_xstate(struct xregs_state *xsave, const void *kbuf)
 	 * The state that came in from userspace was user-state only.
 	 * Mask all the user states out of 'xfeatures':
 	 */
-	xsave->header.xfeatures &= XFEATURE_MASK_SUPERVISOR;
+	xsave->header.xfeatures &= XFEATURE_MASK_SYSTEM;
 
 	/*
 	 * Add back in the features that came in from userspace:
@@ -1236,7 +1238,7 @@ int copy_user_to_xstate(struct xregs_state *xsave, const void __user *ubuf)
 	 * The state that came in from userspace was user-state only.
 	 * Mask all the user states out of 'xfeatures':
 	 */
-	xsave->header.xfeatures &= XFEATURE_MASK_SUPERVISOR;
+	xsave->header.xfeatures &= XFEATURE_MASK_SYSTEM;
 
 	/*
 	 * Add back in the features that came in from userspace:
-- 
2.17.1
