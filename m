Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BDA0E6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 09:56:31 -0400 (EDT)
Date: Wed, 3 Aug 2011 14:56:24 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/8] mm: vmscan: Throttle reclaim if encountering too
 many dirty pages under writeback
Message-ID: <20110803135624.GJ19099@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <1311265730-5324-7-git-send-email-mgorman@suse.de>
 <20110803111940.GD27199@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110803111940.GD27199@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Wed, Aug 03, 2011 at 01:19:40PM +0200, Johannes Weiner wrote:
> On Thu, Jul 21, 2011 at 05:28:48PM +0100, Mel Gorman wrote:
> > Workloads that are allocating frequently and writing files place a
> > large number of dirty pages on the LRU. With use-once logic, it is
> > possible for them to reach the end of the LRU quickly requiring the
> > reclaimer to scan more to find clean pages. Ordinarily, processes that
> > are dirtying memory will get throttled by dirty balancing but this
> > is a global heuristic and does not take into account that LRUs are
> > maintained on a per-zone basis. This can lead to a situation whereby
> > reclaim is scanning heavily, skipping over a large number of pages
> > under writeback and recycling them around the LRU consuming CPU.
> > 
> > This patch checks how many of the number of pages isolated from the
> > LRU were dirty. If a percentage of them are dirty, the process will be
> > throttled if a blocking device is congested or the zone being scanned
> > is marked congested. The percentage that must be dirty depends on
> > the priority. At default priority, all of them must be dirty. At
> > DEF_PRIORITY-1, 50% of them must be dirty, DEF_PRIORITY-2, 25%
> > etc. i.e.  as pressure increases the greater the likelihood the process
> > will get throttled to allow the flusher threads to make some progress.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  mm/vmscan.c |   21 ++++++++++++++++++---
> >  1 files changed, 18 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index cf7b501..b0060f8 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -720,7 +720,8 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> >  static unsigned long shrink_page_list(struct list_head *page_list,
> >  				      struct zone *zone,
> >  				      struct scan_control *sc,
> > -				      int priority)
> > +				      int priority,
> > +				      unsigned long *ret_nr_dirty)
> >  {
> >  	LIST_HEAD(ret_pages);
> >  	LIST_HEAD(free_pages);
> > @@ -971,6 +972,7 @@ keep_lumpy:
> >  
> >  	list_splice(&ret_pages, page_list);
> >  	count_vm_events(PGACTIVATE, pgactivate);
> > +	*ret_nr_dirty += nr_dirty;
> 
> Note that this includes anon pages, which means that swapping is
> throttled as well.
> 

Yes it does. In the current revision of the series, I'm not using
nr_dirty as it throttles too aggressively. Instead the number of pages
under writeback is counted and that is used for the throttling decision.
It still potentially includes anon pages but that is reasonable.

> I don't think it is a downside to throttle swapping during IO
> congestion - waiting for pages under writeback to become reclaimable
> is better than kicking off even more IO in this case as well - but the
> changelog and the comments should include it, I guess.
> 

Fair point. I've updated the changelog accordingly. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
