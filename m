Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3FE6B02C3
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 01:22:22 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k126so98019656oia.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 22:22:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f66si3953315oia.28.2017.06.20.22.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 22:22:21 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
Date: Tue, 20 Jun 2017 22:22:07 -0700
Message-Id: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
In-Reply-To: <cover.1498022414.git.luto@kernel.org>
References: <cover.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>

It was historically possible to have two concurrent TLB flushes
targetting the same CPU: one initiated locally and one initiated
remotely.  This can now cause an OOPS in leave_mm() at
arch/x86/mm/tlb.c:47:

        if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
                BUG();

with this call trace:
 flush_tlb_func_local arch/x86/mm/tlb.c:239 [inline]
 flush_tlb_mm_range+0x26d/0x370 arch/x86/mm/tlb.c:317

Without reentrancy, this OOPS is impossible: leave_mm() is only
called if we're not in TLBSTATE_OK, but then we're unexpectedly
in TLBSTATE_OK in leave_mm().

This can be caused by flush_tlb_func_remote() happening between
the two checks and calling leave_mm(), resulting in two consecutive
leave_mm() calls on the same CPU with no intervening switch_mm()
calls.

We never saw this OOPS before because the old leave_mm()
implementation didn't put us back in TLBSTATE_OK, so the assertion
didn't fire.

Nadav noticed the reentrancy issue in a different context, but
neither of us realized that it caused a problem yet.

Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Reported-by: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Fixes: 3d28ebceaffa ("x86/mm: Rework lazy TLB to track the actual loaded mm")
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 2a5e851f2035..f06239c6919f 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -208,6 +208,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 static void flush_tlb_func_common(const struct flush_tlb_info *f,
 				  bool local, enum tlb_flush_reason reason)
 {
+	/* This code cannot presently handle being reentered. */
+	VM_WARN_ON(!irqs_disabled());
+
 	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
 		leave_mm(smp_processor_id());
 		return;
@@ -313,8 +316,12 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		info.end = TLB_FLUSH_ALL;
 	}
 
-	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm))
+	if (mm == this_cpu_read(cpu_tlbstate.loaded_mm)) {
+		local_irq_disable();
 		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
+		local_irq_enable();
+	}
+
 	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), &info);
 	put_cpu();
@@ -370,8 +377,12 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 
 	int cpu = get_cpu();
 
-	if (cpumask_test_cpu(cpu, &batch->cpumask))
+	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
+		local_irq_disable();
 		flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
+		local_irq_enable();
+	}
+
 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
 		flush_tlb_others(&batch->cpumask, &info);
 	cpumask_clear(&batch->cpumask);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
