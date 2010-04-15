Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9FC6B01F2
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:21:44 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 00/10] Reduce stack usage used by page reclaim V1
Date: Thu, 15 Apr 2010 18:21:33 +0100
Message-Id: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is just an RFC to reduce some of the more obvious stack usage in page
reclaim. It's a bit rushed and I haven't tested this yet but am sending
it out as there may be others working on similar material and would rather
avoid overlap. I built on some of Kosaki Motohiro's work.

On X86 bit, stack usage figures (generated using a modified bloat-o-meter
that uses checkstack.pl as its input) change in the following ways after
the series of patches.

add/remove: 2/0 grow/shrink: 0/4 up/down: 804/-1688 (-884)
function                                     old     new   delta
putback_lru_pages                              -     676    +676
update_isolated_counts                         -     128    +128
do_try_to_free_pages                         172     128     -44
kswapd                                      1324    1168    -156
shrink_page_list                            1616    1224    -392
shrink_zone                                 2320    1224   -1096

There are some growths there but critically they are no longer in the path
that would call writepages. In the main path, there is about 1K of stack
lopped off giving a small amount of breathing room.

KOSAKI Motohiro (3):
  vmscan: kill prev_priority completely
  vmscan: move priority variable into scan_control
  vmscan: simplify shrink_inactive_list()

Mel Gorman (7):
  vmscan: Remove useless loop at end of do_try_to_free_pages
  vmscan: Remove unnecessary temporary vars in do_try_to_free_pages
  vmscan: Split shrink_zone to reduce stack usage
  vmscan: Remove unnecessary temporary variables in shrink_zone()
  vmscan: Setup pagevec as late as possible in shrink_inactive_list()
  vmscan: Setup pagevec as late as possible in shrink_page_list()
  vmscan: Update isolated page counters outside of main path in
    shrink_inactive_list()

 include/linux/mmzone.h |   15 --
 mm/page_alloc.c        |    2 -
 mm/vmscan.c            |  447 +++++++++++++++++++++++-------------------------
 mm/vmstat.c            |    2 -
 4 files changed, 210 insertions(+), 256 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
