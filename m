Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 455F86B025E
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 18:33:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c73so40467842pfb.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:28 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t11si26787026plm.267.2017.02.03.15.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Feb 2017 15:33:27 -0800 (PST)
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v13NX0js000510
	for <linux-mm@kvack.org>; Fri, 3 Feb 2017 15:33:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28cxtrgq7m-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Feb 2017 15:33:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.222.219.45) with ESMTP	id
 27c700b6ea6911e6b83924be05904660-515f8a00 for <linux-mm@kvack.org>;	Fri, 03
 Feb 2017 15:33:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V2 0/7] mm: fix some MADV_FREE issues
Date: Fri, 3 Feb 2017 15:33:16 -0800
Message-ID: <cover.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

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

To address the first the two issues, we can either put MADV_FREE pages into a
separate LRU list (Minchan's previous patches and V1 patches), or put them into
LRU_INACTIVE_FILE list (suggested by Johannes). The patchset use the second
idea. The reason is LRU_INACTIVE_FILE list is tiny nowadays and should be full
of used once file pages. So we can still efficiently reclaim MADV_FREE pages
there without interference with other anon and active file pages. Putting the
pages into inactive file list also has an advantage which allows page reclaim
to prioritize MADV_FREE pages and used once file pages. MADV_FREE pages are put
into the lru list and clear SwapBacked flag, so PageAnon(page) &&
!PageSwapBacked(page) will indicate a MADV_FREE pages. These pages will
directly freed without pageout if they are clean, otherwise normal swap will
reclaim them.

For the third issue, we add a separate RSS count for MADV_FREE pages. The count
will be increased in madvise syscall and decreased in page reclaim (eg, unmap).
There is one limitation, the accounting doesn't work well for shared pages.
Please check the last patch. This probably isn't a big issue, because userspace
will write the pages before reusing them, which will break the page sharing
between two processes. And if two processes share a page, the page can't really
be lazyfreed.

Thanks,
Shaohua

V1->V2:
- Put MADV_FREE pages into LRU_INACTIVE_FILE list instead of adding a new lru
  list, suggested by Johannes
- Add RSS support

Minchan previous patches:
http://marc.info/?l=linux-mm&m=144800657002763&w=2
----------------------
Shaohua Li (7):
  mm: don't assume anonymous pages have SwapBacked flag
  mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
  mm: reclaim MADV_FREE pages
  mm: enable MADV_FREE for swapless system
  mm: add vmstat account for MADV_FREE pages
  proc: show MADV_FREE pages info in smaps
  mm: add a separate RSS for MADV_FREE pages

 drivers/base/node.c           |  2 ++
 fs/proc/array.c               |  9 +++++---
 fs/proc/internal.h            |  3 ++-
 fs/proc/meminfo.c             |  1 +
 fs/proc/task_mmu.c            | 17 +++++++++++---
 fs/proc/task_nommu.c          |  4 +++-
 include/linux/mm_inline.h     | 36 +++++++++++++++++++++++++++---
 include/linux/mm_types.h      |  1 +
 include/linux/mmzone.h        |  2 ++
 include/linux/page-flags.h    |  6 +++++
 include/linux/swap.h          |  2 +-
 include/linux/vm_event_item.h |  2 +-
 mm/gup.c                      |  2 ++
 mm/huge_memory.c              | 14 ++++++++----
 mm/khugepaged.c               | 10 ++++-----
 mm/madvise.c                  | 16 ++++++-------
 mm/memory.c                   | 13 +++++++++--
 mm/migrate.c                  |  5 ++++-
 mm/oom_kill.c                 | 10 +++++----
 mm/page_alloc.c               |  7 ++++--
 mm/rmap.c                     | 10 ++++++++-
 mm/swap.c                     | 50 +++++++++++++++++++++++------------------
 mm/vmscan.c                   | 52 +++++++++++++++++++++++++++++++------------
 mm/vmstat.c                   |  3 +++
 24 files changed, 200 insertions(+), 77 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
