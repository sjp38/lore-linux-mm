Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAA26B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 14:47:29 -0400 (EDT)
Received: by mail-yh0-f49.google.com with SMTP id z6so6639168yhz.8
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 11:47:29 -0700 (PDT)
Received: from g5t1626.atlanta.hp.com (g5t1626.atlanta.hp.com. [15.192.137.9])
        by mx.google.com with ESMTPS id a7si13617016yhd.106.2014.09.04.11.47.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 11:47:28 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Date: Thu,  4 Sep 2014 12:35:35 -0600
Message-Id: <1409855739-8985-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linuxfoundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, konrad.wilk@oracle.com, Toshi Kani <toshi.kani@hp.com>

This patch sets WT to the PA4 slot in the PAT MSR when the processor
is not affected by the PAT errata.  The upper 4 slots of the PAT MSR
are continued to be unused on the following Intel processors.

  errata           cpuid
  --------------------------------------
  Pentium 2, A52   family 0x6, model 0x5
  Pentium 3, E27   family 0x6, model 0x7
  Pentium M, Y26   family 0x6, model 0x9
  Pentium 4, N46   family 0xf, model 0x0

For these affected processors, _PAGE_CACHE_MODE_WT is redirected to UC-
per the default setup in __cachemode2pte_tbl[].

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/mm/pat.c |   47 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 32 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index feb4d30..b1891dc 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -132,6 +132,7 @@ void pat_init(void)
 {
 	u64 pat;
 	bool boot_cpu = !boot_pat_state;
+	struct cpuinfo_x86 *c = &boot_cpu_data;
 
 	if (!pat_enabled)
 		return;
@@ -152,21 +153,37 @@ void pat_init(void)
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
+	    (((c->x86 == 0x6) &&
+	      ((c->x86_model == 0x5) ||
+	       (c->x86_model == 0x7) ||
+	       (c->x86_model == 0x9))) ||
+	     ((c->x86 == 0xf) && (c->x86_model == 0x0)))) {
+		/*
+		 * Upper four PAT entries are not usable on the following
+		 * Intel processors.
+		 *
+		 *   errata           cpuid
+		 *   --------------------------------------
+		 *   Pentium 2, A52   family 0x6, model 0x5
+		 *   Pentium 3, E27   family 0x6, model 0x7
+		 *   Pentium M, Y26   family 0x6, model 0x9
+		 *   Pentium 4, N46   family 0xf, model 0x0
+		 *
+		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4-7:unusable
+		 *
+		 * NOTE: When WT or WP is used, it is redirected * to UC-
+		 * per the default setup in  __cachemode2pte_tbl[].
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	} else {
+		/*
+		 * PAT 0:WB, 1:WC, 2:UC-, 3:UC, 4:WT, 5-7:reserved
+		 */
+		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
+		      PAT(4, WT) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, UC);
+	}
 
 	/* Boot CPU check */
 	if (!boot_pat_state)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
