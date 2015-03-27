Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 572BD6B006C
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 12:40:48 -0400 (EDT)
Received: by wibg7 with SMTP id g7so43378013wib.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 09:40:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da7si4114673wjc.12.2015.03.27.09.40.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 09:40:46 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/4] enhance shmem process and swap accounting
Date: Fri, 27 Mar 2015 17:40:37 +0100
Message-Id: <1427474441-17708-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Vlastimil Babka <vbabka@suse.cz>

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

 Documentation/filesystems/proc.txt | 15 +++++++++--
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
 11 files changed, 176 insertions(+), 45 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
