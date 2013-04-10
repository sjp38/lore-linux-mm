Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 740376B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 09:57:18 -0400 (EDT)
Date: Wed, 10 Apr 2013 14:57:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 04/10] mm: vmscan: Decide whether to compact the pgdat
 based on reclaim progress
Message-ID: <20130410135713.GB3710@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <1365505625-9460-5-git-send-email-mgorman@suse.de>
 <51651D3A.4000301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <51651D3A.4000301@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 10, 2013 at 05:05:14PM +0900, Kamezawa Hiroyuki wrote:
> (2013/04/09 20:06), Mel Gorman wrote:
> > In the past, kswapd makes a decision on whether to compact memory after the
> > pgdat was considered balanced. This more or less worked but it is late to
> > make such a decision and does not fit well now that kswapd makes a decision
> > whether to exit the zone scanning loop depending on reclaim progress.
> > 
> > This patch will compact a pgdat if at least the requested number of pages
> > were reclaimed from unbalanced zones for a given priority. If any zone is
> > currently balanced, kswapd will not call compaction as it is expected the
> > necessary pages are already available.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> I like this way.
> 

Thanks
> > <SNIP>
> > @@ -2873,42 +2895,20 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
> >   		if (try_to_freeze() || kthread_should_stop())
> >   			break;
> >   
> > +		/* Compact if necessary and kswapd is reclaiming efficiently */
> > +		this_reclaimed = sc.nr_reclaimed - nr_reclaimed;
> > +		if (pgdat_needs_compaction && this_reclaimed > nr_attempted)
> > +			compact_pgdat(pgdat, order);
> > +
> 
> What does "this_reclaimed" mean ?   
> "the total amount of reclaimed memory - reclaimed memory at this iteration" ?
> 

It's meant to be "reclaimed memory at this iteration" but I made a merge
error when I decided to reset sc.nr_reclaimed to 0 on every loop in the patch
"mm: vmscan: Flatten kswapd priority loop". Once I did that, nr_reclaimed
became redundant and should have been removed. I've done that now.

> And this_reclaimed > nr_attempted means kswapd is efficient ?
> What "efficient" means here ?
> 

Reclaim efficiency is normally the ratio between pages scanned and pages
reclaimed. Ideally, every page scanned is reclaimed. In this case, being
efficient means that we reclaimed at least the number of pages requested
which is sc->nr_to_reclaim which in the case of kswapd is the high
watermark. I changed the comment to

                /*
                 * Compact if necessary and kswapd is reclaiming at least the
                 * high watermark number of pages as requested
                 */

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
