Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D719C6B02A8
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 05:26:59 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6M9Qsv8017422
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jul 2010 18:26:54 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75BF245DE55
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 18:26:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1201245DE52
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 18:26:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CED4A1DB8018
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 18:26:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F4ADE08006
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 18:26:53 +0900 (JST)
Date: Thu, 22 Jul 2010 18:22:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-Id: <20100722182204.81dddfa9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100722091930.GD13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
	<1279545090-19169-5-git-send-email-mel@csn.ul.ie>
	<20100719221420.GA16031@cmpxchg.org>
	<20100720134555.GU13117@csn.ul.ie>
	<20100720220218.GE16031@cmpxchg.org>
	<20100721115250.GX13117@csn.ul.ie>
	<20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com>
	<20100721142710.GZ13117@csn.ul.ie>
	<20100722085734.ff252542.kamezawa.hiroyu@jp.fujitsu.com>
	<20100722091930.GD13117@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Jul 2010 10:19:30 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Thu, Jul 22, 2010 at 08:57:34AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 21 Jul 2010 15:27:10 +0100
> > Mel Gorman <mel@csn.ul.ie> wrote:

> > 1 tick penalty seems too large. I hope we can have some waitqueue in future.
> > 
> 
> congestion_wait() if congestion occurs goes onto a waitqueue that is
> woken if congestion clears. I didn't measure it this time around but I
> doubt it waits for HZ/10 much of the time.
> 
Okay.

> > > > > -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> > > > > +			/*
> > > > > +			 * The attempt at page out may have made some
> > > > > +			 * of the pages active, mark them inactive again.
> > > > > +			 */
> > > > > +			nr_active = clear_active_flags(&page_list, NULL);
> > > > > +			count_vm_events(PGDEACTIVATE, nr_active);
> > > > > +	
> > > > > +			nr_reclaimed += shrink_page_list(&page_list, sc,
> > > > > +						PAGEOUT_IO_SYNC, &nr_dirty);
> > > > > +		}
> > > > 
> > > > Just a question. This PAGEOUT_IO_SYNC has some meanings ?
> > > > 
> > > 
> > > Yes, in pageout it will wait on pages currently being written back to be
> > > cleaned before trying to reclaim them.
> > > 
> > Hmm. IIUC, this routine is called only when !current_is_kswapd() and
> > pageout is done only whne current_is_kswapd(). So, this seems ....
> > Wrong ?
> > 
> 
> Both direct reclaim and kswapd can reach shrink_inactive_list
> 
> Direct reclaim
> do_try_to_free_pages
>   -> shrink_zones
>     -> shrink_zone
>       -> shrink_list
>         -> shrink_inactive list <--- the routine in question
> 
> Kswapd
> balance_pgdat
>   -> shrink_zone
>     -> shrink_list
>       -> shrink_inactive_list
> 
> pageout() is still called by direct reclaim if the page is anon so it
> will synchronously wait on those if PAGEOUT_IO_SYNC is set. 

Ah, ok. I missed that. Thank you for kindly clarification.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
