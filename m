Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7516B0311
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 00:56:42 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id i42so64879677otb.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 21:56:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r48si1148774otb.25.2017.06.13.21.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 21:56:41 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 07/10] x86/mm: Disable PCID on 32-bit kernels
Date: Tue, 13 Jun 2017 21:56:25 -0700
Message-Id: <40dd3241c8f56825bdcf5a83f61e7cdeacf723cc.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
In-Reply-To: <cover.1497415951.git.luto@kernel.org>
References: <cover.1497415951.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

32-bit kernels on new hardware will see PCID in CPUID, but PCID can
only be used in 64-bit mode.  Rather than making all PCID code
conditional, just disable the feature on 32-bit builds.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/disabled-features.h | 4 +++-
 arch/x86/kernel/cpu/bugs.c               | 8 ++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index 5dff775af7cd..c10c9128f54e 100644
--- a/arch/x86/include/asm/disabled-features.h
+++ b/arch/x86/include/asm/disabled-features.h
@@ -21,11 +21,13 @@
 # define DISABLE_K6_MTRR	(1<<(X86_FEATURE_K6_MTRR & 31))
 # define DISABLE_CYRIX_ARR	(1<<(X86_FEATURE_CYRIX_ARR & 31))
 # define DISABLE_CENTAUR_MCR	(1<<(X86_FEATURE_CENTAUR_MCR & 31))
+# define DISABLE_PCID		0
 #else
 # define DISABLE_VME		0
 # define DISABLE_K6_MTRR	0
 # define DISABLE_CYRIX_ARR	0
 # define DISABLE_CENTAUR_MCR	0
+# define DISABLE_PCID		(1<<(X86_FEATURE_PCID & 31))
 #endif /* CONFIG_X86_64 */
 
 #ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
@@ -49,7 +51,7 @@
 #define DISABLED_MASK1	0
 #define DISABLED_MASK2	0
 #define DISABLED_MASK3	(DISABLE_CYRIX_ARR|DISABLE_CENTAUR_MCR|DISABLE_K6_MTRR)
-#define DISABLED_MASK4	0
+#define DISABLED_MASK4	(DISABLE_PCID)
 #define DISABLED_MASK5	0
 #define DISABLED_MASK6	0
 #define DISABLED_MASK7	0
diff --git a/arch/x86/kernel/cpu/bugs.c b/arch/x86/kernel/cpu/bugs.c
index 0af86d9242da..db684880d74a 100644
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -21,6 +21,14 @@
 
 void __init check_bugs(void)
 {
+#ifdef CONFIG_X86_32
+	/*
+	 * Regardless of whether PCID is enumerated, the SDM says
+	 * that it can't be enabled in 32-bit mode.
+	 */
+	setup_clear_cpu_cap(X86_FEATURE_PCID);
+#endif
+
 	identify_boot_cpu();
 
 	if (!IS_ENABLED(CONFIG_SMP)) {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
