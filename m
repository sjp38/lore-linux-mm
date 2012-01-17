Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 2FD666B006E
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 04:14:09 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so1901977vbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jan 2012 01:14:08 -0800 (PST)
Date: Tue, 17 Jan 2012 18:13:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/3] vmscan hook
Message-ID: <20120117091356.GA29736@barrios-desktop.redhat.com>
References: <1326788038-29141-1-git-send-email-minchan@kernel.org>
 <1326788038-29141-3-git-send-email-minchan@kernel.org>
 <20120117173932.1c058ba4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120117173932.1c058ba4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, penberg@kernel.org, Rik van Riel <riel@redhat.com>, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On Tue, Jan 17, 2012 at 05:39:32PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 17 Jan 2012 17:13:57 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > This patch insert memory pressure notify point into vmscan.c
> > Most problem in system slowness is swap-in. swap-in is a synchronous
> > opeartion so that it affects heavily system response.
> > 
> > This patch alert it when reclaimer start to reclaim inactive anon list.
> > It seems rather earlier but not bad than too late.
> > 
> > Other alert point is when there is few cache pages
> > In this implementation, if it is (cache < free pages),
> > memory pressure notify happens. It has to need more testing and tuning
> > or other hueristic. Any suggesion are welcome.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> In my 1st impression, isn't this too simple ?

I agree It's too simple. It would be good start point rather than
unnecessary complicated things.

> 
> 
> > ---
> >  mm/vmscan.c |   28 ++++++++++++++++++++++++++++
> >  1 files changed, 28 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2880396..cfa2e2d 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -43,6 +43,7 @@
> >  #include <linux/sysctl.h>
> >  #include <linux/oom.h>
> >  #include <linux/prefetch.h>
> > +#include <linux/low_mem_notify.h>
> >  
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> > @@ -2082,16 +2083,43 @@ static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
> >  {
> >  	unsigned long nr[NR_LRU_LISTS];
> >  	unsigned long nr_to_scan;
> > +
> >  	enum lru_list lru;
> >  	unsigned long nr_reclaimed, nr_scanned;
> >  	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
> >  	struct blk_plug plug;
> > +#ifdef CONFIG_LOW_MEM_NOTIFY
> > +	bool low_mem = false;
> > +	unsigned long free, file;
> > +#endif
> >  
> >  restart:
> >  	nr_reclaimed = 0;
> >  	nr_scanned = sc->nr_scanned;
> >  	get_scan_count(mz, sc, nr, priority);
> > +#ifdef CONFIG_LOW_MEM_NOTIFY
> > +	/* We want to avoid swapout */
> > +	if (nr[LRU_INACTIVE_ANON])
> > +		low_mem = true;
> 
> IIUC, nr[LRU_INACTIVE_ANON] can be easily > 0.

Yes. But I thought it would be better than late notification.
Late notification ends up swap out which is a big concern about this patch.
More proper timing suggestion helps me a lot.

> And get_scan_count() now check per-memcg-lru. So, this only works when
> memcg is not used.

Hmm, I didn't look at recent memcg/global reclaim unify patch of Johannes.
I need time to look at it.
Thanks.

> 
> 
> > +	/*
> > +	 * We want to avoid dropping page cache excessively
> > +	 * in no swap system
> > +	 */
> > +	if (nr_swap_pages <= 0) {
> > +		free = zone_page_state(mz->zone, NR_FREE_PAGES);
> > +		file = zone_page_state(mz->zone, NR_ACTIVE_FILE) +
> > +			zone_page_state(mz->zone, NR_INACTIVE_FILE);
> > +		/*
> > +		 * If we have very few page cache pages,
> > +		 * notify to user
> > +		 */
> > +		if (file < free)
> > +			low_mem = true;
> > +	}
> 
> I can't understand why you think you can check lowmem condition by "file < free".

The reason I thought so is I want to maintain some page cache to some degree.
But I admit It's very naive heuristic and should be improved.

> And I don't think using per-zone data is good.
> (I'm not sure how many zones embeded guys using..)

Agree. In case of swapless system, we need another heuristic.

> 
> Another idea:
> 1. can't we use some technique like cleancache to detect the condition ?

I totally forgot cleancache approach. Could you remind that?

> 2. can't we measure page-in/page-out distance by recording something ?

I can't understand your point. What's relation does it with swapout prevent?

> 3. NR_ANON + NR_FILE_MAPPED can't mean the amount of core memory if we can
>    ignore the data file cache ?

It's good but how do we define some amount?
It's very vague but I guess we can get a good idea from that.
Perhaps, you already has it.

> 4. how about checking kswapd's busy status ?

Could you elaborate on your idea?

Kame, Thanks for reply, 

> 
> 
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
