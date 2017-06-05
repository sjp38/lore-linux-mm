Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CBAD6B0311
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:11 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id 106so4283435otc.14
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:11 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h48si8109052otc.100.2017.06.05.15.37.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:10 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 07/11] x86/mm: Disable PCID on 32-bit kernels
Date: Mon,  5 Jun 2017 15:36:31 -0700
Message-Id: <84d23f721ae0c1693fb6de863b0051b75cf3ed26.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
