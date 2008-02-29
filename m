Date: Fri, 29 Feb 2008 14:50:30 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
Message-ID: <20080229145030.GD6045@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost> <20080227214734.6858.9968.sendpatchset@localhost> <20080228133247.6a7b626f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080228133247.6a7b626f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On (28/02/08 13:32), Andrew Morton didst pronounce:
> On Wed, 27 Feb 2008 16:47:34 -0500
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > +/* Returns the first zone at or below highest_zoneidx in a zonelist */
> > +static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
> > +					enum zone_type highest_zoneidx)
> > +{
> > +	struct zone **z;
> > +
> > +	/* Find the first suitable zone to use for the allocation */
> > +	z = zonelist->zones;
> > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > +		z++;
> > +
> > +	return z;
> > +}
> > +
> > +/* Returns the next zone at or below highest_zoneidx in a zonelist */
> > +static inline struct zone **next_zones_zonelist(struct zone **z,
> > +					enum zone_type highest_zoneidx)
> > +{
> > +	/* Find the next suitable zone to use for the allocation */
> > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > +		z++;
> > +
> > +	return z;
> > +}
> > +
> > +/**
> > + * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
> > + * @zone - The current zone in the iterator
> > + * @z - The current pointer within zonelist->zones being iterated
> > + * @zlist - The zonelist being iterated
> > + * @highidx - The zone index of the highest zone to return
> > + *
> > + * This iterator iterates though all zones at or below a given zone index.
> > + */
> > +#define for_each_zone_zonelist(zone, z, zlist, highidx) \
> > +	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
> > +		zone;							\
> > +		z = next_zones_zonelist(z, highidx), zone = *z++)
> > +
> 
> omygawd will that thing generate a lot of code!
> 
> It has four call sites in mm/oom_kill.c and the overall patchset increases
> mm/oom_kill.o's text section (x86_64 allmodconfig) from 3268 bytes to 3845.
> 

Yeah... that's pretty bad. They were inlined to avoid function call overhead
when trying to avoid any additional performance overhead but the text overhead
is not helping either. I'll start looking at things to uninline and see what
can be gained text-reduction wise without mucking performance.

> vmscan.o and page_alloc.o also grew a lot.  otoh total vmlinux bloat from
> the patchset is only around 700 bytes, so I expect that with a little less
> insanity we could actually get an aggregate improvement here.
> 
> Some of the inlining in mmzone.h is just comical.  Some of it is obvious
> (first_zones_zonelist) and some of it is less obvious (pfn_present).
> 
> I applied these for testing but I really don't think we should be merging
> such easily-fixed regressions into mainline.  Could someone please take a
> look at de-porking core MM?
> 
> 
> Also, I switched all your Tested-by:s to Signed-off-by:s.  You were on the
> delivery path, so s-o-b is the appropriate tag.  I would like to believe
> that Signed-off-by: implies Tested-by: anyway (rofl).
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
