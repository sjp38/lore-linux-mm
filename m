From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC 00/26] Slab defragmentation V5
Date: Fri, 31 Aug 2007 18:41:07 -0700
Message-ID: <20070901014107.719506437@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-Id: linux-mm.kvack.org

Slab defragmentation is mainly an issue if Linux is used as a fileserver
and large amounts of dentries, inodes and buffer heads accumulate. In some
load situations the slabs become very sparsely populated so that a lot of
memory is wasted by slabs that only contain one or a few objects. In
extreme cases the performance of a machine will become sluggish since
we are continually running reclaim. Slab defragmentation adds the
capability to recover wasted memory.

For lumpy reclaim slab defragmentation can be used to enhance the
ability to recover larger contiguous areas of memory. Lumpy reclaim currently
cannot do anything if a slab page is encountered. With slab defragmentation
that slab page can be removed and a large contiguous page freed. It may
be possible to have slab pages also part of ZONE_MOVABLE (Mel's defrag
scheme in 2.6.23) or the MOVABLE areas (antifrag patches in mm).

The trouble with this patchset is that it is difficult to validate.
Activities are only performed when special load situations are encountered.
Are there any tests that could give meaningful information about
the effectiveness of these measures? I have run various tests here
creating and deleting files and building kernels under low memory situations
to trigger these reclaim mechanisms but how does one measure their
effectiveness?

The patchset is also available via git

git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git defrag


We currently support the following types of reclaim:

1. dentry cache
2. inode cache (with a generic interface to allow easy setup of more
   filesystems than the currently supported ext2/3/4 reiserfs, XFS
   and proc)
3. buffer_head

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
