Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B75066B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:37:50 -0400 (EDT)
Date: Wed, 15 May 2013 13:37:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/9] Reduce system disruption due to kswapd V4
Message-Id: <20130515133748.5db2c6fb61c72ec61381d941@linux-foundation.org>
In-Reply-To: <1368432760-21573-1-git-send-email-mgorman@suse.de>
References: <1368432760-21573-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 13 May 2013 09:12:31 +0100 Mel Gorman <mgorman@suse.de> wrote:

> This series does not fix all the current known problems with reclaim but
> it addresses one important swapping bug when there is background IO.
> 
> ...
>
> This was tested using memcached+memcachetest while some background IO
> was in progress as implemented by the parallel IO tests implement in MM
> Tests. memcachetest benchmarks how many operations/second memcached can
> service and it is run multiple times. It starts with no background IO and
> then re-runs the test with larger amounts of IO in the background to roughly
> simulate a large copy in progress.  The expectation is that the IO should
> have little or no impact on memcachetest which is running entirely in memory.
> 
>                                         3.10.0-rc1                  3.10.0-rc1
>                                            vanilla            lessdisrupt-v4
> Ops memcachetest-0M             22155.00 (  0.00%)          22180.00 (  0.11%)
> Ops memcachetest-715M           22720.00 (  0.00%)          22355.00 ( -1.61%)
> Ops memcachetest-2385M           3939.00 (  0.00%)          23450.00 (495.33%)
> Ops memcachetest-4055M           3628.00 (  0.00%)          24341.00 (570.92%)
> Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)
> Ops io-duration-2385M             118.00 (  0.00%)             21.00 ( 82.20%)
> Ops io-duration-4055M             162.00 (  0.00%)             36.00 ( 77.78%)
> Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-715M             140134.00 (  0.00%)             18.00 ( 99.99%)
> Ops swaptotal-2385M            392438.00 (  0.00%)              0.00 (  0.00%)
> Ops swaptotal-4055M            449037.00 (  0.00%)          27864.00 ( 93.79%)
> Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-715M                     0.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-2385M               148031.00 (  0.00%)              0.00 (  0.00%)
> Ops swapin-4055M               135109.00 (  0.00%)              0.00 (  0.00%)
> Ops minorfaults-0M            1529984.00 (  0.00%)        1530235.00 ( -0.02%)
> Ops minorfaults-715M          1794168.00 (  0.00%)        1613750.00 ( 10.06%)
> Ops minorfaults-2385M         1739813.00 (  0.00%)        1609396.00 (  7.50%)
> Ops minorfaults-4055M         1754460.00 (  0.00%)        1614810.00 (  7.96%)
> Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)
> Ops majorfaults-715M              185.00 (  0.00%)            180.00 (  2.70%)
> Ops majorfaults-2385M           24472.00 (  0.00%)            101.00 ( 99.59%)
> Ops majorfaults-4055M           22302.00 (  0.00%)            229.00 ( 98.97%)

I doubt if many people have the context to understand what these
numbers really mean.  I don't.

> Note how the vanilla kernels performance collapses when there is enough
> IO taking place in the background. This drop in performance is part of
> what users complain of when they start backups. Note how the swapin and
> major fault figures indicate that processes were being pushed to swap
> prematurely. With the series applied, there is no noticable performance
> drop and while there is still some swap activity, it's tiny.
> 
>                             3.10.0-rc1  3.10.0-rc1
>                                vanilla lessdisrupt-v4
> Page Ins                       1234608      101892
> Page Outs                     12446272    11810468
> Swap Ins                        283406           0
> Swap Outs                       698469       27882
> Direct pages scanned                 0      136480
> Kswapd pages scanned           6266537     5369364
> Kswapd pages reclaimed         1088989      930832
> Direct pages reclaimed               0      120901
> Kswapd efficiency                  17%         17%
> Kswapd velocity               5398.371    4635.115
> Direct efficiency                 100%         88%
> Direct velocity                  0.000     117.817
> Percentage direct scans             0%          2%
> Page writes by reclaim         1655843     4009929
> Page writes file                957374     3982047
> Page writes anon                698469       27882
> Page reclaim immediate            5245        1745
> Page rescued immediate               0           0
> Slabs scanned                    33664       25216
> Direct inode steals                  0           0
> Kswapd inode steals              19409         778

The reduction in inode steals might be a significant thing? 
prune_icache_sb() does invalidate_mapping_pages() and can have the bad
habit of shooting down a vast number of pagecache pages (for a large
file) in a single hit.  Did this workload use large (and clean) files? 
Did you run any test which would expose this effect?

> ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
