Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A02886B0372
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:30:45 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 4so7167575wrc.15
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:30:45 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id y57si2326122wry.133.2017.06.22.12.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 12:30:44 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id x23so7049153wrb.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:30:43 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] mm, hugetlb: allow proper node fallback dequeue
Date: Thu, 22 Jun 2017 21:30:31 +0200
Message-Id: <20170622193034.28972-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

Hi,
the previous version of this patchset has been sent as an RFC [1].
As it doesn't seem anybody would object I am resending and asking
for merging.

Original reasoning:

While working on a hugetlb migration issue addressed in a separate
patchset [2] I have noticed that the hugetlb allocations from the
preallocated pool are quite subotimal. There is no fallback mechanism
implemented and no notion of preferred node. I have tried to work
around it by [4] but Vlastimil was right to push back for a more robust
solution. It seems that such a solution is to reuse zonelist approach
we use for the page alloctor.

This series has 3 patches. The first one tries to make hugetlb
allocation layers more clear. The second one implements the zonelist
hugetlb pool allocation and introduces a preferred node semantic which
is used by the migration callbacks. The last patch is a clean up.

This is based on top of the current mmotm tree (mmotm-2017-06-16-13-59).

Shortlog
Michal Hocko (3):
      mm, hugetlb: unclutter hugetlb allocation layers
      hugetlb: add support for preferred node to alloc_huge_page_nodemask
      mm, hugetlb, soft_offline: use new_page_nodemask for soft offline migration

And the diffstat looks promissing as well

 include/linux/hugetlb.h |   5 +-
 include/linux/migrate.h |   2 +-
 mm/hugetlb.c            | 215 ++++++++++++++++--------------------------------
 mm/memory-failure.c     |  10 +--
 4 files changed, 75 insertions(+), 157 deletions(-)

[1] http://lkml.kernel.org/r/20170613090039.14393-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170608074553.22152-1-mhocko@kernel.org
[3] http://lkml.kernel.org/r/20170608074553.22152-5-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
