Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 54C766B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:56:56 -0400 (EDT)
Date: Thu, 5 Jul 2012 15:56:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Interactivity during IO on ext3
Message-ID: <20120705145652.GN14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

Configuration:	global-dhp__io-interactive-performance-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3
Benchmarks:	postmark largedd fsmark-single fsmark-threaded micro

Summary
=======

There are some terrible results in here that might explain some of the
interactivity mess if the distribution defaulted to ext3 or was was chosen
by the user for any reason. In some cases average read latency has doubled,
tripled and in one case almost quadrupled since 2.6.32. Worse, we are not
consistently good or bad. I see patterns like great release, bad release,
good release, bad again etc.

Benchmark notes
===============

NOTE: This configuration is new and very experimental. This is my first
      time looking at the results of this type of test so flaws are
      inevitable. There is ample scope for improvement but I had to
      start somewhere.

This configuration is very different in that it is trying to analyse the
impact of IO on interactive performance.  Some interactivity problems are
due to an application trying to read() cache-cold data such as configuration
files or cached images. If there is a lot of IO going on, the application
may stall while this happens.  This is a limited scenario for measuring
interactivity but a common one.

These tests are fairly standard except that there is a background
application running in parallel. It begins by creating a 100M file and
using fadvise(POSIX_FADV_DONTNEED) to evict it from cache. Once that is
complete it will try to read 1M from the file every few seconds and record
the latency. When it reaches the end of the file, it dumps it from cache
and starts again.

This latency is a *proxy* measure of interactivity, not a true measure. A
variation would be to measure the time for small writes for applications
that are logging data or applications like gnome-terminal that do small
writes to /tmp as part of its buffer management. The main strength is
that if we get this basic case wrong, then the complex cases are almost
certainly screwed as well.

There are two areas to pay attention to. One is completion time and how
it is affected by the small reads taking place in parallel. A comprehensive
analysis would show exactly how much the workload is affected by a parallel
read but right now I'm just looking at wall time.

The second area to pay attention to is the read latencies paying particular
attention to the average latency and the max latencies. The variations are
harder to draw decent conclusions from. A sensible option would be to plot
a CDF to get a better idea what the probability of a given read latency is
but for now that's a TODO item. As it is, the graphs are barely usable and
I'll be giving that more thought.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

fsmark-single
-------------
  Completion times since 3.2 have been badly affected which coincides with
  the introduction of IO-less dirty page throttling. 3.3 was particularly
  bad.

  2.6.32 was TERRIBLE in terms of read-latencies with the average latency
  and max latencies looking awful. The 90th percentile was close to 4
  seconds and as a result the graphs are even more of a complete mess than
  they might have been otherwise.

  Otherwise it's worth looking closely at 3.0 and 3.2. In 3.0, 95% of the
  reads were below 206ms but in 3.2 this had grown to 273ms. The latency
  of the other 5% results increased from 481ms to 774ms.

  3.4 is looking better at least.

fsmark-threaded
---------------
  With multiple writers, completion times have been affected and again 3.2
  showed a big increase.

  Again, 2.6.32 is a complete disaster and mucks up all the graphs.

  Otherwise, our average read latencies do not look too bad. However, our
  worst-case latencies look pretty bad. Kernel 3.2 is showing that at worst
  a read() can take 4.3 seconds when there are multiple parallel writers.
  This must be fairly rare as 99% of the latencies were below 1 second but
  a 4 second stall in an application sometimes would feel pretty bad.

  Maximum latencies have improved a bit in 3.4 but are still around a half
  second higher than 3.0 and 3.1 kernels.
  
postmark
--------
  This is interesting in that 3.2 kernels results show an improvement in
  maximum read latencies and 3.4 is looking worse. The completion times
  for postmark were very badly affected in 3.4. Almost the opposite of what
  the fsmark workloads showed. It's hard to draw any sensible conclusions
  from this that match up with fsmark.

largedd
-------
  Completion times are more or less unaffected.

  Maximum read latencies are affected though. In 2.6.39, our maximum latency
  was 781ms and was 13163ms in 3.0 and 1122ms in 3.2 which might explain 
  some of the interactivity complains around those kernels when a large
  cp was going on. Right now, things are looking very good.

micro
-----
  Completion times look ok.

  2.6.32 is again hilariously bad.

  3.1 also showed very poor maximum latencies but 3.2 and later kernels
  look good.


==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
==========================================================

fsmark-single
-------------
  Completion times are all over the place with a big increase in 3.2 that
  improved a bit since but not as good as 3.1 kernels were.

  Unlike arnold, 2.6.32 is not a complete mess and makes a comparison more
  meaningful. Our maximum latencies have jumped around a lot with 3.2
  being particularly bad and 3.4 not being much better. 3.1 and 3.3 were
  both good in terms of maximum latency.

  Average latency is shot to hell. In 2.6.32 it was 349ms and it's now 781ms.
  3.2 was really bad but it's not like 3.0 or 3.1 were fantastic either.

fsmark-threaded
---------------
  Completion times are more or less ok.

   Maximum read latency is worse with increases of around 500ms in worst
   latency and even the 90th percentile is not looking great.

   Average latency is completely shot.

postmark
--------
  Again impossible to draw sensible conclusions from this. The throughput
  graph makes a nice sawtooth pattern suitable for poking you in the eye
  until it bleeds.

  It's all over the place in terms of completion times. Average latency
  figures are relatively ok but still regressed. Maximum latencies have
  increased.

largedd
-------
  Completion times are more or less steady although 3.2 showed a large
  jump in the length time it took to copy the files. 3.2 took almost
  10 minutes more to copy the files than 3.1 or 3.3.

  Maximum latencies in 3.2 were very high and the 90th percentile also
  looked pretty bad. 3.4 is better but still way worse than 2.6.32.

  Average latency would be laughable if it was not so tragic.

micro
-----
  This was looking better until 3.4 when max latencies jumped but by
  and large this looks good.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
==========================================================

fsmark-single
-------------
  Completion times are more or less ok. They've been worse since 3.2 
  but still better than 3.2 by a big margin.

  Read latencies are another story. Maximum latency has increased a
  LOT from 1.3 seconds to 3.1 seconds in kernel 3.4. Kernel 3.0 had
  a maximum latency of 6.5 seconds!

  The 90th percentile figures are not much better with latencies of
  more than 1 second being recorded from all the way back to 2.6.39.

  Average latencies have more than tripled from 230ms to 812ms.

fsmark-threaded
---------------
  Completion times are generally good.

  Read latencies are completely screwed. Kernel 3.2 had a maximum latency
  of 15 seconds! 3.4 has improved but it's still way too high. Even
  the 90th percentile figures look completely crap and average latency
  is of course bad with such high latencies being recorded.

postmark
--------
  Once again the throughput figures make a nice stab stab shape for the eyes.

  The latency figures are sufficiently crap that it depresses me to talk
  about them.

largedd
-------
  Completion times look decent.

  Which does not get over the shock of the latency figures were again are
  shocking.  6 second maximum latencies in 3.3 and 3.4 kernels although
  3.2 was actually quite good. Even 90th percentile maximum latencies have
  almost doubled since 3.2 and of course the average latencies have almost
  tripled in line with other results.

micro
-----
  Completion times look decent. 

  The read latencies are ok. The average latency is higher because the
  latencies to the 90th percentile are higher but the maximum latencies
  have improved so overall I guess this is a win.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
