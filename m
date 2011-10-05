Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9333D900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 21:42:47 -0400 (EDT)
Date: Wed, 5 Oct 2011 09:42:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111005014242.GA10237@localhost>
References: <20111003134228.090592370@intel.com>
 <20111003135902.GA16518@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111003135902.GA16518@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> As far as I can tell from the current test results,
> the writeback performance mostly stays on par with vanilla 3.1 kernel
> except for -14% regression on average for NFS, which can be cut down
> to -7% by limiting the commit size.

I find that the overall NFS throughput can be improved by 42% when
doing the NFS writeback wait queue and limiting the commit size.

      3.1.0-rc8-ioless6+  3.1.0-rc8-nfs-wq-smooth+  
------------------------  ------------------------  
                   22.43       +79.2%        40.20  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   28.21       +11.9%        31.58  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   29.21       +54.0%        44.98  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   14.12       +31.0%        18.50  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   29.44        +2.1%        30.06  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                    9.09      +231.0%        30.07  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   25.68       +88.6%        48.43  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   41.06       +14.9%        47.16  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   39.13       +26.7%        49.56  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  238.38       +42.9%       340.54  TOTAL

The theoretic explanation could be, one smooths out the NFS write
requests and the other smooths out the NFS commits, hence yielding
better utilized network/disk pipeline.

As a result, the -14% regression can be turned around into 23% speedup
comparing to vanilla kernel:

      3.1.0-rc4-vanilla+  3.1.0-rc8-nfs-wq-smooth+
------------------------  ------------------------
                   20.89       +92.5%        40.20  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
                   39.43       -19.9%        31.58  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
                   26.60       +69.1%        44.98  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
                   12.70       +45.7%        18.50  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
                   27.41        +9.7%        30.06  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
                   26.52       +13.4%        30.07  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
                   40.70       +19.0%        48.43  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
                   45.28        +4.2%        47.16  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
                   35.74       +38.7%        49.56  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
                  275.28       +23.7%       340.54  TOTAL


The tests don't cover disk arrays on the server side, however it does
test various combinations of memory:bandwidth ratio.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
