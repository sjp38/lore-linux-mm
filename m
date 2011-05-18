Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C4326B0027
	for <linux-mm@kvack.org>; Wed, 18 May 2011 00:09:49 -0400 (EDT)
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110517103840.GL5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	 <1305295404-12129-5-git-send-email-mgorman@suse.de>
	 <4DCFAA80.7040109@jp.fujitsu.com> <1305519711.4806.7.camel@mulgrave.site>
	 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	 <20110516084558.GE5279@suse.de>
	 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	 <20110516102753.GF5279@suse.de>
	 <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
	 <20110517103840.GL5279@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 May 2011 08:09:33 +0400
Message-ID: <1305691773.2580.1.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue, 2011-05-17 at 11:38 +0100, Mel Gorman wrote:
> On Tue, May 17, 2011 at 08:50:44AM +0900, Minchan Kim wrote:
> > Don't we have to move cond_resched?
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 292582c..633e761 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -231,8 +231,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >         if (scanned == 0)
> >                 scanned = SWAP_CLUSTER_MAX;
> > 
> > -       if (!down_read_trylock(&shrinker_rwsem))
> > -               return 1;       /* Assume we'll be able to shrink next time */
> > +       if (!down_read_trylock(&shrinker_rwsem)) {
> > +               ret = 1;
> > +               goto out; /* Assume we'll be able to shrink next time */
> > +       }
> > 
> >         list_for_each_entry(shrinker, &shrinker_list, list) {
> >                 unsigned long long delta;
> > @@ -280,12 +282,14 @@ unsigned long shrink_slab(struct shrink_control *shrink,
> >                         count_vm_events(SLABS_SCANNED, this_scan);
> >                         total_scan -= this_scan;
> > 
> > -                       cond_resched();
> >                 }
> > 
> >                 shrinker->nr += total_scan;
> > +               cond_resched();
> >         }
> >         up_read(&shrinker_rwsem);
> > +out:
> > +       cond_resched();
> >         return ret;
> >  }
> > 
> 
> This makes some sense for the exit path but if one or more of the
> shrinkers takes a very long time without sleeping (extremely long
> list searches for example) then kswapd will not call cond_resched()
> between shrinkers and still consume a lot of CPU.
> 
> > >
> > > balance_pgdat() only calls cond_resched if the zones are not
> > >        balanced. For a high-order allocation that is balanced, it
> > >        checks order-0 again. During that window, order-0 might have
> > >        become unbalanced so it loops again for order-0 and returns
> > >        that was reclaiming for order-0 to kswapd(). It can then find
> > >        that a caller has rewoken kswapd for a high-order and re-enters
> > >        balance_pgdat() without ever have called cond_resched().
> > 
> > If kswapd reclaims order-o followed by high order, it would have a
> > chance to call cond_resched in shrink_page_list. But if all zones are
> > all_unreclaimable is set, balance_pgdat could return any work. Okay.
> > It does make sense.
> > By your scenario, someone wakes up kswapd with higher order, again.
> > So re-enters balance_pgdat without ever have called cond_resched.
> > But if someone wakes up higher order again, we can't have a chance to
> > call kswapd_try_to_sleep. So your patch effect would be nop, too.
> > 
> > It would be better to put cond_resched after balance_pgdat?
> > 
> 
> Which will leave kswapd runnable instead of going to sleep but
> guarantees a scheduling point. Lets see if the problem is that
> cond_resched is being missed although if this was the case then patch
> 4 would truly be a no-op but Colin has already reported that patch 1 on
> its own didn't fix his problem. If the problem is sandybridge-specific
> where kswapd remains runnable and consuming large amounts of CPU in
> turbo mode then we know that there are other cond_resched() decisions
> that will need to be revisited.
> 
> Colin or James, would you be willing to test with patch 1 from this
> series and Minchan's patch below? Thanks.

Yes, but unfortunately I'm on the road at the moment.  I won't get back
to the laptop showing the problem until late on Tuesday (24th).  If it
works for Colin, I'd assume it's OK.

James


> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 292582c..61c45d0 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2753,6 +2753,7 @@ static int kswapd(void *p)
> >                 if (!ret) {
> >                         trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
> >                         order = balance_pgdat(pgdat, order, &classzone_idx);
> > +                       cond_resched();
> >                 }
> >         }
> >         return 0;
> > 
> > >
> > > While it appears unlikely, there are bad conditions which can result
> > > in cond_resched() being avoided.
> > 
> > >
> > > --
> > > Mel Gorman
> > > SUSE Labs
> > >
> > 
> > 
> > 
> > -- 
> > Kind regards,
> > Minchan Kim
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
