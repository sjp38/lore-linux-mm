Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 31D276B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 05:21:12 -0400 (EDT)
Received: by dadi14 with SMTP id i14so4546695dad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 02:21:11 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/7] use interval trees for anon rmap
Date: Tue,  4 Sep 2012 02:20:50 -0700
Message-Id: <1346750457-12385-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org

This patch series applies on top of the previous ones currently queued
into Andrew's -mm tree (the rbtree, augmented rbtree and interval tree
changes).

The goal here is to use interval trees to replace the same_anon_vma
linked list, and avoid anon rmap scalability issues when a given
process has many vmas linked onto the same anon_vma (as can easily
happen when a large vma is broken up into smaller chunks using
mprotect or munmap).

Patch 1 modifies the generic interval tree implementation and as such,
it can be seen as an amendment to the previous patch series which had
introduced it.

Patch 2 makes the anon_vma locking more strict in vma_adjust(), fixing
an issue I noticed when mprotect adjusts the boundary between two vmas
and only the second one has an anon_vma assigned.

Patch 3 makes the anon_vma locking more strict in move_ptes(). This is
a temporary solution to make things simpler while the anon rmap interval
tree is being introduced. Patch 7 later relaxes the locking again for the
most common cases.

Patch 4 implements the anon rmap interval tree and uses it to replace the
same_anon_vma linked list.

Patch 5 eliminates the error case in vma_address() - the call sites
have gotten their vma's from an interval tree so that the desired
pgoff (and address) are guaranteed to fall within the vma's interval.

Patch 6 adds a build option for the existing DEBUG_MM_RB code, and
extends it to check that vma's intervals have not been modified since
the vmas were added onto their interval trees.

Patch 7 avoids taking rmap locks in move_ptes() during exec() and for the
common cases of mremap(). The most common case where mremap() would still
take these locks would be if part of a large vma had been previously moved
and is now being moved back to its original location. I don't expect this
to be very frequent, though, so move_ptes() should be as efficient as it
was before patch 3 for all likely cases.

Michel Lespinasse (7):
  mm: interval tree updates
  mm: fix potential anon_vma locking issue in mprotect()
  mm anon rmap: remove anon_vma_moveto_tail
  mm anon rmap: replace same_anon_vma linked list with an interval tree.
  mm rmap: remove vma_address check for address inside vma
  mm: add CONFIG_DEBUG_VM_RB build option
  mm: avoid taking rmap locks in move_ptes()

 fs/exec.c                             |    2 +-
 include/linux/interval_tree_generic.h |  191 ++++++++++++++++++++++++++++
 include/linux/interval_tree_tmpl.h    |  219 ---------------------------------
 include/linux/mm.h                    |   29 ++++-
 include/linux/rmap.h                  |   15 ++-
 kernel/fork.c                         |    7 +-
 lib/Kconfig.debug                     |    9 ++
 lib/interval_tree.c                   |   15 +--
 mm/huge_memory.c                      |    9 +-
 mm/interval_tree.c                    |  109 ++++++++++++-----
 mm/ksm.c                              |    9 +-
 mm/memory-failure.c                   |    5 +-
 mm/mmap.c                             |  100 +++++++++++-----
 mm/mremap.c                           |   65 ++++++----
 mm/rmap.c                             |  117 +++++-------------
 15 files changed, 484 insertions(+), 417 deletions(-)
 create mode 100644 include/linux/interval_tree_generic.h
 delete mode 100644 include/linux/interval_tree_tmpl.h

-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
