Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7A66F6B0031
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 04:59:32 -0400 (EDT)
Date: Tue, 18 Oct 2011 16:59:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 2/2] nfs: scale writeback threshold proportional
 to dirty threshold
Message-ID: <20111018085926.GC27805@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
 <20111010131051.GA16847@localhost>
 <20111010131154.GB16847@localhost>
 <20111018085351.GB27805@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111018085351.GB27805@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Tang Feng <feng.tang@intel.com>

> @@ -1814,6 +1814,7 @@ void nfs_update_congestion_thresh(void)
>  	 */
>  	global_dirty_limits(&background_thresh, &dirty_thresh);
>  	dirty_thresh <<= PAGE_SHIFT - 10;
> +	dirty_thresh += 1024;
>  
>  	if (nfs_congestion_kb > dirty_thresh / 8)
>  		nfs_congestion_kb = dirty_thresh / 8;

Here are the new results with ioless + this fix + fix to patch 1.

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                  354.65       +45.4%       515.48  TOTAL write_bw                                                                                                      
                10498.00       +91.7%     20120.00  TOTAL nfs_nr_commits                                                                                                
               233013.00       +99.9%    465751.00  TOTAL nfs_nr_writes                                                                                                 
                  895.47        +3.1%       923.62  TOTAL nfs_commit_size                                                                                               
                    5.71       -14.5%         4.88  TOTAL nfs_write_size                                                                                                
               108269.33       -84.3%     17003.69  TOTAL nfs_write_queue_time                                                                                          
                 1836.03       -34.4%      1204.27  TOTAL nfs_write_rtt_time                                                                                            
               110144.96       -83.5%     18220.96  TOTAL nfs_write_execute_time                                                                                        
                 2902.62       -88.6%       332.20  TOTAL nfs_commit_queue_time                                                                                         
                16282.75       -23.3%     12490.87  TOTAL nfs_commit_rtt_time                                                                                           
                19234.16       -33.3%     12833.00  TOTAL nfs_commit_execute_time                                                                                       

before/after this single fix:
(performance is mostly unchanged except for the thresh=1M cases)

      3.1.0-rc8-nfs-wq3+        3.1.0-rc8-nfs-wq4+  
------------------------  ------------------------  
                   41.67        +3.8%        43.23  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   77.49        -5.5%        73.26  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   69.31        +2.0%        70.68  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   21.99        -1.8%        21.59  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   29.03        -0.0%        29.02  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                   32.51        -2.2%        31.78  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   69.78        -1.1%        69.01  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   73.39        +4.6%        76.74  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   80.84        -4.9%        76.87  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    5.78       +13.7%         6.58  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   11.10        +1.3%        11.24  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    7.60       -27.9%         5.48  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  520.49        -1.0%       515.48  TOTAL write_bw

More detailed comparison to vanilla kernel:

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                   21.85       +97.9%        43.23  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   51.38       +42.6%        73.26  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   28.81      +145.3%        70.68  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                   13.74       +57.1%        21.59  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   29.11        -0.3%        29.02  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                   16.68       +90.5%        31.78  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   48.88       +41.2%        69.01  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   57.85       +32.7%        76.74  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   47.13       +63.1%        76.87  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    9.82       -33.0%         6.58  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   13.72       -18.1%        11.24  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   15.68       -65.0%         5.48  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  354.65       +45.4%       515.48  TOTAL write_bw

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                  834.00      +224.2%      2704.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  311.00      +144.1%       759.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  282.00      +253.5%       997.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 1387.00      +334.2%      6023.00  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                 1081.00      +280.3%      4111.00  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  930.00      +368.0%      4352.00  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  254.00      +108.7%       530.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   38.00       +55.3%        59.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                   54.00       +96.3%       106.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                 1321.00       -74.9%       332.00  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                 1932.00       -99.1%        17.00  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                 2074.00       -93.7%       130.00  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                10498.00       +91.7%     20120.00  TOTAL nfs_nr_commits

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                28359.00       -39.2%     17230.00  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                22241.00      +550.6%    144695.00  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                24969.00       +27.8%     31900.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                21722.00       +38.2%     30030.00  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                11015.00       +28.2%     14117.00  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                17012.00      +217.7%     54039.00  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                25616.00        +3.1%     26403.00  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                24761.00      +177.5%     68702.00  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                29235.00       +37.1%     40089.00  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                12929.00       +21.6%     15720.00  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                 7683.00       +24.2%      9542.00  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                 7471.00       +77.8%     13284.00  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
               233013.00       +99.9%    465751.00  TOTAL nfs_nr_writes

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                    7.84       -38.6%         4.81  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   49.58       -41.6%        28.94  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   30.58       -30.5%        21.27  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    2.99       -63.9%         1.08  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    8.06       -73.8%         2.12  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    5.33       -58.9%         2.19  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                   57.68       -32.1%        39.15  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                  465.15       -16.5%       388.43  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  261.60       -16.4%       218.80  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    2.25      +163.5%         5.93  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    2.13     +9221.2%       198.29  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    2.27      +455.3%        12.61  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                  895.47        +3.1%       923.62  TOTAL nfs_commit_size

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                    0.23      +227.7%         0.76  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                    0.69       -78.1%         0.15  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                    0.35       +92.4%         0.66  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    0.19       +13.4%         0.22  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    0.79       -22.2%         0.62  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    0.29       -39.5%         0.18  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                    0.57       +37.4%         0.79  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                    0.71       -53.3%         0.33  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                    0.48       +19.7%         0.58  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    0.23       -45.5%         0.13  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    0.53       -34.0%         0.35  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    0.63       -80.4%         0.12  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                    5.71       -14.5%         4.88  TOTAL nfs_write_size

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                 6544.25       -95.1%       321.04  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                 1064.82       +11.2%      1184.16  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                22801.48       -86.3%      3113.39  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 1083.47       -99.8%         2.56  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    3.82       -55.8%         1.69  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                 2840.08       -99.3%        20.09  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                20227.73       -96.6%       683.65  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 2346.04      +274.0%      8774.87  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                50812.68       -94.3%      2901.88  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  417.03       -99.9%         0.25  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    1.70       -97.9%         0.04  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                  126.23       -99.9%         0.08  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
               108269.33       -84.3%     17003.69  TOTAL nfs_write_queue_time

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                  276.99       -41.1%       163.20  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  106.71       -67.0%        35.21  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   76.32       +13.4%        86.53  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  335.96       -41.8%       195.49  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   33.67       +70.7%        57.48  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  159.03       -46.0%        85.80  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  340.25       -67.6%       110.23  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                   47.88       +12.7%        53.96  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  118.13       -53.8%        54.62  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  223.24       -53.0%       104.83  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   58.89       +12.8%        66.43  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   58.97      +223.0%       190.49  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                 1836.03       -34.4%      1204.27  TOTAL nfs_write_rtt_time

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                 6821.43       -92.9%       484.70  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                 1173.98        +4.0%      1220.80  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                22878.44       -86.0%      3201.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                 1419.50       -86.0%       198.20  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                   37.72       +57.1%        59.27  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                 2999.22       -96.5%       106.41  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                20570.86       -96.1%       795.46  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 2416.09      +265.6%      8832.81  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                50941.27       -94.2%      2960.10  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                  640.32       -83.6%       105.13  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   60.78        +9.4%        66.49  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                  185.35        +2.8%       190.59  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
               110144.96       -83.5%     18220.96  TOTAL nfs_write_execute_time

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                   54.75       -89.4%         5.82  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                   88.26       -98.7%         1.12  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                   38.41       -92.1%         3.05  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                    7.59       -91.0%         0.68  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                    0.42       -93.3%         0.03  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                    2.57       -75.1%         0.64  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                  784.08       -93.8%        48.69  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 1338.39       -81.4%       248.51  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                  586.69       -96.0%        23.32  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                    1.27       -84.3%         0.20  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                    0.02      +147.1%         0.06  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                    0.16       -41.3%         0.09  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                 2902.62       -88.6%       332.20  TOTAL nfs_commit_queue_time

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                  702.80        +8.2%       760.66  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  538.99       -35.8%       346.08  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  704.42       -37.1%       443.00  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  228.96       -18.4%       186.78  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  155.88       -54.6%        70.75  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  169.51       -28.9%       120.53  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                 3791.44       -11.4%      3361.05  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 4229.79       -17.8%      3476.80  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 5534.04       -35.4%      3574.73  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                   96.34       -31.4%        66.11  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   60.95       -35.5%        39.29  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   69.64       -35.3%        45.08  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                16282.75       -23.3%     12490.87  TOTAL nfs_commit_rtt_time

      3.1.0-rc8-vanilla+        3.1.0-rc8-nfs-wq4+
------------------------  ------------------------
                  757.92        +1.2%       766.73  NFS-thresh=100M/nfs-10dd-4k-32p-32768M-100M:10-X
                  627.36       -44.6%       347.25  NFS-thresh=100M/nfs-1dd-4k-32p-32768M-100M:10-X
                  743.59       -40.0%       446.39  NFS-thresh=100M/nfs-2dd-4k-32p-32768M-100M:10-X
                  236.73       -20.8%       187.57  NFS-thresh=10M/nfs-10dd-4k-32p-32768M-10M:10-X
                  156.31       -54.7%        70.79  NFS-thresh=10M/nfs-1dd-4k-32p-32768M-10M:10-X
                  172.16       -29.6%       121.26  NFS-thresh=10M/nfs-2dd-4k-32p-32768M-10M:10-X
                 4579.56       -25.5%      3411.34  NFS-thresh=1G/nfs-10dd-4k-32p-32768M-1024M:10-X
                 5568.53       -33.1%      3725.49  NFS-thresh=1G/nfs-1dd-4k-32p-32768M-1024M:10-X
                 6163.54       -41.5%      3605.27  NFS-thresh=1G/nfs-2dd-4k-32p-32768M-1024M:10-X
                   97.67       -32.1%        66.35  NFS-thresh=1M/nfs-10dd-4k-32p-32768M-1M:10-X
                   60.99       -35.5%        39.35  NFS-thresh=1M/nfs-1dd-4k-32p-32768M-1M:10-X
                   69.82       -35.3%        45.20  NFS-thresh=1M/nfs-2dd-4k-32p-32768M-1M:10-X
                19234.16       -33.3%     12833.00  TOTAL nfs_commit_execute_time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
