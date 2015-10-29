Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8253082F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:29 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so44042512pad.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:29 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yw10si4839560pac.86.2015.10.29.13.12.28
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:28 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 00/11] DAX fsynx/msync support
Date: Thu, 29 Oct 2015 14:12:04 -0600
Message-Id: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

This patch series adds support for fsync/msync to DAX.

Patches 1 through 8 add various utilities that the DAX code will eventually
need, and the DAX code itself is added by patch 9.  Patches 10 and 11 are
filesystem changes that are needed after the DAX code is added, but these
patches may change slightly as the filesystem fault handling for DAX is
being modified ([1] and [2]).

I've marked this series as RFC because I'm still testing, but I wanted to
get this out there so people would see the direction I was going and
hopefully comment on any big red flags sooner rather than later.

I realize that we are getting pretty dang close to the v4.4 merge window,
but I think that if we can get this reviewed and working it's a much better
solution than the "big hammer" approach that blindly flushes entire PMEM
namespaces [3].

[1] http://oss.sgi.com/archives/xfs/2015-10/msg00523.html
[2] http://marc.info/?l=linux-ext4&m=144550211312472&w=2
[3] https://lists.01.org/pipermail/linux-nvdimm/2015-October/002614.html

Ross Zwisler (11):
  pmem: add wb_cache_pmem() to the PMEM API
  mm: add pmd_mkclean()
  pmem: enable REQ_FLUSH handling
  dax: support dirty DAX entries in radix tree
  mm: add follow_pte_pmd()
  mm: add pgoff_mkclean()
  mm: add find_get_entries_tag()
  fs: add get_block() to struct inode_operations
  dax: add support for fsync/sync
  xfs, ext2: call dax_pfn_mkwrite() on write fault
  ext4: add ext4_dax_pfn_mkwrite()

 arch/x86/include/asm/pgtable.h |   5 ++
 arch/x86/include/asm/pmem.h    |  11 +--
 drivers/nvdimm/pmem.c          |   3 +-
 fs/dax.c                       | 161 +++++++++++++++++++++++++++++++++++++++--
 fs/ext2/file.c                 |   5 +-
 fs/ext4/file.c                 |  23 +++++-
 fs/inode.c                     |   1 +
 fs/xfs/xfs_file.c              |   9 ++-
 fs/xfs/xfs_iops.c              |   1 +
 include/linux/dax.h            |   6 ++
 include/linux/fs.h             |   5 +-
 include/linux/mm.h             |   2 +
 include/linux/pagemap.h        |   3 +
 include/linux/pmem.h           |  22 +++++-
 include/linux/radix-tree.h     |   3 +
 include/linux/rmap.h           |   5 ++
 mm/filemap.c                   |  73 ++++++++++++++++++-
 mm/huge_memory.c               |  14 ++--
 mm/memory.c                    |  41 +++++++++--
 mm/page-writeback.c            |   9 +++
 mm/rmap.c                      |  53 ++++++++++++++
 mm/truncate.c                  |   5 +-
 22 files changed, 418 insertions(+), 42 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
