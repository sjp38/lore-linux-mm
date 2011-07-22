Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 76CB16B004A
	for <linux-mm@kvack.org>; Fri, 22 Jul 2011 03:42:36 -0400 (EDT)
Date: Fri, 22 Jul 2011 08:42:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
Message-ID: <20110722074227.GW5349@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
 <1308926697-22475-5-git-send-email-mgorman@suse.de>
 <20110719160903.GA2978@barrios-desktop>
 <20110720104847.GI5349@suse.de>
 <20110721153007.GC1713@barrios-desktop>
 <20110721160706.GS5349@suse.de>
 <20110721163649.GG1713@barrios-desktop>
 <20110721170112.GU5349@suse.de>
 <CAEwNFnB-JQpBctJxCUkO3WiTr7L3BTJfqirBRG8GOMrp79+cbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnB-JQpBctJxCUkO3WiTr7L3BTJfqirBRG8GOMrp79+cbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jul 22, 2011 at 09:21:57AM +0900, Minchan Kim wrote:
> On Fri, Jul 22, 2011 at 2:01 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Fri, Jul 22, 2011 at 01:36:49AM +0900, Minchan Kim wrote:
> >> > > > <SNIP>
> >> > > > @@ -2740,17 +2742,23 @@ static int kswapd(void *p)
> >> > > >       tsk->flags |= PF_MEMALLOC | PF_SWAPWRITE | PF_KSWAPD;
> >> > > >       set_freezable();
> >> > > >
> >> > > > -     order = 0;
> >> > > > -     classzone_idx = MAX_NR_ZONES - 1;
> >> > > > +     order = new_order = 0;
> >> > > > +     classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
> >> > > >       for ( ; ; ) {
> >> > > > -             unsigned long new_order;
> >> > > > -             int new_classzone_idx;
> >> > > >               int ret;
> >> > > >
> >> > > > -             new_order = pgdat->kswapd_max_order;
> >> > > > -             new_classzone_idx = pgdat->classzone_idx;
> >> > > > -             pgdat->kswapd_max_order = 0;
> >> > > > -             pgdat->classzone_idx = MAX_NR_ZONES - 1;
> >> > > > +             /*
> >> > > > +              * If the last balance_pgdat was unsuccessful it's unlikely a
> >> > > > +              * new request of a similar or harder type will succeed soon
> >> > > > +              * so consider going to sleep on the basis we reclaimed at
> >> > > > +              */
> >> > > > +             if (classzone_idx >= new_classzone_idx && order == new_order) {
> >> > > > +                     new_order = pgdat->kswapd_max_order;
> >> > > > +                     new_classzone_idx = pgdat->classzone_idx;
> >> > > > +                     pgdat->kswapd_max_order =  0;
> >> > > > +                     pgdat->classzone_idx = pgdat->nr_zones - 1;
> >> > > > +             }
> >> > > > +
> >> > >
> >> > > But in this part.
> >> > > Why do we need this?
> >> >
> >> > Lets say it's a fork-heavy workload and it is routinely being woken
> >> > for order-1 allocations and the highest zone is very small. For the
> >> > most part, it's ok because the allocations are being satisfied from
> >> > the lower zones which kswapd has no problem balancing.
> >> >
> >> > However, by reading the information even after failing to
> >> > balance, kswapd continues balancing for order-1 due to reading
> >> > pgdat->kswapd_max_order, each time failing for the highest zone. It
> >> > only takes one wakeup request per balance_pgdat() to keep kswapd
> >> > awake trying to balance the highest zone in a continual loop.
> >>
> >> You made balace_pgdat's classzone_idx as communicated back so classzone_idx returned
> >> would be not high zone and in [1/4], you changed that sleeping_prematurely consider only
> >> classzone_idx not nr_zones. So I think it should sleep if low zones is balanced.
> >>
> >
> > If a wakeup for order-1 happened during the last pgdat, the
> > classzone_idx as communicated back from balance_pgdat() is lost and it
> > will not sleep in this ordering of events
> >
> > kswapd                                                                  other processes
> > ======                                                                  ===============
> > order = balance_pgdat(pgdat, order, &classzone_idx);
> >                                                                        wakeup for order-1
> > kswapd balances lower zone
> >                                                                        allocate from lower zone
> > balance_pgdat fails balance for highest zone, returns
> >        with lower classzone_idx and possibly lower order
> > new_order = pgdat->kswapd_max_order      (order == 1)
> > new_classzone_idx = pgdat->classzone_idx (highest zone)
> > if (order < new_order || classzone_idx > new_classzone_idx) {
> >        order = new_order;
> >        classzone_idx = new_classzone_idx; (failure from balance_pgdat() lost)
> > }
> > order = balance_pgdat(pgdat, order, &classzone_idx);
> >
> > The wakup for order-1 at any point during balance_pgdat() is enough to
> > keep kswapd awake even though the process that called wakeup_kswapd
> > would be able to allocate from the lower zones without significant
> > difficulty.
> >
> > This is why if balance_pgdat() fails its request, it should go to sleep
> > if watermarks for the lower zones are met until woken by another
> > process.
> 
> Hmm.
> 
> The role of kswapd is to reclaim pages by background until all of zone
> meet HIGH_WMARK to prevent costly direct reclaim.(Of course, there is
> another reason like GFP_ATOMIC).

kswapd does not necessarily have to balance every zone to prevent direct
reclaim. Again, if the highest zone is small, it does not remain
balanced for very long because it's often the first choice for
allocating from. It gets used very quickly but direct reclaim does not
stall because there are the lower zones.

> So it's not wrong to consume many cpu
> usage by design unless other tasks are ready.

It wastes power while not making the system run any faster. It will
look odd to any user or administrator that is running top and generates
bug reports.

> It would be balanced or
> unreclaimable at last so it should end up. However, the problem is
> small part of highest zone is easily [set|reset] to be
> all_unreclaimabe so the situation could be forever like our example.
> So fundamental solution is to prevent it that all_unreclaimable is
> set/reset easily, I think.
> Unfortunately it have no idea now.

One way would be to have the allocator skip over it easily and
implement a placement policy that relocates only long-lived and very
old pages to the highest zone and then leave them there and have
kswapd ignore the zone. We don't have anything like this at the moment.

> In different viewpoint,  the problem is that it's too excessive
> because kswapd is just best-effort and if it got fails, we have next
> wakeup and even direct reclaim as last resort. In such POV, I think
> this patch is right and it would be a good solution. Then, other
> concern is on your reply about KOSAKI's question.
> 
> I think below your patch is needed.
> 
> Quote from
> "
> 1. Read for balance-request-A (order, classzone) pair
> 2. Fail balance_pgdat
> 3. Sleep based on (order, classzone) pair
> 4. Wake for balance-request-B (order, classzone) pair where
>   balance-request-B != balance-request-A
> 5. Succeed balance_pgdat
> 6. Compare order,classzone with balance-request-A which will treat
>   balance_pgdat() as fail and try go to sleep
> 
> This is not the same as new_classzone_idx being "garbage" but is it
> what you mean? If so, is this your proposed fix?
> 

That was the proposed fix but discussion died. I'll pick it up again
later and am keeping an eye out for any bugs that could be attributed to
it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
