Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id EC5FB6B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:23:31 -0400 (EDT)
Date: Fri, 29 Jun 2012 12:23:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [MMTests] IO metadata on ext3
Message-ID: <20120629112328.GD14154@suse.de>
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

Configuration:	global-dhp__io-metadata-ext3
Benchmarks:	dbench3, fsmark-single, fsmark-threaded

Summary
=======

  While the fsmark figures look ok, fsmark in single threaded mode has
  a small number of large outliers towards the min end of the scale. The
  resulting standard deviation fuzzes results but filtering is not necessarily
  the best answer. A similar effect is visible when running in threaded
  mode except that there is clustering around some values that could be
  presented better. Arithmetic mean is unsuitable for this sort of data.

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
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/arnold/comparison.html
Arch:		x86
CPUs:		1 socket, 2 threads
Model:		Pentium 4
Disk:		Single Rotary Disk
Status:		Fine
===========================================================

dbench
------
  For single clients, we're doing reasonably well. There was a big spike
  for large number of clients in 2.6.34 and to a lesser extent in 2.6.39.4
  but much of this is due to the operations taking place in memory without
  reaching disk. There were also fairness issues and the indicated throughput
  figures are far higher than the disks capabilities so I do not consider
  this to be a regression.

  There was a mild dip for 3.2.x and 3.3.x that has been recovered somewhat
  in 3.4. As this was when IO-Less Dirty Throttling got merged it is hardly
  a surprise and a dip in dbench is not worth backing that out for.

  Recent kernels appear to deal worse for large number of clients. However,
  I very strongly suspect this is due to improved fairness in IO. The
  high throughput figures are due to one client making an unfair amount
  of progress while other clients stall.

fsmark-single
-------------
  Again, this is looking good. Files/sec has improved slightly with the
  exception of a dip in 3.2 and 3.3 which again may be due to IO-Less
  dirty throttling.

  I have a slight concern with the overhead measurements. Somewhere
  between 3.0.23 and 3.1.10 the overhead started deviating a lot more.
  Ideally this should be bisected because it difficult to blame
  IO-Less throttling with any certainity.
  IO-Less Throttling.

fsmark-threaded
---------------
  Looks better but due to high deviations it's hard to be 100% sure.
  If this is of interest then the thing to do is do a proper measurement
  of whether the results are significant or not although with 15 samples
  it still will be fuzzy.

  Right now, there is little to be concerned about.

==========================================================
Machine:	hydra
Result:		http://www.csn.ul.ie/~mel/postings/mmtests-20120424/global-dhp__io-metadata-ext3/hydra/comparison.html
Arch:		x86-64
CPUs:		1 socket, 4 threads
Model:		AMD Phenom II X4 940
Disk:		Single Rotary Disk
Status:		Fine
==========================================================

dbench
------
 Very similar story to the arnold machine. Big spike in 2.6.34 and then
 drops off.

fsmark-single
-------------
  Nothing really notable here. Deviations are too high to draw reasonable
  conclusions from. Looking at the raw results it's due to a small number
  of low outliers. These could be filtered but it would mask the fact that
  throughput is not consistent so strong justification would be required.

fsmark-threaded
---------------
  Similar to fsmark-single. Figures look ok but large deviations are
  a problem Unlike the single-threaded case the raw data shows that we
  cluster around two points that are very far apart from each other. It
  is worth investigating if this can be presented in some sensible
  manner such as k-means clustering because arithmetic mean with this
  sort of data is crap.

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
  Same as the other two complete with spikes.

fsmark-single
-------------
  Other than overhead going crazy in 3.2 there is nothing notable either.
  As with hydra, there are a small number of outliers that result in large
  deviations

fsmark-threaded
---------------
  Similar to hydra. Figures look basically ok but deviations are high with
  some clustering going on.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
