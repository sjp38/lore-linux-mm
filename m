Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7B36B0253
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id r19so819801wrg.0
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e124si14014344wma.119.2017.12.27.08.48.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:18 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 21/74] x86/microcode: Dont abuse the TLB-flush interface
Date: Wed, 27 Dec 2017 17:45:54 +0100
Message-Id: <20171227164614.953361733@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, fenghua.yu@intel.com, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit 23cb7d46f371844c004784ad9552a57446f73e5a upstream.

Commit:

  ec400ddeff20 ("x86/microcode_intel_early.c: Early update ucode on Intel's CPU")

... grubbed into tlbflush internals without coherent explanation.

Since it says its a precaution and the SDM doesn't mention anything like
this, take it out back.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
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
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

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
