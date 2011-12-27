Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 395AA6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 23:45:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 570483EE0C0
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:45:38 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3025645DE52
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:45:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 12C8C45DE4E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:45:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02E531DB8040
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:45:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A70B51DB8037
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 13:45:37 +0900 (JST)
Date: Tue, 27 Dec 2011 13:44:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-Id: <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1324954208.4634.2.camel@hakkenden.homenet>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	<20111221095249.GA28474@tiehlicka.suse.cz>
	<20111221225512.GG23662@dastard>
	<1324630880.562.6.camel@rybalov.eng.ttk.net>
	<20111223102027.GB12731@dastard>
	<1324638242.562.15.camel@rybalov.eng.ttk.net>
	<20111223204503.GC12731@dastard>
	<20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
	<1324954208.4634.2.camel@hakkenden.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Nikolay S." <nowhere@hakkenden.ath.cx>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Dec 2011 06:50:08 +0400
"Nikolay S." <nowhere@hakkenden.ath.cx> wrote:

> В Вт., 27/12/2011 в 11:15 +0900, KAMEZAWA Hiroyuki пишет:
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
> 

Thanks, 
Qeustion:
 1. does this system has no swap ?
 2. What version of kernel which you didn't see the kswapd issue ?
 3. Is this real host ? or virtualized ?


> $ cat /proc/zoneinfo 
...
Node 0, zone    DMA32
  pages free     19620
        min      14715
        low      18393
        high     22072
        scanned  0
        spanned  1044480
        present  896960
    nr_free_pages 19620
    nr_inactive_anon 43203
    nr_active_anon 206577
    nr_inactive_file 412249
    nr_active_file 126151

Then, DMA32(zone=1) files are enough large (> 32 << 12)
Hmm. assuming all frees are used for file(of dd)


(412249 + 126151 + 19620) >> 12 = 136

So, 32, 32, 30 scan seems to work as desgined.

> Node 0, zone   Normal
>   pages free     2854
>         min      2116
>         low      2645
>         high     3174
>         scanned  0
>         spanned  131072
>         present  129024
>     nr_free_pages 2854
>     nr_inactive_anon 20682
>     nr_active_anon 10262
>     nr_inactive_file 47083
>     nr_active_file 11292

Hmm, NORMAL is much smaller than DMA32. (only 500MB.)

Then, at priority=12,

  13 << 12 = 53248

13 pages per a scan seems to work as designed.
To me,  it seems kswapd does usual work...reclaim small memory until free
gets enough. And it seems 'dd' allocates its memory from ZONE_DMA32 because
of gfp_t fallbacks.


Memo.

1. why shrink_slab() should be called per zone, which is not zone aware.
   Isn't it enough to call it per priority ?

2. what spinlock contention that perf showed ?
   And if shrink_slab() doesn't consume cpu as trace shows, why perf 
   says shrink_slab() is heavy..

3. because 8/9 of memory is in DMA32, calling shrink_slab() frequently
   at scanning NORMAL seems to be time wasting.
 

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
