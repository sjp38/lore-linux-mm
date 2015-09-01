Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 17DA86B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 08:51:54 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so11431677wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:51:53 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id a11si3005053wib.95.2015.09.01.05.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 05:51:52 -0700 (PDT)
Received: by wicjd9 with SMTP id jd9so32050472wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:51:52 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:51:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] memcg: fix over-high reclaim amount
Message-ID: <20150901125149.GD8810@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-2-git-send-email-tj@kernel.org>
 <20150828170612.GA21463@dhcp22.suse.cz>
 <20150828183209.GA9423@mtj.duckdns.org>
 <20150831075133.GA29723@dhcp22.suse.cz>
 <20150831133840.GA2271@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831133840.GA2271@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Mon 31-08-15 09:38:40, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Aug 31, 2015 at 09:51:33AM +0200, Michal Hocko wrote:
> > The overall reclaim throughput will be higher with the parallel reclaim.
> 
> Is reclaim throughput as determined by CPU cycle bandwidth a
> meaningful metric? 

Well, considering it has a direct effect on the latency I would consider
it quite meaningful.

> I'm having a bit of trouble imagining that this
> actually would matter especially given that writeback is single
> threaded per bdi_writeback.

Sure, if the LRU contains a lot of dirty pages then the writeback will be
a bottleneck. But LRUs are quite often full of the clean pagecache pages
which can be reclaimed quickly and efficiently.

> Shoving in a large number of threads into the same path which walks
> the same data structures when there's no clear benefit doesn't usually
> end up buying anything. 

I agree that a certain level of throttling is reasonable. We are doing
some of that in the lower layers of the reclaim. It is true that some of
that throttling is specific to the global reclaim and some heuristics
might be applicable on the try_charge level as well but we should be
careful here. Throttling has been quite tricky and there were some
issues where it led to unexpected stalls in the past.

> Cachelines get thrown back and forth, locks
> get contended, CPU cycles which could have been used for a lot of more
> useful things get wasted and IO pattern becomes random.  We can still
> choose to do that but I think we should have explicit justifications
> (e.g. it really harms scalability otherwise).

I do not remember heavy contention on the lru lock and we are not doing
an IO from the direct reclaim (other than swap) so a random IO pattern
shouldn't be an issue as well.
 
> > Threads might still get synchronized on the zone lru lock but this is only
> > for isolating them from the LRU. In a larger hierarchies this even might
> > not be the case because the hierarchy iterator tries to spread the reclaim
> > over different memcgs.
> > 
> > So the per-memcg mutex would solve the potential over-reclaim but it
> > will restrain the reclaim activity unnecessarily. Why is per-contribution
> > reclaim such a big deal in the first place? If there are runaways
> > allocation requests like GFP_NOWAIT then we should look after those. And
> > I would argue that your delayed reclaim idea is a great fit for that. We
> > just should track how many pages were charged over high limit in the
> > process context and reclaim that amount on the way out from the kernel.
> 
> Per-contribution reclaim is not necessarily a "big deal" but is kinda
> mushy on the edges which get more pronounced with async reclaim.

Yes, I am not saying it is a perfect solution. It has its issues as well.
We have been doing this for ages though and there should be really good
reasons with numbers demonstrating improvements to change it to
something else.
 
> * It still can over reclaim to a considerable extent.  The reclaim
>   path uses mean reclaim size of 1M and when the high limit is used as
>   the main mechanism for reclaim rather than global limit, many
>   threads performing simultaneous 1M reclaims will happen.

Yes this is something that has been changed recently and I am not sure
the new SWAP_CLUSTER_MAX value fits well into the current memcg direct
reclaim implementation.
I didn't get to measure the effect yet, though, but maybe we will have
to go back to 32 or something small for the memcg reclaim. This is just
an implementation detail, though.

> * We need to keep track of an additional state.  What if a task
>   performs multiple NOWAIT try_charge()'s?  I guess we should add up
>   those numbers.

Yes, that was the idea. Just accumulate nr_pages attempts when the
current > high and then attempt to reclaim them on the way out as you
were suggesting.

> * But even if we do that, what does that actually mean?  These numbers
>   are arbitrary in nature.

nr_pages at least reflects the request size so we, at least
theoretically, throttle larger consumers more.

>   A thread may have just performed
>   high-order allocations back to back at the point where it steps over
>   the limit with an order-0 allocation or maybe a different thread
>   which wasn't consuming much memory can hit it right after.
>   @nr_pages is a convenient number that we can use on the spot which
>   will make the consumption converge on the limit but I'm not sure
>   this is a number that we should keep track of.

I agree that this is an inherently racy environment. It really depends
on who hits the limit and how good are reclaimers at doing their work
when others piggy back on their work.
We have the background reclaim to reduce that effect for the global
case.  Something similar have been discussed in the past for memcg as
well but it hits its own issues as it has to scale with the potentially
large number of memcgs.

> Also, having a central point of control means that we can actually
> define policies there - e.g. if the overage is less than 10%, let
> tasks through as long as there's at least one reclaiming.

I am not sure whether throttling at this level would be more beneficial
than doing that down at the reclaim paths.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
