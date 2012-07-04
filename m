Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 1BD166B0074
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:53:21 -0400 (EDT)
Date: Wed, 4 Jul 2012 16:53:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Page reclaim performance on ext4
Message-ID: <20120704155316.GK14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

Configuration:	global-dhp__pagereclaim-performance-ext4
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext4
Benchmarks:	postmark largedd fsmark-single fsmark-threaded micro

Summary
=======

fsmark is showing a performance dip in 3.4 on a 32-bit machine that is
not matched by results elsewhere.

A number of tests show that there was swapping activity in 3.1 and 3.2
which should have been completely unnecessary. It has been fixed but the
fixes should have been backported as some were based on reports of poor
interactivity performance during IO.

One largedd test on hydra showed that a number of dirty pages are reaching
the end of the LRU. This is not visible on other tests but should be
monitored.

I added linux-ext4 to the list because there are some performance drops
that are not visible elsewhere so may be filesystem-specific.

Benchmark notes
===============

Each of the benchmarks trigger page reclaim in a fairly simple manner. The
intention is not to be exhaustive but to test basic reclaim patterns that
the VM should never get wrong. Regressions may also be due to changes in
the IO scheduler or underlying filesystem.

The workloads are predominately file-based. Anonymous page reclaim stress
testing is covered by another test.

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

postmark
  o 15000 transactions
  o File size ranged 3096 bytes to 5M
  o 100 subdirectories
  o Total footprint approximately 4*TOTAL_RAM

  This workload is a single-threaded benchmark intended to measure
  filesystem performance for many short-lived and small files. It's
  primary weakness is that it does no application processing and
  so the page aging is basically on per-file granularity. 

largedd
  o Target size 8*TOTAL_RAM

  This downloads a large file and makes copies with dd until the
  target footprint size is reached.

fsmark
  o Parallel directories were used
  o 1 Thread per CPU
  o 30M Filesize
  o 16 directories
  o 256 files per directory
  o TOTAL_RAM_IN_BYTES/FILESIZE files per iteration
  o 15 iterations
  Single: ./fs_mark  -d  /tmp/fsmark-25458/1  -D  16  -N  256  -n  532  -L  15  -S0  -s  31457280
  Thread: ./fs_mark  -d  /tmp/fsmark-28217/1  -d  /tmp/fsmark-28217/2  -d  /tmp/fsmark-28217/3  -d
/tmp/fsmark-28217/4  -d  /tmp/fsmark-28217/5  -d  /tmp/fsmark-28217/6  -d  /tmp/fsmark-28217/7  -d
/tmp/fsmark-28217/8  -d  /tmp/fsmark-28217/9  -d  /tmp/fsmark-28217/10  -d  /tmp/fsmark-28217/11  -d
/tmp/fsmark-28217/12  -d  /tmp/fsmark-28217/13  -d  /tmp/fsmark-28217/14  -d  /tmp/fsmark-28217/15  -d
/tmp/fsmark-28217/16  -d  /tmp/fsmark-28217/17  -d  /tmp/fsmark-28217/18  -d  /tmp/fsmark-28217/19  -d
/tmp/fsmark-28217/20  -d  /tmp/fsmark-28217/21  -d  /tmp/fsmark-28217/22  -d  /tmp/fsmark-28217/23  -d
/tmp/fsmark-28217/24  -d  /tmp/fsmark-28217/25  -d  /tmp/fsmark-28217/26  -d  /tmp/fsmark-28217/27  -d
/tmp/fsmark-28217/28  -d  /tmp/fsmark-28217/29  -d  /tmp/fsmark-28217/30  -d  /tmp/fsmark-28217/31  -d
/tmp/fsmark-28217/32  -D  16  -N  256  -n  16  -L  15  -S0  -s  31457280

micro
  o Total mapping size 10*TOTAL_RAM
  o NR_CPU threads
  o 5 iterations

  This creates one process per CPU and creates a large file-backed mapping
  up to the total mapping size. Each of the threads does a streaming
  read of the mapping for a number of iterations. It then restarts with
  a streaming write.

  Completion time is the primary factor here but be careful as a good
  completion time can be due to excessive reclaim which has an adverse
  effect on many other workloads.

===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext4/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Generally good but swapping in 3.1 and 3.2
===========================================================

fsmark-single
-------------
  There was a performance dip in 3.4 that is not visible for ext3 and so
  may be filesystem-specific. From a reclaim perspective the figures look ok.

fsmark-threaded
---------------
  This also shows a large performance dip in 3.4 and an increase in variance
  but again the reclaim stats look ok.

postmark
--------
  As seen on ext3 there was a performance dip for kernels 3.1 to 3.3 that
  is not quite been recovered in 3.4. There was also swapping activity
  for the 3.1 and 3.2 kernels which may partially explain the problem.

largedd
-------
  Completion times are mixed. Again some swapping activity is visible in
  3.1 and 3.2 which has been resolved but not backported.

micro
-----
  Completion figures are not looking bad for 3.4
   
==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext4/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok but postmark shows high inode steals
==========================================================

fsmark-single
-------------
  Performance was declining until 3.1 and been steady every since.
  Some minor amounts of swapping is visible in 3.1

fsmark-threaded
---------------
 Surprisingly stead performance but recent kernels show some direct
 reclaim is going on. It's a tiny percentage and lower than it has
 been historically but keep an eye on it.

postmark
-------
  As with other tests 3.1 saw a performance dip and swapping activity. 3.2
  was also swapping although performance was not affected. While the reclaim
  figures currently look ok, the actual performance sucks. As the same is
  not visible on ext3, this may be a filesystem problem.

largedd
-------
  Completion figures look good but as before, swapping in 3.1 and 3.2.
  What is of concern is the pages reclaimed by PageReclaim are excessively
  high in 3.3 and 3.4. This implies that a large number of dirty pages
  are reaching the end of the LRU and this can be a problem. Minimally
  it increases kswapd CPU usage but can also be indicate a flushing
  problem.

micro
-----
  Looks ok.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext4/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Generally ok, but swapping in 3.1 and 3.2
==========================================================

fsmark-single
-------------
  Steady performance throughout. Tiny swap activity visible on 3.1 and 3.2
  which caused no harm but does correlate with other tests.

fsmark-threaded
---------------
  Also steady with the exception of 3.2 which is bizzare from a reclaim
  perspective. There was no direct reclaim scanning but a lot of inodes
  were reclaimed.

postmark
--------
  Same performance dip in 3.1 and 3.2 and accompanied by the same swapping
  problem.

largedd
-------
  Completion figures generally looking ok although again 3.1 is bad from
  a swapping and direct reclaim perspective.

micro
-----
  Looks ok

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
