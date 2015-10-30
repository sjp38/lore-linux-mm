Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id DFE6582F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 04:23:26 -0400 (EDT)
Received: by wmeg8 with SMTP id g8so5944532wme.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:23:26 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id fv6si7476789wjc.132.2015.10.30.01.23.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 01:23:25 -0700 (PDT)
Received: by wmeg8 with SMTP id g8so5956771wme.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 01:23:25 -0700 (PDT)
Date: Fri, 30 Oct 2015 09:23:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Message-ID: <20151030082323.GB18429@dhcp22.suse.cz>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org>
 <1446131835-3263-2-git-send-email-mhocko@kernel.org>
 <5632FEEF.2050709@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5632FEEF.2050709@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-10-15 14:23:59, KAMEZAWA Hiroyuki wrote:
> On 2015/10/30 0:17, mhocko@kernel.org wrote:
[...]
> > @@ -3135,13 +3145,56 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >   	if (gfp_mask & __GFP_NORETRY)
> >   		goto noretry;
> >   
> > -	/* Keep reclaiming pages as long as there is reasonable progress */
> > +	/*
> > +	 * Do not retry high order allocations unless they are __GFP_REPEAT
> > +	 * and even then do not retry endlessly.
> > +	 */
> >   	pages_reclaimed += did_some_progress;
> > -	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
> > -	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
> > -		/* Wait for some write requests to complete then retry */
> > -		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
> > -		goto retry;
> > +	if (order > PAGE_ALLOC_COSTLY_ORDER) {
> > +		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
> > +			goto noretry;
> > +
> > +		if (did_some_progress)
> > +			goto retry;
> 
> why directly retry here ?

Because I wanted to preserve the previous logic for GFP_REPEAT as much
as possible here and do an incremental change in the later patch.

[...]

> > @@ -3150,8 +3203,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >   		goto got_pg;
> >   
> >   	/* Retry as long as the OOM killer is making progress */
> > -	if (did_some_progress)
> > +	if (did_some_progress) {
> > +		stall_backoff = 0;
> >   		goto retry;
> > +	}
> 
> Umm ? I'm sorry that I didn't notice page allocation may fail even
> if order < PAGE_ALLOC_COSTLY_ORDER.  I thought old logic ignores
> did_some_progress. It seems a big change.

__alloc_pages_may_oom will set did_some_progress

> So, now, 0-order page allocation may fail in a OOM situation ?

No they don't normally and this patch doesn't change the logic here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
