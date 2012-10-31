Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id EE3C76B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 06:33:38 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so971403pbb.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:33:38 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [RFC PATCH 0/6] mm: use augmented rbtrees for finding unmapped areas
Date: Wed, 31 Oct 2012 03:33:19 -0700
Message-Id: <1351679605-4816-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

Earlier this year, Rik proposed using augmented rbtrees to optimize
our search for a suitable unmapped area during mmap(). This prompted
my work on improving the augmented rbtree code. Rik doesn't seem to
have time to follow up on his idea at this time, so I'm sending this
series to revive the idea.

These changes are against v3.7-rc3. I have only converted the generic
and x86_64 search implementations so far, as I'm really looking for
comments on the general approach; however it shouldn't be too
difficult to convert other architectures in the same way (and
eventually the drivers that define their own f_op->get_unmapped_area
method as well).

Patch 1 augments the VMA rbtree with a new rb_subtree_gap field,
indicating the length of the largest gap immediately preceding any
VMAs in a subtree.

Patch 2 adds new checks to CONFIG_DEBUG_VM_RB to verify the above
information is correctly maintained.

Patch 3 rearranges the vm_area_struct layout so that rbtree searches only
need data that is contained in the first cacheline (this one is from
Rik's original patch series)

Patch 4 adds a generic vm_unmapped_area() search function, which
allows for searching for an address space of any desired length,
within [low; high[ address constraints, with any desired alignment.
The generic arch_get_unmapped_area[_topdown] functions are also converted
to use this.

Patch 5 converts the x86_64 arch_get_unmapped_area[_topdown] functions
to use vm_unmapped_area() as well.

Patch 6 fixes cache coloring on x86_64, as suggested by Rik in his
previous series.

My own feel for this series is that I'm fairly confident in the
robustness of my vm_unmapped_area() implementation; however I would
like to confirm that people are happy with this new interface. Also
the code that figures out what constraints to pass to
vm_unmapped_area() is a bit odd; I have tried to make the constraints
match the behavior of the current code but it's not clear to me if
that behavior makes sense in the first place.

There is also the question of performance. I remember from IRC
conversations that someone (I think it was Mel ?) had found some
regressions with Rik's prior proposal. My current proposal is
significantly faster at updating the rbtrees; however there is still
the fact that vm_unmapped_area() does not use a free area cache as the
old brute-force implementation did. I don't expect that to be a
problem, but I have not confirmed yet if the prior regressions are
gone (and if they are still present, one would want to find out if
they are introduced by rbtree maintainance in Patch 1, or by removing
the free area cache as part of patches 4/5).

Michel Lespinasse (5):
  mm: augment vma rbtree with rb_subtree_gap
  mm: check rb_subtree_gap correctness
  mm: vm_unmapped_area() lookup function
  mm: use vm_unmapped_area() on x86_64 architecture
  mm: fix cache coloring on x86_64

Rik van Riel (1):
  mm: rearrange vm_area_struct for fewer cache misses

 arch/x86/include/asm/elf.h   |    6 +-
 arch/x86/kernel/sys_x86_64.c |  151 +++-----------
 arch/x86/vdso/vma.c          |    2 +-
 include/linux/mm.h           |   31 +++
 include/linux/mm_types.h     |   19 ++-
 mm/mmap.c                    |  450 ++++++++++++++++++++++++++++++++----------
 6 files changed, 423 insertions(+), 236 deletions(-)

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
