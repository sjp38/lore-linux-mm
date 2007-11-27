Date: Tue, 27 Nov 2007 11:55:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [0/10] introduction
Message-Id: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, this is per-zone/reclaim support patch set for memory controller (cgroup).

Major changes from previous one is
 -- tested with 2.6.24-rc3-mm1 + ia64/NUMA
 -- applied comments.

I did small test on real NUMA machine.
My machine was ia64/8CPU/2Node NUMA. I tried to complile the kernel under 800M
bytes limit with 32 parallel make. (make -j 32)

 - 2.6.24-rc3-mm1 (+ scsi fix) .... shows soft lock-up.
   before soft lock-up, %sys was almost 100% in several times.

 - 2.6.24-rc3-mm1 (+ scsi fix) + this set .... completed succesfully
   It seems %iowait dominates the total performance.
   (current memory controller has no background reclaim)

Seems this set give us some progress.

(*) I'd like to merge YAMAMOTO-san's background page reclaim for memory
    controller before discussing about the number of performance.

Andrew, could you pick these up to -mm ?

Patch series brief description:

[1/10] ... add scan_global_lru() macro  (clean up)
[2/10] ... nid/zid helper function for cgroup
[3/10] ... introduce per-zone object for memory controller and add
           active/inactive counter.
[4/10] ... calculate mapper_ratio per cgroup (for memory reclaim)
[5/10] ... calculate active/inactive imbalance per cgroup (based on [3])
[6/10] ... remember reclaim priority in memory controller
[7/10] ... calculate the number of pages to be reclaimed per cgroup

[8/10] ... modifies vmscan.c to isolate global-lru-reclaim and
           memory-cgroup-reclaim in obvious manner.
           (this patch uses functions defined in [4 - 7])
[9/10] ... implement per-zone-lru for cgroup (based on [3])
[10/10] ... implement per-zone lru lock for cgroup (based on [3][9])

Any comments are welcome.

Thanks,
-Kame
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
