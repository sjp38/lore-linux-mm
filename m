Message-Id: <20071114220906.206294426@sgi.com>
Date: Wed, 14 Nov 2007 14:09:06 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/17] Slab defragmentation V7
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Slab defragmentation is mainly an issue if Linux is used as a fileserver
and large amounts of dentries, inodes and buffer heads accumulate. In some
load situations the slabs become very sparsely populated so that a lot of
memory is wasted by slabs that only contain one or a few objects. In
extreme cases the performance of a machine will become sluggish since
we are continually running reclaim. Slab defragmentation adds the
capability to recover the memory that is wasted.

Memory reclaim from the following slab caches is possible:

1. dentry cache
2. inode cache (with a generic interface to allow easy setup of more
   filesystems than the currently supported ext2/3/4 reiserfs, XFS
   and proc)
3. buffer_heads

One typical mechanism that triggers slab defragmentation on my systems
is the daily run of

	updatedb

Updatedb scans all files on the system which causes a high inode and dentry
use. After updatedb is complete we need to go back to the regular use
patterns (typical on my machine: kernel compiles). Those need the memory now
for different purposes. The inodes and dentries used for updatedb will
gradually be aged by the dentry/inode reclaim algorithm which will free
up the dentries and inode entries randomly through the slabs that were
allocated. As a result the slabs will become sparsely populated. If they
become empty then they can be freed but a lot of them will remain sparsely
populated. That is where slab defrag comes in: It removes the objects from
the slabs with just a few entries reclaiming more memory for other uses.
In the simplest case (as provided here) this is done by simply reclaiming
the objects. However, if the logic in the kick() function is made more
sophisticated then we will be able to move the objects out of the slabs.

V6->V7
- Rediff against 2.6.24-rc2-mm1
- Remove lumpy reclaim support. No point anymore given that the antifrag
  handling in 2.6.24-rc2 puts reclaimable slabs into different sections.
  Targeted reclaim never triggers. This has to wait until we make
  slabs movable or we need to perform a special version of lumpy reclaim
  in SLUB while we scan the partial lists for slabs to kick out.
  Removal simplifies handling significantly since we
  get to slabs in a more controlled way via the partial lists.
  The patchset now provides pure reduction of fragmentation levels.
- SLAB/SLOB: Provide inlines that do nothing
- Fix various smaller issues that were brought up during review of V6.

V5->V6
- Rediff against 2.6.24-rc2 + mm slub patches.
- Add reviewed by lines.
- Take out the experimental code to make slab pages movable. That
  has to wait until this has been considered by Mel.

V4->V5:
- Support lumpy reclaim for slabs
- Support reclaim via slab_shrink()
- Add constructors to insure a consistent object state at all times.

V3->V4:
- Optimize scan for slabs that need defragmentation
- Add /sys/slab/*/defrag_ratio to allow setting defrag limits
  per slab.
- Add support for buffer heads.
- Describe how the cleanup after the daily updatedb can be
  improved by slab defragmentation.

V2->V3
- Support directory reclaim
- Add infrastructure to trigger defragmentation after slab shrinking if we
  have slabs with a high degree of fragmentation.

V1->V2
- Clean up control flow using a state variable. Simplify API. Back to 2
  functions that now take arrays of objects.
- Inode defrag support for a set of filesystems
- Fix up dentry defrag support to work on negative dentries by adding
  a new dentry flag that indicates that a dentry is not in the process
  of being freed or allocated.

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
