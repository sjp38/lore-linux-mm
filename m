Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 675A76B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 07:43:36 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so113673tia.8
        for <linux-mm@kvack.org>; Wed, 11 Feb 2009 04:43:33 -0800 (PST)
Date: Wed, 11 Feb 2009 21:43:24 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
Message-Id: <20090211214324.6a9cfb58.minchan.kim@barrios-desktop>
In-Reply-To: <20090211204453.C3C3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <2f11576a0902101241j5a006e09w46ecdbdb9c77e081@mail.gmail.com>
	<20090211003715.GB6422@barrios-desktop>
	<20090211204453.C3C3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 20:50:37 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed, Feb 11, 2009 at 05:41:21AM +0900, KOSAKI Motohiro wrote:
> > > >>  {
> > > >>       struct zone *zone;
> > > >> -     unsigned long nr_to_scan, ret = 0;
> > > >> +     unsigned long nr_to_scan;
> > > >>       enum lru_list l;
> > > >
> > > > Basing it on swsusp-clean-up-shrink_all_zones.patch probably makes it
> > > > easier for Andrew to pick it up.
> > > 
> > > ok, thanks.
> > > 
> > > >>                       reclaim_state.reclaimed_slab = 0;
> > > >> -                     shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
> > > >> -                     ret += reclaim_state.reclaimed_slab;
> > > >> -             } while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
> > > >> +                     shrink_slab(nr_pages, sc.gfp_mask,
> > > >> +                                 global_lru_pages());
> > > >> +                     sc.nr_reclaimed += reclaim_state.reclaimed_slab;
> > > >> +             } while (sc.nr_reclaimed < nr_pages &&
> > > >> +                      reclaim_state.reclaimed_slab > 0);
> > > >
> > > > :(
> > > >
> > > > Is this really an improvement?  `ret' is better to read than
> > > > `sc.nr_reclaimed'.
> > > 
> > > I know it's debetable thing.
> > > but I still think code consistency is important than variable name preference.
> > 
> > How about this ?
> > 
> > I followed do_try_to_free_pages coding style.
> > It use both 'sc->nr_reclaimed' and 'ret'.
> > It can support code consistency and readability. 
> > 
> > So, I think it would be better.  
> > If you don't mind, I will resend with your sign-off.
> 
> looks good. thanks.
> 
> 
> > -static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
> > +static void shrink_all_zones(unsigned long nr_pages, int prio,
> >  				      int pass, struct scan_control *sc)
> >  {
> >  	struct zone *zone;
> >  	unsigned long nr_to_scan, ret = 0;
> > +	unsigned long nr_reclaimed = sc->nr_reclaimed;
> >  	enum lru_list l;
> 
> and, please changelog change.
> this patch have behavior change.
> 
> old bale-out checking didn't checked properly.
> it's because shrink_all_memory() has five pass. but shrink_all_zones()
> initialize ret = 0 every time.
> 
> then, at pass 1-4, if(ret >= nr_pages) don't judge reclaimed enough page or not.
> 

Hmm, I think old bale-out code is right. 
In shrink_all_memory, As more reclaiming with pass progressing, 
the smaller nr_to_scan is. The nr_to_scan is the number of page shrinking which
user want. 
The shrink_all_zones have to reclaim nr_to_scan's page by doing best effort.
So, If you use accumulation of reclaim, it can break bale-out in shrink_all_zones.
I mean here.

'
              NR_LRU_BASE + l)); 
        ret += shrink_list(l, nr_to_scan, zone,
                sc, prio);
        if (ret >= nr_pages)
          return ret; 
      }    
'

I have to make patch again so that it will keep on old bale-out behavior. 

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
