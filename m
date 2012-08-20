Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2C1086B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 18:05:46 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so8652360pbb.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:05:45 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH v3 0/9] faster augmented rbtree interface
Date: Mon, 20 Aug 2012 15:05:22 -0700
Message-Id: <1345500331-10546-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

These are my proposed changes for a faster augmented rbtree interface.

Patches 1-8 are unchanged from my v2 send (in v2 they were called
patches 1 and 3-9 - patch 2 from v2 already got applied into
andrew's -mm tree). Patch 9 wasn't part of the original v2 send,
I had posted it later on as a reply to v2's patch 8/9 following a suggestion
from Peter Zijlstra. Anyway, Andrew asked me to apply the patches over
his current tree, gather the Acked-By and Reviewed-By lines from the previous
send, and resend publically, so here goes.

As noted in v2:

Patch 1 is a trivial fix for a sparse warning.

Patches 2-3 are small cleanups, mainly intended to make the code more readable.

Patches 4-5 are new (well they were in v2), based on something George
Spelvin observed in my previous RFC. It turns out that in rb_erase(),
recoloring is trivial for nodes that have exactly 1 child. We can
shave a few cycles by handling it locally, and changing
rb_erase_color() to only deal with the no-childs case.

Patch 6 adds a performance test for the augmented rbtree support.

Patch 7 introduces my proposed API for augmented rbtree support.
rb_insert_augmented() and rb_erase_augmented() are augmented versions of
rb_insert_color() and rb_erase(). They take an additional argument
(struct rb_augment_callbacks) to specify callbacks to be used to maintain
the augmented rbtree information. users have to specify 3 callbacks
through that structure. Non-augmented rbtree support is provided by
inlining dummy callbacks, so that the non-augmented case is not affected
(either in speed or in compiled size) by the new augmented rbtree API.
For augmented rbtree users, no inlining takes place at this point (I may
propose this later, but feel this shouldn't go with the initial proposal).

Patch 8 removes the old augmented rbtree interface and converts its
only user to the new interface.

Patch 9 adds an RB_DECLARE_CALLBACKS() macro so that people don't have to
write the 3 small callback functions for each augmented rbtree usage.


Overall, this series improves non-augmented rbtree speed by ~5%. For
augmented rbtree users, the new interface is ~2.5 times faster than the old.

Michel Lespinasse (9):
  rbtree test: fix sparse warning about 64-bit constant
  rbtree: add __rb_change_child() helper function
  rbtree: place easiest case first in rb_erase()
  rbtree: handle 1-child recoloring in rb_erase() instead of
    rb_erase_color()
  rbtree: low level optimizations in rb_erase()
  rbtree: augmented rbtree test
  rbtree: faster augmented rbtree manipulation
  rbtree: remove prior augmented rbtree implementation
  rbtree: add RB_DECLARE_CALLBACKS() macro

 Documentation/rbtree.txt |  190 +++++++++++++++++++++-----
 arch/x86/mm/pat_rbtree.c |   32 ++---
 include/linux/rbtree.h   |   53 ++++++-
 lib/rbtree.c             |  352 +++++++++++++++++++++++++---------------------
 lib/rbtree_test.c        |  105 +++++++++++++-
 5 files changed, 513 insertions(+), 219 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
