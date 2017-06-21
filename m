Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8806B0315
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:28 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t199so98072275oif.9
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:28 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e17si6435373ote.394.2017.06.20.22.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:27 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 08/11] x86/mm: Disable PCID on 32-bit kernels
Date: Tue, 20 Jun 2017 22:22:14 -0700
Message-Id: <d817b0638d5225c7ee5560f86e0b216dd9f76e9a.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
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
