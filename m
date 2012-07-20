Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E6C1F6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:31:27 -0400 (EDT)
Received: by yenr5 with SMTP id r5so4810835yen.14
        for <linux-mm@kvack.org>; Fri, 20 Jul 2012 05:31:27 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 0/6] augmented rbtree changes
Date: Fri, 20 Jul 2012 05:31:01 -0700
Message-Id: <1342787467-5493-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

I've been looking at rbtrees with an eye towards improving the augmented
rbtree support, and even though I don't consider this work done, I am
getting to the stage where I would like to get feedback.

Patches 1-2 are generic rbtree improvements I came up with after sending
the previous patch series. Patch 1 makes rb_erase easier to read (IMO),
while patch 2 is another minor optimization in the rbtree rebalancing code.

Patch 3 adds an augmented rbtree test, where nodes get a new 'value' field
in addition to the existing sort key, and we want to maintain an 'augmented'
field for each node, which should be equal to the max of all 'value' fields
for nodes within that node's subtree.

Patch 4 speeds up augmented rbtree insertion. We make the handcoded search
function responsible for updating the augmented values on the path to the
insertion point, then we use a new version of rb_insert_color() which has
an added callback for updating augmented values on a tree rotation.

Patch 5 speeds up the augmented rbtree erase. Here again we use a tree
rotation callback during rebalancing; however we also have to propagate
the augmented node information above nodes being erased and/or stitched,
and I haven't found a nice enough way to do that. So for now I am proposing
the simple-stupid way of propagating all the way to the root. More on
this later.

Patch 6 removes the prior augmented API interface, and migrates its single
current user to the proposed new interface.


IMO patches 1-2 are ready for inclusion in -mm tree along with the
previous rbtree series.


I would like feedback on the rest - but first, I think I should mention
what use cases I envision for this augmented rbtree support. The way
I see it, augmented rbtree could be used in:

- Some kind of generic interval tree support, where nodes have explicit
(start, end) values. The rbtree is sorted by start order, and nodes
are augmented with a max(node->end for node in subtree) property.
arch/x86/mm/pat_rbtree.c and mm/kmemleak.c could make use of that
(instead of an ad-hoc interval tree implementations based on augmented
rbtree and prio tree respectively);

- The rbtree for all VMAs in a MM could be augmented, as suggested by Rik,
to maintain a max(empty gap before node's VMA for node in subtree) property
and support fast virtual address space allocation;

- The prio tree of all VMAs mapping a given file (struct address_space)
could be switched to an augmented rbtree based interval tree (thus removing
the prio tree library in favor of augmented rbtrees)

- I would like to introduce yet another interval tree to hold all VMAs
sharing the same anon_vma (so the linked list of all AVCs with a given
anon_vma would be replaced with an interval tree).

With these plans, each VMA could be on up to 3 separate augmented rbtrees,
so that's why I want them to be fast :)


As they stand, patches 3-6 don't seem to make a difference for basic rbtree
support, and they improve my augmented rbtree insertion/erase benchmark
by a factor of ~2.1 to ~2.3 depending on test machines.


In addition to the usual feedback about code sanity or lack thereof, I would
like to ask if I stroke the right balance on pure speed vs code size.
I think having generic functions for augmented rbtree rebalancing, with
a callback for tree rotations, is probably a decent choice given that we
might have to update several augmented rbtrees in sequence when adding or
removing VMAs.


Another point I am not fully happy with is the way I am propagating augmented
subtree information in rb_erase_augmented(). I initially tried to stop
propagating updates up as soon as a node was reached that already had the
proper augmented value. However, there are a few complications with that.

In case 2 of rb_erase_augmented(), if 'old' had the highest augmented value
in the subtree and 'node' had the next highest value, node's augmented
value is still correct after stitching it as the new root of that subtree,
but its parent's augmented value must still be adjusted as 'old', which
had the highest value in that subtree, has been removed from the subtree.

In case 3 of rb_erase_augmented(), 'node' gets stitched out of its place
and relocated to the subtree root, in place of 'old'. As a result, we
might have to propagate augmented values a few levels above node's old
location, before reaching a node that already has the right augmented
value, but is still below the point where 'old' was replaced with 'new'
which might have a lower augmented value (if 'old' had the highest
value for that subtree).

So while it would be possible to handle all these cases without propagating
all the way to the root (and it should be more efficient too - most of the
nodes in a balanced tree are on the last few levels, so having to go all
the way back to the root really is wasteful), I have not found a nice
elegant way to do that yet, let alone in a generic way. If someone wants
to try their hand at that problem, I would be very interested to see what
they can come up with.


Michel Lespinasse (6):
  rbtree: rb_erase updates and comments
  rbtree: optimize fetching of sibling node
  augmented rbtree test
  rbtree: faster augmented insert
  rbtree: faster augmented erase
  rbtree: remove prior augmented rbtree implementation

 arch/x86/mm/pat_rbtree.c        |   52 ++++++----
 include/linux/rbtree.h          |    8 --
 include/linux/rbtree_internal.h |  131 +++++++++++++++++++++++++
 lib/rbtree.c                    |  206 ++++++++-------------------------------
 lib/rbtree_test.c               |  120 ++++++++++++++++++++++-
 5 files changed, 322 insertions(+), 195 deletions(-)
 create mode 100644 include/linux/rbtree_internal.h

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
