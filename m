Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 12BD36B0003
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 00:22:29 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id q3so50399526pav.3
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 21:22:29 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id f12si28847882pat.121.2015.12.18.21.22.28
        for <linux-mm@kvack.org>;
        Fri, 18 Dec 2015 21:22:28 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 0/7] DAX fsync/msync support
Date: Fri, 18 Dec 2015 22:22:13 -0700
Message-Id: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

Changes from v4:
 - Explicity prevent shadow entries from being added to radix trees for DAX
   mappings in patch 2.  The only shadow entries that would be generated
   for DAX radix trees would be to track zero page mappings that were
   created for holes.  These pages would receive minimal benefit from
   having shadow entries, and the choice to have only one type of
   exceptional entry in a given radix tree makes the logic simpler both in
   clear_exceptional_entry() and in the rest of DAX.  (Jan)

 - Added Reviewed-by from Jan to patch 3.

This series is built upon ext4/master.  A working tree with this series
applied can be found here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_v5

Ross Zwisler (7):
  pmem: add wb_cache_pmem() to the PMEM API
  dax: support dirty DAX entries in radix tree
  mm: add find_get_entries_tag()
  dax: add support for fsync/sync
  ext2: call dax_pfn_mkwrite() for DAX fsync/msync
  ext4: call dax_pfn_mkwrite() for DAX fsync/msync
  xfs: call dax_pfn_mkwrite() for DAX fsync/msync

 arch/x86/include/asm/pmem.h |  11 +--
 fs/block_dev.c              |   3 +-
 fs/dax.c                    | 159 ++++++++++++++++++++++++++++++++++++++++++--
 fs/ext2/file.c              |   4 +-
 fs/ext4/file.c              |   4 +-
 fs/inode.c                  |   1 +
 fs/xfs/xfs_file.c           |   7 +-
 include/linux/dax.h         |   7 ++
 include/linux/fs.h          |   1 +
 include/linux/pagemap.h     |   3 +
 include/linux/pmem.h        |  22 +++++-
 include/linux/radix-tree.h  |   9 +++
 mm/filemap.c                |  84 ++++++++++++++++++++++-
 mm/truncate.c               |  64 ++++++++++--------
 mm/vmscan.c                 |   9 ++-
 15 files changed, 339 insertions(+), 49 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
