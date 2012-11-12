Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 27AA06B004D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 06:51:46 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so4654845pad.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:51:45 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/3] fix missing rb_subtree_gap updates on vma insert/erase
Date: Mon, 12 Nov 2012 03:51:28 -0800
Message-Id: <1352721091-27022-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Using the trinity fuzzer, Sasha Levin uncovered a case where
rb_subtree_gap wasn't correctly updated.

Digging into this, the root cause was that vma insertions and removals
require both an rbtree insert or erase operation (which may trigger
tree rotations), and an update of the next vma's gap (which does not
change the tree topology, but may require iterating on the node's
ancestors to propagate the update). The rbtree rotations caused the
rb_subtree_gap values to be updated in some of the internal nodes, but
without upstream propagation. Then the subsequent update on the next
vma didn't iterate as high up the tree as it should have, as it
stopped as soon as it hit one of the internal nodes that had been
updated as part of a tree rotation.

The fix is to impose that all rb_subtree_gap values must be up to date
before any rbtree insertion or erase, with the possible exception that
the node being erased doesn't need to have an up to date rb_subtree_gap.

These 3 patches apply on top of the stack I previously sent (or equally,
on top of the last published mmotm).

Michel Lespinasse (3):
  mm: ensure safe rb_subtree_gap update when inserting new VMA
  mm: ensure safe rb_subtree_gap update when removing VMA
  mm: debug code to verify rb_subtree_gap updates are safe

 mm/mmap.c |  121 +++++++++++++++++++++++++++++++++++++------------------------
 1 files changed, 73 insertions(+), 48 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
