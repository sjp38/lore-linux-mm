Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6AF86B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 06:39:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a136so25314208wme.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 03:39:40 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id a81si49189218wmf.59.2016.06.02.03.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 03:39:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 9A4F31C0F2B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:39:38 +0100 (IST)
Date: Thu, 2 Jun 2016 11:39:37 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Message-ID: <20160602103936.GU2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <574E05B8.3060009@suse.cz>
 <20160601091921.GT2527@techsingularity.net>
 <574EB274.4030408@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <574EB274.4030408@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Wed, Jun 01, 2016 at 12:01:24PM +0200, Vlastimil Babka wrote:
> > Why?
> > 
> > The comment is fine but I do not see why the recalculation would occur.
> > 
> > In the original code, the preferred_zoneref for statistics is calculated
> > based on either the supplied nodemask or cpuset_current_mems_allowed during
> > the initial attempt. It then relies on the cpuset checks in the slowpath
> > to encorce mems_allowed but the preferred zone doesn't change.
> > 
> > With your proposed change, it's possible that the
> > preferred_zoneref recalculation points to a zoneref disallowed by
> > cpuset_current_mems_sllowed. While it'll be skipped during allocation,
> > the statistics will still be against a zone that is potentially outside
> > what is allowed.
> 
> Hmm that's true and I was ready to agree. But then I noticed  that
> gfp_to_alloc_flags() can mask out ALLOC_CPUSET for GFP_ATOMIC. So it's
> like a lighter version of the ALLOC_NO_WATERMARKS situation. In that
> case it's wrong if we leave ac->preferred_zoneref at a position that has
> skipped some zones due to mempolicies?
> 

So both options are wrong then. How about this?

---8<---
mm, page_alloc: Recalculate the preferred zoneref if the context can ignore memory policies

The optimistic fast path may use cpuset_current_mems_allowed instead of
of a NULL nodemask supplied by the caller for cpuset allocations. The
preferred zone is calculated on this basis for statistic purposes and
as a starting point in the zonelist iterator.

However, if the context can ignore memory policies due to being atomic or
being able to ignore watermarks then the starting point in the zonelist
iterator is no longer correct. This patch resets the zonelist iterator in
the allocator slowpath if the context can ignore memory policies. This will
alter the zone used for statistics but only after it is known that it makes
sense for that context. Resetting it before entering the slowpath would
potentially allow an ALLOC_CPUSET allocation to be accounted for against
the wrong zone. Note that while nodemask is not explicitly set to the
original nodemask, it would only have been overwritten if cpuset_enabled()
and it was reset before the slowpath was entered.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 557549c81083..b17358617a1b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3598,6 +3598,17 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	alloc_flags = gfp_to_alloc_flags(gfp_mask);
 
+	/*
+	 * Reset the zonelist iterators if memory policies can be ignored.
+	 * These allocations are high priority and system rather than user
+	 * orientated.
+	 */
+	if ((alloc_flags & ALLOC_NO_WATERMARKS) || !(alloc_flags & ALLOC_CPUSET)) {
+		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
+		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
+					ac->high_zoneidx, ac->nodemask);
+	}
+
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
@@ -3606,12 +3617,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Allocate without watermarks if the context allows */
 	if (alloc_flags & ALLOC_NO_WATERMARKS) {
-		/*
-		 * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
-		 * the allocation is high priority and these type of
-		 * allocations are system rather than user orientated
-		 */
-		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		page = get_page_from_freelist(gfp_mask, order,
 						ALLOC_NO_WATERMARKS, ac);
 		if (page)
@@ -3810,7 +3815,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	/* Dirty zone balancing only done in the fast path */
 	ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
 
-	/* The preferred zone is used for statistics later */
+	/*
+	 * The preferred zone is used for statistics but crucially it is
+	 * also used as the starting point for the zonelist iterator. It
+	 * may get reset for allocations that ignore memory policies.
+	 */
 	ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
 					ac.high_zoneidx, ac.nodemask);
 	if (!ac.preferred_zoneref) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
