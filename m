Received: by ug-out-1314.google.com with SMTP id s2so153778uge
        for <linux-mm@kvack.org>; Wed, 16 May 2007 12:59:39 -0700 (PDT)
Message-ID: <29495f1d0705161259p70a1e499tb831889fd2bcebcb@mail.gmail.com>
Date: Wed, 16 May 2007 12:59:38 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH] Fix hugetlb pool allocation with empty nodes - V2 -> V3
In-Reply-To: <1178728661.5047.64.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070503022107.GA13592@kryten>
	 <1178310543.5236.43.camel@localhost>
	 <Pine.LNX.4.64.0705041425450.25764@schroedinger.engr.sgi.com>
	 <1178728661.5047.64.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org, ak@suse.de, mel@csn.ul.ie, apw@shadowen.org, Andrew Morton <akpm@linux-foundation.org>, Eric Whitney <eric.whitney@hp.com>, andyw@uk.ibm.com
List-ID: <linux-mm.kvack.org>

On 5/9/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Fri, 2007-05-04 at 14:27 -0700, Christoph Lameter wrote:
> > On Fri, 4 May 2007, Lee Schermerhorn wrote:
> >
> > > On Wed, 2007-05-02 at 21:21 -0500, Anton Blanchard wrote:
> > > > An interesting bug was pointed out to me where we failed to allocate
> > > > hugepages evenly. In the example below node 7 has no memory (it only has
> > > > CPUs). Node 0 and 1 have plenty of free memory. After doing:
> > >
> > > Here's my attempt to fix the problem [I see it on HP platforms as well],
> > > without removing the population check in build_zonelists_node().  Seems
> > > to work.
> >
> > I think we need something like for_each_online_node for each node with
> > memory otherwise we are going to replicate this all over the place for
> > memoryless nodes. Add a nodemap for populated nodes?
> >
> > I.e.
> >
> > for_each_mem_node?
> >
> > Then you do not have to check the zone flags all the time. May avoid a lot
> > of mess?
>
> OK, here's a rework that exports a node_populated_map and associated
> access functions from page_alloc.c where we already check for populated
> zones.  Maybe this should be "node_hugepages_map" ?
>
> Also, we might consider exporting this to user space for applications
> that want to "interleave across all nodes with hugepages"--not that
> hugetlbfs mappings currently obey "vma policy".  Could still be used
> with the "set task policy before allocating region" method [not that I
> advocate this method ;-)].
>
> I don't think that a 'for_each_*_node()' macro is appropriate for this
> usage, as allocate_fresh_huge_page() is an "incremental allocator" that
> returns a page from the "next eligible node" on each call.
>
> By the way:  does anything protect the "static int nid" in
> allocate_fresh_huge_page() from racing attempts to set nr_hugepages?
> Can this happen?  Do we care?
>
> Again, I chose to rework Anton's original patch, maintaining his
> rationale/discussion, rather create a separate patch.  Note the "Rework"
> comments therein--especially regarding NORMAL zone.  I expect we'll need
> a few more rounds of "discussion" on this issue.  And, it'll require
> rework to merge with the "change zonelist order" series that hits the
> same area.
>
> Lee
>
> [PATCH] Fix hugetlb pool allocation with empty nodes - V3

<snip>

===================================================================
> --- Linux.orig/mm/page_alloc.c  2007-05-08 11:47:45.000000000 -0400
> +++ Linux/mm/page_alloc.c       2007-05-09 11:16:27.000000000 -0400

<snip>

> @@ -2021,11 +2024,14 @@ void show_free_areas(void)
>   * Builds allocation fallback zone lists.
>   *
>   * Add all populated zones of a node to the zonelist.
> + * Record nodes with populated gfp_zone(GFP_HIGHUSER) for huge page allocation.
>   */
>  static int __meminit build_zonelists_node(pg_data_t *pgdat,
> -                       struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
> +                       struct zonelist *zonelist, int nr_zones,
> +                       enum zone_type zone_type)
>  {
>         struct zone *zone;
> +       enum zone_type zone_highuser = gfp_zone(GFP_HIGHUSER);
>
>         BUG_ON(zone_type >= MAX_NR_ZONES);
>         zone_type++;
> @@ -2036,7 +2042,10 @@ static int __meminit build_zonelists_nod
>                 if (populated_zone(zone)) {
>                         zonelist->zones[nr_zones++] = zone;
>                         check_highest_zone(zone_type);
> -               }
> +                       if (zone_type == zone_highuser)
> +                               node_set_populated(pgdat->node_id);
> +               } else if (zone_type == zone_highuser)
> +                       node_not_populated(pgdat->node_id);
>
>         } while (zone_type);
>         return nr_zones;

This completely breaks hugepage allocation on 4-node x86_64 box I have
here. Each node has <4GB of memory, so all memory is ZONE_DMA and
ZONE_DMA32. gfp_zone(GFP_HIGHUSER) is ZONE_NORMAL, though. So all
nodes are not populated by the default initialization to an empty
nodemask.

Thanks to Andy Whitcroft for helping me debug this.

I'm not sure how to fix this -- but I ran into while trying to base my
sysfs hugepage allocation patches on top of yours.

Thoughts?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
