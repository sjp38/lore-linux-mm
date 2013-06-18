Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id B49FD6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 18:12:11 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 18:12:10 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D14C3C90044
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 18:12:06 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IMB70m308354
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 18:11:07 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IMB7lf031602
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 18:11:07 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] mm/page_alloc: remove repetitious local_irq_save() in __zone_pcp_update()
Date: Tue, 18 Jun 2013 15:10:37 -0700
Message-Id: <1371593437-30002-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>

__zone_pcp_update() is called via stop_machine(), which already disables
local irq.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bac3107..b46b54a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6179,7 +6179,7 @@ static int __meminit __zone_pcp_update(void *data)
 {
 	struct zone *zone = data;
 	int cpu;
-	unsigned long batch = zone_batchsize(zone), flags;
+	unsigned long batch = zone_batchsize(zone);
 
 	for_each_possible_cpu(cpu) {
 		struct per_cpu_pageset *pset;
@@ -6188,12 +6188,10 @@ static int __meminit __zone_pcp_update(void *data)
 		pset = per_cpu_ptr(zone->pageset, cpu);
 		pcp = &pset->pcp;
 
-		local_irq_save(flags);
 		if (pcp->count > 0)
 			free_pcppages_bulk(zone, pcp->count, pcp);
 		drain_zonestat(zone, pset);
 		setup_pageset(pset, batch);
-		local_irq_restore(flags);
 	}
 	return 0;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
