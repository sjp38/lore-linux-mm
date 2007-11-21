Subject: Re: [PATCH 5/6] Have zonelist contains structs with both a zone
	pointer and zone_idx
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071121004028.10789.46824.sendpatchset@skynet.skynet.ie>
References: <20071121003848.10789.18030.sendpatchset@skynet.skynet.ie>
	 <20071121004028.10789.46824.sendpatchset@skynet.skynet.ie>
Content-Type: text/plain
Date: Wed, 21 Nov 2007 13:12:27 -0500
Message-Id: <1195668748.5294.13.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Are the comparisons noted below correct--i.e., '>' rather than '<'?  I'm
trying to understand how this matches the comments and code.  Doesn't
look right to me, but I could be missing something. 

Lee

On Wed, 2007-11-21 at 00:40 +0000, Mel Gorman wrote:
> Filtering zonelists requires very frequent use of zone_idx(). This is costly
> as it involves a lookup of another structure and a substraction operation. As
> the zone_idx is often required, it should be quickly accessible.  The node
> idx could also be stored here if it was found that accessing zone->node is
> significant which may be the case on workloads where nodemasks are heavily
> used.
> 
> This patch introduces a struct zoneref to store a zone pointer and a zone
> index.  The zonelist then consists of an array of these struct zonerefs which
> are looked up as necessary. Helpers are given for accessing the zone index
> as well as the node index.
> 
> [kamezawa.hiroyu@jp.fujitsu.com: Suggested struct zoneref instead of embedding information in pointers]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <clameter@sgi.com>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
> 
>  arch/parisc/mm/init.c  |    2 -
>  fs/buffer.c            |    6 ++--
>  include/linux/mmzone.h |   64 ++++++++++++++++++++++++++++++++++++------
>  include/linux/oom.h    |    4 +-
>  kernel/cpuset.c        |    4 +-
>  mm/hugetlb.c           |    3 +-
>  mm/mempolicy.c         |   36 ++++++++++++++----------
>  mm/oom_kill.c          |   45 ++++++++++++++----------------
>  mm/page_alloc.c        |   66 ++++++++++++++++++++++++--------------------
>  mm/slab.c              |    2 -
>  mm/slub.c              |    2 -
>  mm/vmscan.c            |    6 ++--
>  12 files changed, 149 insertions(+), 91 deletions(-)
> 
<snip>
> diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc2-mm1-010_use_two_zonelists/include/linux/mmzone.h linux-2.6.24-rc2-mm1-020_zoneid_zonelist/include/linux/mmzone.h
> --- linux-2.6.24-rc2-mm1-010_use_two_zonelists/include/linux/mmzone.h	2007-11-20 23:27:04.000000000 +0000
> +++ linux-2.6.24-rc2-mm1-020_zoneid_zonelist/include/linux/mmzone.h	2007-11-20 23:27:34.000000000 +0000
> @@ -469,6 +469,15 @@ struct zonelist_cache;
>  #endif
>  
>  /*
> + * This struct contains information about a zone in a zonelist. It is stored
> + * here to avoid dereferences into large structures and lookups of tables
> + */
> +struct zoneref {
> +	struct zone *zone;	/* Pointer to actual zone */
> +	int zone_idx;		/* zone_idx(zoneref->zone) */
> +};
> +
> +/*
>   * One allocation request operates on a zonelist. A zonelist
>   * is a list of zones, the first one is the 'goal' of the
>   * allocation, the other zones are fallback zones, in decreasing
> @@ -476,11 +485,18 @@ struct zonelist_cache;
>   *
>   * If zlcache_ptr is not NULL, then it is just the address of zlcache,
>   * as explained above.  If zlcache_ptr is NULL, there is no zlcache.
> + * *
> + * To speed the reading of the zonelist, the zonerefs contain the zone index
> + * of the entry being read. Helper functions to access information given
> + * a struct zoneref are
> + *
> + * zonelist_zone()	- Return the struct zone * for an entry in _zonerefs
> + * zonelist_zone_idx()	- Return the index of the zone for an entry
> + * zonelist_node_idx()	- Return the index of the node for an entry
>   */
> -
>  struct zonelist {
>  	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
> -	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
> +	struct zoneref _zonerefs[MAX_ZONES_PER_ZONELIST + 1];
>  #ifdef CONFIG_NUMA
>  	struct zonelist_cache zlcache;			     // optional ...
>  #endif
> @@ -713,26 +729,52 @@ extern struct zone *next_zone(struct zon
>  	     zone;					\
>  	     zone = next_zone(zone))
>  
> +static inline struct zone *zonelist_zone(struct zoneref *zoneref)
> +{
> +	return zoneref->zone;
> +}
> +
> +static inline int zonelist_zone_idx(struct zoneref *zoneref)
> +{
> +	return zoneref->zone_idx;
> +}
> +
> +static inline int zonelist_node_idx(struct zoneref *zoneref)
> +{
> +#ifdef CONFIG_NUMA
> +	/* zone_to_nid not available in this context */
> +	return zoneref->zone->node;
> +#else
> +	return 0;
> +#endif /* CONFIG_NUMA */
> +}
> +
> +static inline void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
> +{
> +	zoneref->zone = zone;
> +	zoneref->zone_idx = zone_idx(zone);
> +}
> +
>  /* Returns the first zone at or below highest_zoneidx in a zonelist */
> -static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
> +static inline struct zoneref *first_zones_zonelist(struct zonelist *zonelist,
>  					enum zone_type highest_zoneidx)
>  {
> -	struct zone **z;
> +	struct zoneref *z;
>  
>  	/* Find the first suitable zone to use for the allocation */
> -	z = zonelist->zones;
> -	while (*z && zone_idx(*z) > highest_zoneidx)
> +	z = zonelist->_zonerefs;
> +	while (zonelist_zone_idx(z) > highest_zoneidx)
!!! HERE:                             ^
>  		z++;
>  
>  	return z;
>  }
>  
>  /* Returns the next zone at or below highest_zoneidx in a zonelist */
> -static inline struct zone **next_zones_zonelist(struct zone **z,
> +static inline struct zoneref *next_zones_zonelist(struct zoneref *z,
>  					enum zone_type highest_zoneidx)
>  {
>  	/* Find the next suitable zone to use for the allocation */
> -	while (*z && zone_idx(*z) > highest_zoneidx)
> +	while (zonelist_zone_idx(z) > highest_zoneidx)
!!! and HERE:                         ^
>  		z++;
>  
>  	return z;
> @@ -748,9 +790,11 @@ static inline struct zone **next_zones_z
>   * This iterator iterates though all zones at or below a given zone index.
>   */
>  #define for_each_zone_zonelist(zone, z, zlist, highidx) \
> -	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
> +	for (z = first_zones_zonelist(zlist, highidx),			\
> +					zone = zonelist_zone(z++);	\
>  		zone;							\
> -		z = next_zones_zonelist(z, highidx), zone = *z++)
> +		z = next_zones_zonelist(z, highidx),			\
> +					zone = zonelist_zone(z++))
>  
>  #ifdef CONFIG_SPARSEMEM
>  #include <asm/sparsemem.h>
<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
