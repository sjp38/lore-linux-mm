Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 303DD6B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 06:33:39 -0400 (EDT)
Date: Fri, 24 Apr 2009 11:34:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
Message-ID: <20090424103405.GC14283@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-3-git-send-email-mel@csn.ul.ie> <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie> <1240421415.10627.93.camel@nimitz> <20090423001311.GA26643@csn.ul.ie> <1240450447.10627.119.camel@nimitz> <20090423095821.GA25102@csn.ul.ie> <1240508211.10627.139.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240508211.10627.139.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 23, 2009 at 10:36:50AM -0700, Dave Hansen wrote:
> On Thu, 2009-04-23 at 10:58 +0100, Mel Gorman wrote:
> > > How about this:  I'll go and audit the use of order in page_alloc.c to
> > > make sure that having an order>MAX_ORDER-1 floating around is OK and
> > > won't break anything. 
> > 
> > Great. Right now, I think it's ok but I haven't audited for this
> > explicily and a second set of eyes never hurts.
> 
> OK, after looking through this, I have a couple of ideas.  One is that
> we do the MAX_ORDER check in __alloc_pages_internal(), but *after* the
> first call to get_page_from_freelist().  That's because I'm worried if
> we ever got into the reclaim code with a >MAX_ORDER 'order'.  Such as:
> 
> void wakeup_kswapd(struct zone *zone, int order)
> {
> ...
>         if (pgdat->kswapd_max_order < order)
>                 pgdat->kswapd_max_order = order;
>         if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>                 return;
>         if (!waitqueue_active(&pgdat->kswapd_wait))
>                 return;
>         wake_up_interruptible(&pgdat->kswapd_wait);
> }
> 
> unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>                                 gfp_t gfp_mask, nodemask_t *nodemask)
> {
>         struct scan_control sc = {
> ...
>                 .order = order,
>                 .mem_cgroup = NULL,
>                 .isolate_pages = isolate_pages_global,
>                 .nodemask = nodemask,
>         };
> 
>         return do_try_to_free_pages(zonelist, &sc);
> }
> 

That is perfectly rational.

> This will keep us only checking 'order' once for each
> alloc_pages_internal() call.  It is an extra branch, but it is out of
> the really, really hot path since we're about to start reclaim here
> anyway.
> 

I combined yours and Andrew's suggestions into a patch that applies on
top of the series. Dave, as it's basically your patch it needs your
sign-off if you agree it's ok.

I tested this with a bodge that allocates with increasing orders up to a
very large number.  As you'd expect, it worked until it hit order-11 on an
x86 machine and failed for every higher order by returning NULL.

It reports a warning once. We'll probably drop the warning in time but this
will be a chance to check if there are callers that really are being stupid
and are not just callers that are trying to get the best buffer for the job.

=====
Sanity check order in the page allocator slow path

Callers may speculatively call different allocators in order of preference
trying to allocate a buffer of a given size. The order needed to allocate
this may be larger than what the page allocator can normally handle. While
the allocator mostly does the right thing, it should not direct reclaim or
wakeup kswapd with a bogus order. This patch sanity checks the order in the
slow path and returns NULL if it is too large.

Needs-signed-off-by from Dave Hansen here before merging. Based on his
not-signed-off-by patch.
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1464aca..1c60141 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1434,7 +1434,6 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 
 	classzone_idx = zone_idx(preferred_zone);
-	VM_BUG_ON(order >= MAX_ORDER);
 
 zonelist_scan:
 	/*
@@ -1692,6 +1691,15 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct task_struct *p = current;
 
 	/*
+	 * In the slowpath, we sanity check order to avoid ever trying to
+	 * reclaim >= MAX_ORDER areas which will never succeed. Callers may
+	 * be using allocators in order of preference for an area that is
+	 * too large. 
+	 */
+	if (WARN_ON_ONCE(order >= MAX_ORDER))
+		return NULL;
+
+	/*
 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
 	 * __GFP_NOWARN set) should not cause reclaim since the subsystem
 	 * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
