Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0986B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 15:32:17 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so155550427wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:16 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id p7si19245439wij.5.2015.09.14.12.32.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 12:32:15 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so156601401wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 12:32:15 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v5 0/3] mm: make swapin readahead to gain more thp performance
Date: Mon, 14 Sep 2015 22:31:42 +0300
Message-Id: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series makes swapin readahead up to a
certain number to gain more thp performance and adds
tracepoint for khugepaged_scan_pmd, collapse_huge_page,
__collapse_huge_page_isolate.

This patch series was written to deal with programs
that access most, but not all, of their memory after
they get swapped out. Currently these programs do not
get their memory collapsed into THPs after the system
swapped their memory out, while they would get THPs
before swapping happened.

This patch series was tested with a test program,
it allocates 400MB of memory, writes to it, and
then sleeps. I force the system to swap out all.
Afterwards, the test program touches the area by
writing and leaves a piece of it without writing.
This shows how much swap in readahead made by the
patch.

Test results:

                        After swapped out
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 90076 kB    | 88064 kB    | 309928 kB |    %99    |
-------------------------------------------------------------------
Without patch | 194068 kB | 192512 kB     | 205936 kB |    %99    |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 201408 kB | 198656 kB     | 198596 kB |    %98    |
-------------------------------------------------------------------
Without patch | 292624 kB | 192512 kB     | 107380 kB |    %65    |
-------------------------------------------------------------------

Ebru Akagunduz (3):
  mm: add tracepoint for scanning pages
  mm: make optimistic check for swapin readahead
  mm: make swapin readahead to improve thp collapse rate

 include/trace/events/huge_memory.h | 165 ++++++++++++++++++++++++
 mm/huge_memory.c                   | 248 ++++++++++++++++++++++++++++++++-----
 mm/internal.h                      |   4 +
 mm/memory.c                        |   2 +-
 4 files changed, 386 insertions(+), 33 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
