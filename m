Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 261276B00C9
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 05:41:08 -0500 (EST)
Received: by iwn9 with SMTP id 9so2017624iwn.14
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 02:41:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101117042849.410279291@intel.com>
References: <20101117042720.033773013@intel.com>
	<20101117042849.410279291@intel.com>
Date: Wed, 17 Nov 2010 19:34:26 +0900
Message-ID: <AANLkTimV1Y5_6CSjz24dbLjYcoiVn6+6chPhpzHZm8LK@mail.gmail.com>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Wu,

As you know, I am not a expert in this area.
So I hope my review can help understanding other newbie like me and
make clear this document. :)
I didn't look into the code. before it, I would like to clear your concept.

On Wed, Nov 17, 2010 at 1:27 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> As proposed by Chris, Dave and Jan, don't start foreground writeback IO
> inside balance_dirty_pages(). Instead, simply let it idle sleep for some
> time to throttle the dirtying task. In the mean while, kick off the
> per-bdi flusher thread to do background writeback IO.
>
> This patch introduces the basic framework, which will be further
> consolidated by the next patches.
>
> RATIONALS
> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The current balance_dirty_pages() is rather IO inefficient.
>
> - concurrent writeback of multiple inodes (Dave Chinner)
>
> =A0If every thread doing writes and being throttled start foreground
> =A0writeback, it leads to N IO submitters from at least N different
> =A0inodes at the same time, end up with N different sets of IO being
> =A0issued with potentially zero locality to each other, resulting in
> =A0much lower elevator sort/merge efficiency and hence we seek the disk
> =A0all over the place to service the different sets of IO.
> =A0OTOH, if there is only one submission thread, it doesn't jump between
> =A0inodes in the same way when congestion clears - it keeps writing to
> =A0the same inode, resulting in large related chunks of sequential IOs
> =A0being issued to the disk. This is more efficient than the above
> =A0foreground writeback because the elevator works better and the disk
> =A0seeks less.
>
> - IO size too small for fast arrays and too large for slow USB sticks
>
> =A0The write_chunk used by current balance_dirty_pages() cannot be
> =A0directly set to some large value (eg. 128MB) for better IO efficiency.
> =A0Because it could lead to more than 1 second user perceivable stalls.
> =A0Even the current 4MB write size may be too large for slow USB sticks.
> =A0The fact that balance_dirty_pages() starts IO on itself couples the
> =A0IO size to wait time, which makes it hard to do suitable IO size while
> =A0keeping the wait time under control.
>
> For the above two reasons, it's much better to shift IO to the flusher
> threads and let balance_dirty_pages() just wait for enough time or progre=
ss.
>
> Jan Kara, Dave Chinner and me explored the scheme to let
> balance_dirty_pages() wait for enough writeback IO completions to
> safeguard the dirty limit. However it's found to have two problems:
>
> - in large NUMA systems, the per-cpu counters may have big accounting
> =A0errors, leading to big throttle wait time and jitters.
>
> - NFS may kill large amount of unstable pages with one single COMMIT.
> =A0Because NFS server serves COMMIT with expensive fsync() IOs, it is
> =A0desirable to delay and reduce the number of COMMITs. So it's not
> =A0likely to optimize away such kind of bursty IO completions, and the
> =A0resulted large (and tiny) stall times in IO completion based throttlin=
g.
>
> So here is a pause time oriented approach, which tries to control the
> pause time in each balance_dirty_pages() invocations, by controlling
> the number of pages dirtied before calling balance_dirty_pages(), for
> smooth and efficient dirty throttling:
>
> - avoid useless (eg. zero pause time) balance_dirty_pages() calls
> - avoid too small pause time (less than =A010ms, which burns CPU power)
> - avoid too large pause time (more than 100ms, which hurts responsiveness=
)
> - avoid big fluctuations of pause times
>
> For example, when doing a simple cp on ext4 with mem=3D4G HZ=3D250.
>
> before patch, the pause time fluctuates from 0 to 324ms
> (and the stall time may grow very large for slow devices)
>
> [ 1237.139962] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D56
> [ 1237.207489] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D0
> [ 1237.225190] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D0
> [ 1237.234488] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D0
> [ 1237.244692] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D0
> [ 1237.375231] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D31
> [ 1237.443035] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D15
> [ 1237.574630] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D31
> [ 1237.642394] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D15
> [ 1237.666320] balance_dirty_pages: write_chunk=3D1536 pages_written=3D57=
 pause=3D5
> [ 1237.973365] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D81
> [ 1238.212626] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D56
> [ 1238.280431] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D15
> [ 1238.412029] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D31
> [ 1238.412791] balance_dirty_pages: write_chunk=3D1536 pages_written=3D0 =
pause=3D0
>
> after patch, the pause time remains stable around 32ms
>
> cp-2687 =A0[002] =A01452.237012: balance_dirty_pages: weight=3D56% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[002] =A01452.246157: balance_dirty_pages: weight=3D56% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[006] =A01452.253043: balance_dirty_pages: weight=3D56% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[006] =A01452.261899: balance_dirty_pages: weight=3D57% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[006] =A01452.268939: balance_dirty_pages: weight=3D57% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[002] =A01452.276932: balance_dirty_pages: weight=3D57% dirtie=
d=3D128 pause=3D8
> cp-2687 =A0[002] =A01452.285889: balance_dirty_pages: weight=3D57% dirtie=
d=3D128 pause=3D8
>
> CONTROL SYSTEM
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The current task_dirty_limit() adjusts bdi_dirty_limit to get
> task_dirty_limit according to the dirty "weight" of the current task,
> which is the percent of pages recently dirtied by the task. If 100%
> pages are recently dirtied by the task, it will lower bdi_dirty_limit by
> 1/8. If only 1% pages are dirtied by the task, it will return almost
> unmodified bdi_dirty_limit. In this way, a heavy dirtier will get
> blocked at task_dirty_limit=3D(bdi_dirty_limit-bdi_dirty_limit/8) while
> allowing a light dirtier to progress (the latter won't be blocked
> because R << B in fig.1).
>
> Fig.1 before patch, a heavy dirtier and a light dirtier
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0R
> ----------------------------------------------+-o------------------------=
---*--|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0L A =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
B =A0T
> =A0T: bdi_dirty_limit, as returned by bdi_dirty_limit()
> =A0L: T - T/8
>
> =A0R: bdi_reclaimable + bdi_writeback
>
> =A0A: task_dirty_limit for a heavy dirtier ~=3D R ~=3D L
> =A0B: task_dirty_limit for a light dirtier ~=3D T
>
> Since each process has its own dirty limit, we reuse A/B for the tasks as
> well as their dirty limits.
>
> If B is a newly started heavy dirtier, then it will slowly gain weight
> and A will lose weight. =A0The task_dirty_limit for A and B will be
> approaching the center of region (L, T) and eventually stabilize there.
>
> Fig.2 before patch, two heavy dirtiers converging to the same threshold
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 R
> ----------------------------------------------+--------------o-*---------=
------|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0L =A0 =A0 =A0 =A0 =A0 =A0 =A0A B =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 T

Seems good until now.
So, What's the problem if two heavy dirtiers have a same threshold?

>
> Fig.3 after patch, one heavy dirtier
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0|
> =A0 =A0throttle_bandwidth ~=3D bdi_bandwidth =A0=3D> =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0 =A0 =A0 o
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0La| =A0 =A0 =A0 =A0 =A0 o
> ----------------------------------------------+-+-------------o----------=
------|
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0R =A0 =A0 =A0 =A0 =A0 =A0 A =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0T
> =A0T: bdi_dirty_limit
> =A0A: task_dirty_limit =A0 =A0 =A0=3D T - Wa * T/16
> =A0La: task_throttle_thresh =3D A - A/16
>
> =A0R: bdi_dirty_pages =3D bdi_reclaimable + bdi_writeback ~=3D La
>
> Now for IO-less balance_dirty_pages(), let's do it in a "bandwidth contro=
l"
> way. In fig.3, a soft dirty limit region (La, A) is introduced. When R en=
ters
> this region, the task may be throttled for J jiffies on every N pages it =
dirtied.
> Let's call (N/J) the "throttle bandwidth". It is computed by the followin=
g formula:
>
> =A0 =A0 =A0 =A0throttle_bandwidth =3D bdi_bandwidth * (A - R) / (A - La)
> where
> =A0 =A0 =A0 =A0A =3D T - Wa * T/16
> =A0 =A0 =A0 =A0La =3D A - A/16
> where Wa is task weight for A. It's 0 for very light dirtier and 1 for
> the one heavy dirtier (that consumes 100% bdi write bandwidth). =A0The
> task weight will be updated independently by task_dirty_inc() at
> set_page_dirty() time.


Dumb question.

I can't see the difference between old and new,
La depends on A.
A depends on Wa.
T is constant?
Then, throttle_bandwidth depends on Wa.
Wa depends on the number of dirtied pages during some interval.
So if light dirtier become heavy, at last light dirtier and heavy
dirtier will have a same weight.
It means throttle_bandwidth is same. It's a same with old result.

Please, open my eyes. :)
Thanks for the great work.

>
> When R < La, we don't throttle it at all.
> When R > A, the code will detect the negativeness and choose to pause
> 100ms (the upper pause boundary), then loop over again.




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
