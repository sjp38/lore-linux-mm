Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1536C6B0005
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 20:30:09 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id fg3so189973529obb.3
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 17:30:09 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id oc18si1659697obb.104.2016.04.22.17.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 17:30:08 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 0/2] Align mmap address for DAX pmd mappings
Date: Fri, 22 Apr 2016 18:21:21 -0600
Message-Id: <1461370883-7664-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, viro@zeniv.linux.org.uk, willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, mike.kravetz@oracle.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When CONFIG_FS_DAX_PMD is set, DAX supports mmap() using pmd page
size.  This feature relies on both mmap virtual address and FS
block (i.e. physical address) to be aligned by the pmd page size.
Users can use mkfs options to specify FS to align block allocations.
However, aligning mmap address requires code changes to existing
applications for providing a pmd-aligned address to mmap().

For instance, fio with "ioengine=mmap" performs I/Os with mmap() [1].
It calls mmap() with a NULL address, which needs to be changed to
provide a pmd-aligned address for testing with DAX pmd mappings.
Changing all applications that call mmap() with NULL is undesirable.

This patch-set extends filesystems to align an mmap address for
a DAX file so that unmodified applications can use DAX pmd mappings.

[1]: https://github.com/axboe/fio/blob/master/engines/mmap.c

v4:
 - Use loff_t for offset and cast before shift (Jan Kara)
 - Remove redundant paranthesis (Jan Kara)
 - Allow integration with huge page cache support (Matthew Wilcox)
 - Prepare for PUD mapping support (Mike Kravetz, Matthew Wilcox)

v3:
 - Check overflow condition to offset + length. (Matthew Wilcox)
 - Remove indent by using gotos. (Matthew Wilcox)
 - Define dax_get_unmapped_area to NULL when CONFIG_FS_DAX is unset.
   (Matthew Wilcox)
 - Squash all filesystem patches together. (Matthew Wilcox)

v2:
 - Change filesystems to provide their get_unmapped_area().
   (Matthew Wilcox)
 - Add more description about the benefit. (Matthew Wilcox)

---
Toshi Kani (2):
 1/2 thp, dax: add thp_get_unmapped_area for pmd mappings
 2/2 ext2/4, xfs, blk: call thp_get_unmapped_area() for pmd mappings

---
 fs/block_dev.c          |  1 +
 fs/ext2/file.c          |  1 +
 fs/ext4/file.c          |  1 +
 fs/xfs/xfs_file.c       |  1 +
 include/linux/huge_mm.h |  7 +++++++
 mm/huge_memory.c        | 43 +++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 54 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
