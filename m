Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 017516B0274
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:33:56 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w18so4506338wra.5
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:33:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 195si20565985wmp.215.2018.01.01.06.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:33:54 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.9 21/75] x86/mm: Enable CR4.PCIDE on supported systems
Date: Mon,  1 Jan 2018 15:31:58 +0100
Message-Id: <20180101140059.950536297@linuxfoundation.org>
In-Reply-To: <20180101140056.475827799@linuxfoundation.org>
References: <20180101140056.475827799@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@intel.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>

4.9-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Andy Lutomirski <luto@kernel.org>

commit 660da7c9228f685b2ebe664f9fd69aaddcc420b5 upstream.

We can use PCID if the CPU has PCID and PGE and we're not on Xen.

By itself, this has no effect. A followup patch will start using PCID.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
Reviewed-by: Nadav Amit <nadav.amit@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/6327ecd907b32f79d5aa0d466f04503bbec5df88.1498751203.git.luto@kernel.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |    8 ++++++++
 arch/x86/kernel/cpu/common.c    |   22 ++++++++++++++++++++++
 arch/x86/xen/enlighten.c        |    6 ++++++
 3 files changed, 36 insertions(+)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -191,6 +191,14 @@ static inline void __flush_tlb_all(void)
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
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -324,6 +324,25 @@ static __always_inline void setup_smap(s
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
@@ -1082,6 +1101,9 @@ static void identify_cpu(struct cpuinfo_
 	setup_smep(c);
 	setup_smap(c);
 
+	/* Set up PCID */
+	setup_pcid(c);
+
 	/*
 	 * The vendor-specific functions might have changed features.
 	 * Now we do "generic changes."
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -444,6 +444,12 @@ static void __init xen_init_cpuid_mask(v
 		~((1 << X86_FEATURE_MTRR) |  /* disable MTRR */
 		  (1 << X86_FEATURE_ACC));   /* thermal monitoring */
 
+	/*
+	 * Xen PV would need some work to support PCID: CR3 handling as well
+	 * as xen_flush_tlb_others() would need updating.
+	 */
+	cpuid_leaf1_ecx_mask &= ~(1 << (X86_FEATURE_PCID % 32));  /* disable PCID */
+
 	if (!xen_initial_domain())
 		cpuid_leaf1_edx_mask &=
 			~((1 << X86_FEATURE_ACPI));  /* disable ACPI */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
