Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 923A9280303
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 15:35:54 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so48960379pdr.2
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 12:35:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id af4si14508876pbc.227.2015.07.16.12.35.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 12:35:53 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] mm: trace tlb flush after disabling preemption in try_to_unmap_flush
Date: Thu, 16 Jul 2015 15:35:39 -0400
Message-Id: <1437075339-32715-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de
Cc: mhocko@suse.cz, riel@redhat.com, mingo@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

Commit "mm: send one IPI per CPU to TLB flush all entries after unmapping
pages" added a trace_tlb_flush() while preemption was still enabled. This
means that we'll access smp_processor_id() which in turn will get us quite
a few warnings.

Fix it by moving the trace to where the preemption is disabled, one line
down.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---

The diff is all lies: I've moved trace_tlb_flush() one line down rather
than get_cpu() a line up ;)

 mm/rmap.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 30812e9..63ba46c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -613,9 +613,10 @@ void try_to_unmap_flush(void)
 	if (!tlb_ubc->flush_required)
 		return;
 
+	cpu = get_cpu();
+
 	trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, -1UL);
 
-	cpu = get_cpu();
 	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask))
 		percpu_flush_tlb_batch_pages(&tlb_ubc->cpumask);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
