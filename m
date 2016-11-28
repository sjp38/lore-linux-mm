Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37D4A6B02AE
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 14:58:13 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id r94so259014598ioe.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 11:58:13 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id t18si19990967itb.43.2016.11.28.11.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Nov 2016 11:56:38 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH v3 00/33] Radix tree patches for 4.10
Date: Mon, 28 Nov 2016 13:50:04 -0800
Message-Id: <1480369871-5271-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Hi Andrew,

Please include these patches in the -mm tree for 4.10.  Mostly these
are improvements; the only bug fixes in here relate to multiorder
entries (which are unused in the 4.9 tree).  The IDR rewrite has the
highest potential for causing mayhem as the test suite is quite spartan.
We have an Outreachy intern scheduled to work on the test suite for the
2016 winter season, so hopefully it will improve soon.

I did not include Konstantin's suggested change to the API for
radix_tree_iter_resume().  Many of the callers do not currently care
about the size of the entry they are consuming, and determining that
information is not always trivial.  Since this is not a performance
critical API (it's called when we've paused iterating through a tree
in order to schedule for a higher priority task), I think it's more
important to have a simpler interface.

I'd like to thank Kiryl for all the testing he's been doing.  He's found
at least two bugs which weren't related to the API extensions that he
really wanted from this patch set.

Noteworthy changes from v2:

 - Rebased on latest mmots tree
 - Various fixes to accommodate Johannes' exceptional entry accounting changes
 - Renamed radix_tree_iter_next() to radix_tree_iter_resume()
 - Add kerneldoc to radix_tree_iter_join(), radix_tree_iter_split(), and
   partially to struct radix_tree_node.
 - Factor set_iter_tags() out of radix_tree_next_chunk() and use it in
   __radix_tree_next_slot().
 - Rename __radix_tree_iter_next() to skip_siblings() and only compile it in
   when MULTIORDER is supported.
Test suite:
 - Record item order
 - Added an IDR replace test
 - Improve iteration test to handle multiorder entries
 - More tests to check exceptional entry accounting
 - Handle exceptional entries in item_kill_tree()

Konstantin Khlebnikov (1):
  radix tree test suite: benchmark for iterator

Matthew Wilcox (32):
  radix tree test suite: Fix compilation
  tools: Add WARN_ON_ONCE
  radix tree test suite: Allow GFP_ATOMIC allocations to fail
  radix tree test suite: Track preempt_count
  radix tree test suite: Free preallocated nodes
  radix tree test suite: Make runs more reproducible
  radix tree test suite: iteration test misuses RCU
  radix tree test suite: Use rcu_barrier
  radix tree test suite: Handle exceptional entries
  radix tree test suite: record order in each item
  tools: Add more bitmap functions
  radix tree test suite: Use common find-bit code
  radix-tree: Fix typo
  radix-tree: Move rcu_head into a union with private_list
  radix-tree: Create node_tag_set()
  radix-tree: Make radix_tree_find_next_bit more useful
  radix-tree: Improve dump output
  btrfs: Fix race in btrfs_free_dummy_fs_info()
  radix-tree: Improve multiorder iterators
  radix-tree: Delete radix_tree_locate_item()
  radix-tree: Delete radix_tree_range_tag_if_tagged()
  radix-tree: Add radix_tree_join
  radix-tree: Add radix_tree_split
  radix-tree: Add radix_tree_split_preload()
  radix-tree: Fix replacement for multiorder entries
  radix tree test suite: Check multiorder iteration
  idr: Add ida_is_empty
  tpm: Use idr_find(), not idr_find_slowpath()
  rxrpc: Abstract away knowledge of IDR internals
  idr: Reduce the number of bits per level from 8 to 6
  radix tree test suite: Add some more functionality
  Reimplement IDR and IDA using the radix tree

 drivers/char/tpm/tpm-chip.c                        |    4 +-
 drivers/usb/gadget/function/f_hid.c                |    6 +-
 drivers/usb/gadget/function/f_printer.c            |    6 +-
 fs/btrfs/tests/btrfs-tests.c                       |    1 +
 include/linux/idr.h                                |  156 +-
 include/linux/radix-tree.h                         |  179 +--
 init/main.c                                        |    3 +-
 lib/idr.c                                          | 1078 --------------
 lib/radix-tree.c                                   | 1526 +++++++++++++++-----
 mm/khugepaged.c                                    |    7 +-
 mm/page-writeback.c                                |   28 +-
 mm/shmem.c                                         |   32 +-
 net/rxrpc/af_rxrpc.c                               |   11 +-
 net/rxrpc/conn_client.c                            |    4 +-
 tools/include/asm/bug.h                            |   11 +
 tools/include/linux/bitmap.h                       |   26 +
 tools/testing/radix-tree/Makefile                  |   18 +-
 tools/testing/radix-tree/benchmark.c               |   98 ++
 tools/testing/radix-tree/find_next_bit.c           |   57 -
 tools/testing/radix-tree/idr.c                     |  160 ++
 tools/testing/radix-tree/iteration_check.c         |  123 +-
 tools/testing/radix-tree/linux.c                   |   23 +-
 tools/testing/radix-tree/linux/bitops.h            |   40 +-
 tools/testing/radix-tree/linux/bitops/non-atomic.h |   13 +-
 tools/testing/radix-tree/linux/bug.h               |    2 +-
 tools/testing/radix-tree/linux/cpu.h               |   22 +-
 tools/testing/radix-tree/linux/gfp.h               |   22 +-
 tools/testing/radix-tree/linux/idr.h               |    1 +
 tools/testing/radix-tree/linux/kernel.h            |   20 +
 tools/testing/radix-tree/linux/notifier.h          |    8 -
 tools/testing/radix-tree/linux/preempt.h           |    6 +-
 tools/testing/radix-tree/linux/slab.h              |    6 +-
 tools/testing/radix-tree/linux/types.h             |    2 -
 tools/testing/radix-tree/main.c                    |   83 +-
 tools/testing/radix-tree/multiorder.c              |  289 +++-
 tools/testing/radix-tree/regression2.c             |    3 +-
 tools/testing/radix-tree/regression3.c             |    8 +-
 tools/testing/radix-tree/tag_check.c               |    9 +-
 tools/testing/radix-tree/test.c                    |   92 +-
 tools/testing/radix-tree/test.h                    |   23 +-
 40 files changed, 2311 insertions(+), 1895 deletions(-)
 create mode 100644 tools/testing/radix-tree/benchmark.c
 delete mode 100644 tools/testing/radix-tree/find_next_bit.c
 create mode 100644 tools/testing/radix-tree/idr.c
 create mode 100644 tools/testing/radix-tree/linux/idr.h
 delete mode 100644 tools/testing/radix-tree/linux/notifier.h

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
