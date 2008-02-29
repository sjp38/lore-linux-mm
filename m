Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080229145030.GD6045@csn.ul.ie>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
	 <20080229145030.GD6045@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 29 Feb 2008 10:48:14 -0500
Message-Id: <1204300094.5311.50.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-29 at 14:50 +0000, Mel Gorman wrote:
> On (28/02/08 13:32), Andrew Morton didst pronounce:
> > On Wed, 27 Feb 2008 16:47:34 -0500
> > Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> > 
> > > +/* Returns the first zone at or below highest_zoneidx in a zonelist */
> > > +static inline struct zone **first_zones_zonelist(struct zonelist *zonelist,
> > > +					enum zone_type highest_zoneidx)
> > > +{
> > > +	struct zone **z;
> > > +
> > > +	/* Find the first suitable zone to use for the allocation */
> > > +	z = zonelist->zones;
> > > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > > +		z++;
> > > +
> > > +	return z;
> > > +}
> > > +
> > > +/* Returns the next zone at or below highest_zoneidx in a zonelist */
> > > +static inline struct zone **next_zones_zonelist(struct zone **z,
> > > +					enum zone_type highest_zoneidx)
> > > +{
> > > +	/* Find the next suitable zone to use for the allocation */
> > > +	while (*z && zone_idx(*z) > highest_zoneidx)
> > > +		z++;
> > > +
> > > +	return z;
> > > +}
> > > +
> > > +/**
> > > + * for_each_zone_zonelist - helper macro to iterate over valid zones in a zonelist at or below a given zone index
> > > + * @zone - The current zone in the iterator
> > > + * @z - The current pointer within zonelist->zones being iterated
> > > + * @zlist - The zonelist being iterated
> > > + * @highidx - The zone index of the highest zone to return
> > > + *
> > > + * This iterator iterates though all zones at or below a given zone index.
> > > + */
> > > +#define for_each_zone_zonelist(zone, z, zlist, highidx) \
> > > +	for (z = first_zones_zonelist(zlist, highidx), zone = *z++;	\
> > > +		zone;							\
> > > +		z = next_zones_zonelist(z, highidx), zone = *z++)
> > > +
> > 
> > omygawd will that thing generate a lot of code!
> > 
> > It has four call sites in mm/oom_kill.c and the overall patchset increases
> > mm/oom_kill.o's text section (x86_64 allmodconfig) from 3268 bytes to 3845.
> > 
> 
> Yeah... that's pretty bad. They were inlined to avoid function call overhead
> when trying to avoid any additional performance overhead but the text overhead
> is not helping either. I'll start looking at things to uninline and see what
> can be gained text-reduction wise without mucking performance.
> 
> > vmscan.o and page_alloc.o also grew a lot.  otoh total vmlinux bloat from
> > the patchset is only around 700 bytes, so I expect that with a little less
> > insanity we could actually get an aggregate improvement here.

Mel:

Thinking about this:

for_each_zone_zonelist():

Seems like the call sites to this macro are not hot paths, so maybe
these can call out to a zonelist iterator func in page_alloc.c or, as
Kame-san suggested, mmzone.c.

+ oom_kill and vmscan call sites:  if these are hot, we're already in,
uh..., slow mode. 

+ usage in slab.c and slub.c appears to be the fallback/slow path.
Christoph can chime in, here, if he disagrees.

+ in page_alloc.c:  waking up of kswapd and counting free zone pages
[mostly for init code] don't appear to be fast paths.  

+ The call site in hugetlb.c is in the huge-page allocation path, which
is under a global spinlock.  So, any slowdown here could result in
longer lock hold time and higher contention.  But, I have to believe
that in the grand scheme of things, huge-page allocation is not that
hot.  [Someone faulting in terabytes of hugepages might contest that.]

That leaves the call to for_each_zone_zonelist_nodemask() in
get_page_from_freelist().  This might be deserving of inlining?

If this works out, we could end up with these macros being inlined in
only 2 places:  get_page_from_freelist() and a to-be-designed zonelist
iterator function.  [In fact, I believe that such an iterator need not
expose the details of zonelists outside of page_alloc/mmzone, but that
would require more rework of the call sites, and additional helper
functions.  Maybe someday...]

Comments?

Right now, I've got to build/test the latest reclaim scalability patches
that Rik posted, and clean up the issues already pointed out.  If you
don't get to this, I can look at it further next week.

Lee

> > 
> > Some of the inlining in mmzone.h is just comical.  Some of it is obvious
> > (first_zones_zonelist) and some of it is less obvious (pfn_present).
> > 
> > I applied these for testing but I really don't think we should be merging
> > such easily-fixed regressions into mainline.  Could someone please take a
> > look at de-porking core MM?
> > 
> > 
> > Also, I switched all your Tested-by:s to Signed-off-by:s.  You were on the
> > delivery path, so s-o-b is the appropriate tag.  I would like to believe
> > that Signed-off-by: implies Tested-by: anyway (rofl).
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
