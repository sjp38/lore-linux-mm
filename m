Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A472B6B027C
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:41:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d7so7455187wre.15
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:41:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i75si20218754wmg.99.2018.01.01.06.41.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:41:16 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 029/146] x86/mm: Clarify the whole ASID/kernel PCID/user PCID naming
Date: Mon,  1 Jan 2018 15:37:00 +0100
Message-Id: <20180101140128.008675045@linuxfoundation.org>
In-Reply-To: <20180101140123.743014891@linuxfoundation.org>
References: <20180101140123.743014891@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit 0a126abd576ebc6403f063dbe20cf7416c9d9393 upstream.

Ideally we'd also use sparse to enforce this separation so it becomes much
more difficult to mess up.

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
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |   55 +++++++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 12 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -13,16 +13,33 @@
 #include <asm/pti.h>
 #include <asm/processor-flags.h>
 
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
@@ -484,6 +504,17 @@ static inline void flush_tlb_page(struct
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
