Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EBC5E6B01F2
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 18:31:28 -0400 (EDT)
Date: Mon, 30 Aug 2010 15:30:03 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH V4 0/8] Cleancache: overview
Message-ID: <20100830223003.GA1196@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com
List-ID: <linux-mm.kvack.org>

[PATCH V4 0/8] Cleancache: overview

Changes from V3 to V4:
- Rebased to 2.6.36-rc3
- Use exportfs/filehandle for unique file identification on next-gen FS's
  (Many thanks to Andreas Dilger for guidance on the new exportfs interface!)
  See get_key and struct cleancache_filekey in cleancache.[ch] in [PATCH 3/8].
  No changes to any VFS/FS hooks were required to provide this functionality.
  However, this changes the cleancache frontend/backend kernel-internal API
  so matching changes to the tmem and zmem cleancache backends are required.
- Add comments/FAQ entries resulting from V3 and discussions at LSF10/MM
- Note: The global cleancache_ops was retained for performance reasons;
  see FAQ #8

Changes from V2 to V3:
- Rebased to 2.6.35-rc2 (no significant functional changes)
- Use one cleancache_ops struct to avoid pointer hops (Andrew Morton)
- Document and ensure PageLocked requirements are met (Andrew Morton)
- Moved primary doc to Documentation/vm and added a FAQ (Christoph Hellwig)
- Document sysfs API in Documentation/ABI (Andrew Morton)
- Use standard success/fail codes (0/<0) (Nitin Gupta)
- Switch ops function types to void where retval is ignored (Nitin Gupta)
- Clarify in doc: init_fs and flush_fs occur at mount/unmount (Nitin Gupta)
- Fix bug where pool_id==0 is considered an error on fs unmount (Nitin Gupta)

Changes from V1 to V2:
- Rebased to 2.6.34 (no functional changes)
- Convert to sane types (Al Viro)
- Define some raw constants (Konrad Wilk)
- Add ack from Andreas Dilger

Cleancache is a new optional feature provided by the VFS layer that
potentially dramatically increases page cache effectiveness for
many workloads in many environments at a negligible cost.

In previous patch postings, cleancache was part of the Transcendent
Memory ("tmem") patchset.  This patchset refocuses not on the underlying
technology (tmem) but instead on the useful functionality provided for Linux,
and provides a clean API so that cleancache can provide this very useful
functionality either via a Xen tmem driver OR completely independent of tmem.
For example: Nitin Gupta (of compcache and ramzswap fame) is implementing
an in-kernel compression "backend" for cleancache called "zmem"; some believe
cleancache will be a very nice interface for building RAM-like functionality
for pseudo-RAM devices such as SSD or phase-change memory; and there
was interest at LSF10/MM in using cleancache to support memory "rightsizing"
within cgroups.

A more complete description of cleancache can be found in Documentation/vm/
cleancache.txt (in PATCH 1/8) which is included below for convenience.

Note that an earlier version of this patch is now shipping in OpenSuSE 11.2
and will soon ship in a release of Oracle Enterprise Linux.  Underlying
tmem technology is now shipping in Oracle VM 2.2 and was released
in Xen 4.0 on April 15, 2010.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>

 Documentation/ABI/testing/sysfs-kernel-mm-cleancache |   11 
 Documentation/vm/cleancache.txt                      |  267 +++++++++++++++++++
 fs/btrfs/extent_io.c                                 |    9 
 fs/btrfs/super.c                                     |    2 
 fs/buffer.c                                          |    5 
 fs/ext3/super.c                                      |    2 
 fs/ext4/super.c                                      |    2 
 fs/mpage.c                                           |    7 
 fs/ocfs2/super.c                                     |    3 
 fs/super.c                                           |    7 
 include/linux/cleancache.h                           |  101 +++++++
 include/linux/fs.h                                   |    5 
 mm/Kconfig                                           |   22 +
 mm/Makefile                                          |    1 
 mm/cleancache.c                                      |  201 ++++++++++++++
 mm/filemap.c                                         |   11 
 mm/truncate.c                                        |   10 
 17 files changed, 666 insertions(+)

(following is a copy of Documentation/vm/cleancache.txt)

MOTIVATION

Cleancache is a new optional feature provided by the VFS layer that
potentially dramatically increases page cache effectiveness for
many workloads in many environments at a negligible cost.

Cleancache can be thought of as a page-granularity victim cache for clean
pages that the kernel's pageframe replacement algorithm (PFRA) would like
to keep around, but can't since there isn't enough memory.  So when the
PFRA "evicts" a page, it first attempts to put it into a synchronous
concurrency-safe page-oriented "pseudo-RAM" device (such as Xen's
Transcendent Memory, aka "tmem", or in-kernel compressed memory, aka "zmem",
or other RAM-like devices) which is not directly accessible or addressable
by the kernel and is of unknown and possibly time-varying size.  And when a
cleancache-enabled filesystem wishes to access a page in a file on disk,
it first checks cleancache to see if it already contains it; if it does,
the page is copied into the kernel and a disk access is avoided.

FAQs are included below:

IMPLEMENTATION OVERVIEW

A cleancache "backend" that interfaces to this pseudo-RAM links itself
to the kernel's cleancache "frontend" by setting the global cleancache_ops
funcs appropriately.  (A global is required for performance reasons; see
FAQ #8 below.)  The functions provided must conform to certain semantics
as follows:

Most important, cleancache is "ephemeral".  Pages which are copied into
cleancache have an indefinite lifetime which is completely unknowable
by the kernel and so may or may not still be in cleancache at any later time.
Thus, as its name implies, cleancache is not suitable for dirty pages.
Cleancache has complete discretion over what pages to preserve and what
pages to discard and when.

Mounting a cleancache-enabled filesystem should call "init_fs" to obtain a
pool id which, if positive, must be saved in the filesystem's superblock;
a negative return value indicates failure.  A "put_page" will copy a
(presumably about-to-be-evicted) page into cleancache and associate it with
the pool id, a file key, and a page index into the file.  (The combination
of a pool id, a file key, and an index is sometimes called a "handle".)
A "get_page" will copy the page, if found, from cleancache into kernel memory.
A "flush_page" will ensure the page no longer is present in cleancache;
a "flush_inode" will flush all pages associated with the specified file;
and, when a filesystem is unmounted, a "flush_fs" will flush all pages in
all files specified by the given pool id and also surrender the pool id.

An "init_shared_fs", like init_fs, obtains a pool id but tells cleancache
to treat the pool as shared using a 128-bit UUID as a key.  On systems
that may run multiple kernels (such as hard partitioned or virtualized
systems) that may share a clustered filesystem, and where cleancache
may be shared among those kernels, calls to init_shared_fs that specify the
same UUID will receive the same pool id, thus allowing the pages to
be shared.  Note that any security requirements must be imposed outside
of the kernel (e.g. by "tools" that control cleancache).  Or a
cleancache implementation can simply disable shared_init by always
returning a negative value.

If a get_page is successful on a non-shared pool, the page is flushed (thus
making cleancache an "exclusive" cache).  On a shared pool, the page
is NOT flushed on a successful get_page so that it remains accessible to
other sharers.  The kernel is responsible for ensuring coherency between
cleancache (shared or not), the page cache, and the filesystem, using
cleancache flush operations as required.

Note that cleancache must enforce put-put-get coherency and get-get
coherency.  For the former, if two puts are made to the same handle but
with different data, say AAA by the first put and BBB by the second, a
subsequent get can never return the stale data (AAA).  For get-get coherency,
if a get for a given handle fails, subsequent gets for that handle will
never succeed unless preceded by a successful put with that handle.

Last, cleancache provides no SMP serialization guarantees; if two
different Linux threads are simultaneously putting and flushing a page
with the same handle, the results are indeterminate.  Callers must
lock the page to ensure serial behavior.

CLEANCACHE PERFORMANCE METRICS

Cleancache monitoring is done by sysfs files in the
/sys/kernel/mm/cleancache directory.  The effectiveness of cleancache
can be measured (across all filesystems) with:

succ_gets	- number of gets that were successful
failed_gets	- number of gets that failed
puts		- number of puts attempted (all "succeed")
flushes		- number of flushes attempted

A backend implementatation may provide additional metrics.

FAQ

1) Where's the value? (Andrew Morton)

Cleancache provides a significant performance benefit to many workloads
in many environments with negligible overhead by improving the
effectiveness of the pagecache.  Clean pagecache pages are
saved in pseudo-RAM (RAM that is otherwise not directly addressable to
the kernel); fetching those pages later avoids "refaults" and thus
disk reads.

Cleancache (and its sister code "frontswap") provide interfaces for
a new pseudo-RAM memory type that conceptually lies between fast
kernel-directly-addressable RAM and slower DMA/asynchronous devices.
Disallowing direct kernel or userland reads/writes to this pseudo-RAM
is ideal when data is transformed to a different form and size (such
as with compression) or secretly moved (as might be useful for write-
balancing for some RAM-like devices).  Evicted page-cache pages (and
swap pages) are a great use for this kind of slower-than-RAM-but-much-
faster-than-disk pseudo-RAM and the cleancache (and frontswap)
"page-object-oriented" specification provides a nice way to read and
write -- and indirectly "name" -- the pages.

In the virtual case, the whole point of virtualization is to statistically
multiplex physical resources across the varying demands of multiple
virtual machines.  This is really hard to do with RAM and efforts to
do it well with no kernel change have essentially failed (except in some
well-publicized special-case workloads).  Cleancache -- and frontswap --
with a fairly small impact on the kernel, provide a huge amount
of flexibility for more dynamic, flexible RAM multiplexing.
Specifically, the Xen Transcendent Memory backend allows otherwise
"fallow" hypervisor-owned RAM to not only be "time-shared" between multiple
virtual machines, but the pages can be compressed and deduplicated to
optimize RAM utilization.  And when guest OS's are induced to surrender
underutilized RAM (e.g. with "self-ballooning"), page cache pages
are the first to go, and cleancache allows those pages to be
saved and reclaimed if overall host system memory conditions allow.

2) Why does cleancache have its sticky fingers so deep inside the
   filesystems and VFS? (Andrew Morton and Christoph Hellwig)

The core hooks for cleancache in VFS are in most cases a single line
and the minimum set are placed precisely where needed to maintain
coherency (via cleancache_flush operations) between cleancache,
the page cache, and disk.  All hooks compile into nothingness if
cleancache is config'ed off and turn into a function-pointer-
compare-to-NULL if config'ed on but no backend claims the ops
functions, or to a compare-struct-element-to-negative if a
backend claims the ops functions but a filesystem doesn't enable
cleancache.

Some filesystems are built entirely on top of VFS and the hooks
in VFS are sufficient, so don't require an "init_fs" hook; the
initial implementation of cleancache didn't provide this hook.
But for some filesystems (such as btrfs), the VFS hooks are
incomplete and one or more hooks in fs-specific code are required.
And for some other filesystems, such as tmpfs, cleancache may
be counterproductive.  So it seemed prudent to require a filesystem
to "opt in" to use cleancache, which requires adding a hook in
each filesystem.  Not all filesystems are supported by cleancache
only because they haven't been tested.  The existing set should
be sufficient to validate the concept, the opt-in approach means
that untested filesystems are not affected, and the hooks in the
existing filesystems should make it very easy to add more
filesystems in the future.

The total impact of the hooks to existing fs and mm files is 43
lines added (not counting comments and blank lines).

3) Why not make cleancache asynchronous and batched so it can
   more easily interface with real devices with DMA instead
   of copying each individual page? (Minchan Kim)

The one-page-at-a-time copy semantics simplifies the implementation
on both the frontend and backend and also allows the backend to
do fancy things on-the-fly like page compression and
page deduplication.  And since the data is "gone" (copied into/out
of the pageframe) before the cleancache get/put call returns,
a great deal of race conditions and potential coherency issues
are avoided.  While the interface seems odd for a "real device"
or for real kernel-addressable RAM, it makes perfect sense for
pseudo-RAM.

4) Why is non-shared cleancache "exclusive"?  And where is the
   page "flushed" after a "get"? (Minchan Kim)

The main reason is to free up memory in pseudo-RAM and to avoid
unnecessary cleancache_flush calls.  If you want inclusive,
the page can be "put" immediately following the "get".  If
put-after-get for inclusive becomes common, the interface could
be easily extended to add a "get_no_flush" call.

The flush is done by the cleancache backend implementation.

5) What's the performance impact?

Performance analysis has been presented at OLS'09 and LCA'10.
Briefly, performance gains can be significant on most workloads,
especially when memory pressure is high (e.g. when RAM is
overcommitted in a virtual workload); and because the hooks are
invoked primarily in place of or in addition to a disk read/write,
overhead is negligible even in worst case workloads.  Basically
cleancache replaces I/O with memory-copy-CPU-overhead; on older
single-core systems with slow memory-copy speeds, cleancache
has little value, but in newer multicore machines, especially
consolidated/virtualized machines, it has great value.

6) How do I add cleancache support for filesystem X? (Boaz Harrash)

Filesystems that are well-behaved and conform to certain
restrictions can utilize cleancache simply by making a call to
cleancache_init_fs at mount time.  Unusual, misbehaving, or
poorly layered filesystems must either add additional hooks
and/or undergo extensive additional testing... or should just
not enable the optional cleancache.

Some points for a filesystem to consider:

- The FS should be block-device-based (e.g. a ram-based FS such
  as tmpfs should not enable cleancache)
- To ensure coherency/correctness, the FS must ensure that all
  file removal or truncation operations either go through VFS or
  add hooks to do the equivalent cleancache "flush" operations
- To ensure coherency/correctness, either inode numbers must
  be unique across the lifetime of the on-disk file OR the
  FS must provide an "encode_fh" function.
- The FS must call the VFS superblock alloc and deactivate routines
  or add hooks to do the equivalent cleancache calls done there.
- To maximize performance, all pages fetched from the FS should
  go through the do_mpag_readpage routine or the FS should add
  hooks to do the equivalent (cf. btrfs)
- Currently, the FS blocksize must be the same as PAGESIZE.  This
  is not an architectural restriction, but no backends currently
  support anything different.
- A clustered FS should invoke the "shared_init_fs" cleancache
  hook to get best performance for some backends.

7) Why not use the KVA of the inode as the key? (Christoph Hellwig)

If cleancache would use the inode virtual address instead of
inode/filehandle, the pool id could be eliminated.  But, this
won't work because cleancache retains pagecache data pages
persistently even when the inode has been pruned from the
inode unused list, and only flushes the data page if the file
gets removed/truncated.  So if cleancache used the inode kva,
there would be potential coherency issues if/when the inode
kva is reused for a different file.  Alternately, if cleancache
flushed the pages when the inode kva was freed, much of the value
of cleancache would be lost because the cache of pages in cleanache
is potentially much larger than the kernel pagecache and is most
useful if the pages survive inode cache removal.

8) Why does cleancache_ops need to be global?  Can't you use a
   cleancache_ops_register function instead?

The cleancache_enabled macro, which accesses the global, is used
in all of the frequently-used cleancache hooks.  The alternative
is a function call to check a static variable. Since cleancache
is enabled dynamically at runtime, systems that don't enable cleancache
would suffer thousands (possibly tens-of-thousands) of unnecessary
function calls per second.  So the global variable allows cleancache
to be enabled by default at compile time, but have insignificant
performance impact when cleancache remains disabled at runtime.

9) Does cleanache work with KVM?

The memory model of KVM is sufficiently different that a cleancache
backend may have little value for KVM.  This remains to be tested,
especially in an overcommitted system.

10) Does cleancache work in userspace?  It sounds useful for
   memory hungry caches like web browsers.  (Jamie Lokier)

No plans yet, though we agree it sounds useful, at least for
apps that bypass the page cache (e.g. O_DIRECT).

Last updated: Dan Magenheimer, August 30 2010

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
