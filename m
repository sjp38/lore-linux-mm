Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id B78556B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:07:02 -0500 (EST)
Received: by padhx2 with SMTP id hx2so114491826pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:07:02 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vw1si30613885pbc.120.2015.11.13.16.07.01
        for <linux-mm@kvack.org>;
        Fri, 13 Nov 2015 16:07:01 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 00/11] DAX fsynx/msync support
Date: Fri, 13 Nov 2015 17:06:39 -0700
Message-Id: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

This patch series adds support for fsync/msync to DAX.

Patches 1 through 7 add various utilities that the DAX code will eventually
need, and the DAX code itself is added by patch 8.  Patches 9-11 update the
three filesystems that currently support DAX, ext2, ext4 and XFS, to use
the new DAX fsync/msync code.

These patches build on the recent DAX locking changes from Dave Chinner,
Jan Kara and myself.  Dave's changes for XFS and my changes for ext2 have
been merged in the v4.4 window, but Jan's are still unmerged.  You can grab
them here:

http://www.spinics.net/lists/linux-ext4/msg49951.html

Ross Zwisler (11):
  pmem: add wb_cache_pmem() to the PMEM API
  mm: add pmd_mkclean()
  pmem: enable REQ_FUA/REQ_FLUSH handling
  dax: support dirty DAX entries in radix tree
  mm: add follow_pte_pmd()
  mm: add pgoff_mkclean()
  mm: add find_get_entries_tag()
  dax: add support for fsync/sync
  ext2: add support for DAX fsync/msync
  ext4: add support for DAX fsync/msync
  xfs: add support for DAX fsync/msync

 arch/x86/include/asm/pgtable.h |   5 ++
 arch/x86/include/asm/pmem.h    |  11 ++--
 drivers/nvdimm/pmem.c          |   3 +-
 fs/block_dev.c                 |   3 +-
 fs/dax.c                       | 140 +++++++++++++++++++++++++++++++++++++++--
 fs/ext2/file.c                 |  14 ++++-
 fs/ext4/file.c                 |   4 +-
 fs/ext4/fsync.c                |  12 +++-
 fs/inode.c                     |   1 +
 fs/xfs/xfs_file.c              |  18 ++++--
 include/linux/dax.h            |   6 ++
 include/linux/fs.h             |   1 +
 include/linux/mm.h             |   2 +
 include/linux/pagemap.h        |   3 +
 include/linux/pmem.h           |  22 ++++++-
 include/linux/radix-tree.h     |   8 +++
 include/linux/rmap.h           |   5 ++
 mm/filemap.c                   |  71 ++++++++++++++++++++-
 mm/huge_memory.c               |  14 ++---
 mm/memory.c                    |  38 ++++++++---
 mm/rmap.c                      |  51 +++++++++++++++
 mm/truncate.c                  |  62 ++++++++++--------
 22 files changed, 425 insertions(+), 69 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
