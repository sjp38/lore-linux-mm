Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7E9646B0078
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 22:10:25 -0500 (EST)
Date: Tue, 2 Mar 2010 11:10:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] nfs: use 4*rsize readahead size
Message-ID: <20100302031021.GA14267@localhost>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost> <20100224073940.GJ16175@discord.disaster> <20100226074916.GA8545@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100226074916.GA8545@localhost>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Dave,

Here is one more test on a big ext4 disk file:

	   16k	39.7 MB/s
	   32k	54.3 MB/s
	   64k	63.6 MB/s
	  128k	72.6 MB/s
	  256k	71.7 MB/s
rsize ==> 512k  71.7 MB/s
	 1024k	72.2 MB/s
	 2048k	71.0 MB/s
	 4096k	73.0 MB/s
	 8192k	74.3 MB/s
	16384k	74.5 MB/s

It shows that >=128k client side readahead is enough for single disk
case :) As for RAID configurations, I guess big server side readahead
should be enough.

#!/bin/sh

file=/mnt/ext4_test/zero
BDI=0:24

for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
do
        echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
        echo readahead_size=${rasize}k
        fadvise $file 0 0 dontneed
        ssh p9 "fadvise $file 0 0 dontneed"
        dd if=$file of=/dev/null bs=4k count=402400
done

Thanks,
Fengguang

On Fri, Feb 26, 2010 at 03:49:16PM +0800, Wu Fengguang wrote:
> On Wed, Feb 24, 2010 at 03:39:40PM +0800, Dave Chinner wrote:
> > On Wed, Feb 24, 2010 at 02:12:47PM +0800, Wu Fengguang wrote:
> > > On Wed, Feb 24, 2010 at 01:22:15PM +0800, Dave Chinner wrote:
> > > > What I'm trying to say is that while I agree with your premise that
> > > > a 7.8MB readahead window is probably far larger than was ever
> > > > intended, I disagree with your methodology and environment for
> > > > selecting a better default value.  The default readahead value needs
> > > > to work well in as many situations as possible, not just in perfect
> > > > 1:1 client/server environment.
> > > 
> > > Good points. It's imprudent to change a default value based on one
> > > single benchmark. Need to collect more data, which may take time..
> > 
> > Agreed - better to spend time now to get it right...
> 
> I collected more data with large network latency as well as rsize=32k,
> and updates the readahead size accordingly to 4*rsize.
> 
> ===
> nfs: use 2*rsize readahead size
> 
> With default rsize=512k and NFS_MAX_READAHEAD=15, the current NFS
> readahead size 512k*15=7680k is too large than necessary for typical
> clients.
> 
> On a e1000e--e1000e connection, I got the following numbers
> (this reads sparse file from server and involves no disk IO)
> 
> readahead size	normal		1ms+1ms		5ms+5ms		10ms+10ms(*)
> 	   16k	35.5 MB/s	 4.8 MB/s 	 2.1 MB/s 	1.2 MB/s
> 	   32k	54.3 MB/s	 6.7 MB/s 	 3.6 MB/s       2.3 MB/s
> 	   64k	64.1 MB/s	12.6 MB/s	 6.5 MB/s       4.7 MB/s
> 	  128k	70.5 MB/s	20.1 MB/s	11.9 MB/s       8.7 MB/s
> 	  256k	74.6 MB/s	38.6 MB/s	21.3 MB/s      15.0 MB/s
> rsize ==> 512k	77.4 MB/s	59.4 MB/s	39.8 MB/s      25.5 MB/s
> 	 1024k	85.5 MB/s	77.9 MB/s	65.7 MB/s      43.0 MB/s
> 	 2048k	86.8 MB/s	81.5 MB/s	84.1 MB/s      59.7 MB/s
> 	 4096k	87.9 MB/s	77.4 MB/s	56.2 MB/s      59.2 MB/s
> 	 8192k	89.0 MB/s	81.2 MB/s	78.0 MB/s      41.2 MB/s
> 	16384k	87.7 MB/s	85.8 MB/s	62.0 MB/s      56.5 MB/s
> 
> readahead size	normal		1ms+1ms		5ms+5ms		10ms+10ms(*)
> 	   16k	37.2 MB/s	 6.4 MB/s	 2.1 MB/s	 1.2 MB/s
> rsize ==>  32k	56.6 MB/s        6.8 MB/s        3.6 MB/s        2.3 MB/s
> 	   64k	66.1 MB/s       12.7 MB/s        6.6 MB/s        4.7 MB/s
> 	  128k	69.3 MB/s       22.0 MB/s       12.2 MB/s        8.9 MB/s
> 	  256k	69.6 MB/s       41.8 MB/s       20.7 MB/s       14.7 MB/s
> 	  512k	71.3 MB/s       54.1 MB/s       25.0 MB/s       16.9 MB/s
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 	 1024k	71.5 MB/s       48.4 MB/s       26.0 MB/s       16.7 MB/s
> 	 2048k	71.7 MB/s       53.2 MB/s       25.3 MB/s       17.6 MB/s
> 	 4096k	71.5 MB/s       50.4 MB/s       25.7 MB/s       17.1 MB/s
> 	 8192k	71.1 MB/s       52.3 MB/s       26.3 MB/s       16.9 MB/s
> 	16384k	70.2 MB/s       56.6 MB/s       27.0 MB/s       16.8 MB/s
> 
> (*) 10ms+10ms means to add delay on both client & server sides with
>     # /sbin/tc qdisc change dev eth0 root netem delay 10ms 
>     The total >=20ms delay is so large for NFS, that a simple `vi some.sh`
>     command takes a dozen seconds. Note that the actual delay reported
>     by ping is larger, eg. for the 1ms+1ms case:
>         rtt min/avg/max/mdev = 7.361/8.325/9.710/0.837 ms
>     
> 
> So it seems that readahead_size=4*rsize (ie. keep 4 RPC requests in
> flight) is able to get near full NFS bandwidth. Reducing the mulriple
> from 15 to 4 not only makes the client side readahead size more sane
> (2MB by default), but also reduces the disorderness of the server side
> RPC read requests, which yeilds better server side readahead behavior.
> 
> To avoid small readahead when the client mount with "-o rsize=32k" or
> the server only supports rsize <= 32k, we take the max of 2*rsize and
> default_backing_dev_info.ra_pages. The latter defaults to 512K, and can
> be explicitly changed by user with kernel parameter "readahead=" and
> runtime tunable "/sys/devices/virtual/bdi/default/read_ahead_kb" (which
> takes effective for future NFS mounts).
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
> 
> CC: Dave Chinner <david@fromorbit.com> 
> CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/nfs/client.c   |    4 +++-
>  fs/nfs/internal.h |    8 --------
>  2 files changed, 3 insertions(+), 9 deletions(-)
> 
> --- linux.orig/fs/nfs/client.c	2010-02-26 10:10:46.000000000 +0800
> +++ linux/fs/nfs/client.c	2010-02-26 11:07:22.000000000 +0800
> @@ -889,7 +889,9 @@ static void nfs_server_set_fsinfo(struct
>  	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  
>  	server->backing_dev_info.name = "nfs";
> -	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
> +	server->backing_dev_info.ra_pages = max_t(unsigned long,
> +					      default_backing_dev_info.ra_pages,
> +					      4 * server->rpages);
>  	server->backing_dev_info.capabilities |= BDI_CAP_ACCT_UNSTABLE;
>  
>  	if (server->wsize > max_rpc_payload)
> --- linux.orig/fs/nfs/internal.h	2010-02-26 10:10:46.000000000 +0800
> +++ linux/fs/nfs/internal.h	2010-02-26 11:07:07.000000000 +0800
> @@ -10,14 +10,6 @@
>  
>  struct nfs_string;
>  
> -/* Maximum number of readahead requests
> - * FIXME: this should really be a sysctl so that users may tune it to suit
> - *        their needs. People that do NFS over a slow network, might for
> - *        instance want to reduce it to something closer to 1 for improved
> - *        interactive response.
> - */
> -#define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
> -
>  /*
>   * Determine if sessions are in use.
>   */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
