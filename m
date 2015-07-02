Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 569809003CE
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 04:47:26 -0400 (EDT)
Received: by wiar9 with SMTP id r9so93644672wia.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 01:47:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si8344008wiw.5.2015.07.02.01.47.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Jul 2015 01:47:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC v2 0/4] Outsourcing compaction for THP allocations to kcompactd
Date: Thu,  2 Jul 2015 10:46:31 +0200
Message-Id: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>

This RFC series is another evolution of the attempt to deal with THP
allocations latencies. Please see the motivation in the previous version [1]

The main difference here is that I've bitten the bullet and implemented
per-node kcompactd kthreads - see Patch 1 for the details of why and how.
Trying to fit everything into khugepaged was getting too clumsy, and kcompactd
could have more benefits, see e.g. the ideas here [2]. Not everything is
implemented yet, though, I would welcome some feedback first.

The devil will be in the details of course, i.e. how to steer the kcompactd
activity. Ideally it should take somehow into account the amount of free memory,
its fragmentation, pressure for high-order allocations including hugepages,
past successes/failures of compaction, the CPU time spent... not an easy task.
Suggestions welcome :)

I briefly tested it with mmtests/thpscale, but I don't think the results are
that interesting at this moment.

The patchset is based on v4.1, next would probably conflict in at least
mempolicy.c. I know it's still merge window, but didn't want to delay 2 weeks
due to upcoming vacation. Thanks.

[1] https://lwn.net/Articles/643891/
[2] http://article.gmane.org/gmane.linux.kernel/1982369

Vlastimil Babka (4):
  mm, compaction: introduce kcompactd
  mm, thp: stop preallocating hugepages in khugepaged
  mm, thp: check for hugepage availability in khugepaged
  mm, thp: check hugepage availability for fault allocations

 include/linux/compaction.h |  13 +++
 include/linux/mmzone.h     |   8 ++
 mm/compaction.c            | 207 +++++++++++++++++++++++++++++++++++++++++++++
 mm/huge_memory.c           | 180 +++++++++++++++++++--------------------
 mm/internal.h              |  39 +++++++++
 mm/memory_hotplug.c        |  15 ++--
 mm/mempolicy.c             |  42 +++++----
 mm/page_alloc.c            |   6 ++
 mm/vmscan.c                |   7 ++
 9 files changed, 403 insertions(+), 114 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
