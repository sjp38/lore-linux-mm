Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A995C28EB3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA7F320B1F
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA7F320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7E476B028D; Thu,  6 Jun 2019 16:15:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B326B6B028E; Thu,  6 Jun 2019 16:15:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936186B028F; Thu,  6 Jun 2019 16:15:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF246B028D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so2305733pgc.8
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7V3NcjUGogy0AzDV0wQpP5vgz72/I1YSjIQMdGeAqKQ=;
        b=uTSCE9wQOsZwrXpDVNiXXY8C8qjIwwHxJL7TfPpw05ZuZNbFtISvaT2HvMOUGrxu5U
         imDEdUCPr0fDB2BVlmlGW3yhX2WaP3B7xMIzy35t+G9AQaqYxu0WJJ8tuByuD0DcX62w
         pKT7aGPSq0w7m+Z2mLw8+GjXrYSlfmeCFVEDqjB2n3yLI+aXEDmla3/ZXeqqXT/IE5HN
         certDz1PEAdf36edT9N7z2rcwTFO8APWI/DL/Qam2lA58KEDx/l6cOcMn+wJSlW+OjI2
         lR9iVt+y2s8IZkKavf9BEkC7pAnNhCdSdXx/TWUxFx4ecF49AkrLst+nR1jrk7ZG6YWw
         hVVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUd7T8JshO1oA7n2tAwJFwsqfrJ+yqT3tmE4Nx1jN1gcFv3jLbQ
	upJUk59pL7zTbYo5kg719h9yuc0NgVoBfs7qgRXBPnlzG00i44J2Bg2oF1tRFg+kWC35NYXGOVJ
	0vJsbhfKZ3ndAmtaDv9K+wCwtbizgfuzQTGZflEuDrteYzoKrYYNqC+7SacJcxGSB4Q==
X-Received: by 2002:a65:5241:: with SMTP id q1mr290286pgp.298.1559852114809;
        Thu, 06 Jun 2019 13:15:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJP3l/r3Inb951ghZ5T9wSqFZPRsM5esShz4vxVWMxc45g4hznPLChnh3gQlOyK7Uo4/hG
X-Received: by 2002:a65:5241:: with SMTP id q1mr290143pgp.298.1559852112853;
        Thu, 06 Jun 2019 13:15:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852112; cv=none;
        d=google.com; s=arc-20160816;
        b=poWbDreSztod9XE1WtKUpNt73DNmNLXjkdQe66Ag6SvpSu0pqH6H1Yrq1IKc73wra/
         uo1RK+wzOTfk3riE6XM47txf0Z1M7vgWkDbdc1np1IfWOtP7dFLrYp/qKVBZl2K2cidv
         EQeZxXimrce75gX3Rg4tZbuZZkFiuAprjjxqimiSCIAqlzXHYsKLStVn47fj5ljcovz1
         YYhxQnxumRkHXFJSbcznBQoSltVMLBJUjL5rr3Vr85D/SOzJJ0UHwUZkJly9IPZfZFI+
         YTbPvwwD9J49gXY2P3/34vGmWutUa7P7izCfPzxXiF6Nci9IGdqKRcnvFwavyKYm6Xsi
         9nFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7V3NcjUGogy0AzDV0wQpP5vgz72/I1YSjIQMdGeAqKQ=;
        b=pazr32BhLd6WPAU7UoTsAxQHQ+lp8GenME2z61uq58kgMjyg1C/Kk7ZIEUjh/HWLDO
         aUcIFWSt8ECydavyXmIi3CUPC+axBGZDnavPRQ3W2agJxPWHRs8XDmjqqO6M5ZSsWFBZ
         OIKMQoNjtBnuawm46nk2kwkthodifzRSWJ8bUjbCeWhVAGzYjuCqTHMJiK3QGIsNdirq
         ld0fRvltmyKDjvlR6rj87X2wLf6By+EgQLJJyyAq4QwlJ3aN4sYFA3C6kVMRzPuJjfr+
         pteLJxZ6prlZ6PCuK9+pdtoYbdL80y8id0UEVjtgk36AZfbjcQlBIa10LWixD/E2HdYG
         XERQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:12 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:11 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 03/27] x86/fpu/xstate: Change names to separate XSAVES system and user states
Date: Thu,  6 Jun 2019 13:06:22 -0700
Message-Id: <20190606200646.3951-4-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Control-flow Enforcement (CET) MSR contents are XSAVES system states.
To support CET, introduce XSAVES system states first.

XSAVES is a "supervisor" instruction and, comparing to XSAVE, saves
additional "supervisor" states that can be modified only from CPL 0.
However, these states are per-task and not kernel's own.  Rename
"supervisor" states to "system" states to clearly separate them from
"user" states.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/internal.h |  4 +-
 arch/x86/include/asm/fpu/xstate.h   | 20 +++----
 arch/x86/kernel/fpu/init.c          |  2 +-
 arch/x86/kernel/fpu/signal.c        | 10 ++--
 arch/x86/kernel/fpu/xstate.c        | 86 ++++++++++++++---------------
 5 files changed, 60 insertions(+), 62 deletions(-)

diff --git a/arch/x86/include/asm/fpu/internal.h b/arch/x86/include/asm/fpu/internal.h
index 9e27fa05a7ae..bcaa4fc54eb5 100644
--- a/arch/x86/include/asm/fpu/internal.h
+++ b/arch/x86/include/asm/fpu/internal.h
@@ -92,7 +92,7 @@ static inline void fpstate_init_xstate(struct xregs_state *xsave)
 	 * XRSTORS requires these bits set in xcomp_bv, or it will
 	 * trigger #GP:
 	 */
-	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask;
+	xsave->header.xcomp_bv = XCOMP_BV_COMPACTED_FORMAT | xfeatures_mask_user;
 }
 
 static inline void fpstate_init_fxstate(struct fxregs_state *fx)
@@ -225,7 +225,7 @@ static inline void copy_fxregs_to_kernel(struct fpu *fpu)
 
 /*
  * If XSAVES is enabled, it replaces XSAVEOPT because it supports a compact
- * format and supervisor states in addition to modified optimization in
+ * format and system states in addition to modified optimization in
  * XSAVEOPT.
  *
  * Otherwise, if XSAVEOPT is enabled, XSAVEOPT replaces XSAVE because XSAVEOPT
diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
index 7e42b285c856..a1e33ebfb13f 100644
--- a/arch/x86/include/asm/fpu/xstate.h
+++ b/arch/x86/include/asm/fpu/xstate.h
@@ -25,15 +25,15 @@
 #define XFEATURE_MASK_SUPERVISOR (XFEATURE_MASK_PT)
 
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
@@ -41,7 +41,7 @@
 #define REX_PREFIX
 #endif
 
-extern u64 xfeatures_mask;
+extern u64 xfeatures_mask_user;
 extern u64 xstate_fx_sw_bytes[USER_XSTATE_FX_SW_WORDS];
 
 extern void __init update_regset_xstate_info(unsigned int size,
diff --git a/arch/x86/kernel/fpu/init.c b/arch/x86/kernel/fpu/init.c
index ef0030e3fe6b..3271fd8b0322 100644
--- a/arch/x86/kernel/fpu/init.c
+++ b/arch/x86/kernel/fpu/init.c
@@ -230,7 +230,7 @@ static void __init fpu__init_system_xstate_size_legacy(void)
  */
 u64 __init fpu__get_supported_xfeatures_mask(void)
 {
-	return XCNTXT_MASK;
+	return SUPPORTED_XFEATURES_MASK;
 }
 
 /* Legacy code to initialize eager fpu mode. */
diff --git a/arch/x86/kernel/fpu/signal.c b/arch/x86/kernel/fpu/signal.c
index 5a8d118bc423..2aecbeaaee25 100644
--- a/arch/x86/kernel/fpu/signal.c
+++ b/arch/x86/kernel/fpu/signal.c
@@ -256,11 +256,11 @@ static int copy_user_to_fpregs_zeroing(void __user *buf, u64 xbv, int fx_only)
 {
 	if (use_xsave()) {
 		if (fx_only) {
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
@@ -359,7 +359,7 @@ static int __fpu__restore_sig(void __user *buf, void __user *buf_fx, int size)
 
 
 	if (use_xsave() && !fx_only) {
-		u64 init_bv = xfeatures_mask & ~xfeatures;
+		u64 init_bv = xfeatures_mask_user & ~xfeatures;
 
 		if (using_compacted_format()) {
 			ret = copy_user_to_xstate(&fpu->state.xsave, buf_fx);
@@ -390,7 +390,7 @@ static int __fpu__restore_sig(void __user *buf, void __user *buf_fx, int size)
 
 		fpregs_lock();
 		if (use_xsave()) {
-			u64 init_bv = xfeatures_mask & ~XFEATURE_MASK_FPSSE;
+			u64 init_bv = xfeatures_mask_user & ~XFEATURE_MASK_FPSSE;
 			copy_kernel_to_xregs(&init_fpstate.xsave, init_bv);
 		}
 
@@ -464,7 +464,7 @@ void fpu__init_prepare_fx_sw_frame(void)
 
 	fx_sw_reserved.magic1 = FP_XSTATE_MAGIC1;
 	fx_sw_reserved.extended_size = size;
-	fx_sw_reserved.xfeatures = xfeatures_mask;
+	fx_sw_reserved.xfeatures = xfeatures_mask_user;
 	fx_sw_reserved.xstate_size = fpu_user_xstate_size;
 
 	if (IS_ENABLED(CONFIG_IA32_EMULATION) ||
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index 3c36dd1784db..d503e1fa15e8 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -52,13 +52,16 @@ static short xsave_cpuid_features[] __initdata = {
 };
 
 /*
- * Mask of xstate features supported by the CPU and the kernel:
+ * XSAVES system states can only be modified from CPL 0 and saved by
+ * XSAVES.  The rest are user states.  The following is a mask of
+ * supported user state features derived from boot_cpu_has() and
+ * SUPPORTED_XFEATURES_MASK.
  */
-u64 xfeatures_mask __read_mostly;
+u64 xfeatures_mask_user __read_mostly;
 
 static unsigned int xstate_offsets[XFEATURE_MAX] = { [ 0 ... XFEATURE_MAX - 1] = -1};
 static unsigned int xstate_sizes[XFEATURE_MAX]   = { [ 0 ... XFEATURE_MAX - 1] = -1};
-static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask)*8];
+static unsigned int xstate_comp_offsets[sizeof(xfeatures_mask_user)*8];
 
 /*
  * The XSAVE area of kernel can be in standard or compacted format;
@@ -83,7 +86,7 @@ void fpu__xstate_clear_all_cpu_caps(void)
  */
 int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
 {
-	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask;
+	u64 xfeatures_missing = xfeatures_needed & ~xfeatures_mask_user;
 
 	if (unlikely(feature_name)) {
 		long xfeature_idx, max_idx;
@@ -114,15 +117,12 @@ int cpu_has_xfeatures(u64 xfeatures_needed, const char **feature_name)
 }
 EXPORT_SYMBOL_GPL(cpu_has_xfeatures);
 
-static int xfeature_is_supervisor(int xfeature_nr)
+static int xfeature_is_system(int xfeature_nr)
 {
 	/*
-	 * We currently do not support supervisor states, but if
-	 * we did, we could find out like this.
-	 *
 	 * SDM says: If state component 'i' is a user state component,
-	 * ECX[0] return 0; if state component i is a supervisor
-	 * state component, ECX[0] returns 1.
+	 * ECX[0] is 0; if state component i is a system state component,
+	 * ECX[0] is 1.
 	 */
 	u32 eax, ebx, ecx, edx;
 
@@ -132,7 +132,7 @@ static int xfeature_is_supervisor(int xfeature_nr)
 
 static int xfeature_is_user(int xfeature_nr)
 {
-	return !xfeature_is_supervisor(xfeature_nr);
+	return !xfeature_is_system(xfeature_nr);
 }
 
 /*
@@ -165,7 +165,7 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
 	 * None of the feature bits are in init state. So nothing else
 	 * to do for us, as the memory layout is up to date.
 	 */
-	if ((xfeatures & xfeatures_mask) == xfeatures_mask)
+	if ((xfeatures & xfeatures_mask_user) == xfeatures_mask_user)
 		return;
 
 	/*
@@ -192,7 +192,7 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
 	 * in a special way already:
 	 */
 	feature_bit = 0x2;
-	xfeatures = (xfeatures_mask & ~xfeatures) >> 2;
+	xfeatures = (xfeatures_mask_user & ~xfeatures) >> 2;
 
 	/*
 	 * Update all the remaining memory layouts according to their
@@ -220,20 +220,18 @@ void fpstate_sanitize_xstate(struct fpu *fpu)
  */
 void fpu__init_cpu_xstate(void)
 {
-	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask)
+	if (!boot_cpu_has(X86_FEATURE_XSAVE) || !xfeatures_mask_user)
 		return;
 	/*
-	 * Make it clear that XSAVES supervisor states are not yet
-	 * implemented should anyone expect it to work by changing
-	 * bits in XFEATURE_MASK_* macros and XCR0.
+	 * XCR_XFEATURE_ENABLED_MASK sets the features that are managed
+	 * by XSAVE{C, OPT} and XRSTOR.  Only XSAVE user states can be
+	 * set here.
 	 */
-	WARN_ONCE((xfeatures_mask & XFEATURE_MASK_SUPERVISOR),
-		"x86/fpu: XSAVES supervisor states are not yet implemented.\n");
 
-	xfeatures_mask &= ~XFEATURE_MASK_SUPERVISOR;
+	xfeatures_mask_user &= ~XFEATURE_MASK_SUPERVISOR;
 
 	cr4_set_bits(X86_CR4_OSXSAVE);
-	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask);
+	xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
 }
 
 /*
@@ -243,7 +241,7 @@ void fpu__init_cpu_xstate(void)
  */
 static int xfeature_enabled(enum xfeature xfeature)
 {
-	return !!(xfeatures_mask & (1UL << xfeature));
+	return !!(xfeatures_mask_user & BIT_ULL(xfeature));
 }
 
 /*
@@ -273,7 +271,7 @@ static void __init setup_xstate_features(void)
 		cpuid_count(XSTATE_CPUID, i, &eax, &ebx, &ecx, &edx);
 
 		/*
-		 * If an xfeature is supervisor state, the offset
+		 * If an xfeature is a system state, the offset
 		 * in EBX is invalid. We leave it to -1.
 		 */
 		if (xfeature_is_user(i))
@@ -349,7 +347,7 @@ static int xfeature_is_aligned(int xfeature_nr)
  */
 static void __init setup_xstate_comp(void)
 {
-	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask)*8];
+	unsigned int xstate_comp_sizes[sizeof(xfeatures_mask_user)*8];
 	int i;
 
 	/*
@@ -422,7 +420,7 @@ static void __init setup_init_fpu_buf(void)
 	print_xstate_features();
 
 	if (boot_cpu_has(X86_FEATURE_XSAVES))
-		init_fpstate.xsave.header.xcomp_bv = (u64)1 << 63 | xfeatures_mask;
+		init_fpstate.xsave.header.xcomp_bv = BIT_ULL(63) | xfeatures_mask_user;
 
 	/*
 	 * Init all the features state with header.xfeatures being 0x0
@@ -441,8 +439,8 @@ static int xfeature_uncompacted_offset(int xfeature_nr)
 	u32 eax, ebx, ecx, edx;
 
 	/*
-	 * Only XSAVES supports supervisor states and it uses compacted
-	 * format. Checking a supervisor state's uncompacted offset is
+	 * Only XSAVES supports system states and it uses compacted
+	 * format. Checking a system state's uncompacted offset is
 	 * an error.
 	 */
 	if (XFEATURE_MASK_SUPERVISOR & BIT_ULL(xfeature_nr)) {
@@ -466,7 +464,7 @@ static int xfeature_size(int xfeature_nr)
 
 /*
  * 'XSAVES' implies two different things:
- * 1. saving of supervisor/system state
+ * 1. saving of system state
  * 2. using the compacted format
  *
  * Use this function when dealing with the compacted format so
@@ -481,8 +479,8 @@ int using_compacted_format(void)
 /* Validate an xstate header supplied by userspace (ptrace or sigreturn) */
 int validate_xstate_header(const struct xstate_header *hdr)
 {
-	/* No unknown or supervisor features may be set */
-	if (hdr->xfeatures & (~xfeatures_mask | XFEATURE_MASK_SUPERVISOR))
+	/* No unknown or system features may be set */
+	if (hdr->xfeatures & ~xfeatures_mask_user)
 		return -EINVAL;
 
 	/* Userspace must use the uncompacted format */
@@ -589,11 +587,11 @@ static void do_extra_xstate_size_checks(void)
 
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
@@ -617,7 +615,7 @@ static void do_extra_xstate_size_checks(void)
 
 
 /*
- * Get total size of enabled xstates in XCR0/xfeatures_mask.
+ * Get total size of enabled xstates in XCR0/xfeatures_mask_user.
  *
  * Note the SDM's wording here.  "sub-function 0" only enumerates
  * the size of the *user* states.  If we use it to size a buffer
@@ -707,7 +705,7 @@ static int __init init_xstate_size(void)
  */
 static void fpu__init_disable_system_xstate(void)
 {
-	xfeatures_mask = 0;
+	xfeatures_mask_user = 0;
 	cr4_clear_bits(X86_CR4_OSXSAVE);
 	fpu__xstate_clear_all_cpu_caps();
 }
@@ -743,15 +741,15 @@ void __init fpu__init_system_xstate(void)
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
 
@@ -760,10 +758,10 @@ void __init fpu__init_system_xstate(void)
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
@@ -773,9 +771,9 @@ void __init fpu__init_system_xstate(void)
 
 	/*
 	 * Update info used for ptrace frames; use standard-format size and no
-	 * supervisor xstates:
+	 * system xstates:
 	 */
-	update_regset_xstate_info(fpu_user_xstate_size,	xfeatures_mask & ~XFEATURE_MASK_SUPERVISOR);
+	update_regset_xstate_info(fpu_user_xstate_size, xfeatures_mask_user & ~XFEATURE_MASK_SUPERVISOR);
 
 	fpu__init_prepare_fx_sw_frame();
 	setup_init_fpu_buf();
@@ -783,7 +781,7 @@ void __init fpu__init_system_xstate(void)
 	print_xstate_offset_size();
 
 	pr_info("x86/fpu: Enabled xstate features 0x%llx, context size is %d bytes, using '%s' format.\n",
-		xfeatures_mask,
+		xfeatures_mask_user,
 		fpu_kernel_xstate_size,
 		boot_cpu_has(X86_FEATURE_XSAVES) ? "compacted" : "standard");
 	return;
@@ -802,7 +800,7 @@ void fpu__resume_cpu(void)
 	 * Restore XCR0 on xsave capable CPUs:
 	 */
 	if (boot_cpu_has(X86_FEATURE_XSAVE))
-		xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask);
+		xsetbv(XCR_XFEATURE_ENABLED_MASK, xfeatures_mask_user);
 }
 
 /*
@@ -850,7 +848,7 @@ void *get_xsave_addr(struct xregs_state *xsave, int xfeature_nr)
 	 * have not enabled.  Remember that pcntxt_mask is
 	 * what we write to the XCR0 register.
 	 */
-	WARN_ONCE(!(xfeatures_mask & BIT_ULL(xfeature_nr)),
+	WARN_ONCE(!(xfeatures_mask_user & BIT_ULL(xfeature_nr)),
 		  "get of unsupported state");
 	/*
 	 * This assumes the last 'xsave*' instruction to
-- 
2.17.1

