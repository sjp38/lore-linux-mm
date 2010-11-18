Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 754B16B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 02:27:27 -0500 (EST)
Date: Thu, 18 Nov 2010 18:27:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] IO-less dirty throttling v2
Message-ID: <20101118072706.GW13830@dastard>
References: <20101117042720.033773013@intel.com>
 <20101117150330.139251f9.akpm@linux-foundation.org>
 <20101118020640.GS22876@dastard>
 <20101117180912.38541ca4.akpm@linux-foundation.org>
 <20101118032141.GP13830@dastard>
 <20101117193431.ec1f4547.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117193431.ec1f4547.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 07:34:31PM -0800, Andrew Morton wrote:
> On Thu, 18 Nov 2010 14:21:41 +1100 Dave Chinner <david@fromorbit.com> wrote:
> 
> > > But mainly because we're taking the work accounting away from the user
> > > who caused it and crediting it to the kernel thread instead, and that's
> > > an actively *bad* thing to do.
> > 
> > The current foreground writeback is doing work on behalf of the
> > system (i.e. doing background writeback) and therefore crediting it
> > to the user process. That seems wrong to me; it's hiding the
> > overhead of system tasks in user processes.
> > 
> > IMO, time spent doing background writeback should not be creditted
> > to user processes - writeback caching is a function of the OS and
> > it's overhead should be accounted as such.
> 
> bah, that's bunk.  Using this logic, _no_ time spent in the kernel
> should be accounted to the user process and we may as well do away with
> system-time accounting altogether.

That's a rather extreme intepretation and not what I meant at all.
:/

> If userspace performs some action which causes the kernel to consume
> CPU resources, that consumption should be accounted to that process.

Which is pretty much impossible for work deferred to background
kernel threads. On a vanilla kernel (without this series), the CPU
dd consumes on ext4 is (output from top):

 PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
9875 dave      20   0 10708 1604  516 R   74  0.0   0:05.58 dd
9876 root      20   0     0    0    0 D   30  0.0   0:01.76 flush-253:16
 561 root      20   0     0    0    0 R   17  0.0  21:45.06 kswapd0
8820 root      20   0     0    0    0 S   10  0.0  15:58.61 jbd2/vdb-8

The dd is consuming 75% cpu time, all in system, including
foreground writeback.  We've got 30% being consumed by the bdi
flusher doing background writeback.  We've got 17% consumed by
kswapd reclaiming memory. And finally, 10% is consumed by a jbd2
thread.  So, all up, the dd is triggering ~130% CPU usage, but time
only reports:

$ /usr/bin/time dd if=/dev/zero of=/mnt/scratch/test1 bs=1024k count=10000
10000+0 records in
10000+0 records out
10485760000 bytes (10 GB) copied, 17.8536 s, 587 MB/s
0.00user 12.11system 0:17.91elapsed 67%CPU (0avgtext+0avgdata 7296maxresident)k
0inputs+0outputs (11major+506minor)pagefaults 0swaps

67% CPU usage for dd. IOWs, half of the CPU time associated with a
dd write is already accounted to kernel threads in a current kernel.

> Yes, writeback can be inaccurate because process A will write back
> process B's stuff, but that should even out on average, and it's more
> accurate than saying "zero".

Sure, but it still doesn't account for the flusher, jbd or kswapd
CPU usage that is still being chewed up. That's still missing from
'time dd'.

> > Indeed, nobody has
> > realised (until now) just how inefficient it really is because of
> > the fact that the overhead is mostly hidden in user process system
> > time.
> 
> "hidden"?  You do "time dd" and look at the output!
> 
> _now_ it's hidden.  You do "time dd" and whee, no system time!

What I meant is that the cost of foreground writeback was hidden in
the process system time. Now we have separated the two of them, we
can see exactly how much it was costing us because it is no longer
hidden inside the process system time.

Besides, there's plenty of system time still accounted to the dd.
It's now just the CPU time spent writing data into the page cache,
rather than write + writeback CPU time.

> You
> need to do complex gymnastics with kernel thread accounting to work out
> the real cost of your dd.

Yup, that's what we've been doing for years. ;) e.g from the high
bandwidth IO paper I presented at OLS 2006, section 5.3 "kswapd and
pdflush":

	"While running single threaded tests, it was clear
	that there was something running in the back-
	ground that was using more CPU time than the
	writer process and pdflush combined. A sin-
	gle threaded read from disk consuming a single
	CPU was consuming 10-15% of a CPU on each
	node running memory reclaim via kswapd. For
	a single threaded write, this was closer to 30%
	of a CPU per node. On our twelve node ma-
	chine, this meant that we were using between
	1.5 and 3.5 CPUs to reclaim memory being al-
	located by a single CPU."

(http://oss.sgi.com/projects/xfs/papers/ols2006/ols-2006-presentation.pdf)

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
