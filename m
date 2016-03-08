Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B85E16B0255
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 04:46:15 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so141918884wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:46:15 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id o63si19843923wmb.95.2016.03.08.01.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 01:46:14 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id l68so122942564wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 01:46:14 -0800 (PST)
Date: Tue, 8 Mar 2016 10:46:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
Message-ID: <20160308094612.GB13542@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <56DE9A68.2010301@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DE9A68.2010301@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Tue 08-03-16 10:24:56, Vlastimil Babka wrote:
[...]
> > @@ -2819,28 +2819,22 @@ static struct page *
> >  __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
> >  		int alloc_flags, const struct alloc_context *ac,
> >  		enum migrate_mode mode, int *contended_compaction,
> > -		bool *deferred_compaction)
> > +		unsigned long *compact_result)
> >  {
> > -	unsigned long compact_result;
> >  	struct page *page;
> >  
> > -	if (!order)
> > +	if (!order) {
> > +		*compact_result = COMPACT_NONE;
> >  		return NULL;
> > +	}
> >  
> >  	current->flags |= PF_MEMALLOC;
> > -	compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> > +	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
> >  						mode, contended_compaction);
> >  	current->flags &= ~PF_MEMALLOC;
> >  
> > -	switch (compact_result) {
> > -	case COMPACT_DEFERRED:
> > -		*deferred_compaction = true;
> > -		/* fall-through */
> > -	case COMPACT_SKIPPED:
> > +	if (*compact_result <= COMPACT_SKIPPED)
> 
> COMPACT_NONE is -1 and compact_result is unsigned long, so this won't
> work as expected.

Well, COMPACT_NONE is documented as /* compaction disabled */ so we
should never get it from try_to_compact_pages.

[...]
> > @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  				 did_some_progress > 0, no_progress_loops))
> >  		goto retry;
> >  
> > +	/*
> > +	 * !costly allocations are really important and we have to make sure
> > +	 * the compaction wasn't deferred or didn't bail out early due to locks
> > +	 * contention before we go OOM.
> > +	 */
> > +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (compact_result <= COMPACT_CONTINUE)
> 
> Same here.
> I was going to say that this didn't have effect on Sergey's test, but
> turns out it did :)

This should work as expected because compact_result is unsigned long
and so this is the unsigned arithmetic. I can make
#define COMPACT_NONE            -1UL

to make the intention more obvious if you prefer, though.

Thanks for the review.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
