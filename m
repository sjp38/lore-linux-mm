Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 477066B004A
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 22:27:04 -0400 (EDT)
Date: Sat, 4 Sep 2010 12:25:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/3] mm: page allocator: Drain per-cpu lists after
 direct reclaim allocation fails
Message-ID: <20100904022545.GD705@dastard>
References: <1283504926-2120-1-git-send-email-mel@csn.ul.ie>
 <1283504926-2120-4-git-send-email-mel@csn.ul.ie>
 <20100903160026.564fdcc9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903160026.564fdcc9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 04:00:26PM -0700, Andrew Morton wrote:
> On Fri,  3 Sep 2010 10:08:46 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > When under significant memory pressure, a process enters direct reclaim
> > and immediately afterwards tries to allocate a page. If it fails and no
> > further progress is made, it's possible the system will go OOM. However,
> > on systems with large amounts of memory, it's possible that a significant
> > number of pages are on per-cpu lists and inaccessible to the calling
> > process. This leads to a process entering direct reclaim more often than
> > it should increasing the pressure on the system and compounding the problem.
> > 
> > This patch notes that if direct reclaim is making progress but
> > allocations are still failing that the system is already under heavy
> > pressure. In this case, it drains the per-cpu lists and tries the
> > allocation a second time before continuing.
....
> The patch looks reasonable.
> 
> But please take a look at the recent thread "mm: minute-long livelocks
> in memory reclaim".  There, people are pointing fingers at that
> drain_all_pages() call, suspecting that it's causing huge IPI storms.
> 
> Dave was going to test this theory but afaik hasn't yet done so.  It
> would be nice to tie these threads together if poss?

It's been my "next-thing-to-do" since David suggested I try it -
tracking down other problems has got in the way, though. I
just ran my test a couple of times through:

$ ./fs_mark -D 10000 -L 63 -S0 -n 100000 -s 0 \
	-d /mnt/scratch/0 -d /mnt/scratch/1 \
	-d /mnt/scratch/3 -d /mnt/scratch/2 \
	-d /mnt/scratch/4 -d /mnt/scratch/5 \
	-d /mnt/scratch/6 -d /mnt/scratch/7

To create millions of inodes in parallel on an 8p/4G RAM VM.
The filesystem is ~1.1TB XFS:

# mkfs.xfs -f -d agcount=16 /dev/vdb
meta-data=/dev/vdb               isize=256    agcount=16, agsize=16777216 blks
         =                       sectsz=512   attr=2
data     =                       bsize=4096   blocks=268435456, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0
log      =internal log           bsize=4096   blocks=131072, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
# mount -o inode64,delaylog,logbsize=262144,nobarrier /dev/vdb /mnt/scratch

Performance prior to this patch was that each iteration resulted in
~65k files/s, with occassionaly peaks to 90k files/s, but drops to
frequently 45k files/s when reclaim ran to reclaim the inode
caches. This load ran permanently at 800% CPU usage.

Every so often (may once or twice a 50M inode create run) all 8 CPUs
would remain pegged but the create rate would drop to zero for a few
seconds to a couple of minutes. that was the livelock issues I
reported.

With this patchset, I'm seeing a per-iteration average of ~77k
files/s, with only a couple of iterations dropping down to ~55k
file/s and a significantly number above 90k/s. The runtime to 50M
inodes is down by ~30% and the average CPU usage across the run is
around 700%. IOWs, there a significant gain in performance there is
a significant drop in CPU usage. I've done two runs to 50m inodes,
and not seen any sign of a livelock, even for short periods of time.

Ah, spoke too soon - I let the second run keep going, and at ~68M
inodes it's just pegged all the CPUs and is pretty much completely
wedged. Serial console is not responding, I can't get a new login,
and the only thing responding that tells me the machine is alive is
the remote PCP monitoring. It's been stuck for 5 minutes .... and
now it is back. Here's what I saw:

http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-wedge-1.png

The livelock is at the right of the charts, where the top chart is
all red (system CPU time), and the other charts flat line to zero.

And according to fsmark:

     1     66400000            0      64554.2          7705926
     1     67200000            0      64836.1          7573013
<hang happened here>
     2     68000000            0      69472.8          7941399
     2     68800000            0      85017.5          7585203

it didn't record any change in performance, which means the livelock
probably occurred between iterations.  I couldn't get any info on
what caused the livelock this time so I can only assume it has the
same cause....

Still, given the improvements in performance from this patchset,
I'd say inclusion is a no-braniner....

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
