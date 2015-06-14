Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D30696B0038
	for <linux-mm@kvack.org>; Sun, 14 Jun 2015 11:05:01 -0400 (EDT)
Received: by wifx6 with SMTP id x6so54717308wif.0
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:05:01 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id p14si13661064wiv.47.2015.06.14.08.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jun 2015 08:05:00 -0700 (PDT)
Received: by wigg3 with SMTP id g3so54438685wig.1
        for <linux-mm@kvack.org>; Sun, 14 Jun 2015 08:04:59 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC 0/3] mm: make swapin readahead to gain more thp performance
Date: Sun, 14 Jun 2015 18:04:40 +0300
Message-Id: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
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

I've written down test results:

With the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:        470760 kB
AnonHugePages:    468992 kB
Swap:             329244 kB
Fraction:         %99

After swapped in:
In ten minutes:
cat /proc/pid/smaps:
Anonymous:        769208 kB
AnonHugePages:    765952 kB
Swap:              30796 kB
Fraction:         %99

Without the patch:
After swapped out:
cat /proc/pid/smaps:
Anonymous:        238160 kB
AnonHugePages:    235520 kB
Swap:             561844 kB
Fraction:         %98

After swapped in:
cat /proc/pid/smaps:
In ten minutes:
Anonymous:        499956 kB
AnonHugePages:    235520 kB
Swap:             300048 kB
Fraction:         %47

Ebru Akagunduz (3):
  mm: add tracepoint for scanning pages
  mm: make optimistic check for swapin readahead
  mm: make swapin readahead to improve thp collapse rate

 include/linux/mm.h                 |   4 ++
 include/trace/events/huge_memory.h | 123 +++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                   |  56 ++++++++++++++++-
 mm/memory.c                        |   2 +-
 4 files changed, 181 insertions(+), 4 deletions(-)
 create mode 100644 include/trace/events/huge_memory.h

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
