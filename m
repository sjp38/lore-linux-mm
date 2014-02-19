Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 73A086B0036
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 12:33:04 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id t61so576562wes.8
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 09:33:03 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id wf8si1239248wjb.82.2014.02.19.09.33.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 09:33:02 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id z12so590432wgg.29
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 09:33:02 -0800 (PST)
Date: Wed, 19 Feb 2014 18:32:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] mm: exclude memory less nodes from zone_reclaim
Message-ID: <20140219173259.GA5041@dhcp22.suse.cz>
References: <20140219082313.GB14783@dhcp22.suse.cz>
 <1392829383-4125-1-git-send-email-mhocko@suse.cz>
 <20140219171628.GE27108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219171628.GE27108@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 19-02-14 09:16:28, Nishanth Aravamudan wrote:
> On 19.02.2014 [18:03:03 +0100], Michal Hocko wrote:
> > We had a report about strange OOM killer strikes on a PPC machine
> > although there was a lot of swap free and a tons of anonymous memory
> > which could be swapped out. In the end it turned out that the OOM was
> > a side effect of zone reclaim which wasn't doesn't unmap and swapp out
> > and so the system was pushed to the OOM. Although this sounds like a bug
> > somewhere in the kswapd vs. zone reclaim vs. direct reclaim interaction
> > numactl on the said hardware suggests that the zone reclaim should
> > have been set in the first place:
> > node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
> > node 0 size: 0 MB
> > node 0 free: 0 MB
> > node 2 cpus:
> > node 2 size: 7168 MB
> > node 2 free: 6019 MB
> > node distances:
> > node   0   2
> > 0:  10  40
> > 2:  40  10
> > 
> > So all the CPUs are associated with Node0 which doesn't have any memory
> > while Node2 contains all the available memory. Node distances cause an
> > automatic zone_reclaim_mode enabling.
> > 
> > Zone reclaim is intended to keep the allocations local but this doesn't
> > make any sense on the memory less nodes. So let's exlcude such nodes
> > for init_zone_allows_reclaim which evaluates zone reclaim behavior and
> > suitable reclaim_nodes.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> > I haven't got to testing this so I am sending this as an RFC for now.
> > But does this look reasonable?
> > 
> >  mm/page_alloc.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 3e953f07edb0..4a44bdc7a8cf 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1855,7 +1855,7 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> >  {
> >  	int i;
> > 
> > -	for_each_online_node(i)
> > +	for_each_node_state(i, N_HIGH_MEMORY)
> >  		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> >  			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> >  		else
> > @@ -4901,7 +4901,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> > 
> >  	pgdat->node_id = nid;
> >  	pgdat->node_start_pfn = node_start_pfn;
> > -	init_zone_allows_reclaim(nid);
> > +	if (node_state(nid, N_HIGH_MEMORY))
> > +		init_zone_allows_reclaim(nid);
> 
> I don't think this will work, because what sets N_HIGH_MEMORY (and
> shouldn't it be N_MEMORY?)

This should be the same thing AFAIU.

> is check_for_memory() (free_area_init_nodes() for N_MEMORY), which is
> run *after* init_zone_allows_reclaim().

early_calculate_totalpages sets the memory state before we get here.

> Further, the for_each_node_state() loop doesn't make sense at this
> point, becuase we are actually setting up the nids as we go. So node
> 0, will only see node 0 in the N_HIGH_MEMORY mask (if any). Node 1,
> will only see nodes 0 and 1, etc.

I am not sure I understand what you are saying here. Why would se
consider distance to a memoryless node in the first place.
for_each_node_state just makes sure we are comparing only to a node
which has some memory.

> I'm working on testing a patch that reorders some of this in hopefully a
> safe way.

Although it might make some sense to reorganize the code (it's a mess if
you ask me), but I do not think it is necessary.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
