Date: Thu, 26 Jul 2007 17:16:52 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070726161652.GA16556@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070726131539.8a05760f.kamezawa.hiroyu@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (26/07/07 13:15), KAMEZAWA Hiroyuki didst pronounce:
> On Wed, 25 Jul 2007 12:31:21 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> > So for a __GFP_MOVABLE alloc we would scan all zones and for 
> > policy_zone just the policy zone.
> > 
> > Lee should probably also review this in detail since he has recent 
> > experience fiddling around with memory policies. Paul has also 
> > experience in this area.
> > 
> > Maybe this can actually  help to deal with some of the corner cases of 
> > memory policies (just hope the performance impact is not significant).
> > 
> > 
>
> Hmm,  How about following patch ? (not tested, just an idea).
> I'm sorry if I misunderstand concept ot policy_zone.
> 

The following seems like a good idea to do anyway.

> ==
> Index: linux-2.6.23-rc1/include/linux/mempolicy.h
> ===================================================================
> --- linux-2.6.23-rc1.orig/include/linux/mempolicy.h
> +++ linux-2.6.23-rc1/include/linux/mempolicy.h
> @@ -162,14 +162,11 @@ extern struct zonelist *huge_zonelist(st
>  		unsigned long addr, gfp_t gfp_flags);
>  extern unsigned slab_node(struct mempolicy *policy);
>  
> +/*
> + * The smalles zone_idx which all nodes can offer against GFP_xxx
> + */
>  extern enum zone_type policy_zone;
>  

The comment is a little misleading

/* policy_zone is the lowest zone index that is present on all nodes */

Right?

> -static inline void check_highest_zone(enum zone_type k)
> -{
> -	if (k > policy_zone)
> -		policy_zone = k;
> -}
> -
>  int do_migrate_pages(struct mm_struct *mm,
>  	const nodemask_t *from_nodes, const nodemask_t *to_nodes, int flags);
>  
> Index: linux-2.6.23-rc1/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.23-rc1.orig/mm/page_alloc.c
> +++ linux-2.6.23-rc1/mm/page_alloc.c
> @@ -1648,7 +1648,6 @@ static int build_zonelists_node(pg_data_
>  		zone = pgdat->node_zones + zone_type;
>  		if (populated_zone(zone)) {
>  			zonelist->zones[nr_zones++] = zone;
> -			check_highest_zone(zone_type);
>  		}
>  
>  	} while (zone_type);
> @@ -1857,7 +1856,6 @@ static void build_zonelists_in_zone_orde
>  				z = &NODE_DATA(node)->node_zones[zone_type];
>  				if (populated_zone(z)) {
>  					zonelist->zones[pos++] = z;
> -					check_highest_zone(zone_type);
>  				}
>  			}
>  		}
> @@ -1934,6 +1932,7 @@ static void build_zonelists(pg_data_t *p
>  	int local_node, prev_node;
>  	struct zonelist *zonelist;
>  	int order = current_zonelist_order;
> +	int highest_zone;
>  
>  	/* initialize zonelists */
>  	for (i = 0; i < MAX_NR_ZONES; i++) {
> @@ -1981,6 +1980,32 @@ static void build_zonelists(pg_data_t *p
>  		/* calculate node order -- i.e., DMA last! */
>  		build_zonelists_in_zone_order(pgdat, j);
>  	}
> +	/*
> +	 * Find the lowest zone where mempolicy (MBID) can work well.
> + 	 */

/*
 * Find the lowest zone such that using the MPOL_BIND policy with
 * an arbitrary set of nodes will not go OOM because a suitable
 * zone was unavailable
 */

> +	highest_zone = 0;
> +	policy_zone = -1;
> +	for (i = 0; i < MAX_NR_ZONES; i++) {
> +		struct zone *first_zone;
> +		int success = 1;
> +		for_each_node_state(node, N_MEMORY) {
> +			first_zone = NODE_DATA(node)->node_zonelists[i][0];
> +			if (zone_idx(first_zone) > highest_zone)
> +				highest_zone = zone_idx(first_zone);
> +			if (first_zone->zone_pgdat != NODE_DATA(node)) {
> +				/* This node cannot offer right pages for this
> +				   GFP */
> +				success = 0;
> +				break;
> +			}

The second "if" needs to go first I believe.

> +		}
> +		if (success) {
> +			policy_zone = i;
> +			break;
> +		}
> +	}
> +	if (policy_zone == -1)
> +		policy_zone = highest_zone;
>  }
>  
>  /* Construct the zonelist performance cache - see further mmzone.h */

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
