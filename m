Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6276B0276
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 06:55:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j4so9343312wrg.15
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 03:55:32 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m16si2347363wrf.445.2017.12.18.03.55.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 18 Dec 2017 03:55:31 -0800 (PST)
Message-Id: <20171218115254.657030898@linutronix.de>
Date: Mon, 18 Dec 2017 12:42:28 +0100
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V163 13/51] x86/mm: Remove superfluous barriers
References: <20171218114215.239543034@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline;
 filename=0061-x86-mm-Remove-superfluous-barriers.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Rik van Riel <riel@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, daniel.gruss@iaik.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org

From: Peter Zijlstra <peterz@infradead.org>

atomic64_inc_return() already implies smp_mb() before and after.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Ingo Molnar <mingo@kernel.org>
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
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
---
 arch/x86/include/asm/tlbflush.h |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -60,19 +60,13 @@ static inline void invpcid_flush_all_non
 
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
 
 #ifdef CONFIG_PARAVIRT


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
