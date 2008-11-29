Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mATArC6q025000
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 29 Nov 2008 19:53:12 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE4DE45DD79
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:53:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8556145DD74
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:53:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 636F61DB8041
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:53:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E2FD1DB803E
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 19:53:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <492FCFF6.1050808@redhat.com>
References: <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <492FCFF6.1050808@redhat.com>
Message-Id: <20081129164624.8134.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 29 Nov 2008 19:53:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> > So, rik patch and my patch improve perfectly different reclaim aspect.
> > In general, kernel reclaim processing has several key goals.
> > 
> >  (1) if system has droppable cache, system shouldn't happen oom kill.
> >  (2) if system has avaiable swap space, system shouldn't happen 
> >      oom kill as poosible as.
> >  (3) if system has enough free memory, system shouldn't reclaim any page
> >      at all.
> >  (4) if memory pressure is lite, system shouldn't cause heavy reclaim 
> >      latency to application.
> > 
> > rik patch improve (3), my (this mail) modification improve (4).
> 
> Actually, to achieve (3) we would want to skip zones with way
> more than enough free memory in shrink_zones().  Kswapd already
> skips zones like this in shrink_pgdat(), so we definately want
> this change:
> 
> @@ -1519,6 +1519,9 @@ static void shrink_zones(int priority, s
>                          if (zone_is_all_unreclaimable(zone) &&
>                                                  priority != DEF_PRIORITY)
>                                  continue;       /* Let kswapd poll it */
> +                       if (zone_watermark_ok(zone, order, 
> 4*zone->pages_high,
> +                                               end_zone, 0))
> +                               continue;       /* Lots free already */
>                          sc->all_unreclaimable = 0;
>                  } else {
>                          /*
> 
> I'm sending a patch with this right now :)

please wait few days.

Actually, I made similar patch half year ago.
but I droped it because I observe performance degression.

but my recall isn't clear. 
I should mesure it again.

My guessing is,
zone_waterwark_ok() is very slow function, it doesn't only check
the number of the free memory, but also check memory fragmentation.
So, it is called when lite memory pressure, we violate above rule (4).




> > Actually, kswapd background reclaim and direct reclaim have perfectly
> > different purpose and goal.
> > 
> > background reclaim
> >   - kswapd don't need latency overhead reducing.
> >     it isn't observe from end user.
> >   - kswapd shoudn't only increase free pages, but also should 
> >     zone balancing.
> > 
> > foreground reclaim
> >   - it used application task context.
> >   - as possible as, it shouldn't increase latency overhead.
> >   - this reclaiming purpose is to make the memory for _own_ taks.
> >     for other tasks memory don't need to concern.
> >     kswap does it.
> 
> I am not entirely convinced that breaking out of the loop early
> in a zone is not harmful for direct reclaimers.  Maybe it works
> fine, maybe it won't.
> 
> Or maybe direct reclaimers should start scanning the largest zone
> first, so your change can be done with the lowest risk possible?
> 
> Having said that, the 20% additional performance achieved with
> your changes is impressive.
> 
> > o remove priority==DEF_PRIORITY condision
> 
> This one could definately be worth considering.
> 
> However, looking at the changeset that was backed out in the
> early 2.6 series suggests that it may not be the best idea.
> 
> > o shrink_zones() also should have bailing out feature.
> 
> This one is similar.  What are the downsides of skipping a
> zone entirely, when that zone has pages that should be freed?
> 
> If it can lead to the VM reclaiming new pages from one zone,
> while leaving old pages from another zone in memory, we can
> greatly reduce the caching efficiency of the page cache.

I think I can explain logically.

At first, please see below ML archive url.
it describe why akpm's "vmscan.c: dont reclaim too many pages" was dropped.

http://groups.google.co.jp/group/linux.kernel/browse_thread/thread/383853cdce059d1f/f13d5f87d726e325?hl=ja%3Fhl&lnk=gst&q=vmscan%3A+balancing+fix+akpm#f13d5f87d726e325


Again, old akpm patch restrict direct reclaim and background reclaim.
Therefore that url's discussion didn't separate two things too.
but your and mine restrict direct reclaim only.

At that time, Marcelo Tosatti reported akpm patch cause reclaim
imbalancing by FFSB benchmark.

I mesured ffsb on 2.6.28-rc6 and our patch.


mesured machine spec:
  CPU:   IA64 x 8
  MEM
    Node0: DMA ZONE:    2GB
           NORMAL ZONE: 2GB
    Node1: DMA ZONE:    4GB
                 -----------------
                 total  8GB

used configuration file (the same of marcelo's conf)

---------------------------------------------------
directio=0
time=300

[filesystem0]
location=/mnt/sdb1/kosaki/ffsb
num_files=20
num_dirs=10
max_filesize=91534338
min_filesize=65535
[end0]

[threadgroup0]
num_threads=10
write_size=2816
write_blocksize=4096
read_size=2816
read_blocksize=4096
create_weight=100
write_weight=30
read_weight=100
[end0]
--------------------------------------------------------

result:
------------  2.6.28-rc6 ----------------------------------

pgscan_kswapd_dma 10624
pgscan_kswapd_normal 20640

        -> normal/dma ratio 20640 / 10624 = 1.9

pgscan_direct_dma 576
pgscan_direct_normal 2528

        -> normal/dma ratio 2528 / 576 = 4.38

kswapd+direct dma    11200
kswapd+direct normal 23168

	-> normal/dma ratio 2.0

------------  rvr bail out ---------------------------------

pgscan_kswapd_dma 15552
pgscan_kswapd_normal 31936

        -> normal/dma ratio 2.05

pgscan_direct_dma 1216
pgscan_direct_normal 3968

        -> normal/dma ratio 3.26

kswapd+direct dma    16768
kswapd+direct normal 35904

	-> normal/dma ratio 2.1


------------  +kosaki ---------------------------------

pgscan_kswapd_dma 14208
pgscan_kswapd_normal 31616

        -> normal/dma ratio 31616/14208 = 2.25

pgscan_direct_dma 1024
pgscan_direct_normal 3328

        -> normal/dma ratio 3328/1024 = 3.25

kswapd+direct dma    15232
kswapd+direct normal 34944

	-> normal/dma ratio 2.2

----------------------------------------------------------

The result talk about three things.

  - rvr and mine patch increase direct reclaim imbalancing, indeed.
  - However, background reclaim scanning is _very_ much than direct reclaim.
    Then, direct reclaim imbalancing is ignorable on the big view.
    rvr patch doesn't reintroduce zone imbalancing issue.
  - rvr's priority==DEF_PRIORITY condition checking doesn't improve
    zone balancing at all.
    we can drop it.

Again, I believe my patch improve vm scanning totally.

Any comments?


Andrew, I hope add this mesurement result to rvr bailing out patch description too.
Please let me know what I should do.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
