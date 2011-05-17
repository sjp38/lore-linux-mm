Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A13536B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 06:38:48 -0400 (EDT)
Date: Tue, 17 May 2011 11:38:40 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
Message-ID: <20110517103840.GL5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
 <1305295404-12129-5-git-send-email-mgorman@suse.de>
 <4DCFAA80.7040109@jp.fujitsu.com>
 <1305519711.4806.7.camel@mulgrave.site>
 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
 <20110516084558.GE5279@suse.de>
 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
 <20110516102753.GF5279@suse.de>
 <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue, May 17, 2011 at 08:50:44AM +0900, Minchan Kim wrote:
> On Mon, May 16, 2011 at 7:27 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Mon, May 16, 2011 at 05:58:59PM +0900, Minchan Kim wrote:
> >> On Mon, May 16, 2011 at 5:45 PM, Mel Gorman <mgorman@suse.de> wrote:
> >> > On Mon, May 16, 2011 at 02:04:00PM +0900, Minchan Kim wrote:
> >> >> On Mon, May 16, 2011 at 1:21 PM, James Bottomley
> >> >> <James.Bottomley@hansenpartnership.com> wrote:
> >> >> > On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
> >> >> >> (2011/05/13 23:03), Mel Gorman wrote:
> >> >> >> > Under constant allocation pressure, kswapd can be in the situation where
> >> >> >> > sleeping_prematurely() will always return true even if kswapd has been
> >> >> >> > running a long time. Check if kswapd needs to be scheduled.
> >> >> >> >
> >> >> >> > Signed-off-by: Mel Gorman<mgorman@suse.de>
> >> >> >> > ---
> >> >> >> >   mm/vmscan.c |    4 ++++
> >> >> >> >   1 files changed, 4 insertions(+), 0 deletions(-)
> >> >> >> >
> >> >> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> >> >> > index af24d1e..4d24828 100644
> >> >> >> > --- a/mm/vmscan.c
> >> >> >> > +++ b/mm/vmscan.c
> >> >> >> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
> >> >> >> >     unsigned long balanced = 0;
> >> >> >> >     bool all_zones_ok = true;
> >> >> >> >
> >> >> >> > +   /* If kswapd has been running too long, just sleep */
> >> >> >> > +   if (need_resched())
> >> >> >> > +           return false;
> >> >> >> > +
> >> >> >>
> >> >> >> Hmm... I don't like this patch so much. because this code does
> >> >> >>
> >> >> >> - don't sleep if kswapd got context switch at shrink_inactive_list
> >> >> >
> >> >> > This isn't entirely true:  need_resched() will be false, so we'll follow
> >> >> > the normal path for determining whether to sleep or not, in effect
> >> >> > leaving the current behaviour unchanged.
> >> >> >
> >> >> >> - sleep if kswapd didn't
> >> >> >
> >> >> > This also isn't entirely true: whether need_resched() is true at this
> >> >> > point depends on a whole lot more that whether we did a context switch
> >> >> > in shrink_inactive. It mostly depends on how long we've been running
> >> >> > without giving up the CPU.  Generally that will mean we've been round
> >> >> > the shrinker loop hundreds to thousands of times without sleeping.
> >> >> >
> >> >> >> It seems to be semi random behavior.
> >> >> >
> >> >> > Well, we have to do something.  Chris Mason first suspected the hang was
> >> >> > a kswapd rescheduling problem a while ago.  We tried putting
> >> >> > cond_rescheds() in several places in the vmscan code, but to no avail.
> >> >>
> >> >> Is it a result of  test with patch of Hannes(ie, !pgdat_balanced)?
> >> >>
> >> >> If it isn't, it would be nop regardless of putting cond_reshed at vmscan.c.
> >> >> Because, although we complete zone balancing, kswapd doesn't sleep as
> >> >> pgdat_balance returns wrong result. And at last VM calls
> >> >> balance_pgdat. In this case, balance_pgdat returns without any work as
> >> >> kswap couldn't find zones which have not enough free pages and goto
> >> >> out. kswapd could repeat this work infinitely. So you don't have a
> >> >> chance to call cond_resched.
> >> >>
> >> >> But if your test was with Hanne's patch, I am very curious how come
> >> >> kswapd consumes CPU a lot.
> >> >>
> >> >> > The need_resched() in sleeping_prematurely() seems to be about the best
> >> >> > option.  The other option might be just to put a cond_resched() in
> >> >> > kswapd_try_to_sleep(), but that will really have about the same effect.
> >> >>
> >> >> I don't oppose it but before that, I think we have to know why kswapd
> >> >> consumes CPU a lot although we applied Hannes' patch.
> >> >>
> >> >
> >> > Because it's still possible for processes to allocate pages at the same
> >> > rate kswapd is freeing them leading to a situation where kswapd does not
> >> > consider the zone balanced for prolonged periods of time.
> >>
> >> We have cond_resched in shrink_page_list, shrink_slab and balance_pgdat.
> >> So I think kswapd can be scheduled out although it's scheduled in
> >> after a short time as task scheduled also need page reclaim. Although
> >> all task in system need reclaim, kswapd cpu 99% consumption is a
> >> natural result, I think.
> >> Do I miss something?
> >>
> >
> > Lets see;
> >
> > shrink_page_list() only applies if inactive pages were isolated
> >        which in turn may not happen if all_unreclaimable is set in
> >        shrink_zones(). If for whatver reason, all_unreclaimable is
> >        set on all zones, we can miss calling cond_resched().
> >
> > shrink_slab only applies if we are reclaiming slab pages. If the first
> >        shrinker returns -1, we do not call cond_resched(). If that
> >        first shrinker is dcache and __GFP_FS is not set, direct
> >        reclaimers will not shrink at all. However, if there are
> >        enough of them running or if one of the other shrinkers
> >        is running for a very long time, kswapd could be starved
> >        acquiring the shrinker_rwsem and never reaching the
> >        cond_resched().
> 
> Don't we have to move cond_resched?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 292582c..633e761 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -231,8 +231,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>         if (scanned == 0)
>                 scanned = SWAP_CLUSTER_MAX;
> 
> -       if (!down_read_trylock(&shrinker_rwsem))
> -               return 1;       /* Assume we'll be able to shrink next time */
> +       if (!down_read_trylock(&shrinker_rwsem)) {
> +               ret = 1;
> +               goto out; /* Assume we'll be able to shrink next time */
> +       }
> 
>         list_for_each_entry(shrinker, &shrinker_list, list) {
>                 unsigned long long delta;
> @@ -280,12 +282,14 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>                         count_vm_events(SLABS_SCANNED, this_scan);
>                         total_scan -= this_scan;
> 
> -                       cond_resched();
>                 }
> 
>                 shrinker->nr += total_scan;
> +               cond_resched();
>         }
>         up_read(&shrinker_rwsem);
> +out:
> +       cond_resched();
>         return ret;
>  }
> 

This makes some sense for the exit path but if one or more of the
shrinkers takes a very long time without sleeping (extremely long
list searches for example) then kswapd will not call cond_resched()
between shrinkers and still consume a lot of CPU.

> >
> > balance_pgdat() only calls cond_resched if the zones are not
> >        balanced. For a high-order allocation that is balanced, it
> >        checks order-0 again. During that window, order-0 might have
> >        become unbalanced so it loops again for order-0 and returns
> >        that was reclaiming for order-0 to kswapd(). It can then find
> >        that a caller has rewoken kswapd for a high-order and re-enters
> >        balance_pgdat() without ever have called cond_resched().
> 
> If kswapd reclaims order-o followed by high order, it would have a
> chance to call cond_resched in shrink_page_list. But if all zones are
> all_unreclaimable is set, balance_pgdat could return any work. Okay.
> It does make sense.
> By your scenario, someone wakes up kswapd with higher order, again.
> So re-enters balance_pgdat without ever have called cond_resched.
> But if someone wakes up higher order again, we can't have a chance to
> call kswapd_try_to_sleep. So your patch effect would be nop, too.
> 
> It would be better to put cond_resched after balance_pgdat?
> 

Which will leave kswapd runnable instead of going to sleep but
guarantees a scheduling point. Lets see if the problem is that
cond_resched is being missed although if this was the case then patch
4 would truly be a no-op but Colin has already reported that patch 1 on
its own didn't fix his problem. If the problem is sandybridge-specific
where kswapd remains runnable and consuming large amounts of CPU in
turbo mode then we know that there are other cond_resched() decisions
that will need to be revisited.

Colin or James, would you be willing to test with patch 1 from this
series and Minchan's patch below? Thanks.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 292582c..61c45d0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2753,6 +2753,7 @@ static int kswapd(void *p)
>                 if (!ret) {
>                         trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
>                         order = balance_pgdat(pgdat, order, &classzone_idx);
> +                       cond_resched();
>                 }
>         }
>         return 0;
> 
> >
> > While it appears unlikely, there are bad conditions which can result
> > in cond_resched() being avoided.
> 
> >
> > --
> > Mel Gorman
> > SUSE Labs
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
