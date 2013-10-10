From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/8] mm: thrash detection-based file cache sizing v5
Date: Thu, 10 Oct 2013 17:46:54 -0400
Message-ID: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

Hi everyone,

here is an update to the cache sizing patches for 3.13.

	Changes in this revision

o Drop frequency synchronization between refaulted and demoted pages
  and just straight up activate refaulting pages whose access
  frequency indicates they could stay in memory.  This was suggested
  by Rik van Riel a looong time ago but misinterpretation of test
  results during early stages of development took me a while to
  overcome.  It's still the same overall concept, but a little simpler
  and with even faster cache adaptation.  Yay!

o More extensively document underlying design concepts like the
  meaning of the refault distance, based on input from Andrew and
  Tejun.

o Document the new page cache lookup API which can return shadow
  entries, based on input from Andrew

o Document and simplify the synchronization between inode teardown and
  reclaim planting shadow entries, based on input from Andrew

o Drop 'time' from names of variables that are not in typical kernel
  time units like jiffies or seconds, based on input from Andrew

	Summary of problem & solution

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
used pages regardless of inactive list size and so facilitate working
set transitions in excess of the inactive list.

	Tests
	
The reported database workload is easily demonstrated on a 16G machine
with two filesets a 12G.  This fio workload operates on one set first,
then switches to the other.  The VM should obviously always cache the
set that the workload is currently using.

unpatched:
db1: READ: io=196608MB, aggrb=740405KB/s, minb=740405KB/s, maxb=740405KB/s, mint= 271914msec, maxt= 271914msec
db2: READ: io=196608MB, aggrb= 68558KB/s, minb= 68558KB/s, maxb= 68558KB/s, mint=2936584msec, maxt=2936584msec

real    53m29.192s
user    1m11.544s
sys     3m34.820s

patched:
db1: READ: io=196608MB, aggrb=743750KB/s, minb=743750KB/s, maxb=743750KB/s, mint=270691msec, maxt=270691msec
db2: READ: io=196608MB, aggrb=383503KB/s, minb=383503KB/s, maxb=383503KB/s, mint=524967msec, maxt=524967msec

real    13m16.432s
user    0m56.518s
sys     2m38.284s

As can be seen, the unpatched kernel simply never adapts to the
workingset change and db2 is stuck with secondary storage speed.  The
patched kernel on the other hand needs 2-3 iterations over db2 before
it replaces db1 and reaches full memory speed.  Given the unbounded
negative affect of the existing VM behavior, these patches should be
considered correctness fixes rather than performance optimizations.

Another test resembles a fileserver or streaming server workload,
where data in excess of memory size is accessed at different
frequencies.  First, there is very hot data accessed at a high
frequency.  Machines should be fitted so that the hot set of such a
workload can be fully cached or all bets are off.  Then there is a
very big (compared to available memory) set of data that is used-once
or at a very low frequency; this is what drives the inactive list and
does not really benefit from caching.  Lastly, there is a big set of
warm data in between that is accessed at medium frequencies and would
benefit from caching the pages between the first and last streamer of
each burst as much as possible.

unpatched:
cold: READ: io= 30720MB, aggrb= 24808KB/s, minb= 24808KB/s, maxb= 24808KB/s, mint=1267987msec, maxt=1267987msec
 hot: READ: io=174080MB, aggrb=158225KB/s, minb=158225KB/s, maxb=158225KB/s, mint=1126605msec, maxt=1126605msec
warm: READ: io=102400MB, aggrb=112403KB/s, minb= 22480KB/s, maxb= 33010KB/s, mint= 635291msec, maxt= 932866msec

real    21m15.924s
user    17m36.036s
sys     3m5.117s

patched:
cold: READ: io= 30720MB, aggrb= 27451KB/s, minb= 27451KB/s, maxb= 27451KB/s, mint=1145932msec, maxt=1145932msec
 hot: READ: io=174080MB, aggrb=158617KB/s, minb=158617KB/s, maxb=158617KB/s, mint=1123822msec, maxt=1123822msec
warm: READ: io=102400MB, aggrb=131964KB/s, minb= 26392KB/s, maxb= 40164KB/s, mint= 522141msec, maxt= 794592msec

real    19m22.671s
user    19m33.838s
sys     2m39.652s

In both kernels, the hot set is propagated to the active list and then
served from cache for the duration of the workload.

In both kernels, the beginning of the warm set is propagated to the
active list as well, but in the unpatched case the active list
eventually takes up half of memory and does not leave enough space
anymore for many new warm pages to get activated and so they start
thrashing while a significant part of the active list is now stale.
The patched kernel on the other hand constantly challenges the active
pages based on refaults and so manages to keep a cache window rolling
through the warm data set.  This frees up IO bandwidth for the cold
set as well.

For reference, this same test was performed with the traditional
demotion mechanism, where deactivation is coupled to inactive list
reclaim.  However, this had the same outcome as the unpatched kernel:
while the warm set does indeed get activated continuously, it is
forced out of the active list by inactive list pressure, which is
dictated primarily by the unrelated cold set.  The warm set is evicted
before subsequent streamers can benefit from it, even though there
would be enough space available to cache the pages of interest.

	Costs

These patches increase struct inode by three words to manage shadow
entries in the page cache radix tree.  However, given that a typical
inode (like the ext4 inode) is already 1k in size, this is not much.
It's a 2% size increase for a reclaimable object.  fs_mark metadata
tests with millions of inodes did not show a measurable difference.
And as soon as there is any file data involved, the page cache pages
dominate the memory cost anyway.

A much harder cost to estimate is the size of the page cache radix
tree.  Page reclaim used to shrink the radix trees but now the tree
nodes are reused for shadow entries, and so the cost depends heavily
on the page cache access patterns.  However, with workloads that
maintain spatial or temporal locality, the shadow entries are either
refaulted quickly or reclaimed along with the inode object itself.
Workloads that will experience a memory cost increase are those that
don't really benefit from caching in the first place.

A more predictable alternative would be a fixed-cost separate pool of
shadow entries, but this would incur relatively higher memory cost for
well-behaved workloads at the benefit of cornercases.  It would also
make the shadow entry lookup more costly compared to storing them
directly in the cache structure.

The biggest impact on the existing VM fastpaths is an extra branch in
page cache lookups to filter out shadow entries.  shmem already has
this check, though, since it stores swap entries alongside regular
pages inside its page cache radix trees.

	Future

Right now we have a fixed ratio (50:50) between inactive and active
list but we already have complaints about working sets exceeding half
of memory being pushed out of the cache by simple used-once streaming
in the background.  Ultimately, we want to adjust this ratio and allow
for a much smaller inactive list.  These patches are an essential step
in this direction because they decouple the VMs ability to detect
working set changes from the inactive list size.  This would allow us
to base the inactive list size on something more sensible, like the
combined readahead window size for example.

Please consider merging.  Thank you!

 fs/block_dev.c                   |   2 +-
 fs/btrfs/compression.c           |   2 +-
 fs/cachefiles/rdwr.c             |  33 +--
 fs/inode.c                       |  11 +-
 fs/nfs/blocklayout/blocklayout.c |   2 +-
 fs/nilfs2/inode.c                |   4 +-
 include/linux/fs.h               |   2 +
 include/linux/mm.h               |   8 +
 include/linux/mmzone.h           |   6 +
 include/linux/pagemap.h          |  33 ++-
 include/linux/pagevec.h          |   3 +
 include/linux/radix-tree.h       |   5 +-
 include/linux/shmem_fs.h         |   1 +
 include/linux/swap.h             |   9 +
 include/linux/writeback.h        |   1 +
 lib/radix-tree.c                 | 106 ++------
 mm/Makefile                      |   2 +-
 mm/filemap.c                     | 335 +++++++++++++++++++++---
 mm/mincore.c                     |  20 +-
 mm/page-writeback.c              |   2 +-
 mm/readahead.c                   |   6 +-
 mm/shmem.c                       | 122 +++------
 mm/swap.c                        |  49 ++++
 mm/truncate.c                    |  78 ++++--
 mm/vmscan.c                      |  24 +-
 mm/vmstat.c                      |   3 +
 mm/workingset.c                  | 506 +++++++++++++++++++++++++++++++++++++
