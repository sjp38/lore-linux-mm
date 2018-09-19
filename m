Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECD4B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 17:01:03 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g5-v6so2943592pgq.5
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 14:01:03 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h76-v6si23286604pfk.329.2018.09.19.14.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 14:01:02 -0700 (PDT)
From: Keith Busch <keith.busch@intel.com>
Subject: [PATCH 0/7] mm: faster get user pages
Date: Wed, 19 Sep 2018 15:02:43 -0600
Message-Id: <20180919210250.28858-1-keith.busch@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>

Pinning user pages out of nvdimm dax memory is significantly slower
compared to system ram. Analysis points to software overhead incurred
from a radix tree lookup. This patch series fixes that by removing the
relatively costly dev_pagemap lookup that was repeated for each page,
significantly increasing gup time.

The first 5 patches are just updating the benchmark to help test and
demonstrate the value of the last 2 patches.

The results were compared with following benchmark command for device
DAX memory:

  # gup_benchmark -m $((12*1024)) -n 512 -L -f /dev/dax0.0

  Before: 1037581 usec
  After:   375786 usec

Not bad; the after is the same time as using baseline anonymous system
RAM after this patch set, where before was nearly 3x longer.

Keith Busch (7):
  mm/gup_benchmark: Time put_page
  mm/gup_benchmark: Add additional pinning methods
  tools/gup_benchmark: Fix 'write' flag usage
  tools/gup_benchmark: Allow user specified file
  tools/gup_benchmark: Add parameter for hugetlb
  mm/gup: Combine parameters into struct
  mm/gup: Cache dev_pagemap while pinning pages

 include/linux/huge_mm.h                    |  12 +-
 include/linux/hugetlb.h                    |   2 +-
 include/linux/mm.h                         |  27 ++-
 mm/gup.c                                   | 279 ++++++++++++++---------------
 mm/gup_benchmark.c                         |  36 +++-
 mm/huge_memory.c                           |  67 ++++---
 mm/nommu.c                                 |   6 +-
 tools/testing/selftests/vm/gup_benchmark.c |  40 ++++-
 8 files changed, 262 insertions(+), 207 deletions(-)

-- 
2.14.4
