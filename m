Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9ED4A6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 06:50:41 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BBodKo015914
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 20:50:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C883B2AEA81
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:50:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A89351EF082
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:50:38 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 873CE1DB803F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:50:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 19F4AE08002
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 20:50:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
In-Reply-To: <20090211003715.GB6422@barrios-desktop>
References: <2f11576a0902101241j5a006e09w46ecdbdb9c77e081@mail.gmail.com> <20090211003715.GB6422@barrios-desktop>
Message-Id: <20090211204453.C3C3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 20:50:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Feb 11, 2009 at 05:41:21AM +0900, KOSAKI Motohiro wrote:
> > >>  {
> > >>       struct zone *zone;
> > >> -     unsigned long nr_to_scan, ret = 0;
> > >> +     unsigned long nr_to_scan;
> > >>       enum lru_list l;
> > >
> > > Basing it on swsusp-clean-up-shrink_all_zones.patch probably makes it
> > > easier for Andrew to pick it up.
> > 
> > ok, thanks.
> > 
> > >>                       reclaim_state.reclaimed_slab = 0;
> > >> -                     shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> > >> -                     ret += reclaim_state.reclaimed_slab;
> > >> -             } while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
> > >> +                     shrink_slab(nr_pages, sc.gfp_mask,
> > >> +                                 global_lru_pages());
> > >> +                     sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> > >> +             } while (sc.nr_reclaimed < nr_pages &&
> > >> +                      reclaim_state.reclaimed_slab > 0);
> > >
> > > :(
> > >
> > > Is this really an improvement?  `ret' is better to read than
> > > `sc.nr_reclaimed'.
> > 
> > I know it's debetable thing.
> > but I still think code consistency is important than variable name preference.
> 
> How about this ?
> 
> I followed do_try_to_free_pages coding style.
> It use both 'sc->nr_reclaimed' and 'ret'.
> It can support code consistency and readability. 
> 
> So, I think it would be better.  
> If you don't mind, I will resend with your sign-off.

looks good. thanks.


> -static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
> +static void shrink_all_zones(unsigned long nr_pages, int prio,
>  				      int pass, struct scan_control *sc)
>  {
>  	struct zone *zone;
>  	unsigned long nr_to_scan, ret = 0;
> +	unsigned long nr_reclaimed = sc->nr_reclaimed;
>  	enum lru_list l;

and, please changelog change.
this patch have behavior change.

old bale-out checking didn't checked properly.
it's because shrink_all_memory() has five pass. but shrink_all_zones()
initialize ret = 0 every time.

then, at pass 1-4, if(ret >= nr_pages) don't judge reclaimed enough page or not.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
