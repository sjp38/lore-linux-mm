Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8391A6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:51 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so1913477pgv.5
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e12si1063375pgr.143.2017.11.29.02.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:50 -0800 (PST)
Message-Id: <20171129103512.769862503@infradead.org>
Date: Wed, 29 Nov 2017 11:33:04 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 3/6] x86/mm/kaiser: Allow PCID with nokaiser
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-nokaiser-dont-kill-pcid.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

Currently KAISER kills PCID on platforms that lack INVPCID, even when
nokaiser.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |    9 +++++----
 arch/x86/mm/init.c              |    2 +-
 arch/x86/mm/tlb.c               |    7 ++++++-
 3 files changed, 12 insertions(+), 6 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -9,6 +9,7 @@
 #include <asm/cpufeature.h>
 #include <asm/special_insns.h>
 #include <asm/smp.h>
+#include <asm/kaiser.h>
 
 static inline void __invpcid(unsigned long pcid, unsigned long addr,
 			     unsigned long type)
@@ -355,12 +356,12 @@ static inline void __native_flush_tlb(vo
 		 * CR4 has X86_CR4_PCIDE set.  In other words, this does
 		 * not fully flush the TLB if PCIDs are in use.
 		 *
-		 * With KAISER and PCIDs, the means that we did not
+		 * With KAISER and PCIDs, that means that we did not
 		 * flush the user PCID.  Warn if it gets called.
 		 */
-		if (IS_ENABLED(CONFIG_KAISER))
-			WARN_ON_ONCE(this_cpu_read(cpu_tlbstate.cr4) &
-				     X86_CR4_PCIDE);
+		if (IS_ENABLED(CONFIG_KAISER) && kaiser_enabled)
+			WARN_ON_ONCE(this_cpu_read(cpu_tlbstate.cr4) & X86_CR4_PCIDE);
+
 		/*
 		 * If current->mm == NULL then we borrow a mm
 		 * which may change during a task switch and
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -219,7 +219,7 @@ static void setup_pcid(void)
 		 * have KAISER and do not have INVPCID.
 		 */
 		if (!IS_ENABLED(CONFIG_X86_GLOBAL_PAGES) &&
-		    !boot_cpu_has(X86_FEATURE_INVPCID)) {
+		    kaiser_enabled && !boot_cpu_has(X86_FEATURE_INVPCID)) {
 			setup_clear_cpu_cap(X86_FEATURE_PCID);
 			return;
 		}
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -6,13 +6,14 @@
 #include <linux/interrupt.h>
 #include <linux/export.h>
 #include <linux/cpu.h>
+#include <linux/debugfs.h>
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
 #include <asm/cache.h>
 #include <asm/apic.h>
 #include <asm/uv/uv.h>
-#include <linux/debugfs.h>
+#include <asm/kaiser.h>
 
 /*
  *	TLB flushing, formerly SMP-only
@@ -115,6 +116,10 @@ static void flush_user_asid(pgd_t *pgd,
 	 */
 	if (!cpu_feature_enabled(X86_FEATURE_PCID))
 		return;
+
+	if (!kaiser_enabled)
+		return;
+
 	/*
 	 * With PCIDs enabled, write_cr3() only flushes TLB
 	 * entries for the current (kernel) ASID.  This leaves


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
