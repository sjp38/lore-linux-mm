Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id E591B6B2C08
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:59:31 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id 11-v6so2656285vko.21
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 13:59:31 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c48-v6si2305163uad.207.2018.08.23.13.59.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 13:59:30 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v6 0/2] huge_pmd_unshare migration and flushing
Date: Thu, 23 Aug 2018 13:59:15 -0700
Message-Id: <20180823205917.16297-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Correct a data corruption issue caused by improper handling of shared
huge PMDs during page migration.  This issue was observed in a customer
environment and can be recreated fairly easily with a test program.
Patch 0001 addresses this issue only and is copied to stable with the
intention that this will go to stable releases.  It has existed since
the addition of shared huge PMD support.

While considering the issue above, Kirill Shutemov noticed that other
callers of huge_pmd_unshare have potential issues with cache and TLB
flushing.  A separate patch (0002) takes advantage of the new routine
adjust_range_if_pmd_sharing_possible() to adjust flushing ranges in
the cases where huge PMD sharing is possible.  There is no copy to
stable for this patch as it has not been reported as an issue and
discovered only via code inspection.

v5-v6:	Rename and update 'sharing possible' routine as suggested by
	Kirill.
v3-v5:  Address build errors if !CONFIG_HUGETLB_PAGE and
        !CONFIG_ARCH_WANT_HUGE_PMD_SHARE

Mike Kravetz (2):
  mm: migration: fix migration of huge PMD shared pages
  hugetlb: take PMD sharing into account when flushing tlb/caches

 include/linux/hugetlb.h | 14 +++++++
 mm/hugetlb.c            | 93 ++++++++++++++++++++++++++++++++++++-----
 mm/rmap.c               | 42 +++++++++++++++++--
 3 files changed, 135 insertions(+), 14 deletions(-)

-- 
2.17.1
