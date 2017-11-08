Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCA36B02FD
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q126so3393014pgq.7
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:36 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id e22si1497139pgv.360.2017.11.08.11.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:35 -0800 (PST)
Subject: [PATCH 19/30] x86, mm: Move CR3 construction functions
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:22 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194722.C6A09337@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

For flushing the TLB, we need to know which ASID has been programmed
into the hardware.  Since that differs from what is in 'cpu_tlbstate',
we need to be able to transform the ASID in cpu_tlbstate to the one
programmed into the hardware.

It's not easy to include mmu_context.h into tlbflush.h, so just move
the CR3 building over to tlbflush.h.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/mmu_context.h |   29 +----------------------------
 b/arch/x86/include/asm/tlbflush.h    |   27 +++++++++++++++++++++++++++
 b/arch/x86/mm/tlb.c                  |    8 ++++----
 3 files changed, 32 insertions(+), 32 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~kaiser-pcid-pre-build-func-move arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~kaiser-pcid-pre-build-func-move	2017-11-08 10:45:36.197681378 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2017-11-08 10:45:36.205681378 -0800
@@ -281,33 +281,6 @@ static inline bool arch_vma_access_permi
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
@@ -316,7 +289,7 @@ static inline unsigned long build_cr3_no
  */
 static inline unsigned long __get_current_cr3_fast(void)
 {
-	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm),
+	unsigned long cr3 = build_cr3(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd,
 		this_cpu_read(cpu_tlbstate.loaded_mm_asid));
 
 	/* For now, be very restrictive about when this can be called. */
diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-func-move arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-func-move	2017-11-08 10:45:36.199681378 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-08 10:45:36.205681378 -0800
@@ -74,6 +74,33 @@ static inline u64 inc_mm_tlb_gen(struct
 	return new_tlb_gen;
 }
 
+/*
+ * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
+ * bits.  This serves two purposes.  It prevents a nasty situation in
+ * which PCID-unaware code saves CR3, loads some other value (with PCID
+ * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
+ * the saved ASID was nonzero.  It also means that any bugs involving
+ * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
+ * deterministically.
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
diff -puN arch/x86/mm/tlb.c~kaiser-pcid-pre-build-func-move arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~kaiser-pcid-pre-build-func-move	2017-11-08 10:45:36.201681378 -0800
+++ b/arch/x86/mm/tlb.c	2017-11-08 10:45:36.206681378 -0800
@@ -127,7 +127,7 @@ void switch_mm_irqs_off(struct mm_struct
 	 * isn't free.
 	 */
 #ifdef CONFIG_DEBUG_VM
-	if (WARN_ON_ONCE(__read_cr3() != build_cr3(real_prev, prev_asid))) {
+	if (WARN_ON_ONCE(__read_cr3() != build_cr3(real_prev->pgd, prev_asid))) {
 		/*
 		 * If we were to BUG here, we'd be very likely to kill
 		 * the system so hard that we don't see the call trace.
@@ -194,12 +194,12 @@ void switch_mm_irqs_off(struct mm_struct
 		if (need_flush) {
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
-			write_cr3(build_cr3(next, new_asid));
+			write_cr3(build_cr3(next->pgd, new_asid));
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
 					TLB_FLUSH_ALL);
 		} else {
 			/* The new ASID is already up to date. */
-			write_cr3(build_cr3_noflush(next, new_asid));
+			write_cr3(build_cr3_noflush(next->pgd, new_asid));
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, 0);
 		}
 
@@ -277,7 +277,7 @@ void initialize_tlbstate_and_flush(void)
 		!(cr4_read_shadow() & X86_CR4_PCIDE));
 
 	/* Force ASID 0 and force a TLB flush. */
-	write_cr3(build_cr3(mm, 0));
+	write_cr3(build_cr3(mm->pgd, 0));
 
 	/* Reinitialize tlbstate. */
 	this_cpu_write(cpu_tlbstate.loaded_mm_asid, 0);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
