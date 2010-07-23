Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E05586B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 09:55:28 -0400 (EDT)
Date: Fri, 23 Jul 2010 23:55:14 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: VFS scalability git tree
Message-ID: <20100723135514.GJ32635@dastard>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> I'm pleased to announce I have a git tree up of my vfs scalability work.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> 
> Branch vfs-scale-working

Bug's I've noticed so far:

- Using XFS, the existing vfs inode count statistic does not decrease
  as inodes are free.
- the existing vfs dentry count remains at zero
- the existing vfs free inode count remains at zero

$ pminfo -f vfs.inodes vfs.dentry

vfs.inodes.count
    value 7472612

vfs.inodes.free
value 0

vfs.dentry.count
value 0

vfs.dentry.free
value 0


Performance Summary:

With lockdep and CONFIG_XFS_DEBUG enabled, a 16 thread parallel
sequential create/unlink workload on an 8p/4GB RAM VM with a virtio
block device sitting on a short-stroked 12x2TB SAS array w/ 512MB
BBWC in RAID0 via dm and using the noop elevator in the guest VM:

$ sudo mkfs.xfs -f -l size=128m -d agcount=16 /dev/vdb
meta-data=/dev/vdb               isize=256    agcount=16, agsize=1638400 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=26214400, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=32768, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
$ sudo mount -o delaylog,logbsize=262144,nobarrier /dev/vdb /mnt/scratch
$ sudo chmod 777 /mnt/scratch
$ cd ~/src/fs_mark-3.3/
$  ./fs_mark  -S0  -n  500000  -s  0  -d  /mnt/scratch/0  -d  /mnt/scratch/1  -d  /mnt/scratch/3  -d  /mnt/scratch/2  -d  /mnt/scratch/4  -d  /mnt/scratch/5  -d  /mnt/scratch/6  -d  /mnt/scratch/7  -d  /mnt/scratch/8  -d  /mnt/scratch/9  -d  /mnt/scratch/10  -d  /mnt/scratch/11  -d  /mnt/scratch/12  -d  /mnt/scratch/13  -d  /mnt/scratch/14  -d  /mnt/scratch/15

			files/s
2.6.34-rc4		12550
2.6.35-rc5+scale	12285

So the same within the error margins of the benchmark.

Screenshot of monitoring graphs - you can see the effect of the
broken stats:

http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc4-16x500-xfs.png
http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc5-npiggin-scale-lockdep-16x500-xfs.png

With a production build (i.e. no lockdep, no xfs debug), I'll
run the same fs_mark parallel create/unlink workload to show
scalability as I ran here:

http://oss.sgi.com/archives/xfs/2010-05/msg00329.html

The numbers can't be directly compared, but the test and the setup
is the same.  The XFS numbers below are with delayed logging
enabled. ext4 is using default mkfs and mount parameters except for
barrier=0. All numbers are averages of three runs.

	fs_mark rate (thousands of files/second)
           2.6.35-rc5   2.6.35-rc5-scale
threads    xfs   ext4     xfs    ext4
  1         20    39       20     39
  2         35    55       35     57
  4         60    41       57     42
  8         79     9       75      9

ext4 is getting IO bound at more than 2 threads, so apart from
pointing out that XFS is 8-9x faster than ext4 at 8 thread, I'm
going to ignore ext4 for the purposes of testing scalability here.

For XFS w/ delayed logging, 2.6.35-rc5 is only getting to about 600%
CPU and with Nick's patches it's about 650% (10% higher) for
slightly lower throughput.  So at this class of machine for this
workload, the changes result in a slight reduction in scalability.

I looked at dbench on XFS as well, but didn't see any significant
change in the numbers at up to 200 load threads, so not much to
talk about there.

Sometime over the weekend I'll build a 16p VM and see what I get
from that...

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
