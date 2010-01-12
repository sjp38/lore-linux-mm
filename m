Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5950E6B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 19:50:27 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C0oPfF020431
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 09:50:25 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E645E45DE51
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:50:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CAB2B45DE50
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:50:24 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B90BE08001
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:50:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 40DAC1DB803F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 09:50:24 +0900 (JST)
Date: Tue, 12 Jan 2010 09:47:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
Message-Id: <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100111153802.f3150117.minchan.kim@barrios-desktop>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	<1263191277-30373-1-git-send-email-shijie8@gmail.com>
	<20100111153802.f3150117.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 15:38:02 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, 11 Jan 2010 14:27:57 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
> 
> >   Move the __mod_zone_page_state out the guard region of
> > the spinlock to relieve the pressure for memory free.
> > 
> >   Using the zone->lru_lock to replace the zone->lock for
> > zone->pages_scanned and zone's flag ZONE_ALL_UNRECLAIMABLE.
> > 
> > Signed-off-by: Huang Shijie <shijie8@gmail.com>
> > ---
> >  mm/page_alloc.c |   33 +++++++++++++++++++++++----------
> >  1 files changed, 23 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 290dfc3..dfd4be0 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -530,12 +530,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  {
> >  	int migratetype = 0;
> >  	int batch_free = 0;
> > +	int free_ok = 0;
> >  
> >  	spin_lock(&zone->lock);
> > -	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > -	zone->pages_scanned = 0;
> > -
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
> >  	while (count) {
> >  		struct page *page;
> >  		struct list_head *list;
> > @@ -558,23 +555,39 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> >  			page = list_entry(list->prev, struct page, lru);
> >  			/* must delete as __free_one_page list manipulates */
> >  			list_del(&page->lru);
> > -			__free_one_page(page, zone, 0, migratetype);
> > +			free_ok += __free_one_page(page, zone, 0, migratetype);
> >  			trace_mm_page_pcpu_drain(page, 0, migratetype);
> >  		} while (--count && --batch_free && !list_empty(list));
> >  	}
> >  	spin_unlock(&zone->lock);
> > +
> > +	if (likely(free_ok)) {
> > +		spin_lock(&zone->lru_lock);
> > +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > +		zone->pages_scanned = 0;
> > +		spin_unlock(&zone->lru_lock);
> > +
> > +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok);
> > +	}
> >  }
> >  
> >  static void free_one_page(struct zone *zone, struct page *page, int order,
> >  				int migratetype)
> >  {
> > -	spin_lock(&zone->lock);
> > -	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > -	zone->pages_scanned = 0;
> > +	int free_ok;
> >  
> > -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> > -	__free_one_page(page, zone, order, migratetype);
> > +	spin_lock(&zone->lock);
> > +	free_ok = __free_one_page(page, zone, order, migratetype);
> >  	spin_unlock(&zone->lock);
> > +
> > +	if (likely(free_ok)) {
> > +		spin_lock(&zone->lru_lock);
> > +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > +		zone->pages_scanned = 0;
> > +		spin_unlock(&zone->lru_lock);
> > +
> > +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok << order);
> > +	}
> >  }
> >  
> >  static void __free_pages_ok(struct page *page, unsigned int order)
> > -- 
> > 1.6.5.2
> > 
> 
> Thanks, Huang. 
> 
> Frankly speaking, I am not sure this ir right way.
> This patch is adding to fine-grained locking overhead
> 
> As you know, this functions are one of hot pathes.
> In addition, we didn't see the any problem, until now.
> It means out of synchronization in ZONE_ALL_UNRECLAIMABLE 
> and pages_scanned are all right?
> 
> If it is, we can move them out of zone->lock, too.
> If it isn't, we need one more lock, then. 
> 
I don't want to see additional spin_lock, here. 

About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
If you have concerns with other flags, please modify this with single word,
instead of a bit field.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
