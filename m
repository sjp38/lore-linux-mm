Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37C966B02F4
	for <linux-mm@kvack.org>; Thu, 25 May 2017 20:47:59 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h127so258501534oic.11
        for <linux-mm@kvack.org>; Thu, 25 May 2017 17:47:59 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v5si6570149oib.55.2017.05.25.17.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 17:47:58 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v3 4/8] x86/mm: Use new merged flush logic in arch_tlbbatch_flush()
Date: Thu, 25 May 2017 17:47:48 -0700
Message-Id: <50ed8bd642dc32f22250aea47df1e37eb5af13b6.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
In-Reply-To: <cover.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

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
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
