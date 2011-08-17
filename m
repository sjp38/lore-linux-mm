Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id EC25F6B016A
	for <linux-mm@kvack.org>; Tue, 16 Aug 2011 21:14:20 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 477F33EE0BC
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:14:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E21D45DE9E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:14:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1768645DE7E
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:14:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 076E91DB8038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:14:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B42FE1DB803B
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 10:14:16 +0900 (JST)
Date: Wed, 17 Aug 2011 10:06:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] mm: vmscan: Do not writeback filesystem pages in
 kswapd except in high priority
Message-Id: <20110817100652.e321bf26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110811202504.GB4844@suse.de>
References: <1312973240-32576-1-git-send-email-mgorman@suse.de>
	<1312973240-32576-6-git-send-email-mgorman@suse.de>
	<20110811181029.d3c10169.kamezawa.hiroyu@jp.fujitsu.com>
	<20110811202504.GB4844@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, 11 Aug 2011 21:25:04 +0100
Mel Gorman <mgorman@suse.de> wrote:

> On Thu, Aug 11, 2011 at 06:10:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 10 Aug 2011 11:47:18 +0100
> > Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > It is preferable that no dirty pages are dispatched for cleaning from
> > > the page reclaim path. At normal priorities, this patch prevents kswapd
> > > writing pages.
> > > 
> > > However, page reclaim does have a requirement that pages be freed
> > > in a particular zone. If it is failing to make sufficient progress
> > > (reclaiming < SWAP_CLUSTER_MAX at any priority priority), the priority
> > > is raised to scan more pages. A priority of DEF_PRIORITY - 3 is
> > > considered to be the point where kswapd is getting into trouble
> > > reclaiming pages. If this priority is reached, kswapd will dispatch
> > > pages for writing.
> > > 
> > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> > 
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Thanks
> 
> > BTW, I'd like to see summary of the effect of priority..
> > 
> 
> What sort of summary are you looking for? If pressure is high enough,
> writes start happening from reclaim. On NUMA, it can be particularly
> pronounced. Here is a summary of page writes from reclaim over a range
> of tests
> 
> 512M1P-xfs           Page writes file fsmark                                 8113        74
> 512M1P-xfs           Page writes file simple-wb                             19895         1
> 512M1P-xfs           Page writes file mmap-strm                               997        95
> 512M-xfs             Page writes file fsmark                                12071         9
> 512M-xfs             Page writes file simple-wb                             31709         1
> 512M-xfs             Page writes file mmap-strm                            148274      2448
> 512M-4X-xfs          Page writes file fsmark                                12828         0
> 512M-4X-xfs          Page writes file simple-wb                             32168         5
> 512M-4X-xfs          Page writes file mmap-strm                            346460      4405
> 512M-16X-xfs         Page writes file fsmark                                11566        29
> 512M-16X-xfs         Page writes file simple-wb                             31935         4
> 512M-16X-xfs         Page writes file mmap-strm                             38085      4371
> 
> With 1 processor (512M1P), very few writes occur as for the most part
> flushers are keeping up. With 4x times more processors than there are
> CPUs (512M-4X), there are more writes by kswapd..
> 
> 1024M1P-xfs          Page writes file fsmark                                 3446         1
> 1024M1P-xfs          Page writes file simple-wb                             11697         6
> 1024M1P-xfs          Page writes file mmap-strm                              4077       446
> 1024M-xfs            Page writes file fsmark                                 5159         0
> 1024M-xfs            Page writes file simple-wb                             12785         5
> 1024M-xfs            Page writes file mmap-strm                            251153      8108
> 1024M-4X-xfs         Page writes file fsmark                                 4781         0
> 1024M-4X-xfs         Page writes file simple-wb                             12486         6
> 1024M-4X-xfs         Page writes file mmap-strm                           1627122     15000
> 1024M-16X-xfs        Page writes file fsmark                                 3777         1
> 1024M-16X-xfs        Page writes file simple-wb                             11856         2
> 1024M-16X-xfs        Page writes file mmap-strm                              6563      2638
> 4608M1P-xfs          Page writes file fsmark                                 1497         0
> 4608M1P-xfs          Page writes file simple-wb                              4305         0
> 4608M1P-xfs          Page writes file mmap-strm                             17586     10153
> 4608M-xfs            Page writes file fsmark                                 3380         0
> 4608M-xfs            Page writes file simple-wb                              5528         0
> 4608M-4X-xfs         Page writes file fsmark                                 4650         0
> 4608M-4X-xfs         Page writes file simple-wb                              5621         0
> 4608M-4X-xfs         Page writes file mmap-strm                            149751     18395
> 4608M-16X-xfs        Page writes file fsmark                                  388         0
> 4608M-16X-xfs        Page writes file simple-wb                              5466         0
> 4608M-16X-xfs        Page writes file mmap-strm                           3349772     19307
> 
> This is the same type of tests just with more memory. If enough
> processes are running, kswapd will start writing pages as it tries
> to reclaim memory.
> 
> 4096M8N-xfs          Page writes file fsmark                                11571      8163
> 4096M8N-xfs          Page writes file simple-wb                             28979     11460
> 4096M8N-xfs          Page writes file mmap-strm                            178999     12181
> 4096M8N-4X-xfs       Page writes file fsmark                                14421      7487
> 4096M8N-4X-xfs       Page writes file simple-wb                             26474     10529
> 4096M8N-4X-xfs       Page writes file mmap-strm                            163770     58765
> 4096M8N-16X-xfs      Page writes file fsmark                                16726      9265
> 4096M8N-16X-xfs      Page writes file simple-wb                             28800     11129
> 4096M8N-16X-xfs      Page writes file mmap-strm                             73303     48267
> 
> This is with 8 NUMA nodes, each 512M in size. As the flusher threads are
> not targetting a specific ndoe, kswapd writing pages happens more
> frequently.
> 

Thank you for illustration.

> Is this what you are looking for?
> 

I just wondered how 'priority' is used over vmscan.c

It's used for
  - calculate # of pages to be scanned.
  - sleep(congestion_wait())
  - change reclaim mode
  - reclaim stall detection
  - quit scan loop 
  - all_unreclaimable detection
  - swap token
  - write back skip <----- New!

To me, it seems a value is used for many purpose.
And I wonder whether this is good or not..

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
