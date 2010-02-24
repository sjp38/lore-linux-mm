Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8DDBD6B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:29:43 -0500 (EST)
Date: Wed, 24 Feb 2010 14:29:34 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224032934.GF16175@discord.disaster>
References: <20100224024100.GA17048@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100224024100.GA17048@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 10:41:01AM +0800, Wu Fengguang wrote:
> With default rsize=512k and NFS_MAX_READAHEAD=15, the current NFS
> readahead size 512k*15=7680k is too large than necessary for typical
> clients.
> 
> On a e1000e--e1000e connection, I got the following numbers
> 
> 	readahead size		throughput
> 		   16k           35.5 MB/s
> 		   32k           54.3 MB/s
> 		   64k           64.1 MB/s
> 		  128k           70.5 MB/s
> 		  256k           74.6 MB/s
> rsize ==>	  512k           77.4 MB/s
> 		 1024k           85.5 MB/s
> 		 2048k           86.8 MB/s
> 		 4096k           87.9 MB/s
> 		 8192k           89.0 MB/s
> 		16384k           87.7 MB/s
> 
> So it seems that readahead_size=2*rsize (ie. keep two RPC requests in flight)
> can already get near full NFS bandwidth.
> 
> The test script is:
> 
> #!/bin/sh
> 
> file=/mnt/sparse
> BDI=0:15
> 
> for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
> do
> 	echo 3 > /proc/sys/vm/drop_caches
> 	echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
> 	echo readahead_size=${rasize}k
> 	dd if=$file of=/dev/null bs=4k count=1024000
> done

That's doing a cached read out of the server cache, right? You
might find the results are different if the server has to read the
file from disk. I would expect reads from the server cache not
to require much readahead as there is no IO latency on the server
side for the readahead to hide....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
