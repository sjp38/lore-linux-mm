Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5586B005A
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 06:39:17 -0400 (EDT)
Date: Wed, 10 Jun 2009 11:40:26 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/4] Count the number of times zone_reclaim() scans and
	fails
Message-ID: <20090610104025.GJ25943@csn.ul.ie>
References: <1244566904-31470-1-git-send-email-mel@csn.ul.ie> <1244566904-31470-4-git-send-email-mel@csn.ul.ie> <20090610021028.GA6597@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090610021028.GA6597@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 10:10:28AM +0800, Wu Fengguang wrote:
> On Wed, Jun 10, 2009 at 01:01:43AM +0800, Mel Gorman wrote:
> > On NUMA machines, the administrator can configure zone_reclaim_mode that
> > is a more targetted form of direct reclaim. On machines with large NUMA
> > distances for example, a zone_reclaim_mode defaults to 1 meaning that clean
> > unmapped pages will be reclaimed if the zone watermarks are not being met.
> > 
> > There is a heuristic that determines if the scan is worthwhile but it is
> > possible that the heuristic will fail and the CPU gets tied up scanning
> > uselessly. Detecting the situation requires some guesswork and experimentation
> > so this patch adds a counter "zreclaim_failed" to /proc/vmstat. If during
> > high CPU utilisation this counter is increasing rapidly, then the resolution
> > to the problem may be to set /proc/sys/vm/zone_reclaim_mode to 0.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/vmstat.h |    3 +++
> >  mm/vmscan.c            |    4 ++++
> >  mm/vmstat.c            |    3 +++
> >  3 files changed, 10 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> > index ff4696c..416f748 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -36,6 +36,9 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> >  		FOR_ALL_ZONES(PGSTEAL),
> >  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
> >  		FOR_ALL_ZONES(PGSCAN_DIRECT),
> > +#ifdef CONFIG_NUMA
> > +		PGSCAN_ZONERECLAIM_FAILED,
> > +#endif
> 
> I'd rather to refine the zone accounting (ie. mapped tmpfs pages)
> so that we know whether a zone scan is going to be fruitless.  Then
> we can get rid of the remedy patches 3 and 4.
> 

This patch is not a remedy patch as such. tmpfs might not be the only
trigger case for thie zone_reclaim() excessive scan problem. In the
event it's occuring, we want to be able to pinpoint better why we are
spinning at 100% CPU. It's to reduce the debug time if/when this problem
is encountered.

On the mapped tmpfs page accounting, I mentioned the problems I see with
this in another mail. It would alter a number of paths, particularly the
page cache add/remove paths to maintain the counters we need to avoid
tmpfs in this slow NUMA-specific path. I'm hoping that can be avoided.

> We don't have to worry about swap cache pages accounted as file pages.
> Since there are no double accounting in NR_FILE_PAGES for tmpfs pages.
> 
> We don't have to worry about MLOCKED pages, because they may defeat
> the estimation temporarily, but after one or several more zone scans,
> MLOCKED pages will go to the unevictable list, hence this cause of
> zone reclaim failure won't be persistent.
> 
> Any more known accounting holes?
> 

Not that I'm aware of but if/when they show up, I'd like to be able to
detect the situation easily, hence this patch.

> Thanks,
> Fengguang
> 
> >  		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> >  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> >  #ifdef CONFIG_HUGETLB_PAGE
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index e862fc9..8be4582 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2489,6 +2489,10 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> >  	ret = __zone_reclaim(zone, gfp_mask, order);
> >  	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
> >  
> > +	if (!ret) {
> > +		count_vm_events(PGSCAN_ZONERECLAIM_FAILED, 1);
> > +	}
> > +
> >  	return ret;
> >  }
> >  #endif
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 1e3aa81..02677d1 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -673,6 +673,9 @@ static const char * const vmstat_text[] = {
> >  	TEXTS_FOR_ZONES("pgscan_kswapd")
> >  	TEXTS_FOR_ZONES("pgscan_direct")
> >  
> > +#ifdef CONFIG_NUMA
> > +	"zreclaim_failed",
> > +#endif
> >  	"pginodesteal",
> >  	"slabs_scanned",
> >  	"kswapd_steal",
> > -- 
> > 1.5.6.5
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
