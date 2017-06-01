Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A76016B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e135so31810898ita.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:06 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id o74si29895512ito.71.2017.06.01.01.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:05 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id l145so4492336ita.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:05 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 0/9] mm: hwpoison: fixlet for hugetlb migration
Date: Thu,  1 Jun 2017 17:16:50 +0900
Message-Id: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi everyone,

I wrote the patchset updating hwpoison/hugetlb code to address
the 2 reported issues.

One is madvise(MADV_HWPOISON) failure reported by Intel's lkp robot
(see http://lkml.kernel.org/r/20170417055948.GM31394@yexl-desktop.)
First half was already fixed in mainline, and another half about hugetlb
cases are solved in this series.

Another issue is "narrow-down error affected region into a single 4kB
page instead of a whole hugetlb page" issue, which was tried by Anshuman
(http://lkml.kernel.org/r/20170420110627.12307-1-khandual@linux.vnet.ibm.com)
and I updated it to apply it more widely.

Hopefully it helps people who are interested in hugetlb migration for
wider arch/setting.

Thanks,
Naoya Horiguchi
---
Summary:

Anshuman Khandual (1):
      mm: hugetlb: soft-offline: dissolve source hugepage after successful migration

Naoya Horiguchi (8):
      mm: hugetlb: prevent reuse of hwpoisoned free hugepages
      mm: hugetlb: return immediately for hugetlb page in __delete_from_page_cache()
      mm: hwpoison: change PageHWPoison behavior on hugetlb pages
      mm: soft-offline: dissolve free hugepage if soft-offlined
      mm: hwpoison: introduce memory_failure_hugetlb()
      mm: hwpoison: dissolve in-use hugepage in unrecoverable memory error
      mm: hugetlb: delete dequeue_hwpoisoned_huge_page()
      mm: hwpoison: introduce idenfity_page_state

 fs/hugetlbfs/inode.c    |  11 ++
 include/linux/hugetlb.h |   8 +-
 include/linux/swapops.h |   9 --
 mm/filemap.c            |   8 +-
 mm/hugetlb.c            |  47 ++-----
 mm/memory-failure.c     | 323 +++++++++++++++++++++++-------------------------
 mm/migrate.c            |   2 +
 7 files changed, 184 insertions(+), 224 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
