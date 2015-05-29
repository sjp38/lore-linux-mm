Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 284596B0071
	for <linux-mm@kvack.org>; Fri, 29 May 2015 19:18:56 -0400 (EDT)
Received: by obbea2 with SMTP id ea2so68539065obb.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 16:18:55 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id j187si4409763oif.87.2015.05.29.16.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 16:18:54 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v11 3/12] x86, mm, pat: Set WT to PA7 slot of PAT MSR
Date: Fri, 29 May 2015 16:59:01 -0600
Message-Id: <1432940350-1802-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

From: Toshi Kani <toshi.kani@hp.com>

This patch sets WT to the PA7 slot in the PAT MSR when the processor
is not affected by the PAT errata.  The PA7 slot is chosen to improve
robustness in the presence of errata that might cause the high PAT bit
to be ignored.  This way a buggy PA7 slot access will hit the PA3 slot,
which is UC, so at worst we lose performance without causing a correctness
issue.

The following Intel processors are affected by the PAT errata.

   errata               cpuid
   ----------------------------------------------------
   Pentium 2, A52       family 0x6, model 0x5
   Pentium 3, E27       family 0x6, model 0x7, 0x8
   Pentium 3 Xenon, G26 family 0x6, model 0x7, 0x8, 0xa
   Pentium M, Y26       family 0x6, model 0x9
   Pentium M 90nm, X9   family 0x6, model 0xd
   Pentium 4, N46       family 0xf, model 0x0

Instead of making sharp boundary checks, this patch makes conservative
checks to exclude all Pentium 2, 3, M and 4 family processors.  For
such processors, _PAGE_CACHE_MODE_WT is redirected to UC- per the
default setup in __cachemode2pte_tbl[].

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/x86/mm/pat.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 49 insertions(+), 8 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 819ae28..3d9f125 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -201,6 +201,7 @@ void pat_init_cache_modes(void)
 void pat_init(void)
 {
 	u64 pat;
+	struct cpuinfo_x86 *c = &boot_cpu_data;
 	static bool boot_cpu_done;
 
 	if (!boot_cpu_done) {
@@ -246,21 +247,61 @@ void pat_init(void)
 		      PAT(4, WB) | PAT(5, WT) | PAT(6, UC_MINUS) | PAT(7, UC);
 		if (!boot_pat_state)
 			boot_pat_state = pat;
-	} else {
+
+	} else if ((c->x86_vendor == X86_VENDOR_INTEL) &&
+		   (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
+		    ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
 		/*
-		 * PTE encoding used in Linux:
+		 * PAT support with the lower four entries. Intel Pentium 2,
+		 * 3, M, and 4 are affected by PAT errata, which makes the
+		 * upper four entries unusable.  We do not use the upper four
+		 * entries for all the affected processor families for safe.
+		 *
+		 *  PTE encoding used in Linux:
 		 *      PAT
 		 *      |PCD
-		 *      ||PWT
-		 *      |||
-		 *      000 WB		_PAGE_CACHE_WB
-		 *      001 WC		_PAGE_CACHE_WC
-		 *      010 UC-		_PAGE_CACHE_UC_MINUS
-		 *      011 UC		_PAGE_CACHE_UC
+		 *      ||PWT  PAT
+		 *      |||    slot
+		 *      000    0    WB : _PAGE_CACHE_MODE_WB
+		 *      001    1    WC : _PAGE_CACHE_MODE_WC
+		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
+		 *      011    3    UC : _PAGE_CACHE_MODE_UC
 		 * PAT bit unused
+		 *
+		 * NOTE: When WT or WP is used, it is redirected to UC- per
+		 * the default setup in __cachemode2pte_tbl[].
 		 */
 		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
 		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	} else {
+		/*
+		 * PAT full support.  We put WT in slot 7 to improve
+		 * robustness in the presence of errata that might cause
+		 * the high PAT bit to be ignored.  This way a buggy slot 7
+		 * access will hit slot 3, and slot 3 is UC, so at worst
+		 * we lose performance without causing a correctness issue.
+		 * Pentium 4 erratum N46 is an example of such an erratum,
+		 * although we try not to use PAT at all on affected CPUs.
+		 *
+		 *  PTE encoding used in Linux:
+		 *      PAT
+		 *      |PCD
+		 *      ||PWT  PAT
+		 *      |||    slot
+		 *      000    0    WB : _PAGE_CACHE_MODE_WB
+		 *      001    1    WC : _PAGE_CACHE_MODE_WC
+		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
+		 *      011    3    UC : _PAGE_CACHE_MODE_UC
+		 *      100    4    WB : Reserved
+		 *      101    5    WC : Reserved
+		 *      110    6    UC-: Reserved
+		 *      111    7    WT : _PAGE_CACHE_MODE_WT
+		 *
+		 * The reserved slots are unused, but mapped to their
+		 * corresponding types in the presence of PAT errata.
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
 	}
 
 	if (pat_enabled())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
