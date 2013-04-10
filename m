Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 07DE26B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 14:26:08 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 12:26:07 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6BA0E3E4006A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:23:57 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3AINxjP081646
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:24:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3AINwcY007856
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:23:58 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v3 03/11] mm/page_alloc: insert memory barriers to allow async update of pcp batch and high
Date: Wed, 10 Apr 2013 11:23:31 -0700
Message-Id: <1365618219-17154-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

Introduce pageset_update() to perform a safe transision from one set of
pcp->{batch,high} to a new set using memory barriers.

This ensures that batch is always set to a safe value (1) prior to
updating high, and ensure that high is fully updated before setting the
real value of batch. It avoids ->batch ever rising above ->high.

Suggested by Gilad Ben-Yossef <gilad@benyossef.com> in these threads:

	https://lkml.org/lkml/2013/4/9/23
	https://lkml.org/lkml/2013/4/10/49

Also reproduces his proposed comment.

Reviewed-by: Gilad Ben-Yossef <gilad@benyossef.com>
Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 41 ++++++++++++++++++++++++++++++++---------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d259599..f2929df 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4007,12 +4007,37 @@ static int __meminit zone_batchsize(struct zone *zone)
 #endif
 }
 
+/*
+ * pcp->high and pcp->batch values are related and dependent on one another:
+ * ->batch must never be higher then ->high.
+ * The following function updates them in a safe manner without read side
+ * locking.
+ *
+ * Any new users of pcp->batch and pcp->high should ensure they can cope with
+ * those fields changing asynchronously (acording the the above rule).
+ *
+ * mutex_is_locked(&pcp_batch_high_lock) required when calling this function
+ * outside of boot time (or some other assurance that no concurrent updaters
+ * exist).
+ */
+static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
+		unsigned long batch)
+{
+       /* start with a fail safe value for batch */
+	pcp->batch = 1;
+	smp_wmb();
+
+       /* Update high, then batch, in order */
+	pcp->high = high;
+	smp_wmb();
+
+	pcp->batch = batch;
+}
+
 /* a companion to setup_pagelist_highmark() */
 static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 {
-	struct per_cpu_pages *pcp = &p->pcp;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
 }
 
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
@@ -4036,13 +4061,11 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 static void setup_pagelist_highmark(struct per_cpu_pageset *p,
 				unsigned long high)
 {
-	struct per_cpu_pages *pcp;
+	unsigned long batch = max(1UL, high / 4);
+	if ((high / 4) > (PAGE_SHIFT * 8))
+		batch = PAGE_SHIFT * 8;
 
-	pcp = &p->pcp;
-	pcp->high = high;
-	pcp->batch = max(1UL, high/4);
-	if ((high/4) > (PAGE_SHIFT * 8))
-		pcp->batch = PAGE_SHIFT * 8;
+	pageset_update(&p->pcp, high, batch);
 }
 
 static void __meminit setup_zone_pageset(struct zone *zone)
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
