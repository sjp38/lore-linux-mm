Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CBE1D6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 11:05:04 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so613456817pfk.3
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 08:05:04 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id u62si57274862pgc.183.2016.12.30.08.05.02
        for <linux-mm@kvack.org>;
        Fri, 30 Dec 2016 08:05:03 -0800 (PST)
Date: Sat, 31 Dec 2016 01:04:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161230160456.GA7267@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
 <20161229075243.GA29208@dhcp22.suse.cz>
 <20161230014853.GA4184@bbox>
 <20161230092636.GA13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230092636.GA13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 30, 2016 at 10:26:37AM +0100, Michal Hocko wrote:
> On Fri 30-12-16 10:48:53, Minchan Kim wrote:
> > On Thu, Dec 29, 2016 at 08:52:46AM +0100, Michal Hocko wrote:
> > > On Thu 29-12-16 14:33:59, Minchan Kim wrote:
> > > > On Wed, Dec 28, 2016 at 04:30:27PM +0100, Michal Hocko wrote:
> [...]
> > > > > +TRACE_EVENT(mm_vmscan_lru_shrink_active,
> > > > > +
> > > > > +	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
> > > > > +		unsigned long nr_unevictable, unsigned long nr_deactivated,
> > > > > +		unsigned long nr_rotated, int priority, int file),
> > > > > +
> > > > > +	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),
> > > > 
> > > > I agree it is helpful. And it was when I investigated aging problem of 32bit
> > > > when node-lru was introduced. However, the question is we really need all those
> > > > kinds of information? just enough with nr_taken, nr_deactivated, priority, file?
> > > 
> > > Dunno. Is it harmful to add this information? I like it more when the
> > > numbers just add up and you have a clear picture. You never know what
> > > might be useful when debugging a weird behavior. 
> > 
> > Michal, I'm not huge fan of "might be useful" although it's a small piece of code.
> 
> But these are tracepoints. One of their primary reasons to exist is
> to help debug things.  And it is really hard to predict what might be
> useful in advance. It is not like the patch would export numbers which
> would be irrelevant to the reclaim.

What's different?

Please think over if everyone says like that they want to add something
with the reason "it's tracepoint which helps dubug and we cannot assume
what might be useful in the future."

> 
> > It adds just all of kinds overheads (memory footprint, runtime performance,
> > maintainance) without any proved benefit.
> 
> Does it really add any measurable overhead or the maintenance burden? I

Don't limit your thought in this particular case and expand the idea to
others who want to see random value via tracepoint with just "might-be-
good". We will lose the reason to prevent that trend if we merge any
tracepoint expansion patch with just "might-be-useful" reason.
Finally, that would bite us.

> think the only place we could argue about is free_hot_cold_page_list
> which is used in hot paths.

The point of view about shrinking active list, what we want to know
is just (nr_taken|nr_deactivated|priority|file) and it's enough,
I think. So, if you want to add nr_freed, nr_unevictable, nr_rotated
please, describe "what problem we can solve with those each numbers".

> 
> I think we can sacrifice it. The same for culled unevictable
> pages. We wouldn't know what is the missing part
> nr_taken-(nr_activate+nr_deactivate) because it could be either freed or
> moved to the unevictable list but that could be handled in a separate
> tracepoint in putback_lru_page which sounds like a useful thing I guess.
>  
> > If we allow such things, people would start adding more things with just "why not,
> > it might be useful. you never know the future" and it ends up making linux fiction
> > novel mess.
> 
> I agree with this concern in general, but is this the case in this
> particular case?

I believe it's not different.

> 
> > If it's necessary, someday, someone will catch up and will send or ask patch with
> > detailed description "why the stat is important and how it is good for us to solve
> > some problem".
> 
> I can certainly enhance the changelog. See below.
> 
> > From that, we can learn workload, way to solve the problem and git
> > history has the valuable description so new comers can keep the community up easily.
> > So, finally, overheads are justified and get merged.
> > 
> > Please add must-have for your goal described.
> 
> My primary point is that tracepoints which do not give us a good picture
> are quite useless and force us to add trace_printk or other means to
> give us further information. Then I wonder why to have an incomplete
> tracepoint at all.
> 
> Anyway, what do you think about this updated patch? I have kept Hillf's
> A-b so please let me know if it is no longer valid.
> --- 
> From 5f1bc22ad1e54050b4da3228d68945e70342ebb6 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 27 Dec 2016 13:18:20 +0100
> Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> 
> Our reclaim process has several tracepoints to tell us more about how
> things are progressing. We are, however, missing a tracepoint to track
> active list aging. Introduce mm_vmscan_lru_shrink_active which reports

I agree this part.

> the number of
> 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> 	  effectiveness.

I agree nr_taken for knowing shrinking effectiveness but don't
agree nr_scanned. If we want to know LRU isolation effectiveness
with nr_scanned and nr_taken, isolate_lru_pages will do.

> 	- nr_rotated pages which tells us that we are hitting referenced
> 	  pages which are deactivated. If this is a large part of the
> 	  reported nr_deactivated pages then the active list is too small

It might be but not exactly. If your goal is to know LRU size, it can be
done in get_scan_count. I tend to agree LRU size is helpful for
performance analysis because decreased LRU size signals memory shortage
then performance drop.

> 	- nr_activated pages which tells us how many pages are keept on the
                                                               kept

> 	  active list - mostly exec pages. A high number can indicate

                               file-based exec pages

> 	  that we might be trashing on executables.

And welcome to drop nr_unevictable, nr_freed.

I will be off until next week monday so please understand if my response
is slow.

Thanks.

> 
> Changes since v1
> - report nr_taken pages as per Minchan
> - report nr_activated as per Minchan
> - do not report nr_freed pages because that would add a tiny overhead to
>   free_hot_cold_page_list which is a hot path
> - do not report nr_unevictable because we can report this number via a
>   different and more generic tracepoint in putback_lru_page
> - fix move_active_pages_to_lru to report proper page count when we hit
>   into large pages
> 
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/trace/events/vmscan.h | 38 ++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                   | 18 ++++++++++++++----
>  2 files changed, 52 insertions(+), 4 deletions(-)
> 
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 39bad8921ca1..f9ef242ece1b 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -363,6 +363,44 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>  		show_reclaim_flags(__entry->reclaim_flags))
>  );
>  
> +TRACE_EVENT(mm_vmscan_lru_shrink_active,
> +
> +	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_taken,
> +		unsigned long nr_activate, unsigned long nr_deactivated,
> +		unsigned long nr_rotated, int priority, int file),
> +
> +	TP_ARGS(nid, nr_scanned, nr_taken, nr_activate, nr_deactivated, nr_rotated, priority, file),
> +
> +	TP_STRUCT__entry(
> +		__field(int, nid)
> +		__field(unsigned long, nr_scanned)
> +		__field(unsigned long, nr_taken)
> +		__field(unsigned long, nr_activate)
> +		__field(unsigned long, nr_deactivated)
> +		__field(unsigned long, nr_rotated)
> +		__field(int, priority)
> +		__field(int, reclaim_flags)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nid = nid;
> +		__entry->nr_scanned = nr_scanned;
> +		__entry->nr_taken = nr_taken;
> +		__entry->nr_activate = nr_activate;
> +		__entry->nr_deactivated = nr_deactivated;
> +		__entry->nr_rotated = nr_rotated;
> +		__entry->priority = priority;
> +		__entry->reclaim_flags = trace_shrink_flags(file);
> +	),
> +
> +	TP_printk("nid=%d nr_scanned=%ld nr_taken=%ld nr_activated=%ld nr_deactivated=%ld nr_rotated=%ld priority=%d flags=%s",
> +		__entry->nid,
> +		__entry->nr_scanned, __entry->nr_taken,
> +		__entry->nr_activate, __entry->nr_deactivated, __entry->nr_rotated,
> +		__entry->priority,
> +		show_reclaim_flags(__entry->reclaim_flags))
> +);
> +
>  #endif /* _TRACE_VMSCAN_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4abf08861d2..4da4d8d0496c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1846,9 +1846,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>   *
>   * The downside is that we have to touch page->_refcount against each page.
>   * But we had to alter page->flags anyway.
> + *
> + * Returns the number of pages moved to the given lru.
>   */
>  
> -static void move_active_pages_to_lru(struct lruvec *lruvec,
> +static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
>  				     struct list_head *list,
>  				     struct list_head *pages_to_free,
>  				     enum lru_list lru)
> @@ -1857,6 +1859,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  	unsigned long pgmoved = 0;
>  	struct page *page;
>  	int nr_pages;
> +	int nr_moved = 0;
>  
>  	while (!list_empty(list)) {
>  		page = lru_to_page(list);
> @@ -1882,11 +1885,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  				spin_lock_irq(&pgdat->lru_lock);
>  			} else
>  				list_add(&page->lru, pages_to_free);
> +		} else {
> +			nr_moved += nr_pages;
>  		}
>  	}
>  
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);
> +
> +	return nr_moved;
>  }
>  
>  static void shrink_active_list(unsigned long nr_to_scan,
> @@ -1902,7 +1909,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> -	unsigned long nr_rotated = 0;
> +	unsigned nr_deactivate, nr_activate;
> +	unsigned nr_rotated = 0;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> @@ -1980,13 +1988,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 */
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
>  
> -	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> -	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> +	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> +	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
>  	mem_cgroup_uncharge_list(&l_hold);
>  	free_hot_cold_page_list(&l_hold, true);
> +	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_scanned, nr_taken,
> +			nr_activate, nr_deactivate, nr_rotated, sc->priority, file);
>  }
>  
>  /*
> -- 
> 2.10.2
> 
> 
> -- 
> Michal Hocko
> SUSE Labs
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
