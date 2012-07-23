Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 1689A6B005D
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:18:02 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:17:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] memcachetest and parallel IO on ext3
Message-ID: <20120723211756.GD9222@suse.de>
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

Configuration:	global-dhp__parallelio-memcachetest-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-ext3
Benchmarks:	parallelio

Summary
=======

  Indications are not very clear as different machines point to different
  kernels. Very broadly speaking, swapping got worse between 2.6.39 and 3.0
  and then again between 3.2 and 3.3.

Benchmark notes
===============

This is an experimental benchmark designed to measure the impact of
background IO on a target workload.

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

The target workload in this case is memcached and memcachetest. This is a
benchmark of memcached and the workload is mostly anonymous.  The benchmark
was chosen as it was a random client that is considered a valid benchmark
for memcache and does not consume much memory in the client.  The server
was configured to use 80% of memory.

In the background, dd is used to generate IO of varying sizes. As the sizes
increase, memory pressure may push the target workload out of memory. The
benchmark is meant to measure how much the target workload is affected
and may be used as a proxy measure for page reclaim decisions.

Unlike other benchmarks, only the run with the worst throughput is displayed.
This benchmark varies quite a bit depending on the reference pattern from
the client. This hides the interesting result in the noise so we only
consider the worst case.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

parallelio-memcachetest
-----------------------
  Even for small amounts of background IO the memcached process is being
  pushed into swap. This is due to a regression somewhere between 2.6.34
  and 2.6.39 and a much larger regression between 2.6.39 and 3.0.  This is
  even worse in 3.3 and 3.4.

  The "page reclaim immediate" figures started increasing from 3.2 implying
  that a lot of dirty LRU pages are reaching the end of the LRU lists.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
==========================================================

parallelio-memcachetest
-----------------------
  Performance was reasonable until relatively recent kernels. The results
  show that for 3.3 and later kernels that swapping started for moderate
  amounts of IO (1624M) and performance dropped off sharply as a result.

  As with arnold, dirty pages are reaching the end of the LRU list.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
==========================================================

parallelio-memcachetest
-----------------------
  This is showing everything smells of roses and the IO is not interfering
  at all. It is possible that this is due to the amount of memory and that
  the IO is being completed fast enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
