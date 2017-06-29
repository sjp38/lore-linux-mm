Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 136C06B0374
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:53:39 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x82so22009099oix.10
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:53:39 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v206si3981307oia.59.2017.06.29.08.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:53:37 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 09/10] x86/mm: Enable CR4.PCIDE on supported systems
Date: Thu, 29 Jun 2017 08:53:21 -0700
Message-Id: <6327ecd907b32f79d5aa0d466f04503bbec5df88.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

We can use PCID if the CPU has PCID and PGE and we're not on Xen.

By itself, this has no effect.  The next patch will start using
PCID.

Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Juergen Gross <jgross@suse.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h |  8 ++++++++
 arch/x86/kernel/cpu/common.c    | 22 ++++++++++++++++++++++
 arch/x86/xen/enlighten_pv.c     |  6 ++++++
 3 files changed, 36 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 06e997a36d49..6397275008db 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -243,6 +243,14 @@ static inline void __flush_tlb_all(void)
 		__flush_tlb_global();
 	else
 		__flush_tlb();
+
+	/*
+	 * Note: if we somehow had PCID but not PGE, then this wouldn't work --
+	 * we'd end up flushing kernel translations for the current ASID but
+	 * we might fail to flush kernel translations for other cached ASIDs.
+	 *
+	 * To avoid this issue, we force PCID off if PGE is off.
+	 */
 }
 
 static inline void __flush_tlb_one(unsigned long addr)
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 904485e7b230..b95cd94ca97b 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -329,6 +329,25 @@ static __always_inline void setup_smap(struct cpuinfo_x86 *c)
 	}
 }
 
+static void setup_pcid(struct cpuinfo_x86 *c)
+{
+	if (cpu_has(c, X86_FEATURE_PCID)) {
+		if (cpu_has(c, X86_FEATURE_PGE)) {
+			cr4_set_bits(X86_CR4_PCIDE);
+		} else {
+			/*
+			 * flush_tlb_all(), as currently implemented, won't
+			 * work if PCID is on but PGE is not.  Since that
+			 * combination doesn't exist on real hardware, there's
+			 * no reason to try to fully support it, but it's
+			 * polite to avoid corrupting data if we're on
+			 * an improperly configured VM.
+			 */
+			clear_cpu_cap(c, X86_FEATURE_PCID);
+		}
+	}
+}
+
 /*
  * Protection Keys are not available in 32-bit mode.
  */
@@ -1143,6 +1162,9 @@ static void identify_cpu(struct cpuinfo_x86 *c)
 	setup_smep(c);
 	setup_smap(c);
 
+	/* Set up PCID */
+	setup_pcid(c);
+
 	/*
 	 * The vendor-specific functions might have changed features.
 	 * Now we do "generic changes."
diff --git a/arch/x86/xen/enlighten_pv.c b/arch/x86/xen/enlighten_pv.c
index f33eef4ebd12..a136aac543c3 100644
--- a/arch/x86/xen/enlighten_pv.c
+++ b/arch/x86/xen/enlighten_pv.c
@@ -295,6 +295,12 @@ static void __init xen_init_capabilities(void)
 	setup_clear_cpu_cap(X86_FEATURE_ACC);
 	setup_clear_cpu_cap(X86_FEATURE_X2APIC);
 
+	/*
+	 * Xen PV would need some work to support PCID: CR3 handling as well
+	 * as xen_flush_tlb_others() would need updating.
+	 */
+	setup_clear_cpu_cap(X86_FEATURE_PCID);
+
 	if (!xen_initial_domain())
 		setup_clear_cpu_cap(X86_FEATURE_ACPI);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
