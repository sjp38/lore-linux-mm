Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3CC6B0260
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 05:35:57 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id n42so2451167ioe.12
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 02:35:57 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s6si1011791ioe.247.2017.11.29.02.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 02:35:56 -0800 (PST)
Message-Id: <20171129103512.819130098@infradead.org>
Date: Wed, 29 Nov 2017 11:33:05 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 4/6] x86/mm/kaiser: Support PCID without INVPCID
References: <20171129103301.131535445@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-kaiser-support-pcid-noinvpcid.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andy Lutomirski <luto@amacapital.net>

Instead of relying on INVPCID to shoot down user PCID, delay the
invalidate until we switch to the user page-tables.

This gets rid of the INVPCID dependence for KAISER PCID.

XXX we could do a much larger ALTERNATIVE, there is no point in
testing the mask if we don't have PCID support.

Suggested-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/entry/calling.h        |   29 +++++++++++++++++------
 arch/x86/include/asm/tlbflush.h |   39 +++++++++++++++++++++++--------
 arch/x86/mm/init.c              |   13 ----------
 arch/x86/mm/tlb.c               |   49 +---------------------------------------
 4 files changed, 53 insertions(+), 77 deletions(-)

--- a/arch/x86/entry/calling.h
+++ b/arch/x86/entry/calling.h
@@ -4,6 +4,7 @@
 #include <asm/cpufeatures.h>
 #include <asm/page_types.h>
 #include <asm/pgtable_types.h>
+#include <asm/percpu.h>
 
 /*
 
@@ -203,12 +204,6 @@ For 32-bit we have the following convent
 	andq    $(~KAISER_SWITCH_MASK), \reg
 .endm
 
-.macro ADJUST_USER_CR3 reg:req
-	ALTERNATIVE "", "bts $63, \reg", X86_FEATURE_PCID
-	/* Set user PCID bit, and move CR3 up a page to the user page tables: */
-	orq     $(KAISER_SWITCH_MASK), \reg
-.endm
-
 .macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
 	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	mov	%cr3, \scratch_reg
@@ -220,7 +215,27 @@ For 32-bit we have the following convent
 .macro SWITCH_TO_USER_CR3 scratch_reg:req
 	STATIC_JUMP_IF_FALSE .Lend_\@, kaiser_enabled_key, def=1
 	mov	%cr3, \scratch_reg
-	ADJUST_USER_CR3 \scratch_reg
+
+	/*
+	 * Test if the ASID needs a flush.
+	 */
+	push	\scratch_reg			/* preserve CR3 */
+	andq	$(0x7FF), \scratch_reg		/* mask ASID */
+	bt	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
+	jnc	.Lnoflush_\@
+
+	/* Flush needed, clear the bit */
+	btr	\scratch_reg, PER_CPU_VAR(user_asid_flush_mask)
+	pop	\scratch_reg			/* original CR3 */
+	jmp	.Ldo_\@
+
+.Lnoflush_\@:
+	pop	\scratch_reg			/* original CR3 */
+	ALTERNATIVE "", "bts $63, \scratch_reg", X86_FEATURE_PCID
+
+.Ldo_\@:
+	/* Flip the PGD and ASID to the user version */
+	orq     $(KAISER_SWITCH_MASK), \scratch_reg
 	mov	\scratch_reg, %cr3
 .Lend_\@:
 .endm
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -348,19 +348,37 @@ static inline void cr4_set_bits_and_upda
 
 extern void initialize_tlbstate_and_flush(void);
 
+DECLARE_PER_CPU(unsigned long, user_asid_flush_mask);
+
+/*
+ * Given an ASID, flush the corresponding user ASID.
+ * We can delay this until the next time we switch to it.
+ *
+ * See SWITCH_TO_USER_CR3.
+ */
+static inline void flush_user_asid(u16 asid)
+{
+	/* There is no user ASID if KAISER is off */
+	if (!IS_ENABLED(CONFIG_KAISER))
+		return;
+
+	/*
+	 * We only have a single ASID if PCID is off and the CR3
+	 * write will have flushed it.
+	 */
+	if (!cpu_feature_enabled(X86_FEATURE_PCID))
+		return;
+
+	if (!kaiser_enabled)
+		return;
+
+	__set_bit(kern_asid(asid), this_cpu_ptr(&user_asid_flush_mask));
+}
+
 static inline void __native_flush_tlb(void)
 {
 	if (!cpu_feature_enabled(X86_FEATURE_INVPCID)) {
-		/*
-		 * native_write_cr3() only clears the current PCID if
-		 * CR4 has X86_CR4_PCIDE set.  In other words, this does
-		 * not fully flush the TLB if PCIDs are in use.
-		 *
-		 * With KAISER and PCIDs, that means that we did not
-		 * flush the user PCID.  Warn if it gets called.
-		 */
-		if (IS_ENABLED(CONFIG_KAISER) && kaiser_enabled)
-			WARN_ON_ONCE(this_cpu_read(cpu_tlbstate.cr4) & X86_CR4_PCIDE);
+		flush_user_asid(this_cpu_read(cpu_tlbstate.loaded_mm_asid));
 
 		/*
 		 * If current->mm == NULL then we borrow a mm
@@ -436,6 +454,7 @@ static inline void __native_flush_tlb_si
 	 * early.
 	 */
 	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
+		flush_user_asid(loaded_mm_asid);
 		asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
 		return;
 	}
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -211,19 +211,6 @@ static void setup_pcid(void)
 
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		/*
-		 * KAISER uses a PCID for the kernel and another
-		 * for userspace.  Both PCIDs need to be flushed
-		 * when the TLB flush functions are called.  But,
-		 * flushing *another* PCID is insane without
-		 * INVPCID.  Just avoid using PCIDs at all if we
-		 * have KAISER and do not have INVPCID.
-		 */
-		if (!IS_ENABLED(CONFIG_X86_GLOBAL_PAGES) &&
-		    kaiser_enabled && !boot_cpu_has(X86_FEATURE_INVPCID)) {
-			setup_clear_cpu_cap(X86_FEATURE_PCID);
-			return;
-		}
-		/*
 		 * This can't be cr4_set_bits_and_update_boot() --
 		 * the trampoline code can't handle CR4.PCIDE and
 		 * it wouldn't do any good anyway.  Despite the name,
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -101,59 +101,14 @@ static void choose_new_asid(struct mm_st
 	*need_flush = true;
 }
 
-/*
- * Given a kernel asid, flush the corresponding KAISER
- * user ASID.
- */
-static void flush_user_asid(pgd_t *pgd, u16 kern_asid)
-{
-	/* There is no user ASID if KAISER is off */
-	if (!IS_ENABLED(CONFIG_KAISER))
-		return;
-	/*
-	 * We only have a single ASID if PCID is off and the CR3
-	 * write will have flushed it.
-	 */
-	if (!cpu_feature_enabled(X86_FEATURE_PCID))
-		return;
-
-	if (!kaiser_enabled)
-		return;
-
-	/*
-	 * With PCIDs enabled, write_cr3() only flushes TLB
-	 * entries for the current (kernel) ASID.  This leaves
-	 * old TLB entries for the user ASID in place and we must
-	 * flush that context separately.  We can theoretically
-	 * delay doing this until we actually load up the
-	 * userspace CR3, but do it here for simplicity.
-	 */
-	if (cpu_feature_enabled(X86_FEATURE_INVPCID)) {
-		invpcid_flush_single_context(user_asid(kern_asid));
-	} else {
-		/*
-		 * On systems with PCIDs, but no INVPCID, the only
-		 * way to flush a PCID is a CR3 write.  Note that
-		 * we use the kernel page tables with the *user*
-		 * ASID here.
-		 */
-		unsigned long user_asid_flush_cr3;
-		user_asid_flush_cr3 = build_cr3(pgd, user_asid(kern_asid));
-		write_cr3(user_asid_flush_cr3);
-		/*
-		 * We do not use PCIDs with KAISER unless we also
-		 * have INVPCID.  Getting here is unexpected.
-		 */
-		WARN_ON_ONCE(1);
-	}
-}
+__visible DEFINE_PER_CPU(unsigned long, user_asid_flush_mask);
 
 static void load_new_mm_cr3(pgd_t *pgdir, u16 new_asid, bool need_flush)
 {
 	unsigned long new_mm_cr3;
 
 	if (need_flush) {
-		flush_user_asid(pgdir, new_asid);
+		flush_user_asid(new_asid);
 		new_mm_cr3 = build_cr3(pgdir, new_asid);
 	} else {
 		new_mm_cr3 = build_cr3_noflush(pgdir, new_asid);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
