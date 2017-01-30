Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 832CA6B0295
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:30 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id t18so65776533wmt.7
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:30 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k7si12033099wmk.40.2017.01.29.21.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:29 -0800 (PST)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v0U5nB1s022114
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:28 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 288qnvn7jw-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:28 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 21dd4e06e6b011e6a1080002c991e86a-c39f3a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 0/6]mm: add new LRU list for MADV_FREE pages
Date: Sun, 29 Jan 2017 21:51:17 -0800
Message-ID: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

Hi,

We are trying to use MADV_FREE in jemalloc. Several issues are found. Without
solving the issues, jemalloc can't use the MADV_FREE feature.
- Doesn't support system without swap enabled. Because if swap is off, we can't
  or can't efficiently age anonymous pages. And since MADV_FREE pages are mixed
  with other anonymous pages, we can't reclaim MADV_FREE pages. In current
  implementation, MADV_FREE will fallback to MADV_DONTNEED without swap enabled.
  But in our environment, a lot of machines don't enable swap. This will prevent
  our setup using MADV_FREE.
- Increases memory pressure. page reclaim bias file pages reclaim against
  anonymous pages. This doesn't make sense for MADV_FREE pages, because those
  pages could be freed easily and refilled with very slight penality. Even page
  reclaim doesn't bias file pages, there is still an issue, because MADV_FREE
  pages and other anonymous pages are mixed together. To reclaim a MADV_FREE
  page, we probably must scan a lot of other anonymous pages, which is
  inefficient. In our test, we usually see oom with MADV_FREE enabled and nothing
  without it.
- RSS accounting. MADV_FREE pages are accounted as normal anon pages and
  reclaimed lazily, so application's RSS becomes bigger. This confuses our
  workloads. We have monitoring daemon running and if it finds applications' RSS
  becomes abnormal, the daemon will kill the applications even kernel can reclaim
  the memory easily. Currently we don't export separate RSS accounting for
  MADV_FREE pages. This will prevent our setup using MADV_FREE too.

For the first two issues, introducing a new LRU list for MADV_FREE pages could
solve the issues. We can directly reclaim MADV_FREE pages without writting them
out to swap, so the first issue could be fixed. If only MADV_FREE pages are in
the new list, page reclaim can easily reclaim such pages without interference
of file or anonymous pages. The memory pressure issue will disappear.

Actually Minchan posted patches to add the LRU list before, but he didn't
pursue. So I picked up them and the patches are based on Minchan's previous
patches. The main difference between my patches and Minchan previous patches is
page reclaim policy. Minchan's patches introduces a knob to balance the reclaim
of MADV_FREE pages and anon/file pages, while the patches always reclaim
MADV_FREE pages first if there are. I described the reason in patch 5.

For the third issue, we can add a separate RSS count for MADV_FREE pages. The
count will be increased in madvise syscall and decreased in page reclaim (eg,
unmap). One issue is activate_page(). A MADV_FREE page can be promoted to
active page there. But there isn't mm_struct context at that place. Iterating
vma there sounds too silly. The patchset don't fix this issue yet. Hopefully
somebody can share a hint how to fix this issue.

Thanks,
Shaohua

Minchan previous patches:
http://marc.info/?l=linux-mm&m=144800657002763&w=2

Shaohua Li (6):
  mm: add wrap for page accouting index
  mm: add lazyfree page flag
  mm: add LRU_LAZYFREE lru list
  mm: move MADV_FREE pages into LRU_LAZYFREE list
  mm: reclaim lazyfree pages
  mm: enable MADV_FREE for swapless system

 drivers/base/node.c                       |  2 +
 drivers/staging/android/lowmemorykiller.c |  3 +-
 fs/proc/meminfo.c                         |  1 +
 fs/proc/task_mmu.c                        |  8 ++-
 include/linux/mm_inline.h                 | 41 +++++++++++++
 include/linux/mmzone.h                    |  9 +++
 include/linux/page-flags.h                |  6 ++
 include/linux/swap.h                      |  2 +-
 include/linux/vm_event_item.h             |  2 +-
 include/trace/events/mmflags.h            |  1 +
 include/trace/events/vmscan.h             | 31 +++++-----
 kernel/power/snapshot.c                   |  1 +
 mm/compaction.c                           | 11 ++--
 mm/huge_memory.c                          |  6 +-
 mm/khugepaged.c                           |  6 +-
 mm/madvise.c                              | 11 +---
 mm/memcontrol.c                           |  4 ++
 mm/memory-failure.c                       |  3 +-
 mm/memory_hotplug.c                       |  3 +-
 mm/mempolicy.c                            |  3 +-
 mm/migrate.c                              | 29 ++++------
 mm/page_alloc.c                           | 10 ++++
 mm/rmap.c                                 |  7 ++-
 mm/swap.c                                 | 51 +++++++++-------
 mm/vmscan.c                               | 96 +++++++++++++++++++++++--------
 mm/vmstat.c                               |  4 ++
 26 files changed, 242 insertions(+), 109 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
