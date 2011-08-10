Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 59B5E90013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 10:20:33 -0400 (EDT)
Date: Wed, 10 Aug 2011 16:20:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5 0/6]  memg: better numa scanning
Message-ID: <20110810142030.GD15007@tiehlicka.suse.cz>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
 <20110809143314.GJ7463@tiehlicka.suse.cz>
 <20110810091544.d73c7775.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110810091544.d73c7775.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed 10-08-11 09:15:44, KAMEZAWA Hiroyuki wrote:
> On Tue, 9 Aug 2011 16:33:14 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> > On Tue 09-08-11 19:04:50, KAMEZAWA Hiroyuki wrote:
[...]
> > > #!/bin/bash -x
> > > 
> > > cgset -r memory.limit_in_bytes=500M A
> > > 
> > > make -j 4 clean
> > > sync
> > > sync
> > > sync
> > > echo 3 > /proc/sys/vm/drop_caches
> > > sleep 1
> > > echo 0 > /cgroup/memory/A/memory.vmscan_stat
> > > cgexec -g memory:A -g cpuset:A time make -j 8
> > > ==
> > > 
> > > On 8cpu, 4-node fake-numa box.
> > 
> > How big are those nodes? I assume that you haven't used any numa
> > policies, right?
> > 
> 
> This box has 24GB memory and fake numa creates 6GBnode x 4.
> 
> [kamezawa@bluextal ~]$ grep MemTotal /sys/devices/system/node/node?/meminfo
> /sys/devices/system/node/node0/meminfo:Node 0 MemTotal:        6290360 kB
> /sys/devices/system/node/node1/meminfo:Node 1 MemTotal:        6291456 kB
> /sys/devices/system/node/node2/meminfo:Node 2 MemTotal:        6291456 kB
> /sys/devices/system/node/node3/meminfo:Node 3 MemTotal:        6291456 kB
> 
> 2 cpus per each node. (IIRC, Hyperthread)
> 
> [kamezawa@bluextal ~]$ ls -d /sys/devices/system/node/node?/cpu?
> /sys/devices/system/node/node0/cpu0  /sys/devices/system/node/node2/cpu2
> /sys/devices/system/node/node0/cpu4  /sys/devices/system/node/node2/cpu6
> /sys/devices/system/node/node1/cpu1  /sys/devices/system/node/node3/cpu3
> /sys/devices/system/node/node1/cpu5  /sys/devices/system/node/node3/cpu7
> 
> And yes, I don't use any numa policy other than spread-page.

OK, so the load should fit into a single node without spread-page.

> > > (each node has 2cpus.)
> > > 
> > > Under the limit of 500M, 'make' need to scan memory to reclaim.
> > > This tests see how vmscan works.
> > > 
> > > When cpuset.memory_spread_page==0.
> > 
> > > 
> > > [Before patch]
> > > 773.07user 305.45system 4:09.64elapsed 432%CPU (0avgtext+0avgdata 1456576maxresident)k
> > > 4397944inputs+5093232outputs (9688major+35689066minor)pagefaults 0swaps
> > > scanned_pages_by_limit 3867645
> > > scanned_anon_pages_by_limit 1518266
> > > scanned_file_pages_by_limit 2349379
> > > rotated_pages_by_limit 1502640
> > > rotated_anon_pages_by_limit 1416627
> > > rotated_file_pages_by_limit 86013
> > > freed_pages_by_limit 1005141
> > > freed_anon_pages_by_limit 24577
> > > freed_file_pages_by_limit 980564
> > > elapsed_ns_by_limit 82833866094
> > > 
> > > [Patched]
> > > 773.73user 305.09system 3:51.28elapsed 466%CPU (0avgtext+0avgdata 1458464maxresident)k
> > > 4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps
> > 
> > Hmm, 57% reduction of major page faults which doesn't fit with other
> > numbers. At least I do not see any corelation with them. Your workload
> > has freed more or less the same number of file pages (>1% less). Do you
> > have a theory for that?
> > 
> [Before] freed_anon_pages_by_limit 24577 
> [After]  freed_anon_pages_by_limit 20599
> 
> This reduces 3987 swap out. Changes in major fault is 4110.
> I think this is major reason to reduce the major faults.

Ahh, right you are.
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
