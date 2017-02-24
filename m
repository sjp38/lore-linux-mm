Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4A746B038A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 16:31:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so48776294pfb.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:53 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t18si8339664pfj.268.2017.02.24.13.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 13:31:52 -0800 (PST)
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1OLTv2S027952
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 28tunc88bb-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:31:52 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.222.219.45) with ESMTP	id
 a7154c9afad811e684a124be05904660-70dfda00 for <linux-mm@kvack.org>;	Fri, 24
 Feb 2017 13:31:51 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V5 0/6] mm: fix some MADV_FREE issues
Date: Fri, 24 Feb 2017 13:31:43 -0800
Message-ID: <cover.1487965799.git.shli@fb.com>
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
- Accounting. There are two accounting problems. We don't have a global
  accounting. If the system is abnormal, we don't know if it's a problem from
  MADV_FREE side. The other problem is RSS accounting. MADV_FREE pages are
  accounted as normal anon pages and reclaimed lazily, so application's RSS
  becomes bigger. This confuses our workloads. We have monitoring daemon running
  and if it finds applications' RSS becomes abnormal, the daemon will kill the
  applications even kernel can reclaim the memory easily.

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

For the third issue, the previous post adds global accounting and a separate
RSS count for MADV_FREE pages. The problem is we never get accurate accounting
for MADV_FREE pages. The pages are mapped to userspace, can be dirtied without
notice from kernel side. To get accurate accounting, we could write protect the
page, but then there is extra page fault overhead, which people don't want to
pay. Jemalloc guys have concerns about the inaccurate accounting, so this post
drops the accounting patches temporarily. The info exported to /proc/pid/smaps
for MADV_FREE pages are kept, which is the only place we can get accurate
accounting right now.

Thanks,
Shaohua

V4->V5:
- Fix some minor issues pointed out by Johannes
- Integrate Johannes's cleanup patch
- Fix a bug to avoid swapin page is dicarded silently

V3->V4:
- rebase to latest -mm tree
- Address several issues pointed out by Johannes and Minchan
- Dropped vmstat and RSS accounting
http://marc.info/?l=linux-mm&m=148778961127710&w=2

V2->V3:
- rebase to latest -mm tree
- Address severl issues pointed out by Minchan
- Add more descriptions
http://marc.info/?l=linux-mm&m=148710098701674&w=2

V1->V2:
- Put MADV_FREE pages into LRU_INACTIVE_FILE list instead of adding a new lru
  list, suggested by Johannes
- Add RSS support
http://marc.info/?l=linux-mm&m=148616481928054&w=2

Minchan previous patches:
http://marc.info/?l=linux-mm&m=144800657002763&w=2

----------------------
Shaohua Li (6):
  mm: delete unnecessary TTU_* flags
  mm: don't assume anonymous pages have SwapBacked flag
  mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
  mm: reclaim MADV_FREE pages
  mm: enable MADV_FREE for swapless system
  proc: show MADV_FREE pages info in smaps

 Documentation/filesystems/proc.txt |  4 +++
 fs/proc/task_mmu.c                 |  8 +++++-
 include/linux/rmap.h               | 24 ++++++++----------
 include/linux/swap.h               |  2 +-
 include/linux/vm_event_item.h      |  2 +-
 mm/huge_memory.c                   |  6 ++---
 mm/khugepaged.c                    |  8 +++---
 mm/madvise.c                       | 11 ++-------
 mm/memory-failure.c                |  2 +-
 mm/migrate.c                       |  3 ++-
 mm/rmap.c                          | 43 +++++++++++++++-----------------
 mm/swap.c                          | 50 +++++++++++++++++++++-----------------
 mm/vmscan.c                        | 45 +++++++++++++++++++---------------
 mm/vmstat.c                        |  1 +
 14 files changed, 107 insertions(+), 102 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
