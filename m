Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4130B6B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 10:01:37 -0500 (EST)
Received: by wmec201 with SMTP id c201so73906431wme.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:01:36 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id p142si11005815wmb.40.2015.11.27.07.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 07:01:35 -0800 (PST)
Received: by wmww144 with SMTP id w144so61410794wmw.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:01:35 -0800 (PST)
Date: Fri, 27 Nov 2015 16:01:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] vmscan: do not throttle kthreads due to too_many_isolated
Message-ID: <20151127150133.GI2493@dhcp22.suse.cz>
References: <1448465801-3280-1-git-send-email-vdavydov@virtuozzo.com>
 <5655D789.80201@suse.cz>
 <20151125162756.GJ29014@esperanza>
 <20151126081624.GK29014@esperanza>
 <20151127125005.GH2493@dhcp22.suse.cz>
 <20151127134003.GR29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151127134003.GR29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-11-15 16:40:03, Vladimir Davydov wrote:
> On Fri, Nov 27, 2015 at 01:50:05PM +0100, Michal Hocko wrote:
> > On Thu 26-11-15 11:16:24, Vladimir Davydov wrote:
[...]
> > > Anyway, kthreads that use GFP_NOIO and/or mempool aren't safe either,
> > > because it isn't an allocation context problem: the reclaimer locks up
> > > not because it tries to take an fs/io lock the caller holds, but because
> > > it waits for isolated pages to be put back, which will never happen,
> > > since processes that isolated them depend on the kthread making
> > > progress. This is purely a reclaimer heuristic, which kmalloc users are
> > > not aware of.
> > > 
> > > My point is that, in contrast to userspace processes, it is dangerous to
> > > throttle kthreads in the reclaimer, because they might be responsible
> > > for reclaimer progress (e.g. performing writeback).
> > 
> > Wouldn't it be better if your writeback kthread did PF_MEMALLOC/__GFP_MEMALLOC
> > instead because it is in fact a reclaimer so it even get to the reclaim.
> 
> The driver we use is similar to loop. It works as a proxy to fs it works
> on top of. Allowing it to access emergency reserves would deplete them
> quickly, just like in case of plain loop.

OK, I see. I thought it would be using only a very limited amount of
memory for the writeback.

> The problem is not about our driver, in fact. I'm pretty sure one can
> hit it when using memcg along with loop or dm-crypt for instance.

I am not familiar much with neither but from a quick look the loop
driver doesn't use mempools tool, it simply relays the data to the
underlaying file and relies on the underlying fs to write all the pages
and only prevents from the recursion by clearing GFP_FS and GFP_IO. Then
I am not really sure how can we guarantee a forward progress. The
GFP_NOFS allocation might loop inside the allocator endlessly and so
the writeback wouldn't make any progress. This doesn't seem to be only
memcg specific. The global case would just replace the deadlock by a
livelock. I certainly must be missing something here.

> > There way too many allocations done from the kernel thread context to be
> > not throttled (just look at worker threads).
> 
> What about throttling them only once then?

This still sounds way too broad to me and I am even not sure it solves
the problem. If anything I think we really should make it specific
only to those callers who are really required to make a forward
progress. What about PF_LESS_THROTTLE? NFS is already using this flag for a
similar purpose and we indeed do not throttle at few places during the
reclaim. So I would expect current_may_throttle(current) check there
although I must confess I have no idea about the whole condition right
now.

> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 97ba9e1cde09..9253f4531b9c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1578,6 +1578,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  		/* We are about to die and free our memory. Return now. */
>  		if (fatal_signal_pending(current))
>  			return SWAP_CLUSTER_MAX;
> +
> +		if (current->flags & PF_KTHREAD)
> +			break;
>  	}
>  
>  	lru_add_drain();
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
