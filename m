Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B8F746B0037
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:48 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 19:28:47 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 11C9038C8042
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:28:45 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39NSi4N27787356
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 19:28:45 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39NSioa020022
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 19:28:44 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 03/10] mm/page_alloc: insert memory barriers to allow async update of pcp batch and high
Date: Tue,  9 Apr 2013 16:28:12 -0700
Message-Id: <1365550099-6795-4-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365550099-6795-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

In pageset_set_batch() and setup_pagelist_highmark(), ensure that batch
is always set to a safe value (1) prior to updating high, and ensure
that high is fully updated before setting the real value of batch.

Suggested by Gilad Ben-Yossef <gilad@benyossef.com> in this thread:

	https://lkml.org/lkml/2013/4/9/23

Also reproduces his proposed comment.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d259599..a07bd4c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4007,11 +4007,26 @@ static int __meminit zone_batchsize(struct zone *zone)
 #endif
 }
 
+static void pageset_update_prep(struct per_cpu_pages *pcp)
+{
+	/*
+	 * We're about to mess with PCP in an non atomic fashion.  Put an
+	 * intermediate safe value of batch and make sure it is visible before
+	 * any other change
+	 */
+	pcp->batch = 1;
+	smp_wmb();
+}
+
 /* a companion to setup_pagelist_highmark() */
 static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp = &p->pcp;
+	pageset_update_prep(pcp);
+
 	pcp->high = 6 * batch;
+	smp_wmb();
+
 	pcp->batch = max(1UL, 1 * batch);
 }
 
@@ -4039,7 +4054,11 @@ static void setup_pagelist_highmark(struct per_cpu_pageset *p,
 	struct per_cpu_pages *pcp;
 
 	pcp = &p->pcp;
+	pageset_update_prep(pcp);
+
 	pcp->high = high;
+	smp_wmb();
+
 	pcp->batch = max(1UL, high/4);
 	if ((high/4) > (PAGE_SHIFT * 8))
 		pcp->batch = PAGE_SHIFT * 8;
-- 
1.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
