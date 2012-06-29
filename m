Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id D819F6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:21:49 -0400 (EDT)
Date: Fri, 29 Jun 2012 12:21:46 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Page allocator
Message-ID: <20120629112145.GB14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Configuration:	global-dhp__pagealloc-performance
Benchmarks:	kernbench vmr-aim9 vmr-stream pagealloc pft hackbench-pipes hackbench-sockets

Summary
=======
kernbench and aim9 is looking bad in a lot of areas. The page allocator
itself was in very bad shape for a long time but this has improved in 3.4.
If there are reports of page allocator intensive workloads suffering badly
in recent kernels then it may be worth backporting the barrier fix.

Benchmark notes
===============

kernbench is a similar average of five compiles of vmlinux.

vmr-aim9 is a number of micro-benchmarks. The results of this are very
sensitive to a number of factors but it can be useful early warning system.

vmr-stream is the STREAM memory benchmark and variations in it can be
indicative of problems with cache usage.

pagealloc is a page allocator microbenchmark run via SystemTap. The page
allocator is rarely a major component of a workloads time but it can
be a source of slow degrataion of overall performance.

pft is a microbenchmark for page fault rates.

hackbench is usually used for scheduler comparisons but it can sometimes
highlight problems in the page allocator as well.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagealloc-performance/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Good, except for aim9
===========================================================

kernbench
---------
  2.6.32 looks quite bad which was surprising.  That aside, there was a
  major degrading of performance between 2.6.34 and 2.6.39 that is only
  being resolved now. System CPU time was steadily getting worse for quite
  some time.

pagealloc
---------
  Page allocator performance was completely screwed for a long time with
  massive additional latencies in the alloc path. This was fixed in 3.4
  by removing barriers introduced for cpusets.

hackbench-pipes
---------------
  Generally looks ok.

hackbench-sockets
-----------------
  Some very poor results although it seems to have recovered recently. 2.6.39
  through to 3.2 were all awful.

vmr-aim9
--------
  page_test, brk_test, exec_test and fork_test all took a major pounding
  between 2.6.34 and 2.6.39. It has been improving since but still is
  far short of 2.6.32 levels in some cases.

vmr-stream
----------
  Generally looks ok.

pft
---
  Indications are we scaled better over time with a greater number of faults
  being handled when spread across CPUs.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Bad, both kernbench and aim9 need care
==========================================================

kernbench
---------
  2.6.32 looked quite bad and great in 2.6.34. Between 2.6.34 and 2.6.39
  it regressed again and got worse after that. System CPU time looks
  generally good but 3.2 and later kernels are in bad shape in terms of
  overall elapsed time.

pagealloc
---------
  As with arnold, page allocator performance was completely screwed for a
  long time but mostly resolved in 3.4.

hackbench-pipes
---------------
  This has varied considerably over time. Currently looking good but there
  was a time when high number of clients regressed considerably. Judging
  from when it got fixed this might be a scheduler problem rather than a
  page allocator one.

hackbench-sockets
-----------------
  This is marginal at the moment and has had some serious regressions in
  the past.

vmr-aim9
--------
  Like with arnold, a lot of tests took a complete hammering mostly between
  2.6.34 and 2.6.39 with the exception of exec_test which got screwed at
  2.6.34 as well. Like arnold, it has improved in 3.4 but is still far 
  short of 2.6.32

vmr-stream
----------
  Generally looks ok.

pft
---
  Unlike arnold, the figures are worse here. It looks like we were not
  handling as many faults for some time although this is better now. It
  might be related to the page allocator being crap for a long time.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Bad, both kernbench and aim9 need care
==========================================================

kernbench
---------
  As before, 2.6.32 looked bad. 2.6.34 was good but we got worse after that.
  Elapsed time in 3.4 is screwed.

pagealloc
---------
  As with the other two, page allocator performance was bad for a long time
  but not quite as bad as the others. Maybe barriers are cheaper on the I7
  than they are on the other machines. Still, 3.4 is looking good.

hackbench-pipes
---------------
  Looks great. I suspect a lot of scheduler developers must have modern
  Intel CPUs for testing with

hackbench-sockets
-----------------
  Not so great. Performance dropped for a while but is looking marginally
  better now.

vmr-aim9
--------
  Variation of the same story. In general this is looking worse but was
  not as consistently bad as the other two machines. Performance in 3.4
  is a mixed bag.

vmr-stream
----------
  Generally looks ok.

pft
---
  Generally looking good, tests are completing faster. There were regressions
  in old kernels but it has been looking better recently.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
