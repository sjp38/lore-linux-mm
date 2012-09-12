Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3F88A6B010D
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 19:56:51 -0400 (EDT)
Date: Thu, 13 Sep 2012 08:58:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous
 allocation instead of migration
Message-ID: <20120912235855.GB2766@bbox>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
 <20120912130732.99ecf764.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120912130732.99ecf764.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Wed, Sep 12, 2012 at 01:07:32PM -0700, Andrew Morton wrote:
> On Tue, 11 Sep 2012 09:41:52 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > This patch drops clean cache pages instead of migration during
> > alloc_contig_range() to minimise allocation latency by reducing the amount
> > of migration is necessary. It's useful for CMA because latency of migration
> > is more important than evicting the background processes working set.
> > In addition, as pages are reclaimed then fewer free pages for migration
> > targets are required so it avoids memory reclaiming to get free pages,
> > which is a contributory factor to increased latency.
> > 
> > * from v1
> >   * drop migrate_mode_t
> >   * add reclaim_clean_pages_from_list instad of MIGRATE_DISCARD support - Mel
> > 
> > I measured elapsed time of __alloc_contig_migrate_range which migrates
> > 10M in 40M movable zone in QEMU machine.
> > 
> > Before - 146ms, After - 7ms
> > 
> > ...
> >
> > @@ -758,7 +760,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			wait_on_page_writeback(page);
> >  		}
> >  
> > -		references = page_check_references(page, sc);
> > +		if (!force_reclaim)
> > +			references = page_check_references(page, sc);
> 
> grumble.  Could we please document `enum page_references' and
> page_check_references()?
> 
> And the `force_reclaim' arg could do with some documentation.  It only
> forces reclaim under certain circumstances.  They should be described,
> and a reson should be provided.

I will give it a shot by another patch.

> 
> Why didn't this patch use PAGEREF_RECLAIM_CLEAN?  It is possible for
> someone to dirty one of these pages after we tested its cleanness and
> we'll then go off and write it out, but we won't be reclaiming it?

Absolutely.
Thanks Andrew!

Here it goes.

====== 8< ======
