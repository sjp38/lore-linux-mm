Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 505B26B025B
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:52 -0500 (EST)
Received: by padhx2 with SMTP id hx2so59432560pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:52 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id un9si7295761pac.89.2015.11.18.15.25.51
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/9] RFD: huge tmpfs: compound vs. team pages
Date: Thu, 19 Nov 2015 01:25:27 +0200
Message-Id: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello everybody,

The code below the cover letter is not intended for inclusion or rigorous
review. It's rather an excuse to start discussion on how we want to
implement huge pages in shmem/tmpfs and in page cache in general.

Back in February Hugh posted[1] his implementation of huge pages in tmpfs.
There wasn't fallow ups with the patchset since then, but as far as I
know the implementation is in use within Google.

The implementation is built around new concept of "team pages". It's a new
way couple small pages together to be able map them as huge. It's intended
to be used instead of compound pages as more flexible mechanism which fits
better for page cache.

I believe THP refcounting rework made team pages unnecessary: compound
page are flexible enough to serve needs of page cache.

Of course, the only way to prove the claim is "show the code" :)

I've started playing with this and you can checkout my early prototype in
this patchset. Don't expect much: I still learn tmpfs code and it goes
slowly. It can handle only very basic use-cases at the moment.

It would make my life easier if we could agree on what base for huge tmpfs
we want to see upstream and move forward together.

I would really like to see collaboration on this effort. At least one
company with tmpfs expert seems interested in the feature. ;)

Any comments?

[1] http://lkml.kernel.org/g/alpine.LSU.2.11.1502201941340.14414@eggly.anvils

Kirill A. Shutemov (9):
  mm: do not pass mm_struct into handle_mm_fault
  mm: introduce fault_env
  mm: postpone page table allocation until do_set_pte()
  mm: introduce do_set_pmd()
  radix-tree: implement radix_tree_maybe_preload_order()
  rmap: support file THP
  thp: support file pages in zap_huge_pmd()
  thp: handle file pages in split_huge_pmd()
  WIP: shmem: add huge pages support

 Documentation/filesystems/Locking |  10 +-
 arch/alpha/mm/fault.c             |   2 +-
 arch/arc/mm/fault.c               |   2 +-
 arch/arm/mm/fault.c               |   2 +-
 arch/arm64/mm/fault.c             |   2 +-
 arch/avr32/mm/fault.c             |   2 +-
 arch/cris/mm/fault.c              |   2 +-
 arch/frv/mm/fault.c               |   2 +-
 arch/hexagon/mm/vm_fault.c        |   2 +-
 arch/ia64/mm/fault.c              |   2 +-
 arch/m32r/mm/fault.c              |   2 +-
 arch/m68k/mm/fault.c              |   2 +-
 arch/metag/mm/fault.c             |   2 +-
 arch/microblaze/mm/fault.c        |   2 +-
 arch/mips/mm/fault.c              |   2 +-
 arch/mn10300/mm/fault.c           |   2 +-
 arch/nios2/mm/fault.c             |   2 +-
 arch/openrisc/mm/fault.c          |   2 +-
 arch/parisc/mm/fault.c            |   2 +-
 arch/powerpc/mm/copro_fault.c     |   2 +-
 arch/powerpc/mm/fault.c           |   2 +-
 arch/s390/mm/fault.c              |   2 +-
 arch/score/mm/fault.c             |   2 +-
 arch/sh/mm/fault.c                |   2 +-
 arch/sparc/mm/fault_32.c          |   4 +-
 arch/sparc/mm/fault_64.c          |   2 +-
 arch/tile/mm/fault.c              |   2 +-
 arch/um/kernel/trap.c             |   2 +-
 arch/unicore32/mm/fault.c         |   2 +-
 arch/x86/mm/fault.c               |   2 +-
 arch/xtensa/mm/fault.c            |   2 +-
 drivers/iommu/amd_iommu_v2.c      |   2 +-
 fs/userfaultfd.c                  |  22 +-
 include/linux/huge_mm.h           |  20 +-
 include/linux/mm.h                |  33 +-
 include/linux/page-flags.h        |   2 +-
 include/linux/radix-tree.h        |   1 +
 include/linux/rmap.h              |   2 +-
 include/linux/userfaultfd_k.h     |   8 +-
 lib/radix-tree.c                  |  70 +++-
 mm/filemap.c                      | 162 +++++---
 mm/gup.c                          |   5 +-
 mm/huge_memory.c                  | 313 ++++++++-------
 mm/internal.h                     |  12 +-
 mm/ksm.c                          |   3 +-
 mm/memory.c                       | 790 +++++++++++++++++++++-----------------
 mm/migrate.c                      |   2 +-
 mm/rmap.c                         |  51 ++-
 mm/shmem.c                        | 208 +++++++---
 mm/swap.c                         |   2 +
 mm/truncate.c                     |   5 +-
 mm/util.c                         |   6 +
 52 files changed, 1037 insertions(+), 754 deletions(-)

-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
