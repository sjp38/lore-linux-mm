Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5C26B0284
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 19:36:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id q84so15762841pfl.12
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:36:12 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b6si1365002pgt.534.2017.11.22.16.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 16:36:11 -0800 (PST)
Subject: [PATCH 14/23] x86, mm: remove hard-coded ASID limit checks
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 22 Nov 2017 16:35:04 -0800
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
In-Reply-To: <20171123003438.48A0EEDE@viggo.jf.intel.com>
Message-Id: <20171123003504.57EDB845@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

First, it's nice to remove the magic numbers.

Second, KAISER is going to consume half of the available ASID
space.  The space is currently unused, but add a comment to spell
out this new restriction.

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

 b/arch/x86/include/asm/tlbflush.h |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-asids-macros arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-asids-macros	2017-11-22 15:45:51.814619732 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-22 15:45:51.818619732 -0800
@@ -75,6 +75,19 @@ static inline u64 inc_mm_tlb_gen(struct
 	return new_tlb_gen;
 }
 
+/* There are 12 bits of space for ASIDS in CR3 */
+#define CR3_HW_ASID_BITS 12
+/* When enabled, KAISER consumes a single bit for user/kernel switches */
+#define KAISER_CONSUMED_ASID_BITS 0
+
+#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS - KAISER_CONSUMED_ASID_BITS)
+/*
+ * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below
+ * to account for them being zero-based.  Another -1 is because ASID 0
+ * is reserved for use by non-PCID-aware users.
+ */
+#define MAX_ASID_AVAILABLE ((1<<CR3_AVAIL_ASID_BITS) - 2)
+
 /*
  * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
  * bits.  This serves two purposes.  It prevents a nasty situation in
@@ -88,7 +101,7 @@ struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
+		VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 		return __sme_pa(pgd) | (asid + 1);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
@@ -98,7 +111,7 @@ static inline unsigned long build_cr3(pg
 
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
-	VM_WARN_ON_ONCE(asid > 4094);
+	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
