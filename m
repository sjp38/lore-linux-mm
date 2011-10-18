Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 048BC6B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 09:48:40 -0400 (EDT)
Date: Tue, 18 Oct 2011 08:48:35 -0500
From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Reduce vm_stat cacheline contention in
 __vm_enough_memory
Message-ID: <20111018134835.GA16222@sgi.com>
References: <20111013135032.7c2c54cd.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1110131602020.26553@router.home>
 <20111013142434.4d05cbdc.akpm@linux-foundation.org>
 <20111014122506.GB26737@sgi.com>
 <20111014135055.GA28592@sgi.com>
 <alpine.DEB.2.00.1110140856420.6411@router.home>
 <20111014141921.GC28592@sgi.com>
 <alpine.DEB.2.00.1110140932530.6411@router.home>
 <alpine.DEB.2.00.1110140958550.6411@router.home>
 <20111014161603.GA30561@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111014161603.GA30561@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Fri, Oct 14, 2011 at 11:16:03AM -0500, Dimitri Sivanich wrote:
> On Fri, Oct 14, 2011 at 10:18:24AM -0500, Christoph Lameter wrote:
> > Also the whole thing could be optimized by concentrating updates to the
> > vm_stat array at one point in time. If any local per cpu differential
> > overflows then update all the counters in the same cacheline for which we have per cpu
> > differentials.
> > 
> > That will defer another acquisition of the cacheline for the next delta
> > overflowing. After an update all the per cpu differentials would be zero.
> > 
> > This could be added to zone_page_state_add....
> > 
> > 
> > Something like this patch? (Restriction of the updates to the same
> > cacheline missing. Just does everything and the zone_page_state may need
> > uninlining now)
> 
> This patch doesn't have much, if any, effect, at least in the 46 writer thread
> case (NR_VM_EVENT_ITEMS-->NR_VM_ZONE_STAT_ITEMS allowed it to boot :) ).
> I applied this with the change to align vm_stat.
> 
> So far cache alignment of vm_data and increasing ZVC delta has the greatest
> effect.

After further testing, substantial increases in ZVC delta along with cache alignment
of the vm_stat array bring the tmpfs writeback throughput numbers to about where
they are with vm.overcommit_memory==OVERCOMMIT_NEVER.  I still need to determine how
high the ZVC delta needs to be to achieve this performance, but it is greater than 125.

Would it make sense to have the ZVC delta be tuneable (via /proc/sys/vm?), keeping the
same default behavior as what we currently have?

If the thresholds get set higher, it could be that some values that don't normally have
as big a delta may not get updated frequently enough.  Should we maybe update all values
everytime a threshold is hit, as the patch below was intending?

Note that having each counter in a separate cacheline does not have much, if any,
effect.

> 
> > 
> > ---
> >  include/linux/vmstat.h |   19 ++++++++++++++++---
> >  mm/vmstat.c            |   10 ++++------
> >  2 files changed, 20 insertions(+), 9 deletions(-)
> > 
> > Index: linux-2.6/include/linux/vmstat.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/vmstat.h	2011-10-14 09:58:03.000000000 -0500
> > +++ linux-2.6/include/linux/vmstat.h	2011-10-14 10:08:00.000000000 -0500
> > @@ -90,10 +90,23 @@ static inline void vm_events_fold_cpu(in
> >  extern atomic_long_t vm_stat[NR_VM_ZONE_STAT_ITEMS];
> > 
> >  static inline void zone_page_state_add(long x, struct zone *zone,
> > -				 enum zone_stat_item item)
> > +				 enum zone_stat_item item, s8 new_value)
> >  {
> > -	atomic_long_add(x, &zone->vm_stat[item]);
> > -	atomic_long_add(x, &vm_stat[item]);
> > +	enum zone_stat_item i;
> > +
> > +	for (i = 0; i < NR_VM_EVENT_ITEMS; i++) {
> > +		long y;
> > +
> > +		if (i == item)
> > +			y = this_cpu_xchg(zone->pageset->vm_stat_diff[i], new_value) + x;
> > +		else
> > +			y = this_cpu_xchg(zone->pageset->vm_stat_diff[i], 0);
> > +
> > +		if (y) {
> > +			atomic_long_add(y, &zone->vm_stat[item]);
> > +			atomic_long_add(y, &vm_stat[item]);
> > +		}
> > +	}
> >  }
> > 
> >  static inline unsigned long global_page_state(enum zone_stat_item item)
> > Index: linux-2.6/mm/vmstat.c
> > ===================================================================
> > --- linux-2.6.orig/mm/vmstat.c	2011-10-14 10:04:20.000000000 -0500
> > +++ linux-2.6/mm/vmstat.c	2011-10-14 10:08:39.000000000 -0500
> > @@ -221,7 +221,7 @@ void __mod_zone_page_state(struct zone *
> >  	t = __this_cpu_read(pcp->stat_threshold);
> > 
> >  	if (unlikely(x > t || x < -t)) {
> > -		zone_page_state_add(x, zone, item);
> > +		zone_page_state_add(x, zone, item, 0);
> >  		x = 0;
> >  	}
> >  	__this_cpu_write(*p, x);
> > @@ -262,8 +262,7 @@ void __inc_zone_state(struct zone *zone,
> >  	if (unlikely(v > t)) {
> >  		s8 overstep = t >> 1;
> > 
> > -		zone_page_state_add(v + overstep, zone, item);
> > -		__this_cpu_write(*p, -overstep);
> > +		zone_page_state_add(v + overstep, zone, item, -overstep);
> >  	}
> >  }
> > 
> > @@ -284,8 +283,7 @@ void __dec_zone_state(struct zone *zone,
> >  	if (unlikely(v < - t)) {
> >  		s8 overstep = t >> 1;
> > 
> > -		zone_page_state_add(v - overstep, zone, item);
> > -		__this_cpu_write(*p, overstep);
> > +		zone_page_state_add(v - overstep, zone, item, overstep);
> >  	}
> >  }
> > 
> > @@ -343,7 +341,7 @@ static inline void mod_state(struct zone
> >  	} while (this_cpu_cmpxchg(*p, o, n) != o);
> > 
> >  	if (z)
> > -		zone_page_state_add(z, zone, item);
> > +		zone_page_state_add(z, zone, item, 0);
> >  }
> > 
> >  void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
