Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CD92D6B01F3
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 05:42:20 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/3] Reduce watermark-related problems with the per-cpu allocator
Date: Mon, 16 Aug 2010 10:42:10 +0100
Message-Id: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Internal IBM test teams beta testing distribution kernels have reported
problems on machines with a large number of CPUs whereby page allocator
failure messages show huge differences between the nr_free_pages vmstat
counter and what is available on the buddy lists. In an extreme example,
nr_free_pages was above the min watermark but zero pages were on the buddy
lists allowing the system to potentially deadlock. There is no reason why
the problems would not affect mainline so the following series mitigates the
problems in the page allocator related to to per-cpu counter drift and lists.

The first patch ensures that counters are updated after pages are added to
free lists.

The second patch notes that the counter drift between nr_free_pages and what
is on the per-cpu lists can be very high. When memory is low and kswapd
is awake, the per-cpu counters are checked as well as reading the value
of NR_FREE_PAGES. This will slow the page allocator when memory is low and
kswapd is awake but it will be much harder to breach the min watermark and
potentially livelock the system.

The third patch notes that after direct-reclaim an allocation can
fail because the necessary pages are on the per-cpu lists. After a
direct-reclaim-and-allocation-failure, the per-cpu lists are drained and
a second attempt is made.

Performance tests did not show up anything interesting. A version of this
series that continually called vmstat_update() when memory was low was
tested internally and found to help the counter drift problem. I described
this during LSF/MM Summit and the potential for IPI storms was frowned
upon. An alternative fix is in patch two which uses for_each_online_cpu()
to read the vmstat deltas while memory is low and kswapd is awake. This
should be functionally similar.

Comments?

 include/linux/mmzone.h |    9 +++++++++
 mm/mmzone.c            |   27 +++++++++++++++++++++++++++
 mm/page_alloc.c        |   28 ++++++++++++++++++++++------
 mm/vmstat.c            |    5 ++++-
 4 files changed, 62 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
