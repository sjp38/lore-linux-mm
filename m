Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D2B486B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 09:24:38 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id r20so8097417wiv.8
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 06:24:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ds1si19106474wib.36.2014.12.22.06.24.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Dec 2014 06:24:37 -0800 (PST)
Date: Mon, 22 Dec 2014 15:24:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20141222142435.GA2900@dhcp22.suse.cz>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
 <20141219155747.GA31756@dhcp22.suse.cz>
 <20141219182815.GK18274@esperanza>
 <20141220104746.GB6306@dhcp22.suse.cz>
 <20141220141824.GM18274@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220141824.GM18274@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Sat 20-12-14 17:18:24, Vladimir Davydov wrote:
> On Sat, Dec 20, 2014 at 11:47:46AM +0100, Michal Hocko wrote:
> > On Fri 19-12-14 21:28:15, Vladimir Davydov wrote:
> > > So AFAIU the problem does exist. However, I think it could be fixed by
> > > simply waking up all processes waiting on pfmemalloc_wait before putting
> > > kswapd to sleep:
> > 
> > I think that a simple cond_resched() in kswapd_try_to_sleep should be
> > sufficient and less risky fix, so basically what Vlastimil was proposing
> > in the beginning.
> 
> With such a solution we implicitly rely upon the scheduler
> implementation, which AFAIU is wrong.

But this is a scheduling problem, isn't it? !PREEMPT kernel with a
kernel thread looping without a scheduling point which prevents the
woken task to run due to cpu affinity...

> E.g. suppose processes are
> governed by FIFO and kswapd happens to have a higher prio than the
> process killed by OOM. Then after cond_resched kswapd will be picked for
> execution again, and the killing process won't have a chance to remove
> itself from the wait queue.

Except that kswapd runs as SCHED_NORMAL with 0 priority.

> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 744e2b491527..2a123634c220 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -2984,6 +2984,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> > >  	if (remaining)
> > >  		return false;
> > >  
> > > +	if (!pgdat_balanced(pgdat, order, classzone_idx))
> > > +		return false;
> > > +
> > 
> > What would be consequences of not waking up pfmemalloc waiters while the
> > node is not balanced?
> 
> They will get woken up a bit later in balanced_pgdat. This might result
> in latency spikes though. In order not to change the original behaviour
> we could always wake all pfmemalloc waiters no matter if we are going to
> sleep or not:
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 744e2b491527..a21e0bd563c3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2993,10 +2993,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
>  	 * so wake them now if necessary. If necessary, processes will wake
>  	 * kswapd and get throttled again
>  	 */
> -	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
> -		wake_up(&pgdat->pfmemalloc_wait);
> -		return false;
> -	}
> +	wake_up_all(&pgdat->pfmemalloc_wait);
>  
>  	return pgdat_balanced(pgdat, order, classzone_idx);

So you are relying on scheduling points somewhere down the
balance_pgdat. That should be sufficient. I am still quite surprised
that we have an OOM victim still on the queue and balanced pgdat here
because OOM victim didn't have chance to free memory. So somebody else
must have released a lot of memory after OOM.

This patch seems better than the one from Vlastimil. Care to post it
with the full changelog, please?

Thanks!

>  }

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
