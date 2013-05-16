Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id A65156B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 06:33:52 -0400 (EDT)
Date: Thu, 16 May 2013 11:33:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-ID: <20130516103344.GF11497@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
 <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 15, 2013 at 01:37:48PM -0700, Andrew Morton wrote:
> On Mon, 13 May 2013 09:12:31 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > This series does not fix all the current known problems with reclaim but
> > it addresses one important swapping bug when there is background IO.
> > 
> > ...
> >
> > This was tested using memcached+memcachetest while some background IO
> > was in progress as implemented by the parallel IO tests implement in MM
> > Tests. memcachetest benchmarks how many operations/second memcached can
> > service and it is run multiple times. It starts with no background IO and
> > then re-runs the test with larger amounts of IO in the background to roughly
> > simulate a large copy in progress.  The expectation is that the IO should
> > have little or no impact on memcachetest which is running entirely in memory.
> > 
> >                                         3.10.0-rc1                  3.10.0-rc1
> >                                            vanilla            lessdisrupt-v4
> > Ops memcachetest-0M             22155.00 (  0.00%)          22180.00 (  0.11%)
> > Ops memcachetest-715M           22720.00 (  0.00%)          22355.00 ( -1.61%)
> > Ops memcachetest-2385M           3939.00 (  0.00%)          23450.00 (495.33%)
> > Ops memcachetest-4055M           3628.00 (  0.00%)          24341.00 (570.92%)
> > Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> > Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)
> > Ops io-duration-2385M             118.00 (  0.00%)             21.00 ( 82.20%)
> > Ops io-duration-4055M             162.00 (  0.00%)             36.00 ( 77.78%)
> > Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swaptotal-715M             140134.00 (  0.00%)             18.00 ( 99.99%)
> > Ops swaptotal-2385M            392438.00 (  0.00%)              0.00 (  0.00%)
> > Ops swaptotal-4055M            449037.00 (  0.00%)          27864.00 ( 93.79%)
> > Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-715M                     0.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-2385M               148031.00 (  0.00%)              0.00 (  0.00%)
> > Ops swapin-4055M               135109.00 (  0.00%)              0.00 (  0.00%)
> > Ops minorfaults-0M            1529984.00 (  0.00%)        1530235.00 ( -0.02%)
> > Ops minorfaults-715M          1794168.00 (  0.00%)        1613750.00 ( 10.06%)
> > Ops minorfaults-2385M         1739813.00 (  0.00%)        1609396.00 (  7.50%)
> > Ops minorfaults-4055M         1754460.00 (  0.00%)        1614810.00 (  7.96%)
> > Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> > Ops majorfaults-715M              185.00 (  0.00%)            180.00 (  2.70%)
> > Ops majorfaults-2385M           24472.00 (  0.00%)            101.00 ( 99.59%)
> > Ops majorfaults-4055M           22302.00 (  0.00%)            229.00 ( 98.97%)
> 
> I doubt if many people have the context to understand what these
> numbers really mean.  I don't.
> 

I should have stuck in a Sad Face/Happy Face index. You're right though,
there isn't much help explaining the figures here. Do you want to replace
the brief paragraph talking about these figures with the following?

20 iterations of this test were run in total and averaged. Every 5
iterations, additional IO was generated in the background using dd to
measure how the workload was impacted. The 0M, 715M, 2385M and 4055M subblock
refer to the amount of IO going on in the background at each iteration. So
memcachetest-2385M is reporting how many transactions/second memcachetest
recorded on average over 5 iterations while there was 2385M of IO going
on in the ground. There are six blocks of information reported here

memcachetest is the transactions/second reported by memcachetest. In
	the vanilla kernel note that performance drops from around
	22K/sec to just under 4K/second when there is 2385M of IO going
	on in the background. This is one type of performance collapse
	users complain about if a large cp or backup starts in the
	background

io-duration refers to how long it takes for the background IO to
	complete. It's showing that with the patched kernel that the IO
	completes faster while not interfering with the memcache
	workload

swaptotal is the total amount of swap traffic. With the patched kernel,
	the total amount of swapping is much reduced although it is
	still not zero.

swapin in this case is an indication as to whether we are swap trashing.
	The closer the swapin/swapout ratio is to 0, the worse the
	trashing is.  Note with the patched kernel that there is no swapin
	activity indicating that all the pages swapped were really inactive
	unused pages.

minorfaults are just minor faults. An increased number of minor faults
	can indicate that page reclaim is unmapping the pages but not
	swapping them out before they are faulted back in. With the
	patched kernel, there is only a small change in minor faults

majorfaults are just major faults in the target workload and a high
	number can indicate that a workload is being prematurely
	swapped. With the patched kernel, major faults are much reduced. As
	there are no swapin's recorded so it's not being swapped. The likely
	explanation is that that libraries or configuration files used by
	the workload during startup get paged out by the background IO.

Overall with the series applied, there is no noticable performance drop due
to background IO and while there is still some swap activity, it's tiny and
the lack of swapins imply that the swapped pages were inactive and unused.

> > Note how the vanilla kernels performance collapses when there is enough
> > IO taking place in the background. This drop in performance is part of
> > what users complain of when they start backups. Note how the swapin and
> > major fault figures indicate that processes were being pushed to swap
> > prematurely. With the series applied, there is no noticable performance
> > drop and while there is still some swap activity, it's tiny.
> > 
> >                             3.10.0-rc1  3.10.0-rc1
> >                                vanilla lessdisrupt-v4
> > Page Ins                       1234608      101892
> > Page Outs                     12446272    11810468
> > Swap Ins                        283406           0
> > Swap Outs                       698469       27882
> > Direct pages scanned                 0      136480
> > Kswapd pages scanned           6266537     5369364
> > Kswapd pages reclaimed         1088989      930832
> > Direct pages reclaimed               0      120901
> > Kswapd efficiency                  17%         17%
> > Kswapd velocity               5398.371    4635.115
> > Direct efficiency                 100%         88%
> > Direct velocity                  0.000     117.817
> > Percentage direct scans             0%          2%
> > Page writes by reclaim         1655843     4009929
> > Page writes file                957374     3982047
> > Page writes anon                698469       27882
> > Page reclaim immediate            5245        1745
> > Page rescued immediate               0           0
> > Slabs scanned                    33664       25216
> > Direct inode steals                  0           0
> > Kswapd inode steals              19409         778
> 
> The reduction in inode steals might be a significant thing? 

It might. It could either be a reflection of kswap writing fewer swap
pages, reaching the high watermark more quicky and calling shrink_slab()
fewer times overall. This is semi-supported by the reduced slabs scanned
figures.

It could also be a reflection of the IO completing faster. The IO is
generated with dd conv=fdatasync to a single dirty file. If it's getting
pruned during the IO then there will be further delay while the metadata
is re-read from disk. With the series applied, the IO completes faster, it
gets cleaned sooner and when prune_icache_sb invalidates it, it does not get
re-read from disk again -- or at least it gets read back in fewer times..
satisfactory solid explanation.

> prune_icache_sb() does invalidate_mapping_pages() and can have the bad
> habit of shooting down a vast number of pagecache pages (for a large
> file) in a single hit.  Did this workload use large (and clean) files? 
> Did you run any test which would expose this effect?
> 

It uses a single large file for writing so how clean it is depends on
the flushers and how long before dd calls fdatasync

I ran with fsmark in single threaded mode for large numbers of 30M files
filling memory, postmark tuned to fill memory and a basic largedd test --
all mixed read/write workloads. The performance was not obviously affected
by the series.  The overall number of slabs scanned and inodes reclaimed
varied between the tests. Some reclaimed more, some less. I graphed the
slabs scanned over time and found

postmark - single large spike with the series applied at the start,
	otherwise almost identicial levels of scanning. inode reclaimed
	from kswapd were slightly higher over time but not by much

largedd - patched series had a few reclaim spikes but again it was more
	reclaiming overall but broadly similar behaviour to the vanilla
	kernel

fsmark - the patched series showed steady slab scanning throughout the
	lifetime of the test unlike the vanilla kernel which had a
	single large spike at the start. However, very few inodes were
	actually reclaimed, it was scanning activity only and actual
	performance of the benchmark was unchanged.

Overall nothing horrible fell out. I'll run a sysbench test in read-only
mode which would be closer to the workload you have in mind and see what
falls out.

Thanks Andrew.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
