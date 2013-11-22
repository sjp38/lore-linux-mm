Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC216B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 01:38:57 -0500 (EST)
Received: by mail-bk0-f50.google.com with SMTP id e11so632148bkh.23
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 22:38:56 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ce2si5532694bkc.185.2013.11.21.22.38.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 22:38:54 -0800 (PST)
Date: Fri, 22 Nov 2013 01:38:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: NUMA? bisected performance regression 3.11->3.12
Message-ID: <20131122063845.GM3556@cmpxchg.org>
References: <528E8FCE.1000707@intel.com>
 <20131122052219.GL3556@cmpxchg.org>
 <528EF744.8040607@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <528EF744.8040607@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kevin Hilman <khilman@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Paul Bolle <paul.bollee@gmail.com>, Zlatko Calusic <zcalusic@bitsync.net>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>

On Thu, Nov 21, 2013 at 10:18:44PM -0800, Dave Hansen wrote:
> On 11/21/2013 09:22 PM, Johannes Weiner wrote:
> >> > It's a 8-socket/160-thread (one NUMA node per socket) system that is not
> >> > under memory pressure during the test.  The latencies are also such that
> >> > vm.zone_reclaim_mode=0.
> > The change will definitely spread allocations out to all nodes then
> > and it's plausible that the remote references will hurt kernel object
> > allocations in a tight loop.  Just to confirm, could you rerun the
> > test with zone_reclaim_mode enabled to make the allocator stay in the
> > local zones?
> 
> Yeah, setting vm.zone_reclaim_mode=1 fixes it pretty instantaneously.
> 
> For what it's worth, I'm pretty convinced that the numbers folks put in
> the SLIT tables are, at best, horribly inconsistent from system to
> system.  At worst, they're utter fabrications not linked at all to the
> reality of the actual latencies.

You mean the reported distances should probably be bigger on this
particular machine?

But even when correct, zone_reclaim_mode might not be the best
predictor.  Just because it's not worth yet to invest direct reclaim
efforts to stay local does not mean that remote references are free.

I'm currently running some tests with the below draft to see if this
would still leave us with enough fairness.  Does the patch restore
performance even with zone_reclaim_mode disabled?

---

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..c77cead 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1926,7 +1926,8 @@ zonelist_scan:
 		 * back to remote zones that do not partake in the
 		 * fairness round-robin cycle of this zonelist.
 		 */
-		if (alloc_flags & ALLOC_WMARK_LOW) {
+		if ((alloc_flags & ALLOC_WMARK_LOW) &&
+		    (gfp_mask & GFP_MOVABLE_MASK)) {
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
 			if (zone_reclaim_mode &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
