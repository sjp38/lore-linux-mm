Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A737440D2B
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 14:32:08 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s28so3066353pfg.6
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 11:32:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v61si9705727plb.248.2017.11.10.11.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 11:32:07 -0800 (PST)
Subject: [PATCH 22/30] x86, pcid, kaiser: allow flushing for future ASID switches
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 10 Nov 2017 11:31:48 -0800
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
In-Reply-To: <20171110193058.BECA7D88@viggo.jf.intel.com>
Message-Id: <20171110193148.DE946DEC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

If changing the page tables in such a way that an invalidation of
all contexts (aka. PCIDs / ASIDs) is required, they can be
actively invalidated by:

 1. INVPCID for each PCID (works for single pages too).
 2. Load CR3 with each PCID without the NOFLUSH bit set
 3. Load CR3 with the NOFLUSH bit set for each and do
    INVLPG for each address.

But, none of these are really feasible since there are ~6 ASIDs (12 with
KAISER) at the time that invalidation is required.  Instead of
actively invalidating them, invalidate the *current* context and
also mark the cpu_tlbstate _quickly_ to indicate future invalidation
to be required.

At the next context-switch, look for this indicator
('all_other_ctxs_invalid' being set) invalidate all of the
cpu_tlbstate.ctxs[] entries.

This ensures that any future context switches will do a full flush
of the TLB, picking up the previous changes.

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

 b/arch/x86/include/asm/tlbflush.h |   47 +++++++++++++++++++++++++++++---------
 b/arch/x86/mm/tlb.c               |   35 ++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+), 10 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-clear-pcid-cache arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-clear-pcid-cache	2017-11-10 11:22:17.055244930 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-10 11:22:17.060244930 -0800
@@ -184,6 +184,17 @@ struct tlb_state {
 	bool is_lazy;
 
 	/*
+	 * If set we changed the page tables in such a way that we
+	 * needed an invalidation of all contexts (aka. PCIDs / ASIDs).
+	 * This tells us to go invalidate all the non-loaded ctxs[]
+	 * on the next context switch.
+	 *
+	 * The current ctx was kept up-to-date as it ran and does not
+	 * need to be invalidated.
+	 */
+	bool all_other_ctxs_invalid;
+
+	/*
 	 * Access to this CR4 shadow and to H/W CR4 is protected by
 	 * disabling interrupts when modifying either one.
 	 */
@@ -260,6 +271,19 @@ static inline unsigned long cr4_read_sha
 	return this_cpu_read(cpu_tlbstate.cr4);
 }
 
+static inline void tlb_flush_shared_nonglobals(void)
+{
+	/*
+	 * With global pages, all of the shared kenel page tables
+	 * are set as _PAGE_GLOBAL.  We have no shared nonglobals
+	 * and nothing to do here.
+	 */
+	if (IS_ENABLED(CONFIG_X86_GLOBAL_PAGES))
+		return;
+
+	this_cpu_write(cpu_tlbstate.all_other_ctxs_invalid, true);
+}
+
 /*
  * Save some of cr4 feature set we're using (e.g.  Pentium 4MB
  * enable and PPro Global page enable), so that any CPU's that boot
@@ -289,6 +313,10 @@ static inline void __native_flush_tlb(vo
 	preempt_disable();
 	native_write_cr3(__native_read_cr3());
 	preempt_enable();
+	/*
+	 * Does not need tlb_flush_shared_nonglobals() since the CR3 write
+	 * without PCIDs flushes all non-globals.
+	 */
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
@@ -348,24 +376,23 @@ static inline void __native_flush_tlb_si
 
 static inline void __flush_tlb_all(void)
 {
-	if (boot_cpu_has(X86_FEATURE_PGE))
+	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		__flush_tlb_global();
-	else
+	} else {
 		__flush_tlb();
-
-	/*
-	 * Note: if we somehow had PCID but not PGE, then this wouldn't work --
-	 * we'd end up flushing kernel translations for the current ASID but
-	 * we might fail to flush kernel translations for other cached ASIDs.
-	 *
-	 * To avoid this issue, we force PCID off if PGE is off.
-	 */
+		tlb_flush_shared_nonglobals();
+	}
 }
 
 static inline void __flush_tlb_one(unsigned long addr)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__flush_tlb_single(addr);
+	/*
+	 * Invalidate other address spaces inaccessible to single-page
+	 * invalidation:
+	 */
+	tlb_flush_shared_nonglobals();
 }
 
 #define TLB_FLUSH_ALL	-1UL
diff -puN arch/x86/mm/tlb.c~kaiser-pcid-pre-clear-pcid-cache arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~kaiser-pcid-pre-clear-pcid-cache	2017-11-10 11:22:17.057244930 -0800
+++ b/arch/x86/mm/tlb.c	2017-11-10 11:22:17.060244930 -0800
@@ -28,6 +28,38 @@
  *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
  */
 
+/*
+ * We get here when we do something requiring a TLB invalidation
+ * but could not go invalidate all of the contexts.  We do the
+ * necessary invalidation by clearing out the 'ctx_id' which
+ * forces a TLB flush when the context is loaded.
+ */
+void clear_non_loaded_ctxs(void)
+{
+	u16 asid;
+
+	/*
+	 * This is only expected to be set if we have disabled
+	 * kernel _PAGE_GLOBAL pages.
+	 */
+	if (IS_ENABLED(CONFIG_X86_GLOBAL_PAGES)) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
+		/* Do not need to flush the current asid */
+		if (asid == this_cpu_read(cpu_tlbstate.loaded_mm_asid))
+			continue;
+		/*
+		 * Make sure the next time we go to switch to
+		 * this asid, we do a flush:
+		 */
+		this_cpu_write(cpu_tlbstate.ctxs[asid].ctx_id, 0);
+	}
+	this_cpu_write(cpu_tlbstate.all_other_ctxs_invalid, false);
+}
+
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
 
 
@@ -42,6 +74,9 @@ static void choose_new_asid(struct mm_st
 		return;
 	}
 
+	if (this_cpu_read(cpu_tlbstate.all_other_ctxs_invalid))
+		clear_non_loaded_ctxs();
+
 	for (asid = 0; asid < TLB_NR_DYN_ASIDS; asid++) {
 		if (this_cpu_read(cpu_tlbstate.ctxs[asid].ctx_id) !=
 		    next->context.ctx_id)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
