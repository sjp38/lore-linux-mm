Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7F88F6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:02:21 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so65903064wib.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:02:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh9si10199843wib.8.2015.08.05.06.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 06:02:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 0/4] enhance shmem process and swap accounting
Date: Wed,  5 Aug 2015 15:01:21 +0200
Message-Id: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

Reposting due to lack of feedback in May. I hope at least patches 1 and 2
could be merged as they are IMHO bugfixes. 3 and 4 is optional but IMHO useful.

Changes since v2:
o Rebase on next-20150805.
o This means that /proc/pid/maps has the proportional swap share (SwapPss:)
  field as per https://lkml.org/lkml/2015/6/15/274
  It's not clear what to do with shmem here so it's 0 for now.
  - swapped out shmem doesn't have swap entries, so we would have to look at who
    else has the shmem object (partially) mapped
  - to be more precise we should also check if his range actually includes 
    the offset in question, which could get rather involved
  - or is there some easy way I don't see?
o Konstantin suggested for patch 3/4 that I drop the CONFIG_SHMEM #ifdefs
  I didn't see the point in going against tinyfication when the work is
  already done, but I can do that if more people think it's better and it
  would block the series.

Changes since v1:
o In Patch 2, rely on SHMEM_I(inode)->swapped if possible, and fallback to
  radix tree iterator on partially mapped shmem objects, i.e. decouple shmem
  swap usage determination from the page walk, for performance reasons.
  Thanks to Jerome and Konstantin for the tips.
  The downside is that mm/shmem.c had to be touched.

This series is based on Jerome Marchand's [1] so let me quote the first
paragraph from there:

There are several shortcomings with the accounting of shared memory
(sysV shm, shared anonymous mapping, mapping to a tmpfs file). The
values in /proc/<pid>/status and statm don't allow to distinguish
between shmem memory and a shared mapping to a regular file, even
though theirs implication on memory usage are quite different: at
reclaim, file mapping can be dropped or write back on disk while shmem
needs a place in swap. As for shmem pages that are swapped-out or in
swap cache, they aren't accounted at all.

The original motivation for myself is that a customer found (IMHO rightfully)
confusing that e.g. top output for process swap usage is unreliable with
respect to swapped out shmem pages, which are not accounted for.

The fundamental difference between private anonymous and shmem pages is that
the latter has PTE's converted to pte_none, and not swapents. As such, they are
not accounted to the number of swapents visible e.g. in /proc/pid/status VmSwap
row. It might be theoretically possible to use swapents when swapping out shmem
(without extra cost, as one has to change all mappers anyway), and on swap in
only convert the swapent for the faulting process, leaving swapents in other
processes until they also fault (so again no extra cost). But I don't know how
many assumptions this would break, and it would be too disruptive change for a
relatively small benefit.

Instead, my approach is to document the limitation of VmSwap, and provide means
to determine the swap usage for shmem areas for those who are interested and
willing to pay the price, using /proc/pid/smaps. Because outside of ipcs, I
don't think it's possible to currently to determine the usage at all.  The
previous patchset [1] did introduce new shmem-specific fields into smaps
output, and functions to determine the values. I take a simpler approach,
noting that smaps output already has a "Swap: X kB" line, where currently X ==
0 always for shmem areas. I think we can just consider this a bug and provide
the proper value by consulting the radix tree, as e.g. mincore_page() does. In the
patch changelog I explain why this is also not perfect (and cannot be without
swapents), but still arguably much better than showing a 0.

The last two patches are adapted from Jerome's patchset and provide a VmRSS
breakdown to VmAnon, VmFile and VmShm in /proc/pid/status. Hugh noted that
this is a welcome addition, and I agree that it might help e.g. debugging
process memory usage at albeit non-zero, but still rather low cost of extra
per-mm counter and some page flag checks. I updated these patches to 4.0-rc1,
made them respect !CONFIG_SHMEM so that tiny systems don't pay the cost, and
optimized the page flag checking somewhat.

[1] http://lwn.net/Articles/611966/

Jerome Marchand (2):
  mm, shmem: Add shmem resident memory accounting
  mm, procfs: Display VmAnon, VmFile and VmShm in /proc/pid/status

Vlastimil Babka (2):
  mm, documentation: clarify /proc/pid/status VmSwap limitations
  mm, proc: account for shmem swap in /proc/pid/smaps

 Documentation/filesystems/proc.txt | 18 ++++++++++---
 arch/s390/mm/pgtable.c             |  5 +---
 fs/proc/task_mmu.c                 | 52 ++++++++++++++++++++++++++++++++++--
 include/linux/mm.h                 | 28 ++++++++++++++++++++
 include/linux/mm_types.h           |  9 ++++---
 include/linux/shmem_fs.h           |  6 +++++
 kernel/events/uprobes.c            |  2 +-
 mm/memory.c                        | 30 +++++++--------------
 mm/oom_kill.c                      |  5 ++--
 mm/rmap.c                          | 15 +++--------
 mm/shmem.c                         | 54 ++++++++++++++++++++++++++++++++++++++
 11 files changed, 178 insertions(+), 46 deletions(-)

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
