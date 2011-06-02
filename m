Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C404F6B0078
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:23 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 0/12] Per superblock cache reclaim
Date: Thu,  2 Jun 2011 17:00:55 +1000
Message-Id: <1306998067-27659-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

This series converts the VFS cache shrinkers to a per-superblock
shrinker, and provides a callout from the superblock shrinker to
allow the filesystem to shrink internal caches proportionally to the
amount of reclaim done to the VFS caches.

The motivation for this work is that the VFS caches are dependent
caches - dentries pin inodes, and inodes often pin other filesystem
specific structures.  The caches can grow quite large and it is easy
for them to get unbalanced when they are shrunk independently.

Reclaim is also focussed on sharing reclaim batches across all
superblocks rather than within a superblock, so often reclaim calls
only remove a few objects from each superblock at a time. This means
that we touch lots of superblocks and LRUs one every shrinker call,
and we have to traverse the superblock list all the time.

This leads to life-cycle issues - we have to ensure that the
superblock we are trying to work on is active and won't go away, and
also ensure that the unmount process synchronises correctly with
active shrinkers. This is complex and the locks involved cause
issues with lockdep refularly reporting false positive lock
inversions.

Firstly, however, there are several longstanding bugs in the
VM shrinker infrastructure that need to be fixed. Firstly, we need
to add tracepoints so we can observe the behaviour of the shrinker
calculations. Secondly, the shrinker scan calculations are not SMP
safe and that is causing shrinkers to either miss work they should
be doing, or doing a lot more work than they should.

With these fixes in place, I found the reason that I was not able to
balance system behaviour on my first attempt at per-sb shrinkers.
When a shrinker repeatedly returns "-1" to avoid deadlocks, like
will happen when a filesystem is doing GFP_NOFS memory allocations
during transactions (and that happens *a lot* during filesystem
intensive workloads), then the work is delayed by adding it to
shrinker->nr for the next shrinker call to do.

This causes the shrinker->nr to increase until it is 2x the number
of objects in the cache, and so when the shrinker is finally able to
do work, it is effectively told to shrink the entire cache to zero.
Twice over. You'll never guess how I found it - the tracepoints I
added, perhaps? This problem is fixed by only allowing the
shrinker->nr to wind up to half the size of the cache when there are
lots of little additions caused by deadlock avoidance. This is
sufficient to maintain current levels of performance whilst avoiding
the cache trashing problem.

So, back to the VFS cache shrinkers.  To avoid all the above
problems, we can use the per-shrinker context infrastructure that
was introduced recently for XFS. By adding a shrinker context to
each superblock and registering the shrinker after the superblock is
created and unregistering it early in the unmount process we avoid
the need for specific unmount synchronisation between the shrinker
and the unmount process.  Goodbye iprune_sem.

Further, by having per-superblock shrinker callouts, we no longer
need to walk the superblock list on every shrinker call for both the
dentry and inode caches, nor do we need to proportion reclaim
between superblocks. That simplifies the cache shrinking
implementation significantly.

However, to take advantage of this, the first thing we need to do is
convert the inode cache LRU to a per-superblock LRU. This is trivial
to do - it's just a copy of the dentry cache infrastructure. The
inode cache LRU can also be trivially converted to a lock per
superblock as well, so that is done at the same time.

[ Note that it looks like the same change can be made to the dentry
cache LRU, but the simple conversion from the global dcache_lru_lock
to per-sb locks results in occasional, strange ENOENT errors during
path lookups. So that patch is on hold. ]

With a single shrinker - prune_super() - that can address both  the
per-sb dentry and inode LRUs, it is a simple matter of proportioning
the reclaim batch between them. This is done simply by the ratio of
objects in the two caches, and the dentry cache is pruned first so
that it unpins inodes before the inode cache is pruned.

Now that we have prune_super(), reclaiming hundreds of
thousands or millions of dentries and inodes in batches of 128
objects does not make much sense. The VM shrinker infrastructure
uses a batch size of 128 so that it can regularly reschedule if
necessary. The dentry cache pruner already has reschedule checks,
and it is trivial to add them to the VFS and XFS inode cache
pruners. With that done, there is no reason why we can't use a much
larger reclaim batch size and remove more objects from each cache on
each visit to them.

To do this, add a per-shrinker batch size configuration field, and
configure prune_super() to use a larger batch size of 1024
objects. This reduces the number of times we need to make
calculations, traffic locks and structures, and means we spend more
time in cache specific loops than we would with a smaller batch
size. This reduces the overhead of cache shrinking.

Overall, the changes result in steady state cache ratios on XFS,
ext4 and btrfs of 1 dentry : 3 inodes. The state ratio is 1 inused
inode : 2 free inodes (the in-use inode is pinned by the dentry).
The following chart demonstrateN? ext4 (left) and btrfs (right) cache
ratios under steady state 8-way file creation conditions.

http://userweb.kernel.org/~dgc/shrinker/ext4-btrfs-cache-ratio.png

For XFS, however, the situation is slightly more complex. XFS
maintains it's own inode cache (the VFS inode cache is a subset of
the XFS cache), and so needs to be able to keep that synchronised
with the VFS caches. Hence a filesystem specific callout is added
to the superblock pruning method that is proportioned with the
VFS dentry and inode caches. Implementing these methods is optional,
and this is done for XFS in the last patch in the series.

XFS behaviour at different stages of the patch series can be seen in
the following chart:

http://userweb.kernel.org/~dgc/shrinker/per-sb-shrinker-comparison.png

The left-most traces are from a kernel with just the VM
shrink_slab() fixes. The middle trace is the same 8-way create
workload, but with the inode cache LRU changes and the per-sb
superblock shrinker addressing just the VFS dentry and inode
caches. The right-most (partial) workload trace is the full series
with the XFS inode cache shrinker being called from prune_super().

You can see from the top chart that the cache behaviour has much
less variance in the middle trace with the per-sb shrinkers compared
to the left-most trace. Also, you can see that the XFS inode cache
size follows the VFS inode cache residency much more closely in the
right-most trace as a result of using the prune_super() filesystem
callout.

Yes, these XFS traces are much more variable that the ext4 and btrfs
charts, but XFS is putting significantly more pressure on the caches
and most allocations are GFP_NOFS, hence triggering the wind-up
problems described above. It is, however, much better behaved than
the existing shrinker behaviour (worse than the left-most trace with
the VM fixes) and much better than the previous (aborted) per-sb
shrinker attempts:

http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc4-per-sb-basic-16x500-xfs.png
http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc4-per-sb-balance-16x500-xfs.png
http://userweb.kernel.org/~dgc/shrinker-2.6.36/fs_mark-2.6.35-rc4-per-sb-proportional-16x500-xfs.png

---

The following changes since commit c7427d23f7ed695ac226dbe3a84d7f19091d34ce:

  autofs4: bogus dentry_unhash() added in ->unlink() (2011-05-30 01:50:53 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/people/dgc/xfsdev.git per-sb-shrinker

Dave Chinner (12):
      vmscan: add shrink_slab tracepoints
      vmscan: shrinker->nr updates race and go wrong
      vmscan: reduce wind up shrinker->nr when shrinker can't do work
      vmscan: add customisable shrinker batch size
      inode: convert inode_stat.nr_unused to per-cpu counters
      inode: Make unused inode LRU per superblock
      inode: move to per-sb LRU locks
      superblock: introduce per-sb cache shrinker infrastructure
      inode: remove iprune_sem
      superblock: add filesystem shrinker operations
      vfs: increase shrinker batch size
      xfs: make use of new shrinker callout for the inode cache

 Documentation/filesystems/vfs.txt |   21 ++++++
 fs/dcache.c                       |  121 ++++--------------------------------
 fs/inode.c                        |  124 ++++++++++++-------------------------
 fs/super.c                        |   79 +++++++++++++++++++++++-
 fs/xfs/linux-2.6/xfs_super.c      |   26 +++++---
 fs/xfs/linux-2.6/xfs_sync.c       |   71 ++++++++-------------
 fs/xfs/linux-2.6/xfs_sync.h       |    5 +-
 include/linux/fs.h                |   14 ++++
 include/linux/mm.h                |    1 +
 include/trace/events/vmscan.h     |   71 +++++++++++++++++++++
 mm/vmscan.c                       |   70 ++++++++++++++++-----
 11 files changed, 337 insertions(+), 266 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
