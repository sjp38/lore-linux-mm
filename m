Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 617A56B0277
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h12so10366308wre.12
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:24 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d24si10725593wrc.272.2017.12.04.08.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:23 -0800 (PST)
Message-Id: <20171204150608.834570507@linutronix.de>
Date: Mon, 04 Dec 2017 15:07:55 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 49/60] x86/mm: Remove hard-coded ASID limit checks
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm--Remove_hard-coded_ASID_limit_checks.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

First, it's nice to remove the magic numbers.

Second, KERNEL_PAGE_TABLE_ISOLATION is going to consume half of the
available ASID space.  The space is currently unused, but add a comment to
spell out this new restriction.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: keescook@google.com
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: moritz.lipp@iaik.tugraz.at
Cc: linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: hughd@google.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: michael.schwarz@iaik.tugraz.at
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: richard.fellner@student.tugraz.at
Link: https://lkml.kernel.org/r/20171123003504.57EDB845@viggo.jf.intel.com

---
 arch/x86/include/asm/tlbflush.h |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -75,6 +75,22 @@ static inline u64 inc_mm_tlb_gen(struct
 	return new_tlb_gen;
 }
 
+/* There are 12 bits of space for ASIDS in CR3 */
+#define CR3_HW_ASID_BITS		12
+/*
+ * When enabled, KERNEL_PAGE_TABLE_ISOLATION consumes a single bit for
+ * user/kernel switches
+ */
+#define KPTI_CONSUMED_ASID_BITS		0
+
+#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS - KPTI_CONSUMED_ASID_BITS)
+/*
+ * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below to account
+ * for them being zero-based.  Another -1 is because ASID 0 is reserved for
+ * use by non-PCID-aware users.
+ */
+#define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_ASID_BITS) - 2)
+
 /*
  * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID bits.
  * This serves two purposes.  It prevents a nasty situation in which
@@ -87,7 +103,7 @@ struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
+		VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 		return __sme_pa(pgd) | (asid + 1);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
@@ -97,7 +113,7 @@ static inline unsigned long build_cr3(pg
 
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
-	VM_WARN_ON_ONCE(asid > 4094);
+	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
