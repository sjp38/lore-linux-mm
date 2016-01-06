Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2557F828DE
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 13:01:23 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e65so189553218pfe.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 10:01:23 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sq8si3131167pab.10.2016.01.06.10.01.18
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 10:01:19 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v7 0/9] DAX fsync/msync support
Date: Wed,  6 Jan 2016 11:00:54 -0700
Message-Id: <1452103263-1592-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

Changes since v6 [1]:

1) Fixed an existing NULL pointer dereference bug in __dax_dbg() in patch 1.

2) Fixed an existing bug with the way holes are converted into DAX PMD
entries in patch 2.  This solves a BUG_ON reported by Dan Williams.

3) Removed second verification of our radix tree entry before cache flush
in dax_writeback_one(). (Jan Kara)

4) Updated to the new argument list types for dax_pmd_dbg(). (Dan Williams)

5) Fixed the text of a random debug message so that it accurately reflects
the error being found.

This series replaces v6 in the MM tree and in the "akpm" branch of the next
tree.  A working tree can be found here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_v7

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-December/003663.html

Ross Zwisler (9):
  dax: fix NULL pointer dereference in __dax_dbg()
  dax: fix conversion of holes to PMDs
  pmem: add wb_cache_pmem() to the PMEM API
  dax: support dirty DAX entries in radix tree
  mm: add find_get_entries_tag()
  dax: add support for fsync/msync
  ext2: call dax_pfn_mkwrite() for DAX fsync/msync
  ext4: call dax_pfn_mkwrite() for DAX fsync/msync
  xfs: call dax_pfn_mkwrite() for DAX fsync/msync

 arch/x86/include/asm/pmem.h |  11 +--
 fs/block_dev.c              |   2 +-
 fs/dax.c                    | 214 ++++++++++++++++++++++++++++++++++++++++----
 fs/ext2/file.c              |   4 +-
 fs/ext4/file.c              |   4 +-
 fs/inode.c                  |   2 +-
 fs/xfs/xfs_file.c           |   7 +-
 include/linux/dax.h         |   7 ++
 include/linux/fs.h          |   3 +-
 include/linux/pagemap.h     |   3 +
 include/linux/pmem.h        |  22 ++++-
 include/linux/radix-tree.h  |   9 ++
 mm/filemap.c                |  91 +++++++++++++++++--
 mm/truncate.c               |  69 +++++++-------
 mm/vmscan.c                 |   9 +-
 mm/workingset.c             |   4 +-
 16 files changed, 391 insertions(+), 70 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
