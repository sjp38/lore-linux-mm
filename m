Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AB4204403E5
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:38:45 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id n21so78249wrb.11
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:38:45 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d200si6501037wmd.238.2017.12.16.13.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:38:44 -0800 (PST)
Message-Id: <20171216213137.750158822@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:10 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 16/50] x86/mm: Remove hard-coded ASID limit checks
References: <20171216212354.120930222@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0048-x86-mm-Remove-hard-coded-ASID-limit-checks.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Dave Hansen <dave.hansen@linux.intel.com>

First, it's nice to remove the magic numbers.

Second, PAGE_TABLE_ISOLATION is going to consume half of the available ASID
space.  The space is currently unused, but add a comment to spell out this
new restriction.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
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
 arch/x86/include/asm/tlbflush.h |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -69,6 +69,22 @@ static inline u64 inc_mm_tlb_gen(struct
 	return atomic64_inc_return(&mm->context.tlb_gen);
 }
 
+/* There are 12 bits of space for ASIDS in CR3 */
+#define CR3_HW_ASID_BITS		12
+/*
+ * When enabled, PAGE_TABLE_ISOLATION consumes a single bit for
+ * user/kernel switches
+ */
+#define PTI_CONSUMED_ASID_BITS		0
+
+#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS - PTI_CONSUMED_ASID_BITS)
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
@@ -81,7 +97,7 @@ struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
+		VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 		return __sme_pa(pgd) | (asid + 1);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
@@ -91,7 +107,7 @@ static inline unsigned long build_cr3(pg
 
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
