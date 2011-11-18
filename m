Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5CA6B0075
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 11:58:49 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/5] Reduce compaction-related stalls and improve asynchronous migration of dirty pages v3
Date: Fri, 18 Nov 2011 16:58:39 +0000
Message-Id: <1321635524-8586-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, LKML <linux-kernel@vger.kernel.org>

This series is against 3.2-rc2 and follows on from discussions on "mm:
Do not stall in synchronous compaction for THP allocations". That
patch eliminated stalls due to compaction which sometimes resulted
in user-visible interactivity problems on browsers. The downside was
that THP success allocation rates were lower because dirty pages were
not being migrated.

This series is an RFC on how we can migrate more dirty pages with
asynchronous compaction.  The intention is to maximise transparent
hugepage availability while minimising stalls. This does not rule out
the possibility of having a tunable to enable synchronous compaction
at a time when a user is willing to stall waiting on huge pages and
to disable khugepaged.

Patch 1 partially reverts commit 39deaf85 to allow migration to isolate
	dirty pages.

Patch 2 notes that the /proc/sys/vm/compact_memory handler is not using
	synchronous compaction when it should be.

Patch 3 prevents THP allocations using synchronous compaction as this
	can result in user-visible stalls. More details on the stalls
	are in the changelog.

Patch 4 adds a sync parameter to the migratepage callback. It is up
	to the callback to migrate that page without blocking if
	sync==false. For example, fallback_migrate_page will not
	call writepage if sync==false

Patch 5 restores filter-awareness to isolate_lru_page for migration.
	In practice, it means that pages under writeback and pages
	without a ->migratepage callback will not be isolated
	for migration.

This has been lightly tested and nothing horrible fell out
but I need to think a lot more more on patch 4 to see if
buffer_migrate_lock_buffers() is really doing the right thing for
async compaction and if the backout logic is correct. Stalls due
to compaction were eliminated and hugepage allocation success rates
were more or less the same. I'm running a more comprehensive set of
tests over the weekend to see if the warning in patch 4 triggers
in particular and what the allocation success rates look like for
different loads.

Andrea, I didn't pick up your "move ISOLATE_CLEAN setting out of
compaction_migratepages loop" but obviously could if this series gains
any traction. This is also orthogonal to your "improve synchronous
compaction" idea but obviously if the stalls from sync compaction could
be significantly reduced, it would still not collide with this series
that improves the migration of dirty pages for asynchronous compaction.
If your approach works, it would replace patch 3 from this series.

 fs/btrfs/disk-io.c      |    2 +-
 fs/nfs/internal.h       |    2 +-
 fs/nfs/write.c          |    4 +-
 include/linux/fs.h      |    9 +++-
 include/linux/gfp.h     |   11 +++++
 include/linux/migrate.h |    2 +-
 include/linux/mmzone.h  |    2 +
 mm/compaction.c         |    3 +-
 mm/migrate.c            |  106 ++++++++++++++++++++++++++++++++---------------
 mm/page_alloc.c         |    9 ++++-
 mm/vmscan.c             |   36 +++++++++++++++-
 11 files changed, 140 insertions(+), 46 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
