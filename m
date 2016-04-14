Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFC786B0265
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 12:57:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so55382296pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 09:57:20 -0700 (PDT)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id s202si8260867pfs.76.2016.04.14.09.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 09:57:17 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v3 0/2] Align mmap address for DAX pmd mappings
Date: Thu, 14 Apr 2016 10:48:29 -0600
Message-Id: <1460652511-19636-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, viro@zeniv.linux.org.uk
Cc: willy@linux.intel.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
 1/2 dax: add dax_get_unmapped_area for pmd mappings
 2/2 ext2/4, xfs, blk: call dax_get_unmapped_area() for DAX pmd mappings

---
 fs/block_dev.c      |  1 +
 fs/dax.c            | 43 +++++++++++++++++++++++++++++++++++++++++++
 fs/ext2/file.c      |  1 +
 fs/ext4/file.c      |  1 +
 fs/xfs/xfs_file.c   |  1 +
 include/linux/dax.h |  3 +++
 6 files changed, 50 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
