Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 686046B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:45:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d140so3110129wmd.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:09 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 19si2454852wmb.47.2017.01.18.05.45.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 05:45:08 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id d140so4212002wmd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:08 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/2] fix unbounded too_many_isolated
Date: Wed, 18 Jan 2017 14:44:51 +0100
Message-Id: <20170118134453.11725-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>

Hi,
this is based on top of [1]. The first patch continues in the direction
of moving some decisions to zones rather than nodes. In this case it is
the NR_ISOLATED* counters which I believe need to be zone aware as well.
See patch 1 for more information why.

The second path builds on top of that and tries to address the problem
which has been reported by Tetsuo several times already. In the
current implementation we can loop deep in the reclaim path without
any effective way out to re-evaluate our decisions about the reclaim
retries. Patch 2 says more about that but in principle we should locate
retry logic as high in the allocator chain as possible and so we should
get rid of any unbound retry loops inside the reclaim. This is what the
patch does.

I am sending this as an RFC because I am not yet sure this is the best
forward. My testing shows that the system behaves sanely.

Thoughts, comments?

[1] http://lkml.kernel.org/r/20170117103702.28542-1-mhocko@kernel.org

Michal Hocko (2):
      mm, vmscan: account the number of isolated pages per zone
      mm, vmscan: do not loop on too_many_isolated for ever

 include/linux/mmzone.h |  4 +--
 mm/compaction.c        | 16 ++++-----
 mm/khugepaged.c        |  4 +--
 mm/memory_hotplug.c    |  2 +-
 mm/migrate.c           |  4 +--
 mm/page_alloc.c        | 14 ++++----
 mm/vmscan.c            | 93 ++++++++++++++++++++++++++++++++------------------
 mm/vmstat.c            |  4 +--
 8 files changed, 82 insertions(+), 59 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
