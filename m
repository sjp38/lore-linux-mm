Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 17E7F6B005A
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 11:12:22 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 11:12:20 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AC49C6E8049
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 11:11:37 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q59FBbfU085980
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 11:11:37 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59KgT7X012697
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 16:42:29 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/buddy: fix default NUMA nodes
Date: Sun, 10 Jun 2012 00:11:27 +0900
Message-Id: <1339254687-13447-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

In the core function __alloc_pages_nodemask() of buddy allocator,
the NUMA nodes would be allowed nodes of current process or online
high memory nodes if the nodemask passed into the function is NULL.
However, the current implementation of function __alloc_pages_nodemask()
might retrieve the preferred zones from the allowed nodes of current
process or online high memory nodes, but never use that in the case.

The patch fixes that. When the nodemask passed into __alloc_pages_nodemask()
is NULL. We will always use the nodemask from the allowed one of
current process or online high memory nodes.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/page_alloc.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7892f84..dda83c5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2474,6 +2474,7 @@ struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 			struct zonelist *zonelist, nodemask_t *nodemask)
 {
+	nodemask_t *preferred_nodemask = nodemask ? : &cpuset_current_mems_allowed;
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
 	struct page *page = NULL;
@@ -2501,19 +2502,18 @@ retry_cpuset:
 	cpuset_mems_cookie = get_mems_allowed();
 
 	/* The preferred zone is used for statistics later */
-	first_zones_zonelist(zonelist, high_zoneidx,
-				nodemask ? : &cpuset_current_mems_allowed,
+	first_zones_zonelist(zonelist, high_zoneidx, preferred_nodemask,
 				&preferred_zone);
 	if (!preferred_zone)
 		goto out;
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
+	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, preferred_nodemask,
+			order, zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
 			preferred_zone, migratetype);
 	if (unlikely(!page))
-		page = __alloc_pages_slowpath(gfp_mask, order,
-				zonelist, high_zoneidx, nodemask,
+		page = __alloc_pages_slowpath(gfp_mask, order, zonelist,
+				high_zoneidx, preferred_nodemask,
 				preferred_zone, migratetype);
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
