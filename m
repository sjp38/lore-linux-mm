Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C77FE8E0094
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:30:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so6852724edm.18
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:30:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si713567edj.260.2018.12.11.06.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:30:08 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 0/3] reduce THP fault thrashing
Date: Tue, 11 Dec 2018 15:29:38 +0100
Message-Id: <20181211142941.20500-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Hi,

this is my attempt at reducing the madvised THP fault local node thrashing by
reclaim+compaction attempts which Andrea reported, by trying to better utilize
recent compaction results. It doesn't introduce any new __GFP_ONLY_COMPACT flag
or add order-specific decisions like Andrea's and David's previous patches, but
it does add __GFP_NORETRY back to madvised THP faults, like they both did
(Patch 1). Patch 2 is based on another Andrea's suggestion, where any
compaction failure is a reason to not try further (not just defered
compaction). Finally, patch 3 introduces defered compaction tracking for async
mode which is what's used for THP faults. Details in respective patch
changelogs.

I haven't tested it yet besides running transhuge-stress and verifying via
tracepoints that defered async compaction does happen. I hope all interested
parties can test the series on their workloads, thanks in advance. I expect
that THP fault success rates will be worse, but hopefully it will also fix
the local node thrashing issue. The success rates can then likely be improved
by making compaction core smarter, but that's a separate topic.

The series is based on v4.20-rc6.

Vlastimil

Vlastimil Babka (3):
  mm, thp: restore __GFP_NORETRY for madvised thp fault allocations
  mm, page_alloc: reclaim for __GFP_NORETRY costly requests only when
    compaction was skipped
  mm, compaction: introduce deferred async compaction

 include/linux/compaction.h        | 10 ++--
 include/linux/mmzone.h            |  6 +--
 include/trace/events/compaction.h | 29 ++++++-----
 mm/compaction.c                   | 80 ++++++++++++++++++-------------
 mm/huge_memory.c                  | 13 +++--
 mm/page_alloc.c                   | 14 +++---
 6 files changed, 84 insertions(+), 68 deletions(-)

-- 
2.19.2
