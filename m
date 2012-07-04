Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 461A16B0074
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 11:52:23 -0400 (EDT)
Date: Wed, 4 Jul 2012 16:52:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] Page reclaim performance on ext3
Message-ID: <20120704155217.GJ14154@suse.de>
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

Configuration:	global-dhp__pagereclaim-performance-ext3
Result: 	http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext3
Benchmarks:	postmark largedd fsmark-single fsmark-threaded micro

Summary
=======

largedd is showing that in 3.0 that reclaim started writing pages. This
has been "fixed" by deferring the writeback to flusher threads and
immediately reclaiming. This is mostly fixed now but it would be worth
refreshing the memory as to why this happened in the first place.

Slab shrinking is another area to pay attention to. Scanning in recent
kernels is consistent with earlier kernels but there are cases where
the number of inode being reclaimed has changed significantly. Inode
stealing in one case is why higher since 3.1.

postmark detected that there was excessive swapping for some kernels
between 3.0 and 3.3 but that it's not always reproducible and depends
on both the workload and the amount of available memory. It does indicate
that 3.1 and 3.2 might have been very bad kernels for interactivity
performance under memory pressure.

largedd in is showing in some cases that there was excessive swap activity
in 3.1 and 3.2 kernels. This has been fixed but the fixes were not
backported.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Generally good but pay attention to largedd
===========================================================

fsmark-single
-------------
  Generally this is looking good. There was a small performance dip in
  3.3 that has been recovered. All the reclaim was done from kswapd in
  all cases and efficiency was high.

fsmark-threaded
---------------
  Generally looking good although the higher variance in 3.4 is a surprise.
  It is interesting to note that in 2.6.32 and 2.6.34 that direct reclaim
  was used and that this is no longer the case. kswapd efficiency is high
  throughout as the scanning velocity is steady. A point of interest is
  that slabs were not scanned in 3.4. This could be good or bad.

postmark
--------
  postmark performance took a dip in 3.2 and 3.3 and this roughly correlates
  with some other IO tests. It is very interesting to note that there was
  swap activity in 3.1 and 3.2 that has been since resolved but is something
  that -stable users might care about. Otherwise kswapd efficiency and
  scanning rates look good.

largedd
-------
  Figures generally look good here. All the reclaim is done by kswapd
  as expected. It is very interesting to note that in 3.0 and 3.1 that
  reclaim started writing out pages and that it is now being deferred
  to flusher threads and then immediately reclaimed.

micro
-----
  Completion times generally look good and are improving. Some direct
  reclaim is happening but at a steady percentage on each release.
  Efficiency is much lower than other workloads but at least it is
  consistent.

  Slab shrinking may need examination. It clearly shows that scanning
  is taking place but fewer inodes are being reclaimed in recent
  kernels. This is not necessarily bad but worth paying attention to.

  One point of concern is that kswapd CPU usage is high in recent
  kernels for this test. The graph is a complete mess and needs
  closer examination.
   
==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Ok but postmark shows high inode steals
==========================================================

fsmark-single
-------------
  This is all over the place. 3.0 was bad, 3.1 was good but performance
  has declined since then. The reclaim statistics look ok although slabs
  are being scanned without being reclaimed which is curious. kswapd is
  scanning less but that is not necessarily the cause of the problem.

fsmark-threaded
---------------
  In contrast to the single-threaded case, this is looking steady although
  overall kernels are slower than 2.6.32 was.  Direct reclaim velocity is
  slightly higher but still a small percentage of overall scanning. It's
  cause for some concern but not an immediate panic as reclaim efficiency
  is high.

postmark
-------
  postmark performance took a serious dip in 3.2 and 3.3 and while it
  has recovered in 3.4 a bit, it's still far below the peak seen in 3.1.
  For the most part, reclaim statistics look ok with the exception of
  slab shrinking. Inode stealing is way up 3.1 and later kernels.

largedd
-------
  Recent figures look good but in 3.1 and 3.2 there was excessive swapping.
  This was matched by pages reclaimed by direct reclaim in the same kernels
  and this likely shot interactive performance to hell with doing large
  copies on those kernels. This roughly matches other bug reports so it's
  interesting but clearly the patches did not get backported to -stable.

micro
-----
   Completion times looking generally good. 3.1 and 3.2 show better times
   but as it is matched by excessive amounts of reclaim it is not likely
   to be a good trade-off so lets not "fix" that.

==========================================================
Machine:	sandy
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__pagereclaim-performance-ext3/sandy/comparison.html
Arch:		x86-64
CPUs:		1 socket, 8 threads
Model:		Intel Core i7-2600
Disk:		Single Rotary Disk
Status:		
==========================================================

fsmark-single
-------------
  There was a performance dip in 3.4 but otherwise looks ok. Reclaim stats
  look fine.

fsmark-threaded
---------------
  Other than something crazy happening to variance in 3.1, figures look ok.
  There is some direct reclaim going on but the efficiency is high. There
  are 8 threads on this machine and only one disk so some stalling due
  to direct reclaim would be expected if IO was not keeping up.

postmark
--------
  postmark performance took a serious dip in 3.1 and 3.2 which is a kernel
  version earlier than the same dip seen in hydra. No explanation for this
  but it is matched by swap activity in the same kernels so it might be
  an indication there was general swapping-related damage in the 3.0-3.3
  time-frame.

largedd
-------
  Recent figures look good. Again, some swap activity is visible in 3.1 and
  3.2 that has been since fixed but obviously not backported.

micro
-----
  Okish I suppose. Completion times have improved but are all over the place
  and as seen elsewhere good completion times on micro can be sometimes
  due to excessive reclaim and is not necessarily a good thing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
