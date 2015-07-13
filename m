Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C619B6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 16:28:21 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so121969926wgx.3
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:21 -0700 (PDT)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id l7si15420672wif.65.2015.07.13.13.28.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 13:28:20 -0700 (PDT)
Received: by wgkl9 with SMTP id l9so34909945wgk.1
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 13:28:19 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC v3 0/3] mm: make swapin readahead to gain more thp performance
Date: Mon, 13 Jul 2015 23:28:01 +0300
Message-Id: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
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
With patch    | 267128 kB | 266240 kB     | 532876 kB |    %99    |
-------------------------------------------------------------------
Without patch | 238160 kB | 235520 kB     | 561844 kB |    %98    |
-------------------------------------------------------------------

                        After swapped in
-------------------------------------------------------------------
              | Anonymous | AnonHugePages | Swap      | Fraction  |
-------------------------------------------------------------------
With patch    | 533876 kB | 530432 kB     | 266128 kB |    %99    |
-------------------------------------------------------------------
Without patch | 499956 kB | 235520 kB     | 300048 kB |    %47    |
-------------------------------------------------------------------

Ebru Akagunduz (3):
  mm: add tracepoint for scanning pages
  mm: make optimistic check for swapin readahead
  mm: make swapin readahead to improve thp collapse rate

 include/linux/mm.h                 |  23 +++++
 include/trace/events/huge_memory.h | 127 ++++++++++++++++++++++++++++
 mm/huge_memory.c                   | 168 ++++++++++++++++++++++++++++++-------
 mm/memory.c                        |   2 +-
 4 files changed, 288 insertions(+), 32 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
