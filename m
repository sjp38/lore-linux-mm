Subject: Re: [PATCH 4/6] Use two zonelist that are filtered by GFP mask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080228133247.6a7b626f.akpm@linux-foundation.org>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 28 Feb 2008 16:53:58 -0500
Message-Id: <1204235638.5301.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 2008-02-28 at 13:32 -0800, Andrew Morton wrote:
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
> vmscan.o and page_alloc.o also grew a lot.  otoh total vmlinux bloat from
> the patchset is only around 700 bytes, so I expect that with a little less
> insanity we could actually get an aggregate improvement here.
> 
> Some of the inlining in mmzone.h is just comical.  Some of it is obvious
> (first_zones_zonelist) and some of it is less obvious (pfn_present).

Yeah, Mel said he was really reaching to avoid performance regression in
this set.   

> 
> I applied these for testing but I really don't think we should be merging
> such easily-fixed regressions into mainline.  Could someone please take a
> look at de-porking core MM?

OK, Mel should be back real soon now, and I'll take a look as well.  At
this point, we just wanted to get some more testing in -mm.

> 
> 
> Also, I switched all your Tested-by:s to Signed-off-by:s.  You were on the
> delivery path, so s-o-b is the appropriate tag.  I would like to believe
> that Signed-off-by: implies Tested-by: anyway (rofl).


Well, this is not the first time I've been tagged with 's-o-b' and
probably not the last :-).

Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
