Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 607986B005A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 03:26:00 -0400 (EDT)
Received: by ggnf4 with SMTP id f4so1324142ggn.14
        for <linux-mm@kvack.org>; Tue, 07 Aug 2012 00:25:59 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/5] rbtree based interval tree as a prio_tree replacement
Date: Tue,  7 Aug 2012 00:25:38 -0700
Message-Id: <1344324343-3817-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, vrajesh@umich.edu, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

This patchset goes over the rbtree changes that have been already integrated
into Andrew's -mm tree, as well as the augmented rbtree proposal which is
currently pending.

Patch 1 implements support for interval trees, on top of the augmented
rbtree API. It also adds synthetic tests to compare the performance of
interval trees vs prio trees. Short answers is that interval trees are
slightly faster (~25%) on insert/erase, and much faster (~2.4 - 3x)
on search. It is debatable how realistic the synthetic test is, and I have
not made such measurements yet, but my impression is that interval trees
would still come out faster.

Patch 2 uses a preprocessor template to make the interval tree generic,
and uses it as a replacement for the vma prio_tree.

Patch 3 takes the other prio_tree user, kmemleak, and converts it to use
a basic rbtree. We don't actually need the augmented rbtree support here
because the intervals are always non-overlapping.

Patch 4 removes the now-unused prio tree library.

Patch 5 proposes an additional optimization to rb_erase_augmented, now
providing it as an inline function so that the augmented callbacks can be
inlined in. This provides an additional 5-10% performance improvement
for the interval tree insert/erase benchmark. There is a maintainance cost
as it exposes augmented rbtree users to some of the rbtree library internals;
however I think this cost shouldn't be too high as I expect the augmented
rbtree will always have much less users than the base rbtree.

I should probably add a quick summary of why I think it makes sense to
replace prio trees with augmented rbtree based interval trees now.
One of the drivers is that we need augmented rbtrees for Rik's vma
gap finding code, and once you have them, it just makes sense to use them
for interval trees as well, as this is the simpler and more well known
algorithm. prio trees, in comparison, seem *too* clever: they impose an
additional 'heap' constraint on the tree, which they use to guarantee
a faster worst-case complexity of O(k+log N) for stabbing queries in a
well-balanced prio tree, vs O(k*log N) for interval trees (where k=number
of matches, N=number of intervals). Now this sounds great, but in practice
prio trees don't realize this theorical benefit. First, the additional
constraint makes them harder to update, so that the kernel implementation
has to simplify things by balancing them like a radix tree, which is not
always ideal. Second, the fact that there are both index and heap
properties makes both tree manipulation and search more complex,
which results in a higher multiplicative time constant. As it turns out,
the simple interval tree algorithm ends up running faster than the more
clever prio tree.

Michel Lespinasse (5):
  rbtree: add prio tree and interval tree tests
  mm: replace vma prio_tree with an interval tree
  kmemleak: use rbtree instead of prio tree
  prio_tree: remove
  rbtree: move augmented rbtree functionality to rbtree_augmented.h

 Documentation/00-INDEX             |    2 -
 Documentation/prio_tree.txt        |  107 --------
 Documentation/rbtree.txt           |   13 +
 arch/arm/mm/fault-armv.c           |    3 +-
 arch/arm/mm/flush.c                |    3 +-
 arch/parisc/kernel/cache.c         |    3 +-
 arch/x86/mm/hugetlbpage.c          |    3 +-
 arch/x86/mm/pat_rbtree.c           |    2 +-
 fs/hugetlbfs/inode.c               |    9 +-
 fs/inode.c                         |    2 +-
 include/linux/fs.h                 |    6 +-
 include/linux/interval_tree.h      |   27 ++
 include/linux/interval_tree_tmpl.h |  219 +++++++++++++++++
 include/linux/mm.h                 |   30 ++-
 include/linux/mm_types.h           |   14 +-
 include/linux/prio_tree.h          |  120 ---------
 include/linux/rbtree.h             |   48 ----
 include/linux/rbtree_augmented.h   |  223 +++++++++++++++++
 init/main.c                        |    2 -
 kernel/events/uprobes.c            |    3 +-
 kernel/fork.c                      |    2 +-
 lib/Kconfig.debug                  |    6 +
 lib/Makefile                       |    5 +-
 lib/interval_tree.c                |   13 +
 lib/interval_tree_test_main.c      |  105 ++++++++
 lib/prio_tree.c                    |  466 ------------------------------------
 lib/rbtree.c                       |  162 +------------
 lib/rbtree_test.c                  |    2 +-
 mm/Makefile                        |    4 +-
 mm/filemap_xip.c                   |    3 +-
 mm/fremap.c                        |    2 +-
 mm/hugetlb.c                       |    3 +-
 mm/interval_tree.c                 |   61 +++++
 mm/kmemleak.c                      |   98 ++++----
 mm/memory-failure.c                |    3 +-
 mm/memory.c                        |    9 +-
 mm/mmap.c                          |   22 +-
 mm/nommu.c                         |   12 +-
 mm/prio_tree.c                     |  208 ----------------
 mm/rmap.c                          |   18 +-
 40 files changed, 803 insertions(+), 1240 deletions(-)
 delete mode 100644 Documentation/prio_tree.txt
 create mode 100644 include/linux/interval_tree.h
 create mode 100644 include/linux/interval_tree_tmpl.h
 delete mode 100644 include/linux/prio_tree.h
 create mode 100644 include/linux/rbtree_augmented.h
 create mode 100644 lib/interval_tree.c
 create mode 100644 lib/interval_tree_test_main.c
 delete mode 100644 lib/prio_tree.c
 create mode 100644 mm/interval_tree.c
 delete mode 100644 mm/prio_tree.c

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
