Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id B22FB6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 09:26:31 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so2978362wes.25
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 06:26:31 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id gc3si8898074wib.74.2014.07.17.06.26.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 06:26:17 -0700 (PDT)
Date: Thu, 17 Jul 2014 09:26:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: vmscan: clean up struct scan_control
Message-ID: <20140717132604.GF29639@cmpxchg.org>
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org>
 <1405344049-19868-4-git-send-email-hannes@cmpxchg.org>
 <alpine.LSU.2.11.1407141240200.17669@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1407141240200.17669@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 14, 2014 at 12:46:21PM -0700, Hugh Dickins wrote:
> On Mon, 14 Jul 2014, Johannes Weiner wrote:
> 
> > Reorder the members by input and output, then turn the individual
> > integers for may_writepage, may_unmap, may_swap, compaction_ready,
> > hibernation_mode into flags that fit into a single integer.
> > 
> > Stack delta: +72/-296 -224                   old     new   delta
> > kswapd                                       104     176     +72
> > try_to_free_pages                             80      56     -24
> > try_to_free_mem_cgroup_pages                  80      56     -24
> > shrink_all_memory                             88      64     -24
> > reclaim_clean_pages_from_list                168     144     -24
> > mem_cgroup_shrink_node_zone                  104      80     -24
> > __zone_reclaim                               176     152     -24
> > balance_pgdat                                152       -    -152
> > 
> >    text    data     bss     dec     hex filename
> >   38151    5641      16   43808    ab20 mm/vmscan.o.old
> >   38047    5641      16   43704    aab8 mm/vmscan.o
> > 
> > Suggested-by: Mel Gorman <mgorman@suse.de>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmscan.c | 158 ++++++++++++++++++++++++++++++------------------------------
> >  1 file changed, 78 insertions(+), 80 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c28b8981e56a..73d8e69ff3eb 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -58,36 +58,28 @@
> >  #define CREATE_TRACE_POINTS
> >  #include <trace/events/vmscan.h>
> >  
> > -struct scan_control {
> > -	/* Incremented by the number of inactive pages that were scanned */
> > -	unsigned long nr_scanned;
> > -
> > -	/* Number of pages freed so far during a call to shrink_zones() */
> > -	unsigned long nr_reclaimed;
> > -
> > -	/* One of the zones is ready for compaction */
> > -	int compaction_ready;
> > +/* Scan control flags */
> > +#define MAY_WRITEPAGE		0x1
> > +#define MAY_UNMAP		0x2
> > +#define MAY_SWAP		0x4
> > +#define MAY_SKIP_CONGESTION	0x8
> > +#define COMPACTION_READY	0x10
> >  
> > +struct scan_control {
> >  	/* How many pages shrink_list() should reclaim */
> >  	unsigned long nr_to_reclaim;
> >  
> > -	unsigned long hibernation_mode;
> > -
> >  	/* This context's GFP mask */
> >  	gfp_t gfp_mask;
> >  
> > -	int may_writepage;
> > -
> > -	/* Can mapped pages be reclaimed? */
> > -	int may_unmap;
> > -
> > -	/* Can pages be swapped as part of reclaim? */
> > -	int may_swap;
> > -
> > +	/* Allocation order */
> >  	int order;
> >  
> > -	/* Scan (total_size >> priority) pages at once */
> > -	int priority;
> > +	/*
> > +	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> > +	 * are scanned.
> > +	 */
> > +	nodemask_t	*nodemask;
> >  
> >  	/*
> >  	 * The memory cgroup that hit its limit and as a result is the
> > @@ -95,11 +87,17 @@ struct scan_control {
> >  	 */
> >  	struct mem_cgroup *target_mem_cgroup;
> >  
> > -	/*
> > -	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
> > -	 * are scanned.
> > -	 */
> > -	nodemask_t	*nodemask;
> > +	/* Scan (total_size >> priority) pages at once */
> > +	int priority;
> > +
> > +	/* Scan control flags; see above */
> > +	unsigned int flags;
> 
> This seems to result in a fair amount of unnecessary churn:
> why not just put may_writepage etc into an unsigned int bitfield,
> then you get the saving without changing all the rest of the code.

Good point, I didn't even think of that.  Thanks!

Andrew, could you please replace this patch with the following?

---
