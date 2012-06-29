Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EB98D6B006C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:25:09 -0400 (EDT)
Date: Fri, 29 Jun 2012 12:25:06 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] IO metadata on XFS
Message-ID: <20120629112505.GF14154@suse.de>
References: <20120620113252.GE4011@suse.de>
 <20120629111932.GA14154@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120629111932.GA14154@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com

Configuration:	global-dhp__io-metadata-xfs
Benchmarks:	dbench3, fsmark-single, fsmark-threaded

Summary
=======
Most of the figures look good and in general there has been consistent good
performance from XFS. However, fsmark-single is showing a severe performance
dip in a few cases somewhere between 3.1 and 3.4. fs-mark running a single
thread took a particularly bad dive in 3.4 for two machines that is worth
examining closer. Unfortunately it is harder to easy conclusions as the
gains/losses are not consistent between machines which may be related to
the available number of CPU threads.

Benchmark notes
===============

mkfs was run on system startup.
mkfs parameters -f -d agcount=8
mount options inode64,delaylog,logbsize=262144,nobarrier for the most part.
	On kernels to old to support delaylog was removed. On kernels
	where it was the default, it was specified and the warning ignored.

dbench3 was chosen as it's metadata intensive.
  o Duration was 180 seconds
  o OSYNC, OSYNC_DIRECTORY and FSYNC were all off

  As noted in the MMTests, dbench3 can be a random number generator
  particularly when run in asynchronous mode. Even with the limitations,
  it can be useful as an early warning system and as it's still used by
  QA teams it's still worth keeping an eye on.

FSMark
  o Parallel directories were used
  o 1 Thread per CPU
  o 0 Filesize
  o 225 directories
  o 22500 files per directory
  o 50000 files per iteration
  o 15 iterations
  Single: ./fs_mark  -d  /tmp/fsmark-9227/1  -D  225  -N  22500  -n  50000  -L  15  -S0  -s  0
  Thread: ./fs_mark  -d  /tmp/fsmark-9407/1  -d  /tmp/fsmark-9407/2  -D  225  -N  22500  -n  25000  -L  15  -S0  -s  0
 
  FSMark is a more realistic indicator of metadata intensive workloads.


===========================================================
Machine:	arnold
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-xfs/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Great
===========================================================

dbench
------
  XFS is showing steady improvements with a large gain for single client
  in 2.6.39 and more or less retained since then. This is also true for
  higher number of clients although 64 clients was suspiciously poor even
  though 128 clients looked better. I didn't re-examine the raw data to
  see why.

  In general, dbench is looking very good.

fsmark-single
-------------
  Again, this is looking good. Files/sec has improved slightly with the
  exception of a small dip in 3.2 and 3.3 which may be due to IO-Less
  dirty throttling.

  Overhead measurements are a bit all over the place. Not clear if
  this is cause for concern or not.

fsmark-threaded
---------------
  Improved since 2.6.32 and has been steadily good for some time. Overhead
  measurements are all over the place. Again, not clear if this is a cause
  for concern.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok
==========================================================

dbench
------
  The results here look very different to the arnold machine. This is curious
  because the disks have similar size and performance characteristics. It is
  doubtful that the difference is between 32 bit and 64 bit architectures.
  The discrepency may be more due to the different number of CPUs and how
  XFS does locking. One possibility is that fewer CPUs has the side-effect
  of better batching of some operations but this is a case.

  Figures areis showing that throughput is worse and highly variable in
  3.4 for single clients. For higher number of clients figures look better
  overall. There was a dip in 3.1-based kernels though for an unknown
  reason. This does not exactly correlate with the ext3 figures although
  it showed a dip in performance at 3.2.

fsmark-single
-------------
  While performance is better than 2.6.32, there was a dip in performance
  in 3.3 and a very large dip in 3.4. 

fsmark-threaded
---------------
  The same dip in 3.4 is visibile when multiple threads are used but it is
  not as severe.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Fine
==========================================================

dbench
------
 Like seen on other filesystems, this data shows that there was a large dip
 in performance around 3.2 for single threads. Unlike the hydra machine,
 this was recovered in 3.4. As higher number of threads are used the gains
 and losses are inconsistent making it hard to draw a solid conclusion.

fsmark-single
-------------
  This was doing great until 3.4 where there is a large drop.

fsmark-threaded
---------------
  Unlike the single threaded case, things are looking great here.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
