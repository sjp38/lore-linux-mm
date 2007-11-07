From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/23] Slab defragmentation V6
Date: Tue, 06 Nov 2007 17:11:30 -0800
Message-ID: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756148AbXKGBMp@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

Slab defragmentation is mainly an issue if Linux is used as a fileserver
and large amounts of dentries, inodes and buffer heads accumulate. In some
load situations the slabs become very sparsely populated so that a lot of
memory is wasted by slabs that only contain one or a few objects. In
extreme cases the performance of a machine will become sluggish since
we are continually running reclaim. Slab defragmentation adds the
capability to recover wasted memory.

With lumpy reclaim slab defragmentation can be used to enhance the
ability to recover larger contiguous areas of memory. Lumpy reclaim currently
cannot do anything if a slab page is encountered. With slab defragmentation
that slab page can be removed and a large contiguous page freed. It may
be possible to have slab pages also part of ZONE_MOVABLE (Mel's defrag
scheme in 2.6.23) or the MOVABLE areas (antifrag patches in mm).

The patchset is also available via git

git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git defrag


Currently memory reclaim from the following slab caches is possible:

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
populated. That is where slab defrag comes in: It removes the slabs with
just a few entries reclaiming more memory for other uses.

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
