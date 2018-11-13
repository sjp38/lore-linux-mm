Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01CAB6B026C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:50:48 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id h10so4954102pgv.20
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:50:47 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p188-v6si22201860pfp.119.2018.11.12.21.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:50:46 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.19 40/44] mm: don't raise MEMCG_OOM event due to failed high-order allocation
Date: Tue, 13 Nov 2018 00:49:46 -0500
Message-Id: <20181113054950.77898-40-sashal@kernel.org>
In-Reply-To: <20181113054950.77898-1-sashal@kernel.org>
References: <20181113054950.77898-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-doc@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

From: Roman Gushchin <guro@fb.com>

[ Upstream commit 7a1adfddaf0d11a39fdcaf6e82a88e9c0586e08b ]

It was reported that on some of our machines containers were restarted
with OOM symptoms without an obvious reason.  Despite there were almost no
memory pressure and plenty of page cache, MEMCG_OOM event was raised
occasionally, causing the container management software to think, that OOM
has happened.  However, no tasks have been killed.

The following investigation showed that the problem is caused by a failing
attempt to charge a high-order page.  In such case, the OOM killer is
never invoked.  As shown below, it can happen under conditions, which are
very far from a real OOM: e.g.  there is plenty of clean page cache and no
memory pressure.

There is no sense in raising an OOM event in this case, as it might
confuse a user and lead to wrong and excessive actions (e.g.  restart the
workload, as in my case).

Let's look at the charging path in try_charge().  If the memory usage is
about memory.max, which is absolutely natural for most memory cgroups, we
try to reclaim some pages.  Even if we were able to reclaim enough memory
for the allocation, the following check can fail due to a race with
another concurrent allocation:

    if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
        goto retry;

For regular pages the following condition will save us from triggering
the OOM:

   if (nr_reclaimed && nr_pages <= (1 << PAGE_ALLOC_COSTLY_ORDER))
       goto retry;

But for high-order allocation this condition will intentionally fail.  The
reason behind is that we'll likely fall to regular pages anyway, so it's
ok and even preferred to return ENOMEM.

In this case the idea of raising MEMCG_OOM looks dubious.

Fix this by moving MEMCG_OOM raising to mem_cgroup_oom() after allocation
order check, so that the event won't be raised for high order allocations.
This change doesn't affect regular pages allocation and charging.

Link: http://lkml.kernel.org/r/20181004214050.7417-1-guro@fb.com
Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@kernel.org>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 Documentation/admin-guide/cgroup-v2.rst | 4 ++++
 mm/memcontrol.c                         | 4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 184193bcb262..5d9939388a78 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1127,6 +1127,10 @@ PAGE_SIZE multiple when read back.
 		disk readahead.  For now OOM in memory cgroup kills
 		tasks iff shortage has happened inside page fault.
 
+		This event is not raised if the OOM killer is not
+		considered as an option, e.g. for failed high-order
+		allocations.
+
 	  oom_kill
 		The number of processes belonging to this cgroup
 		killed by any kind of OOM killer.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..07c7af6f5e59 100644
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
