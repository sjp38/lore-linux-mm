Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id C7ACF6B0011
	for <linux-mm@kvack.org>; Thu, 19 May 2011 07:36:40 -0400 (EDT)
Subject: Re: [PATCH] mm: vmscan: Correctly check if reclaimer should
 schedule during shrink_slab
From: Colin Ian King <colin.king@canonical.com>
In-Reply-To: <BANLkTimUJeTbWV_0BzgjrDjY=Wpc-PaG5Q@mail.gmail.com>
References: <1305295404-12129-5-git-send-email-mgorman@suse.de>
	 <4DCFAA80.7040109@jp.fujitsu.com> <1305519711.4806.7.camel@mulgrave.site>
	 <BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	 <20110516084558.GE5279@suse.de>
	 <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	 <20110516102753.GF5279@suse.de>
	 <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
	 <20110517103840.GL5279@suse.de> <1305640239.2046.27.camel@lenovo>
	 <20110517161508.GN5279@suse.de>
	 <BANLkTimUJeTbWV_0BzgjrDjY=Wpc-PaG5Q@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 19 May 2011 12:36:22 +0100
Message-ID: <1305804982.2145.6.camel@lenovo>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Thu, 2011-05-19 at 09:09 +0900, Minchan Kim wrote:
> Hi Colin.
> 
> Sorry for bothering you. :(

No problem at all, I've very happy to re-test.

> I hope this test is last.
> 
> We(Mel, KOSAKI and me) finalized opinion.
> 
> Could you test below patch with patch[1/4] of Mel's series(ie,
> !pgdat_balanced  of sleeping_prematurely)?
> If it is successful, we will try to merge this version instead of
> various cond_resched sprinkling version.

tested with the patch below + patch[1/4] of Mel's series.  300 cycles,
2.5 hrs of soak testing: works OK.

Colin
> 
> 
> On Wed, May 18, 2011 at 1:15 AM, Mel Gorman <mgorman@suse.de> wrote:
> > It has been reported on some laptops that kswapd is consuming large
> > amounts of CPU and not being scheduled when SLUB is enabled during
> > large amounts of file copying. It is expected that this is due to
> > kswapd missing every cond_resched() point because;
> >
> > shrink_page_list() calls cond_resched() if inactive pages were isolated
> >        which in turn may not happen if all_unreclaimable is set in
> >        shrink_zones(). If for whatver reason, all_unreclaimable is
> >        set on all zones, we can miss calling cond_resched().
> >
> > balance_pgdat() only calls cond_resched if the zones are not
> >        balanced. For a high-order allocation that is balanced, it
> >        checks order-0 again. During that window, order-0 might have
> >        become unbalanced so it loops again for order-0 and returns
> >        that it was reclaiming for order-0 to kswapd(). It can then
> >        find that a caller has rewoken kswapd for a high-order and
> >        re-enters balance_pgdat() without ever calling cond_resched().
> >
> > shrink_slab only calls cond_resched() if we are reclaiming slab
> >        pages. If there are a large number of direct reclaimers, the
> >        shrinker_rwsem can be contended and prevent kswapd calling
> >        cond_resched().
> >
> > This patch modifies the shrink_slab() case. If the semaphore is
> > contended, the caller will still check cond_resched(). After each
> > successful call into a shrinker, the check for cond_resched() is
> > still necessary in case one shrinker call is particularly slow.
> >
> > This patch replaces
> > mm-vmscan-if-kswapd-has-been-running-too-long-allow-it-to-sleep.patch
> > in -mm.
> >
> > [mgorman@suse.de: Preserve call to cond_resched after each call into shrinker]
> > From: Minchan Kim <minchan.kim@gmail.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c |    9 +++++++--
> >  1 files changed, 7 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index af24d1e..0bed248 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -230,8 +230,11 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
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
> >
> >        list_for_each_entry(shrinker, &shrinker_list, list) {
> >                unsigned long long delta;
> > @@ -282,6 +285,8 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> >                shrinker->nr += total_scan;
> >        }
> >        up_read(&shrinker_rwsem);
> > +out:
> > +       cond_resched();
> >        return ret;
> >  }
> >
> >
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
