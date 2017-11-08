Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5AE4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 04:35:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e8so2054935wmc.2
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 01:35:50 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id a23si3886440edn.387.2017.11.08.01.35.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Nov 2017 01:35:49 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id A51D298C20
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 09:35:48 +0000 (UTC)
Date: Wed, 8 Nov 2017 09:35:47 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator bottleneck
Message-ID: <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
 <20170915102320.zqceocmvvkyybekj@techsingularity.net>
 <d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
 <1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
 <20171103134020.3hwquerifnc6k6qw@techsingularity.net>
 <b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Jesper Dangaard Brouer <brouer@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Wed, Nov 08, 2017 at 02:42:04PM +0900, Tariq Toukan wrote:
> > > Hi all,
> > > 
> > > After leaving this task for a while doing other tasks, I got back to it now
> > > and see that the good behavior I observed earlier was not stable.
> > > 
> > > Recall: I work with a modified driver that allocates a page (4K) per packet
> > > (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
> > > NICs.
> > > 
> > 
> > There is almost new in the data that hasn't been discussed before. The
> > suggestion to free on a remote per-cpu list would be expensive as it would
> > require per-cpu lists to have a lock for safe remote access.
>
> That's right, but each such lock will be significantly less congested than
> the buddy allocator lock.

That is not necessarily true if all the allocations and frees always happen
on the same CPUs. The contention will be equivalent to the zone lock.
Your point will only hold true if there are also heavy allocation streams
from other CPUs that are unrelated.

> In the flow in subject two cores need to
> synchronize (one allocates, one frees).
> We also need to evaluate the cost of acquiring and releasing the lock in the
> case of no congestion at all.
> 

If the per-cpu structures have a lock, there will be a light amount of
overhead. Nothing too severe, but it shouldn't be done lightly either.

> >  However,
> > I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
> > ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's an
> > unfinished prototype I worked on a few weeks ago. I was going to revisit
> > in about a months time when 4.15-rc1 was out. I'd be interested in seeing
> > if it has a postive gain in normal page allocations without destroying
> > the performance of interrupt and softirq allocation contexts. The
> > interrupt/softirq context testing is crucial as that is something that
> > hurt us before when trying to improve page allocator performance.
> > 
> Yes, I will test that once I get back in office (after netdev conference and
> vacation).

Thanks.

> Can you please elaborate in a few words about the idea behind the prototype?
> Does it address page-allocator scalability issues, or only the rate of
> single core page allocations?

Short answer -- maybe. All scalability issues or rates of allocation are
context and workload dependant so the question is impossible to answer
for the general case.

Broadly speaking, the patch reintroduces the per-cpu lists being for !irq
context allocations again. The last time we did this, hard and soft IRQ
allocations went through the buddy allocator which couldn't scale and
the patch was reverted. With this patch, it goes through a very large
pagevec-like structure that is protected by a lock but the fast paths
for alloc/free are extremely simple operations so the lock hold times are
very small. Potentially, a development path is that the current per-cpu
allocator is replaced with pagevec-like structures that are dynamically
allocated which would also allow pages to be freed to remote CPU lists
(if we could detect when that is appropriate which is unclear). We could
also drain remote lists without using IPIs. The downside is that the memory
footprint of the allocator would be higher and the size could no longer
be tuned so there would need to be excellent justification for such a move.

I haven't posted the patches properly yet because mmotm is carrying too
many patches as it is and this patch indirectly depends on the contents. I
also didn't write memory hot-remove support which would be a requirement
before merging. I hadn't intended to put further effort into it until I
had some evidence the approach had promise. My own testing indicated it
worked but the drivers I was using for network tests did not allocate
intensely enough to show any major gain/loss.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
