Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 57D6D6B004D
	for <linux-mm@kvack.org>; Mon, 10 Aug 2009 11:41:57 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/6] Add some trace events for the page allocator v6
Date: Mon, 10 Aug 2009 16:41:49 +0100
Message-Id: <1249918915-16061-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, Li Ming Chun <macli@brc.ubc.ca>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is V6 of a patchset to add some tracepoints of interest when analysing
the page allocator. The only changes since the last revision were to fix a
minor error in the post-processing script and to add a reviewed-by to one
of the patches.

Can we get a yey/nay on whether these should be merged or not?

Changelog since V4
  o Drop the order parameter from mm_pagevec_free() as it's implicitly 0
  o Drop the cpu= information from PCPU events as the CPU printed is
    incorrect and the information is already available
  o Pass down the minimum amount of information during fallback and the
    zone_locked event as the additional information in TP_printk
  o Pass down the minimum amount of information during fallback and figure
    out the additional information in the post-processing TP_printk
  o Make the post-processing script more robust against format changes.
    This could be significantly more robust and construct a regex on
    the fly but it makes more sense to leave this as a POC with the
    view to integrating properly with perf once the important information
    has been identified
  o Exit the script after multiple signals without waiting for further input

Changelog since V3
  o Drop call_site information from trace events
  o Use struct page * instead of void * in trace events
  o Add CPU information to the per-cpu tracepoints information
  o Improved performance of offline-process script so it can run online
  o Add support for interrupting processing script to dump what it has
  o Add support for stripping pids, getting additional information from
    proc and adding information on the parent process
  o Improve layout of output of post processing script for use with sort
  o Add documentation on performance analysis using tracepoints
  o Add documentation on the kmem tracepoints in particular

Changelog since V2
  o Added Ack-ed By's from Rik
  o Only call trace_mm_page_free_direct when page count reaches zero
  o Rebase to 2.6.31-rc5

Changelog since V1
  o Fix minor formatting error for the __rmqueue event
  o Add event for __pagevec_free
  o Bring naming more in line with Larry Woodman's tracing patch
  o Add an example post-processing script for the trace events

The following four patches add some trace events for the page allocator
under the heading of kmem.

	Patch 1 adds events for plain old allocate and freeing of pages
	Patch 2 gives information useful for analysing fragmentation avoidance
	Patch 3 tracks pages going to and from the buddy lists as an indirect
		indication of zone lock hotness
	Patch 4 adds a post-processing script that aggegates the events to
		give a higher-level view
	Patch 5 adds documentation on analysis using tracepoints
	Patch 6 adds documentation on the kmem tracepoints in particular

The first set of events can be used as an indicator as to whether the workload
was heavily dependant on the page allocator or not. You can make a guess based
on vmstat but you can't get a per-process breakdown. Depending on the call
path, the call_site for page allocation may be __get_free_pages() instead
of a useful callsite. Instead of passing down a return address similar to
slab debugging, the user should enable the stacktrace and seg-addr options
to get a proper stack trace.

The second patch is mainly of use to users of hugepages and particularly
dynamic hugepage pool resizing as it could be used to tune min_free_kbytes
to a level that fragmentation was rarely a problem. My main concern is
that maybe I'm trying to jam too much into the TP_printk that could be
extrapolated after the fact if you were familiar with the implementation. I
couldn't determine if it was best to hold the hand of the administrator
even if it cost more to figure it out.

The third patch is trickier to draw conclusions from but high activity on
those events could explain why there were a large number of cache misses
on a page-allocator-intensive workload. The coalescing and splitting of
buddies involves a lot of writing of page metadata and cache line bounces
not to mention the acquisition of an interrupt-safe lock necessary to enter
this path.

The fourth patch parses the trace buffer to draw a higher-level picture of
what is going on broken down on a per-process basis.

The last two patches add documentation.

 Documentation/trace/events-kmem.txt                |  107 +++++
 .../postprocess/trace-pagealloc-postprocess.pl     |  418 ++++++++++++++++++++
 Documentation/trace/tracepoint-analysis.txt        |  327 +++++++++++++++
 include/trace/events/kmem.h                        |  163 ++++++++
 mm/page_alloc.c                                    |   13 +-
 5 files changed, 1027 insertions(+), 1 deletions(-)
 create mode 100644 Documentation/trace/events-kmem.txt
 create mode 100755 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
 create mode 100644 Documentation/trace/tracepoint-analysis.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
