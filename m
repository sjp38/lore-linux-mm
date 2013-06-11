Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4B47A6B0034
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 18:13:45 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 11 Jun 2013 16:13:44 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C24071FF001B
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 16:08:28 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5BMDeFk163018
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 16:13:40 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5BMDdMR002578
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 16:13:39 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH] mm/page_alloc: don't re-init pageset in zone_pcp_update()
Date: Tue, 11 Jun 2013 15:12:59 -0700
Message-Id: <1370988779-7586-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Valdis.Kletnieks@vt.edu, Cody P Schafer <cody@linux.vnet.ibm.com>

Factor pageset_set_high_and_batch() (which contains all needed logic too
set a pageset's ->high and ->batch inrespective of system state) out of
zone_pageset_init(), which avoids us calling pageset_init(), and
unsafely blowing away a pageset at runtime (leaked pages and
potentially some funky allocations would be the result) when memory
hotplug is triggered.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---

Unless memory hotplug is being triggered on boot, this should *not* be cause of Valdis
Kletnieks' reported bug in -next:
         "next-20130607 BUG: Bad page state in process systemd pfn:127643"

---

 mm/page_alloc.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18102e1..f62c7ac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4111,11 +4111,9 @@ static void pageset_set_high(struct per_cpu_pageset *p,
 	pageset_update(&p->pcp, high, batch);
 }
 
-static void __meminit zone_pageset_init(struct zone *zone, int cpu)
+static void __meminit pageset_set_high_and_batch(struct zone *zone,
+		struct per_cpu_pageset *pcp)
 {
-	struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
-
-	pageset_init(pcp);
 	if (percpu_pagelist_fraction)
 		pageset_set_high(pcp,
 			(zone->managed_pages /
@@ -4124,6 +4122,14 @@ static void __meminit zone_pageset_init(struct zone *zone, int cpu)
 		pageset_set_batch(pcp, zone_batchsize(zone));
 }
 
+static void __meminit zone_pageset_init(struct zone *zone, int cpu)
+{
+	struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
+
+	pageset_init(pcp);
+	pageset_set_high_and_batch(zone, pcp);
+}
+
 static void __meminit setup_zone_pageset(struct zone *zone)
 {
 	int cpu;
@@ -6173,7 +6179,8 @@ void __meminit zone_pcp_update(struct zone *zone)
 	unsigned cpu;
 	mutex_lock(&pcp_batch_high_lock);
 	for_each_possible_cpu(cpu)
-		zone_pageset_init(zone, cpu);
+		pageset_set_high_and_batch(zone,
+				per_cpu_ptr(zone->pageset, cpu));
 	mutex_unlock(&pcp_batch_high_lock);
 }
 #endif
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
