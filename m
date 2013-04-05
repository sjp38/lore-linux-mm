Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 6FD3A6B0117
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 16:34:19 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 5 Apr 2013 14:34:18 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id BEAF019D8043
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:34:11 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r35KYFmf329694
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 14:34:15 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r35KYEbG004876
	for <linux-mm@kvack.org>; Fri, 5 Apr 2013 14:34:14 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 1/3] mm/page_alloc: factor out setting of pcp->high and pcp->batch.
Date: Fri,  5 Apr 2013 13:33:48 -0700
Message-Id: <1365194030-28939-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365194030-28939-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Creates pageset_set_batch() for use in setup_pageset().
pageset_set_batch() imitates the functionality of
setup_pagelist_highmark(), but uses the boot time
(percpu_pagelist_fraction == 0) calculations for determining ->high
based on ->batch.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8fcced7..5877cf0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4004,6 +4004,14 @@ static int __meminit zone_batchsize(struct zone *zone)
 #endif
 }
 
+/* a companion to setup_pagelist_highmark() */
+static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
+{
+	struct per_cpu_pages *pcp = &p->pcp;
+	pcp->high = 6 * batch;
+	pcp->batch = max(1UL, 1 * batch);
+}
+
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
@@ -4013,8 +4021,7 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	pageset_set_batch(p, batch);
 	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
@@ -4023,7 +4030,6 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
  * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
  * to the value high for the pageset p.
  */
-
 static void setup_pagelist_highmark(struct per_cpu_pageset *p,
 				unsigned long high)
 {
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
