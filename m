Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7278E007C
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:43:44 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so2041967edq.13
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:43:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq15si1571522ejb.134.2019.01.24.00.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 00:43:42 -0800 (PST)
Date: Thu, 24 Jan 2019 09:43:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: vmscan: do not iterate all mem cgroups for
 global direct reclaim
Message-ID: <20190124084341.GE4087@dhcp22.suse.cz>
References: <1548187782-108454-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190123095926.GS4087@dhcp22.suse.cz>
 <3684a63c-4c1d-fd1a-cda5-af92fb6bea8d@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3684a63c-4c1d-fd1a-cda5-af92fb6bea8d@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 23-01-19 12:24:38, Yang Shi wrote:
> 
> 
> On 1/23/19 1:59 AM, Michal Hocko wrote:
> > On Wed 23-01-19 04:09:42, Yang Shi wrote:
> > > In current implementation, both kswapd and direct reclaim has to iterate
> > > all mem cgroups.  It is not a problem before offline mem cgroups could
> > > be iterated.  But, currently with iterating offline mem cgroups, it
> > > could be very time consuming.  In our workloads, we saw over 400K mem
> > > cgroups accumulated in some cases, only a few hundred are online memcgs.
> > > Although kswapd could help out to reduce the number of memcgs, direct
> > > reclaim still get hit with iterating a number of offline memcgs in some
> > > cases.  We experienced the responsiveness problems due to this
> > > occassionally.
> > Can you provide some numbers?
> 
> What numbers do you mean? How long did it take to iterate all the memcgs?
> For now I don't have the exact number for the production environment, but
> the unresponsiveness is visible.

Yeah, I would be interested in the worst case direct reclaim latencies.
You can get that from our vmscan tracepoints quite easily.

> I had some test number with triggering direct reclaim with 8k memcgs
> artificially, which has just one clean page charged for each memcg, so the
> reclaim is cheaper than real production environment.
> 
> perf shows it took around 220ms to iterate 8k memcgs:
> 
>               dd 13873 [011]   578.542919:
> vmscan:mm_vmscan_direct_reclaim_begin
>               dd 13873 [011]   578.758689:
> vmscan:mm_vmscan_direct_reclaim_end
> 
> So, iterating 400K would take at least 11s in this artificial case. The
> production environment is much more complicated, so it would take much
> longer in fact.

Having real world numbers would definitely help with the justification.

> > > Here just break the iteration once it reclaims enough pages as what
> > > memcg direct reclaim does.  This may hurt the fairness among memcgs
> > > since direct reclaim may awlays do reclaim from same memcgs.  But, it
> > > sounds ok since direct reclaim just tries to reclaim SWAP_CLUSTER_MAX
> > > pages and memcgs can be protected by min/low.
> > OK, this makes some sense to me. The purpose of the direct reclaim is
> > to reclaim some memory and throttle the allocation pace. The iterator is
> > cached so the next reclaimer on the same hierarchy will simply continue
> > so the fairness should be more or less achieved.
> 
> Yes, you are right. I missed this point.
> 
> > 
> > Btw. is there any reason to keep !global_reclaim() check in place? Why
> > is it not sufficient to exclude kswapd?
> 
> Iterating all memcgs in kswapd is still useful to help to reduce those
> zombie memcgs.

Yes, but for that you do not need to check for global_reclaim right?
-- 
Michal Hocko
SUSE Labs
