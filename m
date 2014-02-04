Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id D09226B0038
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:58:40 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b57so4007676eek.10
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 16:58:40 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id s6si38661831eel.140.2014.02.03.16.58.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 16:58:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/10] mm: thrash detection-based file cache sizing v9
Date: Mon,  3 Feb 2014 19:53:32 -0500
Message-Id: <1391475222-1169-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

	Changes in this revision

o Fix vmstat build problems on UP (Fengguang Wu's build bot)

o Clarify why optimistic radix_tree_node->private_list link checking
  is safe without holding the list_lru lock (Dave Chinner)

o Assert locking balance when the list_lru isolator says it dropped
  the list lock (Dave Chinner)

o Remove remnant of a manual reclaim counter in the shadow isolator,
  the list_lru-provided accounting is accurate now that we added
  LRU_REMOVED_RETRY (Dave Chinner)

o Set an object limit for the shadow shrinker instead of messing with
  its seeks setting.  The configured seeks define how pressure applied
  to pages translates to pressure on the object pool, in itself it is
  not enough to replace proper object valuation to classify expired
  and in-use objects.  Shadow nodes contain up to 64 shadow entries
  from different/alternating zones that have their own atomic age
  counter, so determining if a node is overall expired is crazy
  expensive.  Instead, use an object limit above which nodes are very
  likely to be expired.

o __pagevec_lookup and __find_get_pages kerneldoc fixes (Minchan Kim)

o radix_tree_node->count accessors for pages and shadows (Minchan Kim)

o Rebase to v3.14-rc1 and add review tags

	Summary

The VM maintains cached filesystem pages on two types of lists.  One
list holds the pages recently faulted into the cache, the other list
holds pages that have been referenced repeatedly on that first list.
The idea is to prefer reclaiming young pages over those that have
shown to benefit from caching in the past.  We call the recently used
list "inactive list" and the frequently used list "active list".
    
Currently, the VM aims for a 1:1 ratio between the lists, which is the
"perfect" trade-off between the ability to *protect* frequently used
pages and the ability to *detect* frequently used pages.  This means
that working set changes bigger than half of cache memory go
undetected and thrash indefinitely, whereas working sets bigger than
half of cache memory are unprotected against used-once streams that
don't even need caching.

This happens on file servers and media streaming servers, where the
popular files and file sections change over time.  Even though the
individual files might be smaller than half of memory, concurrent
access to many of them may still result in their inter-reference
distance being greater than half of memory.  It's also been reported
as a problem on database workloads that switch back and forth between
tables that are bigger than half of memory.  In these cases the VM
never recognizes the new working set and will for the remainder of the
workload thrash disk data which could easily live in memory.
    
Historically, every reclaim scan of the inactive list also took a
smaller number of pages from the tail of the active list and moved
them to the head of the inactive list.  This model gave established
working sets more gracetime in the face of temporary use-once streams,
but ultimately was not significantly better than a FIFO policy and
still thrashed cache based on eviction speed, rather than actual
demand for cache.
    
This series solves the problem by maintaining a history of pages
evicted from the inactive list, enabling the VM to detect frequently
used pages regardless of inactive list size and facilitate working set
transitions.

	Tests

The reported database workload is easily demonstrated on a 8G machine
with two filesets a 6G.  This fio workload operates on one set first,
then switches to the other.  The VM should obviously always cache the
set that the workload is currently using.

This test is based on a problem encountered by Citus Data customers:
http://citusdata.com/blog/72-linux-memory-manager-and-your-big-data

unpatched:
db1: READ: io=98304MB, aggrb=885559KB/s, minb=885559KB/s, maxb=885559KB/s, mint= 113672msec, maxt= 113672msec
db2: READ: io=98304MB, aggrb= 66169KB/s, minb= 66169KB/s, maxb= 66169KB/s, mint=1521302msec, maxt=1521302msec
sdb: ios=835750/4, merge=2/1, ticks=4659739/60016, in_queue=4719203, util=98.92%

real    27m15.541s
user    0m19.059s
sys     0m51.459s

patched:
db1: READ: io=98304MB, aggrb=877783KB/s, minb=877783KB/s, maxb=877783KB/s, mint=114679msec, maxt=114679msec
db2: READ: io=98304MB, aggrb=397449KB/s, minb=397449KB/s, maxb=397449KB/s, mint=253273msec, maxt=253273msec
sdb: ios=170587/4, merge=2/1, ticks=954910/61123, in_queue=1015923, util=90.40%

real    6m8.630s
user    0m14.714s
sys     0m31.233s

As can be seen, the unpatched kernel simply never adapts to the
workingset change and db2 is stuck indefinitely with secondary storage
speed.  The patched kernel needs 2-3 iterations over db2 before it
replaces db1 and reaches full memory speed.  Given the unbounded
negative affect of the existing VM behavior, these patches should be
considered correctness fixes rather than performance optimizations.

Another test resembles a fileserver or streaming server workload,
where data in excess of memory size is accessed at different
frequencies.  There is very hot data accessed at a high frequency.
Machines should be fitted so that the hot set of such a workload can
be fully cached or all bets are off.  Then there is a very big
(compared to available memory) set of data that is used-once or at a
very low frequency; this is what drives the inactive list and does not
really benefit from caching.  Lastly, there is a big set of warm data
in between that is accessed at medium frequencies and benefits from
caching the pages between the first and last streamer of each burst.

unpatched:
 hot: READ: io=128000MB, aggrb=160693KB/s, minb=160693KB/s, maxb=160693KB/s, mint=815665msec, maxt=815665msec
warm: READ: io= 81920MB, aggrb=109853KB/s, minb= 27463KB/s, maxb= 29244KB/s, mint=717110msec, maxt=763617msec
cold: READ: io= 30720MB, aggrb= 35245KB/s, minb= 35245KB/s, maxb= 35245KB/s, mint=892530msec, maxt=892530msec
 sdb: ios=797960/4, merge=11763/1, ticks=4307910/796, in_queue=4308380, util=100.00%

patched:
 hot: READ: io=128000MB, aggrb=160678KB/s, minb=160678KB/s, maxb=160678KB/s, mint=815740msec, maxt=815740msec
warm: READ: io= 81920MB, aggrb=147747KB/s, minb= 36936KB/s, maxb= 40960KB/s, mint=512000msec, maxt=567767msec
cold: READ: io= 30720MB, aggrb= 40960KB/s, minb= 40960KB/s, maxb= 40960KB/s, mint=768000msec, maxt=768000msec
 sdb: ios=596514/4, merge=9341/1, ticks=2395362/997, in_queue=2396484, util=79.18%

In both kernels, the hot set is propagated to the active list and then
served from cache.

In both kernels, the beginning of the warm set is propagated to the
active list as well, but in the unpatched case the active list
eventually takes up half of memory and no new pages from the warm set
get activated, despite repeated access, and despite most of the active
list soon being stale.  The patched kernel on the other hand detects
the thrashing and manages to keep this cache window rolling through
the data set.  This frees up enough IO bandwidth that the cold set is
served at full speed as well and disk utilization even drops by 20%.

For reference, this same test was performed with the traditional
demotion mechanism, where deactivation is coupled to inactive list
reclaim.  However, this had the same outcome as the unpatched kernel:
while the warm set does indeed get activated continuously, it is
forced out of the active list by inactive list pressure, which is
dictated primarily by the unrelated cold set.  The warm set is evicted
before subsequent streamers can benefit from it, even though there
would be enough space available to cache the pages of interest.

	Costs

Page reclaim used to shrink the radix trees but now the tree nodes are
reused for shadow entries, where the cost depends heavily on the page
cache access patterns.  However, with workloads that maintain spatial
or temporal locality, the shadow entries are either refaulted quickly
or reclaimed along with the inode object itself.  Workloads that will
experience a memory cost increase are those that don't really benefit
from caching in the first place.

A more predictable alternative would be a fixed-cost separate pool of
shadow entries, but this would incur relatively higher memory cost for
well-behaved workloads at the benefit of cornercases.  It would also
make the shadow entry lookup more costly compared to storing them
directly in the cache structure.

	Future

To simplify the merging process, this patch set is implementing thrash
detection on a global per-zone level only for now, but the design is
such that it can be extended to memory cgroups as well.  All we need
to do is store the unique cgroup ID along the node and zone identifier
inside the eviction cookie to identify the lruvec.

Right now we have a fixed ratio (50:50) between inactive and active
list but we already have complaints about working sets exceeding half
of memory being pushed out of the cache by simple streaming in the
background.  Ultimately, we want to adjust this ratio and allow for a
much smaller inactive list.  These patches are an essential step in
this direction because they decouple the VMs ability to detect working
set changes from the inactive list size.  This would allow us to base
the inactive list size on the combined readahead window size for
example and potentially protect a much bigger working set.

It's also a big step towards activating pages with a reuse distance
larger than memory, as long as they are the most frequently used pages
in the workload.  This will require knowing more about the access
frequency of active pages than what we measure right now, so it's also
deferred in this series.

Another possibility of having thrashing information would be to
revisit the idea of local reclaim in the form of zero-config memory
control groups.  Instead of having allocating tasks go straight to
global reclaim, they could try to reclaim the pages in the memcg they
are part of first as long as the group is not thrashing.  This would
allow a user to drop e.g. a back-up job in an otherwise unconfigured
memcg and it would only inflate (and possibly do global reclaim) until
it has enough memory to do proper readahead.  But once it reaches that
point and stops thrashing it would just recycle its own used-once
pages without kicking out the cache of any other tasks in the system
more than necessary.

 Documentation/filesystems/porting               |   6 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c |   2 +-
 fs/9p/vfs_inode.c                               |   2 +-
 fs/affs/inode.c                                 |   2 +-
 fs/afs/inode.c                                  |   2 +-
 fs/bfs/inode.c                                  |   2 +-
 fs/block_dev.c                                  |   4 +-
 fs/btrfs/compression.c                          |   2 +-
 fs/btrfs/inode.c                                |   2 +-
 fs/cachefiles/rdwr.c                            |  33 +-
 fs/cifs/cifsfs.c                                |   2 +-
 fs/coda/inode.c                                 |   2 +-
 fs/ecryptfs/super.c                             |   2 +-
 fs/exofs/inode.c                                |   2 +-
 fs/ext2/inode.c                                 |   2 +-
 fs/ext3/inode.c                                 |   2 +-
 fs/ext4/inode.c                                 |   4 +-
 fs/f2fs/inode.c                                 |   2 +-
 fs/fat/inode.c                                  |   2 +-
 fs/freevxfs/vxfs_inode.c                        |   2 +-
 fs/fuse/inode.c                                 |   2 +-
 fs/gfs2/super.c                                 |   2 +-
 fs/hfs/inode.c                                  |   2 +-
 fs/hfsplus/super.c                              |   2 +-
 fs/hostfs/hostfs_kern.c                         |   2 +-
 fs/hpfs/inode.c                                 |   2 +-
 fs/inode.c                                      |   4 +-
 fs/jffs2/fs.c                                   |   2 +-
 fs/jfs/inode.c                                  |   4 +-
 fs/kernfs/inode.c                               |   2 +-
 fs/logfs/readwrite.c                            |   2 +-
 fs/minix/inode.c                                |   2 +-
 fs/ncpfs/inode.c                                |   2 +-
 fs/nfs/blocklayout/blocklayout.c                |   2 +-
 fs/nfs/inode.c                                  |   2 +-
 fs/nfs/nfs4super.c                              |   2 +-
 fs/nilfs2/inode.c                               |   6 +-
 fs/ntfs/inode.c                                 |   2 +-
 fs/ocfs2/inode.c                                |   4 +-
 fs/omfs/inode.c                                 |   2 +-
 fs/proc/inode.c                                 |   2 +-
 fs/reiserfs/inode.c                             |   2 +-
 fs/sysv/inode.c                                 |   2 +-
 fs/ubifs/super.c                                |   2 +-
 fs/udf/inode.c                                  |   4 +-
 fs/ufs/inode.c                                  |   2 +-
 fs/xfs/xfs_super.c                              |   2 +-
 include/linux/fs.h                              |   1 +
 include/linux/list_lru.h                        |   2 +
 include/linux/mm.h                              |   9 +
 include/linux/mmzone.h                          |   6 +
 include/linux/pagemap.h                         |  33 +-
 include/linux/pagevec.h                         |   3 +
 include/linux/radix-tree.h                      |  55 ++-
 include/linux/shmem_fs.h                        |   1 +
 include/linux/swap.h                            |  36 ++
 include/linux/vmstat.h                          |  29 +-
 lib/radix-tree.c                                | 383 ++++++++++----------
 mm/Makefile                                     |   2 +-
 mm/filemap.c                                    | 417 +++++++++++++++++++---
 mm/list_lru.c                                   |  10 +
 mm/mincore.c                                    |  20 +-
 mm/readahead.c                                  |   6 +-
 mm/shmem.c                                      | 122 ++-----
 mm/swap.c                                       |  50 +++
 mm/truncate.c                                   | 147 +++++++-
 mm/vmscan.c                                     |  24 +-
 mm/vmstat.c                                     |   3 +
 mm/workingset.c                                 | 396 ++++++++++++++++++++
 69 files changed, 1438 insertions(+), 462 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
