Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DF62E6B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:34:31 -0400 (EDT)
Received: by yenr5 with SMTP id r5so78993yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 15:34:31 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v2 0/9] faster augmented rbtree interface
Date: Thu,  2 Aug 2012 15:34:09 -0700
Message-Id: <1343946858-8170-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

These are my proposed changes for a faster augmented rbtree interface.
They are implemented on top of a previous patch series that is already
in Andrew's -mm tree, and I feel they are ready to join it.

Patch 1 is a trivial fix for a sparse warning.

Patch 2 is a small optimization I already sent as part of my previous RFC.
Rik had ACKed it.

Patches 3-4 are small cleanups, mainly intended to make the code more readable.

Patches 5-6 are new, based on something George Spelvin observed in my
previous RFC. It turns out that in rb_erase(), recoloring is trivial for
nodes that have exactly 1 child. We can shave a few cycles by handling it
locally, and changing rb_erase_color() to only deal with the no-childs case.

Patch 7 adds a performance test for the augmented rbtree support.

Patch 8 introduces my proposed API for augmented rbtree support.
rb_insert_augmented() and rb_erase_augmented() are augmented versions of
rb_insert_color() and rb_erase(). They take an additional argument
(struct rb_augment_callbacks) to specify callbacks to be used to maintain
the augmented rbtree information. users have to specify 3 callbacks
through that structure. Non-augmented rbtree support is provided by
inlining dummy callbacks, so that the non-augmented case is not affected
(either in speed or in compiled size) by the new augmented rbtree API.
For augmented rbtree users, no inlining takes place at this point (I may
propose this later, but feel this shouldn't go with the initial proposal). 

Patch 9 removes the old augmented rbtree interface and converts its
only user to the new interface.


Overall, this series improves non-augmented rbtree speed by ~5%. For
augmented rbtree users, the new interface is ~2.5 times faster than the old.

Michel Lespinasse (9):
  rbtree test: fix sparse warning about 64-bit constant
  rbtree: optimize fetching of sibling node
  rbtree: add __rb_change_child() helper function
  rbtree: place easiest case first in rb_erase()
  rbtree: handle 1-child recoloring in rb_erase() instead of
    rb_erase_color()
  rbtree: low level optimizations in rb_erase()
  rbtree: augmented rbtree test
  rbtree: faster augmented rbtree manipulation
  rbtree: remove prior augmented rbtree implementation

 Documentation/rbtree.txt |  190 ++++++++++++++++++++----
 arch/x86/mm/pat_rbtree.c |   65 ++++++---
 include/linux/rbtree.h   |   23 ++-
 lib/rbtree.c             |  370 +++++++++++++++++++++++++---------------------
 lib/rbtree_test.c        |  135 ++++++++++++++++-
 5 files changed, 557 insertions(+), 226 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
