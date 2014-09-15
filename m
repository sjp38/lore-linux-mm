Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id C5D6D6B0039
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 10:25:40 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id m20so2856980qcx.39
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:25:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n20si10540962qgd.109.2014.09.15.07.25.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:25:38 -0700 (PDT)
From: "Jerome Marchand" <jmarchan@redhat.com>
Subject: [RFC PATCH v2 0/5] mm, shmem: Enhance per-process accounting of shared memory
Date: Mon, 15 Sep 2014 16:24:32 +0200
Message-Id: <1410791077-5300-1-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mackerras <paulus@samba.org>, Ingo Molnar <mingo@redhat.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

Changes since v1:
 - Add VmFile and VmAnon line to /proc/<pid>/status.
 - Split first patch: new accounting code on one side and and adding
 new fields to status on the other.
 - Remove ShmOther and ShmSwapCache from smaps and rename ShmOrphan to
 ShmNotMapped.
 - Drop fourth patch "mm, shmem: Add shmem swap memory accounting".
 - Minor implementation details.

I also tried again to come to a better way to account for shmem swap
pages, but my effort were again unsuccessful. Any suggestion is gladly
welcome.

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
Patch 2 adds VmFile, VmAnon and VmShm lines to /proc/<pid>/status.
Patch 3 adds a function to allow generic code to know the physical
location of a shmem page.
Patch 4 adds simple helper function.
Patch 5 adds shmem specific fields to /proc/<pid>/smaps.

Thanks,
Jerome

Jerome Marchand (5):
  mm, shmem: Add shmem resident memory accounting
  mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status
  mm, shmem: Add shmem_locate function
  mm, shmem: Add shmem_vma() helper
  mm, shmem: Show location of non-resident shmem pages in smaps

 Documentation/filesystems/proc.txt | 16 +++++++++-
 arch/s390/mm/pgtable.c             |  5 +---
 fs/proc/task_mmu.c                 | 60 ++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h                 | 10 +++++++
 include/linux/mm_types.h           |  7 +++--
 include/linux/shmem_fs.h           |  7 +++++
 kernel/events/uprobes.c            |  2 +-
 mm/filemap_xip.c                   |  2 +-
 mm/memory.c                        | 28 +++++-------------
 mm/oom_kill.c                      |  5 ++--
 mm/rmap.c                          | 17 ++++-------
 mm/shmem.c                         | 35 ++++++++++++++++++++++
 12 files changed, 147 insertions(+), 47 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
