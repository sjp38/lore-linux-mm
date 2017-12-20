Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0190E6B026D
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 16:58:40 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id o2so3046495wmf.2
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 13:58:39 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id d18si1597244wrc.469.2017.12.20.13.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 13:58:39 -0800 (PST)
Message-Id: <20171220215441.674358478@linutronix.de>
Date: Wed, 20 Dec 2017 22:35:16 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V181 13/54] x86/microcode: Dont abuse the tlbflush interface
References: <20171220213503.672610178@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0066-x86-microcode-Dont-abuse-the-tlbflush-interface.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, Vlastimil Babka <vbabka@suse.cz>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, fenghua.yu@intel.com, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

Commit: ec400ddeff20 ("x86/microcode_intel_early.c: Early update ucode on
Intel's CPU") grubbed into tlbflush internals without coherent explanation.

Since it says its precaution and the SDM doesn't mention anything like
this, take it out back.

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
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: fenghua.yu@intel.com
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/include/asm/tlbflush.h       |   19 ++++++-------------
 arch/x86/kernel/cpu/microcode/intel.c |   13 -------------
 2 files changed, 6 insertions(+), 26 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -246,20 +246,9 @@ static inline void __native_flush_tlb(vo
 	preempt_enable();
 }
 
-static inline void __native_flush_tlb_global_irq_disabled(void)
-{
-	unsigned long cr4;
-
-	cr4 = this_cpu_read(cpu_tlbstate.cr4);
-	/* clear PGE */
-	native_write_cr4(cr4 & ~X86_CR4_PGE);
-	/* write old PGE again and flush TLBs */
-	native_write_cr4(cr4);
-}
-
 static inline void __native_flush_tlb_global(void)
 {
-	unsigned long flags;
+	unsigned long cr4, flags;
 
 	if (static_cpu_has(X86_FEATURE_INVPCID)) {
 		/*
@@ -277,7 +266,11 @@ static inline void __native_flush_tlb_gl
 	 */
 	raw_local_irq_save(flags);
 
-	__native_flush_tlb_global_irq_disabled();
+	cr4 = this_cpu_read(cpu_tlbstate.cr4);
+	/* toggle PGE */
+	native_write_cr4(cr4 ^ X86_CR4_PGE);
+	/* write old PGE again and flush TLBs */
+	native_write_cr4(cr4);
 
 	raw_local_irq_restore(flags);
 }
--- a/arch/x86/kernel/cpu/microcode/intel.c
+++ b/arch/x86/kernel/cpu/microcode/intel.c
@@ -565,15 +565,6 @@ static void print_ucode(struct ucode_cpu
 }
 #else
 
-/*
- * Flush global tlb. We only do this in x86_64 where paging has been enabled
- * already and PGE should be enabled as well.
- */
-static inline void flush_tlb_early(void)
-{
-	__native_flush_tlb_global_irq_disabled();
-}
-
 static inline void print_ucode(struct ucode_cpu_info *uci)
 {
 	struct microcode_intel *mc;
@@ -602,10 +593,6 @@ static int apply_microcode_early(struct
 	if (rev != mc->hdr.rev)
 		return -1;
 
-#ifdef CONFIG_X86_64
-	/* Flush global tlb. This is precaution. */
-	flush_tlb_early();
-#endif
 	uci->cpu_sig.rev = rev;
 
 	if (early)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
