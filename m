Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 0A5076B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 10:57:54 -0400 (EDT)
Date: Thu, 5 Jul 2012 15:57:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Interactivity during IO on ext4
Message-ID: <20120705145750.GO14154@suse.de>
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

Configuration:	global-dhp__io-interactive-performance-ext4
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext4
Benchmarks:	postmark largedd fsmark-single fsmark-threaded micro

Summary
=======

Unlike ext3, these figures look generally good. There are a few wrinkles in
there but indications are that interactivity jitter experienced by users
may have a filesystem-specific component.  One possibility is that there
are differences in how metadata reads are sent to the IO scheduler but I
did not confirm this.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext4/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		
===========================================================

fsmark-single
-------------
  Completion times are more or less ok. 3.2 showed a big improvement
  which is not in line with what was experienced in ext3.

  As with ext3, kernel 2.6.32 was a disaster but otherwise our maximum
  read latencies were looking up until 3.3 when there was a big jump that
  was not fixed in 3.4. By and large though the average latencies are 
  looking good and while the max latency is bad, the 99th percentile
  was looking good implying that the worst latencies are rarely
  experienced.

fsmark-threaded
---------------
  Completion times look generally good with 3.1 being an exception.

  Latencies are also looking good.
  
postmark
--------
  Similar story. Completion times and latencies generally look good.

largedd
-------
  Completion times were higher from 2.6.39 up until 3.3 taking nearly
  two minutes to complete the copy in some cases.

  This is reflected in some of the maximum latencies in that window
  but by and large the read latencies are much improved.

micro
-----
  Looking good all round.


==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext4/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

fsmark-single
-------------
  Completion times have degraded slightly but are acceptable.

  All the latency figures look good with some big improvements.

fsmark-threaded
---------------
  Same story, generally looking good with big improvements.

postmark
--------
  Completion times are a bit varied but latencies look good.

largedd
-------
  Completion times look good.

  Latency has improved since 2.6.32 but there is a big wrinkle
  in there. Maximum latency was 337ms in kernel 3.2 but in 3.3
  it was 707ms and in 3.4 was 990ms. The 99th percentile figures
  look good but something happened to allow bigger outliers.

micro
-----
  For the most part, looks good but there was a big jump in the
  maximum latency in kernel 3.4. Like largedd, the 99th percentil
  did not look as bad so it might be an outlier.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-interactive-performance-ext4/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		
==========================================================

fsmark-single
-------------
  Completion times have degraded slightly but are acceptble.

  All the latency figures look good with some big improvements.

fsmark-threaded
---------------
  Completion times are improved although curiously it is not reflected
  in the performance figures for fsmark itself.

  Maximum latency figures generally look good other than a mild jump
  in 3.2 that has almost being recovered.

postmark
--------
  Completion times have varied a lot and 3.4 is particularly high.

  The latency figures in general regressed in 3.4 in comparison to
  3.3 but by and large the figures look good.

largedd
-------

  Completion times generally look good but were noticably worse for
  a number of releases between 2.6.39 and 3.2. This same window showed
  much higher latency figures with kernel 3.1 showing a maximum latency
  of 1.3 seconds for example. These were mostly outliers though as
  the 99th percentile generally looked ok.

micro
-----
  Generally much improved.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
