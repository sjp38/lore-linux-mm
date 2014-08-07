Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA356B0035
	for <linux-mm@kvack.org>; Thu,  7 Aug 2014 11:31:48 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id z12so4348984wgg.12
        for <linux-mm@kvack.org>; Thu, 07 Aug 2014 08:31:47 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fz18si8904824wic.35.2014.08.07.08.31.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 07 Aug 2014 08:31:46 -0700 (PDT)
Date: Thu, 7 Aug 2014 11:31:41 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/4] mm: memcontrol: reduce reclaim invocations for
 higher order requests
Message-ID: <20140807153141.GD14734@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-2-git-send-email-hannes@cmpxchg.org>
 <20140807130822.GB12730@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140807130822.GB12730@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 07, 2014 at 03:08:22PM +0200, Michal Hocko wrote:
> On Mon 04-08-14 17:14:54, Johannes Weiner wrote:
> > Instead of passing the request size to direct reclaim, memcg just
> > manually loops around reclaiming SWAP_CLUSTER_MAX pages until the
> > charge can succeed.  That potentially wastes scan progress when huge
> > page allocations require multiple invocations, which always have to
> > restart from the default scan priority.
> > 
> > Pass the request size as a reclaim target to direct reclaim and leave
> > it to that code to reach the goal.
> 
> THP charge then will ask for 512 pages to be (direct) reclaimed. That
> is _a lot_ and I would expect long stalls to achieve this target. I
> would also expect quick priority drop down and potential over-reclaim
> for small and moderately sized memcgs (e.g. memcg with 1G worth of pages
> would need to drop down below DEF_PRIORITY-2 to have a chance to scan
> that many pages). All that done for a charge which can fallback to a
> single page charge.
> 
> The current code is quite hostile to THP when we are close to the limit
> but solving this by introducing long stalls instead doesn't sound like a
> proper approach to me.

THP latencies are actually the same when comparing high limit nr_pages
reclaim with the current hard limit SWAP_CLUSTER_MAX reclaim, although
system time is reduced with the high limit.

High limit reclaim with SWAP_CLUSTER_MAX has better fault latency but
it doesn't actually contain the workload - with 1G high and a 4G load,
the consumption at the end of the run is 3.7G.

So what I'm proposing works and is of equal quality from a THP POV.
This change is complicated enough when we stick to the facts, let's
not make up things based on gut feeling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
