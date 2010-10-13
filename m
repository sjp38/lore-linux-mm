Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1D80C6B010F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 05:28:12 -0400 (EDT)
Date: Wed, 13 Oct 2010 20:26:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/17] [RFC] soft and dynamic dirty throttling limits
Message-ID: <20101013092627.GY4681@dastard>
References: <20100912154945.758129106@intel.com>
 <20101012141716.GA26702@infradead.org>
 <20101013030733.GV4681@dastard>
 <20101013082611.GA6733@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101013082611.GA6733@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 04:26:12PM +0800, Wu Fengguang wrote:
> On Wed, Oct 13, 2010 at 11:07:33AM +0800, Dave Chinner wrote:
> > On Tue, Oct 12, 2010 at 10:17:16AM -0400, Christoph Hellwig wrote:
> > > Wu, what's the state of this series?  It looks like we'll need it
> > > rather sooner than later - try to get at least the preparations in
> > > ASAP would be really helpful.
> > 
> > Not ready in it's current form. This load (creating millions of 1
> > byte files in parallel):
> > 
> > $ /usr/bin/time ./fs_mark -D 10000 -S0 -n 100000 -s 1 -L 63 \
> > > -d /mnt/scratch/0 -d /mnt/scratch/1 \
> > > -d /mnt/scratch/2 -d /mnt/scratch/3 \
> > > -d /mnt/scratch/4 -d /mnt/scratch/5 \
> > > -d /mnt/scratch/6 -d /mnt/scratch/7
> > 
> > Locks up all the fs_mark processes spinning in traces like the
> > following and no further progress is made when the inode cache
> > fills memory.
> 
> I reproduced the problem on a 6G/8p 2-socket 11-disk box.
> 
> The root cause is, pageout() is somehow called with low scan priority,
> which deserves more investigation.
> 
> The direct cause is, balance_dirty_pages() then keeps nr_dirty too low,
> which can be improved easily by not pushing down the soft dirty limit
> to less than 1-second worth of dirty pages.
> 
> My test box has two nodes, and their memory usage are rather unbalanced:
> (Dave, maybe you have NUMA setup too?)

No, I'm running the test in a single node VM.

FYI, I'm running the test on XFS (16TB 12 disk RAID0 stripe), using
the mount options "inode64,nobarrier,logbsize=262144,delaylog".

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
