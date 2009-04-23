Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9F66B0062
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:36:26 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NHXMcf006867
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:33:22 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NHasNT152932
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:36:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NHZ6lp001115
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 13:35:07 -0400
Subject: Re: [PATCH 02/22] Do not sanity check order in the fast path
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090423095821.GA25102@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-3-git-send-email-mel@csn.ul.ie>
	 <1240416791.10627.78.camel@nimitz> <20090422171151.GF15367@csn.ul.ie>
	 <1240421415.10627.93.camel@nimitz> <20090423001311.GA26643@csn.ul.ie>
	 <1240450447.10627.119.camel@nimitz>  <20090423095821.GA25102@csn.ul.ie>
Content-Type: text/plain
Date: Thu, 23 Apr 2009 10:36:50 -0700
Message-Id: <1240508211.10627.139.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-04-23 at 10:58 +0100, Mel Gorman wrote:
> > How about this:  I'll go and audit the use of order in page_alloc.c to
> > make sure that having an order>MAX_ORDER-1 floating around is OK and
> > won't break anything. 
> 
> Great. Right now, I think it's ok but I haven't audited for this
> explicily and a second set of eyes never hurts.

OK, after looking through this, I have a couple of ideas.  One is that
we do the MAX_ORDER check in __alloc_pages_internal(), but *after* the
first call to get_page_from_freelist().  That's because I'm worried if
we ever got into the reclaim code with a >MAX_ORDER 'order'.  Such as:

void wakeup_kswapd(struct zone *zone, int order)
{
...
        if (pgdat->kswapd_max_order < order)
                pgdat->kswapd_max_order = order;
        if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
                return;
        if (!waitqueue_active(&pgdat->kswapd_wait))
                return;
        wake_up_interruptible(&pgdat->kswapd_wait);
}

unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
                                gfp_t gfp_mask, nodemask_t *nodemask)
{
        struct scan_control sc = {
...
                .order = order,
                .mem_cgroup = NULL,
                .isolate_pages = isolate_pages_global,
                .nodemask = nodemask,
        };

        return do_try_to_free_pages(zonelist, &sc);
}

This will keep us only checking 'order' once for each
alloc_pages_internal() call.  It is an extra branch, but it is out of
the really, really hot path since we're about to start reclaim here
anyway.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e2f2699..1e3a01e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1498,6 +1498,13 @@ restart:
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)
 		goto got_pg;
+	/*
+	 * We're out of the rocket-hot area above, so do a quick sanity
+	 * check.  We do this here to avoid ever trying to do any reclaim
+	 * of >=MAX_ORDER areas which can never succeed, of course.
+	 */
+	if (order >= MAX_ORDER)
+		goto nopage;
 
 	/*
 	 * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
