Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 263724405A3
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:43 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id j13so150486901iod.6
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:07:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d207si3870947iof.38.2017.02.15.04.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 04:07:42 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FC4b8b179146
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:42 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28mf8pr23f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:41 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 17:37:38 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id ED12C3940060
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:35 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1FC7ZUc43384982
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:35 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1FC7YjP012623
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3 4/4] mm: Enable Buddy allocation isolation for CDM nodes
Date: Wed, 15 Feb 2017 17:37:26 +0530
In-Reply-To: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170215120726.9011-5-khandual@linux.vnet.ibm.com>
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
 mm/page_alloc.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index afbd24d..40c942c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/node.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2898,6 +2899,10 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
+	bool cpuset_fallback = false;
+
+	if (ac->nodemask != orig_mask)
+		cpuset_fallback = true;
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2908,6 +2913,24 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
+				if (cpuset_fallback)
+					continue;
+
+				if (!ac->nodemask)
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
