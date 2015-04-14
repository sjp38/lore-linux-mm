Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f49.google.com (mail-vn0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4BD6B006C
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:41 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so8175463vnb.3
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:41 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v19si1191231ykb.37.2015.04.14.13.56.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:56:40 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 00/11] mm: debug: formatting memory management structs
Date: Tue, 14 Apr 2015 16:56:22 -0400
Message-Id: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This patch series adds knowledge about various memory management structures
to the standard print functions.

In essence, it allows us to easily print those structures:

	printk("%pZp %pZm %pZv", page, mm, vma);

This allows us to customize output when hitting bugs even further, thus
we introduce VM_BUG() which allows printing anything when hitting a bug
rather than just a single piece of information.

This also means we can get rid of VM_BUG_ON_* since they're now nothing
more than a format string.

Sasha Levin (11):
  mm: debug: format flags in a buffer
  mm: debug: deal with a new family of MM pointers
  mm: debug: dump VMA into a string rather than directly on screen
  mm: debug: dump struct MM into a string rather than directly on
    screen
  mm: debug: dump page into a string rather than directly on screen
  mm: debug: clean unused code
  mm: debug: VM_BUG()
  mm: debug: kill VM_BUG_ON_PAGE
  mm: debug: kill VM_BUG_ON_VMA
  mm: debug: kill VM_BUG_ON_MM
  mm: debug: use VM_BUG() to help with debug output

 arch/arm/mm/mmap.c               |    2 +-
 arch/frv/mm/elf-fdpic.c          |    4 +-
 arch/mips/mm/gup.c               |    4 +-
 arch/parisc/kernel/sys_parisc.c  |    2 +-
 arch/powerpc/mm/hugetlbpage.c    |    2 +-
 arch/powerpc/mm/pgtable_64.c     |    4 +-
 arch/s390/mm/gup.c               |    2 +-
 arch/s390/mm/mmap.c              |    2 +-
 arch/s390/mm/pgtable.c           |    6 +--
 arch/sh/mm/mmap.c                |    2 +-
 arch/sparc/kernel/sys_sparc_64.c |    4 +-
 arch/sparc/mm/gup.c              |    2 +-
 arch/sparc/mm/hugetlbpage.c      |    4 +-
 arch/tile/mm/hugetlbpage.c       |    2 +-
 arch/x86/kernel/sys_x86_64.c     |    2 +-
 arch/x86/mm/gup.c                |    8 ++--
 arch/x86/mm/hugetlbpage.c        |    2 +-
 arch/x86/mm/pgtable.c            |    6 +--
 include/linux/huge_mm.h          |    2 +-
 include/linux/hugetlb.h          |    2 +-
 include/linux/hugetlb_cgroup.h   |    4 +-
 include/linux/mm.h               |   22 ++++-----
 include/linux/mmdebug.h          |   40 ++++++----------
 include/linux/page-flags.h       |   26 +++++-----
 include/linux/pagemap.h          |   11 +++--
 include/linux/rmap.h             |    2 +-
 kernel/fork.c                    |    2 +-
 lib/vsprintf.c                   |   22 +++++++++
 mm/balloon_compaction.c          |    4 +-
 mm/cleancache.c                  |    6 +--
 mm/compaction.c                  |    2 +-
 mm/debug.c                       |   98 ++++++++++++++++++++------------------
 mm/filemap.c                     |   18 +++----
 mm/gup.c                         |   12 ++---
 mm/huge_memory.c                 |   50 +++++++++----------
 mm/hugetlb.c                     |   28 +++++------
 mm/hugetlb_cgroup.c              |    2 +-
 mm/internal.h                    |    8 ++--
 mm/interval_tree.c               |    2 +-
 mm/kasan/report.c                |    2 +-
 mm/ksm.c                         |   13 ++---
 mm/memcontrol.c                  |   48 +++++++++----------
 mm/memory.c                      |   10 ++--
 mm/memory_hotplug.c              |    2 +-
 mm/migrate.c                     |    6 +--
 mm/mlock.c                       |    4 +-
 mm/mmap.c                        |   15 +++---
 mm/mremap.c                      |    4 +-
 mm/page_alloc.c                  |   28 +++++------
 mm/page_io.c                     |    4 +-
 mm/pagewalk.c                    |    2 +-
 mm/pgtable-generic.c             |    8 ++--
 mm/rmap.c                        |   20 ++++----
 mm/shmem.c                       |   10 ++--
 mm/slub.c                        |    4 +-
 mm/swap.c                        |   39 +++++++--------
 mm/swap_state.c                  |   16 +++----
 mm/swapfile.c                    |    8 ++--
 mm/vmscan.c                      |   24 +++++-----
 59 files changed, 355 insertions(+), 335 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
