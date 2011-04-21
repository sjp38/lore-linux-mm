Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 15C168D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 23:54:22 -0400 (EDT)
Date: Thu, 21 Apr 2011 05:53:26 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-ID: <20110421035326.GH2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
 <20110421025107.GG2333@cmpxchg.org>
 <BANLkTi=JTGngiosgEsWEo5A-xGAOeEpVGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=JTGngiosgEsWEo5A-xGAOeEpVGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, Apr 20, 2011 at 08:05:05PM -0700, Ying Han wrote:
> On Wed, Apr 20, 2011 at 7:51 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > I'm sorry that I chime in so late, I was still traveling until Monday.
> 
> Hey, hope you had a great trip :)

It was fantastic, thanks ;)

> > > If the cgroup is configured to use per cgroup background
> > > reclaim, a kswapd thread is created which only scans the
> > > per-memcg > > LRU list.
> >
> > We already have direct reclaim, direct reclaim on behalf of a memcg,
> > and global kswapd-reclaim.  Please don't add yet another reclaim path
> > that does its own thing and interacts unpredictably with the rest of
> > them.
> 
> Yes, we do have per-memcg direct reclaim and kswapd-reclaim. but the later
> one is global and we don't want to start reclaiming from each memcg until we
> reach the global memory pressure.

Not each, but a selected subset.  See below.

> > As discussed on LSF, we want to get rid of the global LRU.  So the
> > goal is to have each reclaim entry end up at the same core part of
> > reclaim that round-robin scans a subset of zones from a subset of
> > memory control groups.
> 
> True, but that is for system under global memory pressure and we would like
> to do targeting reclaim instead of reclaiming from the global LRU. That is
> not the same in this patch, which is doing targeting reclaim proactively
> per-memcg based on their hard_limit.

When triggered by global memory pressure we want to scan the subset of
memcgs that are above their soft limit, or all memcgs if none of them
exceeds their soft limit, which is a singleton in the no-memcg case.

When triggered by the hard limit, we want to scan the subset of memcgs
that have reached their hard limit, which is a singleton.

When triggered by the hard limit watermarks, we want scan the subset
of memcgs that are in violation of their watermarks.

I argue that the 'reclaim round-robin from a subset of cgroups' is the
same for all cases and that it makes sense to not encode differences
where there really are none.

> > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > background reclaim and stop it. The watermarks are calculated based
> > > on the cgroup's limit_in_bytes.
> >
> > Which brings me to the next issue: making the watermarks configurable.
> >
> > You argued that having them adjustable from userspace is required for
> > overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> > in in case of global memory pressure.  But that is only a problem
> > because global kswapd reclaim is (apart from soft limit reclaim)
> > unaware of memory control groups.
> >
> > I think the much better solution is to make global kswapd memcg aware
> > (with the above mentioned round-robin reclaim scheduler), compared to
> > adding new (and final!) kernel ABI to avoid an internal shortcoming.
> 
> We need to make the global kswapd memcg aware and that is the
> soft_limit hierarchical reclaim.

Yes, but not only.

> It is different from doing per-memcg background reclaim which we
> want to reclaim memory per-memcg before they goes to per-memcg
> direct reclaim.

Both the condition for waking up kswapd and the subset of control
groups to reclaim from are different.  But not the basic code that
goes through that subset and reclaims until the condition is resolved.

> > The whole excercise of asynchroneous background reclaim is to reduce
> > reclaim latency.  We already have a mechanism for global memory
> > pressure in place.  Per-memcg watermarks should only exist to avoid
> > direct reclaim due to hitting the hardlimit, nothing else.
> 
> Yes, but we have per-memcg direct reclaim which is based on the hard_limit.
> The latency we need to reduce is the direct reclaim which is different from
> global memory pressure.

Where is the difference?  Direct reclaim happens due to physical
memory pressure or due to cgroup-limit memory pressure.  We want both
cases to be mitigated by watermark-triggered asynchroneous reclaim.

I only say that per-memcg watermarks should not be abused to deal with
global memory pressure.

> > So in summary, I think converting the reclaim core to this round-robin
> > scheduler solves all these problems at once: a single code path for
> > reclaim, breaking up of the global lru lock, fair soft limit reclaim,
> > and a mechanism for latency reduction that just DTRT without any
> > user-space configuration necessary.
> 
> Not exactly. We will have cases where only few cgroups configured and the
> total hard_limit always less than the machine capacity. So we will never
> trigger the global memory pressure. However, we still need to smooth out the
> performance per-memcg by doing background page reclaim proactively before
> they hit their hard_limit (direct reclaim)

I did not want to argue against the hard-limit watermarks.  Sorry, I
now realize that my summary was ambiguous.

What I meant was that this group reclaimer should optimally be
implemented first, and then the hard-limit watermarks can be added as
just another trigger + subset filter for asynchroneous reclaim.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
