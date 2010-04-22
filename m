Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 599176B01FA
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:28:54 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:27:28 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Cleancache [PATCH 0/7] (was Transcendent Memory): overview
Message-ID: <20100422132728.GA24243@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

(Sorry for resend... Mail server DNS problems sending to some recipients)

Cleancache [PATCH 0/7] (was Transcendent Memory): overview

Patch applies to 2.6.34-rc5

In previous patch postings, cleancache was part of the Transcendent
Memory ("tmem") patchset.  This patchset refocuses not on the underlying
technology (tmem) but instead on the useful functionality provided for Linux,
and provides a clean API so that cleancache can provide this very useful
functionality either via a Xen tmem driver OR completely independent of tmem.
For example: Nitin Gupta (of compcache and ramzswap fame) is implementing
an in-kernel compression "backend" for cleancache; some believe
cleancache will be a very nice interface for building RAM-like functionality
for pseudo-RAM devices such as SSD or phase-change memory; and a Pune
University team is looking at a backend for virtio (see OLS'2010).

A more complete description of cleancache can be found in the introductory
comment in mm/cleancache.c (in PATCH 2/7) which is included below
for convenience.

Note that an earlier version of this patch is now shipping in OpenSuSE 11.2
and will soon ship in a release of Oracle Enterprise Linux.  Underlying
tmem technology is now shipping in Oracle VM 2.2 and was just released
in Xen 4.0 on April 15, 2010.  (Search news.google.com for Transcendent
Memory)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>

 fs/btrfs/extent_io.c       |    9 ++
 fs/btrfs/super.c           |    2 
 fs/buffer.c                |    5 +
 fs/ext3/super.c            |    2 
 fs/ext4/super.c            |    2 
 fs/mpage.c                 |    7 +
 fs/ocfs2/super.c           |    3 
 fs/super.c                 |    8 +
 include/linux/cleancache.h |   88 ++++++++++++++++++++
 include/linux/fs.h         |    5 +
 mm/Kconfig                 |   22 +++++
 mm/Makefile                |    1 
 mm/cleancache.c            |  198 +++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c               |   11 ++
 mm/truncate.c              |   10 ++
 15 files changed, 373 insertions(+)

Cleancache can be thought of as a page-granularity victim cache for clean
pages that the kernel's pageframe replacement algorithm (PFRA) would like
to keep around, but can't since there isn't enough memory.  So when the
PFRA "evicts" a page, it first attempts to put it into a synchronous
concurrency-safe page-oriented pseudo-RAM device (such as Xen's Transcendent
Memory, aka "tmem", or in-kernel compressed memory, aka "zmem", or other
RAM-like devices) which is not directly accessible or addressable by the
kernel and is of unknown and possibly time-varying size.  And when a
cleancache-enabled filesystem wishes to access a page in a file on disk,
it first checks cleancache to see if it already contains it; if it does,
the page is copied into the kernel and a disk access is avoided.
This pseudo-RAM device links itself to cleancache by setting the
cleancache_ops pointer appropriately and the functions it provides must
conform to certain semantics as follows:

Most important, cleancache is "ephemeral".  Pages which are copied into
cleancache have an indefinite lifetime which is completely unknowable
by the kernel and so may or may not still be in cleancache at any later time.
Thus, as its name implies, cleancache is not suitable for dirty pages.  The
pseudo-RAM has complete discretion over what pages to preserve and what
pages to discard and when.

A filesystem calls "init_fs" to obtain a pool id which, if positive, must be
saved in the filesystem's superblock; a negative return value indicates
failure.  A "put_page" will copy a (presumably about-to-be-evicted) page into
pseudo-RAM and associate it with the pool id, the file inode, and a page
index into the file.  (The combination of a pool id, an inode, and an index
is called a "handle".)  A "get_page" will copy the page, if found, from
pseudo-RAM into kernel memory.  A "flush_page" will ensure the page no longer
is present in pseudo-RAM; a "flush_inode" will flush all pages associated
with the specified inode; and a "flush_fs" will flush all pages in all
inodes specified by the given pool id.

A "init_shared_fs", like init, obtains a pool id but tells the pseudo-RAM
to treat the pool as shared using a 128-bit UUID as a key.  On systems
that may run multiple kernels (such as hard partitioned or virtualized
systems) that may share a clustered filesystem, and where the pseudo-RAM
may be shared among those kernels, calls to init_shared_fs that specify the
same UUID will receive the same pool id, thus allowing the pages to
be shared.  Note that any security requirements must be imposed outside
of the kernel (e.g. by "tools" that control the pseudo-RAM).  Or a
pseudo-RAM implementation can simply disable shared_init by always
returning a negative value.

If a get_page is successful on a non-shared pool, the page is flushed (thus
making cleancache an "exclusive" cache).  On a shared pool, the page
is NOT flushed on a successful get_page so that it remains accessible to
other sharers.  The kernel is responsible for ensuring coherency between
cleancache (shared or not), the page cache, and the filesystem, using
cleancache flush operations as required.

Note that the pseudo-RAM must enforce put-put-get coherency and get-get
coherency.  For the former, if two puts are made to the same handle but
with different data, say AAA by the first put and BBB by the second, a
subsequent get can never return the stale data (AAA).  For get-get coherency,
if a get for a given handle fails, subsequent gets for that handle will
never succeed unless preceded by a successful put with that handle.

Last, pseudo-RAM provides no SMP serialization guarantees; if two
different Linux threads are putting an flushing a page with the same
handle, the results are indeterminate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
