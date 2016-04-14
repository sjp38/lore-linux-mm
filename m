Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D5EE6B0253
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:19:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so131077592pfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:19:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o81si7710341pfa.174.2016.04.14.07.19.15
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:19:15 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 00/29] Radix tree multiorder fixes
Date: Thu, 14 Apr 2016 10:16:21 -0400
Message-Id: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

I must apologise for commit f96d18ff84 which left the impression that
the support for multiorder radix tree entries was functional.  As soon as
Ross tried to use it, it became apparent that my testing was completely
inadequate, and it didn't even work a little bit for orders that were
not a multiple of shift.

This series of patches is the result of about 6 weeks of redesign,
reimplementation, testing, arguing and hair-pulling.  The great news is
that the test-suite is now far better than it was.  That's reflected in
the diffstat for the test-suite alone:
 12 files changed, 436 insertions(+), 28 deletions(-)

The highlight for users of the tree is that the restriction on the order
of inserted entries being >= RADIX_TREE_MAP_SHIFT is now gone; the radix
tree now supports any order between 0 and 64.

For those who are interested in how the tree works, patch 9 is probably
the most interesting one as it introduces the new machinery for handling
sibling entries.

I've tried to be fair in attributing authorship to the person who
contributed the majority of the code in each patch; Ross has been an
invaluable partner in the development of this support and it's fair to
say that each of us has code in every commit.

I should also express my appreciation of the 0day testing.  It prompted
me that I was bloating the tinyconfig in an unacceptable way, and it
bisected to a commit which contained a rather nasty memory-corruption bug.

Changes since v1:

 - Rename get_sibling_offset() to get_slot_offset()
 - Use get_slot_offset() in radix_tree_insert() instead of doing arithmetic
 - Use get_slot_offset() in radix_tree_descend()
 - Some whitespace fixes
 - Fix race in radix_tree_next_chunk() against a multiorder insertion
 - Reduce the nuber of ifdefs by introducing iter_shift()
 - Fix some minor bugs in radix_tree_dump()
 - Merge the commit to fix shrinking bugs with the commit to add a test case
   for the shrinking code
 - Fix a bug in radix_tree_range_tag_if_tagged() if the first index was an
   alias of a multiorder entry
 - Add more test-cases to the test suite
 - Make __radix_tree_lookup fit the same pattern as the other tree walkers

Matthew Wilcox (18):
  radix-tree: Introduce radix_tree_empty
  radix tree test suite: Fix build
  radix tree test suite: Add tests for radix_tree_locate_item()
  Introduce CONFIG_RADIX_TREE_MULTIORDER
  radix-tree: Add missing sibling entry functionality
  radix-tree: Fix sibling entry insertion
  radix-tree: Fix deleting a multi-order entry through an alias
  radix-tree: Remove restriction on multi-order entries
  radix-tree: Introduce radix_tree_load_root()
  radix-tree: Fix extending the tree for multi-order entries at offset 0
  radix tree test suite: Start adding multiorder tests
  radix-tree: Fix several shrinking bugs with multiorder entries
  radix-tree: Rewrite __radix_tree_lookup
  radix-tree: Fix multiorder BUG_ON in radix_tree_insert
  radix-tree: Fix radix_tree_create for sibling entries
  radix-tree: Rewrite radix_tree_locate_item
  radix-tree: Fix radix_tree_range_tag_if_tagged() for multiorder
    entries
  radix-tree: Add copyright statements

Ross Zwisler (11):
  radix tree test suite: Allow testing other fan-out values
  radix tree test suite: keep regression test runs short
  radix tree test suite: rebuild when headers change
  radix-tree: remove unused looping macros
  radix-tree: add support for multi-order iterating
  radix tree test suite: multi-order iteration test
  radix-tree: Rewrite radix_tree_tag_set
  radix-tree: Rewrite radix_tree_tag_clear
  radix-tree: Rewrite radix_tree_tag_get
  radix-tree test suite: add multi-order tag test
  radix-tree: Fix radix_tree_dump() for multi-order entries

 include/linux/radix-tree.h                    | 106 +++--
 kernel/irq/irqdomain.c                        |   7 +-
 lib/Kconfig                                   |   3 +
 lib/radix-tree.c                              | 611 ++++++++++++++------------
 mm/Kconfig                                    |   1 +
 tools/testing/radix-tree/Makefile             |   4 +-
 tools/testing/radix-tree/generated/autoconf.h |   3 +
 tools/testing/radix-tree/linux/init.h         |   0
 tools/testing/radix-tree/linux/kernel.h       |  15 +-
 tools/testing/radix-tree/linux/slab.h         |   1 -
 tools/testing/radix-tree/linux/types.h        |   7 +-
 tools/testing/radix-tree/main.c               |  71 ++-
 tools/testing/radix-tree/multiorder.c         | 326 ++++++++++++++
 tools/testing/radix-tree/regression2.c        |   7 -
 tools/testing/radix-tree/tag_check.c          |  10 +
 tools/testing/radix-tree/test.c               |  13 +-
 tools/testing/radix-tree/test.h               |   7 +-
 17 files changed, 845 insertions(+), 347 deletions(-)
 create mode 100644 tools/testing/radix-tree/generated/autoconf.h
 create mode 100644 tools/testing/radix-tree/linux/init.h
 create mode 100644 tools/testing/radix-tree/multiorder.c

-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
