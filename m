Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id EEDC56B0266
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:38 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id b11so859511itj.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:38 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id f67si207418ite.84.2017.12.05.04.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:38 -0800 (PST)
Message-Id: <20171205123820.287167050@infradead.org>
Date: Tue, 05 Dec 2017 13:34:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 8/9] x86/mm: Clarify the whole ASID/kernel PCID/user PCID naming
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-comment-asid.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

Ideally we'd also use sparse to enforce this sparation so it becomes
much more difficult to mess up.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |   55 +++++++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 12 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -13,16 +13,33 @@
 #include <asm/processor-flags.h>
 #include <asm/invpcid.h>
 
-static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
-{
-	/*
-	 * Bump the generation count.  This also serves as a full barrier
-	 * that synchronizes with switch_mm(): callers are required to order
-	 * their read of mm_cpumask after their writes to the paging
-	 * structures.
-	 */
-	return atomic64_inc_return(&mm->context.tlb_gen);
-}
+/*
+ * The x86 feature is called PCID (Process Context IDentifier). It is similar
+ * to what is traditionally called ASID on the RISC processors.
+ *
+ * We don't use the traditional ASID implementation, where each process/mm gets
+ * its own ASID and flush/restart when we run out of ASID space.
+ *
+ * Instead we have a small per-cpu array of ASIDs and cache the last few mm's
+ * that came by on this CPU, allowing cheaper switch_mm between processes on
+ * this CPU.
+ *
+ * We end up with different spaces for different things. To avoid confusion we
+ * use different names for each of them:
+ *
+ * ASID  - [0, TLB_NR_DYN_ASIDS-1]
+ *         the canonical identifier for an mm
+ *
+ * kPCID - [1, TLB_NR_DYN_ASIDS]
+ *         the value we write into the PCID part of CR3; corresponds to the
+ *         ASID+1, because PCID 0 is special.
+ *
+ * uPCID - [2048 + 1, 2048 + TLB_NR_DYN_ASIDS]
+ *         for KPTI each mm has two address spaces and thus needs two
+ *         PCID values, but we can still do with a single ASID denomination
+ *         for each mm. Corresponds to kPCID + 2048.
+ *
+ */
 
 /* There are 12 bits of space for ASIDS in CR3 */
 #define CR3_HW_ASID_BITS		12
@@ -41,7 +58,7 @@ static inline u64 inc_mm_tlb_gen(struct
 
 /*
  * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below to account
- * for them being zero-based.  Another -1 is because ASID 0 is reserved for
+ * for them being zero-based.  Another -1 is because PCID 0 is reserved for
  * use by non-PCID-aware users.
  */
 #define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_PCID_BITS) - 2)
@@ -52,6 +69,9 @@ static inline u64 inc_mm_tlb_gen(struct
  */
 #define TLB_NR_DYN_ASIDS	6
 
+/*
+ * Given @asid, compute kPCID
+ */
 static inline u16 kern_pcid(u16 asid)
 {
 	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
@@ -86,7 +106,7 @@ static inline u16 kern_pcid(u16 asid)
 }
 
 /*
- * The user PCID is just the kernel one, plus the "switch bit".
+ * Given @asid, compute uPCID
  */
 static inline u16 user_pcid(u16 asid)
 {
@@ -487,6 +507,17 @@ static inline void flush_tlb_page(struct
 void native_flush_tlb_others(const struct cpumask *cpumask,
 			     const struct flush_tlb_info *info);
 
+static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
+{
+	/*
+	 * Bump the generation count.  This also serves as a full barrier
+	 * that synchronizes with switch_mm(): callers are required to order
+	 * their read of mm_cpumask after their writes to the paging
+	 * structures.
+	 */
+	return atomic64_inc_return(&mm->context.tlb_gen);
+}
+
 static inline void arch_tlbbatch_add_mm(struct arch_tlbflush_unmap_batch *batch,
 					struct mm_struct *mm)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
