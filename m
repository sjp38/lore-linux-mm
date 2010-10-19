Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 568926B00AC
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 18:00:07 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o9JM02ZQ009221
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 15:00:02 -0700
Received: from ewy7 (ewy7.prod.google.com [10.241.103.7])
	by kpbe12.cbf.corp.google.com with ESMTP id o9JLxtnr027429
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 15:00:00 -0700
Received: by ewy7 with SMTP id 7so1970479ewy.8
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 14:59:55 -0700 (PDT)
Subject: Results of my VFS scaling evaluation, redux.
From: Frank Mayhar <fmayhar@google.com>
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 14:59:50 -0700
Message-ID: <1287525590.5335.191.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org, mrubin@google.com
List-ID: <linux-mm.kvack.org>

After seeing the reaction to my original post of this work, I decided to
rerun the tests against Dave Chinner's tree just to see how things fare
with his changes.  This time I only ran the "socket test" due to time
constraints and since the "storage test" didn't produce anything
particularly interesting last time.

Further, I was unable to use the hardware I used previously so I reran
the test against both the 2.6.35 base and 2.6.35 plus Nick's changes in
addition to the 2.6.36 base and Dave's version of same.  The changed
hardware changed the absolute test results substantially.  Comparisons
between the runs remain valid, however.

>From my previous post (slightly rewritten):

> For each of the kernels I ran a a??socket testa?? on systems with a
> moderate number of cores and memory (unfortunately I cana??t say more
> about the hardware).  I gathered test results and kernel profiling
> data for each.
> 
> The "Socket Test" does a lot of socket operations; it fields lots of
> connections, receiving and transmitting small amounts of data over each.
> The application it emulates has run into bottlenecks on the dcache_lock
> and the inode_lock several times in the past, which is why I chose it as
> a target.
> 
> The test is multithreaded with at least one thread per core and is
> designed to put as much load on the application being tested as
> possible.  It is in fact designed specifically to find performance
> regressions (albeit at a higher level than the kernel), which makes it
> very suitable for this testing.

The kernels were very stable; I saw no crashes or hangs during my
testing.

The "Socket Test" has a target rate which I'll refer to as 100%.
Internal Google kernels (with modifications to specific code paths)
allow the test to generally achieve that rate, albeit not without
substantial effort.  Against the base 2.6.35 kernel I saw a rate of
around 13.9%; the modified 2.6.35 kernel had a rate of around 8.38%.
The base 2.6.36 kernel was effectively unchanged relative to the 2.6.35
kernel with a rate of 14.12% and, likewise, the modified 2.6.36 kernel
had a rate of around 9.1%.  In each case the difference is small and
expected given the environment.


> More interesting was the kernel profile (which I generated with the new
> perf_events framework).  This revealed a distinct improvement in locking
> performance.  While both kernels spent a substantial amount of time in
> locking, the modified kernel spent significantly less time there.
> 
> Both kernels spent the most time in lock_release (oddly enough; other
> kernels I've seen tend to spend more time acquiring locks than releasing
> them), however the base kernel spent 7.02% of its time there versus
> 2.47% for the modified kernel.  Further, while the unmodified kernel
> spent more than a quarter (26.15%) of its time in that routine actually
> in spin_unlock called from the dcache code (d_alloc, __d_lookup, et al),
> the modified kernel spent only 8.56% of its time in the equivalent
> calls.
> 
> Other lock calls showed similar improvements across the board.  I've
> enclosed a snippet of the relevant measurements (as reported by "perf
> report" in its call-graph mode) for each kernel.
> 
> While the overall performance drop is a little disappointing it's not
> at all unexpected, as the environment was definitely not the one that
> would be helped by the scaling improvements and there is a small but
> nonzero cost to those improvements.  Fortunately, the cost seems small
> enough that with some work it may be possible to effectively eliminate
> it.
> 
> 
> The Storage Test
> 
> This test doesn't have any single result; rather it has a number of
> measurements of such things as sequential and random reads and writes
> as well as a standard set of reads and writes recorded from an
> application.
> 
> As one might expect, this test did fairly well; overall things seemed to
> improve very slightly, by on the order of around one percent.  (There
> was one outlier, a nearly 20 percent regression, but while it should be
> eventually tracked down I don't think it's significant for the purposes
> of this evaluation.)  My vague suspicion, though, is that the margin of
> error (which I didn't compute) nearly eclipses that slight improvement.
> Since the scaling improvements aren't expected to improve performance in
> this kind of environment, this is actually still a win.
> 
> The locking-related profile graph for this test is _much_ more complex
> for the Storage Test than for the Socket Test.  While it appears that
> the dcache locking calls have been pushed down a bit in the profile it's
> a bit hard to tell because other calls appear to dominate.  In the end,
> it looks like there's very little difference made by the scaling
> patches.
> 
> 
> Conclusion.
> 
> In general Nick's work does appear to make things better for locking.
> It virtually eliminates contention on two very important locks that we
> have seen as bottlenecks, pushing locking from the root far enough down
> into the leaves of the data structures that they are no longer of
> significant concern as far as scaling to larger numbers of cores.  I
> suspect that with some further work, the performance cost of the
> improvements, already fairly small, can be essentially eliminated, at
> least for the common cases.
> 
> In the long run this will be a net win.  Systems with large numbers of
> cores are coming and these changes address the scalability challengs of
> the Linux kernel to those systems.  There is still some work to be done,
> however; in addition to the above issues, Nick has expressed concern
> that incremental adoption of his changes will mean performance
> regressions early on, since earlier changes lay the groundwork for later
> improvements but in the meantime add overhead.  Those early regressions
> will be compensated for in the long term by the later improvements but
> may be problematic in the short term.
> 
> Finally, I have kernel profiles for all of the above tests, all of which
> are excessively huge, too huge to even look at in their entirety.  To
> glean the above numbers I used "perf report" in its call-graph mode,
> focusing on locking primitives and percentages above around 0.5%.  I
> kept a copy of the profiles I looked at and they are available upon
> request (just ask).  I will also post them publicly as soon as I have a
> place to put them.


-- 
Frank Mayhar <fmayhar@google.com>
Google Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
