Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 88BFB6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 15:55:47 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id d17so77892eek.16
        for <linux-mm@kvack.org>; Tue, 06 May 2014 12:55:47 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id n46si14284917eeo.187.2014.05.06.12.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 12:55:46 -0700 (PDT)
Date: Tue, 6 May 2014 15:55:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140506195531.GL19914@cmpxchg.org>
References: <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
 <20140506132932.GF19914@cmpxchg.org>
 <20140506143242.GB19672@dhcp22.suse.cz>
 <20140506152112.GG19914@cmpxchg.org>
 <20140506161256.GE19672@dhcp22.suse.cz>
 <20140506165150.GI19914@cmpxchg.org>
 <20140506183001.GB30921@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140506183001.GB30921@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Tue, May 06, 2014 at 08:30:01PM +0200, Michal Hocko wrote:
> On Tue 06-05-14 12:51:50, Johannes Weiner wrote:
> > On Tue, May 06, 2014 at 06:12:56PM +0200, Michal Hocko wrote:
> > > On Tue 06-05-14 11:21:12, Johannes Weiner wrote:
> > > > On Tue, May 06, 2014 at 04:32:42PM +0200, Michal Hocko wrote:
> [...]
> > > > > The strongest point was made by Rik when he claimed that memcg is not
> > > > > aware of memory zones and so one memcg with lowlimit larger than the
> > > > > size of a zone can eat up that zone without any way to free it.
> > > > 
> > > > But who actually cares if an individual zone can be reclaimed?
> > > > 
> > > > Userspace allocations can fall back to any other zone.  Unless there
> > > > are hard bindings, but hopefully nobody binds a memcg to a node that
> > > > is smaller than that memcg's guarantee. 
> > > 
> > > The protected group might spill over to another group and eat it when
> > > another group would be simply pushed out from the node it is bound to.
> > 
> > I don't really understand the point you're trying to make.
> 
> I was just trying to show a case where individual zone matters. To make
> it more specific consider 2 groups A (with low-limit 60% RAM) and B
> (say with low-limit 10% RAM) and bound to a node X (25% of RAM). Now
> having 70% of RAM reserved for guarantee makes some sense, right? B is
> not over-committing the node it is bound to. Yet the A's allocations
> might make pressure on X regardless that the whole system is still doing
> good. This can lead to a situation where X gets depleted and nothing
> would be reclaimable leading to an OOM condition.

Once you assume control of memory *placement* in the system like this,
you can not also pretend to be clueless and have unreclaimable memory
of this magnitude spread around into nodes used by other bound tasks.

If we were to actively support such configurations, we should be doing
direct NUMA balancing and migrate these pages out of node X when B
needs to allocate.  That would fix the problem for all unevictable
memory, not just memcg guarantees, and would prefer node-offloading
over swapping in cases where swap is available.

But really, this whole scenario sounds contrived to me.  And there is
nothing specific about memcg guarantees in there.

> I can imagine that most people would rather see the lowlimit break than
> OOM. And if there is somebody who really wants OOM even under such
> condition then why not, I would be happy to add a knob which would allow
> that. But I feel that the default behavior should be the least explosive
> one...

Memcgs being node-agnostic is a reason *for* doing hard guarantees,
not against it.  If I set up guarantees on a NUMA system balanced by
the kernel, I want them to be honored, and not have my guaranteed
memory reclaimed randomly due to kernel-internal placement decisions.

> > > > And while the pages are not
> > > > reclaimable, they are still movable, so the NUMA balancer is free to
> > > > correct any allocation mistakes later on.
> > > 
> > > Do we want to depend on NUMA balancer, though?
> > 
> > You're missing my point.
> > 
> > This is about which functionality of the system is actually impeded by
> > having large portions of a zone unreclaimable.  Freeing pages in a
> > zone is means to an end, not an end in itself.
> > 
> > We wouldn't depend on the NUMA balancer to "free" a zone, I'm just
> > saying that the NUMA balancer would be unaffected by a zone full of
> > unreclaimable pages, as long as they are movable.
> 
> Agreed. I wasn't objecting to that part. I was merely noticing that we
> do not want to depend on NUMA balancer to fix up placements later just
> because they are unreclaimable due to restrictions defined outside of
> the NUMA scope.

Again, this is not a new problem.  Solve it if you want to, but don't
design a new userspace ABI around a limitation in NUMA node reclaim.

> > So who exactly cares about the ability to reclaim individual zones and
> > how is it a new type of problem compared to existing unreclaimable but
> > movable memory?
> 
> The low limit makes the current situation different. Page allocator
> simply cannot make the best decisions on the placement because it
> doesn't have any idea to which group the page gets charged to and
> therefore whether it gets protected or not. NUMA balancing can help
> to reduce this issues but I do not think it can handle the problem
> itself.

It depends on the task, not on the group.

You can turn your argument upside down: if you fail guarantees just
because a single zone is otherwise unreclaimable, then page allocator
placement ends up dictating which page is guaranteed memory and which
is not.  This really makes no sense to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
