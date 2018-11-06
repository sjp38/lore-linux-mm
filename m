Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B11986B0344
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 11:23:34 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l15-v6so12877524pff.5
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 08:23:34 -0800 (PST)
Received: from alexa-out-blr.qualcomm.com (alexa-out-blr-02.qualcomm.com. [103.229.18.198])
        by mx.google.com with ESMTPS id r2si19411982pgo.483.2018.11.06.08.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 08:23:33 -0800 (PST)
From: Arun KS <arunks@codeaurora.org>
Subject: [PATCH v2 0/4] mm: convert totalram_pages, totalhigh_pages and managed pages to atomic
Date: Tue,  6 Nov 2018 21:51:46 +0530
Message-Id: <1541521310-28739-1-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, mhocko@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: getarunks@gmail.com, Arun KS <arunks@codeaurora.org>

This series convert totalram_pages, totalhigh_pages and
zone->managed_pages to atomic variables.

The patch was comiple tested on x86(x86_64_defconfig & i386_defconfig)
on 4.20-rc1. And memory hotplug tested on arm64, but on an older version
of kernel.

Arun KS (4):
  mm: Fix multiple evaluvations of totalram_pages and managed_pages
  mm: Convert zone->managed_pages to atomic variable
  mm: convert totalram_pages and totalhigh_pages variables to atomic
  mm: Remove managed_page_count spinlock

 arch/csky/mm/init.c                           |  4 +-
 arch/powerpc/platforms/pseries/cmm.c          | 10 ++--
 arch/s390/mm/init.c                           |  2 +-
 arch/um/kernel/mem.c                          |  3 +-
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
 mm/highmem.c                                  |  4 +-
 mm/huge_memory.c                              |  2 +-
 mm/kasan/quarantine.c                         |  2 +-
 mm/memblock.c                                 |  6 +--
 mm/mm_init.c                                  |  2 +-
 mm/oom_kill.c                                 |  2 +-
 mm/page_alloc.c                               | 71 +++++++++++++--------------
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
 57 files changed, 193 insertions(+), 142 deletions(-)

-- 
1.9.1
