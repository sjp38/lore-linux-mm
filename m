Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDF36B0303
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z80so3022444pff.11
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:43 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t12si4490179pgn.395.2017.11.08.11.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:41 -0800 (PST)
Subject: [PATCH 23/30] x86, kaiser: use PCID feature to make user and kernel switches faster
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:30 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194730.213E131D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

Short summary: Use x86 PCID feature to avoid flushing the TLB at all
interrupts and syscalls.  Speed them up.  Makes context switches
and TLB flushing slower.

Background:

KAISER keeps two copies of the page tables.  We switch between them
with the the CR3 register.  But, CR3 was really designed for context
switches and changing it also flushes the entire TLB (modulo global
pages).  This TLB flush increases the cost of interrupts and context
switches.  For syscall-heavy microbenchmarks it can cut the rate of
syscalls by 2/3.

But, now we have suppport for and Intel CPU feature called Process
Context IDentifiers (PCID) in the kernel thanks to Andy Lutomirski.
This feature is intended to allow you to switch between contexts
without flushing the TLB.

Implementation:

We can use PCIDs to avoid flushing the TLB at kernel entry/exit.
This is speeds up both interrupts and syscalls.

We do this by assigning the kernel and userspace different ASIDs.  On
entry from userspace, we move over to the kernel page tables *and*
ASID.  On exit, we restore the user page tables and ASID.  Fortunately,
the ASID is programmed via CR3, which we are already using to switch
between the page table copies.  So, we get one-stop shopping.

In current kernels, CR3 is used to switch between processes which also
provides all the TLB flushing that we need at a context switch.  But,
with KAISER, that CR3 move only flushes the current (kernel) ASID.  We
need an extra TLB flushing operation to flush the user ASID: invpcid.
This is probably ~100 cycles, but this is done with the assumption that
the time we lose in context switches is more than made up for in
interrupts and syscalls.

Support:

PCIDs are generally available on Sandybridge and newer CPUs.  However,
the accompanying INVPCID instruction did not become available until
Haswell (the ones with "v4", or called fourth-generation Core).  This
instruction allows non-current-PCID TLB entries to be flushed without
switching CR3 and global pages to be flushed without a double
MOV-to-CR4.

Without INVPCID, PCIDs are much harder to use.  TLB invalidation gets
much more onerous:

1. Every kernel TLB flush (even for a single page) requires an
   interrupts-off MOV-to-CR4 which is very expensive.  This is because
   there is no way to flush a kernel address that might be loaded
   in *EVERY* PCID.  Right now, there are "only" ~12 of these per-cpu,
   but that's too painful to use the MOV-to-CR3 to flush them.  That
   leaves only the MOV-to-CR4.
2. Every userspace flush (even for a single page requires one of the
   following:
   a. A pair of flushing (bit 63 clear) CR3 writes: one for
      the kernel ASID and another for userspace.
   b. A pair of non-flushing CR3 writes (bit 63 set) with the
      flush done for each.  For instance, what is currently a
      single instruction without KAISER:

		invpcid_flush_one(current_pcid, addr);

      becomes this with KAISER:

      		invpcid_flush_one(current_kern_pcid, addr);
		invpcid_flush_one(current_user_pcid, addr);

      and this without INVPCID:

      		__native_flush_tlb_single(addr);
		write_cr3(mm->pgd | current_user_pcid | NOFLUSH);
      		__native_flush_tlb_single(addr);
		write_cr3(mm->pgd | current_kern_pcid | NOFLUSH);

So, for now, we fully disable PCIDs with KAISER when INVPCID is
not available.  This is fixable, but it's an optimization that
we can do later.

Hugh Dickins also points out that PCIDs really have two distinct
use-cases in the context of KAISER.  The first way they can be used
is as "TLB preservation across context-swtich", which is what
Andy Lutomirksi's 4.14 PCID code does.  They can also be used as
a "KAISER syscall/interrupt accelerator".  If we just use them to
speed up syscall/interrupts (and ignore the context-switch TLB
preservation), then the deficiency of not having INVPCID
becomes much less onerous.

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

 b/arch/x86/entry/calling.h                    |   25 +++-
 b/arch/x86/entry/entry_64.S                   |    1 
 b/arch/x86/include/asm/cpufeatures.h          |    1 
 b/arch/x86/include/asm/pgtable_types.h        |   11 ++
 b/arch/x86/include/asm/tlbflush.h             |  141 +++++++++++++++++++++-----
 b/arch/x86/include/uapi/asm/processor-flags.h |    3 
 b/arch/x86/kvm/x86.c                          |    3 
 b/arch/x86/mm/init.c                          |   75 +++++++++----
 b/arch/x86/mm/tlb.c                           |   66 +++++++++++-
 9 files changed, 264 insertions(+), 62 deletions(-)

diff -puN arch/x86/entry/calling.h~kaiser-pcid arch/x86/entry/calling.h
--- a/arch/x86/entry/calling.h~kaiser-pcid	2017-11-08 10:45:38.410681372 -0800
+++ b/arch/x86/entry/calling.h	2017-11-08 10:45:38.429681372 -0800
@@ -2,6 +2,7 @@
 #include <asm/unwind_hints.h>
 #include <asm/cpufeatures.h>
 #include <asm/page_types.h>
+#include <asm/pgtable_types.h>
 
 /*
 
@@ -191,16 +192,20 @@ For 32-bit we have the following convent
 #ifdef CONFIG_KAISER
 
 /* KAISER PGDs are 8k.  We flip bit 12 to switch between the two halves: */
-#define KAISER_SWITCH_MASK (1<<PAGE_SHIFT)
+#define KAISER_SWITCH_PGTABLES_MASK (1<<PAGE_SHIFT)
+#define KAISER_SWITCH_MASK     (KAISER_SWITCH_PGTABLES_MASK|\
+				(1<<X86_CR3_KAISER_SWITCH_BIT))
 
 .macro ADJUST_KERNEL_CR3 reg:req
-	/* Clear "KAISER bit", point CR3 at kernel pagetables: */
-	andq	$(~KAISER_SWITCH_MASK), \reg
+	ALTERNATIVE "", "bts $63, \reg", X86_FEATURE_PCID
+        /* Clear PCID and "KAISER bit", point CR3 at kernel pagetables: */
+	andq    $(~KAISER_SWITCH_MASK), \reg
 .endm
 
 .macro ADJUST_USER_CR3 reg:req
-	/* Move CR3 up a page to the user page tables: */
-	orq	$(KAISER_SWITCH_MASK), \reg
+	ALTERNATIVE "", "bts $63, \reg", X86_FEATURE_PCID
+	/* Set user PCID bit, and move CR3 up a page to the user page tables: */
+	orq     $(KAISER_SWITCH_MASK), \reg
 .endm
 
 .macro SWITCH_TO_KERNEL_CR3 scratch_reg:req
@@ -219,8 +224,14 @@ For 32-bit we have the following convent
 	movq	%cr3, %r\scratch_reg
 	movq	%r\scratch_reg, \save_reg
 	/*
-	 * Is the switch bit zero?  This means the address is
-	 * up in real KAISER patches in a moment.
+         * Is the "switch mask" all zero?  That means that both of
+	 * these are zero:
+	 *
+	 *     1. The user/kernel PCID bit, and
+	 *     2. The user/kernel "bit" that points CR3 to the
+	 *	  bottom half of the 8k PGD
+	 *
+	 * That indicates a kernel CR3 value, not user/shadow.
 	 */
 	testq	$(KAISER_SWITCH_MASK), %r\scratch_reg
 	jz	.Ldone_\@
diff -puN arch/x86/entry/entry_64.S~kaiser-pcid arch/x86/entry/entry_64.S
--- a/arch/x86/entry/entry_64.S~kaiser-pcid	2017-11-08 10:45:38.412681372 -0800
+++ b/arch/x86/entry/entry_64.S	2017-11-08 10:45:38.430681372 -0800
@@ -602,6 +602,7 @@ END(irq_entries_start)
 	 * tracking that we're in kernel mode.
 	 */
 	SWAPGS
+	SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
 
 	movq	%rsp, %rdi			/* pt_regs pointer */
 	call	sync_regs
diff -puN arch/x86/include/asm/cpufeatures.h~kaiser-pcid arch/x86/include/asm/cpufeatures.h
--- a/arch/x86/include/asm/cpufeatures.h~kaiser-pcid	2017-11-08 10:45:38.414681372 -0800
+++ b/arch/x86/include/asm/cpufeatures.h	2017-11-08 10:45:38.430681372 -0800
@@ -198,6 +198,7 @@
 #define X86_FEATURE_CAT_L3	( 7*32+ 4) /* Cache Allocation Technology L3 */
 #define X86_FEATURE_CAT_L2	( 7*32+ 5) /* Cache Allocation Technology L2 */
 #define X86_FEATURE_CDP_L3	( 7*32+ 6) /* Code and Data Prioritization L3 */
+#define X86_FEATURE_INVPCID_SINGLE ( 7*32+ 7) /* Effectively INVPCID && CR4.PCIDE=1 */
 
 #define X86_FEATURE_HW_PSTATE	( 7*32+ 8) /* AMD HW-PState */
 #define X86_FEATURE_PROC_FEEDBACK ( 7*32+ 9) /* AMD ProcFeedbackInterface */
diff -puN arch/x86/include/asm/pgtable_types.h~kaiser-pcid arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~kaiser-pcid	2017-11-08 10:45:38.416681372 -0800
+++ b/arch/x86/include/asm/pgtable_types.h	2017-11-08 10:45:38.430681372 -0800
@@ -139,6 +139,17 @@
 			 _PAGE_SOFT_DIRTY)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
+/* The ASID is the lower 12 bits of CR3 */
+#define X86_CR3_PCID_ASID_MASK  (_AC((1<<12)-1, UL))
+
+/* Mask for all the PCID-related bits in CR3: */
+#define X86_CR3_PCID_MASK       (X86_CR3_PCID_NOFLUSH | X86_CR3_PCID_ASID_MASK)
+
+/* Make sure this is only usable in KAISER #ifdef'd code: */
+#ifdef CONFIG_KAISER
+#define X86_CR3_KAISER_SWITCH_BIT 11
+#endif
+
 /*
  * The cache modes defined here are used to translate between pure SW usage
  * and the HW defined cache mode bits and/or PAT entries.
diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid	2017-11-08 10:45:38.418681372 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-08 10:45:38.431681372 -0800
@@ -77,7 +77,12 @@ static inline u64 inc_mm_tlb_gen(struct
 /* There are 12 bits of space for ASIDS in CR3 */
 #define CR3_HW_ASID_BITS 12
 /* When enabled, KAISER consumes a single bit for user/kernel switches */
+#ifdef CONFIG_KAISER
+#define X86_CR3_KAISER_SWITCH_BIT 11
+#define KAISER_CONSUMED_ASID_BITS 1
+#else
 #define KAISER_CONSUMED_ASID_BITS 0
+#endif
 
 #define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS-KAISER_CONSUMED_ASID_BITS)
 /*
@@ -86,21 +91,62 @@ static inline u64 inc_mm_tlb_gen(struct
  */
 #define NR_AVAIL_ASIDS ((1<<CR3_AVAIL_ASID_BITS) - 1)
 
+/*
+ * 6 because 6 should be plenty and struct tlb_state will fit in
+ * two cache lines.
+ */
+#define TLB_NR_DYN_ASIDS 6
+
 static inline u16 kern_asid(u16 asid)
 {
 	VM_WARN_ON_ONCE(asid >= NR_AVAIL_ASIDS);
+
+#ifdef CONFIG_KAISER
+	/*
+	 * Make sure that the dynamic ASID space does not confict
+	 * with the bit we are using to switch between user and
+	 * kernel ASIDs.
+	 */
+	BUILD_BUG_ON(TLB_NR_DYN_ASIDS >= (1<<X86_CR3_KAISER_SWITCH_BIT));
+
 	/*
-	 * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
-	 * bits.  This serves two purposes.  It prevents a nasty situation in
-	 * which PCID-unaware code saves CR3, loads some other value (with PCID
-	 * == 0), and then restores CR3, thus corrupting the TLB for ASID 0 if
-	 * the saved ASID was nonzero.  It also means that any bugs involving
-	 * loading a PCID-enabled CR3 with CR4.PCIDE off will trigger
-	 * deterministically.
+	 * The ASID being passed in here should have respected
+	 * the NR_AVAIL_ASIDS and thus never have the switch
+	 * bit set.
+	 */
+	VM_WARN_ON_ONCE(asid & (1<<X86_CR3_KAISER_SWITCH_BIT));
+#endif
+	/*
+	 * The dynamically-assigned ASIDs that get passed in  are
+	 * small (<TLB_NR_DYN_ASIDS).  They never have the high
+	 * switch bit set, so do not bother to clear it.
+	 */
+
+	/*
+	 * If PCID is on, ASID-aware code paths put the ASID+1
+	 * into the PCID bits.  This serves two purposes.  It
+	 * prevents a nasty situation in which PCID-unaware code
+	 * saves CR3, loads some other value (with PCID == 0),
+	 * and then restores CR3, thus corrupting the TLB for
+	 * ASID 0 if the saved ASID was nonzero.  It also means
+	 * that any bugs involving loading a PCID-enabled CR3
+	 * with CR4.PCIDE off will trigger deterministically.
 	 */
 	return asid + 1;
 }
 
+/*
+ * The user ASID is just the kernel one, plus the "switch bit".
+ */
+static inline u16 user_asid(u16 asid)
+{
+	u16 ret = kern_asid(asid);
+#ifdef CONFIG_KAISER
+	ret |= 1<<X86_CR3_KAISER_SWITCH_BIT;
+#endif
+	return ret;
+}
+
 struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
@@ -143,12 +189,6 @@ static inline bool tlb_defer_switch_to_i
 	return !static_cpu_has(X86_FEATURE_PCID);
 }
 
-/*
- * 6 because 6 should be plenty and struct tlb_state will fit in
- * two cache lines.
- */
-#define TLB_NR_DYN_ASIDS 6
-
 struct tlb_context {
 	u64 ctx_id;
 	u64 tlb_gen;
@@ -304,18 +344,42 @@ extern void initialize_tlbstate_and_flus
 
 static inline void __native_flush_tlb(void)
 {
-	/*
-	 * If current->mm == NULL then we borrow a mm which may change during a
-	 * task switch and therefore we must not be preempted while we write CR3
-	 * back:
-	 */
-	preempt_disable();
-	native_write_cr3(__native_read_cr3());
-	preempt_enable();
-	/*
-	 * Does not need tlb_flush_shared_nonglobals() since the CR3 write
-	 * without PCIDs flushes all non-globals.
-	 */
+	if (!cpu_feature_enabled(X86_FEATURE_INVPCID)) {
+		/*
+		 * native_write_cr3() only clears the current PCID if
+		 * CR4 has X86_CR4_PCIDE set.  In other words, this does
+		 * not fully flush the TLB if PCIDs are in use.
+ 		 *
+ 		 * With KAISER and PCIDs, the means that we did not
+		 * flush the user PCID.  Warn if it gets called.
+		 */
+		if (IS_ENABLED(CONFIG_KAISER))
+ 			WARN_ON_ONCE(this_cpu_read(cpu_tlbstate.cr4) &
+ 				     X86_CR4_PCIDE);
+		/*
+		 * If current->mm == NULL then we borrow a mm
+		 * which may change during a task switch and
+		 * therefore we must not be preempted while we
+		 * write CR3 back:
+		 */
+		preempt_disable();
+		native_write_cr3(__native_read_cr3());
+		preempt_enable();
+		/*
+		 * Does not need tlb_flush_shared_nonglobals()
+		 * since the CR3 write without PCIDs flushes all
+		 * non-globals.
+		 */
+		return;
+	}
+ 	/*
+	 * We are no longer using globals with KAISER, so a
+	 * "nonglobals" flush would work too. But, this is more
+	 * conservative.
+	 *
+	 * Note, this works with CR4.PCIDE=0 or 1.
+ 	 */
+	invpcid_flush_all();
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
@@ -350,6 +414,8 @@ static inline void __native_flush_tlb_gl
 		/*
 		 * Using INVPCID is considerably faster than a pair of writes
 		 * to CR4 sandwiched inside an IRQ flag save/restore.
+		 *
+		 * Note, this works with CR4.PCIDE=0 or 1.
 		 */
 		invpcid_flush_all();
 		return;
@@ -369,7 +435,30 @@ static inline void __native_flush_tlb_gl
 
 static inline void __native_flush_tlb_single(unsigned long addr)
 {
-	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
+	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
+
+	/*
+	 * Some platforms #GP if we call invpcid(type=1/2) before
+	 * CR4.PCIDE=1.  Just call invpcid in the case we are called
+	 * early.
+	 */
+	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
+		asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
+		return;
+	}
+	/* Flush the address out of both PCIDs. */
+	/*
+	 * An optimization here might be to determine addresses
+	 * that are only kernel-mapped and only flush the kernel
+	 * ASID.  But, userspace flushes are probably much more
+	 * important performance-wise.
+	 *
+	 * Make sure to do only a single invpcid when KAISER is
+	 * disabled and we have only a single ASID.
+	 */
+	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
+		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
+	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
 }
 
 static inline void __flush_tlb_all(void)
diff -puN arch/x86/include/uapi/asm/processor-flags.h~kaiser-pcid arch/x86/include/uapi/asm/processor-flags.h
--- a/arch/x86/include/uapi/asm/processor-flags.h~kaiser-pcid	2017-11-08 10:45:38.420681372 -0800
+++ b/arch/x86/include/uapi/asm/processor-flags.h	2017-11-08 10:45:38.431681372 -0800
@@ -77,7 +77,8 @@
 #define X86_CR3_PWT		_BITUL(X86_CR3_PWT_BIT)
 #define X86_CR3_PCD_BIT		4 /* Page Cache Disable */
 #define X86_CR3_PCD		_BITUL(X86_CR3_PCD_BIT)
-#define X86_CR3_PCID_MASK	_AC(0x00000fff,UL) /* PCID Mask */
+#define X86_CR3_PCID_NOFLUSH_BIT 63 /* Preserve old PCID */
+#define X86_CR3_PCID_NOFLUSH    _BITULL(X86_CR3_PCID_NOFLUSH_BIT)
 
 /*
  * Intel CPU features in CR4
diff -puN arch/x86/kvm/x86.c~kaiser-pcid arch/x86/kvm/x86.c
--- a/arch/x86/kvm/x86.c~kaiser-pcid	2017-11-08 10:45:38.422681372 -0800
+++ b/arch/x86/kvm/x86.c	2017-11-08 10:45:38.433681372 -0800
@@ -805,7 +805,8 @@ int kvm_set_cr4(struct kvm_vcpu *vcpu, u
 			return 1;
 
 		/* PCID can not be enabled when cr3[11:0]!=000H or EFER.LMA=0 */
-		if ((kvm_read_cr3(vcpu) & X86_CR3_PCID_MASK) || !is_long_mode(vcpu))
+		if ((kvm_read_cr3(vcpu) & X86_CR3_PCID_ASID_MASK) ||
+		    !is_long_mode(vcpu))
 			return 1;
 	}
 
diff -puN arch/x86/mm/init.c~kaiser-pcid arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~kaiser-pcid	2017-11-08 10:45:38.424681372 -0800
+++ b/arch/x86/mm/init.c	2017-11-08 10:45:38.434681372 -0800
@@ -196,34 +196,59 @@ static void __init probe_page_size_mask(
 
 static void setup_pcid(void)
 {
-#ifdef CONFIG_X86_64
-	if (boot_cpu_has(X86_FEATURE_PCID)) {
-		if (boot_cpu_has(X86_FEATURE_PGE)) {
-			/*
-			 * This can't be cr4_set_bits_and_update_boot() --
-			 * the trampoline code can't handle CR4.PCIDE and
-			 * it wouldn't do any good anyway.  Despite the name,
-			 * cr4_set_bits_and_update_boot() doesn't actually
-			 * cause the bits in question to remain set all the
-			 * way through the secondary boot asm.
-			 *
-			 * Instead, we brute-force it and set CR4.PCIDE
-			 * manually in start_secondary().
-			 */
-			cr4_set_bits(X86_CR4_PCIDE);
-		} else {
-			/*
-			 * flush_tlb_all(), as currently implemented, won't
-			 * work if PCID is on but PGE is not.  Since that
-			 * combination doesn't exist on real hardware, there's
-			 * no reason to try to fully support it, but it's
-			 * polite to avoid corrupting data if we're on
-			 * an improperly configured VM.
-			 */
+	if (!IS_ENABLED(CONFIG_X86_64))
+		return;
+
+	if (!boot_cpu_has(X86_FEATURE_PCID))
+		return;
+
+	if (boot_cpu_has(X86_FEATURE_PGE)) {
+		/*
+		 * KAISER uses a PCID for the kernel and another
+		 * for userspace.  Both PCIDs need to be flushed
+		 * when the TLB flush functions are called.  But,
+		 * flushing *another* PCID is insane without
+		 * INVPCID.  Just avoid using PCIDs at all if we
+		 * have KAISER and do not have INVPCID.
+		 */
+		if (!IS_ENABLED(CONFIG_X86_GLOBAL_PAGES) &&
+		    !boot_cpu_has(X86_FEATURE_INVPCID)) {
 			setup_clear_cpu_cap(X86_FEATURE_PCID);
+			return;
 		}
+		/*
+		 * This can't be cr4_set_bits_and_update_boot() --
+		 * the trampoline code can't handle CR4.PCIDE and
+		 * it wouldn't do any good anyway.  Despite the name,
+		 * cr4_set_bits_and_update_boot() doesn't actually
+		 * cause the bits in question to remain set all the
+		 * way through the secondary boot asm.
+		 *
+		 * Instead, we brute-force it and set CR4.PCIDE
+		 * manually in start_secondary().
+		 */
+		cr4_set_bits(X86_CR4_PCIDE);
+
+		/*
+		 * INVPCID's single-context modes (2/3) only work
+		 * if we set X86_CR4_PCIDE, *and* we INVPCID
+		 * support.  It's unusable on systems that have
+		 * X86_CR4_PCIDE clear, or that have no INVPCID
+		 * support at all.
+		 */
+		if (boot_cpu_has(X86_FEATURE_INVPCID))
+			setup_force_cpu_cap(X86_FEATURE_INVPCID_SINGLE);
+	} else {
+		/*
+		 * flush_tlb_all(), as currently implemented, won't
+		 * work if PCID is on but PGE is not.  Since that
+		 * combination doesn't exist on real hardware, there's
+		 * no reason to try to fully support it, but it's
+		 * polite to avoid corrupting data if we're on
+		 * an improperly configured VM.
+		 */
+		setup_clear_cpu_cap(X86_FEATURE_PCID);
 	}
-#endif
 }
 
 #ifdef CONFIG_X86_32
diff -puN arch/x86/mm/tlb.c~kaiser-pcid arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~kaiser-pcid	2017-11-08 10:45:38.426681372 -0800
+++ b/arch/x86/mm/tlb.c	2017-11-08 10:45:38.434681372 -0800
@@ -100,6 +100,68 @@ static void choose_new_asid(struct mm_st
 	*need_flush = true;
 }
 
+/*
+ * Given a kernel asid, flush the corresponding KAISER
+ * user ASID.
+ */
+static void flush_user_asid(pgd_t *pgd, u16 kern_asid)
+{
+	/* There is no user ASID if KAISER is off */
+	if (!IS_ENABLED(CONFIG_KAISER))
+		return;
+	/*
+	 * We only have a single ASID if PCID is off and the CR3
+	 * write will have flushed it.
+	 */
+	if (!cpu_feature_enabled(X86_FEATURE_PCID))
+		return;
+	/*
+	 * With PCIDs enabled, write_cr3() only flushes TLB
+	 * entries for the current (kernel) ASID.  This leaves
+	 * old TLB entries for the user ASID in place and we must
+	 * flush that context separately.  We can theoretically
+	 * delay doing this until we actually load up the
+	 * userspace CR3, but do it here for simplicity.
+	 */
+	if (cpu_feature_enabled(X86_FEATURE_INVPCID)) {
+		invpcid_flush_single_context(user_asid(kern_asid));
+	} else {
+		/*
+		 * On systems with PCIDs, but no INVPCID, the only
+		 * way to flush a PCID is a CR3 write.  Note that
+		 * we use the kernel page tables with the *user*
+		 * ASID here.
+		 */
+		unsigned long user_asid_flush_cr3;
+		user_asid_flush_cr3 = build_cr3(pgd, user_asid(kern_asid));
+		write_cr3(user_asid_flush_cr3);
+		/*
+		 * We do not use PCIDs with KAISER unless we also
+		 * have INVPCID.  Getting here is unexpected.
+		 */
+		WARN_ON_ONCE(1);
+	}
+}
+
+static void load_new_mm_cr3(pgd_t *pgdir, u16 new_asid, bool need_flush)
+{
+	unsigned long new_mm_cr3;
+
+	if (need_flush) {
+		flush_user_asid(pgdir, new_asid);
+		new_mm_cr3 = build_cr3(pgdir, new_asid);
+	} else {
+		new_mm_cr3 = build_cr3_noflush(pgdir, new_asid);
+	}
+
+	/*
+	 * Caution: many callers of this function expect
+	 * that load_cr3() is serializing and orders TLB
+	 * fills with respect to the mm_cpumask writes.
+	 */
+	write_cr3(new_mm_cr3);
+}
+
 void leave_mm(int cpu)
 {
 	struct mm_struct *loaded_mm = this_cpu_read(cpu_tlbstate.loaded_mm);
@@ -229,12 +291,12 @@ void switch_mm_irqs_off(struct mm_struct
 		if (need_flush) {
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].ctx_id, next->context.ctx_id);
 			this_cpu_write(cpu_tlbstate.ctxs[new_asid].tlb_gen, next_tlb_gen);
-			write_cr3(build_cr3(next->pgd, new_asid));
+			load_new_mm_cr3(next->pgd, new_asid, true);
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH,
 					TLB_FLUSH_ALL);
 		} else {
 			/* The new ASID is already up to date. */
-			write_cr3(build_cr3_noflush(next->pgd, new_asid));
+			load_new_mm_cr3(next->pgd, new_asid, false);
 			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, 0);
 		}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
