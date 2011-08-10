Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C47D26B00EE
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 20:23:06 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D51F23EE0C1
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:23:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B29E945DE86
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:23:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 834E245DE7A
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:23:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E4661DB8047
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:23:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ED881DB8038
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 09:23:02 +0900 (JST)
Date: Wed, 10 Aug 2011 09:15:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v5 0/6]  memg: better numa scanning
Message-Id: <20110810091544.d73c7775.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809143314.GJ7463@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
	<20110809143314.GJ7463@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Tue, 9 Aug 2011 16:33:14 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 09-08-11 19:04:50, KAMEZAWA Hiroyuki wrote:
> > 
> > No major update since the last version I posted 27/Jul.
> > The patch is rebased onto mmotm-Aug3.
> > 
> > This patch set implements a victim node selection logic and some
> > behavior fix in vmscan.c for memcg.
> > The logic calculates 'weight' for each nodes and a victim node
> > will be selected by comparing 'weight' in fair style.
> > The core is how to calculate 'weight' and this patch implements
> > a logic, which make use of recent lotation logic and the amount
> > of file caches and inactive anon pages.
> > 
> > I'll be absent in 12/Aug - 17/Aug.
> > I'm sorry if my response is delayed.
> > 
> > In this time, I did 'kernel make' test ...as
> > ==
> > #!/bin/bash -x
> > 
> > cgset -r memory.limit_in_bytes=500M A
> > 
> > make -j 4 clean
> > sync
> > sync
> > sync
> > echo 3 > /proc/sys/vm/drop_caches
> > sleep 1
> > echo 0 > /cgroup/memory/A/memory.vmscan_stat
> > cgexec -g memory:A -g cpuset:A time make -j 8
> > ==
> > 
> > On 8cpu, 4-node fake-numa box.
> 
> How big are those nodes? I assume that you haven't used any numa
> policies, right?
> 

This box has 24GB memory and fake numa creates 6GBnode x 4.

[kamezawa@bluextal ~]$ grep MemTotal /sys/devices/system/node/node?/meminfo
/sys/devices/system/node/node0/meminfo:Node 0 MemTotal:        6290360 kB
/sys/devices/system/node/node1/meminfo:Node 1 MemTotal:        6291456 kB
/sys/devices/system/node/node2/meminfo:Node 2 MemTotal:        6291456 kB
/sys/devices/system/node/node3/meminfo:Node 3 MemTotal:        6291456 kB

2 cpus per each node. (IIRC, Hyperthread)

[kamezawa@bluextal ~]$ ls -d /sys/devices/system/node/node?/cpu?
/sys/devices/system/node/node0/cpu0  /sys/devices/system/node/node2/cpu2
/sys/devices/system/node/node0/cpu4  /sys/devices/system/node/node2/cpu6
/sys/devices/system/node/node1/cpu1  /sys/devices/system/node/node3/cpu3
/sys/devices/system/node/node1/cpu5  /sys/devices/system/node/node3/cpu7

And yes, I don't use any numa policy other than spread-page.



> > (each node has 2cpus.)
> > 
> > Under the limit of 500M, 'make' need to scan memory to reclaim.
> > This tests see how vmscan works.
> > 
> > When cpuset.memory_spread_page==0.
> 
> > 
> > [Before patch]
> > 773.07user 305.45system 4:09.64elapsed 432%CPU (0avgtext+0avgdata 1456576maxresident)k
> > 4397944inputs+5093232outputs (9688major+35689066minor)pagefaults 0swaps
> > scanned_pages_by_limit 3867645
> > scanned_anon_pages_by_limit 1518266
> > scanned_file_pages_by_limit 2349379
> > rotated_pages_by_limit 1502640
> > rotated_anon_pages_by_limit 1416627
> > rotated_file_pages_by_limit 86013
> > freed_pages_by_limit 1005141
> > freed_anon_pages_by_limit 24577
> > freed_file_pages_by_limit 980564
> > elapsed_ns_by_limit 82833866094
> > 
> > [Patched]
> > 773.73user 305.09system 3:51.28elapsed 466%CPU (0avgtext+0avgdata 1458464maxresident)k
> > 4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps
> 
> Hmm, 57% reduction of major page faults which doesn't fit with other
> numbers. At least I do not see any corelation with them. Your workload
> has freed more or less the same number of file pages (>1% less). Do you
> have a theory for that?
> 
[Before] freed_anon_pages_by_limit 24577 
[After]  freed_anon_pages_by_limit 20599

This reduces 3987 swap out. Changes in major fault is 4110.
I think this is major reason to reduce the major faults.

> Is it possible that this is caused by "memcg: stop vmscan when enough
> done."?
> 

The patch is one of a help.

Assume nodes are in following state under limit=2000
     
       Node0   Node1   Node2   Node3
File   250     250       0     250
Anon   250     250      500    250

If select_victim_node() selects Node0, vmscan will visit
Node0->Node1->Node2->Node3 in zonelist order and cause swap-out in Node2.
"memcg: stop vmscan when enough done." will help to avoid scaning Node2
when Node0,Node1,Node3 are selected.

And other patches will help not to select Node2.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
