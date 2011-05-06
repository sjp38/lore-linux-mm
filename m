Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B5D576B0022
	for <linux-mm@kvack.org>; Fri,  6 May 2011 19:06:26 -0400 (EDT)
Date: Sat, 7 May 2011 09:06:19 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC][PATCH v2] writeback: limit number of moved inodes in
 queue_io()
Message-ID: <20110506230619.GG26837@dastard>
References: <20110420080336.441157866@intel.com>
 <20110420080918.560499032@intel.com>
 <20110504073931.GA22675@localhost>
 <20110505163708.GN5323@quack.suse.cz>
 <20110506052955.GA24904@localhost>
 <20110506084238.GA487@localhost>
 <20110506100648.GA3435@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506100648.GA3435@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "Li, Shaohua" <shaohua.li@intel.com>

On Fri, May 06, 2011 at 06:06:48PM +0800, Wu Fengguang wrote:
> On Fri, May 06, 2011 at 04:42:38PM +0800, Wu Fengguang wrote:
> > > patched trace-tar-dd-ext4-2.6.39-rc3+
> > 
> > >        flush-8:0-3048  [004]  1929.981734: writeback_queue_io: bdi 8:0: older=4296600898 age=2 enqueue=13227
> > 
> > > vanilla trace-tar-dd-ext4-2.6.39-rc3
> > 
> > >        flush-8:0-2911  [004]    77.158312: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=18938
> > 
> > >        flush-8:0-2911  [000]    82.461064: writeback_queue_io: bdi 8:0: older=0 age=-1 enqueue=6957
> > 
> > It looks too much to move 13227 and 18938 inodes at once. So I tried
> > arbitrarily limiting the max move number to 1000 and it helps reduce
> > the lock hold time and contentions a lot.
> 
> Oh it seems 1000 is too small at least for this workload, it hurts
> dd+tar+sync total elapsed time. 
> 
> no limit:
>                 avg        167.486 
>                 stddev       8.996 
> limit=1000:
>                 avg        171.222 
>                 stddev       5.588 
> limit=3000:
>                 avg        165.335 
>                 stddev       5.503 
> 
> So use 3000 as the new limit.

I don't think that's even enough. The number is going to be workload
dependent and while a limit might be a good idea, I don't think it
can be chosen just from one simple benchmark. e.g. what does it to
do performance of workloads creating tens of thousands of small
dirty files a second?

....

>                               class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-b
> ounces   acquisitions   holdtime-min   holdtime-max holdtime-total
> ----------------------------------------------------------------------------------------------------------------------------
> -------------------------------------------------------------------
> vanilla 2.6.39-rc3:
>                       inode_wb_list_lock:          2063           2065           0.12        2648.66        5948.99
>  27475         943778           0.09        2704.76      498340.24

I wouldn't consider this a contended lock at all on this workload.

FWIW, my profiles on sustained 8-way small file creation workloads
on ext4 over tens of millions of inodes show a 0.1% contention rate
for the inode_wb_list_lock. That compares to a 2% contention rate
for the inode_lru_lock, a 4% contention rate on the
inode_sb_list_lock and a 6% contention rate on the inode_hash_lock.
So really, the inode_wb_list_lock is not the lock we need to spend
effort on optimising to the nth degree right now...

......
> limit=1000:
> 
> dd+tar+sync total elapsed time (10 runs):
> 				avg        171.222 
> 				stddev       5.588 
> 
>                 &(&wb->list_lock)->rlock:           842            842           0.14         101.10        1013.34
>  20489         970892           0.09         234.11      509829.79
.....
> limit=3000:
> 
> dd+tar+sync total elapsed time (10 runs):
> 				avg        165.335
> 				stddev       5.503
> 
>                 &(&wb->list_lock)->rlock:          1088           1092           0.11         245.08        3268.75
>  21124        1718636           0.09         384.53      849827.20

So, from this acquisitions are doubled, and the total lock hold time
has almost doubled as well. That seems like there's a fair bit of
inefficiency introduced. What does it do to the CPU time consumed by
queue_io() (perf top is your friend)?

FYI, queue_io() is already a _massive_ CPU hog.  See commit dcd79a1
("xfs: don't use vfs writeback for pure metadata modifications") for
how XFS tries to avoid putting dirty inodes on the list if at all
possible:

    Under heavy multi-way parallel create workloads, the VFS
    struggles to write back all the inodes that have been changed in
    age order.  The bdi flusher thread becomes CPU bound, spending
    85% of it's time in the VFS code, mostly traversing the
    superblock dirty inode list to separate dirty inodes old enough
    to flush.

    We already keep an index of all metadata changes in age order -
    in the AIL - and continued log pressure will do age ordered
    writeback without any extra overhead at all. If there is no
    pressure on the log, the xfssyncd will periodically write back
    metadata in ascending disk address offset order so will be very
    efficient.
    .....

We're moving towards only tracking inodes with dirty pages in the
b_dirty list for XFS because this time based expiry is so
inefficient. So anything that reduces the efficiency of
queue_io()....

Cheers,

Dave.


-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
