Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 586406B00A2
	for <linux-mm@kvack.org>; Thu, 14 May 2009 03:52:26 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E7rD5b001559
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 16:53:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B134B45DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:53:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AD5A45DE54
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:53:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F53F1DB8037
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:53:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C097AE08002
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:53:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Prevent shrinking of active anon lru list in case of no swap space
In-Reply-To: <20090514164010.25335493.minchan.kim@barrios-desktop>
References: <20090514155504.9B66.A69D9226@jp.fujitsu.com> <20090514164010.25335493.minchan.kim@barrios-desktop>
Message-Id: <20090514164951.9B72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 16:53:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Thu, 14 May 2009 16:19:52 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > 
> > > Now shrink_active_list is called several places.
> > > But if we don't have a swap space, we can't reclaim anon pages.
> > > So, we don't need deactivating anon pages in anon lru list.
> > > 
> > > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > > Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Rik van Riel <riel@redhat.com>
> > 
> > hm, The analysis seems right. but
> > 
> > In general branch should put into non frequency path.
> > why caller modification as following patch is wrong?
> 
> Yes. You're right. Firstly I though that. 
> But there are a few place where inactve_anon_is_low is called.
> In addition to it, we always have to call with (nr_swap_pages <= 0) with it. 
> So alone inactive_anon_is_low is lost function's meaning.
> 
> I think it's meaningless. 
> But We can improve one function wrapper.
> 
> /* I can't be remind proper function name. Can you suggest me ? */
> if (do_we_have_to_shrink_list(zone, &sc))
> 
> 
> int do_we_have_to_shrink_list(...)
> {
>    if (inactive_anon_is_low(zone, &sc) && (nr_swap_pages <= 0))
>    
> }
> 
> What do you think ?

The idea except function-name is good.
hmm.. sorry. I have no alternative idea.


> 
> > 
> >                         /*
> >                          * Do some background aging of the anon list, to give
> >                          * pages a chance to be referenced before reclaiming.
> >                          */
> > -                        if (inactive_anon_is_low(zone, &sc))
> > +                        if (inactive_anon_is_low(zone, &sc) && (nr_swap_pages <= 0))
> >                                 shrink_active_list(SWAP_CLUSTER_MAX, zone,
> >                                                         &sc, priority, 0);
> > 
> > 
> > 
> > 
> > > ---
> > >  mm/vmscan.c |    6 ++++++
> > >  1 files changed, 6 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 2f9d555..e4d71f4 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1238,6 +1238,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> > >  	enum lru_list lru;
> > >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> > >  
> > > +	/* 
> > > +	 * we can't shrink anon list in case of no swap space.
> > > +	 */
> > > +	if (file == 0 && nr_swap_pages <= 0)
> > > +		return;
> > > +
> > >
> > >  	lru_add_drain();
> > >  	spin_lock_irq(&zone->lru_lock);
> > >  	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
> > > -- 
> > > 1.5.4.3
> > > 
> > > 
> > > -- 
> > > Kinds Regards
> > > Minchan Kim
> > 
> > 
> > 
> 
> 
> -- 
> Kinds Regards
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
