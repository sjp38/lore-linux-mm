From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: exclude memory less nodes from zone_reclaim
Date: Fri, 21 Feb 2014 15:57:48 -0800
Message-ID: <20140221235748.GB25399@linux.vnet.ibm.com>
References: <1392889904-18019-1-git-send-email-mhocko@suse.cz>
 <20140221140735.cef7531462f31c408012b8cb@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140221140735.cef7531462f31c408012b8cb@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On 21.02.2014 [14:07:35 -0800], Andrew Morton wrote:
> On Thu, 20 Feb 2014 10:51:44 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
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
> > make any sense on the memory less nodes. So let's exclude such nodes
> > for init_zone_allows_reclaim which evaluates zone reclaim behavior and
> > suitable reclaim_nodes.
> > 
> > ...
> >
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1855,7 +1855,7 @@ static void __paginginit init_zone_allows_reclaim(int nid)
> >  {
> >  	int i;
> >  
> > -	for_each_online_node(i)
> > +	for_each_node_state(i, N_MEMORY)
> >  		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
> >  			node_set(i, NODE_DATA(nid)->reclaim_nodes);
> >  		else
> > @@ -4901,7 +4901,8 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
> >  
> >  	pgdat->node_id = nid;
> >  	pgdat->node_start_pfn = node_start_pfn;
> > -	init_zone_allows_reclaim(nid);
> > +	if (node_state(nid, N_MEMORY))
> > +		init_zone_allows_reclaim(nid);
> >  #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> >  	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
> >  #endif
> 
> What happens if someone later hot-adds some memory to that node?

This probably isn't a very good answer, but I think the question of how
to support a node that starts off memoryless and then gets memory
hot-added later is still open. But this at least gets us further and
would be needed anyways, I think.

I'm going to try and look at the hot-add component after we get this
base stuff in, if that's ok, but it's definitely on my todo list.

Thanks,
Nish
