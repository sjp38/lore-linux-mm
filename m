Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 21F646B0075
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 13:36:54 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/7] Reduce compaction-related stalls and improve asynchronous migration of dirty pages v4r2
Date: Mon, 21 Nov 2011 18:36:41 +0000
Message-Id: <1321900608-27687-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

This is still a work-in-progress but felt it was important to show
what direction I am going with reconciling Andrea's series with
my own. This is against 3.2-rc2 and follows on from discussions on
"mm: Do not stall in synchronous compaction for THP allocations" and
"[RFC PATCH 0/5] Reduce compaction-related stalls".

Initially, the proposed patch eliminated stalls due to compaction
which sometimes resulted in user-visible interactivity problems on
browsers by simply never using sync compaction. The downside was that
THP success allocation rates were lower because dirty pages were not
being migrated as reported by Andrea. However, Andrea's approach was
a bit heavy handed and reverted fixes Rik merged that reduced the
amount of pages THP reclaimed.

This series is an RFC attempting to reconcile the requirements of
maximising THP usage, without stalling in a user-visible fashion due
to compaction or cheating by reclaiming an excessive number of pages.

Patch 1 partially reverts commit 39deaf85 to allow migration to isolate
	dirty pages.

Patch 2 notes that the /proc/sys/vm/compact_memory handler is not using
	synchronous compaction when it should be.

Patch 3 checks if we isolated a compound page during lumpy scan

Patch 4 adds a sync parameter to the migratepage callback. It is up
	to the callback to migrate that page without blocking if
	sync==false. For example, fallback_migrate_page will not
	call writepage if sync==false

Patch 5 restores filter-awareness to isolate_lru_page for migration.
	In practice, it means that pages under writeback and pages
	without a ->migratepage callback will not be isolated
	for migration.

Patch 6 avoids calling direct reclaim if compaction is deferred but
	makes sure that compaction is only deferred if sync
	compaction was used.

Patch 7 introduces a sync-light migration mechanism that sync compaction
	uses. The objective is to allow some stalls but to not call
	->writepage which can lead to significant user-visible stalls.

This has been lightly tested and nothing horrible fell out. Of critical
importance was that during a light test, stalls due to compaction were
eliminated even though sync compaction was still allowed.  Andrea, I
have not actually tried your test case but while monitoring THP usage
while a USB copy was in progress, I found that THP usage was higher

http://www.csn.ul.ie/~mel/postings/compaction-20111121/thp-comparison-smooth-hydra.png

while memory utilisation was also higher 

http://www.csn.ul.ie/~mel/postings/compaction-20111121/memory-usage-comparison-smooth-hydra.png

 fs/btrfs/disk-io.c      |    5 +-
 fs/nfs/internal.h       |    2 +-
 fs/nfs/write.c          |    4 +-
 include/linux/fs.h      |   11 ++-
 include/linux/migrate.h |   23 +++++--
 include/linux/mmzone.h  |    2 +
 mm/compaction.c         |    5 +-
 mm/memory-failure.c     |    2 +-
 mm/memory_hotplug.c     |    2 +-
 mm/mempolicy.c          |    2 +-
 mm/migrate.c            |  171 ++++++++++++++++++++++++++++++++---------------
 mm/page_alloc.c         |   45 ++++++++++---
 mm/vmscan.c             |   45 +++++++++++--
 13 files changed, 232 insertions(+), 87 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
