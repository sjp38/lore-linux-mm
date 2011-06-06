Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE0E6B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 10:01:31 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2606760pwi.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 07:01:29 -0700 (PDT)
Date: Mon, 6 Jun 2011 23:01:20 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606140120.GC1686@barrios-laptop>
References: <20110531141402.GK19505@random.random>
 <20110531143734.GB13418@barrios-laptop>
 <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
 <20110602223201.GH2802@random.random>
 <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
 <20110606101557.GA5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606101557.GA5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2011 at 11:15:57AM +0100, Mel Gorman wrote:
> On Fri, Jun 03, 2011 at 08:01:44AM +0900, Minchan Kim wrote:
> > On Fri, Jun 3, 2011 at 7:32 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > > On Fri, Jun 03, 2011 at 07:23:48AM +0900, Minchan Kim wrote:
> > >> I mean we have more tail pages than head pages. So I think we are likely to
> > >> meet tail pages. Of course, compared to all pages(page cache, anon and
> > >> so on), compound pages would be very small percentage.
> > >
> > > Yes that's my point, that being a small percentage it's no big deal to
> > > break the loop early.
> > 
> > Indeed.
> > 
> > >
> > >> > isolated the head and it's useless to insist on more tail pages (at
> > >> > least for large page size like on x86). Plus we've compaction so
> > >>
> > >> I can't understand your point. Could you elaborate it?
> > >
> > > What I meant is that if we already isolated the head page of the THP,
> > > we don't need to try to free the tail pages and breaking the loop
> > > early, will still give us a chance to free a whole 2m because we
> > > isolated the head page (it'll involve some work and swapping but if it
> > > was a compoundtranspage we're ok to break the loop and we're not
> > > making the logic any worse). Provided the PMD_SIZE is quite large like
> > > 2/4m...
> > 
> > Do you want this? (it's almost pseudo-code)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 7a4469b..9d7609f 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1017,7 +1017,7 @@ static unsigned long isolate_lru_pages(unsigned
> > long nr_to_scan,
> >         for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> >                 struct page *page;
> >                 unsigned long pfn;
> > -               unsigned long end_pfn;
> > +               unsigned long start_pfn, end_pfn;
> >                 unsigned long page_pfn;
> >                 int zone_id;
> > 
> > @@ -1057,9 +1057,9 @@ static unsigned long isolate_lru_pages(unsigned
> > long nr_to_scan,
> >                  */
> >                 zone_id = page_zone_id(page);
> >                 page_pfn = page_to_pfn(page);
> > -               pfn = page_pfn & ~((1 << order) - 1);
> > +               start_pfn = pfn = page_pfn & ~((1 << order) - 1);
> >                 end_pfn = pfn + (1 << order);
> > -               for (; pfn < end_pfn; pfn++) {
> > +               while (pfn < end_pfn) {
> >                         struct page *cursor_page;
> > 
> >                         /* The target page is in the block, ignore it. */
> > @@ -1086,17 +1086,25 @@ static unsigned long
> > isolate_lru_pages(unsigned long nr_to_scan,
> >                                 break;
> > 
> >                         if (__isolate_lru_page(cursor_page, mode, file) == 0) {
> > +                               int isolated_pages;
> >                                 list_move(&cursor_page->lru, dst);
> >                                 mem_cgroup_del_lru(cursor_page);
> > -                               nr_taken += hpage_nr_pages(page);
> > +                               isolated_pages = hpage_nr_pages(page);
> > +                               nr_taken += isolated_pages;
> > +                               /* if we isolated pages enough, let's
> > break early */
> > +                               if (nr_taken > end_pfn - start_pfn)
> > +                                       break;
> > +                               pfn += isolated_pages;
> 
> I think this condition is somewhat unlikely. We are scanning within
> aligned blocks in this linear scanner. Huge pages are always aligned
> so the only situation where we'll encounter a hugepage in the middle
> of this linear scan is when the requested order is larger than a huge
> page. This is exceptionally rare.
> 
> Did I miss something?

Never. You're absolute right.
I don't have systems which have lots of hpages.
But I have heard some guys tunes MAX_ORDER(Whether it's a good or bad is off-topic).
Anyway, it would be good in such system but I admit it would be rare.
I don't have strong mind about this pseudo patch.

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
