Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 05E5C6B005A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:44 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 12:24:44 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B2A896E8062
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:32 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIOUmw64028858
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIOUKn009094
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:30 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 11/11] mm/page_alloc: rename setup_pagelist_highmark() to match naming of pageset_set_batch()
Date: Wed, 10 Apr 2013 11:23:39 -0700
Message-Id: <1365618219-17154-12-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5ee5ce9..038e9d2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4037,7 +4037,7 @@ static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
 	pcp->batch = batch;
 }
 
-/* a companion to setup_pagelist_highmark() */
+/* a companion to pageset_set_high() */
 static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 {
 	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
@@ -4063,10 +4063,10 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 }
 
 /*
- * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
+ * pageset_set_high() sets the high water mark for hot per_cpu_pagelist
  * to the value high for the pageset p.
  */
-static void setup_pagelist_highmark(struct per_cpu_pageset *p,
+static void pageset_set_high(struct per_cpu_pageset *p,
 				unsigned long high)
 {
 	unsigned long batch = max(1UL, high / 4);
@@ -4082,7 +4082,7 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 
 	pageset_init(pcp);
 	if (percpu_pagelist_fraction)
-		setup_pagelist_highmark(pcp,
+		pageset_set_high(pcp,
 			(zone->managed_pages /
 				percpu_pagelist_fraction));
 	else
@@ -5533,8 +5533,8 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 		unsigned long  high;
 		high = zone->managed_pages / percpu_pagelist_fraction;
 		for_each_possible_cpu(cpu)
-			setup_pagelist_highmark(
-					per_cpu_ptr(zone->pageset, cpu), high);
+			pageset_set_high(per_cpu_ptr(zone->pageset, cpu),
+					 high);
 	}
 	mutex_unlock(&pcp_batch_high_lock);
 	return 0;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
