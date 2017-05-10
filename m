Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBF36280730
	for <linux-mm@kvack.org>; Wed, 10 May 2017 03:15:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g67so5689960wrd.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 00:15:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b8si2598157wmi.104.2017.05.10.00.15.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 00:15:12 -0700 (PDT)
Date: Wed, 10 May 2017 09:15:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170510071511.GA31466@dhcp22.suse.cz>
References: <20170510065328.9215-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510065328.9215-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 09-05-17 23:53:28, Nick Desaulniers wrote:
> Clang flags this file with the -Wunsequenced error that GCC does not
> have.
> 
> unsequenced modification and access to 'gfp_mask'
> 
> It seems that gfp_mask is both read and written without a sequence point
> in between, which is undefined behavior.

Hmm. This is rather news to me. I thought that a = foo(a) is perfectly
valid. Same as a = b = c where c = foo(b) or is the problem in the
following .reclaim_idx = gfp_zone(gfp_mask) initialization? If that is
the case then the current code is OKish because gfp_zone doesn't depend
on the gfp_mask modification. It is messy, right, but works as expected.

Anyway, we have a similar construct __node_reclaim

If you really want to change this code, and I would agree it would be
slightly less tricky, then I would suggest doing something like the
following instead
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5ebf468c5429..ba4b695e810e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2965,7 +2965,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
+		.gfp_mask = current_gfp_context(gfp_mask),
 		.reclaim_idx = gfp_zone(gfp_mask),
 		.order = order,
 		.nodemask = nodemask,
@@ -2980,12 +2980,12 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	 * 1 is returned so that the page allocator does not OOM kill at this
 	 * point.
 	 */
-	if (throttle_direct_reclaim(gfp_mask, zonelist, nodemask))
+	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
 		return 1;
 
 	trace_mm_vmscan_direct_reclaim_begin(order,
 				sc.may_writepage,
-				gfp_mask,
+				sc.gfp_mask,
 				sc.reclaim_idx);
 
 	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
@@ -3772,17 +3772,16 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int classzone_idx = gfp_zone(gfp_mask);
 	unsigned int noreclaim_flag;
 	struct scan_control sc = {
 		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
-		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
+		.gfp_mask = current_gfp_context(gfp_mask),
 		.order = order,
 		.priority = NODE_RECLAIM_PRIORITY,
 		.may_writepage = !!(node_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(node_reclaim_mode & RECLAIM_UNMAP),
 		.may_swap = 1,
-		.reclaim_idx = classzone_idx,
+		.reclaim_idx = gfp_znoe(gfp_mask),
 	};
 
 	cond_resched();
@@ -3793,7 +3792,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
 	 */
 	noreclaim_flag = memalloc_noreclaim_save();
 	p->flags |= PF_SWAPWRITE;
-	lockdep_set_current_reclaim_state(gfp_mask);
+	lockdep_set_current_reclaim_state(sc.gfp_mask);
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
