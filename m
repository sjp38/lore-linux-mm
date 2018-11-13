Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D82286B027C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:33:30 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i22-v6so8727535pfj.1
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 22:33:30 -0800 (PST)
Received: from alexa-out-blr-01.qualcomm.com (alexa-out-blr-01.qualcomm.com. [103.229.18.197])
        by mx.google.com with ESMTPS id f3-v6si20203009pld.186.2018.11.12.22.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 22:33:29 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v5 0/4] mm: convert totalram_pages, totalhigh_pages and managed pages to atomic
Date: Tue, 13 Nov 2018 12:03:06 +0530
Message-Id: <1542090790-21750-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vatsa@codeaurora.org, willy@infradead.org, Arun KS <arunks@codeaurora.org>

This series convert totalram_pages, totalhigh_pages and
zone->managed_pages to atomic variables.

The patch was comiple tested on x86(x86_64_defconfig & i386_defconfig)
on 4.20-rc2. And memory hotplug tested on arm64, but on an older version
of kernel.

totalram_pages, zone->managed_pages and totalhigh_pages updates
are protected by managed_page_count_lock, but readers never care
about it. Convert these variables to atomic to avoid readers
potentially seeing a store tear.

Main motivation was that managed_page_count_lock handling was
complicating things. It was discussed in length here,
https://lore.kernel.org/patchwork/patch/995739/#1181785
It seemes better to remove the lock and convert variables
to atomic. With the change, preventing poteintial store-to-read
tearing comes as a bonus.

Changes in v5:
- totalram_pgs renamed to nr_pages.
https://lore.kernel.org/patchwork/patch/1011293/#1194248

Changes in v4:
- Fixed kbuild test robot error.
- Modified changelog.
- Rebased to 4.20.-rc2

Changes in v3:
- Fixed kbuild test robot errors.
- Modified changelogs to be more clear.
- EXPORT_SYMBOL for _totalram_pages and _totalhigh_pages.

Arun KS (4):
  mm: reference totalram_pages and managed_pages once per function
  mm: convert zone->managed_pages to atomic variable
  mm: convert totalram_pages and totalhigh_pages variables to atomic
  mm: Remove managed_page_count spinlock

 arch/csky/mm/init.c                           |  4 +-
 arch/powerpc/platforms/pseries/cmm.c          | 10 ++--
 arch/s390/mm/init.c                           |  2 +-
 arch/um/kernel/mem.c                          |  4 +-
 arch/x86/kernel/cpu/microcode/core.c          |  5 +-
 drivers/char/agp/backend.c                    |  4 +-
 drivers/gpu/drm/amd/amdkfd/kfd_crat.c         |  2 +-
 drivers/gpu/drm/i915/i915_gem.c               |  2 +-
 drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |  4 +-
 drivers/hv/hv_balloon.c                       | 19 +++----
 drivers/md/dm-bufio.c                         |  2 +-
 drivers/md/dm-crypt.c                         |  2 +-
 drivers/md/dm-integrity.c                     |  2 +-
 drivers/md/dm-stats.c                         |  2 +-
 drivers/media/platform/mtk-vpu/mtk_vpu.c      |  2 +-
 drivers/misc/vmw_balloon.c                    |  2 +-
 drivers/parisc/ccio-dma.c                     |  4 +-
 drivers/parisc/sba_iommu.c                    |  4 +-
 drivers/staging/android/ion/ion_system_heap.c |  2 +-
 drivers/xen/xen-selfballoon.c                 |  6 +--
 fs/ceph/super.h                               |  2 +-
 fs/file_table.c                               |  7 +--
 fs/fuse/inode.c                               |  2 +-
 fs/nfs/write.c                                |  2 +-
 fs/nfsd/nfscache.c                            |  2 +-
 fs/ntfs/malloc.h                              |  2 +-
 fs/proc/base.c                                |  2 +-
 include/linux/highmem.h                       | 28 ++++++++++-
 include/linux/mm.h                            | 27 +++++++++-
 include/linux/mmzone.h                        | 15 +++---
 include/linux/swap.h                          |  1 -
 kernel/fork.c                                 |  5 +-
 kernel/kexec_core.c                           |  5 +-
 kernel/power/snapshot.c                       |  2 +-
 lib/show_mem.c                                |  2 +-
 mm/highmem.c                                  |  5 +-
 mm/huge_memory.c                              |  2 +-
 mm/kasan/quarantine.c                         |  2 +-
 mm/memblock.c                                 |  6 +--
 mm/mm_init.c                                  |  2 +-
 mm/oom_kill.c                                 |  2 +-
 mm/page_alloc.c                               | 72 +++++++++++++--------------
 mm/shmem.c                                    |  7 +--
 mm/slab.c                                     |  2 +-
 mm/swap.c                                     |  2 +-
 mm/util.c                                     |  2 +-
 mm/vmalloc.c                                  |  4 +-
 mm/vmstat.c                                   |  4 +-
 mm/workingset.c                               |  2 +-
 mm/zswap.c                                    |  4 +-
 net/dccp/proto.c                              |  7 +--
 net/decnet/dn_route.c                         |  2 +-
 net/ipv4/tcp_metrics.c                        |  2 +-
 net/netfilter/nf_conntrack_core.c             |  7 +--
 net/netfilter/xt_hashlimit.c                  |  5 +-
 net/sctp/protocol.c                           |  7 +--
 security/integrity/ima/ima_kexec.c            |  2 +-
 57 files changed, 196 insertions(+), 142 deletions(-)

-- 
1.9.1
