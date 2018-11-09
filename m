Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB376B0693
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 01:47:31 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id n22-v6so787377pff.2
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 22:47:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s9-v6sor7159414pgs.2.2018.11.08.22.47.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 22:47:29 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH RFC v1 00/11] hwpoison improvement part 1
Date: Fri,  9 Nov 2018 15:47:04 +0900
Message-Id: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, xishi.qiuxishi@alibaba-inc.com, Laurent Dufour <ldufour@linux.vnet.ibm.com>

Hi everyone,

I wrote hwpoison patches which partially mention the problems
discussed recently on this area [1].

Main point of this series is how we isolate faulty pages more
safely/reliable. As pointed out from Michal in thread [2], we can
have better isolation functions rather than what we currently have.
Patch 8/11 gives the implementation. As a result, the behavior of
poisoned pages (at least from soft-offline) are more predictable
and I think that memory hotremove should properly work with it.

The structure of this series:
  - patch 1-7 are small fixes, preparation, and/or cleanup.
    I can separate these out from main part if you like.
  - patch 8 is core part of this series, providing some code
    to pick out the target page from buddy allocator,
  - patch 9-11 are changes on caller sides (hard-offline,
    hotremove and unpoison.)

One big issue not addressed by this series is hard-offlining hugetlb,
which is still a todo unfortunately.

Another remaining work is to rework on the behavior of PG_hwpoison
flag from hard-offlining of in-use page. Even with this series,
hard-offline for in-use pages works as in the past (i.e. we still take
racy "set PG_hwpoison at first, then do some handling" approach.)
Without changing this, we can't be free from many "if (PageHWPoison)"
checks in mm code. So I'll think/try more about it after this one.

Anyway this is the first step for better solution (I believe,)
and any kind of help is applicated.

Thanks,
Naoya Horiguchi

[1]: https://lwn.net/Articles/753261/
[2]: https://lkml.org/lkml/2018/7/17/60
---
Summary:

Naoya Horiguchi (11):
      mm: hwpoison: cleanup unused PageHuge() check
      mm: soft-offline: add missing error check of set_hwpoison_free_buddy_page()
      mm: move definition of num_poisoned_pages_inc/dec to include/linux/mm.h
      mm: madvise: call soft_offline_page() without MF_COUNT_INCREASED
      mm: hwpoison-inject: don't pin for hwpoison_filter()
      mm: hwpoison: remove MF_COUNT_INCREASED
      mm: remove flag argument from soft offline functions
      mm: soft-offline: isolate error pages from buddy freelist
      mm: hwpoison: apply buddy page handling code to hard-offline
      mm: clear PageHWPoison in memory hotremove
      mm: hwpoison: introduce clear_hwpoison_free_buddy_page()

 drivers/base/memory.c      |   2 +-
 include/linux/mm.h         |  22 ++++++---
 include/linux/page-flags.h |   8 +++-
 include/linux/swapops.h    |  16 -------
 mm/hwpoison-inject.c       |  18 ++------
 mm/madvise.c               |  25 +++++-----
 mm/memory-failure.c        | 112 ++++++++++++++++++++++++++-------------------
 mm/migrate.c               |   9 ----
 mm/page_alloc.c            |  95 +++++++++++++++++++++++++++++++++++---
 mm/sparse.c                |   2 +-
 10 files changed, 193 insertions(+), 116 deletions(-)
