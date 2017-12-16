Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C201244040A
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:39:38 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id k126so5617196wmd.5
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:39:38 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g40si7339219wrd.475.2017.12.16.13.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:39:37 -0800 (PST)
Message-Id: <20171216213137.830714333@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:11 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 17/50] x86/mm: Put MMU to hardware ASID translation in
 one place
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0049-x86-mm-Put-MMU-to-hardware-ASID-translation-in-one-p.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

There are effectively two ASID types:

 1. The one stored in the mmu_context that goes from 0..5
 2. The one programmed into the hardware that goes from 1..6

This consolidates the locations where converting between the two (by doing
a +1) to a single place which gives us a nice place to comment.
PAGE_TABLE_ISOLATION will also need to, given an ASID, know which hardware
ASID to flush for the userspace mapping.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/include/asm/tlbflush.h | 29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 35da2b9871f1..5c945ee819fb 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -91,20 +91,26 @@ static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
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
@@ -114,7 +120,8 @@ static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
 	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
-	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
+	VM_WARN_ON_ONCE(!this_cpu_has(X86_FEATURE_PCID));
+	return __sme_pa(pgd) | kern_pcid(asid) | CR3_NOFLUSH;
 }
 
 #ifdef CONFIG_PARAVIRT
-- 
2.14.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
