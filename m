Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 840716B038A
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:52 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y196so45189015ity.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:07:52 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k22si392254iti.62.2017.02.10.02.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 02:07:51 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1AA478o100840
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:51 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28gxd2kvkj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:07:50 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 10 Feb 2017 20:07:48 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 5C10A2BB0059
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:45 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1AA7be913369524
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:45 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1AA7Clx002249
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 21:07:13 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V2 3/3] mm: Enable Buddy allocation isolation for CDM nodes
Date: Fri, 10 Feb 2017 15:36:40 +0530
In-Reply-To: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170210100640.26927-4-khandual@linux.vnet.ibm.com>
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
 mm/page_alloc.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 84d61bb..392c24a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -64,6 +64,7 @@
 #include <linux/page_owner.h>
 #include <linux/kthread.h>
 #include <linux/memcontrol.h>
+#include <linux/node.h>
 
 #include <asm/sections.h>
 #include <asm/tlbflush.h>
@@ -2908,6 +2909,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
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
