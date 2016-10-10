Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C15596B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 03:41:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id i187so33032945lfe.4
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 00:41:43 -0700 (PDT)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id b127si13542322lfg.422.2016.10.10.00.41.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 00:41:42 -0700 (PDT)
Received: by mail-lf0-f67.google.com with SMTP id b75so8478610lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 00:41:42 -0700 (PDT)
Date: Mon, 10 Oct 2016 09:41:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/4] mm: unreserve highatomic free pages fully before OOM
Message-ID: <20161010074139.GB20420@dhcp22.suse.cz>
References: <1475819136-24358-1-git-send-email-minchan@kernel.org>
 <1475819136-24358-4-git-send-email-minchan@kernel.org>
 <20161007090917.GA18447@dhcp22.suse.cz>
 <20161007144345.GC3060@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161007144345.GC3060@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>

On Fri 07-10-16 23:43:45, Minchan Kim wrote:
> On Fri, Oct 07, 2016 at 11:09:17AM +0200, Michal Hocko wrote:
> > On Fri 07-10-16 14:45:35, Minchan Kim wrote:
> > > After fixing the race of highatomic page count, I still encounter
> > > OOM with many free memory reserved as highatomic.
> > > 
> > > One of reason in my testing was we unreserve free pages only if
> > > reclaim has progress. Otherwise, we cannot have chance to unreseve.
> > > 
> > > Other problem after fixing it was it doesn't guarantee every pages
> > > unreserving of highatomic pageblock because it just release *a*
> > > pageblock which could have few free pages so other context could
> > > steal it easily so that the process stucked with direct reclaim
> > > finally can encounter OOM although there are free pages which can
> > > be unreserved.
> > > 
> > > This patch changes the logic so that it unreserves pageblocks with
> > > no_progress_loop proportionally. IOW, in first retrial of reclaim,
> > > it will try to unreserve a pageblock. In second retrial of reclaim,
> > > it will try to unreserve 1/MAX_RECLAIM_RETRIES * reserved_pageblock
> > > and finally all reserved pageblock before the OOM.
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/page_alloc.c | 57 ++++++++++++++++++++++++++++++++++++++++++++-------------
> > >  1 file changed, 44 insertions(+), 13 deletions(-)
> > 
> > This sounds much more complex then it needs to be IMHO. Why something as
> > simple as thhe following wouldn't work? Please note that I even didn't
> > try to compile this. It is just give you an idea.
> > ---
> >  mm/page_alloc.c | 26 ++++++++++++++++++++------
> >  1 file changed, 20 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 73f60ad6315f..e575a4f38555 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2056,7 +2056,8 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
> >   * intense memory pressure but failed atomic allocations should be easier
> >   * to recover from than an OOM.
> >   */
> > -static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> > +static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
> > +		bool force)
> >  {
> >  	struct zonelist *zonelist = ac->zonelist;
> >  	unsigned long flags;
> > @@ -2067,8 +2068,14 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> >  
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
> >  								ac->nodemask) {
> > -		/* Preserve at least one pageblock */
> > -		if (zone->nr_reserved_highatomic <= pageblock_nr_pages)
> > +		if (!zone->nr_reserved_highatomic)
> > +			continue;
> > +
> > +		/*
> > +		 * Preserve at least one pageblock unless we are really running
> > +		 * out of memory
> > +		 */
> > +		if (!force && zone->nr_reserved_highatomic <= pageblock_nr_pages)
> >  			continue;
> >  
> >  		spin_lock_irqsave(&zone->lock, flags);
> > @@ -2102,10 +2109,12 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
> >  			set_pageblock_migratetype(page, ac->migratetype);
> >  			move_freepages_block(zone, page, ac->migratetype);
> >  			spin_unlock_irqrestore(&zone->lock, flags);
> > -			return;
> > +			return true;
> 
> Such cut-off makes reserved pageblock remained before the OOM.
> We call it as premature OOM kill.

Not sure I understand. The above should get rid of all atomic reserves
before we go OOM. We can do it all at once but that sounds too
aggressive to me. If we just do one at the time we have a chance to
keep some reserves if the OOM situation is really ephemeral.

Does this patch work in your usecase?

> If you feel it's rather complex, simply, we can drain *every*
> reserved pages when no_progress_loops is greater than MAX_RECLAIM_RETRIES.
> Do you want it?
> 
> It's rather conservative approach to keep highatomic pageblocks.
> Anyway, I think it's matter of policy and my goal is just to use up
> every reserved pageblock before OOM so anyone never say
> "Hey, enough free pages which is greater than min watermark but
> why I should see the OOM with GFP_KERNEL 4K allocation".

I agree that triggering OOM while we are above min watermarks is less
than optimial and we should think about how to fix it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
