Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f171.google.com (mail-ve0-f171.google.com [209.85.128.171])
	by kanga.kvack.org (Postfix) with ESMTP id 38A726B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 09:02:07 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id jz11so9666323veb.30
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 06:02:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k1si3654711qcd.34.2014.07.01.06.02.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 06:02:06 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [PATCH 0/5] mm, shmem: Enhance per-process accounting of shared memnory
Date: Tue,  1 Jul 2014 15:01:56 +0200
Message-Id: <1404219721-32241-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

There are several shortcomings with the accounting of shared memory
(sysV shm, shared anonymous mapping, mapping to a tmpfs file). The
values in /proc/<pid>/status and statm don't allow to distinguish
between shmem memory and a shared mapping to a regular file, even
though theirs implication on memory usage are quite different: at
reclaim, file mapping can be dropped or write back on disk while shmem
needs a place in swap. As for shmem pages that are swapped-out or in
swap cache, they aren't accounted at all.

This series addresses these issues by adding new fields to status and
smaps file in /proc/<pid>/. The accounting of resident shared memory is
made in the same way as it's currently done for resident memory and
general swap (a counter in mm_rss_stat), but this approach proved
impractical for paged-out shared memory (it would requires a rmap walk
each time a page is paged-in).

/proc/<pid>/smaps also lacks proper accounting of shared memory since
shmem subsystem hides all implementation detail to generic mm code.
This series adds the shmem_locate() function that returns the location
of a particular page (resident, in swap or swap cache). Called from
smaps code, it allows to show more detailled accounting of shmem
mappings in smaps.

Patch 1 adds a counter to keep track of resident shmem memory.
Patch 2 adds a function to allow generic code to know the physical
location of a shmem page.
Patch 3 adds simple helper function.
Patch 4 accounts swapped-out shmem in /proc/<pid>/status.
Patch 5 adds shmem specific fields to /proc/<pid>/smaps.

Thanks,
Jerome

Jerome Marchand (5):
  mm, shmem: Add shmem resident memory accounting
  mm, shmem: add shmem_locate function
  mm, shmem: add shmem_vma() helper
  mm, shmem: Add shmem swap memory accounting
  mm, shmem: show location of non-resident shmem pages in smaps

 Documentation/filesystems/proc.txt |  15 ++++
 arch/s390/mm/pgtable.c             |   2 +-
 fs/proc/task_mmu.c                 | 139 +++++++++++++++++++++++++++++++++++--
 include/linux/mm.h                 |  20 ++++++
 include/linux/mm_types.h           |   7 +-
 kernel/events/uprobes.c            |   2 +-
 mm/filemap_xip.c                   |   2 +-
 mm/memory.c                        |  37 ++++++++--
 mm/rmap.c                          |   8 +--
 mm/shmem.c                         |  37 ++++++++++
 10 files changed, 249 insertions(+), 20 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
