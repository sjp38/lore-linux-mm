Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 283AB6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:18:54 -0500 (EST)
Received: by pfbg73 with SMTP id g73so16927064pfb.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:18:53 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 76si6919595pfp.49.2015.12.08.11.18.53
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 11:18:53 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 0/7] DAX fsync/msync support
Date: Tue,  8 Dec 2015 12:18:38 -0700
Message-Id: <1449602325-20572-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

This patch series adds a slimmed down version of fsync/msync support to
DAX.  The major change versus v2 of this patch series is that we no longer
remove DAX entries from the radix tree during fsync/msync calls.  Instead
the list of DAX entries in the radix tree grows for the lifetime of the
mapping.  We reclaim DAX entries from the radix tree via
clear_exceptional_entry() for truncate, when the filesystem is unmounted,
etc.

This change was made because if we try and remove radix tree entries during
writeback operations there are a number of race conditions that exist
between those writeback operations and page faults.  In the non-DAX case
these races are dealt with using the page lock, but we don't have a good
replacement lock with the same granularity.  These races could leave us in
a place where we have a DAX page that is dirty and writeable from userspace
but no longer in the radix tree.  This page would then be skipped during
subsequent writeback operations, which is unacceptable.

I do plan to continue to try and solve these race conditions so that we can
have a more optimal fsync/msync solution for DAX, but I wanted to get this
set out for v4.5 consideration while I continued working.  While
suboptimal the solution in this series gives us correct behavior for DAX
fsync/msync and seems like a reasonable short term compromise.

This series is built upon v4.4-rc4 plus the recent ext4 DAX series from Jan
Kara (http://www.spinics.net/lists/linux-ext4/msg49951.html) and a recent
XFS fix from Dave Chinner (https://lkml.org/lkml/2015/12/2/923).  The tree
with all this working can be found here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_v3

Other changes versus v2:
 - Renamed dax_fsync() to dax_writeback_mapping_range(). (Dave Chinner)
 - Removed REQ_FUA/REQ_FLUSH support from the PMEM driver and instead just
   make the call to wmb_pmem() in dax_writeback_mapping_range().  (Dan)
 - Reworked some BUG_ON() calls to be a WARN_ON() followed by an error
   return.
 - Moved call to dax_writeback_mapping_range() from the filesystems down
   into filemap_write_and_wait_range(). (Dave Chinner)
 - Fixed handling of DAX read faults so they create a radix tree entry but
   don't mark it as dirty until the follow-up dax_pfn_mkwrite() call.
 - Update clear_exceptional_entry() and to dax_writeback_one() so they
   validate the DAX radix tree entry before they use it. (Dave Chinner)
 - Added a comment to find_get_entries_tag() to explain the restart
   condition. (Dave Chinner)

Ross Zwisler (7):
  pmem: add wb_cache_pmem() to the PMEM API
  dax: support dirty DAX entries in radix tree
  mm: add find_get_entries_tag()
  dax: add support for fsync/sync
  ext2: call dax_pfn_mkwrite() for DAX fsync/msync
  ext4: call dax_pfn_mkwrite() for DAX fsync/msync
  xfs: call dax_pfn_mkwrite() for DAX fsync/msync

 arch/x86/include/asm/pmem.h |  11 ++--
 fs/block_dev.c              |   3 +-
 fs/dax.c                    | 147 ++++++++++++++++++++++++++++++++++++++++++--
 fs/ext2/file.c              |   4 +-
 fs/ext4/file.c              |   4 +-
 fs/inode.c                  |   1 +
 fs/xfs/xfs_file.c           |   7 ++-
 include/linux/dax.h         |   7 +++
 include/linux/fs.h          |   1 +
 include/linux/pagemap.h     |   3 +
 include/linux/pmem.h        |  22 ++++++-
 include/linux/radix-tree.h  |   9 +++
 mm/filemap.c                |  84 ++++++++++++++++++++++++-
 mm/truncate.c               |  64 +++++++++++--------
 14 files changed, 319 insertions(+), 48 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
