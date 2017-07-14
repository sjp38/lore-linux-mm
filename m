Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A810E440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 07:43:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p64so11036005wrc.8
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:43:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p91si6343791wrc.257.2017.07.14.04.43.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 04:43:23 -0700 (PDT)
Date: Fri, 14 Jul 2017 13:43:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/9] mm, page_alloc: remove stop_machine from
 build_all_zonelists
Message-ID: <20170714114321.GJ2618@dhcp22.suse.cz>
References: <20170714080006.7250-1-mhocko@kernel.org>
 <20170714080006.7250-8-mhocko@kernel.org>
 <52b1af9a-a5a9-9157-8f0f-f17946aeb2da@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52b1af9a-a5a9-9157-8f0f-f17946aeb2da@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 14-07-17 13:29:14, Vlastimil Babka wrote:
> On 07/14/2017 10:00 AM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > build_all_zonelists has been (ab)using stop_machine to make sure that
> > zonelists do not change while somebody is looking at them. This is
> > is just a gross hack because a) it complicates the context from which
> > we can call build_all_zonelists (see 3f906ba23689 ("mm/memory-hotplug:
> > switch locking to a percpu rwsem")) and b) is is not really necessary
> > especially after "mm, page_alloc: simplify zonelist initialization".
> > 
> > Updates of the zonelists happen very seldom, basically only when a zone
> > becomes populated during memory online or when it loses all the memory
> > during offline. A racing iteration over zonelists could either miss a
> > zone or try to work on one zone twice. Both of these are something we
> > can live with occasionally because there will always be at least one
> > zone visible so we are not likely to fail allocation too easily for
> > example.
> 
> Given the experience with with cpusets and mempolicies, I would rather
> avoid the risk of allocation not seeing the only zone(s) that are
> allowed by its nodemask, and triggering premature OOM.

I would argue, those are a different beast because they are directly
under control of not fully priviledged user and change between the empty
nodemask and cpusets very often. For this one to trigger we
would have to online/offline the last memory block in the zone very
often and that doesn't resemble a sensible usecase even remotely.

> So maybe the
> updates could be done in a way to avoid that, e.g. first append a copy
> of the old zonelist to the end, then overwrite and terminate with NULL.
> But if this requires any barriers or something similar on the iteration
> site, which is performance critical, then it's bad.
> Maybe a seqcount, that the iteration side only starts checking in the
> slowpath? Like we have with cpusets now.
> I know that Mel noted that stop_machine() also never had such guarantees
> to prevent this, but it could have made the chances smaller.

I think we can come up with some scheme but is this really worth it
considering how unlikely the whole thing is? Well, if somebody hits a
premature OOM killer or allocations failures it would have to be along
with a heavy memory hotplug operations and then it would be quite easy
to spot what is going on and try to fix it. I would rather not
overcomplicate it, to be honest.

> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/page_alloc.c | 9 ++-------
> >  1 file changed, 2 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 78bd62418380..217889ecd13f 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5066,8 +5066,7 @@ static DEFINE_PER_CPU(struct per_cpu_nodestat, boot_nodestats);
> >   */
> >  DEFINE_MUTEX(zonelists_mutex);
> >  
> > -/* return values int ....just for stop_machine() */
> > -static int __build_all_zonelists(void *data)
> > +static void __build_all_zonelists(void *data)
> >  {
> >  	int nid;
> >  	int cpu;
> > @@ -5103,8 +5102,6 @@ static int __build_all_zonelists(void *data)
> >  			set_cpu_numa_mem(cpu, local_memory_node(cpu_to_node(cpu)));
> >  #endif
> >  	}
> > -
> > -	return 0;
> >  }
> >  
> >  static noinline void __init
> > @@ -5147,9 +5144,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
> >  	if (system_state == SYSTEM_BOOTING) {
> >  		build_all_zonelists_init();
> >  	} else {
> > -		/* we have to stop all cpus to guarantee there is no user
> > -		   of zonelist */
> > -		stop_machine_cpuslocked(__build_all_zonelists, pgdat, NULL);
> > +		__build_all_zonelists(pgdat);
> >  		/* cpuset refresh routine should be here */
> >  	}
> >  	vm_total_pages = nr_free_pagecache_pages();
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
