Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 587A96B026B
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f132so8712813wmf.6
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y62si13206785wmc.40.2017.12.27.08.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:29 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 25/74] x86/mm: Move the CR3 construction functions to tlbflush.h
Date: Wed, 27 Dec 2017 17:45:58 +0100
Message-Id: <20171227164615.105174746@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit 50fb83a62cf472dc53ba23bd3f7bd6c1b2b3b53e upstream.

For flushing the TLB, the ASID which has been programmed into the hardware
must be known.  That differs from what is in 'cpu_tlbstate'.

Add functions to transform the 'cpu_tlbstate' values into to the one
programmed into the hardware (CR3).

It's not easy to include mmu_context.h into tlbflush.h, so just move the
CR3 building over to tlbflush.h.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
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
 arch/x86/include/asm/mmu_context.h |   29 +----------------------------
 arch/x86/include/asm/tlbflush.h    |   26 ++++++++++++++++++++++++++
 arch/x86/mm/tlb.c                  |    8 ++++----
 3 files changed, 31 insertions(+), 32 deletions(-)

--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -291,33 +291,6 @@ static inline bool arch_vma_access_permi
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
@@ -326,7 +299,7 @@ static inline unsigned long build_cr3_no
  */
 static inline unsigned long __get_current_cr3_fast(void)
 {
-	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm),
+	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
 		this_cpu_read(cpu_tlbstate.loaded_mm_asid));
 
 	/* For now, be very restrictive about when this can be called. */
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -69,6 +69,32 @@ static inline u64 inc_mm_tlb_gen(struct
 	return atomic64_inc_return(&mm->context.tlb_gen);
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
