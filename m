Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B4A716B007D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 14:49:42 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: used-once mapped file page detection
Date: Mon, 22 Feb 2010 20:49:07 +0100
Message-Id: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Hi,

this is the second submission of the used-once mapped file page
detection patch.

It is meant to help workloads with large amounts of shortly used file
mappings, like rtorrent hashing a file or git when dealing with loose
objects (git gc on a bigger site?).

Right now, the VM activates referenced mapped file pages on first
encounter on the inactive list and it takes a full memory cycle to
reclaim them again.  When those pages dominate memory, the system
no longer has a meaningful notion of 'working set' and is required
to give up the active list to make reclaim progress.  Obviously,
this results in rather bad scanning latencies and the wrong pages
being reclaimed.

This patch makes the VM be more careful about activating mapped file
pages in the first place.  The minimum granted lifetime without
another memory access becomes an inactive list cycle instead of the
full memory cycle, which is more natural given the mentioned loads.

This test resembles a hashing rtorrent process.  Sequentially, 32MB
chunks of a file are mapped into memory, hashed (sha1) and unmapped
again.  While this happens, every 5 seconds a process is launched and
its execution time taken:

	python2.4 -c 'import pydoc'
	old: max=2.31s mean=1.26s (0.34)
	new: max=1.25s mean=0.32s (0.32)

	find /etc -type f
	old: max=2.52s mean=1.44s (0.43)
	new: max=1.92s mean=0.12s (0.17)

	vim -c ':quit'
	old: max=6.14s mean=4.03s (0.49)
	new: max=3.48s mean=2.41s (0.25)

	mplayer --help
	old: max=8.08s mean=5.74s (1.02)
	new: max=3.79s mean=1.32s (0.81)

	overall hash time (stdev):
	old: time=1192.30 (12.85) thruput=25.78mb/s (0.27)
	new: time=1060.27 (32.58) thruput=29.02mb/s (0.88) (-11%)

I also tested kernbench with regular IO streaming in the background to
see whether the delayed activation of frequently used mapped file
pages had a negative impact on performance in the presence of pressure
on the inactive list.  The patch made no significant difference in
timing, neither for kernbench nor for the streaming IO throughput.

The first patch submission raised concerns about the cost of the extra
faults for actually activated pages on machines that have no hardware
support for young page table entries.

I created an artificial worst case scenario on an ARM machine with
around 300MHz and 64MB of memory to figure out the dimensions
involved.  The test would mmap a file of 20MB, then

  1. touch all its pages to fault them in
  2. force one full scan cycle on the inactive file LRU
  -- old: mapping pages activated
  -- new: mapping pages inactive
  3. touch the mapping pages again
  -- old and new: fault exceptions to set the young bits
  4. force another full scan cycle on the inactive file LRU
  5. touch the mapping pages one last time
  -- new: fault exceptions to set the young bits

The test showed an overall increase of 6% in time over 100 iterations
of the above (old: ~212sec, new: ~225sec).  13 secs total overhead /
(100 * 5k pages), ignoring the execution time of the test itself,
makes for about 25us overhead for every page that gets actually
activated.  Note:

  1. File mapping the size of one third of main memory, _completely_
  in active use across memory pressure - i.e., most pages referenced
  within one LRU cycle.  This should be rare to non-existant,
  especially on such embedded setups.

  2. Many huge activation batches.  Those batches only occur when the
  working set fluctuates.  If it changes completely between every full
  LRU cycle, you have problematic reclaim overhead anyway.

  3. Access of activated pages at maximum speed: sequential loads from
  every single page without doing anything in between.  In reality,
  the extra faults will get distributed between actual operations on
  the data.

So even if a workload manages to get the VM into the situation of
activating a third of memory in one go on such a setup, it will take
2.2 seconds instead 2.1 without the patch.

Comparing the numbers (and my user-experience over several months),
I think this change is an overall improvement to the VM.

Patch 1 is only refactoring to break up that ugly compound conditional
in shrink_page_list() and make it easy to document and add new checks
in a readable fashion.

Patch 2 gets rid of the obsolete page_mapping_inuse().  It's not
strictly related to #3, but it was in the original submission and is a
net simplification, so I kept it.

Patch 3 implements used-once detection of mapped file pages.

	Hannes

 include/linux/rmap.h |    2 +-
 mm/rmap.c            |    3 -
 mm/vmscan.c          |  105 ++++++++++++++++++++++++++++++++-----------------
 3 files changed, 69 insertions(+), 41 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
