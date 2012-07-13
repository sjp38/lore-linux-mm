Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8FCCE6B005D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 20:32:21 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5512005pbb.14
        for <linux-mm@kvack.org>; Thu, 12 Jul 2012 17:32:20 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 00/12] rbtree updates
Date: Thu, 12 Jul 2012 17:31:45 -0700
Message-Id: <1342139517-3451-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com, dwmw2@infradead.org, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, axboe@kernel.dk, ebiederm@xmission.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Change log since v1:
- Added tree graphs as comments as suggested by Peter
- Fixed coding style in rest of lib/rbtree.c as suggested by Peter
- made clear rb_parent_color is private, not to be directly accessed,
  by renaming it to __rb_parent_color
- collapsed some low level optimization patches instead of splitting out
  the parts that were related to tree rotatoins from the parts that were
  related to color flips.
- Added build system support in patch 5

These are quite minor changes against v1, which already got good reviews
from Peter, so I think all that is required now is for Andrea to say he
doesn't oppose this.

--

I recently started looking at the rbtree code (with an eye towards
improving the augmented rbtree support, but I haven't gotten there
yet). I noticed a lot of possible speed improvements, which I am now
proposing in this patch set.

Patches 1-4 are preparatory: remove internal functions from rbtree.h
so that users won't be tempted to use them instead of the documented
APIs, clean up some incorrect usages I've noticed (in particular, with
the recently added fs/proc/proc_sysctl.c rbtree usage), reference the
documentation so that people have one less excuse to miss it, etc.

Patch 5 is a small module I wrote to check the rbtree performance.
It creates 100 nodes with random keys and repeatedly inserts and erases
them from an rbtree. Additionally, it has code to check for rbtree
invariants after each insert or erase operation.

Patches 6-12 is where the rbtree optimizations are done, and they touch
only that one file, lib/rbtree.c . I am getting good results out of these -
in my small benchmark doing rbtree insertion (including search) and erase,
I'm seeing a 30% runtime reduction on Sandybridge E5, which is more than
I initially thought would be possible. (the results aren't as impressive
on my two other test hosts though, AMD barcelona and Intel Westmere, where
I am seeing 14% runtime reduction only). The code size - both source
(ommiting comments) and compiled - is also shorter after these changes.
However, I do admit that the updated code is more arduous to read - one
big reason for that is the removal of the tree rotation helpers, which
added some overhead but also made it easier to reason about things locally.
Overall, I believe this is an acceptable compromise, given that this code
doesn't get modified very often, and that I have good tests for it.

Upon Peter's suggestion, I added comments showing the rtree configuration
before every rotation. I think they help; however it's still best to have
a copy of the cormen/leiserson/rivest book when digging into this code.

This patchset is against v3.4. This code doesn't change very often, so
the patchset should apply to the latest and greatest too.

My proposal would be for this to go in -mm tree to be used as a base to add
on the augmented rbtree support enhancements, which I am already working on.

Michel Lespinasse (12):
  rbtree: reference Documentation/rbtree.txt for usage instructions
  rbtree: empty nodes have no color
  rbtree: fix incorrect rbtree node insertion in fs/proc/proc_sysctl.c
  rbtree: move some implementation details from rbtree.h to rbtree.c
  rbtree: performance and correctness test
  rbtree: break out of rb_insert_color loop after tree rotation
  rbtree: adjust root color in rb_insert_color() only when necessary
  rbtree: low level optimizations in rb_insert_color()
  rbtree: adjust node color in __rb_erase_color() only when necessary
  rbtree: optimize case selection logic in __rb_erase_color()
  rbtree: low level optimizations in __rb_erase_color()
  rbtree: coding style adjustments

 Makefile                   |    2 +-
 fs/proc/proc_sysctl.c      |    5 +-
 include/linux/rbtree.h     |  112 ++---------
 include/linux/timerqueue.h |    2 +-
 lib/Kconfig.debug          |    1 +
 lib/rbtree.c               |  487 ++++++++++++++++++++++++++++----------------
 tests/Kconfig              |   18 ++
 tests/Makefile             |    1 +
 tests/rbtree_test.c        |  135 ++++++++++++
 9 files changed, 487 insertions(+), 276 deletions(-)
 create mode 100644 tests/Kconfig
 create mode 100644 tests/Makefile
 create mode 100644 tests/rbtree_test.c

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
