Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA976B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 04:32:21 -0400 (EDT)
Date: Tue, 31 May 2011 09:32:15 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110531083215.GT5044@csn.ul.ie>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530161415.GB2200@barrios-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110530161415.GB2200@barrios-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Tue, May 31, 2011 at 01:14:15AM +0900, Minchan Kim wrote:
> On Mon, May 30, 2011 at 02:13:00PM +0100, Mel Gorman wrote:
> > Asynchronous compaction is used when promoting to huge pages. This is
> > all very nice but if there are a number of processes in compacting
> > memory, a large number of pages can be isolated. An "asynchronous"
> > process can stall for long periods of time as a result with a user
> > reporting that firefox can stall for 10s of seconds. This patch aborts
> > asynchronous compaction if too many pages are isolated as it's better to
> > fail a hugepage promotion than stall a process.
> > 
> > If accepted, this should also be considered for 2.6.39-stable. It should
> > also be considered for 2.6.38-stable but ideally [11bc82d6: mm:
> > compaction: Use async migration for __GFP_NO_KSWAPD and enforce no
> > writeback] would be applied to 2.6.38 before consideration.
> > 
> > Reported-and-Tested-by: Ury Stankevich <urykhy@gmail.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 

Thanks

> I have a nitpick below.
> Otherwise, looks good to me.
> 
> > ---
> >  mm/compaction.c |   32 ++++++++++++++++++++++++++------
> >  1 files changed, 26 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 021a296..331a2ee 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -240,11 +240,20 @@ static bool too_many_isolated(struct zone *zone)
> >  	return isolated > (inactive + active) / 2;
> >  }
> >  
> > +/* possible outcome of isolate_migratepages */
> > +typedef enum {
> > +	ISOLATE_ABORT,		/* Abort compaction now */
> > +	ISOLATE_NONE,		/* No pages isolated, continue scanning */
> > +	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
> > +} isolate_migrate_t;
> > +
> >  /*
> >   * Isolate all pages that can be migrated from the block pointed to by
> >   * the migrate scanner within compact_control.
> > + *
> > + * Returns false if compaction should abort at this point due to congestion.
> 
> false? I think it would be better to use explicit word, ISOLATE_ABORT.
> 

Oops, thanks for pointing that out. I'll post a V2 once it has been
figured out why NR_ISOLATE_* is getting screwed up on !CONFIG_SMP.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
