Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C27D46B01B9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 05:02:30 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim and use a_ops->writepages() where possible
Date: Tue,  8 Jun 2010 10:02:19 +0100
Message-Id: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

I finally got a chance last week to visit the topic of direct reclaim
avoiding the writing out pages. As it came up during discussions the last
time, I also had a stab at making the VM writing ranges of pages instead
of individual pages. I am not proposing for merging yet until I want to see
what people think of this general direction and if we can agree on if this
is the right one or not.

To summarise, there are two big problems with page reclaim right now. The
first is that page reclaim uses a_op->writepage to write a back back
under the page lock which is inefficient from an IO perspective due to
seeky patterns.  The second is that direct reclaim calling the filesystem
splices two potentially deep call paths together and potentially overflows
the stack on complex storage or filesystems. This series is an early draft
at tackling both of these problems and is in three stages.

The first 4 patches are a forward-port of trace points that are partly
based on trace points defined by Larry Woodman but never merged. They trace
parts of kswapd, direct reclaim, LRU page isolation and page writeback. The
tracepoints can be used to evaluate what is happening within reclaim and
whether things are getting better or worse. They do not have to be part of
the final series but might be useful during discussion.

Patch 5 writes out contiguous ranges of pages where possible using
a_ops->writepages. When writing a range, the inode is pinned and the page
lock released before submitting to writepages(). This potentially generates
a better IO pattern and it should avoid a lock inversion problem within the
filesystem that wants the same page lock held by the VM. The downside with
writing ranges is that the VM may not be generating more IO than necessary.

Patch 6 prevents direct reclaim writing out pages at all and instead dirty
pages are put back on the LRU. For lumpy reclaim, the caller will briefly
wait on dirty pages to be written out before trying to reclaim the dirty
pages a second time.

The last patch increases the responsibility of kswapd somewhat because
it's now cleaning pages on behalf of direct reclaimers but kswapd seemed
a better fit than background flushers to clean pages as it knows where the
pages needing cleaning are. As it's async IO, it should not cause kswapd to
stall (at least until the queue is congested) but the order that pages are
reclaimed on the LRU is altered. Dirty pages that would have been reclaimed
by direct reclaimers are getting another lap on the LRU. The dirty pages
could have been put on a dedicated list but this increased counter overhead
and the number of lists and it is unclear if it is necessary.

The series has survived performance and stress testing, particularly around
high-order allocations on X86, X86-64 and PPC64. The results of the tests
showed that while lumpy reclaim has a slightly lower success rate when
allocating huge pages but it was still very acceptable rates, reclaim was
a lot less disruptive and allocation latency was lower.

Comments?

 .../trace/postprocess/trace-vmscan-postprocess.pl  |  623 ++++++++++++++++++++
 include/trace/events/gfpflags.h                    |   37 ++
 include/trace/events/kmem.h                        |   38 +--
 include/trace/events/vmscan.h                      |  184 ++++++
 mm/vmscan.c                                        |  299 ++++++++--
 5 files changed, 1092 insertions(+), 89 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
