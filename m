Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC6008E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:56:51 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id r131-v6so29063785oie.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:56:51 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v6-v6si11588568oix.348.2018.09.10.14.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 14:56:50 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH RFC] mm: don't raise MEMCG_OOM event due to failed high-order allocation
Date: Mon, 10 Sep 2018 14:56:22 -0700
Message-ID: <20180910215622.4428-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

The memcg OOM killer is never invoked due to a failed high-order
allocation, however the MEMCG_OOM event can be easily raised.

Under some memory pressure it can happen easily because of a
concurrent allocation. Let's look at try_charge(). Even if we were
able to reclaim enough memory, this check can fail due to a race
with another allocation:

    if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
        goto retry;

For regular pages the following condition will save us from triggering
the OOM:

   if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
       goto retry;

But for high-order allocation this condition will intentionally fail.
The reason behind is that we'll likely fall to regular pages anyway,
so it's ok and even preferred to return ENOMEM.

In this case the idea of raising the MEMCG_OOM event looks dubious.

Fix this by moving MEMCG_OOM raising to  mem_cgroup_oom() after
allocation order check, so that the event won't be raised for high
order allocations.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fcec9b39e2a3..103ca3c31c04 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1669,6 +1669,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		return OOM_SKIPPED;
 
+	memcg_memory_event(memcg, MEMCG_OOM);
+
 	/*
 	 * We are in the middle of the charge context here, so we
 	 * don't want to block when potentially sitting on a callstack
@@ -2250,8 +2252,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (fatal_signal_pending(current))
 		goto force;
 
-	memcg_memory_event(mem_over_limit, MEMCG_OOM);
-
 	/*
 	 * keep retrying as long as the memcg oom killer is able to make
 	 * a forward progress or bypass the charge if the oom killer
-- 
2.17.1
