Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5910B6B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 18:00:48 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so109526301lfb.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 15:00:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si18309835wmb.62.2016.09.18.15.00.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 15:00:46 -0700 (PDT)
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6aa81fe3-7f04-78d7-d477-609a7acd351a@suse.cz>
Date: Mon, 19 Sep 2016 00:00:24 +0200
MIME-Version: 1.0
In-Reply-To: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/18/2016 10:03 PM, Linus Torvalds wrote:
> [ More or less random collection of people from previous oom patches 
> and/or discussions, if you feel you shouldn't have been cc'd, blame
> me for just picking things from earlier threads and/or commits ]
> 
> I'm afraid that the oom situation is still not fixed, and the "let's 
> die quickly" patches are still a nasty regression.

So I'm trying to understand the core of the regression compared to
pre-4.7. It can't be the compaction feedback, as that was reverted, and
compaction itself shouldn't perform worse than pre-4.7. This leaves us
with should_reclaim_retry() false. This can return false if:

1) no_progress_loops > MAX_RECLAIM_RETRIES

But we have in __allow_pages_slowpath() this:

if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
no_progress_loops = 0;

I doubt reclaim makes no progress in your case, and the non-costly order
is also true. So, unlikely.

2) The watermark check that includes estimate for pages available for
reclaim fails.

Could be the backoff in calculation of "available" in
should_reclaim_retry() is too aggressive. But it depends on the
no_progress_loops which I think is 0 (see above). Again, unlikely.

But the watermark check doesn't actually work for order-1+ allocations,
the "available" estimate only affects order-0 check. For higher orders
it will be false if the page of sufficient order doesn't already exist.
That's fine if we trust should_compact_retry() in such case.

But Joonsoo already had a theoretical scenario where this can fall apart:
http://lkml.kernel.org/r/<20160824050157.GA22781@js1304-P5Q-DELUXE>

See the part that starts at "Assume following situation:". I suspect
something like that happened here.

I think at least temporarily we'll have to make the watermark check
to be order-0 check for non-costly orders.

Something like below (untested)?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a2214c64ed3c..9b3b3a79c58a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3347,17 +3347,24 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 					ac->nodemask) {
 		unsigned long available;
 		unsigned long reclaimable;
+		int check_order = order;
+		unsigned long watermark = min_wmark_pages(zone);
 
 		available = reclaimable = zone_reclaimable_pages(zone);
 		available -= DIV_ROUND_UP(no_progress_loops * available,
 					  MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
+		if (order > 0 && order <= PAGE_ALLOC_COSTLY_ORDER) {
+			check_order = 0;
+			watermark += 1UL << order;
+		}
+
 		/*
 		 * Would the allocation succeed if we reclaimed the whole
 		 * available?
 		 */
-		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+		if (__zone_watermark_ok(zone, check_order, watermark,
 				ac_classzone_idx(ac), alloc_flags, available)) {
 			/*
 			 * If we didn't make any progress and have a lot of

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
