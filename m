Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A875C6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:12:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F37D13EE081
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:12:10 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DA0AB45DF49
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:12:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B859A45DF41
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:12:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8225D1DB8040
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:12:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 32A131DB802F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:12:10 +0900 (JST)
Date: Tue, 9 Aug 2011 19:04:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5 0/6]  memg: better numa scanning
Message-Id: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


No major update since the last version I posted 27/Jul.
The patch is rebased onto mmotm-Aug3.

This patch set implements a victim node selection logic and some
behavior fix in vmscan.c for memcg.
The logic calculates 'weight' for each nodes and a victim node
will be selected by comparing 'weight' in fair style.
The core is how to calculate 'weight' and this patch implements
a logic, which make use of recent lotation logic and the amount
of file caches and inactive anon pages.

I'll be absent in 12/Aug - 17/Aug.
I'm sorry if my response is delayed.

In this time, I did 'kernel make' test ...as
==
#!/bin/bash -x

cgset -r memory.limit_in_bytes=500M A

make -j 4 clean
sync
sync
sync
echo 3 > /proc/sys/vm/drop_caches
sleep 1
echo 0 > /cgroup/memory/A/memory.vmscan_stat
cgexec -g memory:A -g cpuset:A time make -j 8
==

On 8cpu, 4-node fake-numa box.
(each node has 2cpus.)

Under the limit of 500M, 'make' need to scan memory to reclaim.
This tests see how vmscan works.

When cpuset.memory_spread_page==0.

[Before patch]
773.07user 305.45system 4:09.64elapsed 432%CPU (0avgtext+0avgdata 1456576maxresident)k
4397944inputs+5093232outputs (9688major+35689066minor)pagefaults 0swaps
scanned_pages_by_limit 3867645
scanned_anon_pages_by_limit 1518266
scanned_file_pages_by_limit 2349379
rotated_pages_by_limit 1502640
rotated_anon_pages_by_limit 1416627
rotated_file_pages_by_limit 86013
freed_pages_by_limit 1005141
freed_anon_pages_by_limit 24577
freed_file_pages_by_limit 980564
elapsed_ns_by_limit 82833866094

[Patched]
773.73user 305.09system 3:51.28elapsed 466%CPU (0avgtext+0avgdata 1458464maxresident)k
4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps

scanned_pages_by_limit 4326462
scanned_anon_pages_by_limit 1310619
scanned_file_pages_by_limit 3015843
rotated_pages_by_limit 1264223
rotated_anon_pages_by_limit 1247180
rotated_file_pages_by_limit 17043
freed_pages_by_limit 1003434
freed_anon_pages_by_limit 20599
freed_file_pages_by_limit 982835
elapsed_ns_by_limit 42495200307

elapsed time for vmscan and the number of page faults are reduced.


When cpuset.memory_spread_page==1, in this case, file cache will be
spread to the all nodes in round robin.
==
[Before Patch + cpuset spread=1]
773.23user 309.55system 4:26.83elapsed 405%CPU (0avgtext+0avgdata 1457696maxresident)k
5400928inputs+5105368outputs (17344major+35735886minor)pagefaults 0swaps

scanned_pages_by_limit 3731787
scanned_anon_pages_by_limit 1374310
scanned_file_pages_by_limit 2357477
rotated_pages_by_limit 1403160
rotated_anon_pages_by_limit 1293568
rotated_file_pages_by_limit 109592
freed_pages_by_limit 1120828
freed_anon_pages_by_limit 20076
freed_file_pages_by_limit 1100752
elapsed_ns_by_limit 82458981267


[Patched + cpuset spread=1]
773.56user 306.02system 3:52.28elapsed 464%CPU (0avgtext+0avgdata 1458160maxresident)k
4173504inputs+4783688outputs (5971major+35666498minor)pagefaults 0swaps

scanned_pages_by_limit 2672392
scanned_anon_pages_by_limit 1140069
scanned_file_pages_by_limit 1532323
rotated_pages_by_limit 1108124
rotated_anon_pages_by_limit 1088982
rotated_file_pages_by_limit 19142
freed_pages_by_limit 975653
freed_anon_pages_by_limit 12578
freed_file_pages_by_limit 963075
elapsed_ns_by_limit 46482588602

elapsed time for vmscan and the number of page faults are reduced.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
