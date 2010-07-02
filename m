Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D9A366B01BA
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 02:31:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o626VL6X011856
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Jul 2010 15:31:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83E9845DE54
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:31:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 598E645DE53
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:31:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B6C51DB804C
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:31:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA2BEEF8001
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 15:31:20 +0900 (JST)
Date: Fri, 2 Jul 2010 15:26:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] fs,xfs: Allow kswapd to writeback pages
Message-Id: <20100702152643.36019b4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100701103032.GG31741@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<1277811288-5195-15-git-send-email-mel@csn.ul.ie>
	<20100629123722.GA725@infradead.org>
	<20100629125143.GB31561@csn.ul.ie>
	<20100630091411.49f92cff.kamezawa.hiroyu@jp.fujitsu.com>
	<20100701103032.GG31741@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 1 Jul 2010 11:30:32 +0100
Mel Gorman <mel@csn.ul.ie> wrote:
> > memcg shouldn't
> > depends on it. If so, memcg should depends on some writeback-thread (as kswapd).
> > ok.
> > 
> > Then, my concern here is that which kswapd we should wake up and how it can stop.
> 
> And also what the consequences are of kswapd being occupied with containers
> instead of the global lists for a time.
> 
yes, we may have to add a thread or workqueue for memcg for isolating workloads.


> > IOW, how kswapd can know a memcg has some remaining writeback and struck on it.
> > 
> 
> Another possibility for memcg would be to visit Andrea's suggestion on
> switching stack in more detail. I still haven't gotten around to this as
> phd stuff is sucking up piles of my time.

Sure.

> > One idea is here. (this patch will not work...not tested at all.)
> > If we can have "victim page list" and kswapd can depend on it to know
> > "which pages should be written", kswapd can know when it should work.
> > 
> > cpu usage by memcg will be a new problem...but...
> > 
> > ==
> > Add a new LRU "CLEANING" and make kswapd launder it.
> > This patch also changes PG_reclaim behavior. New PG_reclaim works
> > as
> >  - If PG_reclaim is set, a page is on CLEAINING LIST.
> > 
> > And when kswapd launder a page
> >  - issue an writeback. (I'm thinking whehter I should put this
> >    cleaned page back to CLEANING lru and free it later.) 
> >  - if it can free directly, free it.
> > This just use current shrink_list().
> > 
> > Maybe this patch itself inlcludes many bad point...
> > 
> > ---
> >  fs/proc/meminfo.c         |    2 
> >  include/linux/mm_inline.h |    9 ++
> >  include/linux/mmzone.h    |    7 ++
> >  mm/filemap.c              |    3 
> >  mm/internal.h             |    1 
> >  mm/page-writeback.c       |    1 
> >  mm/page_io.c              |    1 
> >  mm/swap.c                 |   31 ++-------
> >  mm/vmscan.c               |  153 +++++++++++++++++++++++++++++++++++++++++++++-
> >  9 files changed, 176 insertions(+), 32 deletions(-)
> > 
> > Index: mmotm-0611/include/linux/mmzone.h
> > ===================================================================
> > --- mmotm-0611.orig/include/linux/mmzone.h
> > +++ mmotm-0611/include/linux/mmzone.h
> > @@ -85,6 +85,7 @@ enum zone_stat_item {
> >  	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
> >  	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
> >  	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
> > +	NR_CLEANING,		/*  "     "     "   "       "         */
> >  	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
> >  	NR_ANON_PAGES,	/* Mapped anonymous pages */
> >  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
> > @@ -133,6 +134,7 @@ enum lru_list {
> >  	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
> >  	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
> >  	LRU_UNEVICTABLE,
> > +	LRU_CLEANING,

 
> > +static inline int is_cleaning_lru(enum lru_list l)
> > +{
> > +	return (l == LRU_CLEANING);
> > +}
> > +
> 
> Nit - LRU_CLEAN_PENDING might be clearer as CLEANING implies it is currently
> being cleaned (implying it's the same as NR_WRITEBACK) or is definely dirty
> implying it's the same as NR_DIRTY.
> 
ok.

> >  enum zone_watermarks {
> >  	WMARK_MIN,
> >  	WMARK_LOW,
> > Index: mmotm-0611/include/linux/mm_inline.h
> > ===================================================================
> > --- mmotm-0611.orig/include/linux/mm_inline.h
> > +++ mmotm-0611/include/linux/mm_inline.h
> > @@ -56,7 +56,10 @@ del_page_from_lru(struct zone *zone, str
> >  	enum lru_list l;
> >  
> >  	list_del(&page->lru);
> > -	if (PageUnevictable(page)) {
> > +	if (PageReclaim(page)) {
> > +		ClearPageReclaim(page);
> > +		l = LRU_CLEANING;
> > +	} else if (PageUnevictable(page)) {
> >  		__ClearPageUnevictable(page);
> >  		l = LRU_UNEVICTABLE;
> >  	} else {
> 
> One point of note is that having a LRU cleaning list will alter the aging
> of pages quite a bit.
> 
yes.

> A slightly greater concern is that clean pages can be temporarily "lost"
> on the cleaning list. If a direct reclaimer moves pages to the LRU_CLEANING
> list, it's no longer considering those pages even if a flusher thread
> happened to clean those pages before kswapd had a chance. Lets say under
> heavy memory pressure a lot of pages are being dirties and encountered on
> the LRU list. They move to LRU_CLEANING where dirty balancing starts making
> sure they get cleaned but are no longer being reclaimed.
> 
> Of course, I might be wrong but it's not a trivial direction to take.
> 

I hope dirty_ratio at el may help us. But I agree this "hiding" can cause
issue.
IIRC, someone wrote a patch to prevent too many threads enter vmscan..
such kinds of work may be necessary.




> > +/* only called by kswapd to do I/O and put back clean paes to its LRU */
> > +static void shrink_cleaning_list(struct zone *zone)
> > +{

> > +		count_page_types(&page_list, count, 0);
> > +		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
> > +		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
> > +		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
> > +		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
> > +
> > +		nr_freed = shrink_page_list(&page_list, &sc, PAGEOUT_IO_ASYNC);
> 
> So, at this point the isolated pages are cleaned and put back which is
> fine. If they were already clean, they get freed which is also fine. But
> direct reclaimers do not call this function so they could be missing
> clean and freeable pages which worries me.
> 

Hmm. I have to be afraid of that...my first thought was adding klaunderd
and add waitqueue between klaunderd and direct-reclamers.
I used kswapd to make the whole simple but I wonder we need some waitq
if we're afraid that all pages are under I/O! case.


> > +		/*
> > +		 * Put back any unfreeable pages.
> > +		 */

> >  /*
> >   * The background pageout daemon, started as a kernel thread
> >   * from the init process.
> > @@ -2275,7 +2422,9 @@ static int kswapd(void *p)
> >  		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> >  		new_order = pgdat->kswapd_max_order;
> >  		pgdat->kswapd_max_order = 0;
> > -		if (order < new_order) {
> > +		if (need_to_cleaning_node(pgdat)) {
> > +			launder_pgdat(pgdat);
> > +		} else if (order < new_order) {
> >  			/*
> >  			 * Don't sleep if someone wants a larger 'order'
> >  			 * allocation
> 
> I see the direction you are thinking of but I have big concerns about clean
> pages getting delayed for too long on the LRU_CLEANING pages before kswapd
> puts them back in the right place. I think a safer direction would be for
> memcg people to investigate Andrea's "switch stack" suggestion.
> 
Hmm, I may have to consider that. My concern is that IRQ's switch-stack works
well just because no-task-switch in IRQ routine. (I'm sorry if I misunderstand.)

One possibility for memcg will be limit the number of reclaimers who can use
__GFP_FS and use shared stack per cpu per memcg.

Hmm. yet another per-memcg memory shrinker may sound good. 2 years ago, I wrote
a patch to do high-low-watermark memory shirker thread for memcg.
  
  - limit
  - high
  - low

start memory reclaim/writeback when usage exceeds "high" and stop it is below
"low". Implementing this with thread pool can be a choice.



> In the meantime for my own series, memcg now treats dirty pages similar to
> lumpy reclaim. It asks flusher threads to clean pages but stalls waiting
> for those pages to be cleaned for a time. This is an untested patch on top
> of the current series.
> 

Wow...Doesn't this make memcg too slow ? Anyway, memcg should kick flusher
threads..or something, needs other works, too.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
