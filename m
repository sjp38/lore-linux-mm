Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9DF056B0075
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:53:45 -0400 (EDT)
Date: Wed, 4 Jul 2012 16:53:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Page reclaim performance on xfs
Message-ID: <20120704155341.GL14154@suse.de>
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

Configuration:	global-dhp__pagereclaim-performance-xfs
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-xfs
Benchmarks:	postmark largedd fsmark-single fsmark-threaded micro

Summary
=======

For the most part this is looking good. There is excessive swapping
visible on 3.1 and 3.2 which is seen elsewhere.

There is a concern with postmark figures. It is showing that we started
entering direct reclaim in 3.1 on hydra and while the swapping problem
has been addressed, we are still using direct reclaim and in some cases
it is quite a high percentage. This did not happen on older kernels.

Benchmark notes
===============

Each of the benchmarks trigger page reclaim in a fairly simple manner. The
intention is not to be exhaustive but to test basic reclaim patterns that
the VM should never get wrong. Regressions may also be due to changes in
the IO scheduler or underlying filesystem.

The workloads are predominately file-based. Anonymous page reclaim stress
testing is covered by another test.

mkfs was run on system startup.
mkfs parameters -f -d agcount=8
mount options inode64,delaylog,logbsize=262144,nobarrier for the most part.
        On kernels to old to support delaylog was removed. On kernels
        where it was the default, it was specified and the warning ignored.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-xfs/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Generally good but postmark shows direct reclaim
===========================================================

fsmark-single
-------------
  Generally good, steady performance throughout. There was direct
  reclaim activity in early kernels but not any more.

fsmark-threaded
---------------
  Generally good as well.

postmark
--------
  This is interesting. There was a mild performance dip in 3.2 but
  while the excessive swapping is visible in 3.1 and 3.2 as seen
  on other tests, it did not translate into a performance drop.
  What is of concern is that direct reclaim figures are still high
  for recent kernels even if it is not swapping.

largedd
-------
  Completion times have suffered a little and the usual swapping
  in 3.1 and 3.2 is visible but it's tiny.

micro
-----
  Looking great.
   
==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-xfs/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Generally ok, but swapping in 3.1 and 3.2
==========================================================

fsmark-single
-------------
  Generally good, swap in 3.1 and 3.2

fsmark-threaded
---------------
  Generally good, no direct reclaim on recent kernels

postmark
-------
  Looking great other than swapping in 3.1 and 3.2 which again
  does not appear to translate into a performance drop. Direct
  reclaim started around kernel 3.1 and this has not eased off.
  It's a sizable percentage.

largedd
-------
  Completion times ok, swap on 3.1 and 3.2 is not.

micro
-----
  Ok.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-xfs/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Generally ok, but swapping in 3.1 and 3.2
==========================================================

fsmark-single
-------------
  Generally good. No swapping visible on 3.1 and 3.2 but this machine
  also has more memory.

fsmark-threaded
---------------
  Generally good although 3.2 showed that a lot of inodes were reclaimed.
  This matches a similar test on ext4 so something odd happened there.

postmark
--------
  Looking great for performance although some swapping in 3.1 and 3.2
  and direct reclaim scanning is still high.

largedd
-------
  Completion times look good 

micro
-----
  Look ok.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
