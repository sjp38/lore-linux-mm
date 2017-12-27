Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDE956B026F
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id d7so1498208wre.15
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r11si15725569wra.438.2017.12.27.08.48.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:36 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 27/74] x86/mm: Put MMU to hardware ASID translation in one place
Date: Wed, 27 Dec 2017 17:46:00 +0100
Message-Id: <20171227164615.182204914@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit dd95f1a4b5ca904c78e6a097091eb21436478abb upstream.

There are effectively two ASID types:

 1. The one stored in the mmu_context that goes from 0..5
 2. The one programmed into the hardware that goes from 1..6

This consolidates the locations where converting between the two (by doing
a +1) to a single place which gives us a nice place to comment.
PAGE_TABLE_ISOLATION will also need to, given an ASID, know which hardware
ASID to flush for the userspace mapping.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |   29 ++++++++++++++++++-----------
 1 file changed, 18 insertions(+), 11 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -85,20 +85,26 @@ static inline u64 inc_mm_tlb_gen(struct
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
@@ -108,7 +114,8 @@ static inline unsigned long build_cr3(pg
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
