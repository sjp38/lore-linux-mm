Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1355B6B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 13:06:22 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so134486741pfe.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:06:22 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r2si5515156pgo.574.2017.07.24.10.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 10:06:20 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 0/5] DAX common 4k zero page
Date: Mon, 24 Jul 2017 11:06:11 -0600
Message-Id: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

Changes since v4:
 - Added static __vm_insert_mixed() to mm/memory.c that holds the common
   code for both vm_insert_mixed() and vm_insert_mixed_mkwrite() so we
   don't have duplicate code and we don't have to pass boolean flags
   around.  (Dan & Jan)

 - Added a comment for the PFN sanity checking done in the mkwrite case of
   insert_pfn().

 - Added Jan's reviewed-by tags.

This series has passed a full xfstests run on both XFS and ext4.

---

When servicing mmap() reads from file holes the current DAX code allocates
a page cache page of all zeroes and places the struct page pointer in the
mapping->page_tree radix tree.  This has three major drawbacks:

1) It consumes memory unnecessarily.  For every 4k page that is read via a
DAX mmap() over a hole, we allocate a new page cache page.  This means that
if you read 1GiB worth of pages, you end up using 1GiB of zeroed memory.

2) It is slower than using a common zero page because each page fault has
more work to do.  Instead of just inserting a common zero page we have to
allocate a page cache page, zero it, and then insert it.

3) The fact that we had to check for both DAX exceptional entries and for
page cache pages in the radix tree made the DAX code more complex.

This series solves these issues by following the lead of the DAX PMD code
and using a common 4k zero page instead.  This reduces memory usage and
decreases latencies for some workloads, and it simplifies the DAX code,
removing over 100 lines in total.

Ross Zwisler (5):
  mm: add vm_insert_mixed_mkwrite()
  dax: relocate some dax functions
  dax: use common 4k zero page for dax mmap reads
  dax: remove DAX code from page_cache_tree_insert()
  dax: move all DAX radix tree defs to fs/dax.c

 Documentation/filesystems/dax.txt |   5 +-
 fs/dax.c                          | 345 ++++++++++++++++----------------------
 fs/ext2/file.c                    |  25 +--
 fs/ext4/file.c                    |  32 +---
 fs/xfs/xfs_file.c                 |   2 +-
 include/linux/dax.h               |  45 -----
 include/linux/mm.h                |   2 +
 include/trace/events/fs_dax.h     |   2 -
 mm/filemap.c                      |  13 +-
 mm/memory.c                       |  50 +++++-
 10 files changed, 196 insertions(+), 325 deletions(-)

-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
