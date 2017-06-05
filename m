Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38BEB6B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 22:38:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id s4so6083654wrc.15
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 19:38:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w20si7813738wrc.52.2017.06.04.19.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 19:38:25 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v552Xcq2125956
	for <linux-mm@kvack.org>; Sun, 4 Jun 2017 22:38:24 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2avxdq0gvu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 04 Jun 2017 22:38:24 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 5 Jun 2017 12:38:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v552cBEu2425178
	for <linux-mm@kvack.org>; Mon, 5 Jun 2017 12:38:19 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v552bdhj005417
	for <linux-mm@kvack.org>; Mon, 5 Jun 2017 12:37:39 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH] mm/cma: Warn if the CMA area could not be activated
Date: Mon,  5 Jun 2017 08:07:29 +0530
Message-Id: <20170605023729.26303-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com

While activating the CMA area, we check to make sure that all the
PFNs in the range are inside the same zone. This is a requirement
for alloc_contig_range() to work. Any CMA area failing the check
is disabled for good. This happens silently right now making all
future cma_alloc() allocations failure inevitable. Here we add a
error message stating that the CMA area could not be activated
which makes its easier to explain any future cma_alloc() failures
on it. While at this, change the bail out goto label from 'err'
to 'not_in_zone' which makes more sense.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/cma.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 978b4a1..9e45491 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -127,7 +127,7 @@ static int __init cma_activate_area(struct cma *cma)
 			 * to be in the same zone.
 			 */
 			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto err;
+				goto not_in_zone;
 		}
 		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
 	} while (--i);
@@ -141,7 +141,8 @@ static int __init cma_activate_area(struct cma *cma)
 
 	return 0;
 
-err:
+not_in_zone:
+	pr_err("CMA area %s could not be activated\n", cma->name);
 	kfree(cma->bitmap);
 	cma->count = 0;
 	return -EINVAL;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
