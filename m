Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 792716B0338
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 11:53:32 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t188so1579879oih.15
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 08:53:32 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c79si3734922oig.256.2017.06.29.08.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 08:53:31 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 02/10] x86/mm: Delete a big outdated comment about TLB flushing
Date: Thu, 29 Jun 2017 08:53:14 -0700
Message-Id: <55e44997e56086528140c5180f8337dc53fb7ffc.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
In-Reply-To: <cover.1498751203.git.luto@kernel.org>
References: <cover.1498751203.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

The comment describes the old explicit IPI-based flush logic, which
is long gone.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 36 ------------------------------------
 1 file changed, 36 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 1cc47838d1e8..014d07a80053 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -153,42 +153,6 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	switch_ldt(real_prev, next);
 }
 
-/*
- * The flush IPI assumes that a thread switch happens in this order:
- * [cpu0: the cpu that switches]
- * 1) switch_mm() either 1a) or 1b)
- * 1a) thread switch to a different mm
- * 1a1) set cpu_tlbstate to TLBSTATE_OK
- *	Now the tlb flush NMI handler flush_tlb_func won't call leave_mm
- *	if cpu0 was in lazy tlb mode.
- * 1a2) update cpu active_mm
- *	Now cpu0 accepts tlb flushes for the new mm.
- * 1a3) cpu_set(cpu, new_mm->cpu_vm_mask);
- *	Now the other cpus will send tlb flush ipis.
- * 1a4) change cr3.
- * 1a5) cpu_clear(cpu, old_mm->cpu_vm_mask);
- *	Stop ipi delivery for the old mm. This is not synchronized with
- *	the other cpus, but flush_tlb_func ignore flush ipis for the wrong
- *	mm, and in the worst case we perform a superfluous tlb flush.
- * 1b) thread switch without mm change
- *	cpu active_mm is correct, cpu0 already handles flush ipis.
- * 1b1) set cpu_tlbstate to TLBSTATE_OK
- * 1b2) test_and_set the cpu bit in cpu_vm_mask.
- *	Atomically set the bit [other cpus will start sending flush ipis],
- *	and test the bit.
- * 1b3) if the bit was 0: leave_mm was called, flush the tlb.
- * 2) switch %%esp, ie current
- *
- * The interrupt must handle 2 special cases:
- * - cr3 is changed before %%esp, ie. it cannot use current->{active_,}mm.
- * - the cpu performs speculative tlb reads, i.e. even if the cpu only
- *   runs in kernel space, the cpu could load tlb entries for user space
- *   pages.
- *
- * The good news is that cpu_tlbstate is local to each cpu, no
- * write/read ordering problems.
- */
-
 static void flush_tlb_func_common(const struct flush_tlb_info *f,
 				  bool local, enum tlb_flush_reason reason)
 {
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
