Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4A54403E0
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 16:38:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so5614703wmc.6
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 13:38:42 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g70si6616720wmc.179.2017.12.16.13.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 13:38:41 -0800 (PST)
Message-Id: <20171216213137.560512708@linutronix.de>
Date: Sat, 16 Dec 2017 22:24:08 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V149 14/50] x86/mm: Clarify which functions are supposed to
 flush what
References: <20171216212354.120930222@linutronix.de>
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
@@ -231,6 +231,9 @@ static inline void cr4_set_bits_and_upda
 
 extern void initialize_tlbstate_and_flush(void);
 
+/*
+ * flush the entire current user mapping
+ */
 static inline void __native_flush_tlb(void)
 {
 	/*
@@ -243,6 +246,9 @@ static inline void __native_flush_tlb(vo
 	preempt_enable();
 }
 
+/*
+ * flush everything
+ */
 static inline void __native_flush_tlb_global(void)
 {
 	unsigned long cr4, flags;
@@ -272,17 +278,27 @@ static inline void __native_flush_tlb_gl
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
@@ -293,6 +309,9 @@ static inline void __flush_tlb_all(void)
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
