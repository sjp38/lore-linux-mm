Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 8069D6B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:24:27 -0400 (EDT)
Date: Fri, 29 Jun 2012 12:24:23 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] IO metadata on ext4
Message-ID: <20120629112423.GE14154@suse.de>
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

Configuration:	global-dhp__io-metadata-ext4
Benchmarks:	dbench3, fsmark-single, fsmark-threaded

Summary
=======
  For the most part the figures look ok currently. However a number of
  tests show that we have declined since 3.0 in a number of areas. Some
  machines show that there were performance drops in the 3.2 and 3.3
  kernels that have not being fully recovered.

Benchmark notes
===============

mkfs was run on system startup. No attempt was made to age it. No
special mkfs or mount options were used.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext4/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Fine but fsmark has declined since 3.0
===========================================================

dbench
------
  For single clients, we're doing reasonably well and this has been consistent
  with each release.

fsmark-single
-------------
  This is not as happy a story. Variations are quite high but 3.0 was a
  reasonably good kernel and we've been declining ever since with 3.4
  being marginally worse than 2.6.32.

fsmark-threaded
---------------
  The trends are very similar to fsmark-single. 3.0 was reasonably good
  but we have degraded since and are at approximately 2.6.32 levels.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext4/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Fine but fsmark has declined since 3.0
==========================================================

dbench
------
  Unlike arnold, this is looking good with solid gains in most kernels
  for the single-threaded case. The exception was 3.2.9 which saw a
  a big dip that was recovered in 3.3. For higher number of clients the
  figures still look good. It's not clear why there is such a difference
  between arnold and hydra for the single-threaded case.

fsmark-single
-------------
  This is very similar to arnold in that 3.0 performed best and we have
  declined since back to more or less the same level as 2.6.32.

fsmark-threaded
---------------
  Performance here is flat in terms of throughput. 3.4 recorded much higher
  overhead but it is not clear if this is a cause for concern.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext4/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		Fine but there have been recent declines
==========================================================

dbench
------
  Like hydra, this is looking good with solid gains in most kernels for the
  single-threaded case. The same dip in 3.2.9 is visible but unlikely hydra
  it was not recovered until 3.4. Higher number of clients generally look
  good as well although it is interesting to see that the dip in 3.2.9 is
  not consistently visible.

fsmark-single
-------------
  Overhead went crazy in 3.3 and there is a large drop in files/sec in
  3.3 as well. 

fsmark-threaded
---------------
  The trends are similar to the single-threaded case. Looking reasonably
  good but a dip in 3.3 that has not being recovered and overhead is
  higher.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
