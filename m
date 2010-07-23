Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B8F266B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 12:16:22 -0400 (EDT)
Date: Sat, 24 Jul 2010 02:16:13 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100723161613.GB6316@amd>
References: <20100722190100.GA22269@amd>
 <20100723135514.GJ32635@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723135514.GJ32635@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 11:55:14PM +1000, Dave Chinner wrote:
> On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > 
> > Branch vfs-scale-working
> 
> Bug's I've noticed so far:
> 
> - Using XFS, the existing vfs inode count statistic does not decrease
>   as inodes are free.
> - the existing vfs dentry count remains at zero
> - the existing vfs free inode count remains at zero
> 
> $ pminfo -f vfs.inodes vfs.dentry
> 
> vfs.inodes.count
>     value 7472612
> 
> vfs.inodes.free
> value 0
> 
> vfs.dentry.count
> value 0
> 
> vfs.dentry.free
> value 0

Hm, I must have broken it along the way and not noticed. Thanks
for pointing that out.

 
> With a production build (i.e. no lockdep, no xfs debug), I'll
> run the same fs_mark parallel create/unlink workload to show
> scalability as I ran here:
> 
> http://oss.sgi.com/archives/xfs/2010-05/msg00329.html
> 
> The numbers can't be directly compared, but the test and the setup
> is the same.  The XFS numbers below are with delayed logging
> enabled. ext4 is using default mkfs and mount parameters except for
> barrier=0. All numbers are averages of three runs.
> 
> 	fs_mark rate (thousands of files/second)
>            2.6.35-rc5   2.6.35-rc5-scale
> threads    xfs   ext4     xfs    ext4
>   1         20    39       20     39
>   2         35    55       35     57
>   4         60    41       57     42
>   8         79     9       75      9
> 
> ext4 is getting IO bound at more than 2 threads, so apart from
> pointing out that XFS is 8-9x faster than ext4 at 8 thread, I'm
> going to ignore ext4 for the purposes of testing scalability here.
> 
> For XFS w/ delayed logging, 2.6.35-rc5 is only getting to about 600%
> CPU and with Nick's patches it's about 650% (10% higher) for
> slightly lower throughput.  So at this class of machine for this
> workload, the changes result in a slight reduction in scalability.

That's a good test case, thanks. I'll see if I can find where
this is coming from. I will suspect RCU-inodes I suppose. Hm,
may have to make them DESTROY_BY_RCU afterall.

Thanks,
Nick
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
