Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 363226B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 01:32:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t20-v6so4485558pgu.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 22:32:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2-v6sor19555pgu.149.2018.07.16.22.32.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 22:32:45 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 0/2] mm: soft-offline: fix race against page allocation
Date: Tue, 17 Jul 2018 14:32:30 +0900
Message-Id: <1531805552-19547-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

I've updated the patchset based on feedbacks:

- updated comments (from Andrew),
- moved calling set_hwpoison_free_buddy_page() from mm/migrate.c to mm/memory-failure.c,
  which is necessary to check the return code of set_hwpoison_free_buddy_page(),
- lkp bot reported a build error when only 1/2 is applied.

  >    mm/memory-failure.c: In function 'soft_offline_huge_page':
  > >> mm/memory-failure.c:1610:8: error: implicit declaration of function
  > 'set_hwpoison_free_buddy_page'; did you mean 'is_free_buddy_page'?
  > [-Werror=implicit-function-declaration]
  >        if (set_hwpoison_free_buddy_page(page))
  >            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
  >            is_free_buddy_page
  >    cc1: some warnings being treated as errors

  set_hwpoison_free_buddy_page() is defined in 2/2, so we can't use it
  in 1/2. Simply doing s/set_hwpoison_free_buddy_page/!TestSetPageHWPoison/
  will fix this.

v1: https://lkml.org/lkml/2018/7/12/968

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (2):
      mm: fix race on soft-offlining free huge pages
      mm: soft-offline: close the race against page allocation

 include/linux/page-flags.h |  5 +++++
 include/linux/swapops.h    | 10 ---------
 mm/hugetlb.c               | 11 +++++-----
 mm/memory-failure.c        | 53 ++++++++++++++++++++++++++++++++++++++--------
 mm/migrate.c               | 11 ----------
 mm/page_alloc.c            | 30 ++++++++++++++++++++++++++
 6 files changed, 84 insertions(+), 36 deletions(-)
