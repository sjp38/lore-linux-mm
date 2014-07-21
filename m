Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 25CA36B0039
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 01:42:31 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so9040727pad.21
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 22:42:30 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j3si1107912pdd.56.2014.07.20.22.42.28
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 22:42:29 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v7 03/10] x86, mpx: add macro cpu_has_mpx
Date: Mon, 21 Jul 2014 13:38:37 +0800
Message-Id: <1405921124-4230-4-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
References: <1405921124-4230-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Qiaowei Ren <qiaowei.ren@intel.com>

In order to do performance optimization, this patch adds macro
cpu_has_mpx which will directly return 0 when MPX is not supported
by kernel.

Community gave a lot of comments on this macro cpu_has_mpx in previous
version. Dave will introduce a patchset about disabled features to fix
it later.

In this code:
        if (cpu_has_mpx)
                do_some_mpx_thing();

The patch series from Dave will introduce a new macro cpu_feature_enabled()
(if merged after this patchset) to replace the cpu_has_mpx.
        if (cpu_feature_enabled(X86_FEATURE_MPX))
                do_some_mpx_thing();

Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
---
 arch/x86/include/asm/cpufeature.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/cpufeature.h b/arch/x86/include/asm/cpufeature.h
index e265ff9..f302d08 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -339,6 +339,12 @@ extern const char * const x86_power_flags[32];
 #define cpu_has_eager_fpu	boot_cpu_has(X86_FEATURE_EAGER_FPU)
 #define cpu_has_topoext		boot_cpu_has(X86_FEATURE_TOPOEXT)
 
+#ifdef CONFIG_X86_INTEL_MPX
+#define cpu_has_mpx boot_cpu_has(X86_FEATURE_MPX)
+#else
+#define cpu_has_mpx 0
+#endif /* CONFIG_X86_INTEL_MPX */
+
 #ifdef CONFIG_X86_64
 
 #undef  cpu_has_vme
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
