Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78FED6B00E9
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 02:24:31 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8E34F3EE0BB
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:24:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E2D845DE6C
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:24:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3800E45DE66
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:24:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2786C1DB8040
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:24:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E61541DB8037
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 15:24:25 +0900 (JST)
Date: Thu, 14 Jul 2011 15:17:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] mm: vmscan: Do not writeback filesystem pages in
 direct reclaim
Message-Id: <20110714151708.163a0c54.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110714061915.GN7529@suse.de>
References: <1310567487-15367-1-git-send-email-mgorman@suse.de>
	<1310567487-15367-2-git-send-email-mgorman@suse.de>
	<20110714103801.83e10fdb.kamezawa.hiroyu@jp.fujitsu.com>
	<20110714061915.GN7529@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 14 Jul 2011 07:19:15 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Jul 14, 2011 at 10:38:01AM +0900, KAMEZAWA Hiroyuki wrote:
> > > @@ -825,6 +825,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		if (PageDirty(page)) {
> > >  			nr_dirty++;
> > >  
> > > +			/*
> > > +			 * Only kswapd can writeback filesystem pages to
> > > +			 * avoid risk of stack overflow
> > > +			 */
> > > +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> > > +				inc_zone_page_state(page, NR_VMSCAN_WRITE_SKIP);
> > > +				goto keep_locked;
> > > +			}
> > > +
> > 
> > 
> > This will cause tons of memcg OOM kill because we have no help of kswapd (now).
> > 
> > Could you make this
> > 
> > 	if (scanning_global_lru(sc) && page_is_file_cache(page) && !current_is_kswapd())
> > ...
> > 
> 
> I can, but as Christoph points out, the request is already being
> ignored so how will it help?
> 

Hmm, ok, please go as you do now. I'll do hurry up to implement dirty_ratio by myself
without waiting for original patch writer. I think his latest version was really
near to be merged... I'll start rebase his one to mmotm in this end of month.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
