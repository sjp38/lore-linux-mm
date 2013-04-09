Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id EDCEA6B003D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:57 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 19:28:57 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 99287C90025
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:54 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39NSsNR273276
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 19:28:54 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39NSsbD006025
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 19:28:54 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 09/10] mm/page_alloc: in zone_pcp_update(), uze zone_pageset_init()
Date: Tue,  9 Apr 2013 16:28:18 -0700
Message-Id: <1365550099-6795-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
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
index c663e62..334387e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6025,11 +6025,9 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
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
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
