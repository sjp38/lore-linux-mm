Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 672A26B0073
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:41:02 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so86356886pdb.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:41:02 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id yl8si336437pab.167.2015.06.07.10.41.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:41:01 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:40:22 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-d79a40caf8e15a2a15ecdefdc9d05865d4f37baa@git.kernel.org>
Reply-To: tglx@linutronix.de, hpa@zytor.com, akpm@linux-foundation.org,
        mcgrof@suse.com, toshi.kani@hp.com, linux-mm@kvack.org,
        mingo@kernel.org, linux-kernel@vger.kernel.org, luto@amacapital.net,
        bp@suse.de, peterz@infradead.org, torvalds@linux-foundation.org
Subject: [tip:x86/mm] x86/mm/pat:
  Use 7th PAT MSR slot for Write-Through PAT type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: toshi.kani@hp.com, mcgrof@suse.com, hpa@zytor.com, akpm@linux-foundation.org, tglx@linutronix.de, torvalds@linux-foundation.org, peterz@infradead.org, luto@amacapital.net, bp@suse.de, linux-mm@kvack.org, mingo@kernel.org

Commit-ID:  d79a40caf8e15a2a15ecdefdc9d05865d4f37baa
Gitweb:     http://git.kernel.org/tip/d79a40caf8e15a2a15ecdefdc9d05865d4f37baa
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:12 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:28:54 +0200

x86/mm/pat: Use 7th PAT MSR slot for Write-Through PAT type

Assign Write-Through type to the PA7 slot in the PAT MSR when
the processor is not affected by PAT errata. The PA7 slot is
chosen to improve robustness in the presence of errata that
might cause the high PAT bit to be ignored. This way a buggy PA7
slot access will hit the PA3 slot, which is UC, so at worst we
lose performance without causing a correctness issue.

The following Intel processors are affected by the PAT errata.

  Errata               CPUID
  ----------------------------------------------------
  Pentium 2, A52       family 0x6, model 0x5
  Pentium 3, E27       family 0x6, model 0x7, 0x8
  Pentium 3 Xenon, G26 family 0x6, model 0x7, 0x8, 0xa
  Pentium M, Y26       family 0x6, model 0x9
  Pentium M 90nm, X9   family 0x6, model 0xd
  Pentium 4, N46       family 0xf, model 0x0

Instead of making sharp boundary checks, we remain conservative
and exclude all Pentium 2, 3, M and 4 family processors. For
those, _PAGE_CACHE_MODE_WT is redirected to UC- per the default
setup in __cachemode2pte_tbl[].

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: https://lkml.kernel.org/r/1433187393-22688-2-git-send-email-toshi.kani@hp.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/mm/pat.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 50 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f89e460..59ab1a0f 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -235,6 +235,7 @@ static void pat_ap_init(u64 pat)
 void pat_init(void)
 {
 	u64 pat;
+	struct cpuinfo_x86 *c = &boot_cpu_data;
 
 	if (!pat_enabled()) {
 		/*
@@ -244,7 +245,7 @@ void pat_init(void)
 		 * has PAT but the "nopat" boot option has been specified. This
 		 * emulated PAT table is used when MSR_IA32_CR_PAT returns 0.
 		 *
-		 * PTE encoding used:
+		 * PTE encoding:
 		 *
 		 *       PCD
 		 *       |PWT  PAT
@@ -259,21 +260,61 @@ void pat_init(void)
 		 */
 		pat = PAT(0, WB) | PAT(1, WT) | PAT(2, UC_MINUS) | PAT(3, UC) |
 		      PAT(4, WB) | PAT(5, WT) | PAT(6, UC_MINUS) | PAT(7, UC);
-	} else {
+
+	} else if ((c->x86_vendor == X86_VENDOR_INTEL) &&
+		   (((c->x86 == 0x6) && (c->x86_model <= 0xd)) ||
+		    ((c->x86 == 0xf) && (c->x86_model <= 0x6)))) {
 		/*
-		 * PTE encoding used in Linux:
+		 * PAT support with the lower four entries. Intel Pentium 2,
+		 * 3, M, and 4 are affected by PAT errata, which makes the
+		 * upper four entries unusable. To be on the safe side, we don't
+		 * use those.
+		 *
+		 *  PTE encoding:
 		 *      PAT
 		 *      |PCD
-		 *      ||PWT
-		 *      |||
-		 *      000 WB          _PAGE_CACHE_WB
-		 *      001 WC          _PAGE_CACHE_WC
-		 *      010 UC-         _PAGE_CACHE_UC_MINUS
-		 *      011 UC          _PAGE_CACHE_UC
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
+		 * Full PAT support.  We put WT in slot 7 to improve
+		 * robustness in the presence of errata that might cause
+		 * the high PAT bit to be ignored.  This way, a buggy slot 7
+		 * access will hit slot 3, and slot 3 is UC, so at worst
+		 * we lose performance without causing a correctness issue.
+		 * Pentium 4 erratum N46 is an example for such an erratum,
+		 * although we try not to use PAT at all on affected CPUs.
+		 *
+		 *  PTE encoding:
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
 
 	if (!boot_cpu_done) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
