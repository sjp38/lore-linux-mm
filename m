Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 179166B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 16:52:06 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so2908065wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:05 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id v6si243217wiz.67.2015.09.03.13.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 13:52:04 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so2907442wic.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 13:52:04 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RESEND RFC v4 0/3] mm: make swapin readahead to gain more thp performance 
Date: Thu,  3 Sep 2015 23:51:45 +0300
Message-Id: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
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
With patch    | 253720 kB | 251904 kB     | 546284 kB |    %99    |
-------------------------------------------------------------------
Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 533532 kB | 528384 kB     | 266472 kB |    %90    |
-------------------------------------------------------------------
Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
-------------------------------------------------------------------

Ebru Akagunduz (3):
  mm: add tracepoint for scanning pages
  mm: make optimistic check for swapin readahead
  mm: make swapin readahead to improve thp collapse rate

 include/linux/mm.h                 |   4 +
 include/trace/events/huge_memory.h | 126 +++++++++++++++++
 mm/huge_memory.c                   | 272 ++++++++++++++++++++++++++++++++-----
 mm/memory.c                        |   2 +-
 4 files changed, 371 insertions(+), 33 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
