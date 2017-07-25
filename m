Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64A1C6B02B4
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:41:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p62so10234446oih.12
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:41:44 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j7si6123661oif.197.2017.07.24.21.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 21:41:43 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v5 2/2] x86/mm: Improve TLB flush documentation
Date: Mon, 24 Jul 2017 21:41:39 -0700
Message-Id: <695299daa67239284e8db5a60d4d7eb88c914e0a.1500957502.git.luto@kernel.org>
In-Reply-To: <cover.1500957502.git.luto@kernel.org>
References: <cover.1500957502.git.luto@kernel.org>
In-Reply-To: <cover.1500957502.git.luto@kernel.org>
References: <cover.1500957502.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

Improve comments as requested by PeterZ and also add some
documentation at the top of the file.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 43 +++++++++++++++++++++++++++++++++----------
 1 file changed, 33 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index ce104b962a17..d4ee781ca656 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -15,17 +15,24 @@
 #include <linux/debugfs.h>
 
 /*
- *	TLB flushing, formerly SMP-only
- *		c/o Linus Torvalds.
+ * The code in this file handles mm switches and TLB flushes.
  *
- *	These mean you can really definitely utterly forget about
- *	writing to user space from interrupts. (Its not allowed anyway).
+ * An mm's TLB state is logically represented by a totally ordered sequence
+ * of TLB flushes.  Each flush increments the mm's tlb_gen.
  *
- *	Optimizations Manfred Spraul <manfred@colorfullife.com>
+ * Each CPU that might have an mm in its TLB (and that might ever use
+ * those TLB entries) will have an entry for it in its cpu_tlbstate.ctxs
+ * array.  The kernel maintains the following invariant: for each CPU and
+ * for each mm in its cpu_tlbstate.ctxs array, the CPU has performed all
+ * flushes in that mms history up to the tlb_gen in cpu_tlbstate.ctxs
+ * or the CPU has performed an equivalent set of flushes.
  *
- *	More scalable flush, from Andi Kleen
- *
- *	Implement flush IPI by CALL_FUNCTION_VECTOR, Alex Shi
+ * For this purpose, an equivalent set is a set that is at least as strong.
+ * So, for example, if the flush history is a full flush at time 1,
+ * a full flush after time 1 is sufficient, but a full flush before time 1
+ * is not.  Similarly, any number of flushes can be replaced by a single
+ * full flush so long as that replacement flush is after all the flushes
+ * that it's replacing.
  */
 
 atomic64_t last_mm_ctx_id = ATOMIC64_INIT(1);
@@ -138,7 +145,16 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 			return;
 		}
 
-		/* Resume remote flushes and then read tlb_gen. */
+		/*
+		 * Resume remote flushes and then read tlb_gen.  The
+		 * implied barrier in atomic64_read() synchronizes
+		 * with inc_mm_tlb_gen() like this:
+		 *
+		 * switch_mm_irqs_off():	flush request:
+		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
+		 *  MB				 MB
+		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
+		 */
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
 
@@ -186,7 +202,14 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 		VM_WARN_ON_ONCE(cpumask_test_cpu(cpu, mm_cpumask(next)));
 
 		/*
-		 * Start remote flushes and then read tlb_gen.
+		 * Start remote flushes and then read tlb_gen.  As
+		 * above, the implied barrier in atomic64_read()
+		 * synchronizes with inc_mm_tlb_gen() like this:
+		 *
+		 * switch_mm_irqs_off():	flush request:
+		 *  cpumask_set_cpu(...);	 inc_mm_tlb_gen();
+		 *  MB				 MB
+		 *  atomic64_read(.tlb_gen);	 flush_tlb_others(mm_cpumask());
 		 */
 		cpumask_set_cpu(cpu, mm_cpumask(next));
 		next_tlb_gen = atomic64_read(&next->context.tlb_gen);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
