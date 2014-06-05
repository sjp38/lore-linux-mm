Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8713F6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 12:47:40 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so10758230wiw.9
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 09:47:38 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 19si12343039wju.143.2014.06.05.09.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 09:47:37 -0700 (PDT)
Date: Thu, 5 Jun 2014 12:46:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140605164657.GZ2878@cmpxchg.org>
References: <20140528152854.GG2878@cmpxchg.org>
 <20140528155414.GN9895@dhcp22.suse.cz>
 <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
 <20140605143235.GC2926@dhcp22.suse.cz>
 <20140605154328.GX2878@cmpxchg.org>
 <20140605160904.GC15939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140605160904.GC15939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu, Jun 05, 2014 at 06:09:04PM +0200, Michal Hocko wrote:
> On Thu 05-06-14 11:43:28, Johannes Weiner wrote:
> > On Thu, Jun 05, 2014 at 04:32:35PM +0200, Michal Hocko wrote:
> > > On Wed 04-06-14 11:44:08, Johannes Weiner wrote:
> > > > On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> > > > > On Tue 03-06-14 10:22:49, Johannes Weiner wrote:
> > > > > > On Tue, Jun 03, 2014 at 01:07:43PM +0200, Michal Hocko wrote:
> > > > > [...]
> > > > > > > If we consider that memcg and its limits are not zone aware while the
> > > > > > > page allocator and reclaim are zone oriented then I can see a problem
> > > > > > > of unexpected reclaim failure although there is no over commit on the
> > > > > > > low_limit globally. And we do not have in-kernel effective measures to
> > > > > > > mitigate this inherent problem. At least not now and I am afraid it is
> > > > > > > a long route to have something that would work reasonably well in such
> > > > > > > cases.
> > > > > > 
> > > > > > Which "inherent problem"?
> > > > > 
> > > > > zone unawareness of the limit vs. allocation/reclaim which are zone
> > > > > oriented.
> > > > 
> > > > This is a quote from another subthread where you haven't responded:
> > > > 
> > > > ---
> > > > 
> > > > > > > > But who actually cares if an individual zone can be reclaimed?
> > > > > > > > 
> > > > > > > > Userspace allocations can fall back to any other zone.  Unless there
> > > > > > > > are hard bindings, but hopefully nobody binds a memcg to a node that
> > > > > > > > is smaller than that memcg's guarantee. 
> > > > > > > 
> > > > > > > The protected group might spill over to another group and eat it when
> > > > > > > another group would be simply pushed out from the node it is bound to.
> > > > > > 
> > > > > > I don't really understand the point you're trying to make.
> > > > > 
> > > > > I was just trying to show a case where individual zone matters. To make
> > > > > it more specific consider 2 groups A (with low-limit 60% RAM) and B
> > > > > (say with low-limit 10% RAM) and bound to a node X (25% of RAM). Now
> > > > > having 70% of RAM reserved for guarantee makes some sense, right? B is
> > > > > not over-committing the node it is bound to. Yet the A's allocations
> > > > > might make pressure on X regardless that the whole system is still doing
> > > > > good. This can lead to a situation where X gets depleted and nothing
> > > > > would be reclaimable leading to an OOM condition.
> > > > 
> > > > Once you assume control of memory *placement* in the system like this,
> > > > you can not also pretend to be clueless and have unreclaimable memory
> > > > of this magnitude spread around into nodes used by other bound tasks.
> > > 
> > > You are still assuming that the administrator controls the placement.
> > > The load running in your memcg might be a black box for admin. E.g. a
> > > container which pays $$ to get a priority and not get reclaimed if that
> > > is possible. Admin can make sure that the cumulative low_limits for
> > > containers are sane but he doesn't have any control over what the loads
> > > inside are doing and potential OOM when one tries to DOS the other is
> > > definitely not welcome.
> > 
> > This is completely backwards, though: if you pay for guaranteed
> 
> I didn't say anything about guarantee, though. You even do not need
> anything as strong as guarantee. You are paying for prioritization.
>
> > memory, you don't want to get reclaimed just because some other task
> > that might not even have guarantees starts allocating with a
> > restricted node mask.  This breaks isolation.
> 
> If the other task doesn't have any limit set then its pages would get
> reclaimed. This wouldn't be everybody within low limit situation.

Ah, I messed up the consequences of the "all within low limit" clause.
The fallback implications on NUMA boggle my mind.

You can still break isolation when both have the same prioritization:
bind to a node that contains primarily guaranteed memory of another
group, then allocate a chunk that is within your limit to force equal
reclaim of all memory on that node, including the guaranteed memory.

As that other group refaults its pages on another node, you can just
follow it and do it again.

> > For one, this can be used maliciously by intentionally binding a
> > low-priority task to a node with guaranteed memory and starting to
> > allocate.  Even with a small hard limit, you can just plow through
> > files to push guaranteed cache of the other group out of memory.
> >
> > But even if it's not malicious, in such a scenario I'd still prefer
> > OOMing the task with the more restrictive node mask over reclaiming
> > guaranteed memory.
> 
> Why?

I think the locality preference of one group should not harm the
workingset size requirements that another group has to avoid IO.

> > Then, on top of that, we can use direct migration to mitigate OOMs in
> > these scenarios (should we sufficiently care about them), but I'd much
> > prefer OOMs over breaking isolation and the possible priority
> > inversion that is inherent in the fallback on NUMA setups.
> 
> Could you be more specific about what you mean by priority inversion?

As per above, it's not an inversion because of the "all within
guarantee" clause, but I think you can still DOS peers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
