Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id C765A6B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 05:02:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so65536779lfa.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 02:02:27 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id o194si13913597wmg.138.2016.07.11.02.02.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jul 2016 02:02:26 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id B0A6498AEC
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 09:02:25 +0000 (UTC)
Date: Mon, 11 Jul 2016 10:02:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160711090224.GB9806@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
 <20160707232713.GM27480@dastard>
 <20160708095203.GB11498@techsingularity.net>
 <20160711004757.GN12670@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160711004757.GN12670@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 11, 2016 at 10:47:57AM +1000, Dave Chinner wrote:
> > I had tested XFS with earlier releases and noticed no major problems
> > so later releases tested only one filesystem.  Given the changes since,
> > a retest is desirable. I've posted the current version of the series but
> > I'll queue the tests to run over the weekend. They are quite time consuming
> > to run unfortunately.
> 
> Understood. I'm not following the patchset all that closely, so I
> didn' know you'd already tested XFS.
> 

It was needed anyway. Not all of them completed over the weekend. In
particular, the NUMA machine is taking its time because many of the
workloads are scaled by memory size and it takes longer.

> > On the fsmark configuration, I configured the test to use 4K files
> > instead of 0-sized files that normally would be used to stress inode
> > creation/deletion. This is to have a mix of page cache and slab
> > allocations. Shout if this does not suit your expectations.
> 
> Sounds fine. I usually limit that test to 10 million inodes - that's
> my "10-4" test.
> 

Thanks.


I'm not going to go through most of the results in detail. The raw data
is verbose and not necessarily useful in most cases.

tiobench
	Similar results to ext4, similar performance, similar reclaim
	activity

pgbench
	Similar performance results to ext4. Minor differences in
	reclaim activity. The series did enter direct reclaim which the
	mmotm kernel did not. However, it was one minor spike. kswapd
	activity was almost identical.

bonnie
	Similar performance results to ext4, minor differences in
	reclaim activity

parallel dd

	Similar performance results to ext4. Small differences in reclaim
	activity. Again, there was a slight increase in direct reclaim
	activity but negligble in comparison to the overall workload.
	Average direct reclaim velocity was 1.8 pages per second and
	direct reclaim page scans were 0.018% of all scans.

stutter
	Similar performance results to ext4, similar reclaim activity

These observations are all based on two UMA machines.

fsmark 50m-inodes-4k-files-16-threads
=====================================

As fsmark can be variable, this is reported as quartiles. This is one of
the UMA machines;

                                     4.7.0-rc4             4.7.0-rc4
                                mmotm-20160623           approx-v9r6
Min         files/sec-16     2354.80 (  0.00%)     2255.40 ( -4.22%)
1st-qrtle   files/sec-16     3254.90 (  0.00%)     3249.40 ( -0.17%)
2nd-qrtle   files/sec-16     3310.10 (  0.00%)     3306.70 ( -0.10%)
3rd-qrtle   files/sec-16     3353.40 (  0.00%)     3329.00 ( -0.73%)
Max-90%     files/sec-16     3435.70 (  0.00%)     3426.90 ( -0.26%)
Max-93%     files/sec-16     3437.80 (  0.00%)     3462.50 (  0.72%)
Max-95%     files/sec-16     3471.60 (  0.00%)     3536.50 (  1.87%)
Max-99%     files/sec-16     5383.90 (  0.00%)     5900.00 (  9.59%)
Max         files/sec-16     5383.90 (  0.00%)     5900.00 (  9.59%)
Mean        files/sec-16     3342.99 (  0.00%)     3329.64 ( -0.40%)

           4.7.0-rc4   4.7.0-rc4
        mmotm-20160623 approx-v9r6
User          188.46      187.14
System       2964.26     2972.35
Elapsed     10222.83     9865.87

Direct pages scanned            144365      189738
Kswapd pages scanned          13147349    12965288
Kswapd pages reclaimed        13144543    12962266
Direct pages reclaimed          144365      189738
Kswapd efficiency                  99%         99%
Kswapd velocity               1286.077    1314.156
Direct efficiency                 100%        100%
Direct velocity                 14.122      19.232
Percentage direct scans             1%          1%
Slabs scanned                 52563968    52672128
Direct inode steals                132          24
Kswapd inode steals              18234       12096

The performance is comparable and so is slab reclaim activity. The NUMA
machine had completed the same test. On the NUMA machine, there is a also
a slight increase in direct reclaim activity but as a tiny percentage
overall. Slab scan and reclaim activity is almost identical.

fsmark 50m-inodes-0k-files-16-threads
=====================================

I also tested with zero-sized files. The UMA machine showed nothing
interesting, the NUMA machine results were as follows;

                                     4.7.0-rc4             4.7.0-rc4
                                mmotm-20160623           approx-v9r6
Min         files/sec-16   108235.50 (  0.00%)   120783.20 ( 11.59%)
1st-qrtle   files/sec-16   129569.40 (  0.00%)   132300.70 (  2.11%)
2nd-qrtle   files/sec-16   135544.90 (  0.00%)   141198.40 (  4.17%)
3rd-qrtle   files/sec-16   139634.90 (  0.00%)   148242.50 (  6.16%)
Max-90%     files/sec-16   144203.60 (  0.00%)   152247.10 (  5.58%)
Max-93%     files/sec-16   145294.50 (  0.00%)   152642.20 (  5.06%)
Max-95%     files/sec-16   146009.70 (  0.00%)   153355.20 (  5.03%)
Max-99%     files/sec-16   148346.80 (  0.00%)   156353.50 (  5.40%)
Max         files/sec-16   149800.20 (  0.00%)   158316.50 (  5.69%)
Mean        files/sec-16   133796.64 (  0.00%)   140393.61 (  4.93%)
Best99%Mean files/sec-16   149800.20 (  0.00%)   158316.50 (  5.69%)
Best95%Mean files/sec-16   147819.92 (  0.00%)   155778.74 (  5.38%)
Best90%Mean files/sec-16   146541.61 (  0.00%)   154254.78 (  5.26%)
Best50%Mean files/sec-16   140681.59 (  0.00%)   148236.82 (  5.37%)
Best10%Mean files/sec-16   135612.91 (  0.00%)   142230.89 (  4.88%)
Best5%Mean  files/sec-16   134754.93 (  0.00%)   141343.44 (  4.89%)
Best1%Mean  files/sec-16   134054.83 (  0.00%)   140591.69 (  4.88%)

fsmark-threaded App Overhead
                                       4.7.0-rc4       4.7.0-rc4
                                  mmotm-20160623     approx-v9r6
Min      overhead-16  3113450.00 (  0.00%)  2953856.00 ( -5.13%)
Amean    overhead-16  3341992.77 (  0.00%)  3270340.73 ( -2.14%)
Stddev   overhead-16   128214.09 (  0.00%)   137818.89 (  7.49%)
CoeffVar overhead-16        3.84 (  0.00%)        4.21 ( -9.85%)
Max      overhead-16  3756612.00 (  0.00%)  3743079.00 ( -0.36%)

           4.7.0-rc4   4.7.0-rc4
        mmotm-20160623 approx-v9r6
User          242.65      236.67
System       3507.20     3303.89
Elapsed      2201.73     2048.65

Direct pages scanned               261         106
Kswapd pages scanned            170106       59234
Kswapd pages reclaimed          167015       56118
Direct pages reclaimed             261         106
Kswapd efficiency                  98%         94%
Kswapd velocity                 77.260      28.914
Direct efficiency                 100%        100%
Direct velocity                  0.119       0.052
Percentage direct scans             0%          0%
Slabs scanned                 93341634    92911820
Direct inode steals                  0           0
Kswapd inode steals                 39          39

The performance is slightly better and there is no major differences in
the reclaim stats. 

I'll keep looking at results as they come in but the results so far
look fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
