Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6F196B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n187so58106pfn.10
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:21 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f126si41838pfg.228.2017.12.05.04.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:20 -0800 (PST)
Message-Id: <20171205123820.235798978@infradead.org>
Date: Tue, 05 Dec 2017 13:34:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 7/9] x86/mm: Clarify which functions are supposed to flush what
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-comment.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

Per popular request..

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -376,6 +376,9 @@ static inline void invalidate_user_asid(
 		  (unsigned long *)this_cpu_ptr(&cpu_tlbstate.user_pcid_flush_mask));
 }
 
+/*
+ * flush the entire current user mapping
+ */
 static inline void __native_flush_tlb(void)
 {
 	invalidate_user_asid(this_cpu_read(cpu_tlbstate.loaded_mm_asid));
@@ -389,6 +392,9 @@ static inline void __native_flush_tlb(vo
 	preempt_enable();
 }
 
+/*
+ * flush everything
+ */
 static inline void __native_flush_tlb_global(void)
 {
 	unsigned long cr4, flags;
@@ -420,6 +426,9 @@ static inline void __native_flush_tlb_gl
 	raw_local_irq_restore(flags);
 }
 
+/*
+ * flush one page in the user mapping
+ */
 static inline void __native_flush_tlb_single(unsigned long addr)
 {
 	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
@@ -439,15 +448,24 @@ static inline void __native_flush_tlb_si
 		invpcid_flush_one(user_pcid(loaded_mm_asid), addr);
 }
 
+/*
+ * flush everything
+ */
 static inline void __flush_tlb_all(void)
 {
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		__flush_tlb_global();
 	} else {
+		/*
+		 * !PGE -> !PCID (setup_pcid()), thus every flush is total.
+		 */
 		__flush_tlb();
 	}
 }
 
+/*
+ * flush one page in the kernel mapping
+ */
 static inline void __flush_tlb_one(unsigned long addr)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
