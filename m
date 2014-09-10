Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 48E806B003A
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:02:41 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id vb8so13098143obc.26
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:02:41 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id c10si23060823oeu.92.2014.09.10.10.02.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 10:02:39 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 1/6] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Date: Wed, 10 Sep 2014 10:51:45 -0600
Message-Id: <1410367910-6026-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch sets WT to the PA7 slot in the PAT MSR when the processor
is not affected by the PAT errata.  The PA7 slot is chosen to further
minimize the risk of using the PAT bit as the PA3 slot is UC and is
not currently used.

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
---
 arch/x86/mm/pat.c |   43 ++++++++++++++++++++++++++++---------------
 1 file changed, 28 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index ff31851..598d7c7 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -133,6 +133,7 @@ void pat_init(void)
 {
 	u64 pat;
 	bool boot_cpu = !boot_pat_state;
+	struct cpuinfo_x86 *c = &boot_cpu_data;
 
 	if (!pat_enabled)
 		return;
@@ -153,21 +154,33 @@ void pat_init(void)
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
+		 * Intel Pentium 2, 3, M, and 4 are affected by PAT errata,
+		 * which makes the upper four entries unusable.  We do not
+		 * use the upper four entries for all the affected processor
+		 * families for safe.
+		 *
+		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4-7:unusable
+		 *
+		 * NOTE: When WT or WP is used, it is redirected to UC- per
+		 * the default setup in  __cachemode2pte_tbl[].
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	} else {
+		/*
+		 * WT is set to slot 7, which minimizes the risk of using
+		 * the PAT bit as slot 3 is UC and is currently unused.
+		 * Slot 4 should remain as reserved.
+		 *
+		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4-6:reserved, 7:WT
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
