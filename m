Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 537F78D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 01:18:15 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p1I6HxjO028843
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:47:59 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1I6HxTf4071632
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:47:59 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1I6HvLg029567
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 17:17:58 +1100
Date: Fri, 18 Feb 2011 11:25:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 0/4] fadvise(DONTNEED) support
Message-ID: <20110218055505.GA2648@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <cover.1297940291.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <cover.1297940291.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Barrett <damentz@liquorix.net>, Ben Gamari <bgamari.foss@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

* MinChan Kim <minchan.kim@gmail.com> [2011-02-18 00:08:18]:

> Sorry for my laziness. It's time to repost with some test result.
> 
> Recently, there was a reported problem about thrashing.
> (http://marc.info/?l=rsync&m=128885034930933&w=2)
> It happens by backup workloads(ex, nightly rsync).
> That's because the workload makes just use-once pages
> and touches pages twice. It promotes the page into
> active list so that it results in working set page eviction.
> So app developer want to support POSIX_FADV_NOREUSE but other OSes include linux 
> don't support it. (http://marc.info/?l=linux-mm&m=128928979512086&w=2)
> 
> By other approach, app developers use POSIX_FADV_DONTNEED.
> But it has a problem. If kernel meets page is going on writing
> during invalidate_mapping_pages, it can't work.
> It makes application programmer to use it hard since they always 
> consider sync data before calling fadivse(..POSIX_FADV_DONTNEED) to 
> make sure the pages couldn't be discardable. At last, they can't use
> deferred write of kernel so see performance loss.
> (http://insights.oetiker.ch/linux/fadvise.html)
> 
> In fact, invalidation is very big hint to reclaimer.
> It means we don't use the page any more. So the idea in this series is that
> let's move invalidated pages but not-freed page until into inactive list.
> It can help relcaim efficiency very much so that it can prevent
> eviction working set.
> 
> My exeperiment is folowing as.
> 
> Test Environment :
> DRAM : 2G, CPU : Intel(R) Core(TM)2 CPU
> Rsync backup directory size : 16G
> 
> rsync version is 3.0.7.
> rsync patch is Ben's fadivse.
> The stress scenario do following jobs with parallel.
> 
> 1. git clone linux-2.6
> 1. make all -j4 linux-mmotm
> 3. rsync src dst
> 
> nrns : no-patched rsync + no stress
> prns : patched rsync + no stress
> nrs  : no-patched rsync + stress
> prs  : patched rsync + stress
> 
> For profiling, I add some vmstat.
> pginvalidate : the total number of pages which are moved by this patch.
> pgreclaim : the number of pages which are moved at inactive's tail by PG_reclaim of pginvalidate
> 
>                         NRNS    PRNS    NRS     PRS 
> Elapsed time            36:01.49        37:13.58        01:23:24        01:21:45
> nr_vmscan_write         184     1       296     509 
> pgactivate              76559   84714   445214  463143
> pgdeactivate            19360   40184   74302   91423
> pginvalidate            0       2240333 0       1769147
> pgreclaim               0       1849651 0       1650796
> pgfault                 406208  421860  72485217        70334416
> pgmajfault              212     334     5149    3688
> pgsteal_dma             0       0       0       0   
> pgsteal_normal          2645174 1545116 2521098 1578651
> pgsteal_high            5162080 2562269 6074720 3137294
> pgsteal_movable         0       0       0       0   
> pgscan_kswapd_dma       0       0       0       0   
> pgscan_kswapd_normal    2641732 1545374 2499894 1557882
> pgscan_kswapd_high      5143794 2567981 5999585 3051150
> pgscan_kswapd_movable   0       0       0       0   
> pgscan_direct_dma       0       0       0       0   
> pgscan_direct_normal    3643    0       21613   21238
> pgscan_direct_high      20174   1783    76980   87848
> pgscan_direct_movable   0       0       0       0   
> pginodesteal            130     1029    3510    24100
> slabs_scanned           1421824 1648128 1870720 1880320
> kswapd_steal            7785153 4105620 8498332 4608372
> kswapd_inodesteal       189432  474052  342835  472503
> pageoutrun              100687  52282   145712  70946
> allocstall              22      1       149     163 
> pgrotated               0       2231408 2932    1765393
> unevictable_pgs_scanned 0       0       0       0   
>

The results do look impressive
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
