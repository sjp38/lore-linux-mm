Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 871C06B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 00:22:24 -0500 (EST)
Date: Wed, 24 Feb 2010 16:22:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224052215.GH16175@discord.disaster>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100224041822.GB27459@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 24, 2010 at 12:18:22PM +0800, Wu Fengguang wrote:
> On Wed, Feb 24, 2010 at 11:29:34AM +0800, Dave Chinner wrote:
> > On Wed, Feb 24, 2010 at 10:41:01AM +0800, Wu Fengguang wrote:
> > > With default rsize=512k and NFS_MAX_READAHEAD=15, the current NFS
> > > readahead size 512k*15=7680k is too large than necessary for typical
> > > clients.
> > > 
> > > On a e1000e--e1000e connection, I got the following numbers
> > > 
> > > 	readahead size		throughput
> > > 		   16k           35.5 MB/s
> > > 		   32k           54.3 MB/s
> > > 		   64k           64.1 MB/s
> > > 		  128k           70.5 MB/s
> > > 		  256k           74.6 MB/s
> > > rsize ==>	  512k           77.4 MB/s
> > > 		 1024k           85.5 MB/s
> > > 		 2048k           86.8 MB/s
> > > 		 4096k           87.9 MB/s
> > > 		 8192k           89.0 MB/s
> > > 		16384k           87.7 MB/s
> > > 
> > > So it seems that readahead_size=2*rsize (ie. keep two RPC requests in flight)
> > > can already get near full NFS bandwidth.
> > > 
> > > The test script is:
> > > 
> > > #!/bin/sh
> > > 
> > > file=/mnt/sparse
> > > BDI=0:15
> > > 
> > > for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
> > > do
> > > 	echo 3 > /proc/sys/vm/drop_caches
> > > 	echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
> > > 	echo readahead_size=${rasize}k
> > > 	dd if=$file of=/dev/null bs=4k count=1024000
> > > done
> > 
> > That's doing a cached read out of the server cache, right? You
> 
> It does not involve disk IO at least. (The sparse file dataset is
> larger than server cache.)

It still results in effectively the same thing: very low, consistent
IO latency.

Effectively all the test results show is that on a clean, low
latency, uncongested network an unloaded NFS server that has no IO
latency, a client only requires one 512k readahead block to hide 90%
of the server read request latency.  I don't think this is a
particularly good test to base a new default on, though.

e.g. What is the result with a smaller rsize? When the server
actually has to do disk IO?  When multiple clients are reading at
the same time so the server may not detect accesses as sequential
and issue readahead? When another client is writing to the server at
the same time as the read and causing significant read IO latency at
the server?

What I'm trying to say is that while I agree with your premise that
a 7.8MB readahead window is probably far larger than was ever
intended, I disagree with your methodology and environment for
selecting a better default value.  The default readahead value needs
to work well in as many situations as possible, not just in perfect
1:1 client/server environment.

> > might find the results are different if the server has to read the
> > file from disk. I would expect reads from the server cache not
> > to require much readahead as there is no IO latency on the server
> > side for the readahead to hide....
> 
> Sure the result will be different when disk IO is involved.
> In this case I would expect the server admin to setup the optimal
> readahead size for the disk(s).

The default should do the right thing when disk IO is involved, as
almost no-one has an NFS server that doesn't do IO.... ;)

> It sounds silly to have
> 
>         client_readahead_size > server_readahead_size

I don't think it is  - the client readahead has to take into account
the network latency as well as the server latency. e.g. a network
with a high bandwidth but high latency is going to need much more
client side readahead than a high bandwidth, low latency network to
get the same throughput. Hence it is not uncommon to see larger
readahead windows on network clients than for local disk access.

Also, the NFS server may not even be able to detect sequential IO
patterns because of the combined access patterns from the clients,
and so the only effective readahead might be what the clients
issue....

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
