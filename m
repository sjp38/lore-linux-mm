Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B12A26B051F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:58:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i187so14139531wma.15
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:58:27 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id j33si10308133ede.404.2017.07.28.03.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 03:58:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 0FBFD1C2280
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:58:26 +0100 (IST)
Date: Fri, 28 Jul 2017 11:58:25 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC PATCH 6/6] mm: make kcompactd more proactive
Message-ID: <20170728105825.kofzpchclcngdk7c@techsingularity.net>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <20170727160701.9245-7-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727160701.9245-7-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Jul 27, 2017 at 06:07:01PM +0200, Vlastimil Babka wrote:
> Kcompactd activity is currently tied to kswapd - it is woken up when kswapd
> goes to sleep, and compacts to make a single high-order page available, of the
> order that was used to wake up kswapd. This leaves the rest of free pages
> fragmented and results in direct compaction when the demand for fresh
> high-order pages is higher than a single page per kswapd cycle.
> 
> Another extreme would be to let kcompactd compact whole zone the same way as
> manual compaction from /proc interface. This would be wasteful if the resulting
> high-order pages would be not needed, but just split back to base pages for
> allocations.
> 
> This patch aims to adjust the kcompactd effort through observed demand for
> high-order pages. This is done by hooking into alloc_pages_slowpath() and
> counting (per each order > 0) allocation attempts that would pass the order-0
> watermarks, but don't have the high-order page available. This demand is
> (currently) recorded per node and then redistributed per zones in each node
> according to their relative sizes.
> 
> The redistribution considers the current recorded failed attempts together with
> the value used in the previous kcompactd cycle. If there were any recorded
> failed attempts for the current cycle, it means the previous kcompactd activity
> was insufficient, so the two values are added up. If there were zero failed
> attempts it means either the previous amount of activity was optimum, or that
> the demand decreased. We cannot know that without recording also successful
> attempts, which would add overhead to allocator fast paths, so we use
> exponential moving average to decay the kcompactd target in such case.
> In any case, the target is capped to high watermark worth of base pages, since
> that's the kswapd's target when balancing.
> 
> Kcompactd then uses a different termination criteria than direct compaction.
> It checks whether for each order, the recorded number of attempted allocations
> would fit within the free pages of that order of with possible splitting of
> higher orders, assuming there would be no allocations of other orders. This
> should make kcompactd effort reflect the high-order demand.
> 
> In the worst case, the demand is so high that kcompactd will in fact compact
> the whole zone and would have to be run with higher frequency than kswapd to
> make a larger difference. That possibility can be explored later.

Very broadly speaking, I can't see a problem with the direction you are
taking. Misc comments are

o kcompactd_inc_free_target is a bit excessive without data backing it
  up. It's overkill to go through every allowed node incrementing counters
  in the page allocator slow path. It's not even necessarily a good idea
  because it's hard to reason what impact that has on how the attempts get
  decayed and what impact it can have on remote nodes that.  At a first
  cut, I would have thought incrementing the preferred zone only would be
  reasonable. If there are concerns about small high zones then every zone
  in the local node and do not bother with the cpuset checks. Overall, don't
  worry about the remote nodes unless there is strong evidence it's needed.

o Similarly, it's not clear how much benefit there is to spreading
  targets across zones and the compexity in there. I would suggest
  keeping kcompactd_inc_free_target as simple as possible for as long as
  possible. While it's called from the page allocator slowpath for high-order
  allocations only, we shouldn't pay costs there unless we have to.

o The atomics seem a little overkill considering that this is just a
  heuristic hint. If lost updates happen, it's not that big a deal and
  at worst, there is a spurious compaction run just as the counters hit
  0. That corner case is marginal compared to the atomic overheads. Just
  watch for going negative due to the races which is a minor fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
