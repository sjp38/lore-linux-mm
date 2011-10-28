Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 795026B002D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 16:18:49 -0400 (EDT)
Date: Sat, 29 Oct 2011 04:18:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across
 zones
Message-ID: <20111028201829.GA20607@localhost>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-4-git-send-email-jweiner@redhat.com>
 <20110930142805.GC869@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110930142805.GC869@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, "Li, Shaohua" <shaohua.li@intel.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Johannes,

I tested this patchset over the IO-less dirty throttling one.
The below numbers show that

//improvements
1) write bandwidth increased by 1% in general
2) greatly reduced nr_vmscan_immediate_reclaim

//regression
3) much increased cpu %user and %system for btrfs

Thanks,
Fengguang
---

kernel before this patchset: 3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+
kernel after this patchset:  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+

3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+
------------------------  ------------------------
                 2056.51        +1.0%      2076.29  TOTAL write_bw                                                          
             32260625.00       -86.0%   4532517.00  TOTAL nr_vmscan_immediate_reclaim                                       
                   90.44       +25.7%       113.67  TOTAL cpu_user                                                          
                  113.05        +9.9%       124.25  TOTAL cpu_system                                                        

3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+
------------------------  ------------------------
                   52.43        +1.3%        53.12  thresh=1000M/btrfs-100dd-4k-8p-4096M-1000M:10-X
                   52.72        +0.8%        53.16  thresh=1000M/btrfs-10dd-4k-8p-4096M-1000M:10-X
                   52.24        +2.7%        53.67  thresh=1000M/btrfs-1dd-4k-8p-4096M-1000M:10-X
                   35.52        +1.2%        35.94  thresh=1000M/ext3-100dd-4k-8p-4096M-1000M:10-X
                   39.37        +1.6%        39.98  thresh=1000M/ext3-10dd-4k-8p-4096M-1000M:10-X
                   47.52        +0.5%        47.75  thresh=1000M/ext3-1dd-4k-8p-4096M-1000M:10-X
                   47.13        +1.1%        47.64  thresh=1000M/ext4-100dd-4k-8p-4096M-1000M:10-X
                   52.28        +3.0%        53.86  thresh=1000M/ext4-10dd-4k-8p-4096M-1000M:10-X
                   54.34        +1.0%        54.87  thresh=1000M/ext4-1dd-4k-8p-4096M-1000M:10-X
                   47.63        +0.3%        47.78  thresh=1000M/xfs-100dd-4k-8p-4096M-1000M:10-X
                   51.25        +2.1%        52.34  thresh=1000M/xfs-10dd-4k-8p-4096M-1000M:10-X
                   52.66        +2.5%        54.00  thresh=1000M/xfs-1dd-4k-8p-4096M-1000M:10-X
                   54.63        -0.0%        54.63  thresh=100M/btrfs-10dd-4k-8p-4096M-100M:10-X
                   53.75        +1.0%        54.29  thresh=100M/btrfs-1dd-4k-8p-4096M-100M:10-X
                   54.14        +0.4%        54.35  thresh=100M/btrfs-2dd-4k-8p-4096M-100M:10-X
                   36.87        -0.0%        36.86  thresh=100M/ext3-10dd-4k-8p-4096M-100M:10-X
                   45.20        -0.3%        45.07  thresh=100M/ext3-1dd-4k-8p-4096M-100M:10-X
                   40.75        -0.6%        40.51  thresh=100M/ext3-2dd-4k-8p-4096M-100M:10-X
                   44.14        +0.3%        44.29  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                   52.91        +0.1%        52.99  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                   50.30        +0.8%        50.72  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                   44.55        +2.8%        45.80  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                   52.75        +4.3%        55.03  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                   50.99        +1.7%        51.87  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                   37.35        +2.0%        38.11  thresh=10M/btrfs-10dd-4k-8p-4096M-10M:10-X
                   53.32        +2.3%        54.55  thresh=10M/btrfs-1dd-4k-8p-4096M-10M:10-X
                   50.72        +3.9%        52.70  thresh=10M/btrfs-2dd-4k-8p-4096M-10M:10-X
                   32.05        +0.7%        32.27  thresh=10M/ext3-10dd-4k-8p-4096M-10M:10-X
                   43.91        -1.2%        43.39  thresh=10M/ext3-1dd-4k-8p-4096M-10M:10-X
                   42.37        +0.3%        42.50  thresh=10M/ext3-2dd-4k-8p-4096M-10M:10-X
                   35.04        -1.9%        34.36  thresh=10M/ext4-10dd-4k-8p-4096M-10M:10-X
                   52.93        -0.4%        52.73  thresh=10M/ext4-1dd-4k-8p-4096M-10M:10-X
                   49.24        -0.0%        49.22  thresh=10M/ext4-2dd-4k-8p-4096M-10M:10-X
                   30.96        -0.8%        30.73  thresh=10M/xfs-10dd-4k-8p-4096M-10M:10-X
                   54.30        -0.8%        53.89  thresh=10M/xfs-1dd-4k-8p-4096M-10M:10-X
                   45.63        +1.2%        46.17  thresh=10M/xfs-2dd-4k-8p-4096M-10M:10-X
                    1.92        -1.5%         1.89  thresh=1M/btrfs-10dd-4k-8p-4096M-1M:10-X
                    2.28        +5.9%         2.42  thresh=1M/btrfs-1dd-4k-8p-4096M-1M:10-X
                    2.07        -1.4%         2.04  thresh=1M/btrfs-2dd-4k-8p-4096M-1M:10-X
                   25.31       +10.2%        27.88  thresh=1M/ext3-10dd-4k-8p-4096M-1M:10-X
                   42.95        -0.9%        42.56  thresh=1M/ext3-1dd-4k-8p-4096M-1M:10-X
                   38.62        -0.9%        38.26  thresh=1M/ext3-2dd-4k-8p-4096M-1M:10-X
                   30.81        -1.0%        30.51  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                   49.72        +0.2%        49.80  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                   44.75        -0.3%        44.61  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                   27.87        +1.3%        28.23  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                   51.05        +1.0%        51.54  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                   45.25        +0.3%        45.39  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                 2056.51        +1.0%      2076.29  TOTAL write_bw

3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+
------------------------  ------------------------
               560289.00       -98.5%      8145.00  thresh=1000M/btrfs-100dd-4k-8p-4096M-1000M:10-X
               576882.00       -98.4%      9511.00  thresh=1000M/btrfs-10dd-4k-8p-4096M-1000M:10-X
               651258.00       -98.8%      7963.00  thresh=1000M/btrfs-1dd-4k-8p-4096M-1000M:10-X
              1963294.00       -85.4%    286815.00  thresh=1000M/ext3-100dd-4k-8p-4096M-1000M:10-X
              2108028.00       -10.6%   1885114.00  thresh=1000M/ext3-10dd-4k-8p-4096M-1000M:10-X
              2499456.00       -99.9%      2061.00  thresh=1000M/ext3-1dd-4k-8p-4096M-1000M:10-X
              2534868.00       -78.5%    545815.00  thresh=1000M/ext4-100dd-4k-8p-4096M-1000M:10-X
              2921668.00       -76.8%    677177.00  thresh=1000M/ext4-10dd-4k-8p-4096M-1000M:10-X
              2841049.00      -100.0%       779.00  thresh=1000M/ext4-1dd-4k-8p-4096M-1000M:10-X
              2481823.00       -86.3%    339342.00  thresh=1000M/xfs-100dd-4k-8p-4096M-1000M:10-X
              2508629.00       -87.4%    316614.00  thresh=1000M/xfs-10dd-4k-8p-4096M-1000M:10-X
              2656628.00      -100.0%       678.00  thresh=1000M/xfs-1dd-4k-8p-4096M-1000M:10-X
               466024.00       -98.9%      5263.00  thresh=100M/btrfs-10dd-4k-8p-4096M-100M:10-X
               460626.00       -99.6%      1853.00  thresh=100M/btrfs-1dd-4k-8p-4096M-100M:10-X
               454364.00       -99.3%      2959.00  thresh=100M/btrfs-2dd-4k-8p-4096M-100M:10-X
               682975.00       -89.3%     73185.00  thresh=100M/ext3-10dd-4k-8p-4096M-100M:10-X
               787717.00       -99.7%      2648.00  thresh=100M/ext3-1dd-4k-8p-4096M-100M:10-X
               611101.00       -99.2%      4629.00  thresh=100M/ext3-2dd-4k-8p-4096M-100M:10-X
               555841.00       -87.9%     67433.00  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
               475452.00       -99.9%       311.00  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
               501009.00       -97.9%     10608.00  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
               362202.00       -82.4%     63873.00  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
               716571.00                      0.00  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
               621495.00       -93.9%     38030.00  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                 4463.00       -81.2%       839.00  thresh=10M/btrfs-10dd-4k-8p-4096M-10M:10-X
                18824.00       -97.4%       490.00  thresh=10M/btrfs-1dd-4k-8p-4096M-10M:10-X
                12486.00       -94.1%       736.00  thresh=10M/btrfs-2dd-4k-8p-4096M-10M:10-X
                43396.00       -70.2%     12945.00  thresh=10M/ext3-10dd-4k-8p-4096M-10M:10-X
               109247.00      -100.0%        42.00  thresh=10M/ext3-1dd-4k-8p-4096M-10M:10-X
                92196.00      -100.0%        15.00  thresh=10M/ext3-2dd-4k-8p-4096M-10M:10-X
                44717.00       -52.9%     21078.00  thresh=10M/ext4-10dd-4k-8p-4096M-10M:10-X
                87977.00                      0.00  thresh=10M/ext4-1dd-4k-8p-4096M-10M:10-X
               130864.00       -98.9%      1381.00  thresh=10M/ext4-2dd-4k-8p-4096M-10M:10-X
                35133.00       -99.9%        52.00  thresh=10M/xfs-10dd-4k-8p-4096M-10M:10-X
               117181.00      -100.0%        10.00  thresh=10M/xfs-1dd-4k-8p-4096M-10M:10-X
               133795.00       -79.3%     27705.00  thresh=10M/xfs-2dd-4k-8p-4096M-10M:10-X
                    0.00                      0.00  thresh=1M/btrfs-10dd-4k-8p-4096M-1M:10-X
                    5.00                      0.00  thresh=1M/btrfs-1dd-4k-8p-4096M-1M:10-X
                    0.00                      0.00  thresh=1M/btrfs-2dd-4k-8p-4096M-1M:10-X
                34914.00       -62.8%     12983.00  thresh=1M/ext3-10dd-4k-8p-4096M-1M:10-X
                73497.00                      0.00  thresh=1M/ext3-1dd-4k-8p-4096M-1M:10-X
                52923.00       -68.0%     16922.00  thresh=1M/ext3-2dd-4k-8p-4096M-1M:10-X
                40172.00       -65.8%     13750.00  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                60073.00       -79.0%     12601.00  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                58565.00       -69.8%     17690.00  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                21840.00       -50.8%     10744.00  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                46227.00       -65.2%     16103.00  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                42881.00       -63.6%     15625.00  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
             32260625.00       -86.0%   4532517.00  TOTAL nr_vmscan_immediate_reclaim


3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+
------------------------  ------------------------
                    4.46       +48.6%         6.62  thresh=1000M/btrfs-100dd-4k-8p-4096M-1000M:10-X
                    0.92      +261.7%         3.34  thresh=1000M/btrfs-10dd-4k-8p-4096M-1000M:10-X
                    1.12      +222.2%         3.61  thresh=1000M/btrfs-1dd-4k-8p-4096M-1000M:10-X
                    2.59       -14.3%         2.22  thresh=1000M/ext3-100dd-4k-8p-4096M-1000M:10-X
                    0.68        -0.6%         0.67  thresh=1000M/ext3-10dd-4k-8p-4096M-1000M:10-X
                    0.67        -3.2%         0.64  thresh=1000M/ext3-1dd-4k-8p-4096M-1000M:10-X
                    2.84        +1.9%         2.89  thresh=1000M/ext4-100dd-4k-8p-4096M-1000M:10-X
                    0.70        +1.7%         0.71  thresh=1000M/ext4-10dd-4k-8p-4096M-1000M:10-X
                    0.70        -6.3%         0.66  thresh=1000M/ext4-1dd-4k-8p-4096M-1000M:10-X
                    2.86        +1.5%         2.91  thresh=1000M/xfs-100dd-4k-8p-4096M-1000M:10-X
                    0.75        -0.5%         0.75  thresh=1000M/xfs-10dd-4k-8p-4096M-1000M:10-X
                    0.96        -4.0%         0.92  thresh=1000M/xfs-1dd-4k-8p-4096M-1000M:10-X
                    1.15      +229.7%         3.79  thresh=100M/btrfs-10dd-4k-8p-4096M-100M:10-X
                    0.95      +269.8%         3.50  thresh=100M/btrfs-1dd-4k-8p-4096M-100M:10-X
                    0.84      +309.1%         3.45  thresh=100M/btrfs-2dd-4k-8p-4096M-100M:10-X
                    0.76        -0.8%         0.76  thresh=100M/ext3-10dd-4k-8p-4096M-100M:10-X
                    0.73        -5.5%         0.69  thresh=100M/ext3-1dd-4k-8p-4096M-100M:10-X
                    0.66        -5.3%         0.62  thresh=100M/ext3-2dd-4k-8p-4096M-100M:10-X
                    0.89        +2.0%         0.91  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                    0.75        -7.0%         0.70  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                    0.74        -4.5%         0.71  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                    0.92        +1.1%         0.93  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                    0.99        -4.4%         0.95  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                    0.91        -2.2%         0.89  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                    2.51      +107.7%         5.21  thresh=10M/btrfs-10dd-4k-8p-4096M-10M:10-X
                    2.46      +103.1%         4.99  thresh=10M/btrfs-1dd-4k-8p-4096M-10M:10-X
                    2.33      +113.0%         4.97  thresh=10M/btrfs-2dd-4k-8p-4096M-10M:10-X
                    1.52        +0.2%         1.53  thresh=10M/ext3-10dd-4k-8p-4096M-10M:10-X
                    2.07        -1.4%         2.04  thresh=10M/ext3-1dd-4k-8p-4096M-10M:10-X
                    1.92        -0.1%         1.92  thresh=10M/ext3-2dd-4k-8p-4096M-10M:10-X
                    1.66        -3.2%         1.61  thresh=10M/ext4-10dd-4k-8p-4096M-10M:10-X
                    2.48        -0.8%         2.46  thresh=10M/ext4-1dd-4k-8p-4096M-10M:10-X
                    2.22        -1.2%         2.19  thresh=10M/ext4-2dd-4k-8p-4096M-10M:10-X
                    1.51        -1.4%         1.49  thresh=10M/xfs-10dd-4k-8p-4096M-10M:10-X
                    2.04        -1.8%         2.00  thresh=10M/xfs-1dd-4k-8p-4096M-10M:10-X
                    1.80        +1.5%         1.82  thresh=10M/xfs-2dd-4k-8p-4096M-10M:10-X
                    2.72       +13.0%         3.08  thresh=1M/btrfs-10dd-4k-8p-4096M-1M:10-X
                    1.05       +15.4%         1.21  thresh=1M/btrfs-1dd-4k-8p-4096M-1M:10-X
                    1.07       +16.5%         1.25  thresh=1M/btrfs-2dd-4k-8p-4096M-1M:10-X
                    4.58        +7.6%         4.93  thresh=1M/ext3-10dd-4k-8p-4096M-1M:10-X
                    2.49        -0.3%         2.49  thresh=1M/ext3-1dd-4k-8p-4096M-1M:10-X
                    2.81        +0.8%         2.83  thresh=1M/ext3-2dd-4k-8p-4096M-1M:10-X
                    5.25        +1.7%         5.34  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                    2.52        +1.4%         2.56  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                    2.83        -0.4%         2.82  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                    5.11        +1.5%         5.19  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                    2.81        -0.1%         2.81  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                    3.11        -0.6%         3.09  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                   90.44       +25.7%       113.67  TOTAL cpu_user

3.1.0-rc9-ioless-full-nfs-wq5-next-20111014+  3.1.0-rc9-ioless-full-per-zone-dirty-next-20111014+
------------------------  ------------------------
                    6.49       +20.1%         7.79  thresh=1000M/btrfs-100dd-4k-8p-4096M-1000M:10-X
                    5.24       +26.9%         6.65  thresh=1000M/btrfs-10dd-4k-8p-4096M-1000M:10-X
                    6.16       +22.0%         7.51  thresh=1000M/btrfs-1dd-4k-8p-4096M-1000M:10-X
                    1.15       -12.3%         1.01  thresh=1000M/ext3-100dd-4k-8p-4096M-1000M:10-X
                    0.71        +1.5%         0.72  thresh=1000M/ext3-10dd-4k-8p-4096M-1000M:10-X
                    2.15        -3.2%         2.08  thresh=1000M/ext3-1dd-4k-8p-4096M-1000M:10-X
                    1.29        +1.1%         1.31  thresh=1000M/ext4-100dd-4k-8p-4096M-1000M:10-X
                    0.84        +0.1%         0.84  thresh=1000M/ext4-10dd-4k-8p-4096M-1000M:10-X
                    2.10        -1.9%         2.06  thresh=1000M/ext4-1dd-4k-8p-4096M-1000M:10-X
                    1.24        -0.5%         1.23  thresh=1000M/xfs-100dd-4k-8p-4096M-1000M:10-X
                    0.65        +1.6%         0.66  thresh=1000M/xfs-10dd-4k-8p-4096M-1000M:10-X
                    1.77        +3.5%         1.83  thresh=1000M/xfs-1dd-4k-8p-4096M-1000M:10-X
                    5.38       +22.5%         6.59  thresh=100M/btrfs-10dd-4k-8p-4096M-100M:10-X
                    6.05       +19.7%         7.25  thresh=100M/btrfs-1dd-4k-8p-4096M-100M:10-X
                    5.99       +18.9%         7.13  thresh=100M/btrfs-2dd-4k-8p-4096M-100M:10-X
                    0.71        +2.8%         0.73  thresh=100M/ext3-10dd-4k-8p-4096M-100M:10-X
                    2.28        -1.3%         2.25  thresh=100M/ext3-1dd-4k-8p-4096M-100M:10-X
                    1.88        -2.0%         1.85  thresh=100M/ext3-2dd-4k-8p-4096M-100M:10-X
                    0.68        -1.1%         0.67  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                    1.65        +0.4%         1.66  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                    1.51        -2.9%         1.47  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                    0.63        +2.9%         0.65  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                    1.87        +1.7%         1.90  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                    1.70        -1.4%         1.68  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                    5.31       +25.7%         6.67  thresh=10M/btrfs-10dd-4k-8p-4096M-10M:10-X
                    5.50       +21.3%         6.67  thresh=10M/btrfs-1dd-4k-8p-4096M-10M:10-X
                    5.74       +20.8%         6.94  thresh=10M/btrfs-2dd-4k-8p-4096M-10M:10-X
                    0.85        -0.6%         0.84  thresh=10M/ext3-10dd-4k-8p-4096M-10M:10-X
                    1.41        -4.4%         1.35  thresh=10M/ext3-1dd-4k-8p-4096M-10M:10-X
                    1.43        -2.7%         1.40  thresh=10M/ext3-2dd-4k-8p-4096M-10M:10-X
                    0.77        -3.0%         0.75  thresh=10M/ext4-10dd-4k-8p-4096M-10M:10-X
                    1.39        -3.3%         1.35  thresh=10M/ext4-1dd-4k-8p-4096M-10M:10-X
                    1.37        -5.1%         1.30  thresh=10M/ext4-2dd-4k-8p-4096M-10M:10-X
                    0.70        -2.5%         0.68  thresh=10M/xfs-10dd-4k-8p-4096M-10M:10-X
                    2.11        -3.7%         2.03  thresh=10M/xfs-1dd-4k-8p-4096M-10M:10-X
                    1.77        -1.0%         1.75  thresh=10M/xfs-2dd-4k-8p-4096M-10M:10-X
                    0.86       +10.3%         0.94  thresh=1M/btrfs-10dd-4k-8p-4096M-1M:10-X
                    0.66       +14.0%         0.76  thresh=1M/btrfs-1dd-4k-8p-4096M-1M:10-X
                    0.57       +11.8%         0.63  thresh=1M/btrfs-2dd-4k-8p-4096M-1M:10-X
                    1.89        +8.8%         2.06  thresh=1M/ext3-10dd-4k-8p-4096M-1M:10-X
                    3.20        -0.5%         3.19  thresh=1M/ext3-1dd-4k-8p-4096M-1M:10-X
                    2.77        +0.1%         2.77  thresh=1M/ext3-2dd-4k-8p-4096M-1M:10-X
                    2.00        +0.3%         2.01  thresh=1M/ext4-10dd-4k-8p-4096M-1M:10-X
                    3.16        +1.5%         3.21  thresh=1M/ext4-1dd-4k-8p-4096M-1M:10-X
                    2.52        -0.9%         2.50  thresh=1M/ext4-2dd-4k-8p-4096M-1M:10-X
                    1.84        +0.7%         1.85  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                    2.82        +0.3%         2.82  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                    2.27        -0.3%         2.26  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                  113.05        +9.9%       124.25  TOTAL cpu_system

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
