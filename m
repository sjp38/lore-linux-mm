Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4E87E6B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:56:17 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:56:15 -0700 (PDT)
Subject: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:56:07 +0400
Message-ID: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

There is good old tradition: every year somebody submit patches for extending
vma->vm_flags upto 64-bits, because there no free bits left on 32-bit systems.

previous attempts:
https://lkml.org/lkml/2011/4/12/24	(KOSAKI Motohiro)
https://lkml.org/lkml/2010/4/27/23	(Benjamin Herrenschmidt)
https://lkml.org/lkml/2009/10/1/202	(Hugh Dickins)

Here already exist special type for this: vm_flags_t, but not all code uses it.
So, before switching vm_flags_t from unsinged long to u64 we must spread
vm_flags_t everywhere and fix all possible type-casting problems.

There is no functional changes in this patch set,
it only prepares code for vma->vm_flags converting.

---

Konstantin Khlebnikov (16):
      mm: introduce NR_VMA_FLAGS
      mm: use vm_flags_t for vma flags
      mm/shmem: use vm_flags_t for vma flags
      mm/nommu: use vm_flags_t for vma flags
      mm/drivers: use vm_flags_t for vma flags
      mm/x86: use vm_flags_t for vma flags
      mm/arm: use vm_flags_t for vma flags
      mm/unicore32: use vm_flags_t for vma flags
      mm/ia64: use vm_flags_t for vma flags
      mm/powerpc: use vm_flags_t for vma flags
      mm/s390: use vm_flags_t for vma flags
      mm/mips: use vm_flags_t for vma flags
      mm/parisc: use vm_flags_t for vma flags
      mm/score: use vm_flags_t for vma flags
      mm: cast vm_flags_t to u64 before printing
      mm: vm_flags_t strict type checking


 arch/arm/include/asm/cacheflush.h                |    5 -
 arch/arm/kernel/asm-offsets.c                    |    6 +
 arch/arm/mm/fault.c                              |    2 
 arch/ia64/mm/fault.c                             |    9 +
 arch/mips/mm/c-r3k.c                             |    2 
 arch/mips/mm/c-r4k.c                             |    6 -
 arch/mips/mm/c-tx39.c                            |    2 
 arch/parisc/mm/fault.c                           |    4 -
 arch/powerpc/include/asm/mman.h                  |    2 
 arch/s390/mm/fault.c                             |    8 +
 arch/score/mm/cache.c                            |    6 -
 arch/sh/mm/tlbflush_64.c                         |    2 
 arch/unicore32/kernel/asm-offsets.c              |    6 +
 arch/unicore32/mm/fault.c                        |    2 
 arch/x86/mm/hugetlbpage.c                        |    4 -
 drivers/char/mem.c                               |    2 
 drivers/infiniband/hw/ipath/ipath_file_ops.c     |    6 +
 drivers/infiniband/hw/qib/qib_file_ops.c         |    6 +
 drivers/media/video/omap3isp/ispqueue.h          |    2 
 drivers/staging/android/ashmem.c                 |    2 
 drivers/staging/android/binder.c                 |   15 +-
 drivers/staging/tidspbridge/core/tiomap3430.c    |   13 +-
 drivers/staging/tidspbridge/rmgr/drv_interface.c |    4 -
 fs/binfmt_elf.c                                  |    2 
 fs/binfmt_elf_fdpic.c                            |   24 ++-
 fs/exec.c                                        |    2 
 fs/proc/nommu.c                                  |    3 
 fs/proc/task_nommu.c                             |   14 +-
 include/linux/backing-dev.h                      |    7 -
 include/linux/huge_mm.h                          |    4 -
 include/linux/ksm.h                              |    8 +
 include/linux/mm.h                               |  163 +++++++++++++++-------
 include/linux/mm_types.h                         |   11 +
 include/linux/mman.h                             |    4 -
 include/linux/rmap.h                             |    8 +
 include/linux/shmem_fs.h                         |    5 -
 kernel/bounds.c                                  |    2 
 kernel/events/core.c                             |    4 -
 kernel/fork.c                                    |    2 
 kernel/sys.c                                     |    4 -
 mm/backing-dev.c                                 |    4 +
 mm/huge_memory.c                                 |    2 
 mm/ksm.c                                         |    4 -
 mm/madvise.c                                     |    2 
 mm/memory.c                                      |    9 +
 mm/mlock.c                                       |    2 
 mm/mmap.c                                        |   36 ++---
 mm/mprotect.c                                    |    9 +
 mm/mremap.c                                      |    2 
 mm/nommu.c                                       |   19 +--
 mm/rmap.c                                        |   16 +-
 mm/shmem.c                                       |   54 ++++---
 mm/vmscan.c                                      |    4 -
 53 files changed, 322 insertions(+), 224 deletions(-)

-- 
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
