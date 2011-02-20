Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD588D0039
	for <linux-mm@kvack.org>; Sun, 20 Feb 2011 09:44:03 -0500 (EST)
Received: by iyf13 with SMTP id 13so1895210iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Feb 2011 06:43:59 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v6 0/4] fadvise(DONTNEED) support
Date: Sun, 20 Feb 2011 23:43:35 +0900
Message-Id: <cover.1298212517.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

Recently, there was a reported problem about thrashing.
(http://marc.info/?l=rsync&m=128885034930933&w=2)
It happens by backup workloads(ex, nightly rsync).
That's because the workload makes just use-once pages
and touches pages twice. It promotes the page into
active list so that it results in working set page eviction.
So app developer want to support POSIX_FADV_NOREUSE but other OSes include linux 
don't support it. (http://marc.info/?l=linux-mm&m=128928979512086&w=2)

By other approach, app developers use POSIX_FADV_DONTNEED.
But it has a problem. If kernel meets page is going on writing
during invalidate_mapping_pages, it can't work.
It makes application programmer to use it hard since they always 
consider sync data before calling fadivse(..POSIX_FADV_DONTNEED) to 
make sure the pages couldn't be discardable. At last, they can't use
deferred write of kernel so see performance loss.
(http://insights.oetiker.ch/linux/fadvise.html)

In fact, invalidation is very big hint to reclaimer.
It means we don't use the page any more. So the idea in this series is that
let's move invalidated pages but not-freed page until into inactive list.
It can help relcaim efficiency very much so that it can prevent
eviction working set.

My exeperiment is folowing as.

Test Environment :
DRAM : 2G, CPU : Intel(R) Core(TM)2 CPU
Rsync backup directory size : 16G

rsync version is 3.0.7.
rsync patch is Ben's fadivse.
The stress scenario do following jobs with parallel.

1. git clone linux-2.6
1. make all -j4 linux-mmotm
3. rsync src dst

nrns : no-patched rsync + no stress
prns : patched rsync + no stress
nrs  : no-patched rsync + stress
prs  : patched rsync + stress

For profiling, I added some vmstat.
pginvalidate : the total number of pages which are moved by invalidate_mapping_pages
pgreclaim : the number of pages which are moved at inactive's tail by PG_reclaim of pginvalidate

                        NRNS    PRNS    NRS     PRS 
Elapsed time            36:01.49        37:13.58        01:23:24        01:21:45
nr_vmscan_write         184     1       296     509 
pgactivate              76559   84714   445214  463143
pgdeactivate            19360   40184   74302   91423
pginvalidate            0       2240333 0       1769147
pgreclaim               0       1849651 0       1650796
pgfault                 406208  421860  72485217        70334416
pgmajfault              212     334     5149    3688
pgsteal_dma             0       0       0       0   
pgsteal_normal          2645174 1545116 2521098 1578651
pgsteal_high            5162080 2562269 6074720 3137294
pgsteal_movable         0       0       0       0   
pgscan_kswapd_dma       0       0       0       0   
pgscan_kswapd_normal    2641732 1545374 2499894 1557882
pgscan_kswapd_high      5143794 2567981 5999585 3051150
pgscan_kswapd_movable   0       0       0       0   
pgscan_direct_dma       0       0       0       0   
pgscan_direct_normal    3643    0       21613   21238
pgscan_direct_high      20174   1783    76980   87848
pgscan_direct_movable   0       0       0       0   
pginodesteal            130     1029    3510    24100
slabs_scanned           1421824 1648128 1870720 1880320
kswapd_steal            7785153 4105620 8498332 4608372
kswapd_inodesteal       189432  474052  342835  472503
pageoutrun              100687  52282   145712  70946
allocstall              22      1       149     163 
pgrotated               0       2231408 2932    1765393
unevictable_pgs_scanned 0       0       0       0   

In stress test(NRS vs PRS), pgsteal_[normal|high] are reduced by 37% and 48%.
pgscan_kswapd_[normal|high] are reduced by 37% and 49%.
It means although the VM scan small window, it can reclaim enough pages to work well and
prevent eviction unnecessary page.
rsync program's elapsed time is reduced by 1.5 minutes but I think rsync's fadvise 
isn't good because [NRNS vs NRS] it takes one minutes longer time. 
I think it's because calling unnecessary fadivse system calls so that 
rsync's fadvise should be smart then effect would be much better than now.
The pgmajor fault is reduced by 28%. It's good.
What I can't understand is that why inode steal is increased.
If anyone know it, please explain to me.
Anyway, this patch improves reclaim efficiency very much.

Recently, Steven Barrentt already applied this series to his project kernel 
"Liquorix kernel" and said followin as with one problem.
(The problem is solved by [3/4]. See the description)

" I've been having really good results with your new patch set that
mitigates the problem where a backup utility or something like that
reads each file once and eventually evicting the original working set
out of the page cache.
...
...
 These patches solved some problems on a friend's desktop.
 He said that his wife wanted to send me kisses and hugs because their
computer was so responsive after the patches were applied.
"
So I think this patch series solves real problem.

 - [1/3] is to move invalidated page which is dirty/writeback on active list
   into inactive list's head.
 - [2/3] is to move memcg reclaimable page on inactive's tail.
 - [3/3] is for moving invalidated page into inactive list's tail when the
   page's writeout is completed for reclaim asap.

This patches are based on mmotm-02-04

Changelog since v5:
 - Remove vmstat patch as profiling for final merge

Changelog since v4:
 - Remove patches related to madvise and clean up patch of swap.c
   (I will separate madvise issue from this series and repost after merging this series)

Minchan Kim (3):
  deactivate invalidated pages
  memcg: move memcg reclaimable page into tail of inactive list
  Reclaim invalidated page ASAP

 include/linux/memcontrol.h |    6 ++
 include/linux/swap.h       |    1 +
 mm/memcontrol.c            |   27 ++++++++++
 mm/page-writeback.c        |   12 ++++-
 mm/swap.c                  |  116 +++++++++++++++++++++++++++++++++++++++++++-
 mm/truncate.c              |   17 +++++--
 6 files changed, 172 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
