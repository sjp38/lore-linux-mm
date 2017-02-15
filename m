Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4E7F4405A3
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:44 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 101so152560571iom.7
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 04:07:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j130si3865942iof.9.2017.02.15.04.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 04:07:44 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1FC4bBw069447
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:43 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28mjud1c8a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 07:07:43 -0500
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 17:37:38 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6422AE005F
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:39:08 +0530 (IST)
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1FC7XV438862894
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:33 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1FC7XVT012615
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:37:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH V3 3/4] mm: Add new parameter to get_page_from_freelist() function
Date: Wed, 15 Feb 2017 17:37:25 +0530
In-Reply-To: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170215120726.9011-4-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

This changes the function get_page_from_freelist to accommodate a new
parameter orig_mask which preserves the requested nodemask till the
zonelist iteration phase where it can be used to verify if the cpuset
based nodemask override is ever performed. This enables deciding the
acceptance of CDM zone during allocation which is implemented in the
subsequent patch.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 84d61bb..afbd24d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2893,7 +2893,7 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
-						const struct alloc_context *ac)
+			const struct alloc_context *ac, nodemask_t *orig_mask)
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
@@ -3050,7 +3050,8 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+	const struct alloc_context *ac, unsigned long *did_some_progress,
+	nodemask_t *orig_mask)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3079,7 +3080,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * we're still under heavy pressure.
 	 */
 	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
-					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET,
+					ac, orig_mask);
 	if (page)
 		goto out;
 
@@ -3115,14 +3117,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 
 		if (gfp_mask & __GFP_NOFAIL) {
 			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET,
+					ac, orig_mask);
 			/*
 			 * fallback to ignore cpuset restriction if our nodes
 			 * are depleted
 			 */
 			if (!page)
 				page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
+					ALLOC_NO_WATERMARKS, ac, orig_mask);
 		}
 	}
 out:
@@ -3141,7 +3144,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result,
+		nodemask_t *orig_mask)
 {
 	struct page *page;
 
@@ -3162,8 +3166,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
-
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags, ac, orig_mask);
 	if (page) {
 		struct zone *zone = page_zone(page);
 
@@ -3247,7 +3251,8 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result,
+		nodemask_t *orig_mask)
 {
 	*compact_result = COMPACT_SKIPPED;
 	return NULL;
@@ -3314,7 +3319,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		unsigned long *did_some_progress)
+		unsigned long *did_some_progress, nodemask_t *orig_mask)
 {
 	struct page *page = NULL;
 	bool drained = false;
@@ -3324,7 +3329,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags, ac, orig_mask);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -3517,7 +3523,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-						struct alloc_context *ac)
+			struct alloc_context *ac, nodemask_t *orig_mask)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
@@ -3581,7 +3587,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * The adjusted alloc_flags might result in immediate success, so try
 	 * that first
 	 */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags, ac, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3596,7 +3603,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						alloc_flags, ac,
 						INIT_COMPACT_PRIORITY,
-						&compact_result);
+						&compact_result, orig_mask);
 		if (page)
 			goto got_pg;
 
@@ -3645,7 +3652,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order,
+					alloc_flags, ac, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3681,13 +3689,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
-							&did_some_progress);
+						&did_some_progress, orig_mask);
 	if (page)
 		goto got_pg;
 
 	/* Try direct compaction and then allocating */
 	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
-					compact_priority, &compact_result);
+				compact_priority, &compact_result, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3734,7 +3742,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto retry_cpuset;
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, ac,
+					&did_some_progress, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3826,7 +3835,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask, order,
+					alloc_flags, &ac, nodemask);
 	if (likely(page))
 		goto out;
 
@@ -3845,7 +3855,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
 
-	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	page = __alloc_pages_slowpath(alloc_mask, order, &ac, nodemask);
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
