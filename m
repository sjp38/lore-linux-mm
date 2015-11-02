Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id B95776B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 09:47:50 -0500 (EST)
Received: by lbbwb3 with SMTP id wb3so89468106lbb.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 06:47:50 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id r123si14822607lfr.149.2015.11.02.06.47.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 06:47:48 -0800 (PST)
Date: Mon, 2 Nov 2015 17:47:29 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151102144729.GA17424@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
 <20151027084320.GF13221@esperanza>
 <20151027155833.GB4665@cmpxchg.org>
 <20151028082003.GK13221@esperanza>
 <20151028185810.GA31488@cmpxchg.org>
 <20151029092747.GR13221@esperanza>
 <20151029175228.GB9160@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151029175228.GB9160@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 29, 2015 at 10:52:28AM -0700, Johannes Weiner wrote:
...
> Now, you mentioned that you'd rather see the socket buffers accounted
> at the allocator level, but I looked at the different allocation paths
> and network protocols and I'm not convinced that this makes sense. We
> don't want to be in the hotpath of every single packet when a lot of
> them are small, short-lived management blips that don't involve user
> space to let the kernel dispose of them.
> 
> __sk_mem_schedule() on the other hand is already wired up to exactly
> those consumers we are interested in for memory isolation: those with
> bigger chunks of data attached to them and those that have exploding
> receive queues when userspace fails to read(). UDP and TCP.
> 
> I mean, there is a reason why the global memory limits apply to only
> those types of packets in the first place: everything else is noise.
> 
> I agree that it's appealing to account at the allocator level and set
> page->mem_cgroup etc. but in this case we'd pay extra to capture a lot
> of noise, and I don't want to pay that just for aesthetics. In this
> case it's better to track ownership on the socket level and only count
> packets that can accumulate a significant amount of memory consumed.

Sigh, you seem to be right. Moreover, I can't even think of a neat way
to account skb pages to memcg, because rcv skbs are generated in device
drivers, where we don't know which socket/memcg it will go to. We could
recharge individual pages when skb gets to the network or transport
layer, but it would result in unjustified overhead.

> 
> > > We tried using the per-memcg tcp limits, and that prevents the OOMs
> > > for sure, but it's horrendous for network performance. There is no
> > > "stop growing" phase, it just keeps going full throttle until it hits
> > > the wall hard.
> > > 
> > > Now, we could probably try to replicate the global knobs and add a
> > > per-memcg soft limit. But you know better than anyone else how hard it
> > > is to estimate the overall workingset size of a workload, and the
> > > margins on containerized loads are razor-thin. Performance is much
> > > more sensitive to input errors, and often times parameters must be
> > > adjusted continuously during the runtime of a workload. It'd be
> > > disasterous to rely on yet more static, error-prone user input here.
> > 
> > Yeah, but the dynamic approach proposed in your patch set doesn't
> > guarantee we won't hit OOM in memcg due to overgrown buffers. It just
> > reduces this possibility. Of course, memcg OOM is far not as disastrous
> > as the global one, but still it usually means the workload breakage.
> 
> Right now, the entire machine breaks. Confining it to a faulty memcg,
> as well as reducing the likelihood of that OOM in many cases seems
> like a good move in the right direction, no?

It seems. However, memcg OOM is also bad, we should strive to avoid it
if we can.

> 
> And how likely are memcg OOMs because of this anyway? There is of

Frankly, I've no idea. Your arguments below sound reassuring though.

> course a scenario imaginable where the packets pile up, followed by
> some *other* part of the workload, the one that doesn't read() and
> process packets, trying to expand--which then doesn't work and goes
> OOM. But that seems like a complete corner case. In the vast majority
> of cases, the application will be in full operation and just fail to
> read() fast enough--because the network bandwidth is enormous compared
> to the container's size, or because it shares the CPU with thousands
> of other workloads and there is scheduling latency.
> 
> This would be the perfect point to reign in the transmit window...
> 
> > The static approach is error-prone for sure, but it has existed for
> > years and worked satisfactory AFAIK.
> 
> ...but that point is not a fixed amount of memory consumed. It depends
> on the workload and the random interactions it's having with thousands
> of other containers on that same machine.
> 
> The point of containers is to maximize utilization of your hardware
> and systematically eliminate slack in the system. But it's exactly
> that slack on dedicated bare-metal machines that allowed us to take a
> wild guess at the settings and then tune them based on observing a
> handful of workloads. This approach is not going to work anymore when
> we pack the machine to capacity and still expect every single
> container out of thousands to perform well. We need that automation.

But we do use static approach when setting memory limits, no?
memory.{low,high,max} - they are all static.

I understand it's appealing to have just one knob - memory size - like
in case of virtual machines, but it doesn't seem to work with
containers. You added memory.low and memory.high knobs. VMs don't have
anything like that. How is one supposed to set them? Depends on the
workload, I guess. Also, there is the pids cgroup for limiting the
number of pids that can be used by a cgroup, because pid turns out to be
a resource in case of containers.  May be, tcp window should be
considered as a separate resource either, as it is now, and shouldn't go
to memcg? I'm just wondering...

> 
> The static setting working okay on the global level is also why I'm
> not interested in starting to experiment with it. There is no reason
> to change it. It's much more likely that any attempt to change it will
> be shot down, not because of the approach chosen, but because there is
> no problem to solve there. I doubt we can get networking people to
> care about containers by screwing with things that work for them ;-)

Fair enough.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
