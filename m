Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0375F6B0089
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 05:14:01 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBNADruE013294
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 15:43:53 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBNADr3R3149954
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 15:43:53 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBNADqfN019904
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 21:13:53 +1100
Date: Thu, 23 Dec 2010 14:03:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v2)
Message-ID: <20101223083354.GB16046@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101210142745.29934.29186.stgit@localhost6.localdomain6>
 <20101210143112.29934.22944.stgit@localhost6.localdomain6>
 <AANLkTinaTUUfvK+Nc-Whck21r-OzT+0CFVnS4W_jG5aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinaTUUfvK+Nc-Whck21r-OzT+0CFVnS4W_jG5aw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-14 20:02:45]:

> > +                       if (should_reclaim_unmapped_pages(zone))
> > +                               wakeup_kswapd(zone, order);
> 
> I think we can put the logic into zone_watermark_okay.
>

I did some checks and zone_watermark_ok is used in several places for
a generic check like this -- for example prior to zone_reclaim(), if
in get_page_from_freelist() we skip zones based on the return value.
The compaction code uses it as well, the impact would be deeper. The
compaction code uses it to check whether an allocation will succeed or
not, I don't want unmapped page control to impact that.
 
> > +                       /*
> > +                        * We do unmapped page reclaim once here and once
> > +                        * below, so that we don't lose out
> > +                        */
> > +                       reclaim_unmapped_pages(priority, zone, &sc);
> 
> It can make unnecessary stir of lru pages.
> How about this?
> zone_watermark_ok returns ZONE_UNMAPPED_PAGE_FULL.
> wakeup_kswapd(..., please reclaim unmapped page cache).
> If kswapd is woke up by unmapped page full, kswapd sets up sc with unmap = 0.
> If the kswapd try to reclaim unmapped page, shrink_page_list doesn't
> rotate non-unmapped pages.

With may_unmap set to 0 and may_writepage set to 0, I don't think this
should be a major problem, like I said this code is already enabled if
zone_reclaim_mode != 0 and CONFIG_NUMA is set.

> > +unsigned long reclaim_unmapped_pages(int priority, struct zone *zone,
> > +                                               struct scan_control *sc)
> > +{
> > +       if (unlikely(unmapped_page_control) &&
> > +               (zone_unmapped_file_pages(zone) > zone->min_unmapped_pages)) {
> > +               struct scan_control nsc;
> > +               unsigned long nr_pages;
> > +
> > +               nsc = *sc;
> > +
> > +               nsc.swappiness = 0;
> > +               nsc.may_writepage = 0;
> > +               nsc.may_unmap = 0;
> > +               nsc.nr_reclaimed = 0;
> 
> This logic can be put in zone_reclaim_unmapped_pages.
> 

Now that I refactored the code and called it zone_reclaim_pages, I
expect the correct sc to be passed to it. This code is reused between
zone_reclaim() and reclaim_unmapped_pages(). In the former,
zone_reclaim does the setup.

> If we want really this, how about the new cache lru idea as Kame suggests?
> For example, add_to_page_cache_lru adds the page into cache lru.
> page_add_file_rmap moves the page into inactive file.
> page_remove_rmap moves the page into lru cache, again.
> We can count the unmapped pages and if the size exceeds limit, we can
> wake up kswapd.
> whenever the memory pressure happens, first of all, reclaimer try to
> reclaim cache lru.

We already have a file LRU and that has active/inactive lists, I don't
think a special mapped/unmapped list makes sense at this point.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
