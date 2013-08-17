Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id DFD596B0034
	for <linux-mm@kvack.org>; Sat, 17 Aug 2013 15:32:23 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 9/9] mm: thrash detection-based file cache sizing v4
Date: Sat, 17 Aug 2013 15:31:14 -0400
Message-Id: <1376767883-4411-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Changes in version 4:

o Rework shrinker and shadow planting throttle.  The per-file
  throttling created problems in production tests.  And the shrinker
  code changed so much over the development of the series that the
  throttling policy is no longer applicable, so just remove it, and
  with it the extra unsigned long to track refault ratios in struct
  inode (yay!).

o Remove the 'enough free pages' filter from refault detection.  This
  never was just right for all types of zone sizes (varying watermarks
  and lowmem reserves) and filtered too many valid refault hits.  It
  was put in place to detect when reclaim already freed enough pages,
  to stop deactivating more than necessary.  But reclaim advances the
  working set time, so progress is reflected in the refault distances
  that we check either way.  Just remove the redundant test.

o Update changelog in terms of what the refault distance means and how
  the code protects against spurious refaults that happen out of
  order.  Suggested by Vlastimil Babka.

Changes in version 3:

o Drop global working set time, store zone ID in addition to
  zone-specific timestamp in radix tree instead.  Balance zones based
  on their own refaults only.  Based on feedback from Peter Zijlstra.

o Lazily remove inodes without shadow entries from the global list to
  reduce modifications of said list to an absolute minimum.  Global
  list operations are now reduced to when an inode has its first cache
  page reclaimed (rare) and when a linked inode is destroyed (rare) or
  when the inode's shadows are shrunk to zero (rare).  Based on
  feedback from Peter Zijlstra.

o Document all interfaces properly

o Split out fair allocator patches (in -mmotm)

---

The VM maintains cached filesystem pages on two types of lists.  One
list holds the pages recently faulted into the cache, the other list
holds pages that have been referenced repeatedly on that first list.
The idea is to prefer reclaiming young pages over those that have
shown to benefit from caching in the past.  We call the recently used
list "inactive list" and the frequently used list "active list".

The tricky part of this model is finding the right balance between
them.  A big inactive list may not leave enough room for the active
list to protect all the frequently used pages.  A big active list may
not leave enough room for the inactive list for a new set of
frequently used pages, "working set", to establish itself because the
young pages get pushed out of memory before having a chance to get
promoted.

Historically, every reclaim scan of the inactive list also took a
smaller number of pages from the tail of the active list and moved
them to the head of the inactive list.  This model gave established
working sets more gracetime in the face of temporary use once streams,
but was not satisfactory when use once streaming persisted over longer
periods of time and the established working set was temporarily
suspended, like a nightly backup evicting all the interactive user
program data.
    
Subsequently, the rules were changed to only age active pages when
they exceeded the amount of inactive pages, i.e. leave the working set
alone as long as the other half of memory is easy to reclaim use once
pages.  This works well until working set transitions exceed the size
of half of memory and the average access distance between the pages of
the new working set is bigger than the inactive list.  The VM will
mistake the thrashing new working set for use once streaming, while
the unused old working set pages are stuck on the active list.

This happens on file servers and media streaming servers, where the
popular set of files changes over time.  Even though the individual
files might be smaller than half of memory, concurrent access to many
of them may still result in their inter-reference distance being
greater than half of memory.  It's also been reported as a problem on
database workloads that switch back and forth between tables that are
bigger than half of memory.  In these cases the VM never recognizes
the new working set and will for the remainder of the workload thrash
disk data which could easily live in memory.

This series solves the problem by maintaining a history of pages
evicted from the inactive list, enabling the VM to tell streaming IO
from thrashing and rebalance the page cache lists when appropriate.

 drivers/staging/lustre/lustre/llite/dir.c |   2 +-
 fs/block_dev.c                            |   2 +-
 fs/btrfs/compression.c                    |   4 +-
 fs/cachefiles/rdwr.c                      |  13 +-
 fs/ceph/xattr.c                           |   2 +-
 fs/inode.c                                |   6 +-
 fs/logfs/readwrite.c                      |   6 +-
 fs/nfs/blocklayout/blocklayout.c          |   2 +-
 fs/nilfs2/inode.c                         |   4 +-
 fs/ntfs/file.c                            |   7 +-
 fs/splice.c                               |   6 +-
 include/linux/fs.h                        |   2 +
 include/linux/mm.h                        |   8 +
 include/linux/mmzone.h                    |   8 +
 include/linux/pagemap.h                   |  55 ++--
 include/linux/pagevec.h                   |   3 +
 include/linux/radix-tree.h                |   5 +-
 include/linux/shmem_fs.h                  |   1 +
 include/linux/swap.h                      |   9 +
 include/linux/writeback.h                 |   1 +
 lib/radix-tree.c                          | 105 ++------
 mm/Makefile                               |   2 +-
 mm/filemap.c                              | 264 ++++++++++++++++---
 mm/mincore.c                              |  20 +-
 mm/page-writeback.c                       |   2 +-
 mm/readahead.c                            |   8 +-
 mm/shmem.c                                | 122 +++------
 mm/swap.c                                 |  22 ++
 mm/truncate.c                             |  78 ++++--
 mm/vmscan.c                               |  62 ++++-
 mm/vmstat.c                               |   5 +
 mm/workingset.c                           | 396 ++++++++++++++++++++++++++++
 net/ceph/pagelist.c                       |   4 +-
 net/ceph/pagevec.c                        |   2 +-
 34 files changed, 939 insertions(+), 299 deletions(-)

Based on -mmotm, which includes the required page allocator fairness
patches.  All that: http://git.cmpxchg.org/cgit/linux-jw.git/

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
