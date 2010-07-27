Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BB869600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 07:10:04 -0400 (EDT)
Date: Tue, 27 Jul 2010 21:09:58 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100727110958.GA2913@amd>
References: <20100722190100.GA22269@amd>
 <20100723135514.GJ32635@dastard>
 <20100727070538.GA2893@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727070538.GA2893@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 05:05:39PM +1000, Nick Piggin wrote:
> On Fri, Jul 23, 2010 at 11:55:14PM +1000, Dave Chinner wrote:
> > On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> > > I'm pleased to announce I have a git tree up of my vfs scalability work.
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> > > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> > > 
> > > Branch vfs-scale-working
> > 
> > With a production build (i.e. no lockdep, no xfs debug), I'll
> > run the same fs_mark parallel create/unlink workload to show
> > scalability as I ran here:
> > 
> > http://oss.sgi.com/archives/xfs/2010-05/msg00329.html
> 
> I've made a similar setup, 2s8c machine, but using 2GB ramdisk instead
> of a real disk (I don't have easy access to a good disk setup ATM, but
> I guess we're more interested in code above the block layer anyway).
> 
> Made an XFS on /dev/ram0 with 16 ags, 64MB log, otherwise same config as
> yours.

I also tried dbench on this setup. 20 runs of dbench -t20 8
(that is a 20 second run, 8 clients).

Numbers are throughput, higher is better:

          N           Min           Max        Median           Avg Stddev
vanilla  20       2219.19       2249.43       2230.43     2230.9915 7.2528893
scale    20       2428.21        2490.8       2437.86      2444.111 16.668256
Difference at 95.0% confidence
        213.119 +/- 8.22695
        9.55268% +/- 0.368757%
        (Student's t, pooled s = 12.8537)

vfs-scale is 9.5% or 210MB/s faster than vanilla.

Like fs_mark, dbench has creat/unlink activity, so I hope rcu-inodes
should not be such a problem in practice. In my creat/unlink benchmark,
it is creating and destroying one inode repeatedly, which is the
absolute worst case for rcu-inodes. Wheras in most real workloads
would be creating and destroying many inodes, which is not such a dis
advantage for rcu-inodes.

Incidentally, XFS was by far the fastest "real" filesystem I tested on
this workload. ext4 was around 1700MB/s (ext2 was around 3100MB/s and
ramfs is 3350MB/s).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
