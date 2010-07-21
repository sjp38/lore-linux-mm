Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8241E6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 20:02:24 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6M02Mvd015845
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jul 2010 09:02:22 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D698945DE54
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:02:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D37E45DE50
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:02:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BA931DB805D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:02:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1658C1DB8055
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 09:02:21 +0900 (JST)
Date: Thu, 22 Jul 2010 08:57:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-Id: <20100722085734.ff252542.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100721142710.GZ13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
	<1279545090-19169-5-git-send-email-mel@csn.ul.ie>
	<20100719221420.GA16031@cmpxchg.org>
	<20100720134555.GU13117@csn.ul.ie>
	<20100720220218.GE16031@cmpxchg.org>
	<20100721115250.GX13117@csn.ul.ie>
	<20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com>
	<20100721142710.GZ13117@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 15:27:10 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Jul 21, 2010 at 09:01:11PM +0900, KAMEZAWA Hiroyuki wrote:
 
> > But, hmm, memcg will have to select to enter this rounine based on
> > the result of 1st memory reclaim.
> > 
> 
> It has the option of igoring pages being dirtied but I worry that the
> container could be filled with dirty pages waiting for flushers to do
> something.

I'll prepare dirty_ratio for memcg. It's not easy but requested by I/O cgroup
guys, too...


> 
> > >  
> > > -		/*
> > > -		 * The attempt at page out may have made some
> > > -		 * of the pages active, mark them inactive again.
> > > -		 */
> > > -		nr_active = clear_active_flags(&page_list, NULL);
> > > -		count_vm_events(PGDEACTIVATE, nr_active);
> > > +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> > > +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> > > +			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > >  
> >
> > Congestion wait is required ?? Where the congestion happens ?
> > I'm sorry you already have some other trick in other patch.
> > 
> 
> It's to wait for the IO to occur.
> 
1 tick penalty seems too large. I hope we can have some waitqueue in future.



> > > -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> > > +			/*
> > > +			 * The attempt at page out may have made some
> > > +			 * of the pages active, mark them inactive again.
> > > +			 */
> > > +			nr_active = clear_active_flags(&page_list, NULL);
> > > +			count_vm_events(PGDEACTIVATE, nr_active);
> > > +	
> > > +			nr_reclaimed += shrink_page_list(&page_list, sc,
> > > +						PAGEOUT_IO_SYNC, &nr_dirty);
> > > +		}
> > 
> > Just a question. This PAGEOUT_IO_SYNC has some meanings ?
> > 
> 
> Yes, in pageout it will wait on pages currently being written back to be
> cleaned before trying to reclaim them.
> 
Hmm. IIUC, this routine is called only when !current_is_kswapd() and
pageout is done only whne current_is_kswapd(). So, this seems ....
Wrong ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
