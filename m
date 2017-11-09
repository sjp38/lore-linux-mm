Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id DDD6A440460
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 00:21:37 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id w17so1233186oti.22
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 21:21:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l128si1018821oig.518.2017.11.08.21.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 21:21:36 -0800 (PST)
Date: Thu, 9 Nov 2017 06:21:01 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Page allocator bottleneck
Message-ID: <20171109062101.64bde3b6@redhat.com>
In-Reply-To: <20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
	<20170915102320.zqceocmvvkyybekj@techsingularity.net>
	<d8cfaf8b-7601-2712-f9f2-8327c720db5a@mellanox.com>
	<1c218381-067e-7757-ccc2-4e5befd2bfc3@mellanox.com>
	<20171103134020.3hwquerifnc6k6qw@techsingularity.net>
	<b249f79a-a92e-f2ef-fdd5-3a9b8b6c3f48@mellanox.com>
	<20171108093547.ctsjv4a42xjvfsf7@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Tariq Toukan <tariqt@mellanox.com>, Linux Kernel Network Developers <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>, Alexei Starovoitov <ast@fb.com>, Saeed Mahameed <saeedm@mellanox.com>, Eran Ben Elisha <eranbe@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, brouer@redhat.com, "Michael S. Tsirkin" <mst@redhat.com>

On Wed, 8 Nov 2017 09:35:47 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Nov 08, 2017 at 02:42:04PM +0900, Tariq Toukan wrote:
> > > > Hi all,
> > > > 
> > > > After leaving this task for a while doing other tasks, I got back to it now
> > > > and see that the good behavior I observed earlier was not stable.
> > > > 
> > > > Recall: I work with a modified driver that allocates a page (4K) per packet
> > > > (MTU=1500), in order to simulate the stress on page-allocator in 200Gbps
> > > > NICs.
> > > >   
> > > 
> > > There is almost new in the data that hasn't been discussed before. The
> > > suggestion to free on a remote per-cpu list would be expensive as it would
> > > require per-cpu lists to have a lock for safe remote access.  
> >
> > That's right, but each such lock will be significantly less congested than
> > the buddy allocator lock.  
> 
> That is not necessarily true if all the allocations and frees always happen
> on the same CPUs. The contention will be equivalent to the zone lock.
> Your point will only hold true if there are also heavy allocation streams
> from other CPUs that are unrelated.
> 
> > In the flow in subject two cores need to
> > synchronize (one allocates, one frees).
> > We also need to evaluate the cost of acquiring and releasing the lock in the
> > case of no congestion at all.
> >   
> 
> If the per-cpu structures have a lock, there will be a light amount of
> overhead. Nothing too severe, but it shouldn't be done lightly either.
> 
> > >  However,
> > > I'd be curious if you could test the mm-pagealloc-irqpvec-v1r4 branch
> > > ttps://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git .  It's an
> > > unfinished prototype I worked on a few weeks ago. I was going to revisit
> > > in about a months time when 4.15-rc1 was out. I'd be interested in seeing
> > > if it has a postive gain in normal page allocations without destroying
> > > the performance of interrupt and softirq allocation contexts. The
> > > interrupt/softirq context testing is crucial as that is something that
> > > hurt us before when trying to improve page allocator performance.
> > >   
> > Yes, I will test that once I get back in office (after netdev conference and
> > vacation).  
> 
> Thanks.

I'll also commit to testing this (when I return home, as Tariq I'm also
in Seoul ATM).

 
> > Can you please elaborate in a few words about the idea behind the prototype?
> > Does it address page-allocator scalability issues, or only the rate of
> > single core page allocations?  
> 
> Short answer -- maybe. All scalability issues or rates of allocation are
> context and workload dependant so the question is impossible to answer
> for the general case.
> 
> Broadly speaking, the patch reintroduces the per-cpu lists being for !irq
> context allocations again. The last time we did this, hard and soft IRQ
> allocations went through the buddy allocator which couldn't scale and
> the patch was reverted. With this patch, it goes through a very large
> pagevec-like structure that is protected by a lock but the fast paths
> for alloc/free are extremely simple operations so the lock hold times are
> very small. Potentially, a development path is that the current per-cpu
> allocator is replaced with pagevec-like structures that are dynamically
> allocated which would also allow pages to be freed to remote CPU lists

I've had huge success using ptr_ring, as a queue between CPUs, to
minimize cross-CPU cache-line touching.  With the recently accepted BPF
map called "cpumap" used for XDP_REDIRECT.

It's important to handle the two borderline cases in ptr_ring, of the
queue being almost full (default handled in ptr_ring) or almost empty.
Like describe in[1] slide 14:

[1] http://people.netfilter.org/hawk/presentations/NetConf2017_Seoul/XDP_devel_update_NetConf2017_Seoul.pdf

The use of XDP_REDIRECT + cpumap, do expose issues with the page
allocator.  E.g. slide 19 show ixgbe recycle scheme failing, but still
hitting the PCP.  Also notice slide 22 deducing the overhead.  Scale
stressing ptr_ring is showed in extra slides 35-39.


> (if we could detect when that is appropriate which is unclear). We could
> also drain remote lists without using IPIs. The downside is that the memory
> footprint of the allocator would be higher and the size could no longer
> be tuned so there would need to be excellent justification for such a move.
> 
> I haven't posted the patches properly yet because mmotm is carrying too
> many patches as it is and this patch indirectly depends on the contents. I
> also didn't write memory hot-remove support which would be a requirement
> before merging. I hadn't intended to put further effort into it until I
> had some evidence the approach had promise. My own testing indicated it
> worked but the drivers I was using for network tests did not allocate
> intensely enough to show any major gain/loss.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
