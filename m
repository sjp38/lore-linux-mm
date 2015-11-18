Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 034BE6B0275
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:29:59 -0500 (EST)
Received: by wmec201 with SMTP id c201so63970471wme.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:29:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c125si3629587wmd.11.2015.11.18.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 01:29:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 0/6] enhance shmem process and swap accounting
Date: Wed, 18 Nov 2015 10:29:30 +0100
Message-Id: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>

Changes since v4:
o Rebase on next-20151118
o Hugh pointed out a problem with private mappings of tmpfs files where
  smaps would show a sum of shmem object's swapped out pages and swapped
  out COWed pages. Fixed this by falling back to the find_get_page() approach.
  Patches are now layered by employing find_get_page() first, and then
  optimizing the non-private mappings on top (with some measurements).
o Expanded commit messages.

Changes since v3:
o Rebase on next-20151002
o Apply (feedb)acks from Michal Hocko and Konstantin Khlebnikov (Thanks!)
  - drop CONFIG_SHMEM ifdefs, as it was the 2nd suggestion already
  - add comments about not taking i_mutex in patch 2
o Rename VmAnon/VmFile/VmShm to RssAnon/RssFile... to make it hopefully more
  obvious that it's a breakdown of VmRSS. Naming things sucks.

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
breakdown to RssAnon, RssFile and RssShm in /proc/pid/status. Hugh noted that
this is a welcome addition, and I agree that it might help e.g. debugging
process memory usage at albeit non-zero, but still rather low cost of extra
per-mm counter and some page flag checks.

[1] http://lwn.net/Articles/611966/

Jerome Marchand (2):
  mm, shmem: add internal shmem resident memory accounting
  mm, procfs: breakdown RSS for anon, shmem and file in /proc/pid/status

Vlastimil Babka (4):
  mm, documentation: clarify /proc/pid/status VmSwap limitations for
    shmem
  mm, proc: account for shmem swap in /proc/pid/smaps
  mm, proc: reduce cost of /proc/pid/smaps for shmem mappings
  mm, proc: reduce cost of /proc/pid/smaps for unpopulated shmem
    mappings

 Documentation/filesystems/proc.txt | 21 ++++++++--
 arch/s390/mm/pgtable.c             |  5 +--
 fs/proc/task_mmu.c                 | 70 ++++++++++++++++++++++++++++++--
 include/linux/mm.h                 | 18 ++++++++-
 include/linux/mm_types.h           |  7 ++--
 include/linux/shmem_fs.h           |  4 ++
 kernel/events/uprobes.c            |  2 +-
 mm/memory.c                        | 30 +++++---------
 mm/oom_kill.c                      |  5 ++-
 mm/rmap.c                          | 12 ++----
 mm/shmem.c                         | 81 ++++++++++++++++++++++++++++++++++++++
 11 files changed, 208 insertions(+), 47 deletions(-)

-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
