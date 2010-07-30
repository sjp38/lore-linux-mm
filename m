Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E0596B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 00:54:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6U4st06015532
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 30 Jul 2010 13:54:56 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 72D2545DE51
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:54:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4565A45DE4E
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:54:55 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B68CE18003
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:54:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5B89E08002
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:54:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Why PAGEOUT_IO_SYNC stalls for a long time
In-Reply-To: <20100729142413.GB3571@csn.ul.ie>
References: <20100729153719.4ABD.A69D9226@jp.fujitsu.com> <20100729142413.GB3571@csn.ul.ie>
Message-Id: <20100730115222.4AD8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 30 Jul 2010 13:54:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andreas Mohr <andi@lisas.de>, Bill Davidsen <davidsen@tmr.com>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

> > (1) and (8) might be solved
> > by sleeping awhile, but it's unrelated on io-congestion. but might not be. It only works
> > by lucky. So I don't like to depned on luck. 
> 
> In this case, waiting a while really in the right thing to do. It stalls
> the caller, but it's a high-order allocation. The alternative is for it
> to keep scanning which when under memory pressure could result in far
> too many pages being evicted. How long to wait is a tricky one to answer
> but I would recommend making this a low priority.

For case (1), just lock_page() instead trylock is brilliant way than random sleep. 
Is there any good reason to give up synchrounous lumpy reclaim when trylock_page() failed?
IOW, briefly lock_page() and wait_on_page_writeback() have the same latency. why should
we only avoid former?

side note: page lock contention is very common case.

For case (8), I don't think sleeping is right way. get_page() is used in really various place of
our kernel. so we can't assume it's only temporary reference count increasing. In the other
hand, this contention is not so common because shrink_page_list() is excluded from IO
activity by page-lock and wait_on_page_writeback(). so I think giving up this case don't
makes too many pages eviction.
If you disagree, can you please explain your expected bad scinario?



> > > > 3. pageout() is intended anynchronous api. but doesn't works so.
> > > > 
> > > > pageout() call ->writepage with wbc->nonblocking=1. because if the system have
> > > > default vm.dirty_ratio (i.e. 20), we have 80% clean memory. so, getting stuck
> > > > on one page is stupid, we should scan much pages as soon as possible.
> > > > 
> > > > HOWEVER, block layer ignore this argument. if slow usb memory device connect
> > > > to the system, ->writepage() will sleep long time. because submit_bio() call
> > > > get_request_wait() unconditionally and it doesn't have any PF_MEMALLOC task
> > > > bonus.
> > > 
> > > Is this not a problem in the writeback layer rather than pageout()
> > > specifically?
> > 
> > Well, outside pageout(), probably only XFS makes PF_MEMALLOC + writeout. 
> > because PF_MEMALLOC is enabled only very limited situation. but I don't know
> > XFS detail at all. I can't tell this area...
> > 
> 
> All direct reclaimers have PF_MEMALLOC set so it's not that limited a
> situation. See here

Yes, all direct reclaimers have PF_MEMALLOC. but usually all direct reclaimers don't call
any IO related function except pageout(). As far as I know, current shrink_icache() and 
shrink_dcache() doesn't make IO. Am I missing something?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
