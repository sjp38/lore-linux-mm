Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 70D586B003B
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 04:54:09 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so8154017pad.0
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 01:54:09 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v3si274639pds.170.2014.09.11.01.54.08
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 01:54:08 -0700 (PDT)
From: Qiaowei Ren <qiaowei.ren@intel.com>
Subject: [PATCH v8 03/10] x86, mpx: add macro cpu_has_mpx
Date: Thu, 11 Sep 2014 16:46:43 +0800
Message-Id: <1410425210-24789-4-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qiaowei Ren <qiaowei.ren@intel.com>

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
index bb9b258..82ec7ed 100644
--- a/arch/x86/include/asm/cpufeature.h
+++ b/arch/x86/include/asm/cpufeature.h
@@ -353,6 +353,12 @@ extern const char * const x86_bug_flags[NBUGINTS*32];
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
