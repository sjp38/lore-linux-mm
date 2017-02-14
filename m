Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FE5F680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 14:36:15 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id q71so211156115ywg.1
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:15 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 3si1333926pgi.256.2017.02.14.11.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 11:36:14 -0800 (PST)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EJWdXk006526
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:14 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28m6c1rj8q-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 11:36:14 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 d805a596f2ec11e6b2960002c99293a0-e11d7a00 for <linux-mm@kvack.org>;	Tue, 14
 Feb 2017 11:36:13 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V3 0/7] mm: fix some MADV_FREE issues
Date: Tue, 14 Feb 2017 11:36:06 -0800
Message-ID: <cover.1487100204.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

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

V2->V3:
- rebase to latest -mm tree
- Address severl issues pointed out by Minchan
- Add more descriptions

V1->V2:
- Put MADV_FREE pages into LRU_INACTIVE_FILE list instead of adding a new lru
  list, suggested by Johannes
- Add RSS support
http://marc.info/?l=linux-mm&m=148616481928054&w=2

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
 fs/proc/task_mmu.c            | 17 ++++++++++++---
 fs/proc/task_nommu.c          |  4 +++-
 include/linux/mm_inline.h     | 29 ++++++++++++++++++++++++
 include/linux/mm_types.h      |  1 +
 include/linux/mmzone.h        |  2 ++
 include/linux/page-flags.h    |  6 +++++
 include/linux/swap.h          |  2 +-
 include/linux/vm_event_item.h |  2 +-
 mm/gup.c                      |  2 ++
 mm/huge_memory.c              | 14 ++++++++----
 mm/khugepaged.c               | 10 ++++-----
 mm/madvise.c                  | 16 ++++++--------
 mm/memory.c                   | 13 +++++++++--
 mm/migrate.c                  |  5 ++++-
 mm/oom_kill.c                 | 10 +++++----
 mm/page_alloc.c               | 13 ++++++++---
 mm/rmap.c                     | 40 ++++++++++++++++++++++-----------
 mm/swap.c                     | 51 ++++++++++++++++++++++++-------------------
 mm/vmscan.c                   | 30 +++++++++++++++++--------
 mm/vmstat.c                   |  3 +++
 24 files changed, 203 insertions(+), 82 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
