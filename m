Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 25DE66B025F
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:21:58 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id c20so41177282pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:21:58 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o68si6894186pfj.173.2016.04.06.14.21.50
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:50 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 00/30] Radix tree multiorder fixes
Date: Wed,  6 Apr 2016 17:21:09 -0400
Message-Id: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

I must apologise for commit f96d18ff84 which left the impression that
the support for multiorder radix tree entries was functional.  As soon as
Ross tried to use it, it became apparent that my testing was completely
inadequate, and it didn't even work a little bit for orders that were
not a multiple of shift.

This series of patches is the result of about 5 weeks of redesign,
reimplementation, testing, arguing and hair-pulling.  The great news is
that the test-suite is now far better than it was.  That's reflected in
the diffstat for the test-suite alone:
 12 files changed, 427 insertions(+), 28 deletions(-)

The highlight for users of the tree is that the restriction on the order
being >= RADIX_TREE_MAP_SHIFT is now gone; the radix tree now supports
any order between 0 and 64.

For those who are interested in how the tree works, patch 9 is probably
the most interesting one as it introduces the new machinery for handling
sibling entries.

I've tried to be fair in attributing authorship to the person who
contributed the majority of the code in each patch; Ross has been an
invaluable partner in the development of this support and it's fair to
say that each of us has code in every commit.

I should also express my appreciation of the 0day testing.  It prompted
me that I was bloating the tinyconfig in an unacceptable way, and it
bisected to a commit which contained a rahter nasty memory-corruption bug.

Matthew Wilcox (20):
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
  radix-tree: Fix several shrinking bugs with multiorder entries
  radix tree test suite: Start adding multiorder tests
  radix-tree: Rewrite __radix_tree_lookup
  radix-tree: Fix multiorder BUG_ON in radix_tree_insert
  radix-tree: add support for multi-order iterating
  radix tree test suite: Add multiorder shrinking test
  radix-tree: Fix radix_tree_create for sibling entries
  radix-tree: Rewrite radix_tree_locate_item
  radix-tree: Fix two bugs in radix_tree_range_tag_if_tagged()
  radix-tree: Add copyright statements

Ross Zwisler (10):
  radix tree test suite: Allow testing other fan-out values
  radix tree test suite: keep regression test runs short
  radix tree test suite: rebuild when headers change
  radix-tree: remove unused looping macros
  radix tree test suite: multi-order iteration test
  radix-tree: Rewrite radix_tree_tag_set
  radix-tree: Rewrite radix_tree_tag_clear
  radix-tree: Rewrite radix_tree_tag_get
  radix-tree test suite: add multi-order tag test
  radix-tree: Fix radix_tree_dump() for multi-order entries

 include/linux/radix-tree.h                    | 103 +++--
 kernel/irq/irqdomain.c                        |   7 +-
 lib/Kconfig                                   |   3 +
 lib/radix-tree.c                              | 545 +++++++++++++++-----------
 mm/Kconfig                                    |   1 +
 tools/testing/radix-tree/Makefile             |   4 +-
 tools/testing/radix-tree/generated/autoconf.h |   3 +
 tools/testing/radix-tree/linux/init.h         |   0
 tools/testing/radix-tree/linux/kernel.h       |  15 +-
 tools/testing/radix-tree/linux/slab.h         |   1 -
 tools/testing/radix-tree/linux/types.h        |   7 +-
 tools/testing/radix-tree/main.c               |  71 +++-
 tools/testing/radix-tree/multiorder.c         | 317 +++++++++++++++
 tools/testing/radix-tree/regression2.c        |   7 -
 tools/testing/radix-tree/tag_check.c          |  10 +
 tools/testing/radix-tree/test.c               |  13 +-
 tools/testing/radix-tree/test.h               |   7 +-
 17 files changed, 807 insertions(+), 307 deletions(-)
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
