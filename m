Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCCD6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:03:00 -0500 (EST)
Date: Wed, 24 Nov 2010 10:02:42 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-ID: <20101124100242.GW19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101123092826.GD19571@csn.ul.ie> <AANLkTi=KunDRwVd73vtbng0F+a=QBgJeV5BXrewYJa3R@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=KunDRwVd73vtbng0F+a=QBgJeV5BXrewYJa3R@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 24, 2010 at 08:24:35AM +0900, Minchan Kim wrote:
> >> <SNIP>
> >>
> >> +static void __pagevec_lru_deactive(struct pagevec *pvec)
> >> +{
> >
> > Might be worth commenting that this function must be called with pre-emption
> > disabled. FWIW, I am reasonably sure your implementation is prefectly safe
> > but a note wouldn't hurt.
> 
> Will fix.
> 

Thanks

> >
> >> +     int i, lru, file;
> >> +
> >> +     struct zone *zone = NULL;
> >> +
> >> +     for (i = 0; i < pagevec_count(pvec); i++) {
> >> +             struct page *page = pvec->pages[i];
> >> +             struct zone *pagezone = page_zone(page);
> >> +
> >> +             if (pagezone != zone) {
> >> +                     if (zone)
> >> +                             spin_unlock_irq(&zone->lru_lock);
> >> +                     zone = pagezone;
> >> +                     spin_lock_irq(&zone->lru_lock);
> >> +             }
> >> +
> >> +             if (PageLRU(page)) {
> >> +                     if (PageActive(page)) {
> >> +                             file = page_is_file_cache(page);
> >> +                             lru = page_lru_base_type(page);
> >> +                             del_page_from_lru_list(zone, page,
> >> +                                             lru + LRU_ACTIVE);
> >> +                             ClearPageActive(page);
> >> +                             ClearPageReferenced(page);
> >> +                             add_page_to_lru_list(zone, page, lru);
> >> +                             __count_vm_event(PGDEACTIVATE);
> >> +
> >
> > What about memcg, do we not need to be calling mem_cgroup_add_lru_list() here
> > as well? I'm looking at the differences between what move_active_pages_to_lru()
> 
> Recently, add_page_to_lru_list contains mem_cgroup_add_lru_list.
> 

My bad, you're right. I was thrown by move_active_pages_to_lru() needing to
do memcg stuff manually and didn't spot why it ok to miss it here.

> > is doing and this. I'm wondering if it'd be worth your whole building a list
> > of active pages that are to be moved to the inactive list and passing them
> > to move_active_pages_to_lru() ? I confuess I have not thought about it deeply
> > so it might be a terrible suggestion but it might reduce duplication of code.
> 
> Firstly I tried it so I sent a patch about making
> move_to_active_pages_to_lru more generic.
> move_to_active_pages_to_lru needs zone argument so I need gathering
> pages per zone in truncate.
> I don't want for user of the function to consider even zone and
> zone->lru_lock handling.
> 
> I think the lru_demote_pages could be used elsewhere(ex, readahead max
> size heuristic).
> So it's generic and easy to use. :)
> 

Ok, that's fair enough.

> >
> >> +                             update_page_reclaim_stat(zone, page, file, 0);
> >> +                     }
> >> +             }
> >> +     }
> >> +     if (zone)
> >> +             spin_unlock_irq(&zone->lru_lock);
> >> +
> >> +     release_pages(pvec->pages, pvec->nr, pvec->cold);
> >> +     pagevec_reinit(pvec);
> >> +}
> >> +
> >>  /*
> >>   * Drain pages out of the cpu's pagevecs.
> >>   * Either "cpu" is the current CPU, and preemption has already been
> >> @@ -292,8 +333,28 @@ static void drain_cpu_pagevecs(int cpu)
> >>               pagevec_move_tail(pvec);
> >>               local_irq_restore(flags);
> >>       }
> >> +
> >> +     pvec = &per_cpu(lru_deactive_pvecs, cpu);
> >> +     if (pagevec_count(pvec))
> >> +             __pagevec_lru_deactive(pvec);
> >> +}
> >> +
> >> +/*
> >> + * Function used to forecefully demote a page to the head of the inactive
> >> + * list.
> >
> > s/forecefully/forcefully/
> >
> > The comment should also state *why* and under what circumstances we move
> > pages to the inactive list like this. Also based on the discussions
> > elsewhere in this thread, it'd be nice to include a comment why it's the
> > head of the inactive list and not the tail.
> 
> Fair enough.
> 
> Thanks for the comment, Mel.
> 
> -- 
> Kind regards,
> Minchan Kim
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
