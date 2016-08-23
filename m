Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 648206B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 18:04:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so279337136pfd.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 15:04:31 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id hm6si5740071pac.254.2016.08.23.15.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 15:04:30 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 0/9] re-enable DAX PMD support
Date: Tue, 23 Aug 2016 16:04:10 -0600
Message-Id: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Matthew Wilcox <mawilcox@microsoft.com>

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

Changes since v1:
 - PMD entry locking is now done based on the starting offset of the PMD
   entry, rather than on the radix tree slot which was unreliable. (Jan)
 - Fixed the one issue I could find with hole punch.  As far as I can tell
   hole punch now works correctly for both PMD and PTE DAX entries, 4k zero
   pages and huge zero pages.
 - Fixed the way that ext2 returns the size of holes in ext2_get_block().
   (Jan)
 - Made the 'wait_table' global variable static in respnse to a sparse
   warning.
 - Fixed some more inconsitent usage between the names 'ret' and 'entry'
   for radix tree entry variables.

Ross Zwisler (9):
  ext4: allow DAX writeback for hole punch
  ext2: tell DAX the size of allocation holes
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  dax: make 'wait_table' global variable static
  dax: consistent variable naming for DAX entries
  dax: coordinate locking for offsets in PMD range
  dax: re-enable DAX PMD support
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 297 +++++++++++++++++++++++++++++-----------------------
 fs/ext2/inode.c     |   3 +
 fs/ext4/inode.c     |   7 +-
 include/linux/dax.h |  29 ++++-
 mm/filemap.c        |   6 +-
 6 files changed, 201 insertions(+), 142 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
