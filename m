Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 6F7C26B0081
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 07:32:56 -0400 (EDT)
Date: Wed, 20 Jun 2012 12:32:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: MMTests 0.04
Message-ID: <20120620113252.GE4011@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

MMTests 0.04 is a configurable test suite that runs a number of common
workloads of interest to MM developers. Apparently I never sent a release
note for 0.03 so here is the changelog for both

v0.04
o Add benchmarks for tbench, pipetest, lmbench, starve, memcachedtest
o Add basic benchmark to run trinity fuzz testing tool
o Add monitor that runs parallel IO in the background. Measures how much
  IO interferes with a target workload.
o Allow limited run of sysbench to save time
o Add helpers for running oprofile, taken from libhugetlbfs
o Add fsmark configurations suitable for page reclaim and metadata tests
o Add a mailserver simulator (needs work, takes too long to run)
o Tune page fault test configuration for page allocator comparisons 
o Allow greater skew when running STREAM on NUMA machines
o Add a monitor that roughly measures interactive app startup times
o Add a monitor that tracks read() latency (useful for interactivity tests)
o Add script for calculating quartiles (incomplete, not tested properly)
o Add config examples for measuring interactivity during IO (not validated)
o Add background allocator for hugepage allocations (not validated)
o Patch SystemTap installation to work with 3.4 and later kernels
o Allow use of out-of-box THP configuration

v0.03
o Add a page allocator micro-benchmark
o Add monitor for tracking processes stuck in D state
o Add a page fault micro-benchmark
o Add a memory compaction micro-benchmark
o Patch a tiobench divide-by-0 error
o Adapt systemtap for >= 3.3 kernel
o Reporting scripts for kernbench
o Reporting scripts for ddresidency

At LSF/MM at some point a request was made that a series of tests
be identified that were of interest to MM developers and that could be
used for testing the Linux memory management subsystem. There is renewed
interest in some sort of general testing framework during discussions for
Kernel Summit 2012 so here is what I use.

http://www.csn.ul.ie/~mel/projects/mmtests/
http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.04-mmtests-0.01.tar.gz

In this release there are a number of stock configuration options added.
For example config-global-dhp__pagealloc-performance runs a number of tests
that may be able to identify performance regressions or gains in the page
allocator. Similarly there network and scheduler configs. There are also
more complex options. config-global-dhp__parallelio-memcachetest will run
memcachetest in the foreground while doing IO of different sizes in the
background to measure how much unrelated IO affects the throughput of an
in-memory database.

This release is a little half-baked but decided to release anyway due to
current discussions. By my own admission there are areas that need cleaning
up and there is some serious cut&paste-itis going on in parts.  I wanted
to get that all fixed up before releasing but that could take too long.
The biggest warts by far are in how reports are generated due to being
able to crank a new one out in 3 minutes where as doing it properly would
require redesign.  What should have happened is that the stats generation and
reporting be completely separated but that can be still fixed because the raw
data is captured.  The stats reporting in general needs better work because
while some tests know how to make a better estimate of mean by filtering
outliers it is not being handled consistently and the methodology needs work.
The raw data is there which I considered to be a higher priority initially.

I ran a number of tests against kernels since 2.6.32 and there is a lot of
interesting stuff in there. Unfortunately I have not had the chance to dig
through it all and validate all the tests are working exactly as expected
so they are not all available. However, this is an example report for one
test configuration on one machine. It's a bit ugly but that was not a high
priority. The other tests work on a similar principal

http://www.csn.ul.ie/~mel/postings/mmtests-20120620/global-dhp__pagealloc-performance/comparison.html

Just glancing through, it's possible to see interesting things and additional
investigation work that is required.

o Something awful happened in 3.2.9 across the board according to this
  machine
o Kernbench in 3.3 and 3.4 was still not great in comparison to 3.1
o Page allocator performance was ruined for a large number of releases
  but generally improved in 3.3 although it's still a bit all over
  the place [*]
o hackbench-pipes had a fun history but is mostly good in 3.4
o hackbench-sockets had a similarly fun history
o aim9 shows that page-test took a big drop after 2.6.32 and has not
  recovered yet. Some of the other tests are also very alarming
o STREAM is ok at least but that is not heavily dependant on kernel

[*] It was this report that led to commit cc9a6c877 and the effect is
    visible if you squint hard enough. Needs a graph generator and
    a double checking that true-mean is measuring the right thing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
