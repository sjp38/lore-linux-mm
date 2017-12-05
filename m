Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 230C16B0260
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:41:38 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id h200so826604itb.3
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:41:38 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id i132si41193ioa.108.2017.12.05.04.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 04:41:37 -0800 (PST)
Message-Id: <20171205123819.935639403@infradead.org>
Date: Tue, 05 Dec 2017 13:34:46 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 1/9] x86/mm: Remove superfluous barriers
References: <20171205123444.990868007@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-tlb-remove-barriers.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@kernel.org>, moritz.lipp@iaik.tugraz.at, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at

atomic64_inc_return() already implies smp_mb() before and after.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlbflush.h |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -62,19 +62,13 @@ static inline void invpcid_flush_all_non
 
 static inline u64 inc_mm_tlb_gen(struct mm_struct *mm)
 {
-	u64 new_tlb_gen;
-
 	/*
 	 * Bump the generation count.  This also serves as a full barrier
 	 * that synchronizes with switch_mm(): callers are required to order
 	 * their read of mm_cpumask after their writes to the paging
 	 * structures.
 	 */
-	smp_mb__before_atomic();
-	new_tlb_gen = atomic64_inc_return(&mm->context.tlb_gen);
-	smp_mb__after_atomic();
-
-	return new_tlb_gen;
+	return atomic64_inc_return(&mm->context.tlb_gen);
 }
 
 /* There are 12 bits of space for ASIDS in CR3 */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
