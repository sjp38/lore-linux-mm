Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 179EC6B025F
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:38 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id r196so817753itc.4
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:38 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k80si46674ioi.42.2017.12.05.04.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:37 -0800 (PST)
Message-Id: <20171205123820.034976940@infradead.org>
Date: Tue, 05 Dec 2017 13:34:48 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 3/9] x86/mm: Address feedback
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-invalidate-other-fix.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

fold into: ("x86/mm: Allow flushing for future ASID switches")

Andy asked for the KPTI check to be pulled out of the API such that
the function always does as advertised.

Rename to: invalidate_other_asid() because the pcid name is actually
wrong if we consider our ASID to represend two PCID values (as it does
with KPTI). In specific, it will not flush the user PCID of the
current ASID.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -270,16 +270,11 @@ static inline unsigned long cr4_read_sha
 	return this_cpu_read(cpu_tlbstate.cr4);
 }
 
-static inline void invalidate_pcid_other(void)
+/*
+ * Mark all other ASIDs as invalid, preserves the current.
+ */
+static inline void invalidate_other_asid(void)
 {
-	/*
-	 * With global pages, all of the shared kenel page tables
-	 * are set as _PAGE_GLOBAL.  We have no shared nonglobals
-	 * and nothing to do here.
-	 */
-	if (!static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_KPTI))
-		return;
-
 	this_cpu_write(cpu_tlbstate.invalidate_other, true);
 }
 
@@ -411,11 +406,16 @@ static inline void __flush_tlb_one(unsig
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
 	__flush_tlb_single(addr);
+
+	if (!static_cpu_has_bug(X86_BUG_CPU_SECURE_MODE_KPTI))
+		return;
+
 	/*
-	 * Invalidate other address spaces inaccessible to single-page
-	 * invalidation:
+	 * __flush_tlb_single() will have cleared the TLB entry for this ASID,
+	 * but since kernel space is replicated across all, we must also
+	 * invalidate all others.
 	 */
-	invalidate_pcid_other();
+	invalidate_other_asid();
 }
 
 #define TLB_FLUSH_ALL	-1UL


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
