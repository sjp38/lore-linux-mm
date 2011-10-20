Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A7ED86B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:49:41 -0400 (EDT)
Date: Thu, 20 Oct 2011 10:49:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 2/2] nfs: scale writeback threshold proportional
 to dirty threshold
Message-ID: <20111020024936.GA19911@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010131051.GA16847@localhost>
 <20111010131154.GB16847@localhost>
 <20111018085351.GB27805@localhost>
 <20111018085926.GC27805@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111018085926.GC27805@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Feng <feng.tang@intel.com>

> >  	if (nfs_congestion_kb > dirty_thresh / 8)
> >  		nfs_congestion_kb = dirty_thresh / 8;

To confirm whether that's a good threshold,  I tried double it by
using "/ 4".  It results in -8.4% overall throughput regression. So
I'll stick with the current "/ 8".

Thanks,
Fengguang
---

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  472.17        -8.4%       432.32  TOTAL write_bw
                15776.00       -27.3%     11466.00  TOTAL nfs_nr_commits
               401731.00       +75.5%    705206.00  TOTAL nfs_nr_writes
                  918.32       +22.4%      1124.07  TOTAL nfs_commit_size
                    4.97       -25.3%         3.71  TOTAL nfs_write_size
                14098.08       -30.6%      9788.99  TOTAL nfs_write_queue_time
                 1314.33       +55.3%      2041.51  TOTAL nfs_write_rtt_time
                15438.68       -23.2%     11851.79  TOTAL nfs_write_execute_time
                  177.75       +73.1%       307.68  TOTAL nfs_commit_queue_time
                15026.97        -3.6%     14491.26  TOTAL nfs_commit_rtt_time
                15227.06        -2.7%     14809.49  TOTAL nfs_commit_execute_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                   44.49        -7.7%        41.08  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   62.35        -1.7%        61.28  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   67.51       -10.0%        60.76  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   22.90       -30.0%        16.03  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   29.91       -16.9%        24.87  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                   26.51       -20.0%        21.20  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   68.96        -1.2%        68.13  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   60.08       -17.9%        49.30  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   70.55        +4.1%        73.44  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    5.63       -16.9%         4.68  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    7.91        -2.4%         7.71  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    5.38       -28.7%         3.84  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  472.17        -8.4%       432.32  TOTAL write_bw

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                 2565.00       -11.6%      2267.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  384.00        +1.8%       391.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  866.00        -9.9%       780.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 5801.00       -41.0%      3423.00  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                 2092.00       -27.6%      1515.00  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                 3231.00       -24.2%      2450.00  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  408.00        -2.9%       396.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   46.00        -4.3%        44.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   86.00        +9.3%        94.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  138.00       -51.4%        67.00  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                  119.00       -91.6%        10.00  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   40.00       -27.5%        29.00  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                15776.00       -27.3%     11466.00  TOTAL nfs_nr_commits

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                17896.00       +30.5%     23348.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                62623.00      +371.7%    295418.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                37830.00       +37.4%     51991.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                27685.00       +13.1%     31312.00  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                51531.00        +7.4%     55330.00  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                84310.00       +14.8%     96814.00  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                21208.00        +0.8%     21375.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                26724.00        +5.1%     28092.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                31308.00       +67.6%     52461.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                12866.00       +13.9%     14649.00  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                12907.00        +9.2%     14088.00  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                14843.00       +37.0%     20328.00  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
               401731.00       +75.5%    705206.00  TOTAL nfs_nr_writes

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                    5.21        +5.2%         5.48  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   48.66        -3.4%        47.01  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   23.39        -0.1%        23.36  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    1.19       +18.7%         1.41  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    4.28       +15.1%         4.92  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    2.46        +5.5%         2.60  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   50.71        +1.7%        51.57  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                  464.69        -0.5%       462.22  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  245.31        -4.8%       233.60  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                   12.22       +71.4%        20.94  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   19.89     +1063.9%       231.46  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   40.33        -2.0%        39.52  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  918.32       +22.4%      1124.07  TOTAL nfs_commit_size

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                    0.75       -28.7%         0.53  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                    0.30       -79.1%         0.06  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                    0.54       -34.6%         0.35  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    0.25       -38.1%         0.15  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    0.17       -22.4%         0.13  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    0.09       -30.3%         0.07  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                    0.98        -2.1%         0.96  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                    0.80        -9.5%         0.72  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                    0.67       -37.9%         0.42  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    0.13       -26.9%         0.10  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    0.18       -10.4%         0.16  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    0.11       -48.1%         0.06  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                    4.97       -25.3%         3.71  TOTAL nfs_write_size

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  383.37       -32.7%       258.17  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                 5483.72       -67.9%      1759.47  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                 3757.03       -36.1%      2399.96  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    2.61     +9692.1%       255.20  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  145.09      +277.8%       548.13  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                   57.93      +584.8%       396.71  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  498.56        -1.1%       492.84  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 2475.43       +15.0%      2847.51  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 1293.33       -35.9%       829.56  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    0.20      +188.5%         0.59  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    0.56       -11.5%         0.49  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    0.25       +39.0%         0.35  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                14098.08       -30.6%      9788.99  TOTAL nfs_write_queue_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  156.19      +153.8%       396.37  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   47.14       -60.0%        18.86  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   74.76       +59.7%       119.40  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  176.05       +77.5%       312.45  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   88.28       +32.3%       116.82  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  107.48       +12.3%       120.71  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  129.32       -14.8%       110.23  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   85.62       +36.9%       117.24  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   58.52       -20.8%        46.34  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  118.53      +115.7%       255.64  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                  112.27       +40.8%       158.12  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                  160.16       +68.2%       269.33  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                 1314.33       +55.3%      2041.51  TOTAL nfs_write_rtt_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  540.09       +21.2%       654.86  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                 5533.64       -67.8%      1779.65  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                 3833.18       -34.2%      2521.16  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  178.79      +217.6%       567.74  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  233.78      +184.6%       665.23  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  165.69      +212.4%       517.63  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  630.13        -4.0%       605.10  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 2574.27       +15.6%      2976.37  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 1357.04       -35.2%       879.46  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  118.76      +115.8%       256.26  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                  112.86       +40.6%       158.64  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                  160.43       +68.1%       269.70  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                15438.68       -23.2%     11851.79  TOTAL nfs_write_execute_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                    4.15       -29.5%         2.92  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                    5.79      +550.6%        37.64  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                    5.30      +161.4%        13.86  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    0.63       +23.4%         0.78  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    0.77       +52.3%         1.17  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    0.54      +100.0%         1.08  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   66.40       +44.8%        96.17  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   25.80       +41.4%        36.48  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   67.99       +72.2%       117.05  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    0.19       +66.4%         0.31  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    0.10                      0.00  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    0.10      +106.9%         0.21  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  177.75       +73.1%       307.68  TOTAL nfs_commit_queue_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  786.25        -7.3%       729.04  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  523.35        +4.8%       548.62  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  487.58        +4.9%       511.71  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  181.60       +22.2%       221.92  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  110.03       +13.2%       124.60  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  128.24       +11.0%       142.35  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                 4352.76        -5.2%      4126.10  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 4022.83        -2.6%      3917.34  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 4282.52        -6.6%      3999.64  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                   62.09       +56.1%        96.94  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   39.20       -22.5%        30.40  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   50.52       -15.7%        42.59  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                15026.97        -3.6%     14491.26  TOTAL nfs_commit_rtt_time

3.1.0-rc9-ioless-full-next-20111014+  3.1.0-rc9-ioless-full-nfs-thresh-4-next-20111014+
------------------------  ------------------------
                  790.68        -7.4%       732.23  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  529.17       +10.8%       586.28  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  493.32        +6.6%       525.82  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  182.35       +22.2%       222.82  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  110.82       +13.5%       125.80  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  128.80       +11.4%       143.46  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                 4420.89        -4.4%      4224.24  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 4048.67        -2.3%      3953.91  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 4370.05        -5.6%      4124.34  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                   62.33       +56.1%        97.28  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   39.33       -22.4%        30.50  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   50.65       -15.5%        42.79  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                15227.06        -2.7%     14809.49  TOTAL nfs_commit_execute_time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
