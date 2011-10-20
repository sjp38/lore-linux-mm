Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C57A26B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 23:39:34 -0400 (EDT)
Date: Thu, 20 Oct 2011 11:39:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111020033930.GA22746@localhost>
References: <20111003134228.090592370@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111003134228.090592370@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>

FYI, a simple sequential write comparison between the common filesystems.

For a newly created filesystem, btrfs is super fast!  The interesting thing is,
btrfs performs best in the dirty_thresh=100M cases, rather than the 1G/8G cases.

btrfs also performs equally well in the 1dd, 2dd, 10dd, 100dd cases. However
the tests are blind to the possibility of long term fragmentation.

                   btrfs                      ext3                      ext4                       xfs  
------------------------  ------------------------  ------------------------  ------------------------  
                   56.55       -45.8%        30.66       -10.8%        50.42       -26.1%        41.76  thresh=1G/X-100dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6a+
                   56.11       -37.2%        35.24        +0.2%        56.23       -13.9%        48.34  thresh=1G/X-10dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6a+
                   56.21       -22.5%        43.58        +3.4%        58.12        -6.9%        52.36  thresh=1G/X-1dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6a+

                   58.23       -35.9%        37.34       -20.2%        46.45       -23.5%        44.53  thresh=100M/X-10dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6a+
                   58.43       -23.9%        44.44        -3.1%        56.60        -4.4%        55.89  thresh=100M/X-1dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6a+
                   58.53       -28.7%        41.70        -7.5%        54.14       -12.7%        51.11  thresh=100M/X-2dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6a+

                   54.37       -40.8%        32.21       -34.6%        35.58       -42.9%        31.07  thresh=8M/X-10dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6a+
                   56.12       -19.1%        45.37        +0.5%        56.39        -1.2%        55.44  thresh=8M/X-1dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6a+
                   56.22       -22.3%        43.71        -8.8%        51.26       -15.4%        47.59  thresh=8M/X-2dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6a+

                  510.77       -30.6%       354.27        -8.9%       465.19       -16.2%       428.07  TOTAL write_bw

Below is a more extensive run on virtually the same kernel.

In the thresh=8G case, ext4 performs noticeably better than others,
and the number of dd tasks is no longer relevant with big enough memory.

                   btrfs                      ext3                      ext4                       xfs  
------------------------  ------------------------  ------------------------  ------------------------  
                   92.89       -28.6%        66.36        +7.8%       100.10        -2.7%        90.41  thresh=8G/X-100dd-1M-32p-32768M-8192M:10-3.1.0-rc8-ioless6+
                   89.69       -19.7%        72.00       +18.7%       106.42        +2.2%        91.67  thresh=8G/X-10dd-1M-32p-32768M-8192M:10-3.1.0-rc8-ioless6+
                   92.26       -18.7%        75.01       +16.3%       107.26        +1.4%        93.51  thresh=8G/X-1dd-1M-32p-32768M-8192M:10-3.1.0-rc8-ioless6+
                   89.96       -16.8%        74.87       +20.7%       108.62        +3.1%        92.76  thresh=8G/X-2dd-1M-32p-32768M-8192M:10-3.1.0-rc8-ioless6+
note: the above 8G cases run on another test box!

                   60.29       -47.0%        31.96       -14.6%        51.47       -27.9%        43.44  thresh=1G/X-100dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6+
                   58.80       -38.5%        36.19        -4.4%        56.19       -15.3%        49.83  thresh=1G/X-10dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6+
                   58.53       -23.1%        45.03        -0.2%        58.41       -10.0%        52.70  thresh=1G/X-1dd-4k-8p-4096M-1024M:10-3.1.0-rc8-ioless6+

                   58.01       -35.0%        37.69        -4.1%        55.62       -12.4%        50.82  thresh=400M-300M/X-10dd-4k-8p-4096M-400M:300M-3.1.0-rc8-ioless6+
                   57.69       -26.0%        42.69        +1.8%        58.71        -2.4%        56.33  thresh=400M-300M/X-1dd-4k-8p-4096M-400M:300M-3.1.0-rc8-ioless6+
                   57.13       -32.4%        38.63        +2.5%        58.58        -6.8%        53.27  thresh=400M-300M/X-2dd-4k-8p-4096M-400M:300M-3.1.0-rc8-ioless6+

                   56.97       -33.3%        38.01        -3.2%        55.14        -9.3%        51.67  thresh=400M/X-10dd-4k-8p-4096M-400M:10-3.1.0-rc8-ioless6+
                   57.78       -22.3%        44.90        +0.6%        58.14        -0.7%        57.35  thresh=400M/X-1dd-4k-8p-4096M-400M:10-3.1.0-rc8-ioless6+
                   56.12       -27.3%        40.81        +2.4%        57.49        -4.9%        53.36  thresh=400M/X-2dd-4k-8p-4096M-400M:10-3.1.0-rc8-ioless6+

                   59.39       -36.0%        38.02       -20.0%        47.50       -24.4%        44.89  thresh=100M/X-10dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6+
                   58.68       -23.0%        45.20        -0.9%        58.18        -1.1%        58.06  thresh=100M/X-1dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6+
                   58.92       -27.9%        42.50        -5.3%        55.79       -11.8%        51.94  thresh=100M/X-2dd-4k-8p-4096M-100M:10-3.1.0-rc8-ioless6+

                   57.12       -41.1%        33.63       -36.0%        36.58       -43.6%        32.19  thresh=8M/X-10dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6+
                   59.29       -18.5%        48.30        -3.3%        57.35        -5.8%        55.86  thresh=8M/X-1dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6+
                   59.23       -21.0%        46.77       -10.8%        52.82       -17.3%        48.96  thresh=8M/X-2dd-4k-8p-4096M-8M:10-3.1.0-rc8-ioless6+

                 1238.75       -27.5%       898.56        +0.1%      1240.38        -8.9%      1129.01  TOTAL write_bw

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
