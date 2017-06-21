Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DBE76B0338
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:30 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id x57so71181494otd.8
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:30 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s13si6431575ota.97.2017.06.20.22.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:29 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 10/11] x86/mm: Enable CR4.PCIDE on supported systems
Date: Tue, 20 Jun 2017 22:22:16 -0700
Message-Id: <57c1d18b1c11f9bc9a3bcf8bdee38033415e1a13.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

We can use PCID if the CPU has PCID and PGE and we're not on Xen.

By itself, this has no effect.  The next patch will start using
PCID.

Cc: Juergen Gross <jgross@suse.com>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/include/asm/tlbflush.h |  8 ++++++++
 arch/x86/kernel/cpu/common.c    | 15 +++++++++++++++
 arch/x86/xen/enlighten_pv.c     |  6 ++++++
 3 files changed, 29 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 87b13e51e867..57b305e13c4c 100644
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
index 904485e7b230..01caf66b270f 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -1143,6 +1143,21 @@ static void identify_cpu(struct cpuinfo_x86 *c)
 	setup_smep(c);
 	setup_smap(c);
 
+	/* Set up PCID */
+	if (cpu_has(c, X86_FEATURE_PCID)) {
+		if (cpu_has(c, X86_FEATURE_PGE)) {
+			cr4_set_bits(X86_CR4_PCIDE);
+		} else {
+			/*
+			 * flush_tlb_all(), as currently implemented, won't
+			 * work if PCID is on but PGE is not.  Since that
+			 * combination doesn't exist on real hardware, there's
+			 * no reason to try to fully support it.
+			 */
+			clear_cpu_cap(c, X86_FEATURE_PCID);
+		}
+	}
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
