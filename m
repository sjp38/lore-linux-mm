Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 981E96B0390
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 00:26:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c2so51080863pfd.9
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 21:26:41 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s1si9790923pge.356.2017.04.16.21.26.39
        for <linux-mm@kvack.org>;
        Sun, 16 Apr 2017 21:26:40 -0700 (PDT)
Date: Mon, 17 Apr 2017 13:26:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Message-ID: <20170417042637.GB20981@bbox>
References: <20170317231636.142311-1-timmurray@google.com>
 <20170330155123.GA3929@cmpxchg.org>
 <CAEe=SxmpXD=f9N_i+xe6gFUKKUefJYvBd8dSwxSM+7rbBBTniw@mail.gmail.com>
 <20170413043047.GA16783@bbox>
 <20170413160147.GB29727@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170413160147.GB29727@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, LKML <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Suren Baghdasaryan <surenb@google.com>, Patrik Torstensson <totte@google.com>, Android Kernel Team <kernel-team@android.com>

Hi Johannes,

On Thu, Apr 13, 2017 at 12:01:47PM -0400, Johannes Weiner wrote:
> On Thu, Apr 13, 2017 at 01:30:47PM +0900, Minchan Kim wrote:
> > On Thu, Mar 30, 2017 at 12:40:32PM -0700, Tim Murray wrote:
> > > As a result, I think there's still a need for relative priority
> > > between mem cgroups, not just an absolute limit.
> > > 
> > > Does that make sense?
> > 
> > I agree with it.
> > 
> > Recently, embedded platform's workload for smart things would be much
> > diverse(from game to alarm) so it's hard to handle the absolute limit
> > proactively and userspace has more hints about what workloads are
> > more important(ie, greedy) compared to others although it would be
> > harmful for something(e.g., it's not visible effect to user)
> > 
> > As a such point of view, I support this idea as basic approach.
> > And with thrashing detector from Johannes, we can do fine-tune of
> > LRU balancing and vmpressure shooting time better.
> > 
> > Johannes,
> > 
> > Do you have any concern about this memcg prority idea?
> 
> While I fully agree that relative priority levels would be easier to
> configure, this patch doesn't really do that. It allows you to set a
> scan window divider to a fixed amount and, as I already pointed out,
> the scan window is no longer representative of memory pressure.
> 
> [ Really, sc->priority should probably just be called LRU lookahead
>   factor or something, there is not much about it being representative
>   of any kind of urgency anymore. ]

I agree that sc->priority is not memory pressure indication.
I should have clarified my intention. Sorry about that.

I'm not saying I like this implementation as I mentioned with
previous reply.
http://lkml.kernel.org/r/20170322052013.GE30149@bbox

Just about general idea, in global OOM case, break proportional
reclaim and then prefering low-priority group's reclaim would be
good for some workload like current embedded platform. And to
achieve it, aging velocity control via scan window adjusting seems
to be reasonable.

> 
> With this patch, if you configure the priorities of two 8G groups to 0
> and 4, reclaim will treat them exactly the same*. If you configure the
> priorities of two 100G groups to 0 and 7, reclaim will treat them
> exactly the same. The bigger the group, the more of the lower range of
> the priority range becomes meaningless, because once the divider
> produces outcomes bigger than SWAP_CLUSTER_MAX(32), it doesn't
> actually bias reclaim anymore.

It seems it's the logic of memcg reclaim not global which is major
concern for current problem because there is no set up limitation for
each memcg.

> 
> So that's not a portable relative scale of pressure discrimination.
> 
> But the bigger problem with this is that, as sc->priority doesn't
> represent memory pressure anymore, it is merely a cut-off for which
> groups to scan and which groups not to scan *based on their size*.

Yes, because there are no measurable pressure concept in current VM
and you are trying to add the notion which is really good!

> 
> That is the same as setting memory.low!
> 
> * For simplicity, I'm glossing over the fact here that LRUs are split
>   by type and into inactive/active, so in reality the numbers are a
>   little different, but you get the point.
> 
> > Or
> > Do you think the patchset you are preparing solve this situation?
> 
> It's certainly a requirement. In order to implement a relative scale
> of memory pressure discrimination, we first need to be able to really
> quantify memory pressure.

Yeb. If we can get it, it would be better than unconditional
discriminated aging by the static priority which would leave
non-workingset pages in high priority group while workingset in
low-priority group would be evicted.

Rather than it, we ages every group's LRU fairly and if high-priority
group makes memory pressure beyond his threshold, VM should feedback
to low priority groups to be reclaimed more, which would be better.

> 
> Then we can either allow setting absolute latency/slowdown minimums
> for each group, with reclaim skipping groups above those thresholds,
> or we can map a relative priority scale against the total slowdown due
> to lack of memory in the system, and each group gets a relative share
> based on its priority compared to other groups.

Fully agreed.

> 
> But there is no way around first having a working measure of memory
> pressure before we can meaningfully distribute it among the groups.

Yeb. I'm looking foward to seeing it.

Thanks for the thoughtful comment, Johannes!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
