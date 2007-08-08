Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l78JtF38031192
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 15:55:15 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l78JtFMD248388
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 13:55:15 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l78JtEEs004475
	for <linux-mm@kvack.org>; Wed, 8 Aug 2007 13:55:15 -0600
Date: Wed, 8 Aug 2007 12:55:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 02/14] Memoryless nodes: introduce mask of nodes with memory
Message-ID: <20070808195514.GE16588@us.ibm.com>
References: <20070804030100.862311140@sgi.com> <20070804030152.843011254@sgi.com> <20070808123804.d3b3bc79.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070808123804.d3b3bc79.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, kxr@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On 08.08.2007 [12:38:04 -0700], Andrew Morton wrote:
> On Fri, 03 Aug 2007 20:01:02 -0700
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > +/* Any regular memory on that node ? */
> > +static void check_for_regular_memory(pg_data_t *pgdat)
> > +{
> > +#ifdef CONFIG_HIGHMEM
> > +	enum zone_type zone;
> > +
> > +	for (zone = 0; zone <= ZONE_NORMAL; zone++)
> > +		if (pgdat->node_zones[zone].present_pages)
> > +			node_set_state(nid, N_NORMAL_MEMORY);
> > +	}
> > +#endif
> > +}
> 
> mm/page_alloc.c: In function 'check_for_regular_memory':
> mm/page_alloc.c:2427: error: 'nid' undeclared (first use in this function)
> mm/page_alloc.c:2427: error: (Each undeclared identifier is reported only once
> mm/page_alloc.c:2427: error: for each function it appears in.)
> mm/page_alloc.c: At top level:
> mm/page_alloc.c:2430: error: expected identifier or '(' before '}' token
> 
> OK, easily fixable with
> 
> /* Any regular memory on that node ? */
> static void check_for_regular_memory(pg_data_t *pgdat)
> {
> #ifdef CONFIG_HIGHMEM
> 	enum zone_type zone_type;
> 	
> 	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
> 		struct zone *zone = &pgdat->node_zones[zone_type];
> 		if (zone->present_pages)
> 			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
> 	}
> #endif
> }
> 
> but we continue to have some significant testing issues out there.		

This would be because the patch that Christoph submitted here is not the
same as the patch that Mel and I tested...There was no
check_for_regular_memory() function in the kernels I was building.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
