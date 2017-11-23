Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E321A6B0286
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:15 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 82so15862052pfp.5
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:15 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f66si16032162pfc.315.2017.11.22.16.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:14 -0800 (PST)
Subject: [PATCH 15/23] x86, mm: put mmu-to-h/w ASID translation in one place
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:06 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003506.67E81D7F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

There are effectively two ASID types:
1. The one stored in the mmu_context that goes from 0->5
2. The one programmed into the hardware that goes from 1->6

This consolidates the locations where converting beween the two
(by doing +1) to a single place which gives us a nice place to
comment.  KAISER will also need to, given an ASID, know which
hardware ASID to flush for the userspace mapping.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |   30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-kern arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-kern	2017-11-22 15:45:52.346619731 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-22 15:45:52.350619731 -0800
@@ -88,21 +88,26 @@ static inline u64 inc_mm_tlb_gen(struct
  */
 #define MAX_ASID_AVAILABLE ((1<<CR3_AVAIL_ASID_BITS) - 2)
 
-/*
- * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
- * bits.  This serves two purposes.  It prevents a nasty situation in
- * which PCID-unaware code saves CR3, loads some other value (with PCID
- * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
- * the saved ASID was nonzero.  It also means that any bugs involving
- * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
- * deterministically.
- */
+static inline u16 kern_asid(u16 asid)
+{
+	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
+	/*
+	 * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
+	 * bits.  This serves two purposes.  It prevents a nasty situation in
+	 * which PCID-unaware code saves CR3, loads some other value (with PCID
+	 * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
+	 * the saved ASID was nonzero.  It also means that any bugs involving
+	 * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
+	 * deterministically.
+	 */
+	return asid + 1;
+}
+
 struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
-		return __sme_pa(pgd) | (asid + 1);
+		return __sme_pa(pgd) | kern_asid(asid);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
 		return __sme_pa(pgd);
@@ -112,7 +117,8 @@ static inline unsigned long build_cr3(pg
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
 	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
-	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
+	VM_WARN_ON_ONCE(!this_cpu_has(X86_FEATURE_PCID));
+	return __sme_pa(pgd) | kern_asid(asid) | CR3_NOFLUSH;
 }
 
 #ifdef CONFIG_PARAVIRT
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
