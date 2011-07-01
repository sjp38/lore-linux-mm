Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 511ED6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:59:42 -0400 (EDT)
Date: Fri, 1 Jul 2011 15:59:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback clustering
Message-ID: <20110701145935.GB29530@suse.de>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110701093305.GA28531@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, jack@suse.cz, linux-mm@kvack.org

On Fri, Jul 01, 2011 at 05:33:05AM -0400, Christoph Hellwig wrote:
> Johannes, Mel, Wu,

Am adding Jan Kara as he has been working on writeback efficiency
recently as well.

> Dave has been stressing some XFS patches of mine that remove the XFS
> internal writeback clustering in favour of using write_cache_pages.
> 

Against what kernel? 2.6.38 was a disaster for reclaim I've been
finding out this week. I don't know about 2.6.38.8. 2.6.39 was better.

> As part of investigating the behaviour he found out that we're still
> doing lots of I/O from the end of the LRU in kswapd.  Not only is that
> pretty bad behaviour in general, but it also means we really can't
> just remove the writeback clustering in writepage given how much
> I/O is still done through that.
> 
> Any chance we could the writeback vs kswap behaviour sorted out a bit
> better finally?
> 
> Some excerpts from the previous discussion:
> 
> On Fri, Jul 01, 2011 at 02:18:51PM +1000, Dave Chinner wrote:
> > I'm now only running test 180 on 100 files rather than the 1000 the
> > test normally runs on, because it's faster and still shows the
> > problem. 

I had stopped looking at writeback problems while Wu and Jan were
working on various writeback patchsets like io-less throttling. I
don't know where they currently stand and while I submitted a number
of reclaim patches since I last looked at this problem around 2.6.37,
they were related to migration, kswapd reclaiming too much memory
and kswapd using too much CPU - not writeback.

At the time I stopped, the tests I was looking at were writing very
few pages off the end of the LRU. Unfortunately I no longer have the
results to see but for unrelated reasons, I've been other regression
tests. Here is an example fsmark report over a number of kernels. The
machine used is old but unfortunately it's the only one I have a full
range of results at the moment.

FS-Mark
            fsmark-2.6.32.42-mainline-fsmarkfsmark-2.6.34.10-mainline-fsmarkfsmark-2.6.37.6-mainline-fsmarkfsmark-2.6.38-mainline-fsmarkfsmark-2.6.39-mainline-fsmark
            2.6.32.42-mainline2.6.34.10-mainline 2.6.37.6-mainline   2.6.38-mainline   2.6.39-mainline
Files/s  min         162.80 ( 0.00%)      156.20 (-4.23%)      155.60 (-4.63%)      157.80 (-3.17%)      151.10 (-7.74%)
Files/s  mean        173.77 ( 0.00%)      176.27 ( 1.42%)      168.19 (-3.32%)      172.98 (-0.45%)      172.05 (-1.00%)
Files/s  stddev        7.64 ( 0.00%)       12.54 (39.05%)        8.55 (10.57%)        8.39 ( 8.90%)       10.30 (25.77%)
Files/s  max         190.30 ( 0.00%)      206.80 ( 7.98%)      185.20 (-2.75%)      198.90 ( 4.32%)      201.00 ( 5.32%)
Overhead min     1742851.00 ( 0.00%)  1612311.00 ( 8.10%)  1251552.00 (39.26%)  1239859.00 (40.57%)  1393047.00 (25.11%)
Overhead mean    2443021.87 ( 0.00%)  2486525.60 (-1.75%)  2024365.53 (20.68%)  1849402.47 (32.10%)  1886692.53 (29.49%)
Overhead stddev   744034.70 ( 0.00%)   359446.19 (106.99%)   335986.49 (121.45%)   375627.48 (98.08%)   320901.34 (131.86%)
Overhead max     4744130.00 ( 0.00%)  3082235.00 (53.92%)  2561054.00 (85.24%)  2626346.00 (80.64%)  2559170.00 (85.38%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        624.12    647.61     658.8    670.78    653.98
Total Elapsed Time (seconds)               5767.71   5742.30   5974.45   5852.32   5760.49

MMTests Statistics: vmstat
Page Ins                                   3143712   3367600   3108596   3371952   3102548
Page Outs                                104939296 105255268 105126820 105130540 105226620
Swap Ins                                         0         0         0         0         0
Swap Outs                                        0         0         0         0         0
Direct pages scanned                          3521       131      7035         0         0
Kswapd pages scanned                      23596104  23662641  23588211  23695015  23638226
Kswapd pages reclaimed                    23594758  23661359  23587478  23693447  23637005
Direct pages reclaimed                        3521       131      7031         0         0
Kswapd efficiency                              99%       99%       99%       99%       99%
Kswapd velocity                           4091.070  4120.760  3948.181  4048.824  4103.510
Direct efficiency                             100%      100%       99%      100%      100%
Direct velocity                              0.610     0.023     1.178     0.000     0.000
Percentage direct scans                         0%        0%        0%        0%        0%
Page writes by reclaim                          75        32        37       252        44
Slabs scanned                              1843200   1927168   2714112   2801280   2738816
Direct inode steals                              0         0         0         0         0
Kswapd inode steals                        1827970   1822770   1669879   1819583   1681155
Compaction stalls                                0         0         0         0         0
Compaction success                               0         0         0         0         0
Compaction failures                              0         0         0         0         0
Compaction pages moved                           0         0         0    228180         0
Compaction move failure                          0         0         0    637776         0

The number of pages written from reclaim is exceptionally low (2.6.38
was a total disaster but that release was bad for a number of reasons,
haven't tested 2.6.38.8 yet) but reduced by 2.6.37 as expected. Direct
reclaim usage was reduced and efficiency (ratio of pages scanned to
pages reclaimed) was high.

As I look through the results I have at the moment, the number of
pages written back was simply really low which is why the problem fell
off my radar.

> > That means the test is only using 1GB of disk space, and
> > I'm running on a VM with 1GB RAM. It appears to be related to the VM
> > triggering random page writeback from the LRU - 100x10MB files more
> > than fills memory, hence it being the smallest test case i could
> > reproduce the problem on.
> > 

My tests were on a machine with 8G and ext3. I'm running some of
the tests against ext4 and xfs to see if that makes a difference but
it's possible the tests are simply not agressive enough so I want to
reproduce Dave's test if possible.

I'm assuming "test 180" is from xfstests which was not one of the tests
I used previously. To run with 1000 files instead of 100, was the file
"180" simply editted to make it look like this loop instead?

# create files and sync them
i=1;
while [ $i -lt 100 ]
do
        file=$SCRATCH_MNT/$i
        xfs_io -f -c "pwrite -b 64k -S 0xff 0 10m" $file > /dev/null
        if [ $? -ne 0 ]
        then
                echo error creating/writing file $file
                exit
        fi
        let i=$i+1
done

> > My triage notes are as follows, and the patch that fixes the bug is
> > attached below.
> > 
> > <SNIP>
> > 
> >            <...>-393   [000] 696245.229559: xfs_ilock_nowait:     dev 253:16 ino 0x244099 flags ILOCK_EXCL caller xfs_setfilesize
> >            <...>-393   [000] 696245.229560: xfs_setfilesize:      dev 253:16 ino 0x244099 isize 0xa00000 disize 0x94e000 new_size 0x0 offset 0x600000 count 3813376
> >            <...>-393   [000] 696245.229561: xfs_iunlock:          dev 253:16 ino 0x244099 flags ILOCK_EXCL caller xfs_setfilesize
> > 
> > For an IO that was from offset 0x600000 for just under 4MB. The end
> > of that IO is at byte 10104832, which is _exactly_ what the inode
> > size says it is.
> > 
> > It is very clear that from the IO completions that we are getting a
> > *lot* of kswapd driven writeback directly through .writepage:
> > 
> > $ grep "xfs_setfilesize:" t.t |grep "4096$" | wc -l
> > 801
> > $ grep "xfs_setfilesize:" t.t |grep -v "4096$" | wc -l
> > 78
> > 
> > So there's ~900 IO completions that change the file size, and 90% of
> > them are single page updates.
> > 
> > $ ps -ef |grep [k]swap
> > root       514     2  0 12:43 ?        00:00:00 [kswapd0]
> > $ grep "writepage:" t.t | grep "514 " |wc -l
> > 799
> > 
> > Oh, now that is too close to just be a co-incidence. We're getting
> > significant amounts of random page writeback from the the ends of
> > the LRUs done by the VM.
> > 
> > <sigh>

Does the value for nr_vmscan_write in /proc/vmstat correlate? It must
but lets me sure because I'm using that figure rather than ftrace to
count writebacks at the moment. A more relevant question is this -
how many pages were reclaimed by kswapd and what percentage is 799
pages of that? What do you consider an acceptable percentage?

> On Fri, Jul 01, 2011 at 07:20:21PM +1000, Dave Chinner wrote:
> > > Looks good.  I still wonder why I haven't been able to hit this.
> > > Haven't seen any 180 failure for a long time, with both 4k and 512 byte
> > > filesystems and since yesterday 1k as well.
> > 
> > It requires the test to run the VM out of RAM and then force enough
> > memory pressure for kswapd to start writeback from the LRU. The
> > reproducer I have is a 1p, 1GB RAM VM with it's disk image on a
> > 100MB/s HW RAID1 w/ 512MB BBWC disk subsystem.
> > 

You say it's a 1G VM but you don't say what architecure. What is
the size of the highest zone? If this is 32-bit x86 for example, the
highest zone is HighMem and it would be really small. Unfortunately
it would always be the first choice for allocating and reclaiming
from which would drastically increase the number of pages written back
from reclaim.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
