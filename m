Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CA6FE6B016B
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 10:33:28 -0400 (EDT)
Date: Tue, 9 Aug 2011 16:33:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 0/6]  memg: better numa scanning
Message-ID: <20110809143314.GJ7463@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Tue 09-08-11 19:04:50, KAMEZAWA Hiroyuki wrote:
> 
> No major update since the last version I posted 27/Jul.
> The patch is rebased onto mmotm-Aug3.
> 
> This patch set implements a victim node selection logic and some
> behavior fix in vmscan.c for memcg.
> The logic calculates 'weight' for each nodes and a victim node
> will be selected by comparing 'weight' in fair style.
> The core is how to calculate 'weight' and this patch implements
> a logic, which make use of recent lotation logic and the amount
> of file caches and inactive anon pages.
> 
> I'll be absent in 12/Aug - 17/Aug.
> I'm sorry if my response is delayed.
> 
> In this time, I did 'kernel make' test ...as
> ==
> #!/bin/bash -x
> 
> cgset -r memory.limit_in_bytes=500M A
> 
> make -j 4 clean
> sync
> sync
> sync
> echo 3 > /proc/sys/vm/drop_caches
> sleep 1
> echo 0 > /cgroup/memory/A/memory.vmscan_stat
> cgexec -g memory:A -g cpuset:A time make -j 8
> ==
> 
> On 8cpu, 4-node fake-numa box.

How big are those nodes? I assume that you haven't used any numa
policies, right?

> (each node has 2cpus.)
> 
> Under the limit of 500M, 'make' need to scan memory to reclaim.
> This tests see how vmscan works.
> 
> When cpuset.memory_spread_page==0.

> 
> [Before patch]
> 773.07user 305.45system 4:09.64elapsed 432%CPU (0avgtext+0avgdata 1456576maxresident)k
> 4397944inputs+5093232outputs (9688major+35689066minor)pagefaults 0swaps
> scanned_pages_by_limit 3867645
> scanned_anon_pages_by_limit 1518266
> scanned_file_pages_by_limit 2349379
> rotated_pages_by_limit 1502640
> rotated_anon_pages_by_limit 1416627
> rotated_file_pages_by_limit 86013
> freed_pages_by_limit 1005141
> freed_anon_pages_by_limit 24577
> freed_file_pages_by_limit 980564
> elapsed_ns_by_limit 82833866094
> 
> [Patched]
> 773.73user 305.09system 3:51.28elapsed 466%CPU (0avgtext+0avgdata 1458464maxresident)k
> 4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps

Hmm, 57% reduction of major page faults which doesn't fit with other
numbers. At least I do not see any corelation with them. Your workload
has freed more or less the same number of file pages (>1% less). Do you
have a theory for that?

Is it possible that this is caused by "memcg: stop vmscan when enough
done."?

> 
> scanned_pages_by_limit 4326462
> scanned_anon_pages_by_limit 1310619
> scanned_file_pages_by_limit 3015843
> rotated_pages_by_limit 1264223
> rotated_anon_pages_by_limit 1247180
> rotated_file_pages_by_limit 17043
> freed_pages_by_limit 1003434
> freed_anon_pages_by_limit 20599
> freed_file_pages_by_limit 982835
> elapsed_ns_by_limit 42495200307
> 
> elapsed time for vmscan and the number of page faults are reduced.
> 
> 
> When cpuset.memory_spread_page==1, in this case, file cache will be
> spread to the all nodes in round robin.
> ==
> [Before Patch + cpuset spread=1]
> 773.23user 309.55system 4:26.83elapsed 405%CPU (0avgtext+0avgdata 1457696maxresident)k
> 5400928inputs+5105368outputs (17344major+35735886minor)pagefaults 0swaps
> 
> scanned_pages_by_limit 3731787
> scanned_anon_pages_by_limit 1374310
> scanned_file_pages_by_limit 2357477
> rotated_pages_by_limit 1403160
> rotated_anon_pages_by_limit 1293568
> rotated_file_pages_by_limit 109592
> freed_pages_by_limit 1120828
> freed_anon_pages_by_limit 20076
> freed_file_pages_by_limit 1100752
> elapsed_ns_by_limit 82458981267
> 
> 
> [Patched + cpuset spread=1]
> 773.56user 306.02system 3:52.28elapsed 464%CPU (0avgtext+0avgdata 1458160maxresident)k
> 4173504inputs+4783688outputs (5971major+35666498minor)pagefaults 0swaps

page fauls and time seem to be consistent with the previous test which
is really good. 

> 
> scanned_pages_by_limit 2672392
> scanned_anon_pages_by_limit 1140069
> scanned_file_pages_by_limit 1532323
> rotated_pages_by_limit 1108124
> rotated_anon_pages_by_limit 1088982
> rotated_file_pages_by_limit 19142
> freed_pages_by_limit 975653
> freed_anon_pages_by_limit 12578
> freed_file_pages_by_limit 963075
> elapsed_ns_by_limit 46482588602
> 
> elapsed time for vmscan and the number of page faults are reduced.
> 
> Thanks,
> -Kame

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
