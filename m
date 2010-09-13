Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BCA826B00C9
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 20:59:02 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8D0wxUt007471
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 13 Sep 2010 09:58:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62BCB45DE50
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:58:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F33C45DE3E
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:58:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FFF71DB8052
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:58:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC0ED1DB804E
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 09:58:58 +0900 (JST)
Date: Mon, 13 Sep 2010 09:53:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/10] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-Id: <20100913095346.317fcb12.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100909093211.GM29263@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-11-git-send-email-mel@csn.ul.ie>
	<20100909122228.3db2b95c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100909093211.GM29263@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Sep 2010 10:32:11 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Sep 09, 2010 at 12:22:28PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon,  6 Sep 2010 11:47:33 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> > > There are a number of cases where pages get cleaned but two of concern
> > > to this patch are;
> > >   o When dirtying pages, processes may be throttled to clean pages if
> > >     dirty_ratio is not met.
> > >   o Pages belonging to inodes dirtied longer than
> > >     dirty_writeback_centisecs get cleaned.
> > > 
> > > The problem for reclaim is that dirty pages can reach the end of the LRU if
> > > pages are being dirtied slowly so that neither the throttling or a flusher
> > > thread waking periodically cleans them.
> > > 
> > > Background flush is already cleaning old or expired inodes first but the
> > > expire time is too far in the future at the time of page reclaim. To mitigate
> > > future problems, this patch wakes flusher threads to clean 4M of data -
> > > an amount that should be manageable without causing congestion in many cases.
> > > 
> > > Ideally, the background flushers would only be cleaning pages belonging
> > > to the zone being scanned but it's not clear if this would be of benefit
> > > (less IO) or not (potentially less efficient IO if an inode is scattered
> > > across multiple zones).
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > ---
> > >  mm/vmscan.c |   32 ++++++++++++++++++++++++++++++--
> > >  1 files changed, 30 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 408c101..33d27a4 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -148,6 +148,18 @@ static DECLARE_RWSEM(shrinker_rwsem);
> > >  /* Direct lumpy reclaim waits up to five seconds for background cleaning */
> > >  #define MAX_SWAP_CLEAN_WAIT 50
> > >  
> > > +/*
> > > + * When reclaim encounters dirty data, wakeup flusher threads to clean
> > > + * a maximum of 4M of data.
> > > + */
> > > +#define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
> > > +#define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
> > > +static inline long nr_writeback_pages(unsigned long nr_dirty)
> > > +{
> > > +	return laptop_mode ? 0 :
> > > +			min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
> > > +}
> > > +
> > >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> > >  						  struct scan_control *sc)
> > >  {
> > > @@ -686,12 +698,14 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
> > >   */
> > >  static unsigned long shrink_page_list(struct list_head *page_list,
> > >  					struct scan_control *sc,
> > > +					int file,
> > >  					unsigned long *nr_still_dirty)
> > >  {
> > >  	LIST_HEAD(ret_pages);
> > >  	LIST_HEAD(free_pages);
> > >  	int pgactivate = 0;
> > >  	unsigned long nr_dirty = 0;
> > > +	unsigned long nr_dirty_seen = 0;
> > >  	unsigned long nr_reclaimed = 0;
> > >  
> > >  	cond_resched();
> > > @@ -790,6 +804,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		}
> > >  
> > >  		if (PageDirty(page)) {
> > > +			nr_dirty_seen++;
> > > +
> > >  			/*
> > >  			 * Only kswapd can writeback filesystem pages to
> > >  			 * avoid risk of stack overflow
> > > @@ -923,6 +939,18 @@ keep_lumpy:
> > >  
> > >  	list_splice(&ret_pages, page_list);
> > >  
> > > +	/*
> > > +	 * If reclaim is encountering dirty pages, it may be because
> > > +	 * dirty pages are reaching the end of the LRU even though the
> > > +	 * dirty_ratio may be satisified. In this case, wake flusher
> > > +	 * threads to pro-actively clean up to a maximum of
> > > +	 * 4 * SWAP_CLUSTER_MAX amount of data (usually 1/2MB) unless
> > > +	 * !may_writepage indicates that this is a direct reclaimer in
> > > +	 * laptop mode avoiding disk spin-ups
> > > +	 */
> > > +	if (file && nr_dirty_seen && sc->may_writepage)
> > > +		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
> > > +
> > 
> > Thank you. Ok, I'll check what happens in memcg.
> > 
> 
> Thanks
> 
> > Can I add
> > 	if (sc->memcg) {
> > 		memcg_check_flusher_wakeup()
> > 	}
> > or some here ?
> > 
> 
> It seems reasonable.
> 
> > Hm, maybe memcg should wake up flusher at starting try_to_free_memory_cgroup_pages().
> > 
> 
> I'm afraid I cannot make a judgement call on which is the best as I am
> not very familiar with how cgroups behave in comparison to normal
> reclaim. There could easily be a follow-on patch though that was cgroup
> specific?
> 

Yes, I'd like to make patches when this series is merged. It's not difficult and
makes it clear how memcg and flusher works for getting good reviews.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
