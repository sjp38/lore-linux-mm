Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2398295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:00 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id zy2so93536617pac.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:00 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 85si7769514pfn.180.2016.04.14.07.37.41
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:41 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 00/19] Radix tree cleanups
Date: Thu, 14 Apr 2016 10:37:03 -0400
Message-Id: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

This patch series applies on top of the radix-fixes series I sent
recently.

It aims to improve the radix tree by making the code more understandable
and has the nice side-effect of shrinking the code size on i386-tinyconfig
by about 250 bytes.  The 'height' concept is entirely gone from the code
by patch 7 of the series.  We eliminate most of the tricky arithmetic
on index.  This paves the way towards allowing different shift amounts
at different layers of the tree, something I know various people are
interested in.

It integrates two of the patches from Neil Brown which are pre-requisites
for locking exceptional entries.

We end up deleting almost a hundred lines of code from the kernel
(excluding the test-suite).

Matthew Wilcox (18):
  drivers/hwspinlock: Use correct radix tree API
  radix-tree: Miscellaneous fixes
  radix-tree: Split node->path into offset and height
  radix-tree: Replace node->height with node->shift
  radix-tree: Remove a use of root->height from delete_node
  radix tree test suite: Remove dependencies on height
  radix-tree: Remove root->height
  radix-tree: Rename INDIRECT_PTR to INTERNAL_NODE
  radix-tree: Rename ptr_to_indirect() to node_to_entry()
  radix-tree: Rename indirect_to_ptr() to entry_to_node()
  radix-tree: Rename radix_tree_is_indirect_ptr()
  radix-tree: Change naming conventions in radix_tree_shrink
  radix-tree: Tidy up next_chunk
  radix-tree: Tidy up range_tag_if_tagged
  radix-tree: Tidy up __radix_tree_create()
  radix-tree: Introduce radix_tree_replace_clear_tags()
  radix-tree: Make radix_tree_descend() more useful
  radix-tree: Free up the bottom bit of exceptional entries for reuse

NeilBrown (1):
  dax: move RADIX_DAX_ definitions to dax.c

 drivers/hwspinlock/hwspinlock_core.c  |   2 +-
 fs/dax.c                              |   9 +
 include/linux/radix-tree.h            |  94 +++---
 lib/radix-tree.c                      | 577 +++++++++++++++-------------------
 mm/filemap.c                          |  23 +-
 tools/testing/radix-tree/multiorder.c |  99 +++---
 tools/testing/radix-tree/test.c       |  36 ++-
 tools/testing/radix-tree/test.h       |   4 +-
 8 files changed, 385 insertions(+), 459 deletions(-)

-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
