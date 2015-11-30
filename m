Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5749D6B0253
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 11:14:07 -0500 (EST)
Received: by lffu14 with SMTP id u14so203921514lff.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 08:14:06 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id rq3si10825212lbb.14.2015.11.30.08.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 08:14:05 -0800 (PST)
Date: Mon, 30 Nov 2015 19:13:46 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151130161346.GD24704@esperanza>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <20151124215940.GB1373@cmpxchg.org>
 <20151130113628.GB24704@esperanza>
 <20151130155838.GB30243@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151130155838.GB30243@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 30, 2015 at 10:58:38AM -0500, Johannes Weiner wrote:
> On Mon, Nov 30, 2015 at 02:36:28PM +0300, Vladimir Davydov wrote:
> > Suppose we have the following cgroup configuration.
> > 
> > A __ B
> >   \_ C
> > 
> > A is empty (which is natural for the unified hierarchy AFAIU). B has
> > some workload running in it, and C generates socket pressure. Due to the
> > socket pressure coming from C we start reclaim in A, which results in
> > thrashing of B, but we might not put sockets under pressure in A or C,
> > because vmpressure does not account pages scanned/reclaimed in B when
> > generating a vmpressure event for A or C. This might result in
> > aggressive reclaim and thrashing in B w/o generating a signal for C to
> > stop growing socket buffers.
> > 
> > Do you think such a situation is possible? If so, would it make sense to
> > switch to post-order walk in shrink_zone and pass sub-tree
> > scanned/reclaimed stats to vmpressure for each scanned memcg?
> 
> In that case the LRU pages in C would experience pressure as well,
> which would then reign in the sockets in C. There must be some LRU
> pages in there, otherwise who is creating socket pressure?
> 
> The same applies to shrinkers. All secondary reclaim is driven by LRU
> reclaim results.
> 
> I can see that there is some unfairness in distributing memcg reclaim
> pressure purely based on LRU size, because there are scenarios where
> the auxiliary objects (incl. sockets, but mostly shrinker pools)
> amount to a significant portion of the group's memory footprint. But
> substitute group for NUMA node and we've had this behavior for
> years. I'm not sure it's actually a problem in practice.
> 

Fiar enough. Let's wait until we hit this problem in real world then.

The patch looks good to me.

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
