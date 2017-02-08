Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 19C4E6B025E
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:02:30 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so33127621wjy.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:02:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x7si2510876wmf.1.2017.02.08.06.02.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:02:29 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18DweDB023716
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 09:02:27 -0500
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28g066kggx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:02:26 -0500
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 19:32:23 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2DB13E005B
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 19:33:47 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18E2Kv810354810
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:20 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18E2Jak024513
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:32:20 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 3/3] mm: Enable Buddy allocation isolation for CDM nodes
Date: Wed,  8 Feb 2017 19:31:48 +0530
In-Reply-To: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
References: <20170208140148.16049-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170208140148.16049-4-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

This implements allocation isolation for CDM nodes in buddy allocator by
discarding CDM memory zones all the time except in the cases where the gfp
flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
where it is non NULL (explicit allocation request in the kernel or user
process MPOL_BIND policy based requests).

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 40908de..7d8c82a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/node.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2908,6 +2909,24 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		struct page *page;
 		unsigned long mark;
 
+		/*
+		 * CDM nodes get skipped if the requested gfp flag
+		 * does not have __GFP_THISNODE set or the nodemask
+		 * does not have any CDM nodes in case the nodemask
+		 * is non NULL (explicit allocation requests from
+		 * kernel or user process MPOL_BIND policy which has
+		 * CDM nodes).
+		 */
+		if (is_cdm_node(zone->zone_pgdat->node_id)) {
+			if (!(gfp_mask & __GFP_THISNODE)) {
+				if (!ac->nodemask)
+					continue;
+
+				if (!nodemask_has_cdm(*ac->nodemask))
+					continue;
+			}
+		}
+
 		if (cpusets_enabled() &&
 			(alloc_flags & ALLOC_CPUSET) &&
 			!__cpuset_zone_allowed(zone, gfp_mask))
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
