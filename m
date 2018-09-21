Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F23E8E000B
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:08:51 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so6656700pff.12
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:08:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z1-v6si5733063pfc.97.2018.09.21.08.08.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:08:49 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 03/27] x86/fpu/xstate: Enable XSAVES system states
Date: Fri, 21 Sep 2018 08:03:27 -0700
Message-Id: <20180921150351.20898-4-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

XSAVES saves both system and user states.  The Linux kernel
currently does not save/restore any system states.  This patch
creates the framework for supporting system states.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/internal.h |   3 +-
 arch/x86/include/asm/fpu/xstate.h   |   9 ++-
 arch/x86/kernel/fpu/core.c          |   7 +-
 arch/x86/kernel/fpu/init.c          |  10 ---
 arch/x86/kernel/fpu/xstate.c        | 112 +++++++++++++++++-----------
 5 files changed, 80 insertions(+), 61 deletions(-)

diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index f1f9bf91a0ab..1f447865db3a 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -45,7 +45,6 @@ extern void fpu__init_cpu_xstate(void);
 extern void fpu__init_system(struct cpuinfo_x86 *c);
 extern void fpu__init_check_bugs(void);
 extern void fpu__resume_cpu(void);
-extern u64 fpu__get_supported_xfeatures_mask(void);
 
 /*
  * Debugging facility:
@@ -94,7 +93,7 @@ static inline void fpstate_init_xstate(struct xregs_state *xsave)
 	 * trigger #GP:
 	 */
 	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT |
-			xfeatures_mask_user;
+			xfeatures_mask_all;
 }
 
 static inline void fpstate_init_fxstate(struct fxregs_state *fx)
diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
index 9b382e5157ed..a32dc5f8c963 100644
--- a/arch/x86/include/asm/fpu/xstate.h
+++ b/arch/x86/include/asm/fpu/xstate.h
@@ -19,10 +19,10 @@
 #define XSAVE_YMM_SIZE	    256
 #define XSAVE_YMM_OFFSET    (XSAVE_HDR_SIZE + XSAVE_HDR_OFFSET)
 
-/* System features */
-#define XFEATURE_MASK_SYSTEM (XFEATURE_MASK_PT)
-
-/* All currently supported features */
+/*
+ * SUPPORTED_XFEATURES_MASK indicates all features
+ * implemented in and supported by the kernel.
+ */
 #define SUPPORTED_XFEATURES_MASK (XFEATURE_MASK_FP | \
 				  XFEATURE_MASK_SSE | \
 				  XFEATURE_MASK_YMM | \
@@ -40,6 +40,7 @@
 #endif
 
 extern u64 xfeatures_mask_user;
+extern u64 xfeatures_mask_all;
 extern u64 xstate_fx_sw_bytes[USER_XSTATE_FX_SW_WORDS];
 
 extern void __init update_regset_xstate_info(unsigned int size,
diff --git a/arch/x86/kernel/fpu/core.c b/arch/x86/kernel/fpu/core.c
index 4bd56079048f..9f51b0e1da25 100644
--- a/arch/x86/kernel/fpu/core.c
+++ b/arch/x86/kernel/fpu/core.c
@@ -365,8 +365,13 @@ void fpu__drop(struct fpu *fpu)
  */
 static inline void copy_init_user_fpstate_to_fpregs(void)
 {
+	/*
+	 * Only XSAVES user states are copied.
+	 * System states are preserved.
+	 */
 	if (use_xsave())
-		copy_kernel_to_xregs(&init_fpstate.xsave, -1);
+		copy_kernel_to_xregs(&init_fpstate.xsave,
+				     xfeatures_mask_user);
 	else if (static_cpu_has(X86_FEATURE_FXSR))
 		copy_kernel_to_fxregs(&init_fpstate.fxsave);
 	else
diff --git a/arch/x86/kernel/fpu/init.c b/arch/x86/kernel/fpu/init.c
index 761c3a5a9e07..eaf9d9d479a5 100644
--- a/arch/x86/kernel/fpu/init.c
+++ b/arch/x86/kernel/fpu/init.c
@@ -222,16 +222,6 @@ static void __init fpu__init_system_xstate_size_legacy(void)
 	fpu_user_xstate_size = fpu_kernel_xstate_size;
 }
 
-/*
- * Find supported xfeatures based on cpu features and command-line input.
- * This must be called after fpu__init_parse_early_param() is called and
- * xfeatures_mask is enumerated.
- */
-u64 __init fpu__get_supported_xfeatures_mask(void)
-{
-	return SUPPORTED_XFEATURES_MASK;
-}
-
 /* Legacy code to initialize eager fpu mode. */
 static void __init fpu__init_system_ctx_switch(void)
 {
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index 19f8df54c72a..dd2c561c4544 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -51,13 +51,16 @@ static short xsave_cpuid_features[] __initdata = {
 };
 
 /*
- * Mask of xstate features supported by the CPU and the kernel:
+ * Mask of xstate features supported by the CPU and the kernel.
+ * This is the result from CPUID query, SUPPORTED_XFEATURES_MASK,
+ * and boot_cpu_has().
  */
 u64 xfeatures_mask_user __read_mostly;
+u64 xfeatures_mask_all __read_mostly;
 
 static unsigned int xstate_offsets[XFEATURE_MAX] = { [ 0 ... XFEATURE_MAX - 1] = -1};
 static unsigned int xstate_sizes[XFEATURE_MAX]   = { [ 0 ... XFEATURE_MAX - 1] = -1};
-static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask_user)*8];
+static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask_all)*8];
 
 /*
  * The XSAVE area of kernel can be in standard or compacted format;
@@ -82,7 +85,7 @@ void fpu__xstate_clear_all_cpu_caps(void)
  */
 int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
 {
-	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask_user;
+	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask_all;
 
 	if (unlikely(feature_name)) {
 		long xfeature_idx, max_idx;
@@ -164,7 +167,7 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
 	 * None of the feature bits are in init state. So nothing else
 	 * to do for us, as the memory layout is up to date.
 	 */
-	if ((xfeatures & xfeatures_mask_user) == xfeatures_mask_user)
+	if ((xfeatures & xfeatures_mask_all) == xfeatures_mask_all)
 		return;
 
 	/*
@@ -219,30 +222,31 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
  */
 void fpu__init_cpu_xstate(void)
 {
-	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask_user)
+	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask_all)
 		return;
+
+	cr4_set_bits(X86_CR4_OSXSAVE);
+
 	/*
-	 * Make it clear that XSAVES system states are not yet
-	 * implemented should anyone expect it to work by changing
-	 * bits in XFEATURE_MASK_* macros and XCR0.
+	 * XCR_XFEATURE_ENABLED_MASK sets the features that are managed
+	 * by XSAVE{C, OPT} and XRSTOR.  Only XSAVE user states can be
+	 * set here.
 	 */
-	WARN_ONCE((xfeatures_mask_user & XFEATURE_MASK_SYSTEM),
-		"x86/fpu: XSAVES system states are not yet implemented.\n");
+	xsetbv(XCR_XFEATURE_ENABLED_MASK,
+	       xfeatures_mask_user);
 
-	xfeatures_mask_user &= ~XFEATURE_MASK_SYSTEM;
-
-	cr4_set_bits(X86_CR4_OSXSAVE);
-	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
+	/*
+	 * MSR_IA32_XSS sets which XSAVES system states to be managed by
+	 * XSAVES.  Only XSAVES system states can be set here.
+	 */
+	if (boot_cpu_has(X86_FEATURE_XSAVES))
+		wrmsrl(MSR_IA32_XSS,
+		       xfeatures_mask_all & ~xfeatures_mask_user);
 }
 
-/*
- * Note that in the future we will likely need a pair of
- * functions here: one for user xstates and the other for
- * system xstates.  For now, they are the same.
- */
 static int xfeature_enabled(enum xfeature xfeature)
 {
-	return !!(xfeatures_mask_user & BIT_ULL(xfeature));
+	return !!(xfeatures_mask_all & BIT_ULL(xfeature));
 }
 
 /*
@@ -348,7 +352,7 @@ static int xfeature_is_aligned(int xfeature_nr)
  */
 static void __init setup_xstate_comp(void)
 {
-	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask_user)*8];
+	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask_all)*8];
 	int i;
 
 	/*
@@ -422,7 +426,7 @@ static void __init setup_init_fpu_buf(void)
 
 	if (boot_cpu_has(X86_FEATURE_XSAVES))
 		init_fpstate.xsave.header.xcomp_bv =
-			BIT_ULL(63) | xfeatures_mask_user;
+			BIT_ULL(63) | xfeatures_mask_all;
 
 	/*
 	 * Init all the features state with header.xfeatures being 0x0
@@ -441,11 +445,10 @@ static int xfeature_uncompacted_offset(int xfeature_nr)
 	u32 eax, ebx, ecx, edx;
 
 	/*
-	 * Only XSAVES supports system states and it uses compacted
-	 * format. Checking a system state's uncompacted offset is
-	 * an error.
+	 * Checking a system or unsupported state's uncompacted offset
+	 * is an error.
 	 */
-	if (XFEATURE_MASK_SYSTEM & (1 << xfeature_nr)) {
+	if (~xfeatures_mask_user & BIT_ULL(xfeature_nr)) {
 		WARN_ONCE(1, "No fixed offset for xstate %d\n", xfeature_nr);
 		return -1;
 	}
@@ -482,7 +485,7 @@ int using_compacted_format(void)
 int validate_xstate_header(const struct xstate_header *hdr)
 {
 	/* No unknown or system features may be set */
-	if (hdr->xfeatures & (~xfeatures_mask_user | XFEATURE_MASK_SYSTEM))
+	if (hdr->xfeatures & ~xfeatures_mask_user)
 		return -EINVAL;
 
 	/* Userspace must use the uncompacted format */
@@ -617,15 +620,12 @@ static void do_extra_xstate_size_checks(void)
 
 
 /*
- * Get total size of enabled xstates in XCR0/xfeatures_mask_user.
+ * Get total size of enabled xstates in XCR0 | IA32_XSS.
  *
  * Note the SDM's wording here.  "sub-function 0" only enumerates
  * the size of the *user* states.  If we use it to size a buffer
  * that we use 'XSAVES' on, we could potentially overflow the
  * buffer because 'XSAVES' saves system states too.
- *
- * Note that we do not currently set any bits on IA32_XSS so
- * 'XCR0 | IA32_XSS == XCR0' for now.
  */
 static unsigned int __init get_xsaves_size(void)
 {
@@ -707,6 +707,7 @@ static int init_xstate_size(void)
  */
 static void fpu__init_disable_system_xstate(void)
 {
+	xfeatures_mask_all = 0;
 	xfeatures_mask_user = 0;
 	cr4_clear_bits(X86_CR4_OSXSAVE);
 	fpu__xstate_clear_all_cpu_caps();
@@ -722,6 +723,8 @@ void __init fpu__init_system_xstate(void)
 	static int on_boot_cpu __initdata = 1;
 	int err;
 	int i;
+	u64 cpu_user_xfeatures_mask;
+	u64 cpu_system_xfeatures_mask;
 
 	WARN_ON_FPU(!on_boot_cpu);
 	on_boot_cpu = 0;
@@ -742,10 +745,24 @@ void __init fpu__init_system_xstate(void)
 		return;
 	}
 
+	/*
+	 * Find user states supported by the processor.
+	 * Only these bits can be set in XCR0.
+	 */
 	cpuid_count(XSTATE_CPUID, 0, &eax, &ebx, &ecx, &edx);
-	xfeatures_mask_user = eax + ((u64)edx << 32);
+	cpu_user_xfeatures_mask = eax + ((u64)edx << 32);
+
+	/*
+	 * Find system states supported by the processor.
+	 * Only these bits can be set in IA32_XSS MSR.
+	 */
+	cpuid_count(XSTATE_CPUID, 1, &eax, &ebx, &ecx, &edx);
+	cpu_system_xfeatures_mask = ecx + ((u64)edx << 32);
 
-	if ((xfeatures_mask_user & XFEATURE_MASK_FPSSE) != XFEATURE_MASK_FPSSE) {
+	xfeatures_mask_all = cpu_user_xfeatures_mask |
+			     cpu_system_xfeatures_mask;
+
+	if ((xfeatures_mask_all & XFEATURE_MASK_FPSSE) != XFEATURE_MASK_FPSSE) {
 		/*
 		 * This indicates that something really unexpected happened
 		 * with the enumeration.  Disable XSAVE and try to continue
@@ -760,10 +777,11 @@ void __init fpu__init_system_xstate(void)
 	 */
 	for (i = 0; i < ARRAY_SIZE(xsave_cpuid_features); i++) {
 		if (!boot_cpu_has(xsave_cpuid_features[i]))
-			xfeatures_mask_user &= ~BIT_ULL(i);
+			xfeatures_mask_all &= ~BIT_ULL(i);
 	}
 
-	xfeatures_mask_user &= fpu__get_supported_xfeatures_mask();
+	xfeatures_mask_all &= SUPPORTED_XFEATURES_MASK;
+	xfeatures_mask_user = xfeatures_mask_all & cpu_user_xfeatures_mask;
 
 	/* Enable xstate instructions to be able to continue with initialization: */
 	fpu__init_cpu_xstate();
@@ -775,8 +793,7 @@ void __init fpu__init_system_xstate(void)
 	 * Update info used for ptrace frames; use standard-format size and no
 	 * system xstates:
 	 */
-	update_regset_xstate_info(fpu_user_xstate_size,
-				  xfeatures_mask_user & ~XFEATURE_MASK_SYSTEM);
+	update_regset_xstate_info(fpu_user_xstate_size, xfeatures_mask_user);
 
 	fpu__init_prepare_fx_sw_frame();
 	setup_init_fpu_buf();
@@ -784,7 +801,7 @@ void __init fpu__init_system_xstate(void)
 	print_xstate_offset_size();
 
 	pr_info("x86/fpu: Enabled xstate features 0x%llx, context size is %d bytes, using '%s' format.\n",
-		xfeatures_mask_user,
+		xfeatures_mask_all,
 		fpu_kernel_xstate_size,
 		boot_cpu_has(X86_FEATURE_XSAVES) ? "compacted" : "standard");
 	return;
@@ -804,6 +821,13 @@ void fpu__resume_cpu(void)
 	 */
 	if (boot_cpu_has(X86_FEATURE_XSAVE))
 		xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
+
+	/*
+	 * Restore IA32_XSS
+	 */
+	if (boot_cpu_has(X86_FEATURE_XSAVES))
+		wrmsrl(MSR_IA32_XSS,
+		       xfeatures_mask_all & ~xfeatures_mask_user);
 }
 
 /*
@@ -853,9 +877,9 @@ void *get_xsave_addr(struct xregs_state *xsave, int xstate_feature)
 	/*
 	 * We should not ever be requesting features that we
 	 * have not enabled.  Remember that pcntxt_mask is
-	 * what we write to the XCR0 register.
+	 * what we write to the XCR0 | IA32_XSS registers.
 	 */
-	WARN_ONCE(!(xfeatures_mask_user & xstate_feature),
+	WARN_ONCE(!(xfeatures_mask_all & xstate_feature),
 		  "get of unsupported state");
 	/*
 	 * This assumes the last 'xsave*' instruction to
@@ -1005,7 +1029,7 @@ int copy_xstate_to_kernel(void *kbuf, struct xregs_state *xsave, unsigned int of
 	 */
 	memset(&header, 0, sizeof(header));
 	header.xfeatures = xsave->header.xfeatures;
-	header.xfeatures &= ~XFEATURE_MASK_SYSTEM;
+	header.xfeatures &= xfeatures_mask_user;
 
 	/*
 	 * Copy xregs_state->header:
@@ -1089,7 +1113,7 @@ int copy_xstate_to_user(void __user *ubuf, struct xregs_state *xsave, unsigned i
 	 */
 	memset(&header, 0, sizeof(header));
 	header.xfeatures = xsave->header.xfeatures;
-	header.xfeatures &= ~XFEATURE_MASK_SYSTEM;
+	header.xfeatures &= xfeatures_mask_user;
 
 	/*
 	 * Copy xregs_state->header:
@@ -1182,7 +1206,7 @@ int copy_kernel_to_xstate(struct xregs_state *xsave, const void *kbuf)
 	 * The state that came in from userspace was user-state only.
 	 * Mask all the user states out of 'xfeatures':
 	 */
-	xsave->header.xfeatures &= XFEATURE_MASK_SYSTEM;
+	xsave->header.xfeatures &= (xfeatures_mask_all & ~xfeatures_mask_user);
 
 	/*
 	 * Add back in the features that came in from userspace:
@@ -1238,7 +1262,7 @@ int copy_user_to_xstate(struct xregs_state *xsave, const void __user *ubuf)
 	 * The state that came in from userspace was user-state only.
 	 * Mask all the user states out of 'xfeatures':
 	 */
-	xsave->header.xfeatures &= XFEATURE_MASK_SYSTEM;
+	xsave->header.xfeatures &= (xfeatures_mask_all & ~xfeatures_mask_user);
 
 	/*
 	 * Add back in the features that came in from userspace:
-- 
2.17.1
