Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C40B16B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 23:58:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C5C153EE0BC
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:58:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A774345DF58
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:58:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 903F445DF54
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:58:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 774781DB8044
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:58:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CA481DB802C
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:58:12 +0900 (JST)
Date: Tue, 27 Dec 2011 13:56:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-Id: <20111227135658.08c8016a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111227035730.GA22840@barrios-laptop.redhat.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	<20111221095249.GA28474@tiehlicka.suse.cz>
	<20111221225512.GG23662@dastard>
	<1324630880.562.6.camel@rybalov.eng.ttk.net>
	<20111223102027.GB12731@dastard>
	<1324638242.562.15.camel@rybalov.eng.ttk.net>
	<20111223204503.GC12731@dastard>
	<20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
	<20111227035730.GA22840@barrios-laptop.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, nowhere <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Dec 2011 12:57:31 +0900
Minchan Kim <minchan@kernel.org> wrote:

> On Tue, Dec 27, 2011 at 11:15:43AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Sat, 24 Dec 2011 07:45:03 +1100
> > Dave Chinner <david@fromorbit.com> wrote:
> > 
> > > On Fri, Dec 23, 2011 at 03:04:02PM +0400, nowhere wrote:
> > > > В Пт., 23/12/2011 в 21:20 +1100, Dave Chinner пишет:
> > > > > On Fri, Dec 23, 2011 at 01:01:20PM +0400, nowhere wrote:
> > > > > > В Чт., 22/12/2011 в 09:55 +1100, Dave Chinner пишет:
> > > > > > > On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrote:
> > 
> > > > Here is the report of trace-cmd while dd'ing
> > > > https://80.237.6.56/report-dd.xz
> > > 
> > > Ok, it's not a shrink_slab() problem - it's just being called ~100uS
> > > by kswapd. The pattern is:
> > > 
> > > 	- reclaim 94 (batches of 32,32,30) pages from iinactive list
> > > 	  of zone 1, node 0, prio 12
> > > 	- call shrink_slab
> > > 		- scan all caches
> > > 		- all shrinkers return 0 saying nothing to shrink
> > > 	- 40us gap
> > > 	- reclaim 10-30 pages from inactive list of zone 2, node 0, prio 12
> > > 	- call shrink_slab
> > > 		- scan all caches
> > > 		- all shrinkers return 0 saying nothing to shrink
> > > 	- 40us gap
> > > 	- isolate 9 pages from LRU zone ?, node ?, none isolated, none freed
> > > 	- isolate 22 pages from LRU zone ?, node ?, none isolated, none freed
> > > 	- call shrink_slab
> > > 		- scan all caches
> > > 		- all shrinkers return 0 saying nothing to shrink
> > > 	40us gap
> > > 
> > > And it just repeats over and over again. After a while, nid=0,zone=1
> > > drops out of the traces, so reclaim only comes in batches of 10-30
> > > pages from zone 2 between each shrink_slab() call.
> > > 
> > > The trace starts at 111209.881s, with 944776 pages on the LRUs. It
> > > finishes at 111216.1 with kswapd going to sleep on node 0 with
> > > 930067 pages on the LRU. So 7 seconds to free 15,000 pages (call it
> > > 2,000 pages/s) which is awfully slow....
> > > 
> > > vmscan gurus - time for you to step in now...
> > >
> >  
> > Can you show /proc/zoneinfo ? I want to know each zone's size.
> > 
> > Below is my memo.
> > 
> > In trace log, priority = 11 or 12. Then, I think kswapd can reclaim memory
> > to satisfy "sc.nr_reclaimed >= SWAP_CLUSTER_MAX" condition and loops again.
> > 
> > Seeing balance_pgdat() and trace log, I guess it does
> > 
> > 	wake up
> > 
> > 	shrink_zone(zone=0(DMA?))     => nothing to reclaim.
> > 		shrink_slab()
> > 	shrink_zone(zone=1(DMA32?))   => reclaim 32,32,31 pages 
> > 		shrink_slab()
> > 	shrink_zone(zone=2(NORMAL?))  => reclaim 13 pages. 
> > 		srhink_slab()
> > 
> > 	sleep or retry.
> > 
> > Why shrink_slab() need to be called frequently like this ?
> 
> I guess it's caused by small NORMAL zone.

You're right. I confirmed his zoneinfo.

> The scenario I think is as follows,
> 
> 1. dd comsumes memory in NORMAL zone
> 2. dd enter direct reclaim and wakeup kswapd
> 3. kswapd reclaims some memory in NORMAL zone until it reclaims high wamrk
> 4. schedule
> 5. dd consumes memory again in NORMAL zone
> 6. kswapd fail to reclaim memory by high watermark due to 5.
> 7. loop again, goto 3.
> 
> The point is speed between reclaim VS memory consumption.
> So kswapd cannot reach a point which enough pages are in NORMAL zone.
> 
> > 
> > BTW. I'm sorry if I miss something ...Why only kswapd reclaims memory
> > while 'dd' operation ? (no direct relcaim by dd.)
> > Is this log record cpu hog after 'dd' ?
> 
> If above scenario is right, dd couldn't enter direct reclaim to reclaim memory.
> 

I think you're right. IIUC, kswapd's behavior is what we usually see.

Hmm, if I understand correctly,

 - dd's speed down is caused by kswapd's cpu consumption.
 - kswapd's cpu consumption is enlarged by shrink_slab() (by perf)
 - kswapd can't stop because NORMAL zone is small.
 - memory reclaim speed is enough because dd can't get enough cpu.

I wonder reducing to call shrink_slab() may be a help but I'm not sure
where lock conention comes from...

Regards,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
