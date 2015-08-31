Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id B1CB46B0255
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 03:51:36 -0400 (EDT)
Received: by wicpl12 with SMTP id pl12so19432873wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 00:51:36 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id wh5si25434891wjb.69.2015.08.31.00.51.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 00:51:35 -0700 (PDT)
Received: by widfa3 with SMTP id fa3so15218505wid.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 00:51:35 -0700 (PDT)
Date: Mon, 31 Aug 2015 09:51:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] memcg: fix over-high reclaim amount
Message-ID: <20150831075133.GA29723@dhcp22.suse.cz>
References: <1440775530-18630-1-git-send-email-tj@kernel.org>
 <1440775530-18630-2-git-send-email-tj@kernel.org>
 <20150828170612.GA21463@dhcp22.suse.cz>
 <20150828183209.GA9423@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150828183209.GA9423@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

On Fri 28-08-15 14:32:09, Tejun Heo wrote:
> Hello,
> 
> On Fri, Aug 28, 2015 at 07:06:13PM +0200, Michal Hocko wrote:
> > I do not think this a better behavior. If you have parallel charges to
> > the same memcg then you can easilly over-reclaim  because everybody
> > will reclaim the maximum rather than its contribution.
> > 
> > Sure we can fail to reclaim the target and slowly grow over high limit
> > but that is to be expected. This is not the max limit which cannot be
> > breached and external memory pressure/reclaim is there to mitigate that.
> 
> Ah, I see, yeah, over-reclaim can happen.  How about just wrapping the
> over-high reclaim with a per-memcg mutex?  Do we gain anything by
> putting multiple tasks into the reclaim path?

The overall reclaim throughput will be higher with the parallel reclaim.
Threads might still get synchronized on the zone lru lock but this is only
for isolating them from the LRU. In a larger hierarchies this even might
not be the case because the hierarchy iterator tries to spread the reclaim
over different memcgs.

So the per-memcg mutex would solve the potential over-reclaim but it
will restrain the reclaim activity unnecessarily. Why is per-contribution
reclaim such a big deal in the first place? If there are runaways
allocation requests like GFP_NOWAIT then we should look after those. And
I would argue that your delayed reclaim idea is a great fit for that. We
just should track how many pages were charged over high limit in the
process context and reclaim that amount on the way out from the kernel.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
