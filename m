Message-Id: <20080719132959.550229715@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 22:29:59 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 0/3] page reclaim throttle v8
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

-- 

Hi,

This patch is latest page reclaim throttle patch.



changelog
========================================
  v7 -> v8
     o remove Kconfig parameter.
     o merge throtte patch and sysctl parameter adding patch.
     o add some patch description.

  v6 -> v7
     o rebase to 2.6.26-rc2-mm1
     o get_vm_stat: make cpu-unplug safety.
     o mark vm_max_nr_task_per_zone __read_mostly.
     o add check __GFP_FS, __GFP_IO for avoid deadlock.
     o fixed compile error on x86_64.

  v5 -> v6
     o rebase to 2.6.25-mm1
     o use PGFREE statics instead wall time.
     o separate function type change patch and introduce throttle patch.

  v4 -> v5
     o rebase to 2.6.25-rc8-mm1

  v3 -> v4:
     o fixed recursive shrink_zone problem.
     o add last_checked variable in shrink_zone for 
       prevent corner case regression.

  v2 -> v3:
     o use wake_up() instead wake_up_all()
     o max reclaimers can be changed Kconfig option and sysctl.
     o some cleanups

  v1 -> v2:
     o make per zone throttle 



background
=====================================
current VM implementation doesn't has limit of number of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

at end of last year, KAMEZAWA Hiroyuki proposed the patch of page 
reclaim throttle and explain it improve reclaim time.
	http://marc.info/?l=linux-mm&m=119667465917215&w=2

but unfortunately it works only memcgroup reclaim.
since, I implement it again for support global reclaim and mesure it.


benefit
=====================================
<<1. fixed a bug of incorrect OOM killer>>

if do following command, sometimes OOM killer happened.
(OOM happend about 10%)

 $ ./hackbench 125 process 1000

because following bad scenario is happend.

   1. memory shortage happend.
   2. many task call shrink_zone() at the same time.
   3. thus, All page are isolated from LRU at the same time.
   4. if another task call shrink_zone() in addition, it can't isolate any page from LRU.
   5. Then, it cause reclaim failure and OOM killer.

my patch is solution for that problem directly.


<<2. performance improvement>>
I mesured performance by hackbench.
result number mean seconds (i.e. smaller is better)


                                              improvement
   num_group   2.6.26-rc8-mm1   + throttle    ratio
   -----------------------------------------------------------------
   100          39.262           39.035
   110          42.051           46.697
   120          45.153           45.685
   130          73.325           57.183
   140          87.830           63.791       
   150         947.493          113.231       >800%

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
