Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 25C2C6B0035
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 05:49:36 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so6951007pbc.33
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 02:49:35 -0800 (PST)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id ds4si20064154pbb.349.2014.02.03.02.49.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 02:49:34 -0800 (PST)
Received: by mail-pb0-f42.google.com with SMTP id jt11so6941698pbb.29
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 02:49:34 -0800 (PST)
Date: Mon, 3 Feb 2014 02:49:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages
In-Reply-To: <20140203095329.GH6732@suse.de>
Message-ID: <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com> <20140203095329.GH6732@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 3 Feb 2014, Mel Gorman wrote:

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
> > compact_blocks_moved 7609
> > compact_pages_moved 3431
> > compact_pagemigrate_failed 133219
> > compact_stall 13
> > 
> > After the patch, it is much more efficient:
> > 
> > compact_blocks_moved 7998
> > compact_pages_moved 6403
> > compact_pagemigrate_failed 3
> > compact_stall 15
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  mm/compaction.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -578,6 +578,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >  			continue;
> >  		}
> >  
> > +		/*
> > +		 * Migration will fail if an anonymous page is pinned in memory,
> > +		 * so avoid taking zone->lru_lock and isolating it unnecessarily
> > +		 * in an admittedly racy check.
> > +		 */
> > +		if (!page_mapping(page) && page_count(page))
> > +			continue;
> > +
> 
> Are you sure about this? The page_count check migration does is this
> 
>         int expected_count = 1 + extra_count;
>         if (!mapping) {
>                 if (page_count(page) != expected_count)
>                         return -EAGAIN;
>                 return MIGRATEPAGE_SUCCESS;
>         }
> 
>         spin_lock_irq(&mapping->tree_lock);
> 
>         pslot = radix_tree_lookup_slot(&mapping->page_tree,
>                                         page_index(page));
> 
>         expected_count += 1 + page_has_private(page);
> 
> Migration expects and can migrate pages with no mapping and a page count
> but you are now skipping them. I think you may have intended to split
> migrations page count into a helper or copy the logic.
> 

Thanks for taking a look!

The patch is correct, it just shows my lack of a complete commit message 
which I'm struggling with recently.  In the case that this is addressing, 
get_user_pages() already gives page_count(page) == 1, then 
__isolate_lru_page() does another get_page() that is dropped in 
putback_lru_page() after the call into migrate_pages().  So in the code 
you quote above we always have page_count(page) == 2 and
expected_count == 1.

So what we desperately need to do is avoid isolating any page where 
page_count(page) is non-zero and !page_mapping(page) and do that before 
the get_page() in __isolate_lru_page() because we want to avoid taking 
zone->lru_lock.  On my 128GB machine filled with ~120GB of pinned memory 
for the driver, this lock gets highly contended under compaction and even 
reclaim if the rest of userspace is using a lot of memory.

It's not really relevant to the commit message, but I found that if all 
that ~120GB is faulted and I manually invoke compaction with the procfs 
trigger (with my fix to do cc.ignore_skip_hint = true), this lock gets 
taken ~450,000 times and only 0.05% of isolated pages are actually 
successfully migrated.

Deferred compaction will certainly help for compaction that isn't induced 
via procfs, but we've encountered massive amounts of lock contention in 
this path and extremely low success to failure ratios of page migration on 
average of 2-3 out of 60 runs and the fault path really does grind to a 
halt without this patch (or simply doing MADV_NOHUGEPAGE before the driver 
does ib_umem_get() for 120GB of memory, but we want those hugepages!).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
