Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id F0A036B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 20:16:53 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so1090186pbc.12
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 17:16:53 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id i8si30916795pav.277.2014.02.05.17.16.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 17:16:52 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so1047722pab.38
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 17:16:52 -0800 (PST)
Date: Wed, 5 Feb 2014 17:16:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch v2] mm, compaction: avoid isolating pinned pages
In-Reply-To: <20140206000504.GA17465@lge.com>
Message-ID: <alpine.LSU.2.11.1402051647360.28926@eggly.anvils>
References: <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com> <20140204000237.GA17331@lge.com> <alpine.DEB.2.02.1402031610090.10778@chino.kir.corp.google.com> <20140204015332.GA14779@lge.com>
 <alpine.DEB.2.02.1402031755440.26347@chino.kir.corp.google.com> <20140204021533.GA14924@lge.com> <alpine.DEB.2.02.1402031848290.15032@chino.kir.corp.google.com> <alpine.DEB.2.02.1402041842100.14045@chino.kir.corp.google.com> <alpine.LSU.2.11.1402051232530.3440@eggly.anvils>
 <20140206000504.GA17465@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 6 Feb 2014, Joonsoo Kim wrote:
> On Wed, Feb 05, 2014 at 12:56:40PM -0800, Hugh Dickins wrote:
> > On Tue, 4 Feb 2014, David Rientjes wrote:
> > 
> > > Page migration will fail for memory that is pinned in memory with, for
> > > example, get_user_pages().  In this case, it is unnecessary to take
> > > zone->lru_lock or isolating the page and passing it to page migration
> > > which will ultimately fail.
> > > 
> > > This is a racy check, the page can still change from under us, but in
> > > that case we'll just fail later when attempting to move the page.
> > > 
> > > This avoids very expensive memory compaction when faulting transparent
> > > hugepages after pinning a lot of memory with a Mellanox driver.
> > > 
> > > On a 128GB machine and pinning ~120GB of memory, before this patch we
> > > see the enormous disparity in the number of page migration failures
> > > because of the pinning (from /proc/vmstat):
> > > 
> > > 	compact_pages_moved 8450
> > > 	compact_pagemigrate_failed 15614415
> > > 
> > > 0.05% of pages isolated are successfully migrated and explicitly 
> > > triggering memory compaction takes 102 seconds.  After the patch:
> > > 
> > > 	compact_pages_moved 9197
> > > 	compact_pagemigrate_failed 7
> > > 
> > > 99.9% of pages isolated are now successfully migrated in this 
> > > configuration and memory compaction takes less than one second.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > ---
> > >  v2: address page count issue per Joonsoo
> > > 
> > >  mm/compaction.c | 9 +++++++++
> > >  1 file changed, 9 insertions(+)
> > > 
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -578,6 +578,15 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > >  			continue;
> > >  		}
> > >  
> > > +		/*
> > > +		 * Migration will fail if an anonymous page is pinned in memory,
> > > +		 * so avoid taking lru_lock and isolating it unnecessarily in an
> > > +		 * admittedly racy check.
> > > +		 */
> > > +		if (!page_mapping(page) &&
> > > +		    page_count(page) > page_mapcount(page))
> > > +			continue;
> > > +
> > >  		/* Check if it is ok to still hold the lock */
> > >  		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
> > 
> > Much better, maybe good enough as an internal patch to fix a particular
> > problem you're seeing; but not yet good enough to go upstream.
> > 
> > Anonymous pages are not the only pages which might be pinned,
> > and your test doesn't mention PageAnon, so does not match your comment.
> > 
> > I've remembered is_page_cache_freeable() in mm/vmscan.c, which gives
> > more assurance that a page_count - page_has_private test is appropriate,
> > whatever the filesystem and migrate method to be used.
> > 
> > So I think the test you're looking for is
> > 
> > 		pincount = page_count(page) - page_mapcount(page);
> > 		if (page_mapping(page))
> > 			pincount -= 1 + page_has_private(page);
> > 		if (pincount > 0)
> > 			continue;
> > 
> > but please cross-check and test that out, it's easy to be off-by-one etc.
> 
> Hello, Hugh.
> 
> I don't think that this is right.
> One of migratepage function, aio_migratepage(), pass extra count 1 to
> migrate_page_move_mapping(). So it can be migrated when pincount == 1 in
> above test.
> 
> I think that we should not be aggressive here. This is just for prediction
> so that it is better not to skip apropriate pages at most. Just for anon case
> that we are sure easily is the right solution for me.

Interesting, thank you for the pointer.  That's a pity!

I hope that later on we can modify fs/aio.c to set PagePrivate on
ring pages, revert the extra argument to migrate_page_move_mapping(),
and then let it appear the same as the other filesystems (but lacking
a writepage, reclaim won't try to free the pages).

But that's "later on" and may prove impossible in the implementation.
I agree it's beyond the scope of David's patch, and so only anonymous
should be dealt with in this way at present.

And since page_mapping() is non-NULL on PageAnon PageSwapCache pages,
those will fall through David's test and go on to try migration:
which is the correct default.  Although we could add code to handle
pinned swapcache, it would be rather an ugly excrescence, until the case
gets handled naturally when proper page_mapping() support is added later.

Okay, to David's current patch
Acked-by: Hugh Dickins <hughd@google.com>
though I'd like to hear whether Mel is happy with it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
