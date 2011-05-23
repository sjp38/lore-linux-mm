Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EA51E6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:35:44 -0400 (EDT)
Date: Mon, 23 May 2011 18:35:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-ID: <20110523173535.GZ5279@suse.de>
References: <20110520153346.GA1843@barrios-desktop>
 <BANLkTi=X+=Wh1MLs7Fc-v-OMtxAHbcPmxA@mail.gmail.com>
 <20110520161934.GA2386@barrios-desktop>
 <BANLkTi=4C5YAxwAFWC6dsAPMR3xv6LP1hw@mail.gmail.com>
 <BANLkTimThVw7-PN6ypBBarqXJa1xxYA_Ow@mail.gmail.com>
 <BANLkTint+Qs+cO+wKUJGytnVY3X1bp+8rQ@mail.gmail.com>
 <BANLkTinx+oPJFQye7T+RMMGzg9E7m28A=Q@mail.gmail.com>
 <BANLkTik29nkn-DN9ui6XV4sy5Wo2jmeS9w@mail.gmail.com>
 <BANLkTikQd34QZnQVSn_9f_Mxc8wtJMHY0w@mail.gmail.com>
 <20110523164225.GA14734@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110523164225.GA14734@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@redhat.com

On Mon, May 23, 2011 at 06:42:25PM +0200, Andrea Arcangeli wrote:
> On Mon, May 23, 2011 at 08:12:50AM +0900, Minchan Kim wrote:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 292582c..1663d24 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -231,8 +231,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >        if (scanned == 0)
> >                scanned = SWAP_CLUSTER_MAX;
> > 
> > -       if (!down_read_trylock(&shrinker_rwsem))
> > -               return 1;       /* Assume we'll be able to shrink next time */
> > +       if (!down_read_trylock(&shrinker_rwsem)) {
> > +               /* Assume we'll be able to shrink next time */
> > +               ret = 1;
> > +               goto out;
> > +       }
> 
> It looks cleaner to return -1 here to differentiate the failure in
> taking the lock from when we take the lock and just 1 object is
> freed. Callers seems to be ok with -1 already and more intuitive for
> the while (nr > 10) loops too (those loops could be changed to "while
> (nr > 0)" if all shrinkers are accurate and not doing something
> inaccurate like the above code did, the shrinkers retvals I didn't
> check yet).
> 

Only one caller reads the value of shrink_slab() and while it would
survive -1 being returned, it gains nothing. I don't see it as being
much clearer than the existing return value of 1.

> >        up_read(&shrinker_rwsem);
> > +out:
> > +       cond_resched();
> >        return ret;
> >  }
> 
> If we enter the loop some of the shrinkers will reschedule but it
> looks good for the last iteration that may have still run for some
> time before returning.

Yes.

> The actual failure of shrinker_rwsem seems only
> theoretical though (but ok to cover it too with the cond_resched, but
> in practice this should be more for the case where shrinker_rwsem
> doesn't fail).
> 

Profiles from some users imply that this condition is being hit. I
can't 100% prove it as I can't reproduce the problem locally
(seems to require a sandybridge laptop for some reason). Tests did
show that kswapd CPU usage was reduced as well as the liklihood
of hanging when shrink_slab used cond_resched() like this. See
https://lkml.org/lkml/2011/5/17/274 .

> > @@ -2331,7 +2336,7 @@ static bool sleeping_prematurely(pg_data_t
> > *pgdat, int order, long remaining,
> >         * must be balanced
> >         */
> >        if (order)
> > -               return pgdat_balanced(pgdat, balanced, classzone_idx);
> > +               return !pgdat_balanced(pgdat, balanced, classzone_idx);
> >        else
> >                return !all_zones_ok;
> >  }
> 
> I now wonder if this is why compaction in kswapd didn't work out well
> and kswapd would spin at 100% load so much when compaction was added,

It's possible.

> plus with kswapd-compaction patch I think this code should be changed
> to:
> 
>  if (!COMPACTION_BUILD && order)
>   return !pgdat_balanced();
>  else
>   return !all_zones_ok;
> 
> (but only with kswapd-compaction)
> 

Why? kswapd can enter lumpy reclaim when !COMPACTION_BUILD. While this
is hardly desirable, I don't see why kswapd should use different logic
for balancing depending on whether compaction is used or not.

> I should probably give kswapd-compaction another spin after fixing
> this, because with compaction kswapd should be super successful at
> satisfying zone_watermark_ok_safe(zone, _order_...) in the
> sleeping_prematurely high watermark check, leading to pgdat_balanced
> returning true most of the time (which would make kswapd go crazy spin
> instead of stopping as it was supposed to). Mel, do you also think
> it's worth another try with a fixed sleeping_prematurely like above?
> 

It's worth a try anyway although I think it's more important to figure
out if all_unreclaimable is being improperly set or not.

> Another thing, I'm not excited of the schedule_timeout(HZ/10) in
> kswapd_try_to_sleep(), it seems all for the statistics.

It's to catch where kswapd balances a zone but continual allocations put
the zone under the high watermark quickly. It's to keep kswapd awake to
reduce the likelihood that processes get hit the min watermark and
stall.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
