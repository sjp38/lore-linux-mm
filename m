Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2366B003D
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 18:39:26 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so1588176bkb.6
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 15:39:25 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id oj6si8748826bkb.174.2013.11.24.15.39.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 15:39:25 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/9] mm: thrash detection-based file cache sizing v6
Date: Sun, 24 Nov 2013 18:38:19 -0500
Message-Id: <1385336308-27121-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

	Changes in this revision:

o Based on suggestions from Dave Chinner and Rik van Riel, rework the
  shadow entry reclaim to directly track and scan radix tree nodes
  containing only shadows instead of operating on an inode level.
  This adds one word to the address space (thus inode) and two words
  to the radix_tree_node, but the number of objects per slab remains
  unchanged in both cases.  The shrinker no longer needs to scan radix
  trees but can just walk the list of immediately reclaimable nodes.

[ Dave, I looked into getting rid of the AS_EXITING flag but since
  reclaim can't participate in inode lifetime management (no iput in
  NOFS context), the fs somehow needs to communicate the final
  truncate so that reclaim can stop putting shadow entries into the
  tree.  We can't detect it in the truncate call, unless we modify the
  API to carry that bit of information, and switch every filesystem
  over to the new truncate, but at that point we might as well just
  leave the AS_EXITING setting in one place in the vfs code with a
  comment; it seems less error prone.

  In the last revision, it seems you were mostly thrown by the dumb
  shrinker linking every inode, thus increasing the inode footprint
  massively.  All inode involvement is gone now, maybe you won't hate
  the address space flag as much anymore after a fresh look... ]

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

The reported database workload is easily demonstrated on an 8G machine
with two filesets a 6G.  This fio workload operates on one set first,
then switches to the other.  The VM should obviously always cache the
set that the workload is currently using.

unpatched:
db1: READ: io=98304MB, aggrb=803577KB/s, minb=803577KB/s, maxb=803577KB/s, mint= 125269msec, maxt= 125269msec
db2: READ: io=98304MB, aggrb= 65610KB/s, minb= 65610KB/s, maxb= 65610KB/s, mint=1534266msec, maxt=1534266msec
sdb: ios=835729/7, merge=4/2, ticks=4620185/318869, in_queue=4938281, util=98.33%

real    27m40.094s
user    0m20.017s
sys     1m35.293s

patched:
db1: READ: io=98304MB, aggrb=796954KB/s, minb=796954KB/s, maxb=796954KB/s, mint=126310msec, maxt=126310msec
db2: READ: io=98304MB, aggrb=376076KB/s, minb=376076KB/s, maxb=376076KB/s, mint=267667msec, maxt=267667msec
sdb: ios=170660/4, merge=2/1, ticks=956451/62623, in_queue=1018896, util=86.23%

real    6m34.717s
user    0m17.120s
sys     0m54.790s

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
 hot: READ: io=128000MB, aggrb=160534KB/s, minb=160534KB/s, maxb=160534KB/s, mint=816470msec, maxt=816470msec
warm: READ: io= 81920MB, aggrb=109290KB/s, minb= 27322KB/s, maxb= 29199KB/s, mint=718211msec, maxt=767549msec
cold: READ: io= 30720MB, aggrb= 35230KB/s, minb= 35230KB/s, maxb= 35230KB/s, mint=892894msec, maxt=892894msec
 sdb: ios=796569/4, merge=11772/1, ticks=4288174/988, in_queue=4288609, util=100.00%

patched:
 hot: READ: io=128000MB, aggrb=160628KB/s, minb=160628KB/s, maxb=160628KB/s, mint=815995msec, maxt=815995msec
warm: READ: io= 81920MB, aggrb=149706KB/s, minb= 37426KB/s, maxb= 40960KB/s, mint=512000msec, maxt=560338msec
cold: READ: io= 30720MB, aggrb= 40960KB/s, minb= 40960KB/s, maxb= 40960KB/s, mint=768000msec, maxt=768000msec
 sdb: ios=584920/4, merge=8399/1, ticks=2279529/961, in_queue=2280425, util=77.89%

In both kernels, the hot set is propagated to the active list and then
served from cache.

In both kernels, the beginning of the warm set is propagated to the
active list as well, but in the unpatched case the active list
eventually takes up half of memory and no new pages from the warm set
get activated, despite repeated access, and despite most of the active
list soon being stale.  The patched kernel on the other hand detects
the thrashing and manages to keep this cache window rolling through
the data set.  This frees up enough IO bandwidth that the cold set is
served at full speed as well and disk utilization drops by a quarter.

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

The additional cost to page cache insertions and deletions is small
and only measurable in microbenchmarks without actual IO.

	Future

Right now we have a fixed ratio (50:50) between inactive and active
list but we already have complaints about working sets exceeding half
of memory being pushed out of the cache by simple streaming in the
background.  Ultimately, we want to adjust this ratio and allow for a
much smaller inactive list.  These patches are an essential step in
this direction because they decouple the VMs ability to detect working
set changes from the inactive list size.  This would allow us to base
the inactive list size on the combined readahead window size for
example and potentially protect a much bigger working set.

Another possibility of having thrashing information would be to
revisit the idea of local reclaim in the form of zero-config memory
control groups.  Instead of having allocating tasks go straight to
global reclaim, they could try to reclaim the pages in the memcg they
are part of first, as long as the group is not thrashing.  This would
allow a user to drop e.g. a back-up job in an otherwise unconfigured
memcg and it would only inflate (and possibly do global reclaim) until
it has enough memory to do proper readahead.  But once it reaches that
point and stops thrashing it would just recycle its own used-once
pages without kicking out the cache of any other tasks in the system
more than necessary.

Thanks!

 fs/block_dev.c                   |   2 +-
 fs/btrfs/compression.c           |   2 +-
 fs/cachefiles/rdwr.c             |  33 ++--
 fs/inode.c                       |  18 +-
 fs/nfs/blocklayout/blocklayout.c |   2 +-
 fs/nilfs2/inode.c                |   4 +-
 fs/super.c                       |   4 +-
 fs/xfs/xfs_buf.c                 |   2 +-
 fs/xfs/xfs_qm.c                  |   2 +-
 include/linux/fs.h               |   1 +
 include/linux/list_lru.h         |   2 +-
 include/linux/mm.h               |   8 +
 include/linux/mmzone.h           |   5 +
 include/linux/pagemap.h          |  33 +++-
 include/linux/pagevec.h          |   3 +
 include/linux/radix-tree.h       |  53 ++++-
 include/linux/shmem_fs.h         |   1 +
 include/linux/swap.h             |   6 +
 include/linux/vm_event_item.h    |   1 +
 lib/radix-tree.c                 | 383 ++++++++++++++++++------------------
 mm/Makefile                      |   2 +-
 mm/filemap.c                     | 388 +++++++++++++++++++++++++++++++++----
 mm/list_lru.c                    |   4 +-
 mm/mincore.c                     |  20 +-
 mm/readahead.c                   |   6 +-
 mm/shmem.c                       | 122 +++---------
 mm/swap.c                        |  49 +++++
 mm/truncate.c                    |  93 +++++++--
 mm/vmscan.c                      |  24 ++-
 mm/vmstat.c                      |   4 +
 mm/workingset.c                  | 377 +++++++++++++++++++++++++++++++++++
 31 files changed, 1253 insertions(+), 401 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
