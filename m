Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 35A78900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 22:28:29 -0400 (EDT)
Date: Fri, 29 Apr 2011 10:28:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH] mm: cut down __GFP_NORETRY page allocation
 failures
Message-ID: <20110429022824.GA8061@localhost>
References: <20110426055521.GA18473@localhost>
 <BANLkTik8k9A8N8CPk+eXo9c_syxJFRyFCA@mail.gmail.com>
 <BANLkTim0MNgqeh1KTfvpVFuAvebKyQV8Hg@mail.gmail.com>
 <20110426062535.GB19717@localhost>
 <BANLkTinM9DjK9QsGtN0Sh308rr+86UMF0A@mail.gmail.com>
 <20110426063421.GC19717@localhost>
 <BANLkTi=xDozFNBXNdGDLK6EwWrfHyBifQw@mail.gmail.com>
 <20110426092029.GA27053@localhost>
 <20110426124743.e58d9746.akpm@linux-foundation.org>
 <20110428133644.GA12400@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110428133644.GA12400@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Dave Young <hidave.darkstar@gmail.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>

> Test results:
> 
> - the failure rate is pretty sensible to the page reclaim size,
>   from 282 (WMARK_HIGH) to 704 (WMARK_MIN) to 10496 (SWAP_CLUSTER_MAX)
> 
> - the IPIs are reduced by over 100 times

It's reduced by 500 times indeed.

CAL:     220449     220246     220372     220558     220251     219740     220043     219968   Function call interrupts
CAL:         93        463        410        540        298        282        272        306   Function call interrupts

> base kernel: vanilla 2.6.39-rc3 + __GFP_NORETRY readahead page allocation patch
> -------------------------------------------------------------------------------
> nr_alloc_fail 10496
> allocstall 1576602

> patched (WMARK_MIN)
> -------------------
> nr_alloc_fail 704
> allocstall 105551

> patched (WMARK_HIGH)
> --------------------
> nr_alloc_fail 282
> allocstall 53860

> this patch (WMARK_HIGH, limited scan)
> -------------------------------------
> nr_alloc_fail 276
> allocstall 54034

There is a bad side effect though: the much reduced "allocstall" means
each direct reclaim will take much more time to complete. A simple solution
is to terminate direct reclaim after 10ms. I noticed that an 100ms
time threshold can reduce the reclaim latency from 621ms to 358ms.
Further lowering the time threshold to 20ms does not help reducing the
real latencies though.

However the very subjective perception is, in such heavy 1000-dd
workload, the reduced reclaim latency hardly improves the overall
responsiveness.

base kernel
-----------

start time: 243
total time: 529

wfg@fat ~% getdelays -dip 3971
print delayacct stats ON
printing IO accounting
PID     3971


CPU             count     real total  virtual total    delay total
                  961     3176517096     3158468847   313952766099
IO              count    delay total  delay average
                    2      181251847             60ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1205    38120615476             31ms
dd: read=16384, write=0, cancelled_write=0
wfg@fat ~% getdelays -dip 3383
print delayacct stats ON
printing IO accounting
PID     3383


CPU             count     real total  virtual total    delay total
                 1270     4206360536     4181445838   358641985177
IO              count    delay total  delay average
                    0              0              0ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                 1606    39897314399             24ms
dd: read=0, write=0, cancelled_write=0

no time limit
-------------
wfg@fat ~% getdelays -dip `pidof dd`
print delayacct stats ON
printing IO accounting
PID     9609


CPU             count     real total  virtual total    delay total
                  865     2792575464     2779071029   235345541230
IO              count    delay total  delay average
                    4      300247552             60ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   32    20504634169            621ms
dd: read=106496, write=0, cancelled_write=0

100ms limit
-----------

start time: 288
total time: 514
nr_alloc_fail 1269
allocstall 128915

wfg@fat ~% getdelays -dip `pidof dd`
print delayacct stats ON
printing IO accounting
PID     5077


CPU             count     real total  virtual total    delay total
                  937     2949551600     2935087806   207877301298
IO              count    delay total  delay average
                    1      151891691            151ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   71    25475514278            358ms
dd: read=507904, write=0, cancelled_write=0

PID     5101


CPU             count     real total  virtual total    delay total
                 1201     3827418144     3805399187   221075772599
IO              count    delay total  delay average
                    4      300331997             60ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   94    31996779648            336ms
dd: read=618496, write=0, cancelled_write=0

nr_alloc_fail 937
allocstall 128684

slabs_scanned 63616
kswapd_steal 4616011
kswapd_inodesteal 5
kswapd_low_wmark_hit_quickly 5394
kswapd_high_wmark_hit_quickly 2826
kswapd_skip_congestion_wait 0
pageoutrun 36679

20ms limit
----------

start time: 294
total time: 516
nr_alloc_fail 1662
allocstall 132101

CPU             count     real total  virtual total    delay total
                  839     2750581848     2734464704   198489159459
IO              count    delay total  delay average
                    1       43566814             43ms
SWAP            count    delay total  delay average
                    0              0              0ms
RECLAIM         count    delay total  delay average
                   95    35234061367            370ms
dd: read=20480, write=0, cancelled_write=0

test script
-----------
tic=$(date +'%s')

for i in `seq 1000`
do
        truncate -s 1G /fs/sparse-$i
        dd if=/fs/sparse-$i of=/dev/null &>/dev/null &
done

tac=$(date +'%s')
echo start time: $((tac-tic))

wait

tac=$(date +'%s')
echo total time: $((tac-tic))

egrep '(nr_alloc_fail|allocstall)' /proc/vmstat

Thanks,
Fengguang
---
Subject: mm: limit direct reclaim delays
Date: Fri Apr 29 09:04:11 CST 2011

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

--- linux-next.orig/mm/vmscan.c	2011-04-29 09:02:42.000000000 +0800
+++ linux-next/mm/vmscan.c	2011-04-29 09:04:10.000000000 +0800
@@ -2037,6 +2037,7 @@ static unsigned long do_try_to_free_page
 	struct zone *zone;
 	unsigned long writeback_threshold;
 	unsigned long min_reclaim = sc->nr_to_reclaim;
+	unsigned long start_time = jiffies;
 
 	get_mems_allowed();
 	delayacct_freepages_start();
@@ -2070,11 +2071,14 @@ static unsigned long do_try_to_free_page
 			}
 		}
 		total_scanned += sc->nr_scanned;
-		if (sc->nr_reclaimed >= min_reclaim &&
-		    total_scanned > 2 * sc->nr_to_reclaim)
-			goto out;
-		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
-			goto out;
+		if (sc->nr_reclaimed >= min_reclaim) {
+			if (sc->nr_reclaimed >= sc->nr_to_reclaim)
+				goto out;
+			if (total_scanned > 2 * sc->nr_to_reclaim)
+				goto out;
+			if (jiffies - start_time > HZ / 100)
+				goto out;
+		}
 
 		/*
 		 * Try to write back as many pages as we just scanned.  This

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
