Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 50EF482F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:52:45 -0400 (EDT)
Received: by wijp11 with SMTP id p11so294592342wij.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 10:52:44 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m139si12808747wmb.72.2015.10.29.10.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 10:52:43 -0700 (PDT)
Date: Thu, 29 Oct 2015 10:52:28 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Message-ID: <20151029175228.GB9160@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
 <20151026172216.GC2214@cmpxchg.org>
 <20151027084320.GF13221@esperanza>
 <20151027155833.GB4665@cmpxchg.org>
 <20151028082003.GK13221@esperanza>
 <20151028185810.GA31488@cmpxchg.org>
 <20151029092747.GR13221@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029092747.GR13221@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 29, 2015 at 12:27:47PM +0300, Vladimir Davydov wrote:
> On Wed, Oct 28, 2015 at 11:58:10AM -0700, Johannes Weiner wrote:
> > Having the hard limit as a failsafe (or a minimum for other consumers)
> > is one thing, and certainly something I'm open to for cgroupv2, should
> > we have problems with load startup up after a socket memory landgrab.
> > 
> > That being said, if the VM is struggling to reclaim pages, or is even
> > swapping, it makes perfect sense to let the socket memory scheduler
> > know it shouldn't continue to increase its footprint until the VM
> > recovers. Regardless of any hard limitations/minimum guarantees.
> > 
> > This is what my patch does and it seems pretty straight-forward to
> > me. I don't really understand why this is so controversial.
> 
> I'm not arguing that the idea behind this patch set is necessarily bad.
> Quite the contrary, it does look interesting to me. I'm just saying that
> IMO it can't replace hard/soft limits. It probably could if it was
> possible to shrink buffers, but I don't think it's feasible, even
> theoretically. That's why I propose not to change the behavior of the
> existing per memcg tcp limit at all. And frankly I don't get why you are
> so keen on simplifying it. You say it's a "crapload of boilerplate
> code". Well, I don't see how it is - it just replicates global knobs and
> I don't see how it could be done in a better way. The code is hidden
> behind jump labels, so the overhead is zero if it isn't used. If you
> really dislike this code, we can isolate it under a separate config
> option. But all right, I don't rule out the possibility that the code
> could be simplified. If you do that w/o breaking it, that'll be OK to
> me, but I don't see why it should be related to this particular patch
> set.

Okay, I see your concern.

I'm not trying to change the behavior, just the implementation,
because it's too complex for the functionality it actually provides.

And the reason it's part of this patch set is because I'm using the
same code to hook into the memory accounting, so it makes sense to
refactor this stuff in the same go.

There is also a niceness factor of not adding more memcg callbacks to
the networking subsystem when there is an option to consolidate them.

Now, you mentioned that you'd rather see the socket buffers accounted
at the allocator level, but I looked at the different allocation paths
and network protocols and I'm not convinced that this makes sense. We
don't want to be in the hotpath of every single packet when a lot of
them are small, short-lived management blips that don't involve user
space to let the kernel dispose of them.

__sk_mem_schedule() on the other hand is already wired up to exactly
those consumers we are interested in for memory isolation: those with
bigger chunks of data attached to them and those that have exploding
receive queues when userspace fails to read(). UDP and TCP.

I mean, there is a reason why the global memory limits apply to only
those types of packets in the first place: everything else is noise.

I agree that it's appealing to account at the allocator level and set
page->mem_cgroup etc. but in this case we'd pay extra to capture a lot
of noise, and I don't want to pay that just for aesthetics. In this
case it's better to track ownership on the socket level and only count
packets that can accumulate a significant amount of memory consumed.

> > We tried using the per-memcg tcp limits, and that prevents the OOMs
> > for sure, but it's horrendous for network performance. There is no
> > "stop growing" phase, it just keeps going full throttle until it hits
> > the wall hard.
> > 
> > Now, we could probably try to replicate the global knobs and add a
> > per-memcg soft limit. But you know better than anyone else how hard it
> > is to estimate the overall workingset size of a workload, and the
> > margins on containerized loads are razor-thin. Performance is much
> > more sensitive to input errors, and often times parameters must be
> > adjusted continuously during the runtime of a workload. It'd be
> > disasterous to rely on yet more static, error-prone user input here.
> 
> Yeah, but the dynamic approach proposed in your patch set doesn't
> guarantee we won't hit OOM in memcg due to overgrown buffers. It just
> reduces this possibility. Of course, memcg OOM is far not as disastrous
> as the global one, but still it usually means the workload breakage.

Right now, the entire machine breaks. Confining it to a faulty memcg,
as well as reducing the likelihood of that OOM in many cases seems
like a good move in the right direction, no?

And how likely are memcg OOMs because of this anyway? There is of
course a scenario imaginable where the packets pile up, followed by
some *other* part of the workload, the one that doesn't read() and
process packets, trying to expand--which then doesn't work and goes
OOM. But that seems like a complete corner case. In the vast majority
of cases, the application will be in full operation and just fail to
read() fast enough--because the network bandwidth is enormous compared
to the container's size, or because it shares the CPU with thousands
of other workloads and there is scheduling latency.

This would be the perfect point to reign in the transmit window...

> The static approach is error-prone for sure, but it has existed for
> years and worked satisfactory AFAIK.

...but that point is not a fixed amount of memory consumed. It depends
on the workload and the random interactions it's having with thousands
of other containers on that same machine.

The point of containers is to maximize utilization of your hardware
and systematically eliminate slack in the system. But it's exactly
that slack on dedicated bare-metal machines that allowed us to take a
wild guess at the settings and then tune them based on observing a
handful of workloads. This approach is not going to work anymore when
we pack the machine to capacity and still expect every single
container out of thousands to perform well. We need that automation.

The static setting working okay on the global level is also why I'm
not interested in starting to experiment with it. There is no reason
to change it. It's much more likely that any attempt to change it will
be shot down, not because of the approach chosen, but because there is
no problem to solve there. I doubt we can get networking people to
care about containers by screwing with things that work for them ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
