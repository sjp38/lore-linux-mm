Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 99C866B02B9
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 04:00:42 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Reduce watermark-related problems with the per-cpu allocator V2
Date: Mon, 23 Aug 2010 09:00:39 +0100
Message-Id: <1282550442-15193-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Changelog since V1
  o Fix for !CONFIG_SMP
  o Correct spelling mistakes
  o Clarify a ChangeLog
  o Only check for counter drift on machines large enough for the counter
    drift to breach the min watermark when NR_FREE_PAGES report the low
    watermark is fine

Internal IBM test teams beta testing distribution kernels have reported
problems on machines with a large number of CPUs whereby page allocator
failure messages show huge differences between the nr_free_pages vmstat
counter and what is available on the buddy lists. In an extreme example,
nr_free_pages was above the min watermark but zero pages were on the buddy
lists allowing the system to potentially livelock unable to make forward
progress unless an allocation succeeds. There is no reason why the problems
would not affect mainline so the following series mitigates the problems
in the page allocator related to to per-cpu counter drift and lists.

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

This patch should be merged after the patch "vmstat : update
zone stat threshold at onlining a cpu" which is in mmotm as
vmstat-update-zone-stat-threshold-when-onlining-a-cpu.patch .

Are there any objections to merging?

 include/linux/mmzone.h |   13 +++++++++++++
 mm/mmzone.c            |   29 +++++++++++++++++++++++++++++
 mm/page_alloc.c        |   29 +++++++++++++++++++++--------
 mm/vmstat.c            |   15 ++++++++++++++-
 4 files changed, 77 insertions(+), 9 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
