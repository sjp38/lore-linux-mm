Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D42EC46460
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52ACC20B1F
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52ACC20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FA4F6B028F; Thu,  6 Jun 2019 16:15:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9357A6B0292; Thu,  6 Jun 2019 16:15:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7598A6B0293; Thu,  6 Jun 2019 16:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 291D06B028F
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:17 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z10so2291664pgf.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=xNZB2zLiZ21eOdSBBflS3RlJecfHCk2sycG3I8os74o=;
        b=HOJ4jwvVW24JE6BAR7jlTC+g6hNy+eiYMpOi0Kt1U6WOEWqwOO8OZCFcdSf5zBL2fY
         62WBZLpnfHV2HkRzHRVS5UoM9fVCO2jTjZAA64ZGDhVRBWpyyE1XI3h99emUht1dsSAy
         IqExd0gg4QDXGbNaShBYjKucKlPDVzA4KayoReRAY3auhRlGP4SdVrYX8fV5+pvcePZw
         sODRZJrDffEukjcn+lj1pXiow7FLBuQ4zFxCPgQ4UcqOMl3CEzBDboK8f4rjGGYzhcfl
         rwDZYa/z+ZENGsAiiz/zHp8jb/nPtfTxW893QFL7t52Y2huNZhAth4GYY7SPPfsmGWz0
         VB8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXmIWEFYR6csMWSuqxjGm7+kWmzUw268GLkBFXtHPMm+C6782wo
	y6jSj+0tWtfWe1yUPhL/bb0XCUOXBlDRg0cFL7fGR2RMJZgGLYzVdqoi+2L8BokINE8KMZGuIf6
	hZoC8+YQsYELW3puvgq0dNa2/DduhFH2U/enXUM7IvFGtU6sbf323O0Ca6rEqVvOocQ==
X-Received: by 2002:a17:90a:2561:: with SMTP id j88mr1637636pje.121.1559852116818;
        Thu, 06 Jun 2019 13:15:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvNs7rsDrIikOlkllqgy4G0quYo3NlNkdkB+r+ixYDlm8vYT3fGV2I5PLwnHzxCb6l5w0u
X-Received: by 2002:a17:90a:2561:: with SMTP id j88mr1637529pje.121.1559852115423;
        Thu, 06 Jun 2019 13:15:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852115; cv=none;
        d=google.com; s=arc-20160816;
        b=HsVtDua7yqQhCBWS/TckusnnNpuHULlswjmd0tS9YnkQFq8rsjCKShVcpLFRwnXeCE
         HMtFWjscADuvV2m/dLKACA5hhYYLGytP/lbcTNbO6CTulm+xxuagnglZUfclAcBKTWpz
         Zm5L7Yz7g3cPrV42gxuCzNDG4STJ/pSOQy/yincaga7ajskUf6Sq1akSwhkR4Zx+nhr1
         rDofmAn9F6CbYaHJaP3Hqho6UEpb6lrpYG8BQcmNUu0G5jWfY/114J61YbTDASzoQ+sY
         eT/z908/YRb1c5BYjV1oPd/XIhGcJoqUPQ1w/c/Y5yUQufjFldVl9xl+p6x7sTnaIpvI
         rR1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=xNZB2zLiZ21eOdSBBflS3RlJecfHCk2sycG3I8os74o=;
        b=xJVAhvtTZ/VikvIb5mmr33znv++UjnmG3JElCIBZxX0UyBw9A3zfyPRqJrwhaYm+tx
         5/atSeGNfl0HUoZjoYRxIB2fVK1euPkRerHbNycHFbngiQUbHXD+yb9Ils3NWxkpriu/
         A6oZcz/oz+hZlOcSbtgPmRCjvAzZnVboom81TKPgyojBjdqy7HW9/VHQKqCfQbXH3DZh
         Hj4HORkWMy25hDwn7RxLrNtUQYlRrAzdls0zOtMrXodJeranX6U6gz8aOYzONECIYne2
         1k+8X/bH+vyWvxfP823WHrV2m0ki0R+/LvgXmKFKYO7TaxW004HHSPokrzvEF67jafY2
         Gs2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91si31377plh.398.2019.06.06.13.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:14 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:13 -0700
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
Subject: [PATCH v7 05/27] x86/fpu/xstate: Add XSAVES system states for shadow stack
Date: Thu,  6 Jun 2019 13:06:24 -0700
Message-Id: <20190606200646.3951-6-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Intel Control-flow Enforcement Technology (CET) introduces the
following MSRs.

    MSR_IA32_U_CET (user-mode CET settings),
    MSR_IA32_PL3_SSP (user-mode shadow stack),
    MSR_IA32_PL0_SSP (kernel-mode shadow stack),
    MSR_IA32_PL1_SSP (Privilege Level 1 shadow stack),
    MSR_IA32_PL2_SSP (Privilege Level 2 shadow stack).

Introduce them into XSAVES system states.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/fpu/types.h            | 22 +++++++++++++++++++++
 arch/x86/include/asm/fpu/xstate.h           |  4 +++-
 arch/x86/include/uapi/asm/processor-flags.h |  2 ++
 arch/x86/kernel/fpu/xstate.c                | 10 ++++++++++
 4 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/fpu/types.h b/arch/x86/include/asm/fpu/types.h
index f098f6cab94b..d7ef4d9c7ad5 100644
--- a/arch/x86/include/asm/fpu/types.h
+++ b/arch/x86/include/asm/fpu/types.h
@@ -114,6 +114,9 @@ enum xfeature {
 	XFEATURE_Hi16_ZMM,
 	XFEATURE_PT_UNIMPLEMENTED_SO_FAR,
 	XFEATURE_PKRU,
+	XFEATURE_RESERVED,
+	XFEATURE_CET_USER,
+	XFEATURE_CET_KERNEL,
 
 	XFEATURE_MAX,
 };
@@ -128,6 +131,8 @@ enum xfeature {
 #define XFEATURE_MASK_Hi16_ZMM		(1 << XFEATURE_Hi16_ZMM)
 #define XFEATURE_MASK_PT		(1 << XFEATURE_PT_UNIMPLEMENTED_SO_FAR)
 #define XFEATURE_MASK_PKRU		(1 << XFEATURE_PKRU)
+#define XFEATURE_MASK_CET_USER		(1 << XFEATURE_CET_USER)
+#define XFEATURE_MASK_CET_KERNEL	(1 << XFEATURE_CET_KERNEL)
 
 #define XFEATURE_MASK_FPSSE		(XFEATURE_MASK_FP | XFEATURE_MASK_SSE)
 #define XFEATURE_MASK_AVX512		(XFEATURE_MASK_OPMASK \
@@ -229,6 +234,23 @@ struct pkru_state {
 	u32				pad;
 } __packed;
 
+/*
+ * State component 11 is Control-flow Enforcement user states
+ */
+struct cet_user_state {
+	u64 user_cet;			/* user control-flow settings */
+	u64 user_ssp;			/* user shadow stack pointer */
+};
+
+/*
+ * State component 12 is Control-flow Enforcement kernel states
+ */
+struct cet_kernel_state {
+	u64 kernel_ssp;			/* kernel shadow stack */
+	u64 pl1_ssp;			/* privilege level 1 shadow stack */
+	u64 pl2_ssp;			/* privilege level 2 shadow stack */
+};
+
 struct xstate_header {
 	u64				xfeatures;
 	u64				xcomp_bv;
diff --git a/arch/x86/include/asm/fpu/xstate.h b/arch/x86/include/asm/fpu/xstate.h
index 2ec19415c58e..9ac8a81e851d 100644
--- a/arch/x86/include/asm/fpu/xstate.h
+++ b/arch/x86/include/asm/fpu/xstate.h
@@ -30,7 +30,9 @@
 				  XFEATURE_MASK_Hi16_ZMM | \
 				  XFEATURE_MASK_PKRU | \
 				  XFEATURE_MASK_BNDREGS | \
-				  XFEATURE_MASK_BNDCSR)
+				  XFEATURE_MASK_BNDCSR | \
+				  XFEATURE_MASK_CET_USER | \
+				  XFEATURE_MASK_CET_KERNEL)
 
 #ifdef CONFIG_X86_64
 #define REX_PREFIX	"0x48, "
diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index bcba3c643e63..a8df907e8017 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -130,6 +130,8 @@
 #define X86_CR4_SMAP		_BITUL(X86_CR4_SMAP_BIT)
 #define X86_CR4_PKE_BIT		22 /* enable Protection Keys support */
 #define X86_CR4_PKE		_BITUL(X86_CR4_PKE_BIT)
+#define X86_CR4_CET_BIT		23 /* enable Control-flow Enforcement */
+#define X86_CR4_CET		_BITUL(X86_CR4_CET_BIT)
 
 /*
  * x86-64 Task Priority Register, CR8
diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index 6b453455a4f0..7f99878111d7 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -36,6 +36,9 @@ static const char *xfeature_names[] =
 	"Processor Trace (unused)"	,
 	"Protection Keys User registers",
 	"unknown xstate feature"	,
+	"Control-flow User registers"	,
+	"Control-flow Kernel registers"	,
+	"unknown xstate feature"	,
 };
 
 static short xsave_cpuid_features[] __initdata = {
@@ -49,6 +52,9 @@ static short xsave_cpuid_features[] __initdata = {
 	X86_FEATURE_AVX512F,
 	X86_FEATURE_INTEL_PT,
 	X86_FEATURE_PKU,
+	0,		   /* Unused */
+	X86_FEATURE_SHSTK, /* XFEATURE_CET_USER */
+	X86_FEATURE_SHSTK, /* XFEATURE_CET_KERNEL */
 };
 
 /*
@@ -320,6 +326,8 @@ static void __init print_xstate_features(void)
 	print_xstate_feature(XFEATURE_MASK_ZMM_Hi256);
 	print_xstate_feature(XFEATURE_MASK_Hi16_ZMM);
 	print_xstate_feature(XFEATURE_MASK_PKRU);
+	print_xstate_feature(XFEATURE_MASK_CET_USER);
+	print_xstate_feature(XFEATURE_MASK_CET_KERNEL);
 }
 
 /*
@@ -566,6 +574,8 @@ static void check_xstate_against_struct(int nr)
 	XCHECK_SZ(sz, nr, XFEATURE_ZMM_Hi256, struct avx_512_zmm_uppers_state);
 	XCHECK_SZ(sz, nr, XFEATURE_Hi16_ZMM,  struct avx_512_hi16_state);
 	XCHECK_SZ(sz, nr, XFEATURE_PKRU,      struct pkru_state);
+	XCHECK_SZ(sz, nr, XFEATURE_CET_USER,   struct cet_user_state);
+	XCHECK_SZ(sz, nr, XFEATURE_CET_KERNEL, struct cet_kernel_state);
 
 	/*
 	 * Make *SURE* to add any feature numbers in below if
-- 
2.17.1

