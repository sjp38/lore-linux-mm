Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D90969000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:59:15 -0400 (EDT)
Date: Mon, 3 Oct 2011 21:59:02 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111003135902.GA16518@localhost>
References: <20111003134228.090592370@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111003134228.090592370@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 03, 2011 at 09:42:28PM +0800, Wu, Fengguang wrote:
> Hi,
> 
> This is the minimal IO-less balance_dirty_pages() changes that are expected to
> be regression free (well, except for NFS).
> 
>         git://github.com/fengguang/linux.git dirty-throttling-v12
> 
> Tests results will be posted in a separate email.

The complete test matrix for the major filesystems would take some more
days to complete.  As far as I can tell from the current test results,
the writeback performance mostly stays on par with vanilla 3.1 kernel
except for -14% regression on average for NFS, which can be cut down
to -7% by limiting the commit size.

USB stick:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+  
------------------------  ------------------------  
                   54.39        +0.6%        54.73  3G-UKEY-HDD/xfs-10dd-4k-8p-4096M-20:10-X
                   63.72        -1.8%        62.58  3G-UKEY-HDD/xfs-1dd-4k-8p-4096M-20:10-X
                   58.53        -3.2%        56.65  3G-UKEY-HDD/xfs-2dd-4k-8p-4096M-20:10-X
                    6.31        +1.6%         6.41  UKEY-thresh=50M/xfs-1dd-4k-8p-4096M-50M:10-X
                    4.91        +0.9%         4.95  UKEY-thresh=50M/xfs-2dd-4k-8p-4096M-50M:10-X

single disk:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+
------------------------  ------------------------
                   47.59        -0.2%        47.50  thresh=100M/ext4-10dd-4k-8p-4096M-100M:10-X
                   56.83        +2.4%        58.18  thresh=100M/ext4-1dd-4k-8p-4096M-100M:10-X
                   54.81        +1.8%        55.79  thresh=100M/ext4-2dd-4k-8p-4096M-100M:10-X
                   45.89        -2.2%        44.89  thresh=100M/xfs-10dd-4k-8p-4096M-100M:10-X
                   56.68        +2.4%        58.06  thresh=100M/xfs-1dd-4k-8p-4096M-100M:10-X
                   53.33        -2.6%        51.94  thresh=100M/xfs-2dd-4k-8p-4096M-100M:10-X
                   89.22        +3.6%        92.40  thresh=1024M-1000M/xfs-10dd-1M-32p-32768M-1024M:1000M-X
                   93.01        -0.4%        92.65  thresh=1024M-1000M/xfs-1dd-1M-32p-32768M-1024M:1000M-X
                   91.19        -0.8%        90.46  thresh=1024M-1000M/xfs-2dd-1M-32p-32768M-1024M:1000M-X
                   58.23        +3.5%        60.29  thresh=1G/btrfs-100dd-4k-8p-4096M-1024M:10-X
                   57.53        +2.2%        58.80  thresh=1G/btrfs-10dd-4k-8p-4096M-1024M:10-X
                   57.18        +2.4%        58.53  thresh=1G/btrfs-1dd-4k-8p-4096M-1024M:10-X
                   35.97       -11.2%        31.96  thresh=1G/ext3-100dd-4k-8p-4096M-1024M:10-X
                   36.55        -1.0%        36.19  thresh=1G/ext3-10dd-4k-8p-4096M-1024M:10-X
                   44.94        +0.2%        45.03  thresh=1G/ext3-1dd-4k-8p-4096M-1024M:10-X
                   53.25        -3.3%        51.47  thresh=1G/ext4-100dd-4k-8p-4096M-1024M:10-X
                   56.17        +0.0%        56.19  thresh=1G/ext4-10dd-4k-8p-4096M-1024M:10-X
                   58.11        +0.5%        58.41  thresh=1G/ext4-1dd-4k-8p-4096M-1024M:10-X
                   41.93        +3.6%        43.44  thresh=1G/xfs-100dd-4k-8p-4096M-1024M:10-X
                   46.34        +7.5%        49.83  thresh=1G/xfs-10dd-4k-8p-4096M-1024M:10-X
                   52.67        +0.1%        52.70  thresh=1G/xfs-1dd-4k-8p-4096M-1024M:10-X
                   25.28       +10.4%        27.91  thresh=1M/xfs-10dd-4k-8p-4096M-1M:10-X
                   31.56       +60.3%        50.61  thresh=1M/xfs-1dd-4k-8p-4096M-1M:10-X
                   43.89        -2.5%        42.81  thresh=1M/xfs-2dd-4k-8p-4096M-1M:10-X
                   86.10       +25.7%       108.19  thresh=2048M-2000M/xfs-10dd-1M-32p-32768M-2048M:2000M-X
                   93.31        -1.7%        91.69  thresh=2048M-2000M/xfs-1dd-1M-32p-32768M-2048M:2000M-X
                   90.52        +0.2%        90.72  thresh=2048M-2000M/xfs-2dd-1M-32p-32768M-2048M:2000M-X
                   48.57        +4.6%        50.82  thresh=400M-300M/xfs-10dd-4k-8p-4096M-400M:300M-X
                   55.00        +2.4%        56.33  thresh=400M-300M/xfs-1dd-4k-8p-4096M-400M:300M-X
                   52.41        +1.6%        53.27  thresh=400M-300M/xfs-2dd-4k-8p-4096M-400M:300M-X
                   50.78        +1.8%        51.67  thresh=400M/xfs-10dd-4k-8p-4096M-400M:10-X
                   57.48        -0.2%        57.35  thresh=400M/xfs-1dd-4k-8p-4096M-400M:10-X
                   54.14        -1.4%        53.36  thresh=400M/xfs-2dd-4k-8p-4096M-400M:10-X
                   81.43       +11.0%        90.41  thresh=8G/xfs-100dd-1M-32p-32768M-8192M:10-X
                   87.37        +4.9%        91.67  thresh=8G/xfs-10dd-1M-32p-32768M-8192M:10-X
                   92.58        +1.0%        93.51  thresh=8G/xfs-1dd-1M-32p-32768M-8192M:10-X
                   89.78        +3.3%        92.76  thresh=8G/xfs-2dd-1M-32p-32768M-8192M:10-X
                   25.00       +28.7%        32.19  thresh=8M/xfs-10dd-4k-8p-4096M-8M:10-X
                   54.37        +2.7%        55.86  thresh=8M/xfs-1dd-4k-8p-4096M-8M:10-X
                   43.26       +13.2%        48.96  thresh=8M/xfs-2dd-4k-8p-4096M-8M:10-X
                 2350.25        +3.6%      2434.78  TOTAL

single disk, different dd block sizes:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+  
------------------------  ------------------------  
                   40.88        +6.8%        43.65  3G-bs=1M/xfs-100dd-1M-8p-4096M-20:10-X
                   49.31        +1.3%        49.95  3G-bs=1M/xfs-10dd-1M-8p-4096M-20:10-X
                   54.75        -0.2%        54.66  3G-bs=1M/xfs-1dd-1M-8p-4096M-20:10-X
                   39.65        -1.2%        39.18  3G-bs=1k/xfs-100dd-1k-8p-4096M-20:10-X
                   48.08        +0.3%        48.21  3G-bs=1k/xfs-10dd-1k-8p-4096M-20:10-X
                   52.76        -0.3%        52.60  3G-bs=1k/xfs-1dd-1k-8p-4096M-20:10-X
                   40.60        +7.4%        43.60  3G/xfs-100dd-4k-8p-4096M-20:10-X
                   49.56        +1.9%        50.49  3G/xfs-10dd-4k-8p-4096M-20:10-X
                   53.90        +0.1%        53.95  3G/xfs-1dd-4k-8p-4096M-20:10-X

JBOD:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+
------------------------  ------------------------
                  653.81        -1.7%       642.93  JBOD-10HDD-16G/xfs-100dd-1M-24p-16384M-20:10-X
                  660.44        -0.5%       657.40  JBOD-10HDD-16G/xfs-10dd-1M-24p-16384M-20:10-X
                  651.53        +3.8%       676.56  JBOD-10HDD-16G/xfs-1dd-1M-24p-16384M-20:10-X
                  330.97        +1.4%       335.62  JBOD-10HDD-6G/ext4-100dd-1M-16p-8192M-20:10-X
                  376.51        +0.3%       377.73  JBOD-10HDD-6G/ext4-10dd-1M-16p-8192M-20:10-X
                  392.36        -1.6%       385.96  JBOD-10HDD-6G/ext4-1dd-1M-16p-8192M-20:10-X
                  390.44        -0.7%       387.56  JBOD-10HDD-6G/ext4-2dd-1M-16p-8192M-20:10-X
                  270.08        +2.1%       275.78  JBOD-10HDD-thresh=100M/ext4-100dd-1M-16p-8192M-100M:10-X
                  325.17       +11.4%       362.32  JBOD-10HDD-thresh=100M/ext4-10dd-1M-16p-8192M-100M:10-X
                  379.30        +3.1%       391.19  JBOD-10HDD-thresh=100M/ext4-1dd-1M-16p-8192M-100M:10-X
                  351.38        +8.6%       381.60  JBOD-10HDD-thresh=100M/ext4-2dd-1M-16p-8192M-100M:10-X
                  351.03       -23.5%       268.55  JBOD-10HDD-thresh=100M/xfs-100dd-1M-24p-16384M-100M:10-X
                  411.98       +19.2%       491.25  JBOD-10HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
                  502.51       +12.9%       567.37  JBOD-10HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
                  345.61        +4.3%       360.62  JBOD-10HDD-thresh=2G/ext4-100dd-1M-16p-8192M-2048M:10-X
                  383.20        +0.2%       383.78  JBOD-10HDD-thresh=2G/ext4-10dd-1M-16p-8192M-2048M:10-X
                  393.46        -0.6%       391.27  JBOD-10HDD-thresh=2G/ext4-1dd-1M-16p-8192M-2048M:10-X
                  393.40        -0.9%       389.85  JBOD-10HDD-thresh=2G/ext4-2dd-1M-16p-8192M-2048M:10-X
                  646.70        -1.2%       638.68  JBOD-10HDD-thresh=2G/xfs-100dd-1M-24p-16384M-2048M:10-X
                  652.26        +2.2%       666.84  JBOD-10HDD-thresh=2G/xfs-10dd-1M-24p-16384M-2048M:10-X
                  642.60        +7.4%       690.19  JBOD-10HDD-thresh=2G/xfs-1dd-1M-24p-16384M-2048M:10-X
                  391.37        -3.7%       376.88  JBOD-10HDD-thresh=4G/ext4-10dd-1M-16p-8192M-4096M:10-X
                  395.83        -1.2%       390.90  JBOD-10HDD-thresh=4G/ext4-1dd-1M-16p-8192M-4096M:10-X
                  398.18        -1.7%       391.44  JBOD-10HDD-thresh=4G/ext4-2dd-1M-16p-8192M-4096M:10-X
                  665.94        -0.9%       659.95  JBOD-10HDD-thresh=4G/xfs-100dd-1M-24p-16384M-4096M:10-X
                  660.60        +0.0%       660.73  JBOD-10HDD-thresh=4G/xfs-10dd-1M-24p-16384M-4096M:10-X
                  655.92        +2.1%       669.58  JBOD-10HDD-thresh=4G/xfs-1dd-1M-24p-16384M-4096M:10-X
                  342.39        +1.4%       347.02  JBOD-10HDD-thresh=800M/ext4-100dd-1M-16p-8192M-800M:10-X
                  367.30        +1.0%       371.03  JBOD-10HDD-thresh=800M/ext4-10dd-1M-16p-8192M-800M:10-X
                  384.76        +0.4%       386.29  JBOD-10HDD-thresh=800M/ext4-1dd-1M-16p-8192M-800M:10-X
                  378.61        +2.4%       387.56  JBOD-10HDD-thresh=800M/ext4-2dd-1M-16p-8192M-800M:10-X
                  556.88        -1.2%       550.21  JBOD-10HDD-thresh=800M/xfs-100dd-1M-24p-16384M-800M:10-X
                  646.96        +2.7%       664.74  JBOD-10HDD-thresh=800M/xfs-10dd-1M-24p-16384M-800M:10-X
                  619.52       +13.2%       701.36  JBOD-10HDD-thresh=800M/xfs-1dd-1M-24p-16384M-800M:10-X
                  209.76        +5.8%       221.88  JBOD-2HDD-6G/xfs-100dd-1M-24p-16384M-20:10-X
                  222.62        +2.3%       227.69  JBOD-2HDD-6G/xfs-10dd-1M-24p-16384M-20:10-X
                  234.09        -1.5%       230.62  JBOD-2HDD-6G/xfs-1dd-1M-24p-16384M-20:10-X
                  146.22       -15.8%       123.06  JBOD-2HDD-thresh=100M/xfs-100dd-1M-24p-16384M-100M:10-X
                  204.93        +0.3%       205.48  JBOD-2HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
                  205.06        +2.7%       210.52  JBOD-2HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
                  120.58       -76.6%        28.19  JBOD-2HDD-thresh=10M/xfs-100dd-1M-24p-16384M-10M:10-X
                   73.11       +53.5%       112.25  JBOD-2HDD-thresh=10M/xfs-10dd-1M-24p-16384M-10M:10-X
                   98.99       +80.2%       178.38  JBOD-2HDD-thresh=10M/xfs-1dd-1M-24p-16384M-10M:10-X
                  340.86        -1.3%       336.28  JBOD-4HDD-6G/xfs-100dd-1M-24p-16384M-20:10-X
                  369.65        +4.2%       385.01  JBOD-4HDD-6G/xfs-10dd-1M-24p-16384M-20:10-X
                  424.24        -3.4%       410.01  JBOD-4HDD-6G/xfs-1dd-1M-24p-16384M-20:10-X
                  279.28       -19.6%       224.53  JBOD-4HDD-thresh=100M/xfs-100dd-1M-24p-16384M-100M:10-X
                  335.48       +11.6%       374.31  JBOD-4HDD-thresh=100M/xfs-10dd-1M-24p-16384M-100M:10-X
                  353.58        +9.0%       385.41  JBOD-4HDD-thresh=100M/xfs-1dd-1M-24p-16384M-100M:10-X
                   34.31        +0.3%        34.42  JBOD-MMAP-RANDWRITE-4K/ext4-fio_mmap_randwrite_4k-4k-16p-8192M-20:10-X
                19621.76        +1.8%     19968.81  TOTAL

software RAID0:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+  
------------------------  ------------------------  
                  562.90        -2.3%       549.79  RAID0-10HDD-16G/xfs-1000dd-1M-24p-16384M-20:10-X
                  662.22        -0.5%       659.09  RAID0-10HDD-16G/xfs-100dd-1M-24p-16384M-20:10-X
                  645.99        +0.7%       650.40  RAID0-10HDD-16G/xfs-10dd-1M-24p-16384M-20:10-X
                 1871.12        -0.6%      1859.27  TOTAL

NFS:

      3.1.0-rc4-vanilla+        3.1.0-rc8-ioless6+  
------------------------  ------------------------  
                   20.89        +7.4%        22.43  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   39.43       -28.5%        28.21  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   26.60        +9.8%        29.21  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   12.70       +11.2%        14.12  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   27.41        +7.4%        29.44  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                   26.52       -65.7%         9.09  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   40.70       -36.9%        25.68  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   45.28        -9.3%        41.06  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   35.74        +9.5%        39.13  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                    2.89       +15.8%         3.35  NFS-thresh=1M/nfs-10dd-1M-32p-32768M-1M:10-X
                    6.69       -18.7%         5.44  NFS-thresh=1M/nfs-1dd-1M-32p-32768M-1M:10-X
                    7.16       -57.5%         3.04  NFS-thresh=1M/nfs-2dd-1M-32p-32768M-1M:10-X
                  292.02       -14.3%       250.21  TOTAL

the NFS smooth patch may cut the regressions by half:

      3.1.0-rc8-ioless6+     3.1.0-rc4-nfs-smooth+
------------------------  ------------------------
                   22.43       +39.5%        31.30  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   28.21        -4.7%        26.87  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   29.21       +17.3%        34.28  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   14.12        -6.3%        13.23  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   29.44       -57.6%        12.48  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    9.09       +41.0%        12.81  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   25.68       +63.6%        42.01  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   41.06        -7.5%        37.97  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   39.13       +13.0%        44.21  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                    3.35        +2.2%         3.42  NFS-thresh=1M/nfs-10dd-1M-32p-32768M-1M:10-X
                    5.44       +37.0%         7.45  NFS-thresh=1M/nfs-1dd-1M-32p-32768M-1M:10-X
                    3.04       +21.9%         3.70  NFS-thresh=1M/nfs-2dd-1M-32p-32768M-1M:10-X
                  250.21        +7.8%       269.74  TOTAL

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
