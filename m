Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9CFE6B0276
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:55:30 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l4so9300583wre.10
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:55:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t61si3309687wrc.53.2017.12.18.03.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 03:55:29 -0800 (PST)
Message-Id: <20171218115254.738037567@linutronix.de>
Date: Mon, 18 Dec 2017 12:42:29 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V163 14/51] x86/mm: Clarify which functions are supposed to
 flush what
References: <20171218114215.239543034@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0067-x86-mm-Clarify-which-functions-are-supposed-to-flush.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

Per popular request..

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/include/asm/tlbflush.h |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -228,6 +228,9 @@ static inline void cr4_set_bits_and_upda
 
 extern void initialize_tlbstate_and_flush(void);
 
+/*
+ * flush the entire current user mapping
+ */
 static inline void __native_flush_tlb(void)
 {
 	/*
@@ -240,6 +243,9 @@ static inline void __native_flush_tlb(vo
 	preempt_enable();
 }
 
+/*
+ * flush everything
+ */
 static inline void __native_flush_tlb_global(void)
 {
 	unsigned long cr4, flags;
@@ -269,17 +275,27 @@ static inline void __native_flush_tlb_gl
 	raw_local_irq_restore(flags);
 }
 
+/*
+ * flush one page in the user mapping
+ */
 static inline void __native_flush_tlb_single(unsigned long addr)
 {
 	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
 }
 
+/*
+ * flush everything
+ */
 static inline void __flush_tlb_all(void)
 {
-	if (boot_cpu_has(X86_FEATURE_PGE))
+	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		__flush_tlb_global();
-	else
+	} else {
+		/*
+		 * !PGE -> !PCID (setup_pcid()), thus every flush is total.
+		 */
 		__flush_tlb();
+	}
 
 	/*
 	 * Note: if we somehow had PCID but not PGE, then this wouldn't work --
@@ -290,6 +306,9 @@ static inline void __flush_tlb_all(void)
 	 */
 }
 
+/*
+ * flush one page in the kernel mapping
+ */
 static inline void __flush_tlb_one(unsigned long addr)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
