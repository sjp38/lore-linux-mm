Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id E6A4A6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 19:04:58 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so1036217pbc.14
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 16:04:58 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id pk8si30797693pab.10.2014.02.05.16.04.56
        for <linux-mm@kvack.org>;
        Wed, 05 Feb 2014 16:04:58 -0800 (PST)
Date: Thu, 6 Feb 2014 09:05:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch v2] mm, compaction: avoid isolating pinned pages
Message-ID: <20140206000504.GA17465@lge.com>
References: <20140203095329.GH6732@suse.de>
 <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
 <20140204000237.GA17331@lge.com>
 <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com>
 <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com>
 <20140204021533.GA14924@lge.com>
 <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com>
 <alpine.LSU.2.11.1402051232530.3440@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402051232530.3440@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 05, 2014 at 12:56:40PM -0800, Hugh Dickins wrote:
> On Tue, 4 Feb 2014, David Rientjes wrote:
> 
> > Page migration will fail for memory that is pinned in memory with, for
> > example, get_user_pages().  In this case, it is unnecessary to take
> > zone->lru_lock or isolating the page and passing it to page migration
> > which will ultimately fail.
> > 
> > This is a racy check, the page can still change from under us, but in
> > that case we'll just fail later when attempting to move the page.
> > 
> > This avoids very expensive memory compaction when faulting transparent
> > hugepages after pinning a lot of memory with a Mellanox driver.
> > 
> > On a 128GB machine and pinning ~120GB of memory, before this patch we
> > see the enormous disparity in the number of page migration failures
> > because of the pinning (from /proc/vmstat):
> > 
> > 	compact_pages_moved 8450
> > 	compact_pagemigrate_failed 15614415
> > 
> > 0.05% of pages isolated are successfully migrated and explicitly 
> > triggering memory compaction takes 102 seconds.  After the patch:
> > 
> > 	compact_pages_moved 9197
> > 	compact_pagemigrate_failed 7
> > 
> > 99.9% of pages isolated are now successfully migrated in this 
> > configuration and memory compaction takes less than one second.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  v2: address page count issue per Joonsoo
> > 
> >  mm/compaction.c | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -578,6 +578,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >  			continue;
> >  		}
> >  
> > +		/*
> > +		 * Migration will fail if an anonymous page is pinned in memory,
> > +		 * so avoid taking lru_lock and isolating it unnecessarily in an
> > +		 * admittedly racy check.
> > +		 */
> > +		if (!page_mapping(page) &&
> > +		    page_count(page) > page_mapcount(page))
> > +			continue;
> > +
> >  		/* Check if it is ok to still hold the lock */
> >  		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> 
> Much better, maybe good enough as an internal patch to fix a particular
> problem you're seeing; but not yet good enough to go upstream.
> 
> Anonymous pages are not the only pages which might be pinned,
> and your test doesn't mention PageAnon, so does not match your comment.
> 
> I've remembered is_page_cache_freeable() in mm/vmscan.c, which gives
> more assurance that a page_count - page_has_private test is appropriate,
> whatever the filesystem and migrate method to be used.
> 
> So I think the test you're looking for is
> 
> 		pincount = page_count(page) - page_mapcount(page);
> 		if (page_mapping(page))
> 			pincount -= 1 + page_has_private(page);
> 		if (pincount > 0)
> 			continue;
> 
> but please cross-check and test that out, it's easy to be off-by-one etc.

Hello, Hugh.

I don't think that this is right.
One of migratepage function, aio_migratepage(), pass extra count 1 to
migrate_page_move_mapping(). So it can be migrated when pincount == 1 in
above test.

I think that we should not be aggressive here. This is just for prediction
so that it is better not to skip apropriate pages at most. Just for anon case
that we are sure easily is the right solution for me.

Thanks.

> 
> For a moment I thought a PageWriteback test would be useful too,
> but no, that should already appear in the pincount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
