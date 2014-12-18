Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 021336B0075
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 19:51:25 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id l13so74467iga.2
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:51:24 -0800 (PST)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id p9si4898523igx.39.2014.12.17.16.51.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 16:51:23 -0800 (PST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so209358iec.1
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 16:51:23 -0800 (PST)
Date: Wed, 17 Dec 2014 16:51:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/6] mm/page_alloc.c:__alloc_pages_nodemask(): don't
 alter arg gfp_mask
In-Reply-To: <20141217162905.9bc063be55a341d40b293c72@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1412171642370.23841@chino.kir.corp.google.com>
References: <548f68b5.yNW2nTZ3zFvjiAsf%akpm@linux-foundation.org> <548F6F94.2020209@jp.fujitsu.com> <20141215154323.08cc8e7d18ef78f19e5ecce2@linux-foundation.org> <alpine.DEB.2.10.1412171608300.16260@chino.kir.corp.google.com>
 <20141217162905.9bc063be55a341d40b293c72@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, hannes@cmpxchg.org, mel@csn.ul.ie, ming.lei@canonical.com

On Wed, 17 Dec 2014, Andrew Morton wrote:

> > The above is wrong because it unconditionally sets __GFP_HARDWALL as the 
> > gfp mask for __alloc_pages_slowpath() when we actually only want that for 
> > the first allocation attempt, it's needed for the implementation of 
> > __cpuset_node_allowed().
> 
> no,
> 
> : 	/* First allocation attempt */
> : 	mask = gfp_mask|__GFP_HARDWALL;
> : 	page = get_page_from_freelist(mask, nodemask, order, zonelist,
> : 			high_zoneidx, alloc_flags, preferred_zone,
> : 			classzone_idx, migratetype);
> : 	if (unlikely(!page)) {
> : 		/*
> : 		 * Runtime PM, block IO and its error handling path
> : 		 * can deadlock because I/O on the device might not
> : 		 * complete.
> : 		 */
> : 		mask = memalloc_noio_flags(gfp_mask);
> 
> ^^ this
> 
> : 		page = __alloc_pages_slowpath(mask, order,
> : 				zonelist, high_zoneidx, nodemask,
> : 				preferred_zone, classzone_idx, migratetype);
> : 	}
> : 
> : 	trace_mm_page_alloc(page, order, mask, migratetype);
> 

Sorry, I should have applied the patch locally to look at it.

> > The page allocator slowpath is always called from the fastpath if the 
> > first allocation didn't succeed, so we don't know from which we allocated 
> > the page at this tracepoint.
> 
> True, but the idea is that when we call trace_mm_page_alloc(), local
> var `mask' holds the gfp_t which was used in the most recent allocation
> attempt.
> 

So if the fastpath succeeds, which should be the majority of the time, 
then we get a tracepoint here that says we allocated with 
__GFP_FS | __GFP_IO even though we may have PF_MEMALLOC_NOIO set.  So if 
page != NULL, we can know that either the fastpath succeeded or we don't 
have PF_MEMALLOC_NOIO and were allowed to reclaim.  Not sure that's very 
helpful.

Easiest thing to do would be to just clear __GFP_FS and __GFP_IO when we 
clear everything not in gfp_allowed_mask, but that's pointless if the 
fastpath succeeds.  I'm not sure it's worth to restructure the code with a 
possible performance overhead for the benefit of a tracepoint.

And then there's the call to lockdep_trace_alloc() which does care about 
__GFP_FS.  That looks broken because we need to clear __GFP_FS with 
PF_MEMALLOC_NOIO.

I think that should be

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2871,7 +2873,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	gfp_mask &= gfp_allowed_mask;
 
-	lockdep_trace_alloc(gfp_mask);
+	lockdep_trace_alloc(memalloc_noio_flags(gfp_mask));
 
 	might_sleep_if(gfp_mask & __GFP_WAIT);
 
Wow.  I think we should just trace gfp_mask & gfp_allowed_mask and pass a 
bit to say whether PF_MEMALLOC_NOIO is set or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
