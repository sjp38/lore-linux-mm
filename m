Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B7C1E6B0296
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:24:04 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id w132so75382757ita.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:24:04 -0800 (PST)
Received: from p3plsmtps2ded01.prod.phx3.secureserver.net (p3plsmtps2ded01.prod.phx3.secureserver.net. [208.109.80.58])
        by mx.google.com with ESMTPS id 72si256575ioc.29.2016.11.16.14.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:24:03 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 00/29] Improve radix tree for 4.10
Date: Wed, 16 Nov 2016 16:16:25 -0800
Message-Id: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Hi Andrew,

Please include these patches in the -mm tree for 4.10.  Mostly these are
improvements; the only bug fixes in here relate to multiorder entries
(which as far as I'm aware remain unused).  The IDR rewrite has the
highest potential for causing mayhem as the test suite is quite spartan.
We have an Outreachy intern scheduled to work on the test suite for the
2016 winter season, so hopefully it will improve soon.

I posted a series of patches to improve the radix tree code two months
ago, and Konstantin had the quite reasonable objection that they slowed
down the iterators.  He helpfully sent out the benchmark he used.
With this revision of the patchset, I have slightly improved performance
on his benchmark.

Noteworthy changes from the last revision of the patchset:

 - Fix the existing radix tree iterator design instead of rewriting it
 - Avoid adding the new radix_tree_for_each_tagged_max iterator; just
   check in the one caller whether we've exceeded the limit.
 - Change the name of radix_tree_iter_save() back to
   radix_tree_iter_next().  I went back and forth on this one, and could
   easily be convinced to rename it as I think radix_tree_iter_save()
   makes more sense to the callers.
 - Add radix_tree_iter_delete() instead of poking around the internals
   of the radix tree in ida_destroy()
 - Add accessors for the idr cyclic allocation cursor

Patches 1-9: Test suite improvements, including Konstantin's benchmark
Patches 10-12: join/split (Kirill wants these for huge page cache)
Patches 13-17: General improvements to the radix tree
Patches 18-22: Radix tree iterator improvements
Patches 23-29: Replace the IDR with the radix tree

Konstantin Khlebnikov (1):
  radix tree test suite: benchmark for iterator

Matthew Wilcox (28):
  tools: Add WARN_ON_ONCE
  radix tree test suite: Allow GFP_ATOMIC allocations to fail
  radix tree test suite: Track preempt_count
  radix tree test suite: Free preallocated nodes
  radix tree test suite: Make runs more reproducible
  radix tree test suite: Use rcu_barrier
  tools: Add more bitmap functions
  radix tree test suite: Use common find-bit code
  radix-tree: Add radix_tree_join
  radix-tree: Add radix_tree_split
  radix-tree: Add radix_tree_split_preload()
  radix-tree: Fix typo
  radix-tree: Move rcu_head into a union with private_list
  radix-tree: Create node_tag_set()
  radix-tree: Make radix_tree_find_next_bit more useful
  radix-tree: Improve dump output
  btrfs: Fix race in btrfs_free_dummy_fs_info()
  radix tree test suite: iteration test misuses RCU
  radix tree: Improve multiorder iterators
  radix-tree: Delete radix_tree_locate_item()
  radix-tree: Delete radix_tree_range_tag_if_tagged()
  idr: Add ida_is_empty
  tpm: Use idr_find(), not idr_find_slowpath()
  rxrpc: Abstract away knowledge of IDR internals
  idr: Reduce the number of bits per level from 8 to 6
  radix tree test suite: Add some more functionality
  radix-tree: Create all_tag_set
  Reimplement IDR and IDA using the radix tree

 drivers/char/tpm/tpm-chip.c                        |    4 +-
 drivers/usb/gadget/function/f_hid.c                |    6 +-
 drivers/usb/gadget/function/f_printer.c            |    6 +-
 fs/btrfs/tests/btrfs-tests.c                       |    1 +
 include/linux/idr.h                                |  156 +--
 include/linux/radix-tree.h                         |  161 ++-
 init/main.c                                        |    3 +-
 lib/idr.c                                          | 1075 ----------------
 lib/radix-tree.c                                   | 1328 +++++++++++++++-----
 mm/khugepaged.c                                    |    2 +-
 mm/page-writeback.c                                |   28 +-
 mm/shmem.c                                         |   32 +-
 net/rxrpc/af_rxrpc.c                               |   11 +-
 net/rxrpc/conn_client.c                            |    4 +-
 tools/include/asm/bug.h                            |   11 +
 tools/include/linux/bitmap.h                       |   26 +
 tools/lib/find_bit.c                               |    8 +
 tools/testing/radix-tree/Makefile                  |   18 +-
 tools/testing/radix-tree/benchmark.c               |   98 ++
 tools/testing/radix-tree/find_next_bit.c           |   57 -
 tools/testing/radix-tree/idr.c                     |  148 +++
 tools/testing/radix-tree/iteration_check.c         |   39 +-
 tools/testing/radix-tree/linux.c                   |   23 +-
 tools/testing/radix-tree/linux/bitops.h            |   40 +-
 tools/testing/radix-tree/linux/bitops/non-atomic.h |   13 +-
 tools/testing/radix-tree/linux/bug.h               |    2 +-
 tools/testing/radix-tree/linux/gfp.h               |   22 +-
 tools/testing/radix-tree/linux/idr.h               |    1 +
 tools/testing/radix-tree/linux/kernel.h            |   20 +
 tools/testing/radix-tree/linux/preempt.h           |    6 +-
 tools/testing/radix-tree/linux/slab.h              |    6 +-
 tools/testing/radix-tree/linux/types.h             |    2 -
 tools/testing/radix-tree/main.c                    |   80 +-
 tools/testing/radix-tree/multiorder.c              |  111 +-
 tools/testing/radix-tree/regression2.c             |    3 +-
 tools/testing/radix-tree/regression3.c             |    6 +-
 tools/testing/radix-tree/tag_check.c               |    9 +-
 tools/testing/radix-tree/test.c                    |   47 +
 tools/testing/radix-tree/test.h                    |   18 +
 39 files changed, 1884 insertions(+), 1747 deletions(-)
 create mode 100644 tools/testing/radix-tree/benchmark.c
 delete mode 100644 tools/testing/radix-tree/find_next_bit.c
 create mode 100644 tools/testing/radix-tree/idr.c
 create mode 100644 tools/testing/radix-tree/linux/idr.h

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
