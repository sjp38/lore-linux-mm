Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5086B006E
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 05:18:28 -0500 (EST)
Received: by mail-bw0-f41.google.com with SMTP id 17so5188133bke.14
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 02:18:26 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v3 2/5] arm: Move arm over to generic on_each_cpu_mask
Date: Sun, 13 Nov 2011 12:17:26 +0200
Message-Id: <1321179449-6675-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

Note the generic version has the mask as first parameter

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
---
 arch/arm/kernel/smp_tlb.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/arch/arm/kernel/smp_tlb.c b/arch/arm/kernel/smp_tlb.c
index 7dcb352..02c5d2c 100644
--- a/arch/arm/kernel/smp_tlb.c
+++ b/arch/arm/kernel/smp_tlb.c
@@ -13,18 +13,6 @@
 #include <asm/smp_plat.h>
 #include <asm/tlbflush.h>
 
-static void on_each_cpu_mask(void (*func)(void *), void *info, int wait,
-	const struct cpumask *mask)
-{
-	preempt_disable();
-
-	smp_call_function_many(mask, func, info, wait);
-	if (cpumask_test_cpu(smp_processor_id(), mask))
-		func(info);
-
-	preempt_enable();
-}
-
 /**********************************************************************/
 
 /*
@@ -87,7 +75,7 @@ void flush_tlb_all(void)
 void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (tlb_ops_need_broadcast())
-		on_each_cpu_mask(ipi_flush_tlb_mm, mm, 1, mm_cpumask(mm));
+		on_each_cpu_mask(mm_cpumask(mm), ipi_flush_tlb_mm, mm, 1);
 	else
 		local_flush_tlb_mm(mm);
 }
@@ -98,7 +86,8 @@ void flush_tlb_page(struct vm_area_struct *vma, unsigned long uaddr)
 		struct tlb_args ta;
 		ta.ta_vma = vma;
 		ta.ta_start = uaddr;
-		on_each_cpu_mask(ipi_flush_tlb_page, &ta, 1, mm_cpumask(vma->vm_mm));
+		on_each_cpu_mask(mm_cpumask(vma->vm_mm), ipi_flush_tlb_page,
+					&ta, 1);
 	} else
 		local_flush_tlb_page(vma, uaddr);
 }
@@ -121,7 +110,8 @@ void flush_tlb_range(struct vm_area_struct *vma,
 		ta.ta_vma = vma;
 		ta.ta_start = start;
 		ta.ta_end = end;
-		on_each_cpu_mask(ipi_flush_tlb_range, &ta, 1, mm_cpumask(vma->vm_mm));
+		on_each_cpu_mask(mm_cpumask(vma->vm_mm), ipi_flush_tlb_range,
+					&ta, 1);
 	} else
 		local_flush_tlb_range(vma, start, end);
 }
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
