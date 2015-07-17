Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AA6722802E4
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 02:12:28 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so56450843pdr.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 23:12:28 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id hw8si16865797pbc.91.2015.07.16.23.12.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 23:12:27 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so55451449pac.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 23:12:27 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] mm/rmap: disable preemption for trace_tlb_flush()
Date: Fri, 17 Jul 2015 15:12:54 +0900
Message-Id: <1437113574-2047-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

tlb_flush contains TP_CONDITION(cpu_online(smp_processor_id()))
which is better be executed with preemption disabled.

Move trace_tlb_flush(TLB_REMOTE_SHOOTDOWN) in try_to_unmap_flush()
under get_cpu().

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/rmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 30812e9..74086cc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -613,9 +613,9 @@ void try_to_unmap_flush(void)
 	if (!tlb_ubc->flush_required)
 		return;
 
+	cpu = get_cpu();
 	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, -1UL);
 
-	cpu = get_cpu();
 	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
 		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
 
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
