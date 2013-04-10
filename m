Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C1BF06B004D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:30 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:24:29 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 3F9616E8048
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:23 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIOPGB190656
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:25 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIOO6k007314
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 15:24:25 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 10/11] mm/page_alloc: in zone_pcp_update(), uze zone_pageset_init()
Date: Wed, 10 Apr 2013 11:23:38 -0700
Message-Id: <1365618219-17154-11-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Previously, zone_pcp_update() called pageset_set_batch() directly,
essentially assuming that percpu_pagelist_fraction == 0. Correct this by
calling zone_pageset_init(), which chooses the appropriate ->batch and
->high calculations.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 749b6e1..5ee5ce9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6032,11 +6032,9 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 void __meminit zone_pcp_update(struct zone *zone)
 {
 	unsigned cpu;
-	unsigned long batch;
 	mutex_lock(&pcp_batch_high_lock);
-	batch = zone_batchsize(zone);
 	for_each_possible_cpu(cpu)
-		pageset_set_batch(per_cpu_ptr(zone->pageset, cpu), batch);
+		zone_pageset_init(zone, cpu);
 	mutex_unlock(&pcp_batch_high_lock);
 }
 #endif
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
