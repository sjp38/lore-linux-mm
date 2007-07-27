Date: Fri, 27 Jul 2007 18:46:22 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070727174622.GD646@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com> <20070726225920.GA10225@skynet.ie> <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com> <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie> <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (27/07/07 10:35), Christoph Lameter didst pronounce:
> On Fri, 27 Jul 2007, Mel Gorman wrote:
> 
> > This was fairly straight-forward but I wouldn't call it a bug fix for 2.6.23
> > for the policys + ZONE_MOVABLE issue; I still prefer the last patch for
> > the fix.
> > 
> > This patch uses one zonelist per node and filters based on a gfp_mask where
> > necessary. It consumes less memory and reduces cache pressure at the cost
> > of CPU. It also adds a zone_id field to struct zone as zone_idx is used more
> > than it was previously.
> > 
> > Performance differences on kernbench for Total CPU time ranged from
> > -0.06% to +1.19%.
> 
> Performance is equal otherwise?
>  

Initial tests imply yes but I haven't done broader tests yet. It saves 64
bytes on the size of the node structure on a non-numa i386 machine so even
that might be noticable in some cases.

> > Obvious things that are outstanding;
> > 
> > o Compile-test parisc
> > o Split patch in two to keep the zone_idx changes separetly
> > o Verify zlccache is not broken
> > o Have a version of __alloc_pages take a nodemask and ditch
> >   bind_zonelist()
> 
> Yeah. I think the NUMA folks would love this but the rest of the 
> developers may object.
> 
> > I can work on bringing this up to scratch during the cycle.
> > 
> > Patch as follows. Comments?
> 
> Glad to see some movement in this area. 
> 
> > index bc68dd9..f2a597e 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -116,6 +116,13 @@ static inline enum zone_type gfp_zone(gfp_t flags)
> >  	return ZONE_NORMAL;
> >  }
> >  
> > +static inline int should_filter_zone(struct zone *zone, int highest_zoneidx)
> > +{
> > +	if (zone_idx(zone) > highest_zoneidx)
> > +		return 1;
> > +	return 0;
> > +}
> > +
> 
> I think this should_filter() creates more overhead than which it saves.

It's why part of the patch adds a zone_idx field to struct zone instead
of mucking around with pgdat->node_zones.

> In 
> particular true for configurations with a small number of zones like SMP 
> systems. For large NUMA systems the cache savings will likely may it 
> beneficial.
> 
> Simply filter all.
> 

What do you mean by simply filter all? The should_filter_zone() is
returning 1 if the zone should not be used for the current gfp_mask. It
would be easier to read (but slower) if it was expressed as

if (zone_idx(zone) > gfp_zone(gfp_mask))
	return 1;

so that zones unsuitable for gfp_mask are ignored.

> > @@ -258,7 +258,7 @@ static inline void mpol_fix_fork_child_flag(struct task_struct *p)
> >  static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
> >  		unsigned long addr, gfp_t gfp_flags)
> >  {
> > -	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
> > +	return &NODE_DATA(0)->node_zonelist;
> >  }
> 
> These modifications look good in terrms of code size reduction.
> 

720 bytes less in the size of the text section for a standalone non-numa
machine.

> > @@ -438,7 +439,7 @@ extern struct page *mem_map;
> >  struct bootmem_data;
> >  typedef struct pglist_data {
> >  	struct zone node_zones[MAX_NR_ZONES];
> > -	struct zonelist node_zonelists[MAX_NR_ZONES];
> > +	struct zonelist node_zonelist;
> 
> Looks like a significant memory savings on 1024 node numa. zonelist has
> #define MAX_ZONES_PER_ZONELIST (MAX_NUMNODES * MAX_NR_ZONES)
> zones.
> 

I'll gather figures.

> > @@ -185,11 +186,15 @@ static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
> >  		if (NODE_DATA(node)->node_present_pages)
> >  			node_set(node, nodes);
> >  
> > -	for (z = zonelist->zones; *z; z++)
> > +	for (z = zonelist->zones; *z; z++) {
> > +
> > +		if (should_filter_zone(*z, highest_zoneidx))
> > +			continue;
> 
> Huh? Why do you need it here? Note that this code is also going away with 
> the memoryless node patch. We can use the nodes with memory nodemask here.
> 

This function expects to walk a zonelist suitable for the gfp_mask. As
the zonelists it gets has potentially unsuitable zones in it, it must be
filtered as well so that it is functionally identical.

> > diff --git a/mm/slub.c b/mm/slub.c
> > index 9b2d617..a020a12 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1276,6 +1276,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
> >  	struct zonelist *zonelist;
> >  	struct zone **z;
> >  	struct page *page;
> > +	enum zone_type highest_zoneidx = gfp_zone(flags);
> >  
> >  	/*
> >  	 * The defrag ratio allows a configuration of the tradeoffs between
> > @@ -1298,11 +1299,13 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
> >  	if (!s->defrag_ratio || get_cycles() % 1024 > s->defrag_ratio)
> >  		return NULL;
> >  
> > -	zonelist = &NODE_DATA(slab_node(current->mempolicy))
> > -					->node_zonelists[gfp_zone(flags)];
> > +	zonelist = &NODE_DATA(slab_node(current->mempolicy))->node_zonelist;
> >  	for (z = zonelist->zones; *z; z++) {
> >  		struct kmem_cache_node *n;
> >  
> > +		if (should_filter_zone(*z, highest_zoneidx))
> > +			continue;
> > +
> >  		n = get_node(s, zone_to_nid(*z));
> >  
> >  		if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
> 
> Isnt there some way to fold these traversals into a common page allocator 
> function?

Probably. When I looked first, each of the users were traversing the zonelist
slightly differently so it wasn't obvious how to have a single iterator but
it's a point for improvement.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
