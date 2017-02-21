Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71AB56B038D
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:58:53 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v63so62727175pgv.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:58:53 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i1si6379198pgc.96.2017.02.21.01.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 01:58:52 -0800 (PST)
From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 0/5] mm subsystem refcounter conversions
Date: Tue, 21 Feb 2017 11:58:39 +0200
Message-Id: <1487671124-11188-1-git-send-email-elena.reshetova@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, catalin.marinas@arm.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, Elena Reshetova <elena.reshetova@intel.com>

v2:
 - incorporated fixes reported 0day CI

Now when new refcount_t type and API are finally merged
(see include/linux/refcount.h), the following
patches convert various refcounters in the mm susystem from atomic_t
to refcount_t. By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The below patches are fully independent and can be cherry-picked separately.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

Elena Reshetova (5):
  mm: convert bdi_writeback_congested.refcnt from atomic_t to refcount_t
  mm: convert anon_vma.refcount from atomic_t to refcount_t
  mm: convert kmemleak_object.use_count from atomic_t to refcount_t
  mm: convert mm_struct.mm_users from atomic_t to refcount_t
  mm: convert mm_struct.mm_count from atomic_t to refcount_t

 arch/alpha/kernel/smp.c                  |  6 +++---
 arch/arc/mm/tlb.c                        |  2 +-
 arch/blackfin/mach-common/smp.c          |  4 ++--
 arch/ia64/include/asm/tlbflush.h         |  2 +-
 arch/ia64/kernel/smp.c                   |  2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c        |  4 ++--
 arch/mips/kernel/process.c               |  2 +-
 arch/mips/kernel/smp.c                   |  6 +++---
 arch/parisc/include/asm/mmu_context.h    |  2 +-
 arch/powerpc/mm/hugetlbpage.c            |  2 +-
 arch/powerpc/mm/icswx.c                  |  4 ++--
 arch/sh/kernel/smp.c                     |  6 +++---
 arch/sparc/kernel/smp_64.c               |  6 +++---
 arch/sparc/mm/srmmu.c                    |  2 +-
 arch/um/kernel/tlb.c                     |  2 +-
 arch/x86/kernel/tboot.c                  |  4 ++--
 drivers/firmware/efi/arm-runtime.c       |  4 ++--
 drivers/gpu/drm/amd/amdkfd/kfd_process.c |  2 +-
 fs/coredump.c                            |  2 +-
 fs/proc/base.c                           |  2 +-
 fs/userfaultfd.c                         |  3 +--
 include/linux/backing-dev-defs.h         |  3 ++-
 include/linux/backing-dev.h              |  4 ++--
 include/linux/mm_types.h                 |  5 +++--
 include/linux/rmap.h                     |  7 ++++---
 include/linux/sched.h                    | 10 +++++-----
 kernel/events/uprobes.c                  |  2 +-
 kernel/exit.c                            |  2 +-
 kernel/fork.c                            | 12 ++++++------
 kernel/sched/core.c                      |  2 +-
 lib/is_single_threaded.c                 |  2 +-
 mm/backing-dev.c                         | 13 +++++++------
 mm/debug.c                               |  4 ++--
 mm/init-mm.c                             |  4 ++--
 mm/khugepaged.c                          |  2 +-
 mm/kmemleak.c                            | 16 ++++++++--------
 mm/ksm.c                                 |  2 +-
 mm/memory.c                              |  2 +-
 mm/mmu_notifier.c                        | 10 +++++-----
 mm/mprotect.c                            |  2 +-
 mm/oom_kill.c                            |  2 +-
 mm/rmap.c                                | 14 +++++++-------
 mm/swapfile.c                            |  2 +-
 mm/vmacache.c                            |  2 +-
 44 files changed, 98 insertions(+), 95 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
