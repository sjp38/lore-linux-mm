Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8616B02E1
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:57:00 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x202so31504644pgx.1
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:57:00 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n65si12451324pfg.62.2017.11.28.01.56.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 01:56:59 -0800 (PST)
Subject: [PATCH] x86/mm/kaiser: Flush the correct ASID in __native_flush_tlb_single()
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 28 Nov 2017 01:55:31 -0800
Message-Id: <20171128095531.F32E1BC7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, "Reported-by:fengguang.wu"@intel.com, tglx@linutronix.de, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, bp@alien8.de, x86@kernel.org


I believe this fixes a bug introduced in the following KAISER patch:

    x86/mm/kaiser: Use PCID feature to make user and kernel switches faster

It's only been lightly tested.  I'm sharing so that folks who might
be running into it have a fix to test.

--

From: Dave Hansen <dave.hansen@linux.intel.com>

There have been a series of weird warnings and boot problems on
when running the KAISER PCID patches.  I believe many of them can
be tracked down to this problem.  One example:

	http://lkml.kernel.org/r/5a1aaa36.CWNgvwmmRFzeAlPc%fengguang.wu@intel.com

The issue is when we are relatively early in boot and have the
lower 12 bits of CR3 clear and thus are running with PCID (aka
ASID) 0.  cpu_tlbstate.loaded_mm_asid contains a 0.  *But* PCID
0 is not ASID 0.  The ASIDs are biased up by one as not to conflict
with the somewhat special hardware PCID 0.

Upon entering __native_flush_tlb_single(), we set loaded_mm_asid=0.
We then calculate the kern_asid(), biasing up by 1, get 1, and pass
*that* to INVPCID.  Thus, we have PCID 0 loaded in CR3 but are
flushing PCID 1 with INVPCID.  That obviously does not work.

To fix this, mark the cpu_tlbstate.loaded_mm_asid as invalid, then
detect that state in __native_flush_tlb_single(), falling back to
INVLPG.

Also add a VM_WARN_ON() to help find these in the future.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reported-by: fengguang.wu@intel.com
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |   36 +++++++++++++++++++++++++++++++-----
 b/arch/x86/mm/init.c              |    1 +
 2 files changed, 32 insertions(+), 5 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-fix-wrong-asid-flush arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-fix-wrong-asid-flush	2017-11-28 01:43:05.180452966 -0800
+++ b/arch/x86/include/asm/tlbflush.h	2017-11-28 01:43:05.190452966 -0800
@@ -77,6 +77,8 @@ static inline u64 inc_mm_tlb_gen(struct
 
 /* There are 12 bits of space for ASIDS in CR3 */
 #define CR3_HW_ASID_BITS 12
+#define CR3_NR_HW_ASIDS	(1<<CR3_HW_ASID_BITS)
+#define INVALID_HW_ASID	(CR3_NR_HW_ASIDS+1)
 /* When enabled, KAISER consumes a single bit for user/kernel switches */
 #ifdef CONFIG_KAISER
 #define X86_CR3_KAISER_SWITCH_BIT 11
@@ -425,19 +427,40 @@ static inline void __native_flush_tlb_gl
 	raw_local_irq_restore(flags);
 }
 
+static inline void __invlpg(unsigned long addr)
+{
+	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
+}
+
+static inline u16 cr3_asid(void)
+{
+	return __read_cr3() & ((1<<CR3_HW_ASID_BITS)-1);
+}
+
 static inline void __native_flush_tlb_single(unsigned long addr)
 {
-	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
+	u16 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 
 	/*
-	 * Some platforms #GP if we call invpcid(type=1/2) before
-	 * CR4.PCIDE=1.  Just call invpcid in the case we are called
-	 * early.
+	 * Handle systems that do not support PCIDs.  This will also
+	 * get used in cases where this is called before PCID detection
+	 * is done.
 	 */
 	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
-		asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
+		__invlpg(addr);
 		return;
 	}
+
+	/*
+	 * An "invalid" loaded_mm_asid means that we have not
+	 * initialized 'cpu_tlbstate' and are not using PCIDs.
+	 * Just flush the TLB as if PCIDs were not present.
+	 */
+	if (loaded_mm_asid == INVALID_HW_ASID) {
+		__invlpg(addr);
+		return;
+	}
+
 	/* Flush the address out of both PCIDs. */
 	/*
 	 * An optimization here might be to determine addresses
@@ -451,6 +474,9 @@ static inline void __native_flush_tlb_si
 	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
 		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
 	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
+
+	/* Check that we are flushing the active ASID: */
+	VM_WARN_ON_ONCE(kern_asid(loaded_mm_asid) != cr3_asid());
 }
 
 static inline void __flush_tlb_all(void)
diff -puN arch/x86/mm/init.c~kaiser-fix-wrong-asid-flush arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~kaiser-fix-wrong-asid-flush	2017-11-28 01:43:05.186452966 -0800
+++ b/arch/x86/mm/init.c	2017-11-28 01:43:05.190452966 -0800
@@ -882,6 +882,7 @@ void __init zone_sizes_init(void)
 
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate) = {
 	.loaded_mm = &init_mm,
+	.loaded_mm_asid = INVALID_HW_ASID, /* We are not doing ASID management yet */
 	.next_asid = 1,
 	.cr4 = ~0UL,	/* fail hard if we screw up cr4 shadow initialization */
 };
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
