Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id D0ADE6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 21:45:07 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so7844843pbb.17
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:45:07 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id m1si22708704pbe.28.2014.02.03.18.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 18:45:06 -0800 (PST)
Received: by mail-pa0-f54.google.com with SMTP id fa1so7838081pad.41
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 18:45:06 -0800 (PST)
Date: Mon, 3 Feb 2014 18:44:20 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages
In-Reply-To: <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.11.1402031800280.29005@eggly.anvils>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de> <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 3 Feb 2014, David Rientjes wrote:
> On Mon, 3 Feb 2014, Mel Gorman wrote:
> 
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

120GB of memory on the active/inactive lrus but longterm pinned,
that's quite worrying: not just a great waste of time for compaction,
but for page reclaim also.  I suppose a fairly easy way around it would
be for the driver to use mlock too, moving them all to unevictable lru.

But in general, you may well  be right that, racy as this isolation/
migration procedure necessarily is, in the face of longterm pinning it
may make more sense to test page_count before proceding to isolation
rather than only after in migration.  We always took the view that it's
better to give up only at the last moment, but that may be a bad bet.

> > > 
> > > compact_blocks_moved 7609
> > > compact_pages_moved 3431
> > > compact_pagemigrate_failed 133219
> > > compact_stall 13
> > > 
> > > After the patch, it is much more efficient:
> > > 
> > > compact_blocks_moved 7998
> > > compact_pages_moved 6403
> > > compact_pagemigrate_failed 3
> > > compact_stall 15
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > ---
> > >  mm/compaction.c | 8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -578,6 +578,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > >  			continue;
> > >  		}
> > >  
> > > +		/*
> > > +		 * Migration will fail if an anonymous page is pinned in memory,
> > > +		 * so avoid taking zone->lru_lock and isolating it unnecessarily
> > > +		 * in an admittedly racy check.
> > > +		 */
> > > +		if (!page_mapping(page) && page_count(page))
> > > +			continue;
> > > +
> > 
> > Are you sure about this? The page_count check migration does is this
> > 
> >         int expected_count = 1 + extra_count;
> >         if (!mapping) {
> >                 if (page_count(page) != expected_count)
> >                         return -EAGAIN;
> >                 return MIGRATEPAGE_SUCCESS;
> >         }
> > 
> >         spin_lock_irq(&mapping->tree_lock);
> > 
> >         pslot = radix_tree_lookup_slot(&mapping->page_tree,
> >                                         page_index(page));
> > 
> >         expected_count += 1 + page_has_private(page);
> > 
> > Migration expects and can migrate pages with no mapping and a page count
> > but you are now skipping them. I think you may have intended to split
> > migrations page count into a helper or copy the logic.
> > 
> 
> Thanks for taking a look!
> 
> The patch is correct, it just shows my lack of a complete commit message 

I don't think so.  I agree with Mel that you should be reconsidering
those tests that migrate_page_move_mapping() makes, but remembering that
it's called at a stage between try_to_unmap() and remove_migration_ptes(),
when page_mapcount has been brought down to 0 - not the case here.

> which I'm struggling with recently.  In the case that this is addressing, 
> get_user_pages() already gives page_count(page) == 1, then 

But get_user_pages() brings the pages into user address space (if not
already there), page_mapcount 1 and page_count 1, and does an additional
pin on the page, page_count 2.  Or if it's a page_mapping page (perhaps
even PageAnon in SwapCache) there's another +1; if page_has_buffers
another +1; mapped into more user address spaces, +more.

Your	if (!page_mapping(page) && page_count(page))
		continue;
is letting through any Anon SwapCache pages (probably no great concern
in your 120GB example; but I don't understand why you want to special-
case Anon anyway, beyond your specific testcase); and refusing to
isolate all those unpinned anonymous pages mapped into userspace which
migration is perfectly capable of migrating.  If 120GB out of 128GB is
pinned, that won't be a significant proportion, and of course your
change saves a lot of wasted time and lock contention; but for most
people it's a considerable proportion of their memory, and needs to
be migratable.

I think Joonsoo is making the same point (though I disagree with the
test he suggested); but I've not yet read the latest mails under a
separate subject (" fix" appended).

Hugh

> __isolate_lru_page() does another get_page() that is dropped in 
> putback_lru_page() after the call into migrate_pages().  So in the code 
> you quote above we always have page_count(page) == 2 and
> expected_count == 1.
> 
> So what we desperately need to do is avoid isolating any page where 
> page_count(page) is non-zero and !page_mapping(page) and do that before 
> the get_page() in __isolate_lru_page() because we want to avoid taking 
> zone->lru_lock.  On my 128GB machine filled with ~120GB of pinned memory 
> for the driver, this lock gets highly contended under compaction and even 
> reclaim if the rest of userspace is using a lot of memory.
> 
> It's not really relevant to the commit message, but I found that if all 
> that ~120GB is faulted and I manually invoke compaction with the procfs 
> trigger (with my fix to do cc.ignore_skip_hint = true), this lock gets 
> taken ~450,000 times and only 0.05% of isolated pages are actually 
> successfully migrated.
> 
> Deferred compaction will certainly help for compaction that isn't induced 
> via procfs, but we've encountered massive amounts of lock contention in 
> this path and extremely low success to failure ratios of page migration on 
> average of 2-3 out of 60 runs and the fault path really does grind to a 
> halt without this patch (or simply doing MADV_NOHUGEPAGE before the driver 
> does ib_umem_get() for 120GB of memory, but we want those hugepages!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
