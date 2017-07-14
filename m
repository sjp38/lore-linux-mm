Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E46D4440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:56:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l34so11165941wrc.12
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:56:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si3303170wrb.59.2017.07.14.05.56.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:56:55 -0700 (PDT)
Date: Fri, 14 Jul 2017 13:56:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/9] mm, page_alloc: do not set_cpu_numa_mem on empty
 nodes initialization
Message-ID: <20170714125653.sukwmyvxnx3qqice@suse.de>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-4-mhocko@kernel.org>
 <20170714094810.ftthctfz33artwh2@suse.de>
 <20170714105003.GE2618@dhcp22.suse.cz>
 <20170714123242.zepgecug2kdolhky@suse.de>
 <20170714123940.GN2618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170714123940.GN2618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 14, 2017 at 02:39:41PM +0200, Michal Hocko wrote:
> On Fri 14-07-17 13:32:42, Mel Gorman wrote:
> > On Fri, Jul 14, 2017 at 12:50:04PM +0200, Michal Hocko wrote:
> > > On Fri 14-07-17 10:48:10, Mel Gorman wrote:
> > > > On Fri, Jul 14, 2017 at 10:00:00AM +0200, Michal Hocko wrote:
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > __build_all_zonelists reinitializes each online cpu local node for
> > > > > CONFIG_HAVE_MEMORYLESS_NODES. This makes sense because previously memory
> > > > > less nodes could gain some memory during memory hotplug and so the local
> > > > > node should be changed for CPUs close to such a node. It makes less
> > > > > sense to do that unconditionally for a newly creaded NUMA node which is
> > > > > still offline and without any memory.
> > > > > 
> > > > > Let's also simplify the cpu loop and use for_each_online_cpu instead of
> > > > > an explicit cpu_online check for all possible cpus.
> > > > > 
> > > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > > ---
> > > > >  mm/page_alloc.c | 6 ++----
> > > > >  1 file changed, 2 insertions(+), 4 deletions(-)
> > > > > 
> > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > index 7746824a425d..ebc3311555b1 100644
> > > > > --- a/mm/page_alloc.c
> > > > > +++ b/mm/page_alloc.c
> > > > > @@ -5096,10 +5096,8 @@ static int __build_all_zonelists(void *data)
> > > > >  
> > > > >  			build_zonelists(pgdat);
> > > > >  		}
> > > > > -	}
> > > > >  
> > > > >  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> > > > > -	for_each_possible_cpu(cpu) {
> > > > >  		/*
> > > > >  		 * We now know the "local memory node" for each node--
> > > > >  		 * i.e., the node of the first zone in the generic zonelist.
> > > > > @@ -5108,10 +5106,10 @@ static int __build_all_zonelists(void *data)
> > > > >  		 * secondary cpus' numa_mem as they come on-line.  During
> > > > >  		 * node/memory hotplug, we'll fixup all on-line cpus.
> > > > >  		 */
> > > > > -		if (cpu_online(cpu))
> > > > > +		for_each_online_cpu(cpu)
> > > > >  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> > > > > -	}
> > > > >  #endif
> > > > > +	}
> > > > >  
> > > > 
> > > > This is not as clear a benefit. For each online node, we now go through
> > > > all online CPUs once per node. There would be some rationale for using
> > > > for_each_online_cpu.
> > > 
> > > I am not sure I understand. I am using for_each_online_cpu...
> > 
> > Yes, but within a loop that looks like
> > 
> > for_each_online_node(nid)
> > 	...
> > 	for_each_online_cpu(cpu)
> > 
> > Or maybe you aren't because we are looking at different baselines. I had
> > minor fuzz and conflicts applying the series.
> 
> The current mmotm after this patch looks like this
> 	if (self && !node_online(self->node_id)) {
> 		build_zonelists(self);
> 	} else {
> 		for_each_online_node(nid) {
> 			pg_data_t *pgdat = NODE_DATA(nid);
> 
> 			build_zonelists(pgdat);
> 		}
> 
> #ifdef CONFIG_HAVE_MEMORYLESS_NODES
> 		/*
> 		 * We now know the "local memory node" for each node--
> 		 * i.e., the node of the first zone in the generic zonelist.
> 		 * Set up numa_mem percpu variable for on-line cpus.  During
> 		 * boot, only the boot cpu should be on-line;  we'll init the
> 		 * secondary cpus' numa_mem as they come on-line.  During
> 		 * node/memory hotplug, we'll fixup all on-line cpus.
> 		 */
> 		for_each_online_cpu(cpu)
> 			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> #endif
> 	}
> 

Ok, that makes more sense.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
