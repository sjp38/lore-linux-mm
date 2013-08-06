Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CA72C6B0034
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:23:19 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/9] mm: thrash detection-based file cache sizing v3
Date: Tue,  6 Aug 2013 18:22:49 -0400
Message-Id: <1375827778-12357-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman@kvack.org, "Gushchin <klamm"@yandex-team.ru, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Changes in version 3:

o Lazily remove inodes without shadow entries from the global list to
  reduce modifications of said list to an absolute minimum.  Global
  list operations are now reduced to when an inode has its first cache
  page reclaimed (rare) and when a linked inode is destroyed (rare) or
  when the inode's shadows are shrunk (rare) to zero (rare).  These
  events should be even rarer than the per-sb inode list operations,
  which take a global lock.  Based on feedback from Peter Zijlstra.

o Drop global working set time, store zone ID in addition to
  zone-specific timestamp in radix tree instead.  Balance zones based
  on their own refaults only.  This allows the refault detecting side
  to be much sleaker too and removes a lot of changes to the page
  allocator interface.  Based on feedback from Peter Zijlstra.

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
 include/linux/fs.h                        |   3 +
 include/linux/mm.h                        |   8 +
 include/linux/mmzone.h                    |   7 +
 include/linux/pagemap.h                   |  55 +++-
 include/linux/pagevec.h                   |   3 +
 include/linux/radix-tree.h                |   5 +-
 include/linux/shmem_fs.h                  |   1 +
 include/linux/swap.h                      |  10 +
 include/linux/writeback.h                 |   1 +
 lib/radix-tree.c                          | 105 ++-----
 mm/Makefile                               |   2 +-
 mm/filemap.c                              | 265 +++++++++++++---
 mm/mincore.c                              |  20 +-
 mm/page-writeback.c                       |   2 +-
 mm/readahead.c                            |   8 +-
 mm/shmem.c                                | 122 ++------
 mm/swap.c                                 |  22 ++
 mm/truncate.c                             |  78 ++++-
 mm/vmscan.c                               |  62 +++-
 mm/vmstat.c                               |   4 +
 mm/workingset.c                           | 461 ++++++++++++++++++++++++++++
 net/ceph/pagelist.c                       |   4 +-
 net/ceph/pagevec.c                        |   2 +-
 34 files changed, 1005 insertions(+), 299 deletions(-)

Based on the latest -mmotm, which includes the required page allocator
fairness patches.  All that: http://git.cmpxchg.org/cgit/linux-jw.git/

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
