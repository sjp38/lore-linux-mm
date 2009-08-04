Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8BA6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 13:43:09 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/4] Add some trace events for the page allocator v3
Date: Tue,  4 Aug 2009 19:12:22 +0100
Message-Id: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Changelog since V2
  o Added Ack-ed By's from Rik
  o Only call trace_mm_page_free_direct when page count reaches zero
  o Rebase to 2.6.31-rc5

Changelog since V1
  o Fix minor formatting error for the __rmqueue event
  o Add event for __pagevec_free
  o Bring naming more in line with Larry Woodman's tracing patch
  o Add an example post-processing script for the trace events

This is V3 of a patchset to add some trace points for the page allocator. This
version adds some ACKs, drops the RFC from the headline and fixes one issue
where trace_mm_page_free_direct triggered more than it should. The following
four patches add some trace events for the page allocator under the heading
of kmem.

	Patch 1 adds events for plain old allocate and freeing of pages
	Patch 2 gives information useful for analysing fragmentation avoidance
	Patch 3 tracks pages going to and from the buddy lists as an indirect
		indication of zone lock hotness
	Patch 4 adds a post-processing script that aggegates the events to
		give a higher-level view

The first one could be used as an indicator as to whether the workload was
heavily dependant on the page allocator or not. You can make a guess based
on vmstat but you can't get a per-process breakdown. Depending on the call
path, the call_site for page allocation may be __get_free_pages() instead
of a useful callsite. Instead of passing down a return address similar to
slab debugging, the user should enable the stacktrace and seg-addr options
to get a proper stack trace.

The second patch would mainly be useful for users of hugepages and
particularly dynamic hugepage pool resizing as it could be used to tune
min_free_kbytes to a level that fragmentation was rarely a problem. My
main concern is that maybe I'm trying to jam too much into the TP_printk
that could be extrapolated after the fact if you were familiar with the
implementation. I couldn't determine if it was best to hold the hand of
the administrator even if it cost more to figure it out.

The third patch is trickier to draw conclusions from but high activity on
those events could explain why there were a large number of cache misses
on a page-allocator-intensive workload. The coalescing and splitting of
buddies involves a lot of writing of page metadata and cache line bounces
not to mention the acquisition of an interrupt-safe lock necessary to enter
this path.

The fourth patch parses the trace buffer to draw a higher-level picture of
what is going on broken down on a per-process basis.

 .../postprocess/trace-pagealloc-postprocess.pl     |  131 ++++++++++++++
 include/trace/events/kmem.h                        |  184 ++++++++++++++++++++
 mm/page_alloc.c                                    |   14 ++-
 3 files changed, 328 insertions(+), 1 deletions(-)
 create mode 100755 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
