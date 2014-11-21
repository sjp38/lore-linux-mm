Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1957C6B0073
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 13:25:08 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 9so2508168ykp.8
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 10:25:07 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id y8si7776801qch.46.2014.11.21.10.25.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 10:25:06 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v6 1/7] x86, mm, pat: Set WT to PA7 slot of PAT MSR
Date: Fri, 21 Nov 2014 11:10:34 -0700
Message-Id: <1416593440-23083-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1416593440-23083-1-git-send-email-toshi.kani@hp.com>
References: <1416593440-23083-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

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
---
 arch/x86/mm/pat.c |   71 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 56 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 25d2c58..0f0be47 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -197,6 +197,7 @@ void pat_init(void)
 {
 	u64 pat;
 	bool boot_cpu = !boot_pat_state;
+	struct cpuinfo_x86 *c = &boot_cpu_data;
 
 	if (!pat_enabled)
 		return;
@@ -217,21 +218,61 @@ void pat_init(void)
 		}
 	}
 
-	/* Set PWT to Write-Combining. All other bits stay the same */
-	/*
-	 * PTE encoding used in Linux:
-	 *      PAT
-	 *      |PCD
-	 *      ||PWT
-	 *      |||
-	 *      000 WB		_PAGE_CACHE_WB
-	 *      001 WC		_PAGE_CACHE_WC
-	 *      010 UC-		_PAGE_CACHE_UC_MINUS
-	 *      011 UC		_PAGE_CACHE_UC
-	 * PAT bit unused
-	 */
-	pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
-	      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	if ((c->x86_vendor == X86_VENDOR_INTEL) &&
+	    (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
+	     ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
+		/*
+		 * PAT support with the lower four entries. Intel Pentium 2,
+		 * 3, M, and 4 are affected by PAT errata, which makes the
+		 * upper four entries unusable.  We do not use the upper four
+		 * entries for all the affected processor families for safe.
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
+		 * PAT bit unused
+		 *
+		 * NOTE: When WT or WP is used, it is redirected to UC- per
+		 * the default setup in __cachemode2pte_tbl[].
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
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
+	}
 
 	/* Boot CPU check */
 	if (!boot_pat_state)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
