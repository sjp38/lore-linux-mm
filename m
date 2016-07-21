Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2686828FF
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:31:39 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so127031198pab.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:31:39 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h12si8467914pag.125.2016.07.21.01.31.38
        for <linux-mm@kvack.org>;
        Thu, 21 Jul 2016 01:31:39 -0700 (PDT)
Date: Thu, 21 Jul 2016 17:31:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/5] mm, vmscan: Do not account skipped pages as scanned
Message-ID: <20160721083151.GA8356@bbox>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-2-git-send-email-mgorman@techsingularity.net>
 <20160721051648.GA31865@bbox>
 <20160721081506.GF10438@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <20160721081506.GF10438@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 09:15:06AM +0100, Mel Gorman wrote:
> On Thu, Jul 21, 2016 at 02:16:48PM +0900, Minchan Kim wrote:
> > On Wed, Jul 20, 2016 at 04:21:47PM +0100, Mel Gorman wrote:
> > > Page reclaim determines whether a pgdat is unreclaimable by examining how
> > > many pages have been scanned since a page was freed and comparing that
> > > to the LRU sizes. Skipped pages are not considered reclaim candidates but
> > > contribute to scanned. This can prematurely mark a pgdat as unreclaimable
> > > and trigger an OOM kill.
> > > 
> > > While this does not fix an OOM kill message reported by Joonsoo Kim,
> > > it did stop pgdat being marked unreclaimable.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > > ---
> > >  mm/vmscan.c | 5 ++++-
> > >  1 file changed, 4 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 22aec2bcfeec..b16d578ce556 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -1415,7 +1415,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > >  	LIST_HEAD(pages_skipped);
> > >  
> > >  	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> > > -					!list_empty(src); scan++) {
> > > +					!list_empty(src);) {
> > >  		struct page *page;
> > >  
> > >  		page = lru_to_page(src);
> > > @@ -1429,6 +1429,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > >  			continue;
> > >  		}
> > >  
> > > +		/* Pages skipped do not contribute to scan */
> > 
> > The comment should explain why.
> > 
> > /* Pages skipped do not contribute to scan to prevent premature OOM */
> > 
> 
> Specifically, it's to prevent pgdat being considered unreclaimable
> prematurely. I'll update the comment.
> 
> > 
> > > +		scan++;
> > > +
> > 
> > 
> > The one of my concern about node-lru is to add more lru lock contetion
> > in multiple zone system so such unbounded skip scanning under the lock
> > should have a limit to prevent latency spike and serialization of
> > current reclaim work.
> > 
> 
> The LRU lock already was quite a large lock, particularly on NUMA systems,
> with contention raising the more direct reclaimers that are active. It's
> worth remembering that the series also shows much lower system CPU time
> in some tests. This is the current CPU usage breakdown for a parallel dd test
> 
>            4.7.0-rc4   4.7.0-rc7   4.7.0-rc7
>         mmotm-20160623mm1-followup-v3r1mm1-oomfix-v4r2
> User         1548.01      927.23      777.74
> System       8609.71     5540.02     4445.56
> Elapsed      3587.10     3598.00     3498.54
> 
> The LRU lock is held during skips but it's also doing no real work.

If the inactive LRU list is almost full with higher zone pages,
the unbounded scanning under lru_lock would be disaster because
other reclaimer can be stucked with lru-lock.

With [1/5], testing was slower 100 times(To be honest, I should give
up seeing ending of test). That's why I tested this series without [1/5].

> 
> > Another concern is big mismatch between the number of pages from list and
> > LRU stat count because lruvec_lru_size call sites don't take the stat
> > under the lock while isolate_lru_pages moves many pages from lru list
> > to temporal skipped list.
> > 
> 
> It's already known that the reading of the LRU size can mismatch the
> actual size. It's why inactive_list_is_low() in the last patch has
> checks like
> 
> inactive -= min(inactive, inactive_zone);
> 
> It's watching for underflows
> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
