Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 7D5D76B0062
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 17:19:07 -0400 (EDT)
Date: Mon, 23 Jul 2012 22:19:01 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] memcachetest and parallel IO on xfs
Message-ID: <20120723211901.GE9222@suse.de>
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

Configuration:	global-dhp__parallelio-memcachetest-xfs
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-xfs
Benchmarks:	parallelio

Summary
=======

Indications are that there was a large regression in page reclaim decisions
between 2.6.39 and 3.0 as swapping increased a lot.

Benchmark notes
===============

This is an experimental benchmark designed to measure the impact of
background IO on a target workload.

mkfs was run on system startup.
mkfs parameters -f -d agcount=8
mount options inode64,delaylog,logbsize=262144,nobarrier for the most part.
        On kernels to old to support delaylog was removed. On kernels
        where it was the default, it was specified and the warning ignored.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-xfs/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
===========================================================

parallelio-memcachetest
-----------------------

  Even for small amounts of background IO the memcached process is being
  pushed into swap for 3.3 and 3.4 although earlier kernels fared better.
  There are indications that there was a serious regression between 2.6.39
  and 3.0 as throughput dropped for larger amounts of IO and swapping was
  high.

  The "page reclaim immediate" figures started increasing from 3.2 implying
  that a lot of dirty LRU pages are reaching the end of the LRU lists.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-xfs/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
==========================================================

parallelio-memcachetest
-----------------------

  Performance again dropped sharply betwen 2.6.39 and 3.0 with huge jumps
  in the amount of swap IO.

  As with arnold, dirty pages are reaching the end of the LRU list.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__parallelio-memcachetest-xfs/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
==========================================================

  No results available.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
