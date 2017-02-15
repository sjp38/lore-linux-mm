Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E4F1680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:28:22 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j13so141514675iod.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 20:28:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h68si2970324ith.114.2017.02.14.20.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 20:28:21 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1F4NbBi024487
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:28:20 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28mb5bgwcn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 23:28:20 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Feb 2017 14:28:17 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 98F162CE8054
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:28:14 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1F4S64437355580
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:28:14 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1F4Rg7E016715
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 15:27:42 +1100
Subject: Re: [PATCH V2 3/3] mm: Enable Buddy allocation isolation for CDM
 nodes
References: <20170210100640.26927-1-khandual@linux.vnet.ibm.com>
 <20170210100640.26927-4-khandual@linux.vnet.ibm.com>
 <44bbca4e-af5a-805c-c74b-28e684026611@suse.cz>
 <aed94333-7cd7-958e-ff8c-78a6cf05fe45@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 09:57:19 +0530
MIME-Version: 1.0
In-Reply-To: <aed94333-7cd7-958e-ff8c-78a6cf05fe45@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <628673ca-15ee-c1be-ad53-3809f83722d7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On 02/14/2017 03:44 PM, Anshuman Khandual wrote:
> On 02/14/2017 01:58 PM, Vlastimil Babka wrote:
>> On 02/10/2017 11:06 AM, Anshuman Khandual wrote:
>>> This implements allocation isolation for CDM nodes in buddy allocator by
>>> discarding CDM memory zones all the time except in the cases where the gfp
>>> flag has got __GFP_THISNODE or the nodemask contains CDM nodes in cases
>>> where it is non NULL (explicit allocation request in the kernel or user
>>> process MPOL_BIND policy based requests).
>>>
>>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>> ---
>>>  mm/page_alloc.c | 16 ++++++++++++++++
>>>  1 file changed, 16 insertions(+)
>>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 84d61bb..392c24a 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -64,6 +64,7 @@
>>>  #include <linux/page_owner.h>
>>>  #include <linux/kthread.h>
>>>  #include <linux/memcontrol.h>
>>> +#include <linux/node.h>
>>>  
>>>  #include <asm/sections.h>
>>>  #include <asm/tlbflush.h>
>>> @@ -2908,6 +2909,21 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>>>  		struct page *page;
>>>  		unsigned long mark;
>>>  
>>> +		/*
>>> +		 * CDM nodes get skipped if the requested gfp flag
>>> +		 * does not have __GFP_THISNODE set or the nodemask
>>> +		 * does not have any CDM nodes in case the nodemask
>>> +		 * is non NULL (explicit allocation requests from
>>> +		 * kernel or user process MPOL_BIND policy which has
>>> +		 * CDM nodes).
>>> +		 */
>>> +		if (is_cdm_node(zone->zone_pgdat->node_id)) {
>>> +			if (!(gfp_mask & __GFP_THISNODE)) {
>>> +				if (!ac->nodemask)
>>> +					continue;
>>> +			}
>>> +		}
>>
>> With the current cpuset implementation, this will have a subtle corner
>> case when allocating from a cpuset that allows the cdm node, and there
>> is no (task or vma) mempolicy applied for the allocation. In the fast
>> path (__alloc_pages_nodemask()) we'll set ac->nodemask to
>> current->mems_allowed, so your code will wrongly assume that this
>> ac->nodemask is a policy that allows the CDM node. Probably not what you
>> want?
> 
> You are right, its a problem and not what we want. We can make the
> function get_page_from_freelist() take another parameter "orig_nodemask"
> which gets passed into __alloc_pages_nodemask() in the first place. So
> inside zonelist iterator we can compare orig_nodemask with current
> ac.nodemask to figure out if cpuset swapping of nodemask happened and
> skip CDM node if necessary. Thats a viable solution IMHO.

Hello Vlastimil,

As I mentioned before yesterday this solution works and tested to verify that
there is no allocation leak happening to CDM even after cpuset_enabled() is 
turned ON after changing /sys/fs/cgroup/cpuset/ setup. Major part of the change
is just to add an additional parameter into the function get_page_from_freelist
and changing all it's call sites.

- Anshuman

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 392c24a..9f41e0f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2894,11 +2894,15 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  */
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
-						const struct alloc_context *ac)
+			const struct alloc_context *ac, nodemask_t *orig_mask)
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
 	struct pglist_data *last_pgdat_dirty_limit = NULL;
+	bool cpuset_fallback;
+
+	if (ac->nodemask != orig_mask)
+		cpuset_fallback = true;
 
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -2919,6 +2923,9 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 		 */
 		if (is_cdm_node(zone->zone_pgdat->node_id)) {
 			if (!(gfp_mask & __GFP_THISNODE)) {
+				if (cpuset_fallback)
+					continue;
+
 				if (!ac->nodemask)
 					continue;
 			}
@@ -3066,7 +3073,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 
 static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
-	const struct alloc_context *ac, unsigned long *did_some_progress)
+	const struct alloc_context *ac, unsigned long *did_some_progress, nodemask_t *orig_mask)
 {
 	struct oom_control oc = {
 		.zonelist = ac->zonelist,
@@ -3095,7 +3102,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	 * we're still under heavy pressure.
 	 */
 	page = get_page_from_freelist(gfp_mask | __GFP_HARDWALL, order,
-					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
+					ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac, orig_mask);
 	if (page)
 		goto out;
 
@@ -3131,14 +3138,14 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 
 		if (gfp_mask & __GFP_NOFAIL) {
 			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac, orig_mask);
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
@@ -3157,7 +3164,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result, nodemask_t *orig_mask)
 {
 	struct page *page;
 
@@ -3178,7 +3185,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac, orig_mask);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -3263,7 +3270,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result, nodemask_t *orig_mask)
 {
 	*compact_result = COMPACT_SKIPPED;
 	return NULL;
@@ -3330,7 +3337,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		unsigned long *did_some_progress)
+		unsigned long *did_some_progress, nodemask_t *orig_mask)
 {
 	struct page *page = NULL;
 	bool drained = false;
@@ -3340,7 +3347,7 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac, orig_mask);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -3533,7 +3540,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
-						struct alloc_context *ac)
+				struct alloc_context *ac, nodemask_t *orig_mask)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
 	struct page *page = NULL;
@@ -3597,7 +3604,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	 * The adjusted alloc_flags might result in immediate success, so try
 	 * that first
 	 */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3612,7 +3619,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						alloc_flags, ac,
 						INIT_COMPACT_PRIORITY,
-						&compact_result);
+						&compact_result, orig_mask);
 		if (page)
 			goto got_pg;
 
@@ -3661,7 +3668,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3697,13 +3704,13 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
-							&did_some_progress);
+							&did_some_progress, orig_mask);
 	if (page)
 		goto got_pg;
 
 	/* Try direct compaction and then allocating */
 	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
-					compact_priority, &compact_result);
+					compact_priority, &compact_result, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3750,7 +3757,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto retry_cpuset;
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress, orig_mask);
 	if (page)
 		goto got_pg;
 
@@ -3842,7 +3849,7 @@ struct page *
 	}
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac, nodemask);
 	if (likely(page))
 		goto out;
 
@@ -3861,7 +3868,7 @@ struct page *
 	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
 
-	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	page = __alloc_pages_slowpath(alloc_mask, order, &ac, nodemask);
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
