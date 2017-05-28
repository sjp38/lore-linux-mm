Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9C96B02FA
	for <linux-mm@kvack.org>; Sun, 28 May 2017 13:01:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id l1so51724094oib.4
        for <linux-mm@kvack.org>; Sun, 28 May 2017 10:01:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j17si2839138oib.318.2017.05.28.10.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 May 2017 10:01:58 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v4 4/8] x86/mm: Use new merged flush logic in arch_tlbbatch_flush()
Date: Sun, 28 May 2017 10:00:13 -0700
Message-Id: <50ed8bd642dc32f22250aea47df1e37eb5af13b6.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
In-Reply-To: <cover.1495990440.git.luto@kernel.org>
References: <cover.1495990440.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

Now there's only one copy of the local tlb flush logic for
non-kernel pages on SMP kernels.

The only functional change is that arch_tlbbatch_flush() will now
leave_mm() on the local CPU if that CPU is in the batch and is in
TLBSTATE_LAZY mode.

Cc: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/mm/tlb.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 12b8812e8926..c03b4a0ce58c 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -382,12 +382,8 @@ void arch_tlbbatch_flush(struct arch_tlbflush_unmap_batch *batch)
 
 	int cpu = get_cpu();
 
-	if (cpumask_test_cpu(cpu, &batch->cpumask)) {
-		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
-		local_flush_tlb();
-		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
-	}
-
+	if (cpumask_test_cpu(cpu, &batch->cpumask))
+		flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
 		flush_tlb_others(&batch->cpumask, &info);
 	cpumask_clear(&batch->cpumask);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
