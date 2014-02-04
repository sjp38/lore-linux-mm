Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DF0AD6B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:02:39 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so7711692pab.7
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:02:39 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id zk9si22318711pac.144.2014.02.03.16.02.37
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 16:02:38 -0800 (PST)
Date: Tue, 4 Feb 2014 09:02:37 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [patch] mm, compaction: avoid isolating pinned pages
Message-ID: <20140204000237.GA17331@lge.com>
References: <alpine.DEB.2.02.1402012145510.2593@chino.kir.corp.google.com>
 <20140203095329.GH6732@suse.de>
 <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402030231590.31061@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 03, 2014 at 02:49:32AM -0800, David Rientjes wrote:
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

Hello,

I think that you need more code to skip this type of page correctly.
Without page_mapped() check, this code makes migratable pages be skipped,
since if page_mapped() case, page_count() may be more than zero.

So I think that you need following change.

(!page_mapping(page) && !page_mapped(page) && page_count(page))

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
