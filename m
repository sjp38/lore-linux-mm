Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 036966B0071
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 19:32:30 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o98NWNGm021831
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 16:32:23 -0700
Received: from gxk24 (gxk24.prod.google.com [10.202.11.24])
	by wpaz17.hot.corp.google.com with ESMTP id o98NTfAk025334
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 16:32:22 -0700
Received: by gxk24 with SMTP id 24so773461gxk.0
        for <linux-mm@kvack.org>; Fri, 08 Oct 2010 16:32:22 -0700 (PDT)
Subject: Results of my VFS scaling evaluation.
From: Frank Mayhar <fmayhar@google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Oct 2010 16:32:19 -0700
Message-ID: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: mrubin@google.com
List-ID: <linux-mm.kvack.org>

Nick Piggin has been doing work on lock contention in VFS, in particular
to remove the dcache and inode locks, and we are very interested in this
work.  He has entirely eliminated two of the most contended locks,
replacing them with a combination of more granular locking, seqlocks,
RCU lists and other mechanisms that reduce locking and contention in
general. He has published this work at

git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git

As we have run into problems with lock contention, Google is very
interested in these improvements.

Ia??ve built two kernels, one an unmodified 2.6.35 based on the a??mastera??
branch of Nicka??s tree (which is identical to the main Linux tree as of
that time) and one with Nicka??s changes based on the a??vfs-scalea?? branch
of his tree.

For each of the kernels I ran a a??socket testa?? and a a??storage test,a?? each
of which I ran on systems with a moderate number of cores and memory
(unfortunately I cana??t say more about the hardware).  I gathered test
results and kernel profiling data for each.

The "Socket Test" does a lot of socket operations; it fields lots of
connections, receiving and transmitting small amounts of data over each.
The application it emulates has run into bottlenecks on the dcache_lock
and the inode_lock several times in the past, which is why I chose it as
a target.

The "Storage Test" does more storage operations, doing some network
transfers but spending most of its time reading and writing the disk.  I
chose it for the obvious reason that any VFS changes will probably
directly affect its results.

Both of these tests are multithreaded with at least one thread per core
and are designed to put as much load on the application being tested as
possible.  They are in fact designed specifically to find performance
regressions (albeit at a higher level than the kernel), which makes them
very suitable for this testing.

Before going into details of the test results, however, I must say that
the most striking thing about Nick's work how stable it is.  In all of
the work I've been doing, all the kernels I've built and run and all the
tests I've run, I've run into no hangs and only one crash, that in an
area that we happen to stress very heavily, for which I posted a patch,
available at
 http://www.kerneltrap.org/mailarchive/linux-fsdevel/2010/9/27/6886943
The crash involved the fact that we use cgroups very heavily, and there
was an oversight in the new d_set_d_op() routine that failed to clear
flags before it set them.


The Socket Test

This test has a target rate which I'll refer to as 100%.  Internal
Google kernels (with modifications to specific code paths) allow the
test to generally achieve that rate, albeit not without substantial
effort.  Against the base 2.6.35 kernel I saw a rate of around 65.28%.
Against the modified kernel the rate was around 65.2%.  The difference,
while significant, is small and entirely expected given that the running
environment was not one that could take advantage of the improved
scaling.

More interesting was the kernel profile (which I generated with the new
perf_events framework).  This revealed a distinct improvement in locking
performance.  While both kernels spent a substantial amount of time in
locking, the modified kernel spent significantly less time there.

Both kernels spent the most time in lock_release (oddly enough; other
kernels I've seen tend to spend more time acquiring locks than releasing
them), however the base kernel spent 7.02% of its time there versus
2.47% for the modified kernel.  Further, while the unmodified kernel
spent more than a quarter (26.15%) of its time in that routine actually
in spin_unlock called from the dcache code (d_alloc, __d_lookup, et al),
the modified kernel spent only 8.56% of its time in the equivalent
calls.

Other lock calls showed similar improvements across the board.  I've
enclosed a snippet of the relevant measurements (as reported by "perf
report" in its call-graph mode) for each kernel.

While the overall performance drop is a little disappointing it's not
at all unexpected, as the environment was definitely not the one that
would be helped by the scaling improvements and there is a small but
nonzero cost to those improvements.  Fortunately, the cost seems small
enough that with some work it may be possible to effectively eliminate
it.


The Storage Test

This test doesn't have any single result; rather it has a number of
measurements of such things as sequential and random reads and writes
as well as a standard set of reads and writes recorded from an
application.

As one might expect, this test did fairly well; overall things seemed to
improve very slightly, by on the order of around one percent.  (There
was one outlier, a nearly 20 percent regression, but while it should be
eventually tracked down I don't think it's significant for the purposes
of this evaluation.)  My vague suspicion, though, is that the margin of
error (which I didn't compute) nearly eclipses that slight improvement.
Since the scaling improvements aren't expected to improve performance in
this kind of environment, this is actually still a win.

The locking-related profile graph for this test is _much_ more complex
for the Storage Test than for the Socket Test.  While it appears that
the dcache locking calls have been pushed down a bit in the profile it's
a bit hard to tell because other calls appear to dominate.  In the end,
it looks like there's very little difference made by the scaling
patches.


Conclusion.

In general Nick's work does appear to make things better for locking.
It virtually eliminates contention on two very important locks that we
have seen as bottlenecks, pushing locking from the root far enough down
into the leaves of the data structures that they are no longer of
significant concern as far as scaling to larger numbers of cores.  I
suspect that with some further work, the performance cost of the
improvements, already fairly small, can be essentially eliminated, at
least for the common cases.

In the long run this will be a net win.  Systems with large numbers of
cores are coming and these changes address the scalability challengs of
the Linux kernel to those systems.  There is still some work to be done,
however; in addition to the above issues, Nick has expressed concern
that incremental adoption of his changes will mean performance
regressions early on, since earlier changes lay the groundwork for later
improvements but in the meantime add overhead.  Those early regressions
will be compensated for in the long term by the later improvements but
may be problematic in the short term.

Finally, I have kernel profiles for all of the above tests, all of which
are excessively huge, too huge to even look at in their entirety.  To
glean the above numbers I used "perf report" in its call-graph mode,
focusing on locking primitives and percentages above around 0.5%.  I
kept a copy of the profiles I looked at and they are available upon
request (just ask).  I will also post them publicly as soon as I have a
place to put them.
-- 
Frank Mayhar <fmayhar@google.com>
Google Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
