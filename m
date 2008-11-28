Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAS72MVe029624
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 28 Nov 2008 16:02:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 867CF45DD7A
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 16:02:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67AD745DE51
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 16:02:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C9CB1DB803A
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 16:02:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F273A1DB803B
	for <linux-mm@kvack.org>; Fri, 28 Nov 2008 16:02:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max pages
In-Reply-To: <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081124145057.4211bd46@bree.surriel.com> <20081125203333.26F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081128140405.3D0B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 28 Nov 2008 16:02:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Hi

I mesured some data in this week and I got some interesting data.


> > Kosaki, this should address the zone scanning pressure issue.
> 
> hmmmm. I still don't like the behavior when priority==DEF_PRIORITY.
> but I also should explain by code and benchmark.
> 
> therefore, I'll try to mesure this patch in this week.

1. many # of process reclaiming at that time

I mesure ten times  following bench.

$ hackbench 140 process 300


rc6+stream: 2.6.28-rc6 + 
            vmscan-evict-streaming-io-first.patch (in -mm)
rvr:        above + Rik's bailing out patch
kosaki:     above + kosaki modify (attached the last in this mail)


result (unit: second)

	rc6+stream	rvr		+kosaki patch
-----------------------------------------------------------
	175.457		62.514		104.87
	168.409		225.698		133.128
	154.658		114.694		194.867
	46.148		179.108		11.82
	289.575		111.08		60.779
	146.871		189.796		86.515
	305.036		114.124		54.009
	225.21		112.999		273.841
	224.674		227.842		166.547
	118.071		81.869		84.431
	------------------------------------------
avg	185.4109	141.9724	117.0807
std	74.18484	55.93676126	73.28439987
min	46.148		62.514		11.82
max	305.036		227.842		273.841


OK.
Rik patch improve about 30% and my patch improve 20% more.
totally, We got about 50% improvement.



2. "communicate each other application" conflict the other

console A
  $ dbench 100

console B
  $ hackbench 130 process 300


hackbench result (unit :second)

	rc6+stream	rvr		+kosaki
====================================================
	588.74		57.084		139.448
	569.876		325.063		52.233
	427.078		295.259		53.492
	65.264		132.873		59.009
	136.636		136.367		319.115
	221.538		76.352		187.937
	244.881		125.774		158.846
	37.523		115.77		122.17
	182.485		382.376		105.195
	273.983		299.577		130.478
	----------------------------------------
avg	274.8004	194.6495	132.7923
std	184.4902365	111.5699478	75.88299814
min	37.523		57.084		52.233
max	588.74		382.376		319.115



That's more interesting.

-rc6 reclaim victory on min score. but also it has worst max score. why?

traditional reclaim assume following two case is equivalent.

  case (1)
    - task (a) spent 1 sec for reclaim.
    - task (b) spent 1 sec for reclaim.
    - task (c) spent 1 sec for reclaim.

  case (2)
    - task (a) spent 3 sec for reclaim.
    - task (b) spent 0 sec for reclaim.
    - task (c) spent 0 sec for reclaim.

However, when these task comminicate each other, it isn't correct.

if task (2)-(a) is dbench process, ok, you are lucky.
dbench process don't comminicate each other. that's performance is
decided from avarage performance.
one process slowdown don't become system slowdown.

then, hackbench and dbench get both good result.


In the other hand, if task (2)-(a) is hackbench process, you are unlucky.
hackbench process communicate each other.
then the performance is decided slowest process.

then, hackbench performance dramatically decreased although dbench
performance almost don't increased.

Therefore, I think case (1) is better.



So, rik patch and my patch improve perfectly different reclaim aspect.
In general, kernel reclaim processing has several key goals.

 (1) if system has droppable cache, system shouldn't happen oom kill.
 (2) if system has avaiable swap space, system shouldn't happen 
     oom kill as poosible as.
 (3) if system has enough free memory, system shouldn't reclaim any page
     at all.
 (4) if memory pressure is lite, system shouldn't cause heavy reclaim 
     latency to application.

rik patch improve (3), my (this mail) modification improve (4).


BTW, reclaim throttle patch has one another improvement likes 
Hanns's "vmscan: serialize aggressive reclaimers" patch.
actually, rik patch improvement (3). but it isn't perfect.
if 10000 thread call reclaim at that time, system reclaim 32*10000 pages.
it is definitly too much.
but it is obviously offtopic :)


Rik, could you please merge my modify into your patch?

======
In past, HPC guys want to improve lite reclaim latency multiple times.
(e.g. http://marc.info/?l=linux-mm&m=121418258514542&w=2)

because their workload has following characteristics.
  - their workload make many process or many thread.
  - typically, write() is called at job ending phase.
    then, many file cache isn't reused.
  - In their parallel job, any process comminicate each other.
    then, system performance is decide from slowest thread.
    then, large reclaim latency decrease system performance directly.

Actually, kswapd background reclaim and direct reclaim have perfectly
different purpose and goal.

background reclaim
  - kswapd don't need latency overhead reducing.
    it isn't observe from end user.
  - kswapd shoudn't only increase free pages, but also should 
    zone balancing.

foreground reclaim
  - it used application task context.
  - as possible as, it shouldn't increase latency overhead.
  - this reclaiming purpose is to make the memory for _own_ taks.
    for other tasks memory don't need to concern.
    kswap does it.


Almost developer don't payed attention for HPC in past.
However, in these days, # of cpus increase rapidly. and
parallel processing technique become commonly.
(e.g. now, gcc has OpenMP feature support directly)

Therefore, we shouldn't ignore parallel application modern days.



o remove priority==DEF_PRIORITY condision
o shrink_zones() also should have bailing out feature.

---
 mm/vmscan.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1469,7 +1469,7 @@ static void shrink_zone(int priority, st
 		 * freeing target can get unreasonably large.
 		 */
 		if (sc->nr_reclaimed > sc->swap_cluster_max &&
-		    priority < DEF_PRIORITY && !current_is_kswapd())
+		    !current_is_kswapd())
 			break;
 	}
 
@@ -1534,6 +1534,8 @@ static void shrink_zones(int priority, s
 		}
 
 		shrink_zone(priority, zone, sc);
+		if (sc->nr_reclaimed > sc->swap_cluster_max)
+			break;
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
