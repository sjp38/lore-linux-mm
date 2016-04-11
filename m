Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7586B0253
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:14:13 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id v188so90764279wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:14:13 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id q7si29245027wjo.248.2016.04.11.08.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 08:14:12 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a140so22007091wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:14:12 -0700 (PDT)
Date: Mon, 11 Apr 2016 17:14:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 09/11] mm, compaction: Abstract compaction feedback to
 helpers
Message-ID: <20160411151410.GL23157@dhcp22.suse.cz>
References: <1459855533-4600-1-git-send-email-mhocko@kernel.org>
 <1459855533-4600-10-git-send-email-mhocko@kernel.org>
 <570BB719.2030007@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <570BB719.2030007@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonsoo Kim <js1304@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 11-04-16 16:39:21, Vlastimil Babka wrote:
> On 04/05/2016 01:25 PM, Michal Hocko wrote:
[...]
> >+/* Compaction has failed and it doesn't make much sense to keep retrying. */
> >+static inline bool compaction_failed(enum compact_result result)
> >+{
> >+	/* All zones where scanned completely and still not result. */
> 
> Hmm given that try_to_compact_pages() uses a max() on results, then in fact
> it takes only one zone to get this. Others could have been also SKIPPED or
> DEFERRED. Is that what you want?

In short I didn't find any better way and still guarantee a some
guarantee of convergence. COMPACT_COMPLETE means that at least one zone
was completely scanned and led to no result. That zone would be
compact_suitable by definition. If I made DEFERRED or SKIPPED more
priorite (aka higher in the enum) then I could easily end up in a state
where all zones would return COMPACT_COMPLETE and few remaining would
just alternate returning their DEFFERED resp. SKIPPED. So while this
might sound like giving up too early I couldn't come up with anything
more specific that would lead to reliable results.

I am open to any suggestions of course.

[...]
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -3362,25 +3362,12 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (page)
> >  		goto got_pg;
> >
> >-	/* Checks for THP-specific high-order allocations */
> >-	if (is_thp_gfp_mask(gfp_mask)) {
> >-		/*
> >-		 * If compaction is deferred for high-order allocations, it is
> >-		 * because sync compaction recently failed. If this is the case
> >-		 * and the caller requested a THP allocation, we do not want
> >-		 * to heavily disrupt the system, so we fail the allocation
> >-		 * instead of entering direct reclaim.
> >-		 */
> >-		if (compact_result == COMPACT_DEFERRED)
> >-			goto nopage;
> >-
> >-		/*
> >-		 * Compaction is contended so rather back off than cause
> >-		 * excessive stalls.
> >-		 */
> >-		if(compact_result == COMPACT_CONTENDED)
> >-			goto nopage;
> >-	}
> >+	/*
> >+	 * Checks for THP-specific high-order allocations and back off
> >+	 * if the the compaction backed off
> >+	 */
> >+	if (is_thp_gfp_mask(gfp_mask) && compaction_withdrawn(compact_result))
> >+		goto nopage;
> 
> The change of semantics for THP is not trivial here and should at least be
> discussed in changelog. CONTENDED and DEFERRED is only subset of
> compaction_withdrawn() as seen above.

True. My main motivation was to get rid of the compaction specific code
from the allocator path as much as possible. I can drop the above hunk
of course but I think we should get rid of these checks and make the
code simpler. To be honest I am not even sure those changes are really
measurable.

> Why is it useful to back off due to
> COMPACT_PARTIAL_SKIPPED (we were just unlucky in our starting position), but
> not due to COMPACT_COMPLETE (we have seen the whole zone but failed anyway)?

OK, that is a good remark. I could change that to:
	if (is_thp_gfp_mask(gfp_mask) &&
		(compaction_withdrawn(compact_result) || compaction_failed(compact_result))

> Why back off due to COMPACT_SKIPPED (not enough order-0 pages) without
> trying reclaim at least once, and then another async compaction, like
> before?

The idea was that COMPACT_SKIPPED wouldn't change after a single reclaim
round most of the time because a zone would have to get above
low_wmark + 1<<9 pages.  So the only situation where it would matter would be if
we had some order-9 pages available hidden by the min wmark and we would
reclaim enough to get above the above gap. I am not sure this is what we
really want in the first place. Increase the reclaim stalls when we are
getting under memory pressure.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
