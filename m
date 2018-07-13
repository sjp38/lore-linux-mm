Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 100436B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 23:26:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k21-v6so153976pfi.12
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 20:26:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w8-v6sor19909pll.21.2018.07.12.20.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 20:26:19 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 0/2] mm: soft-offline: fix race against page allocation
Date: Fri, 13 Jul 2018 12:26:04 +0900
Message-Id: <1531452366-11661-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, xishi.qiuxishi@alibaba-inc.com, zy.zhengyi@alibaba-inc.com, linux-kernel@vger.kernel.org

Xishi recently reported the issue about race on reusing the target pages
of soft offlining.
Discussion and analysis showed that we need make sure that setting PG_hwpoison
should be done in the right place under zone->lock for soft offline.
1/2 handles free hugepage's case, and 2/2 hanldes free buddy page's case.

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (2):
      mm: fix race on soft-offlining free huge pages
      mm: soft-offline: close the race against page allocation

 include/linux/page-flags.h |  5 +++++
 include/linux/swapops.h    | 10 ----------
 mm/hugetlb.c               | 11 +++++------
 mm/memory-failure.c        | 44 +++++++++++++++++++++++++++++++++++---------
 mm/migrate.c               |  4 +---
 mm/page_alloc.c            | 29 +++++++++++++++++++++++++++++
 6 files changed, 75 insertions(+), 28 deletions(-)
