Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED286B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 19:45:35 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t61so1866819wes.28
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 16:45:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hq3si11427400wib.38.2014.02.06.05.54.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 05:55:07 -0800 (PST)
Date: Thu, 6 Feb 2014 13:53:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch v2] mm, compaction: avoid isolating pinned pages
Message-ID: <20140206135337.GV6732@suse.de>
References: <20140204000237.GA17331@lge.com>
 <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com>
 <20140204015332.GA14779@lge.com>
 <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com>
 <20140204021533.GA14924@lge.com>
 <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com>
 <alpine.LSU.2.11.1402051232530.3440@eggly.anvils>
 <20140206000504.GA17465@lge.com>
 <alpine.LSU.2.11.1402051647360.28926@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402051647360.28926@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 05, 2014 at 05:16:06PM -0800, Hugh Dickins wrote:
> On Thu, 6 Feb 2014, Joonsoo Kim wrote:
> > On Wed, Feb 05, 2014 at 12:56:40PM -0800, Hugh Dickins wrote:
> > > On Tue, 4 Feb 2014, David Rientjes wrote:
> > > 
> > > > Page migration will fail for memory that is pinned in memory with, for
> > > > example, get_user_pages().  In this case, it is unnecessary to take
> > > > zone->lru_lock or isolating the page and passing it to page migration
> > > > which will ultimately fail.
> > > > 
> > > > This is a racy check, the page can still change from under us, but in
> > > > that case we'll just fail later when attempting to move the page.
> > > > 
> > > > This avoids very expensive memory compaction when faulting transparent
> > > > hugepages after pinning a lot of memory with a Mellanox driver.
> > > > 
> > > > On a 128GB machine and pinning ~120GB of memory, before this patch we
> > > > see the enormous disparity in the number of page migration failures
> > > > because of the pinning (from /proc/vmstat):
> > > > 
> > > > 	compact_pages_moved 8450
> > > > 	compact_pagemigrate_failed 15614415
> > > > 
> > > > 0.05% of pages isolated are successfully migrated and explicitly 
> > > > triggering memory compaction takes 102 seconds.  After the patch:
> > > > 
> > > > 	compact_pages_moved 9197
> > > > 	compact_pagemigrate_failed 7
> > > > 
> > > > 99.9% of pages isolated are now successfully migrated in this 
> > > > configuration and memory compaction takes less than one second.
> > > > 
> > > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > > ---
> > > >  v2: address page count issue per Joonsoo
> > > > 
> > > >  mm/compaction.c | 9 +++++++++
> > > >  1 file changed, 9 insertions(+)
> > > > 
> > > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > > --- a/mm/compaction.c
> > > > +++ b/mm/compaction.c
> > > > @@ -578,6 +578,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > > >  			continue;
> > > >  		}
> > > >  
> > > > +		/*
> > > > +		 * Migration will fail if an anonymous page is pinned in memory,
> > > > +		 * so avoid taking lru_lock and isolating it unnecessarily in an
> > > > +		 * admittedly racy check.
> > > > +		 */
> > > > +		if (!page_mapping(page) &&
> > > > +		    page_count(page) > page_mapcount(page))
> > > > +			continue;
> > > > +
> > > >  		/* Check if it is ok to still hold the lock */
> > > >  		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> > > 
> > > Much better, maybe good enough as an internal patch to fix a particular
> > > problem you're seeing; but not yet good enough to go upstream.
> > > 
> > > Anonymous pages are not the only pages which might be pinned,
> > > and your test doesn't mention PageAnon, so does not match your comment.
> > > 
> > > I've remembered is_page_cache_freeable() in mm/vmscan.c, which gives
> > > more assurance that a page_count - page_has_private test is appropriate,
> > > whatever the filesystem and migrate method to be used.
> > > 
> > > So I think the test you're looking for is
> > > 
> > > 		pincount = page_count(page) - page_mapcount(page);
> > > 		if (page_mapping(page))
> > > 			pincount -= 1 + page_has_private(page);
> > > 		if (pincount > 0)
> > > 			continue;
> > > 
> > > but please cross-check and test that out, it's easy to be off-by-one etc.
> > 
> > Hello, Hugh.
> > 
> > I don't think that this is right.
> > One of migratepage function, aio_migratepage(), pass extra count 1 to
> > migrate_page_move_mapping(). So it can be migrated when pincount == 1 in
> > above test.
> > 
> > I think that we should not be aggressive here. This is just for prediction
> > so that it is better not to skip apropriate pages at most. Just for anon case
> > that we are sure easily is the right solution for me.
> 
> Interesting, thank you for the pointer.  That's a pity!
> 
> I hope that later on we can modify fs/aio.c to set PagePrivate on
> ring pages, revert the extra argument to migrate_page_move_mapping(),
> and then let it appear the same as the other filesystems (but lacking
> a writepage, reclaim won't try to free the pages).
> 
> But that's "later on" and may prove impossible in the implementation.
> I agree it's beyond the scope of David's patch, and so only anonymous
> should be dealt with in this way at present.
> 
> And since page_mapping() is non-NULL on PageAnon PageSwapCache pages,
> those will fall through David's test and go on to try migration:
> which is the correct default.  Although we could add code to handle
> pinned swapcache, it would be rather an ugly excrescence, until the case
> gets handled naturally when proper page_mapping() support is added later.
> 
> Okay, to David's current patch
> Acked-by: Hugh Dickins <hughd@google.com>
> though I'd like to hear whether Mel is happy with it.
> 

I have nothing useful to add other than

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
