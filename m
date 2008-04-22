Subject: Re: Suspect use of "first_zones_zonelist()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080422174901.GA7261@csn.ul.ie>
References: <1208877444.5534.34.camel@localhost>
	 <20080422161524.GA27624@csn.ul.ie> <1208884215.5534.57.camel@localhost>
	 <20080422174901.GA7261@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 22 Apr 2008 14:01:10 -0400
Message-Id: <1208887271.5534.99.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-22 at 18:49 +0100, Mel Gorman wrote:
> On (22/04/08 13:10), Lee Schermerhorn didst pronounce:
> > > > <SNIP>
> > > >
> > > > --i.e., the first that satisfies any nodemask
> > > > constraint.  I renamed 'dummy' to 'zone', ignore the return value and
> > > > use:  newnid = zone->node.  [I guess I could use zonelist_node_idx(zr
> > > > -1) as well.] 
> > > 
> > > zr - 1 would be vunerable to the iterator implementation changing.
> > 
> > Ah, good point.  Shouldn't peek under the covers like that.
> > 
> > > 
> > > >  This results in page migration to the expected node.
> > > > 
> > > 
> > > This use of zone instead of the zoneref cursor should be made throughout.
> > > 
> > > > Anyway, after discovering this, I checked other usages of
> > > > first_zones_zonelist() outside of the iterator macros, and I THINK they
> > > > might be making the same mistake?
> > > > 
> > > 
> > > Yes, you're right.
> > > 
> > > > Here's a patch that "fixes" these.  Do you agree?  Or am I
> > > > misunderstanding this area [again!]?
> > > > 
> > > 
> > > No, I screwed up with the use of cursors and didn't get caught for it as
> > > the effect would be very difficult to spot normally. I extended your patch
> > > slightly below to catch the other callers. Can you take a read-through please?
> > 
> > OK.  Looks good.  I see I missed one case.
> > 
> > A suggestion.  How about enhancing the comment [maybe a kernel doc
> > block?] on first_zones_zonelist() to explain that it returns the zone
> > via the zone parameter and that the return value is a cursor for
> > iterators?  Perhaps similarly for next_zones_zonelist() in mmzone.c?
> > 
> > Or would you like me to take a cut at this?
> > 
> 
> That's a good suggestion. How about the following?

Very nice.  Wish I'd had that to reference earlier :)

Lee
> 
> =======
> Subject: [PATCH] fix off-by-one usage of first_zones_zonelist()
> 
> Against:  2.6.25-mm1
> 
> The return value of first_zones_zonelist() is actually the zoneref
> AFTER the "requested zone"--i.e., the first zone in the zonelist
> that satisfies any nodemask constraint.  The "requested zone" is
> returned via the @zone parameter.  The returned zoneref is intended
> to be passed to next_zones_zonelist() on subsequent iterations.
> 
> This patch fixes first_zones_zonelist() callers appropriately and documents
> first_zones_zonelist() to help avoid a repeat of the same mistake.
> 
> Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  fs/buffer.c            |    9 ++++-----
>  include/linux/mmzone.h |   25 ++++++++++++++++++++++++-
>  mm/mempolicy.c         |    9 ++++-----
>  mm/page_alloc.c        |    4 ++--
>  4 files changed, 34 insertions(+), 13 deletions(-)
> 
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/fs/buffer.c linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/fs/buffer.c
> --- linux-2.6.25-mm1-clean/fs/buffer.c	2008-04-22 10:30:02.000000000 +0100
> +++ linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/fs/buffer.c	2008-04-22 18:35:56.000000000 +0100
> @@ -368,18 +368,17 @@ void invalidate_bdev(struct block_device
>   */
>  static void free_more_memory(void)
>  {
> -	struct zoneref *zrefs;
> -	struct zone *dummy;
> +	struct zone *zone;
>  	int nid;
>  
>  	wakeup_pdflush(1024);
>  	yield();
>  
>  	for_each_online_node(nid) {
> -		zrefs = first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
> +		(void)first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
>  						gfp_zone(GFP_NOFS), NULL,
> -						&dummy);
> -		if (zrefs->zone)
> +						&zone);
> +		if (zone)
>  			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
>  						GFP_NOFS);
>  	}
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/include/linux/mmzone.h linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/include/linux/mmzone.h
> --- linux-2.6.25-mm1-clean/include/linux/mmzone.h	2008-04-22 10:30:03.000000000 +0100
> +++ linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/include/linux/mmzone.h	2008-04-22 18:45:37.000000000 +0100
> @@ -742,12 +742,36 @@ static inline int zonelist_node_idx(stru
>  #endif /* CONFIG_NUMA */
>  }
>  
> +/**
> + * next_zones_zonelist - Returns the next zone at or below highest_zoneidx within the allowed nodemask using a cursor within a zonelist as a starting point
> + * @z - The cursor used as a starting point for the search
> + * @highest_zoneidx - The zone index of the highest zone to return
> + * @nodes - An optional nodemask to filter the zonelist with
> + * @zone - The first suitable zone found is returned via this parameter
> + *
> + * This function returns the next zone at or below a given zone index that is
> + * within the allowed nodemask using a cursor as the starting point for the
> + * search. The zoneref returned is a cursor that is used as the next starting
> + * point for future calls to next_zones_zonelist().
> + */
>  struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					enum zone_type highest_zoneidx,
>  					nodemask_t *nodes,
>  					struct zone **zone);
>  
> -/* Returns the first zone at or below highest_zoneidx in a zonelist */
> +/**
> + * first_zones_zonelist - Returns the first zone at or below highest_zoneidx within the allowed nodemask in a zonelist
> + * @zonelist - The zonelist to search for a suitable zone
> + * @highest_zoneidx - The zone index of the highest zone to return
> + * @nodes - An optional nodemask to filter the zonelist with
> + * @zone - The first suitable zone found is returned via this parameter
> + *
> + * This function returns the first zone at or below a given zone index that is
> + * within the allowed nodemask. The zoneref returned is a cursor that can be
> + * used to iterate the zonelist with next_zones_zonelist. The cursor should
> + * not be used by the caller as it does not match the value of the zone
> + * returned.
> + */
>  static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  					enum zone_type highest_zoneidx,
>  					nodemask_t *nodes,
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/mempolicy.c linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/mm/mempolicy.c
> --- linux-2.6.25-mm1-clean/mm/mempolicy.c	2008-04-22 10:30:04.000000000 +0100
> +++ linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/mm/mempolicy.c	2008-04-22 18:35:56.000000000 +0100
> @@ -1396,14 +1396,13 @@ unsigned slab_node(struct mempolicy *pol
>  		 * first node.
>  		 */
>  		struct zonelist *zonelist;
> -		struct zoneref *z;
> -		struct zone *dummy;
> +		struct zone *zone;
>  		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
>  		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
> -		z = first_zones_zonelist(zonelist, highest_zoneidx,
> +		(void)first_zones_zonelist(zonelist, highest_zoneidx,
>  							&policy->v.nodes,
> -							&dummy);
> -		return zonelist_node_idx(z);
> +							&zone);
> +		return zone->node;
>  	}
>  
>  	default:
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.25-mm1-clean/mm/page_alloc.c linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/mm/page_alloc.c
> --- linux-2.6.25-mm1-clean/mm/page_alloc.c	2008-04-22 10:30:04.000000000 +0100
> +++ linux-2.6.25-mm1-fix-first_zone_zonelist-v1r2/mm/page_alloc.c	2008-04-22 18:35:56.000000000 +0100
> @@ -1412,9 +1412,9 @@ get_page_from_freelist(gfp_t gfp_mask, n
>  	int zlc_active = 0;		/* set if using zonelist_cache */
>  	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
>  
> -	z = first_zones_zonelist(zonelist, high_zoneidx, nodemask,
> +	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
>  							&preferred_zone);
> -	classzone_idx = zonelist_zone_idx(z);
> +	classzone_idx = zone_idx(preferred_zone);
>  
>  zonelist_scan:
>  	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
