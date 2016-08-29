Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8060E82F64
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:12:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id n130so1396061itg.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 12:12:08 -0700 (PDT)
Received: from g4t3427.houston.hpe.com (g4t3427.houston.hpe.com. [15.241.140.73])
        by mx.google.com with ESMTPS id n51si1947986ota.79.2016.08.29.12.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 12:12:07 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Date: Mon, 29 Aug 2016 13:11:19 -0600
Message-Id: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mawilcox@microsoft.com, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com, david@fromorbit.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, mike.kravetz@oracle.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

RESEND:
 - Rebased to 4.8.0-rc4, and drop blk as BLK_DEV_DAX was removed.

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
 fs/ext2/file.c          |  1 +
 fs/ext4/file.c          |  1 +
 fs/xfs/xfs_file.c       |  1 +
 include/linux/huge_mm.h |  7 +++++++
 mm/huge_memory.c        | 43 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 53 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
