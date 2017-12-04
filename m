Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7227B6B0273
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:18 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c9so9936276wrb.4
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:18 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id j18si5316783wmi.233.2017.12.04.08.52.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:17 -0800 (PST)
Message-Id: <20171204150608.921681380@linutronix.de>
Date: Mon, 04 Dec 2017 15:07:56 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 50/60] x86/mm: Put MMU to hardware ASID translation in one
 place
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm--Put_MMU-to-h-w_ASID_translation_in_one_place.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

There are effectively two ASID types:

 1. The one stored in the mmu_context that goes from 0..5
 2. The one programmed into the hardware that goes from 1..6

This consolidates the locations where converting between the two (by doing
a +1) to a single place which gives us a nice place to comment.
KERNEL_PAGE_TABLE_ISOLATION will also need to, given an ASID, know which
hardware ASID to flush for the userspace mapping.

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
Link: https://lkml.kernel.org/r/20171123003506.67E81D7F@viggo.jf.intel.com

---
 arch/x86/include/asm/tlbflush.h |   29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -91,20 +91,26 @@ static inline u64 inc_mm_tlb_gen(struct
  */
 #define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_ASID_BITS) - 2)
 
-/*
- * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID bits.
- * This serves two purposes.  It prevents a nasty situation in which
- * PCID-unaware code saves CR3, loads some other value (with PCID == 0),
- * and then restores CR3, thus corrupting the TLB for ASID 0 if the saved
- * ASID was nonzero.  It also means that any bugs involving loading a
- * PCID-enabled CR3 with CR4.PCIDE off will trigger deterministically.
- */
+static inline u16 kern_pcid(u16 asid)
+{
+	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
+	/*
+	 * If PCID is on, ASID-aware code paths put the ASID+1 into the
+	 * PCID bits.  This serves two purposes.  It prevents a nasty
+	 * situation in which PCID-unaware code saves CR3, loads some other
+	 * value (with PCID == 0), and then restores CR3, thus corrupting
+	 * the TLB for ASID 0 if the saved ASID was nonzero.  It also means
+	 * that any bugs involving loading a PCID-enabled CR3 with
+	 * CR4.PCIDE off will trigger deterministically.
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
+		return __sme_pa(pgd) | kern_pcid(asid);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
 		return __sme_pa(pgd);
@@ -114,7 +120,8 @@ static inline unsigned long build_cr3(pg
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
 	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
-	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
+	VM_WARN_ON_ONCE(!this_cpu_has(X86_FEATURE_PCID));
+	return __sme_pa(pgd) | kern_pcid(asid) | CR3_NOFLUSH;
 }
 
 #ifdef CONFIG_PARAVIRT


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
