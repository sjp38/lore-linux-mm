Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id C0620828DF
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 09:48:29 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so135158700wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:48:29 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m6si4240134wjz.36.2016.03.08.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 06:48:28 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id p65so4531217wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 06:48:28 -0800 (PST)
Date: Tue, 8 Mar 2016 15:48:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom: protect !costly allocations some more
Message-ID: <20160308144827.GK13542@dhcp22.suse.cz>
References: <20160307160838.GB5028@dhcp22.suse.cz>
 <1457444565-10524-1-git-send-email-mhocko@kernel.org>
 <1457444565-10524-4-git-send-email-mhocko@kernel.org>
 <56DEE2FD.4000105@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DEE2FD.4000105@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 08-03-16 15:34:37, Vlastimil Babka wrote:
> On 03/08/2016 02:42 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > should_reclaim_retry will give up retries for higher order allocations
> > if none of the eligible zones has any requested or higher order pages
> > available even if we pass the watermak check for order-0. This is done
> > because there is no guarantee that the reclaimable and currently free
> > pages will form the required order.
> > 
> > This can, however, lead to situations were the high-order request (e.g.
> > order-2 required for the stack allocation during fork) will trigger
> > OOM too early - e.g. after the first reclaim/compaction round. Such a
> > system would have to be highly fragmented and there is no guarantee
> > further reclaim/compaction attempts would help but at least make sure
> > that the compaction was active before we go OOM and keep retrying even
> > if should_reclaim_retry tells us to oom if the last compaction round
> > was either inactive (deferred, skipped or bailed out early due to
> > contention) or it told us to continue.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/linux/compaction.h |  5 +++++
> >  mm/page_alloc.c            | 53 ++++++++++++++++++++++++++++++++--------------
> >  2 files changed, 42 insertions(+), 16 deletions(-)
> > 
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index b167801187e7..49e04326dcb8 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -14,6 +14,11 @@ enum compact_result {
> >  	/* compaction should continue to another pageblock */
> >  	COMPACT_CONTINUE,
> >  	/*
> > +	 * whoever is calling compaction should retry because it was either
> > +	 * not active or it tells us there is more work to be done.
> > +	 */
> > +	COMPACT_SHOULD_RETRY = COMPACT_CONTINUE,
> 
> Hmm, I'm not sure about this. AFAIK compact_zone() doesn't ever return
> COMPACT_CONTINUE, and thus try_to_compact_pages() also doesn't. This
> overloading of CONTINUE only applies to compaction_suitable(). But the
> value that should_compact_retry() is testing comes only from
> try_to_compact_pages(). So this is not wrong, but perhaps a bit misleading?

Well the idea was that I wanted to cover all the _possible_ cases where
compaction might want to tell us "please try again even when the last
round wasn't really successful". COMPACT_CONTINUE might not be returned
right now but we can come up with that in the future. It sounds like a
sensible feedback to me. But maybe there would be a better name for such
a feedback. I confess this is a bit oom-rework centric name...

Also I find it better to hide details behind a more generic name.

I am open to suggestions here, of course.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
