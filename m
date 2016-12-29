Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55EC76B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:52:50 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id n3so37433159wjy.6
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:52:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wf7si26720281wjb.193.2016.12.28.23.52.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 23:52:49 -0800 (PST)
Date: Thu, 29 Dec 2016 08:52:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161229075243.GA29208@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
 <20161229053359.GA1815@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229053359.GA1815@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 29-12-16 14:33:59, Minchan Kim wrote:
> On Wed, Dec 28, 2016 at 04:30:27PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Our reclaim process has several tracepoints to tell us more about how
> > things are progressing. We are, however, missing a tracepoint to track
> > active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> > the number of scanned, rotated, deactivated and freed pages from the
> > particular node's active list.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/linux/gfp.h           |  2 +-
> >  include/trace/events/vmscan.h | 38 ++++++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c               |  6 +++++-
> >  mm/vmscan.c                   | 22 +++++++++++++++++-----
> >  4 files changed, 61 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index 4175dca4ac39..61aa9b49e86d 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -503,7 +503,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
> >  extern void __free_pages(struct page *page, unsigned int order);
> >  extern void free_pages(unsigned long addr, unsigned int order);
> >  extern void free_hot_cold_page(struct page *page, bool cold);
> > -extern void free_hot_cold_page_list(struct list_head *list, bool cold);
> > +extern int free_hot_cold_page_list(struct list_head *list, bool cold);
> >  
> >  struct page_frag_cache;
> >  extern void __page_frag_drain(struct page *page, unsigned int order,
> > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > index 39bad8921ca1..d34cc0ced2be 100644
> > --- a/include/trace/events/vmscan.h
> > +++ b/include/trace/events/vmscan.h
> > @@ -363,6 +363,44 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
> >  		show_reclaim_flags(__entry->reclaim_flags))
> >  );
> >  
> > +TRACE_EVENT(mm_vmscan_lru_shrink_active,
> > +
> > +	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
> > +		unsigned long nr_unevictable, unsigned long nr_deactivated,
> > +		unsigned long nr_rotated, int priority, int file),
> > +
> > +	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),
> 
> I agree it is helpful. And it was when I investigated aging problem of 32bit
> when node-lru was introduced. However, the question is we really need all those
> kinds of information? just enough with nr_taken, nr_deactivated, priority, file?

Dunno. Is it harmful to add this information? I like it more when the
numbers just add up and you have a clear picture. You never know what
might be useful when debugging a weird behavior. 

[...]
> > -	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> > -	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> > +	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> 
> Who use nr_active in here?

this is an omission. I just forgot to add it... Thanks for noticing.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
