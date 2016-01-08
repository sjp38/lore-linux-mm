Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9E9A9828E9
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 18:15:45 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so271556292pac.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 15:15:45 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id r5si7928437pfr.2.2016.01.08.15.15.44
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 15:15:45 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 06/13] x86/mm: Disable PCID on 32-bit kernels
Date: Fri,  8 Jan 2016 15:15:24 -0800
Message-Id: <a68c8eb9183aa633c5c976a58120ee0a64f75563.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
In-Reply-To: <cover.1452294700.git.luto@kernel.org>
References: <cover.1452294700.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

32-bit kernels on new hardware will see PCID in CPUID, but PCID can
only be used in 64-bit mode.  Rather than making all PCID code
conditional, just disable the feature on 32-bit builds.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/disabled-features.h | 4 +++-
 arch/x86/kernel/cpu/bugs.c               | 6 ++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/disabled-features.h b/arch/x86/include/asm/disabled-features.h
index f226df064660..8b17c2ad1048 100644
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
 
 /*
@@ -35,7 +37,7 @@
 #define DISABLED_MASK1	0
 #define DISABLED_MASK2	0
 #define DISABLED_MASK3	(DISABLE_CYRIX_ARR|DISABLE_CENTAUR_MCR|DISABLE_K6_MTRR)
-#define DISABLED_MASK4	0
+#define DISABLED_MASK4	(DISABLE_PCID)
 #define DISABLED_MASK5	0
 #define DISABLED_MASK6	0
 #define DISABLED_MASK7	0
diff --git a/arch/x86/kernel/cpu/bugs.c b/arch/x86/kernel/cpu/bugs.c
index bd17db15a2c1..741d107e5376 100644
--- a/arch/x86/kernel/cpu/bugs.c
+++ b/arch/x86/kernel/cpu/bugs.c
@@ -19,6 +19,12 @@
 
 void __init check_bugs(void)
 {
+	/*
+	 * Regardless of whether PCID is enumerated, it can't be used in
+	 * 32-bit mode.
+	 */
+	setup_clear_cpu_cap(X86_FEATURE_PCID);
+
 	identify_boot_cpu();
 #ifndef CONFIG_SMP
 	pr_info("CPU: ");
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
