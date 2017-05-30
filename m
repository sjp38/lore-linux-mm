Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 994BD6B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j27so1167799wre.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:40 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z24si14391842edc.188.2017.05.30.11.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:17:39 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 0/6] mm: per-lruvec slab stats
Date: Tue, 30 May 2017 14:17:18 -0400
Message-Id: <20170530181724.27197-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi everyone,

Josef is working on a new approach to balancing slab caches and the
page cache. For this to work, he needs slab cache statistics on the
lruvec level. These patches implement that by adding infrastructure
that allows updating and reading generic VM stat items per lruvec,
then switches some existing VM accounting sites, including the slab
accounting ones, to this new cgroup-aware API.

I'll follow up with more patches on this, because there is actually
substantial simplification that can be done to the memory controller
when we replace private memcg accounting with making the existing VM
accounting sites cgroup-aware. But this is enough for Josef to base
his slab reclaim work on, so here goes.

 drivers/base/node.c        |  10 +-
 include/linux/memcontrol.h | 257 ++++++++++++++++++++++++++++++++++++---------
 include/linux/mmzone.h     |   4 +-
 include/linux/swap.h       |   1 -
 include/linux/vmstat.h     |   1 -
 kernel/fork.c              |   8 +-
 mm/memcontrol.c            |  14 ++-
 mm/page-writeback.c        |  15 +--
 mm/page_alloc.c            |   4 -
 mm/rmap.c                  |   8 +-
 mm/slab.c                  |  12 +--
 mm/slab.h                  |  18 +---
 mm/slub.c                  |   4 +-
 mm/vmscan.c                |  18 +---
 mm/vmstat.c                |   4 +-
 mm/workingset.c            |   9 +-
 16 files changed, 250 insertions(+), 137 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
