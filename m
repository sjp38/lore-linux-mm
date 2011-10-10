Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3C9FD6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 10:28:57 -0400 (EDT)
Date: Mon, 10 Oct 2011 22:28:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/11] IO-less dirty throttling v12
Message-ID: <20111010142846.GA21218@localhost>
References: <20111003134228.090592370@intel.com>
 <1318248846.14400.21.camel@laptop>
 <20111010130722.GA11387@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111010130722.GA11387@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Trond,

> As for the NFS performance, the dd tests show that adding a writeback
> wait queue to limit the number of NFS PG_writeback pages (patches
> will follow) is able to gain 48% throughput in itself:
> 
>       3.1.0-rc8-ioless6+         3.1.0-rc8-nfs-wq+  
> ------------------------  ------------------------  
>                    22.43       +81.8%        40.77  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
>                    28.21       +52.6%        43.07  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
>                    29.21       +55.4%        45.39  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
>                    14.12       +40.4%        19.83  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
>                    29.44       +11.4%        32.81  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
>                     9.09      +240.9%        30.97  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
>                    25.68       +84.6%        47.42  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
>                    41.06        +7.6%        44.20  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
>                    39.13       +25.9%        49.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
>                   238.38       +48.4%       353.72  TOTAL
> 
> Which will result in 28% overall improvements over the vanilla kernel:
> 
>       3.1.0-rc4-vanilla+         3.1.0-rc8-nfs-wq+  
> ------------------------  ------------------------  
>                    20.89       +95.2%        40.77  NFS-thresh=100M/nfs-10dd-1M-32p-32768M-100M:10-X
>                    39.43        +9.2%        43.07  NFS-thresh=100M/nfs-1dd-1M-32p-32768M-100M:10-X
>                    26.60       +70.6%        45.39  NFS-thresh=100M/nfs-2dd-1M-32p-32768M-100M:10-X
>                    12.70       +56.1%        19.83  NFS-thresh=10M/nfs-10dd-1M-32p-32768M-10M:10-X
>                    27.41       +19.7%        32.81  NFS-thresh=10M/nfs-1dd-1M-32p-32768M-10M:10-X
>                    26.52       +16.8%        30.97  NFS-thresh=10M/nfs-2dd-1M-32p-32768M-10M:10-X
>                    40.70       +16.5%        47.42  NFS-thresh=1G/nfs-10dd-1M-32p-32768M-1024M:10-X
>                    45.28        -2.4%        44.20  NFS-thresh=1G/nfs-1dd-1M-32p-32768M-1024M:10-X
>                    35.74       +37.8%        49.26  NFS-thresh=1G/nfs-2dd-1M-32p-32768M-1024M:10-X
>                   275.28       +28.5%       353.72  TOTAL
> 
> As for the most concerned NFS commits, the wait queue patch increases
> the (nr_commits / bytes_written) ratio by +74% for the thresh=1G,10dd
> case, +55% for the thresh=100M,10dd case, and mostly ignorable in the
> other 1dd, 2dd cases, which looks acceptable.
> 
> The other noticeable change of the wait queue is, the RTT time per

Sorry it's not RTT, but mainly the local queue time of the WRITE RPCs.

> write is reduced by 1-2 order(s) in many of the below cases (from
> dozens of seconds to hundreds of milliseconds).

I also measured the stddev of the network bandwidths, and find more
smooth network transfers in general with the wait queue, which is
expected.

thresh=1G
        vanilla       ioless6       nfs-wq
1dd     83088173.728  53468627.578  53627922.011
2dd     52398918.208  43733074.167  53531381.177
10dd    67792638.857  44734947.283  39681731.234

However the major difference should still be that the writeback wait
queue can significantly reduce the local queue time for the WRITE RPCs.

The wait queue patch looks reasonable in that it keeps the pages in
PG_dirty state rather than to prematurely put them to PG_writeback
state only to queue them up for dozens of seconds before xmit.

It should be safe because that's exactly the old proved behavior
before the per-bdi writeback patches introduced in 2.6.32. The 2nd
patch on proportional nfs_congestion_kb is a new change, though.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
