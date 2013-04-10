Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 3E99A6B005A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:33 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 12:24:32 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A631B1FF003E
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:19:29 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIOMUZ115336
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:24:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIOLg9018637
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:24:21 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 09/11] mm/page_alloc: factor zone_pageset_init() out of setup_zone_pageset()
Date: Wed, 10 Apr 2013 11:23:37 -0700
Message-Id: <1365618219-17154-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b0762c7..749b6e1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4076,22 +4076,25 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
 	pageset_update(&p->pcp, high, batch);
 }
 
+static void __meminit zone_pageset_init(struct zone *zone, int cpu)
+{
+	struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
+
+	pageset_init(pcp);
+	if (percpu_pagelist_fraction)
+		setup_pagelist_highmark(pcp,
+			(zone->managed_pages /
+				percpu_pagelist_fraction));
+	else
+		pageset_set_batch(pcp, zone_batchsize(zone));
+}
+
 static void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
-
 	zone->pageset = alloc_percpu(struct per_cpu_pageset);
-
-	for_each_possible_cpu(cpu) {
-		struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
-
-		setup_pageset(pcp, zone_batchsize(zone));
-
-		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(pcp,
-				(zone->managed_pages /
-					percpu_pagelist_fraction));
-	}
+	for_each_possible_cpu(cpu)
+		zone_pageset_init(zone, cpu);
 }
 
 /*
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
