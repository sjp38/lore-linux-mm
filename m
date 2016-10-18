Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB446B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:29:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id l29so127804909pfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 23:29:54 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f74si34117070pfe.260.2016.10.17.23.29.52
        for <linux-mm@kvack.org>;
        Mon, 17 Oct 2016 23:29:53 -0700 (PDT)
Date: Tue, 18 Oct 2016 15:29:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: exclude isolated non-lru pages from
 NR_ISOLATED_ANON or NR_ISOLATED_FILE.
Message-ID: <20161018062950.GA18818@bbox>
References: <20161014083219.GA20260@spreadtrum.com>
 <20161014113044.GB6063@dhcp22.suse.cz>
 <20161014134604.GA2179@blaptop>
 <20161014135334.GF6063@dhcp22.suse.cz>
 <20161014144448.GA2899@blaptop>
 <20161014150355.GH6063@dhcp22.suse.cz>
 <20161014152633.GA3157@blaptop>
 <20161015071044.GC9949@dhcp22.suse.cz>
 <20161016230618.GB9196@bbox>
 <20161017084244.GF23322@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017084244.GF23322@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ming Ling <ming.ling@spreadtrum.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, hannes@cmpxchg.org, baiyaowei@cmss.chinamobile.com, iamjoonsoo.kim@lge.com, rientjes@google.com, hughd@google.com, kirill.shutemov@linux.intel.com, riel@redhat.com, mgorman@suse.de, aquini@redhat.com, corbet@lwn.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, orson.zhai@spreadtrum.com, geng.ren@spreadtrum.com, chunyan.zhang@spreadtrum.com, zhizhou.tian@spreadtrum.com, yuming.han@spreadtrum.com, xiajing@spreadst.com

On Mon, Oct 17, 2016 at 10:42:45AM +0200, Michal Hocko wrote:
> On Mon 17-10-16 08:06:18, Minchan Kim wrote:
> > Hi Michal,
> > 
> > On Sat, Oct 15, 2016 at 09:10:45AM +0200, Michal Hocko wrote:
> > > On Sat 15-10-16 00:26:33, Minchan Kim wrote:
> > > > On Fri, Oct 14, 2016 at 05:03:55PM +0200, Michal Hocko wrote:
> > > [...]
> > > > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > > > index 0409a4ad6ea1..6584705a46f6 100644
> > > > > --- a/mm/compaction.c
> > > > > +++ b/mm/compaction.c
> > > > > @@ -685,7 +685,8 @@ static bool too_many_isolated(struct zone *zone)
> > > > >   */
> > > > >  static unsigned long
> > > > >  isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > > > > -			unsigned long end_pfn, isolate_mode_t isolate_mode)
> > > > > +			unsigned long end_pfn, isolate_mode_t isolate_mode,
> > > > > +			unsigned long *isolated_file, unsigned long *isolated_anon)
> > > > >  {
> > > > >  	struct zone *zone = cc->zone;
> > > > >  	unsigned long nr_scanned = 0, nr_isolated = 0;
> > > > > @@ -866,6 +867,10 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
> > > > >  
> > > > >  		/* Successfully isolated */
> > > > >  		del_page_from_lru_list(page, lruvec, page_lru(page));
> > > > > +		if (page_is_file_cache(page))
> > > > > +			(*isolated_file)++;
> > > > > +		else
> > > > > +			(*isolated_anon)++;
> > > > >  
> > > > >  isolate_success:
> > > > >  		list_add(&page->lru, &cc->migratepages);
> > > > > 
> > > > > Makes more sense?
> > > > 
> > > > It is doable for isolation part. IOW, maybe we can make acct_isolated
> > > > simple with those counters but we need to handle migrate, putback part.
> > > > If you want to remove the check of __PageMoable with those counter, it
> > > > means we should pass the counter on every functions related migration
> > > > where isolate, migrate, putback parts.
> > > 
> > > OK, I see. Can we just get rid of acct_isolated altogether? Why cannot
> > > we simply update NR_ISOLATED_* while isolating pages? Just looking at
> > > isolate_migratepages_block:
> > > 			acct_isolated(zone, cc);
> > > 			putback_movable_pages(&cc->migratepages);
> > > 
> > > suggests we are doing something suboptimal. I guess we cannot get rid of
> > > __PageMoveble checks which is sad because that just adds a lot of
> > > confusion because checking for !__PageMovable(page) for LRU pages is
> > > just a head scratcher (LRU pages are movable arent' they?). Maybe it
> > > would be even good to get rid of this misnomer. PageNonLRUMovable?
> > 
> > Yeah, I hated the naming but didn't have a good idea.
> > PageNonLRUMovable, definitely, one I thought as candidate but dropped
> > by lenghthy naming. If others don't object, I am happy to change it.
> 
> Yes it is long but it is less confusing because it is just utterly
> confusing to test for LRU pages with !__PageMovable when in fact they
> are movable. Heck even unreclaimable pages are movable unless explicitly
> configured to not be.
>  
> > > Anyway, I would suggest to do something like this. Batching NR_ISOLATED*
> > > just doesn't make all that much sense as these are per-cpu and the
> > > resulting code seems to be easier without it.
> > 
> > Agree. Could you resend it as formal patch?
> 
> Sure, what do you think about the following? I haven't marked it for
> stable because there was no bug report for it AFAIU.
> ---
> From 3b2bd4486f36ada9f6dc86d3946855281455ba9f Mon Sep 17 00:00:00 2001
> From: Ming Ling <ming.ling@spreadtrum.com>
> Date: Mon, 17 Oct 2016 10:26:50 +0200
> Subject: [PATCH] mm, compaction: fix NR_ISOLATED_* stats for pfn based
>  migration
> 
> Since bda807d44454 ("mm: migrate: support non-lru movable page
> migration") isolate_migratepages_block) can isolate !PageLRU pages which
> would acct_isolated account as NR_ISOLATED_*. Accounting these non-lru
> pages NR_ISOLATED_{ANON,FILE} doesn't make any sense and it can misguide
> heuristics based on those counters such as pgdat_reclaimable_pages resp.
> too_many_isolated which would lead to unexpected stalls during the
> direct reclaim without any good reason. Note that
> __alloc_contig_migrate_range can isolate a lot of pages at once.
> 
> On mobile devices such as 512M ram android Phone, it may use a big zram
> swap. In some cases zram(zsmalloc) uses too many non-lru but migratedable
> pages, such as:
> 
>       MemTotal: 468148 kB
>       Normal free:5620kB
>       Free swap:4736kB
>       Total swap:409596kB
>       ZRAM: 164616kB(zsmalloc non-lru pages)
>       active_anon:60700kB
>       inactive_anon:60744kB
>       active_file:34420kB
>       inactive_file:37532kB
> 
> Fix this by only accounting lru pages to NR_ISOLATED_* in
> isolate_migratepages_block right after they were isolated and we still
> know they were on LRU. Drop acct_isolated because it is called after the
> fact and we've lost that information. Batching per-cpu counter doesn't
> make much improvement anyway. Also make sure that we uncharge only LRU
> pages when putting them back on the LRU in putback_movable_pages resp.
> when unmap_and_move migrates the page.
> 
> Fixes: bda807d44454 ("mm: migrate: support non-lru movable page migration")
> Signed-off-by: Ming Ling <ming.ling@spreadtrum.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Minchan Kim <minchan@kernel.org>

with folding other fix patch you posted.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
