Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id B488D9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 08:04:41 -0400 (EDT)
Received: by labow3 with SMTP id ow3so14970908lab.1
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 05:04:41 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pj6si11807368lbb.17.2015.08.03.05.04.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 05:04:40 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/3] Make workingset detection logic memcg aware
Date: Mon, 3 Aug 2015 15:04:20 +0300
Message-ID: <cover.1438599199.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Currently, workingset detection logic is not memcg aware - inactive_age
is maintained per zone. As a result, if memory cgroups are used,
refaulted file pages are activated randomly. This patch set makes
inactive_age per lruvec so that workingset detection will work correctly
for memory cgroup reclaim.

Thanks,

Vladimir Davydov (3):
  mm: move workingset_activation under lru_lock
  mm: make workingset detection logic memcg aware
  mm: workingset: make shadow node shrinker memcg aware

 include/linux/list_lru.h |  1 -
 include/linux/mmzone.h   |  7 ++++---
 include/linux/swap.h     |  2 +-
 mm/filemap.c             |  2 +-
 mm/internal.h            |  1 +
 mm/swap.c                |  5 +++--
 mm/vmscan.c              |  2 +-
 mm/workingset.c          | 34 +++++++++++++++++++++++-----------
 8 files changed, 34 insertions(+), 20 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
