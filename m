Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D46D66B0292
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 05:00:51 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 56so28252406wrx.5
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:51 -0700 (PDT)
Received: from mail-wr0-f194.google.com (mail-wr0-f194.google.com. [209.85.128.194])
        by mx.google.com with ESMTPS id p105si12079328wrc.206.2017.06.13.02.00.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 02:00:50 -0700 (PDT)
Received: by mail-wr0-f194.google.com with SMTP id v104so27755144wrb.0
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 02:00:50 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/4] mm, hugetlb: allow proper node fallback dequeue
Date: Tue, 13 Jun 2017 11:00:35 +0200
Message-Id: <20170613090039.14393-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
while working on a hugetlb migration issue addressed in a separate
patchset [1] I have noticed that the hugetlb allocations from the
preallocated pool are quite subotimal. There is no fallback mechanism
implemented and no notion of preferred node. I have tried to work
around it by [2] but Vlastimil was right to push back for a more robust
solution. It seems that such a solution is to reuse zonelist approach
we use for the page alloctor.

This series has 4 patches. The first one tries to make hugetlb
allocation layers more clear. The second one implements the zonelist
hugetlb pool allocation and introduces a preferred node semantic which
is used by the migration callbacks. The third patch is a pure clean up
as well as the last patch.

Note that this patch depends on [1] (without the last patch which
is replaced by this work). You can find the whole series in
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git branch
attempts/hugetlb-zonelists

I am sending this as an RFC because I might be missing some subtle
dependencies which led to the original design.

Shortlog
Michal Hocko (4):
      mm, hugetlb: unclutter hugetlb allocation layers
      hugetlb: add support for preferred node to alloc_huge_page_nodemask
      mm, hugetlb: get rid of dequeue_huge_page_node
      mm, hugetlb, soft_offline: use new_page_nodemask for soft offline migration

And the diffstat looks promissing as well

 include/linux/hugetlb.h |   3 +-
 include/linux/migrate.h |   2 +-
 mm/hugetlb.c            | 233 ++++++++++++++++--------------------------------
 mm/memory-failure.c     |  10 +--
 4 files changed, 82 insertions(+), 166 deletions(-)

[1] http://lkml.kernel.org/r/20170608074553.22152-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170608074553.22152-5-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
