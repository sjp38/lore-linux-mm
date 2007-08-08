Date: Wed, 8 Aug 2007 12:38:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 02/14] Memoryless nodes: introduce mask of nodes with
 memory
Message-Id: <20070808123804.d3b3bc79.akpm@linux-foundation.org>
In-Reply-To: <20070804030152.843011254@sgi.com>
References: <20070804030100.862311140@sgi.com>
	<20070804030152.843011254@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kxr@sgi.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, Bob Picco <bob.picco@hp.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 03 Aug 2007 20:01:02 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> +/* Any regular memory on that node ? */
> +static void check_for_regular_memory(pg_data_t *pgdat)
> +{
> +#ifdef CONFIG_HIGHMEM
> +	enum zone_type zone;
> +
> +	for (zone = 0; zone <= ZONE_NORMAL; zone++)
> +		if (pgdat->node_zones[zone].present_pages)
> +			node_set_state(nid, N_NORMAL_MEMORY);
> +	}
> +#endif
> +}

mm/page_alloc.c: In function 'check_for_regular_memory':
mm/page_alloc.c:2427: error: 'nid' undeclared (first use in this function)
mm/page_alloc.c:2427: error: (Each undeclared identifier is reported only once
mm/page_alloc.c:2427: error: for each function it appears in.)
mm/page_alloc.c: At top level:
mm/page_alloc.c:2430: error: expected identifier or '(' before '}' token

OK, easily fixable with

/* Any regular memory on that node ? */
static void check_for_regular_memory(pg_data_t *pgdat)
{
#ifdef CONFIG_HIGHMEM
	enum zone_type zone_type;
	
	for (zone_type = 0; zone_type <= ZONE_NORMAL; zone_type++) {
		struct zone *zone = &pgdat->node_zones[zone_type];
		if (zone->present_pages)
			node_set_state(zone_to_nid(zone), N_NORMAL_MEMORY);
	}
#endif
}

but we continue to have some significant testing issues out there.		

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
