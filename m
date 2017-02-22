Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8146B0389
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 13:50:47 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id 2so11177784ywn.1
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:47 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j7si2421452ioo.214.2017.02.22.10.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 10:50:46 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v1MIkMNr001678
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:46 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 28scegrv1e-3
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:50:46 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 d10d1d5cf92f11e685ab24be0593f280-8cbf9a00 for <linux-mm@kvack.org>;	Wed, 22
 Feb 2017 10:50:45 -0800
From: Shaohua Li <shli@fb.com>
Subject: [PATCH V4 0/6] mm: fix some MADV_FREE issues
Date: Wed, 22 Feb 2017 10:50:38 -0800
Message-ID: <cover.1487788131.git.shli@fb.com>
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

V3->V4:
- rebase to latest -mm tree
- Address several issues pointed out by Johannes and Minchan
- Dropped vmstat and RSS accounting

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
 include/linux/rmap.h               |  4 +--
 include/linux/swap.h               |  2 +-
 include/linux/vm_event_item.h      |  2 +-
 mm/huge_memory.c                   |  6 ++--
 mm/khugepaged.c                    |  8 ++----
 mm/madvise.c                       | 11 ++------
 mm/memory-failure.c                |  2 +-
 mm/migrate.c                       |  3 +-
 mm/rmap.c                          | 15 +++++++---
 mm/swap.c                          | 56 +++++++++++++++++++++++---------------
 mm/vmscan.c                        | 45 +++++++++++++++++-------------
 mm/vmstat.c                        |  1 +
 14 files changed, 96 insertions(+), 71 deletions(-)

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
