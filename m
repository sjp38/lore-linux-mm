Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3359960020C
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 10:38:26 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/2] Prioritise inodes and zones for writeback required by page reclaim
Date: Wed,  4 Aug 2010 15:38:29 +0100
Message-Id: <1280932711-23696-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Commenting on the series "Reduce writeback from page reclaim context V6"
Andrew Morton noted;

  direct-reclaim wants to write a dirty page because that page is in the
  zone which the caller wants to allocate from!  Telling the flusher threads
  to perform generic writeback will sometimes cause them to just gum the
  disk up with pages from different zones, making it even harder/slower to
  allocate a page from the zones we're interested in, no?

On the machines used to test the series, there were relatively few zones
and only one BDI so the scenario describes is a possibility. This series is
a very early prototype series aimed at mitigating the problem.

Patch 1 adds wakeup_flusher_threads_pages() which takes a list of pages
from page reclaim. Each inode belonging to a page on the list is marked
I_DIRTY_RECLAIM. When the flusher thread wakes, inodes with this tag are
unconditionally moved to the wb->b_io list for writing.

Patch 2 notes that writing back inodes does not necessarily write back
pages belonging to the zone page reclaim is concerned with. In response, it
adds a zone and counter to wb_writeback_work. As pages from the target zone
are written, the zone-specific counter is updated. When the flusher thread
then checks the zone counters if a specific zone is being targeted. While
more pages may be written than necessary, the assumption is that the pages
need cleaning eventually, the inode must be relatively old to have pages at
the end of the LRU, the IO will be relatively efficient due to less random
seeks and that pages from the target zone will still be cleaned.

Testing did not show any significant differences in terms of reducing dirty
file pages being written back but the lack of multiple BDIs and NUMA nodes in
the test rig is a problem. Maybe someone else has access to a more suitable
test rig.

Any comment as to the suitability for such a direction?

 fs/fs-writeback.c         |   83 +++++++++++++++++++++++++++++++++++++++++---
 include/linux/fs.h        |    5 ++-
 include/linux/writeback.h |    5 +++
 mm/page-writeback.c       |   12 ++++++-
 mm/vmscan.c               |   11 ++++--
 5 files changed, 103 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
