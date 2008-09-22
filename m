Date: Mon, 22 Sep 2008 19:51:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/13] memory cgroup updates v4
Message-Id: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a series of patches for memory resource controller.
Based on mmotm Sep18 ver. This passed some tests and seems works well.

This consists of followings

  - fixes.
    * fixes do_swap_page() handling.
  - new feature
    * "root" cgroup is treated as nolimit.
    * implements account_move() and move account at force_empty rather than
      forgeting all.
    * atomic page_cgroup->flags.
    * page_cgroup lookup system. (and page_cgroup.h is added.)
  - optimize.
    * per cpu status update.
  - remove page_cgroup pointer from struct page.
  - lazy lru add/remove
  
peformance is here. (on 8cpu Xeon/64bit) not so bad.

2.6.26-rc6-mm1(2008/9/18 version)
==
Execl Throughput                           2311.6 lps   (29.9 secs, 3 samples)
C Compiler Throughput                      1331.9 lpm   (60.4 secs, 3 samples)
Shell Scripts (1 concurrent)               7500.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)               3031.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)              1729.7 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places          99310.2 lpm   (30.0 secs, 3 samples)

afte all patches.
==
Execl Throughput                           2308.7 lps   (29.9 secs, 3 samples)
C Compiler Throughput                      1343.4 lpm   (60.3 secs, 3 samples)
Shell Scripts (1 concurrent)               7451.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)               3024.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)              1752.0 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places          99255.3 lpm   (30.0 secs, 3 samples)

after all patches + add padding to make "struct page" to be 64 bytes ;)
==
Execl Throughput                           2332.2 lps   (29.9 secs, 3 samples)
C Compiler Throughput                      1345.3 lpm   (60.4 secs, 3 samples)
Shell Scripts (1 concurrent)               7564.3 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)               3075.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)              1755.0 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places          99979.3 lpm   (30.0 secs, 3 samples)



This patch set saves 8bytes per page struct.
(when CONFIG_MEM_RES_CTLR=y but memcg is disabled at boot)
On this 48Gbytes machine, 48 * 1024 * 1024 * 1024 / 4096 * 8 = 96MB.
Maybe good for distros and users who don't want memcg.

Extra memory usage by this hash routine is 16k for root hash table on this
machine and 20bytes per 128MB. (and some per-cpu area.)

IMHO, because "lookup_page_cgroup" interface is added, updates/optimzation
for internal lookup method can be done later. (we can do some.)
So, I don't want to discuss special-lookup-support-for-some-memory-model
or which-is-quicker-lookup-method etc...too much here.

Brief description.

1/13 .... special mapping fix. (NEW)
     => avoid accounting pages not on LRU...which we cannot reclaim.

2/13 .... account swap-cache under lock.
     => move accounting of swap-cache under lock for avoiding unnecessary race.
         
3/13 .... make root cgroup to be unlimited.
     => fix root cgroup's memory limit to unlimited.

4/13 .... atomic-flags for page_cgroup
     => make page_cgroup->flags to be atomic.

5/13 .... implement move_account function.
     => add a function for moving page_cgroup's account to other cgroup.

6/13 ... force_empty to migrate account
     => move all account to root cgroup rather than forget all.

7/13 ...make mapping NULL (clean up)
     => ensure page->mapping to be NULL before calling mem_cgroup_uncharge_cache().

8/13 ...optimize cpustat
     => optimize access to per-cpu statistics for memcg.

9/13 ...lookup page_cgroup (CHANGED)
     => preallocate all page_cgroup at boot and remove page->page_cgroup pointer.

10/13...page_cgroup lookaside buffer 
     => helps looking up page_cgroup from page.

11/13...lazy lru freeing page_cgroup (NEW)
     => do removal from LRU in bached manner like pagevec.

12/13...lazy lru add page_cgroup (NEW)
     => do addition to LRU in bached manner like pagevec.

13/13...swap accountig fix. (NEW)
     => fix race in swap accounting (can be happen)
        and this intrduce new protocal as precharge/commit/cancel.

Some patches are big but not complicated I think.

patch 13/13 includes a brandnew concept.
So please review and tell me your opinion.


Thanks,
-Kame
    





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
