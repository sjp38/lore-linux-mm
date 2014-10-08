Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 462776B0080
	for <linux-mm@kvack.org>; Wed,  8 Oct 2014 09:25:44 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so9119856pab.12
        for <linux-mm@kvack.org>; Wed, 08 Oct 2014 06:25:43 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id c8si18124511pat.196.2014.10.08.06.25.42
        for <linux-mm@kvack.org>;
        Wed, 08 Oct 2014 06:25:42 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v1 0/7] Huge page support for DAX
Date: Wed,  8 Oct 2014 09:25:22 -0400
Message-Id: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.krenel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

This patchset, on top of the v11 DAX patchset I posted recently, adds
support for transparent huge pages.  In-memory databases and HPC apps are
particularly fond of using huge pages for their massive data sets.

The actual DAX code here is not how I want it to be, for example it
will allocate on read-faults instead of using zero pages to fill until
we have a write fault (which is going to prove tricky without at least
some of Kirill's patches for supporting huge pages in the page cache).

I'm posting this for review now since I clearly don't understand the
Linux MM very well and I'm expecting to be told I've done all the huge
memory bits wrongly :-)

I'd like to thank Kirill for all his helpful suggestions ... I may not
have taken all of them, but this would be in a lot worse shape without
him.

The first patch is from Kirill's patchset to allow huge pages in the
page cache.  Patches 2-4 are the ones that touch the MM and I'd really
like reviewed.  Patch 5 is the DAX code that is easily critiqued, and
patches 6 & 7 are very boring, just hooking up the dax-hugepage code to
ext2 & ext4.

Kirill A. Shutemov (1):
  thp: vma_adjust_trans_huge(): adjust file-backed VMA too

Matthew Wilcox (6):
  mm: Prepare for DAX huge pages
  mm: Add vm_insert_pfn_pmd()
  mm: Add a pmd_fault handler
  dax: Add huge page fault support
  ext2: Huge page fault support
  ext4: Huge page fault support

 Documentation/filesystems/dax.txt |   7 +-
 arch/x86/include/asm/pgtable.h    |  10 +++
 fs/dax.c                          | 133 ++++++++++++++++++++++++++++++++++++++
 fs/ext2/file.c                    |   9 ++-
 fs/ext4/file.c                    |   9 ++-
 include/linux/fs.h                |   2 +
 include/linux/huge_mm.h           |  11 +---
 include/linux/mm.h                |   4 ++
 mm/huge_memory.c                  |  53 +++++++++------
 mm/memory.c                       |  63 ++++++++++++++++--
 10 files changed, 262 insertions(+), 39 deletions(-)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
