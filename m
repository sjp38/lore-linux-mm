Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 967526B005A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:47 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 14:24:46 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 69D7A38C80A9
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:28 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AIOONU62324892
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:24:27 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AIODF3009896
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:24:13 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 07/11] mm/page_alloc: factor setup_pageset() into pageset_init() and pageset_set_batch()
Date: Wed, 10 Apr 2013 11:23:35 -0700
Message-Id: <1365618219-17154-8-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3447a4b..352c279a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4043,7 +4043,7 @@ static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
 }
 
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+static void pageset_init(struct per_cpu_pageset *p)
 {
 	struct per_cpu_pages *pcp;
 	int migratetype;
@@ -4052,11 +4052,16 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	pageset_set_batch(p, batch);
 	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
 
+static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+{
+	pageset_init(p);
+	pageset_set_batch(p, batch);
+}
+
 /*
  * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
  * to the value high for the pageset p.
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
