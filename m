Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 287646B005A
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 05:25:17 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so17353876eek.14
        for <linux-mm@kvack.org>; Mon, 02 Jan 2012 02:25:16 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v5 2/8] arm: Move arm over to generic on_each_cpu_mask
Date: Mon,  2 Jan 2012 12:24:13 +0200
Message-Id: <1325499859-2262-3-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

Note that the generic version is a little different then the Arm one:

1. It has the mask as first parameter
2. It calls the function on the calling CPU with interrupts disabled,
   but this should be OK since the function is called on the other CPUs
   with interrupts disabled anyway.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org
CC: Avi Kivity <avi@redhat.com>
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
