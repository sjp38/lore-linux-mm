Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B5FAB6B0253
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 09:25:40 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so176174463pfn.3
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 06:25:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id v86si47916903pfi.16.2016.01.19.06.25.39
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 06:25:39 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/8] Support multi-order entries in the radix tree
Date: Tue, 19 Jan 2016 09:25:25 -0500
Message-Id: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

In order to support huge pages in the page cache, Kirill has proposed
simply creating 512 entries.  I think this runs into problems with
fsync() tracking dirty bits in the radix tree.  Ross inserts a special
entry to represent the PMD at the index for the start of the PMD, but
this requires probing the tree twice; once for the PTE and once for the PMD.
When we add PUD entries, that will become three times.

The approach in this patch set is to modify the radix tree to support
multi-order entries.  Pointers to internal radix tree nodes mostly do not
have the 'indirect' bit set.  I change that so they always have that bit
set; then any pointer without the indirect bit set is a multi-order entry.

If the order of the entry is a multiple of the fanout of the tree,
then all is well.  If not, it is necessary to insert alias nodes into
the tree that point to the canonical entry.  At this point, I have not
added support for entries which are smaller than the last-level fanout of
the tree (and I put a BUG_ON in to prevent that usage).  Adding support
would be a simple matter of one last pointer-chase when we get to the
bottom of the tree, but I am not aware of any reason to add support for
smaller multi-order entries at this point, so I haven't.

Note that no actual users are modified at this point.  I think it'd be
mostly a matter of deleting code from the DAX fsync support at this point,
but with that code in flux, I'm a little reluctant to add more churn
to it.  I'm also not entriely sure where Kirill is on the page-cache
modifications; he seems to have his hands full fixing up the MM right now.

Before diving into the important modifications, I add Andrew Morton's
radix tree test harness to the tree in patches 1 & 2.  It was absolutely
invaluable in catching some of my bugs.  Patches 3 & 4 are minor tweaks.
Patches 5-7 are the interesting ones.  Patch 8 we might want to leave
out entirely or shift over to the test harness.  I found it useful during
debugging and others might too.

Matthew Wilcox (8):
  radix-tree: Add an explicit include of bitops.h
  radix tree test harness
  radix-tree: Cleanups
  radix_tree: Convert some variables to unsigned types
  radix_tree: Tag all internal tree nodes as indirect pointers
  radix_tree: Loop based on shift count, not height
  radix_tree: Add support for multi-order entries
  radix_tree: Add radix_tree_dump

 include/linux/radix-tree.h                         |  12 +-
 lib/radix-tree.c                                   | 231 ++++++++++----
 mm/filemap.c                                       |   2 +-
 tools/testing/radix-tree/.gitignore                |   2 +
 tools/testing/radix-tree/Makefile                  |  20 ++
 tools/testing/radix-tree/find_next_bit.c           |  57 ++++
 tools/testing/radix-tree/linux.c                   |  60 ++++
 tools/testing/radix-tree/linux/bitops.h            | 150 ++++++++++
 tools/testing/radix-tree/linux/bitops/__ffs.h      |  43 +++
 tools/testing/radix-tree/linux/bitops/ffs.h        |  41 +++
 tools/testing/radix-tree/linux/bitops/ffz.h        |  12 +
 tools/testing/radix-tree/linux/bitops/find.h       |  13 +
 tools/testing/radix-tree/linux/bitops/fls.h        |  41 +++
 tools/testing/radix-tree/linux/bitops/fls64.h      |  14 +
 tools/testing/radix-tree/linux/bitops/hweight.h    |  11 +
 tools/testing/radix-tree/linux/bitops/le.h         |  53 ++++
 tools/testing/radix-tree/linux/bitops/non-atomic.h | 111 +++++++
 tools/testing/radix-tree/linux/bug.h               |   1 +
 tools/testing/radix-tree/linux/cpu.h               |  35 +++
 tools/testing/radix-tree/linux/export.h            |   2 +
 tools/testing/radix-tree/linux/gfp.h               |   8 +
 tools/testing/radix-tree/linux/init.h              |   0
 tools/testing/radix-tree/linux/kernel.h            |  34 +++
 tools/testing/radix-tree/linux/kmemleak.h          |   1 +
 tools/testing/radix-tree/linux/mempool.h           |  17 ++
 tools/testing/radix-tree/linux/notifier.h          |   8 +
 tools/testing/radix-tree/linux/percpu.h            |   7 +
 tools/testing/radix-tree/linux/preempt.h           |   5 +
 tools/testing/radix-tree/linux/radix-tree.h        |   1 +
 tools/testing/radix-tree/linux/rcupdate.h          |   9 +
 tools/testing/radix-tree/linux/slab.h              |  28 ++
 tools/testing/radix-tree/linux/string.h            |   0
 tools/testing/radix-tree/linux/types.h             |  28 ++
 tools/testing/radix-tree/main.c                    | 271 +++++++++++++++++
 tools/testing/radix-tree/rcupdate.c                |  86 ++++++
 tools/testing/radix-tree/regression.h              |   7 +
 tools/testing/radix-tree/regression1.c             | 221 ++++++++++++++
 tools/testing/radix-tree/regression2.c             | 126 ++++++++
 tools/testing/radix-tree/tag_check.c               | 332 +++++++++++++++++++++
 tools/testing/radix-tree/test.c                    | 219 ++++++++++++++
 tools/testing/radix-tree/test.h                    |  40 +++
 41 files changed, 2294 insertions(+), 65 deletions(-)
 create mode 100644 tools/testing/radix-tree/.gitignore
 create mode 100644 tools/testing/radix-tree/Makefile
 create mode 100644 tools/testing/radix-tree/find_next_bit.c
 create mode 100644 tools/testing/radix-tree/linux.c
 create mode 100644 tools/testing/radix-tree/linux/bitops.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/__ffs.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/ffs.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/ffz.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/find.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/fls.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/fls64.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/hweight.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/le.h
 create mode 100644 tools/testing/radix-tree/linux/bitops/non-atomic.h
 create mode 100644 tools/testing/radix-tree/linux/bug.h
 create mode 100644 tools/testing/radix-tree/linux/cpu.h
 create mode 100644 tools/testing/radix-tree/linux/export.h
 create mode 100644 tools/testing/radix-tree/linux/gfp.h
 create mode 100644 tools/testing/radix-tree/linux/init.h
 create mode 100644 tools/testing/radix-tree/linux/kernel.h
 create mode 100644 tools/testing/radix-tree/linux/kmemleak.h
 create mode 100644 tools/testing/radix-tree/linux/mempool.h
 create mode 100644 tools/testing/radix-tree/linux/notifier.h
 create mode 100644 tools/testing/radix-tree/linux/percpu.h
 create mode 100644 tools/testing/radix-tree/linux/preempt.h
 create mode 120000 tools/testing/radix-tree/linux/radix-tree.h
 create mode 100644 tools/testing/radix-tree/linux/rcupdate.h
 create mode 100644 tools/testing/radix-tree/linux/slab.h
 create mode 100644 tools/testing/radix-tree/linux/string.h
 create mode 100644 tools/testing/radix-tree/linux/types.h
 create mode 100644 tools/testing/radix-tree/main.c
 create mode 100644 tools/testing/radix-tree/rcupdate.c
 create mode 100644 tools/testing/radix-tree/regression.h
 create mode 100644 tools/testing/radix-tree/regression1.c
 create mode 100644 tools/testing/radix-tree/regression2.c
 create mode 100644 tools/testing/radix-tree/tag_check.c
 create mode 100644 tools/testing/radix-tree/test.c
 create mode 100644 tools/testing/radix-tree/test.h

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
