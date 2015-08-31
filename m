Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2AEBE6B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 09:38:45 -0400 (EDT)
Received: by ykap84 with SMTP id p84so1919790yka.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:38:44 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id y144si9379033yke.97.2015.08.31.06.38.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 06:38:44 -0700 (PDT)
Received: by ykap84 with SMTP id p84so1919246yka.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 06:38:43 -0700 (PDT)
Date: Mon, 31 Aug 2015 09:38:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 1/4] memcg: fix over-high reclaim amount
Message-ID: <20150831133840.GA2271@mtj.duckdns.org>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-2-git-send-email-tj@kernel.org>
 <20150828170612.GA21463@dhcp22.suse.cz>
 <20150828183209.GA9423@mtj.duckdns.org>
 <20150831075133.GA29723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831075133.GA29723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello, Michal.

On Mon, Aug 31, 2015 at 09:51:33AM +0200, Michal Hocko wrote:
> The overall reclaim throughput will be higher with the parallel reclaim.

Is reclaim throughput as determined by CPU cycle bandwidth a
meaningful metric?  I'm having a bit of trouble imagining that this
actually would matter especially given that writeback is single
threaded per bdi_writeback.

Shoving in a large number of threads into the same path which walks
the same data structures when there's no clear benefit doesn't usually
end up buying anything.  Cachelines get thrown back and forth, locks
get contended, CPU cycles which could have been used for a lot of more
useful things get wasted and IO pattern becomes random.  We can still
choose to do that but I think we should have explicit justifications
(e.g. it really harms scalability otherwise).

> Threads might still get synchronized on the zone lru lock but this is only
> for isolating them from the LRU. In a larger hierarchies this even might
> not be the case because the hierarchy iterator tries to spread the reclaim
> over different memcgs.
> 
> So the per-memcg mutex would solve the potential over-reclaim but it
> will restrain the reclaim activity unnecessarily. Why is per-contribution
> reclaim such a big deal in the first place? If there are runaways
> allocation requests like GFP_NOWAIT then we should look after those. And
> I would argue that your delayed reclaim idea is a great fit for that. We
> just should track how many pages were charged over high limit in the
> process context and reclaim that amount on the way out from the kernel.

Per-contribution reclaim is not necessarily a "big deal" but is kinda
mushy on the edges which get more pronounced with async reclaim.

* It still can over reclaim to a considerable extent.  The reclaim
  path uses mean reclaim size of 1M and when the high limit is used as
  the main mechanism for reclaim rather than global limit, many
  threads performing simultaneous 1M reclaims will happen.

* We need to keep track of an additional state.  What if a task
  performs multiple NOWAIT try_charge()'s?  I guess we should add up
  those numbers.

* But even if we do that, what does that actually mean?  These numbers
  are arbitrary in nature.  A thread may have just performed
  high-order allocations back to back at the point where it steps over
  the limit with an order-0 allocation or maybe a different thread
  which wasn't consuming much memory can hit it right after.
  @nr_pages is a convenient number that we can use on the spot which
  will make the consumption converge on the limit but I'm not sure
  this is a number that we should keep track of.

Also, having a central point of control means that we can actually
define policies there - e.g. if the overage is less than 10%, let
tasks through as long as there's at least one reclaiming.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
