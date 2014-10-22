Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC3E6B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 09:51:33 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id gi9so2913548lab.5
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 06:51:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lj3si23373520lab.112.2014.10.22.06.51.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 06:51:31 -0700 (PDT)
Date: Wed, 22 Oct 2014 15:51:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: remove mem_cgroup_reclaimable check from soft
 reclaim
Message-ID: <20141022135131.GB30802@dhcp22.suse.cz>
References: <1413897350-32553-1-git-send-email-vdavydov@parallels.com>
 <20141021182239.GA24899@phnom.home.cmpxchg.org>
 <20141022112116.GA30802@dhcp22.suse.cz>
 <20141022124025.GA17161@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022124025.GA17161@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 22-10-14 08:40:25, Johannes Weiner wrote:
> On Wed, Oct 22, 2014 at 01:21:16PM +0200, Michal Hocko wrote:
> > On Tue 21-10-14 14:22:39, Johannes Weiner wrote:
> > [...]
> > > From 27bd24b00433d9f6c8d60ba2b13dbff158b06c13 Mon Sep 17 00:00:00 2001
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Date: Tue, 21 Oct 2014 09:53:54 -0400
> > > Subject: [patch] mm: memcontrol: do not filter reclaimable nodes in NUMA
> > >  round-robin
> > > 
> > > The round-robin node reclaim currently tries to include only nodes
> > > that have memory of the memcg in question, which is quite elaborate.
> > > 
> > > Just use plain round-robin over the nodes that are allowed by the
> > > task's cpuset, which are the most likely to contain that memcg's
> > > memory.  But even if zones without memcg memory are encountered,
> > > direct reclaim will skip over them without too much hassle.
> > 
> > I do not think that using the current's node mask is correct. Different
> > tasks in the same memcg might be bound to different nodes and then a set
> > of nodes might be reclaimed much more if a particular task hits limit
> > more often. It also doesn't make much sense from semantical POV, we are
> > reclaiming memcg so the mask should be union of all tasks allowed nodes.
> 
> Unless the cpuset hierarchy is separate from the memcg hierarchy, all
> tasks in the memcg belong to the same cpuset.  And the whole point of
> cpusets is that a group of tasks has the same nodemask, no?

Memory limit and memory placement are orthogonal configurations and they
might be stacked one on top of other in both directions.
 
> Sure, there are *possible* configurations for which this assumption
> breaks, like multiple hierarchies, but are they sensible?  Do we care?

Why wouldn't they be sensible? What is wrong about limiting memory of
a load which internally uses node placement for its components?

> > What we do currently is overly complicated though and I agree that there
> > is no good reason for it.
> > Let's just s@cpuset_current_mems_allowed@node_online_map@ and round
> > robin over all nodes. As you said we do not have to optimize for empty
> > zones.
> 
> That was what I first had.  And cpuset_current_mems_allowed defaults
> to node_online_map, but once the user sets up cpusets in conjunction
> with memcgs, it seems to be the preferred value.
> 
> The other end of this is that if you have 16 nodes and use cpuset to
> bind the task to node 14 and 15, round-robin iterations of node 1-13
> will reclaim the group's memory on 14 and only the 15 iteration will
> actually look at memory from node 15 first.

mem_cgroup_select_victim_node can check reclaimability of the memcg
(hierarchy) and skip nodes without pages. Or would that be too
expensive? We are in the slow path already.

> It seems using the cpuset bindings, while theoretically independent,
> would do the right thing for all intents and purposes.

Only if cpuset is on top of memcg. Not the other way around as mentioned
above (possible node over-reclaim).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
