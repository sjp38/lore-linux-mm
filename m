Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72E936B0268
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:38 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id z142so810504itc.6
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:38 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id y81si37828iod.179.2017.12.05.04.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:37 -0800 (PST)
Message-Id: <20171205123820.185021296@infradead.org>
Date: Tue, 05 Dec 2017 13:34:51 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 6/9] x86/microcode: Dont abuse the tlbflush interface
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-cleanup.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, hpa@zytor.com, fenghua.yu@intel.com

Commit ec400ddeff20 ("x86/microcode_intel_early.c: Early update ucode
on Intel's CPU") grubbed into tlbflush internals without coherent
explanation.

Since it says its precaution and the SDM doesn't mention anything like
this, take it out back.

Cc: hpa@zytor.com
Cc: fenghua.yu@intel.com
Cc: bp@alien8.de
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h       |   19 ++++++-------------
 arch/x86/kernel/cpu/microcode/intel.c |   13 -------------
 2 files changed, 6 insertions(+), 26 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -394,20 +394,9 @@ static inline void __native_flush_tlb(vo
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
@@ -427,7 +416,11 @@ static inline void __native_flush_tlb_gl
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
