Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9176B0032
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 04:23:06 -0400 (EDT)
Received: by wigg3 with SMTP id g3so69026703wig.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 01:23:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fn5si17057879wib.71.2015.06.15.01.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Jun 2015 01:23:04 -0700 (PDT)
Date: Mon, 15 Jun 2015 09:22:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/25] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20150615082259.GL26425@suse.de>
References: <00fe01d0a41c$5f242bf0$1d6c83d0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <00fe01d0a41c$5f242bf0$1d6c83d0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Thu, Jun 11, 2015 at 03:58:14PM +0800, Hillf Danton wrote:
> > @@ -1319,6 +1322,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  	struct list_head *src = &lruvec->lists[lru];
> >  	unsigned long nr_taken = 0;
> >  	unsigned long scan;
> > +	LIST_HEAD(pages_skipped);
> > 
> >  	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
> >  		struct page *page;
> > @@ -1329,6 +1333,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > 
> >  		VM_BUG_ON_PAGE(!PageLRU(page), page);
> > 
> > +		if (page_zone_id(page) > sc->reclaim_idx)
> > +			list_move(&page->lru, &pages_skipped);
> > +
> >  		switch (__isolate_lru_page(page, mode)) {
> >  		case 0:
> >  			nr_pages = hpage_nr_pages(page);
> > @@ -1347,6 +1354,15 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> >  		}
> >  	}
> > 
> > +	/*
> > +	 * Splice any skipped pages to the start of the LRU list. Note that
> > +	 * this disrupts the LRU order when reclaiming for lower zones but
> > +	 * we cannot splice to the tail. If we did then the SWAP_CLUSTER_MAX
> > +	 * scanning would soon rescan the same pages to skip and put the
> > +	 * system at risk of premature OOM.
> > +	 */
> > +	if (!list_empty(&pages_skipped))
> > +		list_splice(&pages_skipped, src);
> >  	*nr_scanned = scan;
> >  	trace_mm_vmscan_lru_isolate(sc->order, nr_to_scan, scan,
> >  				    nr_taken, mode, is_file_lru(lru));
> 
> Can we avoid splicing pages by skipping pages with scan not incremented?
> 

The reclaimers would still have to do the work of examining those pages
and ignoring them even if the counters are not updated. It'll look like
high CPU usage for no obvious reason.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
