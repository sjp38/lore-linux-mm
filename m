Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 544FA6B0047
	for <linux-mm@kvack.org>; Sat, 21 Feb 2009 08:36:17 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 3so195285eyh.44
        for <linux-mm@kvack.org>; Sat, 21 Feb 2009 05:36:14 -0800 (PST)
From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] kmemcheck: disable fast string operations on P4 CPUs
Date: Sat, 21 Feb 2009 14:36:01 +0100
Message-Id: <1235223364-2097-2-git-send-email-vegard.nossum@gmail.com>
In-Reply-To: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
References: <1235223364-2097-1-git-send-email-vegard.nossum@gmail.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

This patch may allow us to remove the REP emulation code from
kmemcheck.

Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 arch/x86/kernel/cpu/intel.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/cpu/intel.c b/arch/x86/kernel/cpu/intel.c
index 1f137a8..65e9717 100644
--- a/arch/x86/kernel/cpu/intel.c
+++ b/arch/x86/kernel/cpu/intel.c
@@ -75,6 +75,29 @@ static void __cpuinit early_init_intel(struct cpuinfo_x86 *c)
 	 */
 	if (c->x86 == 6 && c->x86_model < 15)
 		clear_cpu_cap(c, X86_FEATURE_PAT);
+
+#ifdef CONFIG_KMEMCHECK
+	/*
+	 * P4s have a "fast strings" feature which causes single-
+	 * stepping REP instructions to only generate a #DB on
+	 * cache-line boundaries.
+	 *
+	 * Ingo Molnar reported a Pentium D (model 6) and a Xeon
+	 * (model 2) with the same problem.
+	 */
+	if (c->x86 == 15) {
+		u64 misc_enable;
+
+		rdmsrl(MSR_IA32_MISC_ENABLE, misc_enable);
+
+		if (misc_enable & MSR_IA32_MISC_ENABLE_FAST_STRING) {
+			printk(KERN_INFO "kmemcheck: Disabling fast string operations\n");
+
+			misc_enable &= ~MSR_IA32_MISC_ENABLE_FAST_STRING;
+			wrmsrl(MSR_IA32_MISC_ENABLE, misc_enable);
+		}
+	}
+#endif
 }
 
 #ifdef CONFIG_X86_32
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
