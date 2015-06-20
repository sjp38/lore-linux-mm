Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 195CA6B009C
	for <linux-mm@kvack.org>; Sat, 20 Jun 2015 07:28:32 -0400 (EDT)
Received: by wiga1 with SMTP id a1so39117500wig.0
        for <linux-mm@kvack.org>; Sat, 20 Jun 2015 04:28:31 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id fx5si9614487wib.35.2015.06.20.04.28.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jun 2015 04:28:30 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so38129792wib.1
        for <linux-mm@kvack.org>; Sat, 20 Jun 2015 04:28:29 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v2 0/3] mm: make swapin readahead to gain more thp performance
Date: Sat, 20 Jun 2015 14:28:03 +0300
Message-Id: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
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
it allocates 800MB of memory, writes to it, and
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
With patch    | 265772 kB | 264192 kB     | 534232 kB |    %99    |
-------------------------------------------------------------------
Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
-------------------------------------------------------------------

			After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 532756 kB | 528384 kB     | 267248 kB |    %99    |
-------------------------------------------------------------------
Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
-------------------------------------------------------------------

Ebru Akagunduz (3):
  mm: add tracepoint for scanning pages
  mm: make optimistic check for swapin readahead
  mm: make swapin readahead to improve thp collapse rate

 include/linux/mm.h                 |   4 ++
 include/trace/events/huge_memory.h | 123 +++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                   |  58 ++++++++++++++++-
 mm/memory.c                        |   2 +-
 4 files changed, 183 insertions(+), 4 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
