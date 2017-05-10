Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4AF2280730
	for <linux-mm@kvack.org>; Wed, 10 May 2017 03:03:14 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s89so17379782pfk.11
        for <linux-mm@kvack.org>; Wed, 10 May 2017 00:03:14 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d92si1501200pld.304.2017.05.10.00.03.13
        for <linux-mm@kvack.org>;
        Wed, 10 May 2017 00:03:13 -0700 (PDT)
Date: Wed, 10 May 2017 16:03:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] vmscan: scan pages until it founds eligible pages
Message-ID: <20170510070311.GA24772@bbox>
References: <1493700038-27091-1-git-send-email-minchan@kernel.org>
 <20170502051452.GA27264@bbox>
 <20170502075432.GC14593@dhcp22.suse.cz>
 <20170502145150.GA19011@bgram>
 <20170502151436.GN14593@dhcp22.suse.cz>
 <20170503044809.GA21619@bgram>
 <20170503060044.GA1236@dhcp22.suse.cz>
 <20170510014654.GA23584@bbox>
 <20170510061312.GB26158@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170510061312.GB26158@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, kernel-team@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 10, 2017 at 08:13:12AM +0200, Michal Hocko wrote:
> On Wed 10-05-17 10:46:54, Minchan Kim wrote:
> > On Wed, May 03, 2017 at 08:00:44AM +0200, Michal Hocko wrote:
> [...]
> > > @@ -1486,6 +1486,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
> > >  			continue;
> > >  		}
> > >  
> > > +		/*
> > > +		 * Do not count skipped pages because we do want to isolate
> > > +		 * some pages even when the LRU mostly contains ineligible
> > > +		 * pages
> > > +		 */
> > 
> > How about adding comment about "why"?
> > 
> > /*
> >  * Do not count skipped pages because it makes the function to return with
> >  * none isolated pages if the LRU mostly contains inelgible pages so that
> >  * VM cannot reclaim any pages and trigger premature OOM.
> >  */
> 
> I am not sure this is necessarily any better. Mentioning a pre-mature
> OOM would require a much better explanation because a first immediate
> question would be "why don't we scan those pages at priority 0". Also
> decision about the OOM is at a different layer and it might change in
> future when this doesn't apply any more. But it is not like I would
> insist...
> 
> > > +		scan++;
> > >  		switch (__isolate_lru_page(page, mode)) {
> > >  		case 0:
> > >  			nr_pages = hpage_nr_pages(page);
> > 
> > Confirmed.
> 
> Hmm. I can clearly see how we could skip over too many pages and hit
> small reclaim priorities too quickly but I am still scratching my head
> about how we could hit the OOM killer as a result. The amount of pages
> on the active anonymous list suggests that we are not able to rotate
> pages quickly enough. I have to keep thinking about that.

I explained it but seems to be not enouggh. Let me try again.

The problem is that get_scan_count determines nr_to_scan with
eligible zones.

        size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
        size = size >> sc->priority;

Assumes sc->priority is 0 and LRU list is as follows.

        N-N-N-N-H-H-H-H-H-H-H-H-H-H-H-H-H-H-H-H

(Ie, small eligible pages are in the head of LRU but others are
almost ineligible pages)

In that case, size becomes 4 so VM want to scan 4 pages but 4 pages
from tail of the LRU are not eligible pages.
If get_scan_count counts skipped pages, it doesn't reclaim remained
pages after scanning 4 pages.

If it's more helpful to understand the problem, I will add it to
the description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
