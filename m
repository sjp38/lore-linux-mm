Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 408106B0270
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:52:17 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id w95so10634490wrc.20
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:52:17 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k14si10496899wre.228.2017.12.04.08.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:52:16 -0800 (PST)
Message-Id: <20171204150608.754046147@linutronix.de>
Date: Mon, 04 Dec 2017 15:07:54 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 48/60] x86/mm: Move the CR3 construction functions to
 tlbflush.h
References: <20171204140706.296109558@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=x86-mm--Move_the_CR3_construction_functions_to_tlbflush.h.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

From: Dave Hansen <dave.hansen@linux.intel.com>

For flushing the TLB, the ASID which has been programmed into the hardware
must be known.  That differs from what is in 'cpu_tlbstate'.

Add functions to transform the 'cpu_tlbstate' values into to the one
programmed into the hardware (CR3).

It's not easy to include mmu_context.h into tlbflush.h, so just move
the CR3 building over to tlbflush.h.

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
Link: https://lkml.kernel.org/r/20171123003502.CC87BF47@viggo.jf.intel.com

---
 arch/x86/include/asm/mmu_context.h |   29 +----------------------------
 arch/x86/include/asm/tlbflush.h    |   26 ++++++++++++++++++++++++++
 arch/x86/mm/tlb.c                  |    8 ++++----
 3 files changed, 31 insertions(+), 32 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -260,33 +260,6 @@ static inline bool arch_vma_access_permi
 }
 
 /*
- * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
- * bits.  This serves two purposes.  It prevents a nasty situation in
- * which PCID-unaware code saves CR3, loads some other value (with PCID
- * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
- * the saved ASID was nonzero.  It also means that any bugs involving
- * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
- * deterministically.
- */
-
-static inline unsigned long build_cr3(struct mm_struct *mm, u16 asid)
-{
-	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
-		return __sme_pa(mm->pgd) | (asid + 1);
-	} else {
-		VM_WARN_ON_ONCE(asid != 0);
-		return __sme_pa(mm->pgd);
-	}
-}
-
-static inline unsigned long build_cr3_noflush(struct mm_struct *mm, u16 asid)
-{
-	VM_WARN_ON_ONCE(asid > 4094);
-	return __sme_pa(mm->pgd) | (asid + 1) | CR3_NOFLUSH;
-}
-
-/*
  * This can be used from process context to figure out what the value of
  * CR3 is without needing to do a (slow) __read_cr3().
  *
@@ -295,7 +268,7 @@ static inline unsigned long build_cr3_no
  */
 static inline unsigned long __get_current_cr3_fast(void)
 {
-	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm),
+	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
 		this_cpu_read(cpu_tlbstate.loaded_mm_asid));
 
 	/* For now, be very restrictive about when this can be called. */
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -75,6 +75,32 @@ static inline u64 inc_mm_tlb_gen(struct
 	return new_tlb_gen;
 }
 
+/*
+ * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID bits.
+ * This serves two purposes.  It prevents a nasty situation in which
+ * PCID-unaware code saves CR3, loads some other value (with PCID == 0),
+ * and then restores CR3, thus corrupting the TLB for ASID 0 if the saved
+ * ASID was nonzero.  It also means that any bugs involving loading a
+ * PCID-enabled CR3 with CR4.PCIDE off will trigger deterministically.
+ */
+struct pgd_t;
+static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
+{
+	if (static_cpu_has(X86_FEATURE_PCID)) {
+		VM_WARN_ON_ONCE(asid > 4094);
+		return __sme_pa(pgd) | (asid + 1);
+	} else {
+		VM_WARN_ON_ONCE(asid != 0);
+		return __sme_pa(pgd);
+	}
+}
+
+static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
+{
+	VM_WARN_ON_ONCE(asid > 4094);
+	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
+}
+
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -128,7 +128,7 @@ void switch_mm_irqs_off(struct mm_struct
 	 * isn't free.
 	 */
 #ifdef CONFIG_DEBUG_VM
-	if (WARN_ON_ONCE(__read_cr3() != build_cr3(real_prev, prev_asid))) {
+	if (WARN_ON_ONCE(__read_cr3() != build_cr3(real_prev->pgd, prev_asid))) {
 		/*
 		 * If we were to BUG here, we'd be very likely to kill
 		 * the system so hard that we don't see the call trace.
@@ -195,7 +195,7 @@ void switch_mm_irqs_off(struct mm_struct
 		if (need_flush) {
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
-			write_cr3(build_cr3(next, new_asid));
+			write_cr3(build_cr3(next->pgd, new_asid));
 
 			/*
 			 * NB: This gets called via leave_mm() in the idle path
@@ -208,7 +208,7 @@ void switch_mm_irqs_off(struct mm_struct
 			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 		} else {
 			/* The new ASID is already up to date. */
-			write_cr3(build_cr3_noflush(next, new_asid));
+			write_cr3(build_cr3_noflush(next->pgd, new_asid));
 
 			/* See above wrt _rcuidle. */
 			trace_tlb_flush_rcuidle(TLB_FLUSH_ON_TASK_SWITCH, 0);
@@ -288,7 +288,7 @@ void initialize_tlbstate_and_flush(void)
 		!(cr4_read_shadow() & X86_CR4_PCIDE));
 
 	/* Force ASID 0 and force a TLB flush. */
-	write_cr3(build_cr3(mm, 0));
+	write_cr3(build_cr3(mm->pgd, 0));
 
 	/* Reinitialize tlbstate. */
 	this_cpu_write(cpu_tlbstate.loaded_mm_asid, 0);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
