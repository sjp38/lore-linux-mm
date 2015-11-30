Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2DAD76B0255
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 10:58:54 -0500 (EST)
Received: by wmec201 with SMTP id c201so144706670wme.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:58:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n9si67438376wjq.229.2015.11.30.07.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 07:58:52 -0800 (PST)
Date: Mon, 30 Nov 2015 10:58:38 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151130155838.GB30243@cmpxchg.org>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <20151124215940.GB1373@cmpxchg.org>
 <20151130113628.GB24704@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151130113628.GB24704@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 30, 2015 at 02:36:28PM +0300, Vladimir Davydov wrote:
> Suppose we have the following cgroup configuration.
> 
> A __ B
>   \_ C
> 
> A is empty (which is natural for the unified hierarchy AFAIU). B has
> some workload running in it, and C generates socket pressure. Due to the
> socket pressure coming from C we start reclaim in A, which results in
> thrashing of B, but we might not put sockets under pressure in A or C,
> because vmpressure does not account pages scanned/reclaimed in B when
> generating a vmpressure event for A or C. This might result in
> aggressive reclaim and thrashing in B w/o generating a signal for C to
> stop growing socket buffers.
> 
> Do you think such a situation is possible? If so, would it make sense to
> switch to post-order walk in shrink_zone and pass sub-tree
> scanned/reclaimed stats to vmpressure for each scanned memcg?

In that case the LRU pages in C would experience pressure as well,
which would then reign in the sockets in C. There must be some LRU
pages in there, otherwise who is creating socket pressure?

The same applies to shrinkers. All secondary reclaim is driven by LRU
reclaim results.

I can see that there is some unfairness in distributing memcg reclaim
pressure purely based on LRU size, because there are scenarios where
the auxiliary objects (incl. sockets, but mostly shrinker pools)
amount to a significant portion of the group's memory footprint. But
substitute group for NUMA node and we've had this behavior for
years. I'm not sure it's actually a problem in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
