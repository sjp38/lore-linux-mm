Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 017BB6B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 09:31:01 -0400 (EDT)
Date: Mon, 2 Jul 2012 14:30:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [MMTests] IO metadata on XFS
Message-ID: <20120702133057.GR14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
 <20120629112505.GF14154@suse.de>
 <20120701235458.GM19223@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120701235458.GM19223@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com

On Mon, Jul 02, 2012 at 09:54:58AM +1000, Dave Chinner wrote:
> On Fri, Jun 29, 2012 at 12:25:06PM +0100, Mel Gorman wrote:
> > Configuration:	global-dhp__io-metadata-xfs
> > Benchmarks:	dbench3, fsmark-single, fsmark-threaded
> > 
> > Summary
> > =======
> > Most of the figures look good and in general there has been consistent good
> > performance from XFS. However, fsmark-single is showing a severe performance
> > dip in a few cases somewhere between 3.1 and 3.4. fs-mark running a single
> > thread took a particularly bad dive in 3.4 for two machines that is worth
> > examining closer.
> 
> That will be caused by the fact we changed all the metadata updates
> to be logged, which means a transaction every time .dirty_inode is
> called.
> 

Ok.

> This should mostly go away when XFS is converted to use .update_time
> rather than .dirty_inode to only issue transactions when the VFS
> updates the atime rather than every .dirty_inode call...
> 

Sound. I'll keep an eye out for it in the future.  If you want to
use the same test configuration then be sure you set the partition
configuration correctly. For example, these are the values I used for
config-global-dhp__io-metadata configuration file.

export TESTDISK_PARTITION=/dev/sda6
export TESTDISK_FILESYSTEM=xfs
export TESTDISK_MKFS_PARAM="-f -d agcount=8"
export TESTDISK_MOUNT_ARGS=inode64,delaylog,logbsize=262144,nobarrier

> > Unfortunately it is harder to easy conclusions as the
> > gains/losses are not consistent between machines which may be related to
> > the available number of CPU threads.
> 
> It increases the CPU overhead (dirty_inode can be called up to 4
> times per write(2) call, IIRC), so with limited numbers of
> threads/limited CPU power it will result in lower performance. Where
> you have lots of CPU power, there will be little difference in
> performance...
> 

Thanks for that clarification.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
