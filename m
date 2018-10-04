Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA3C6B0006
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 17:41:22 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id 131-v6so5786968ywe.1
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 14:41:22 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p7-v6si1329488ybc.559.2018.10.04.14.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 14:41:21 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v2] mm: don't raise MEMCG_OOM event due to failed high-order
 allocation
Date: Thu, 4 Oct 2018 21:41:09 +0000
Message-ID: <20181004214050.7417-1-guro@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

I was reported that on some of our machines containers were restarted
with OOM symptoms without an obvious reason. Despite there were almost
no memory pressure and plenty of page cache, MEMCG_OOM event was
raised occasionally, causing the container management software to
think, that OOM has happened. However, no tasks have been killed.

The following investigation showed that the problem is caused by
a failing attempt to charge a high-order page. In such case, the
OOM killer is never invoked. As shown below, it can happen under
conditions, which are very far from a real OOM: e.g. there is plenty
of clean page cache and no memory pressure.

There is no sense in raising an OOM event in this case, as it might
confuse a user and lead to wrong and excessive actions (e.g. restart
the workload, as in my case).

Let's look at the charging path in try_charge(). If the memory usage
is about memory.max, which is absolutely natural for most memory cgroups,
we try to reclaim some pages. Even if we were able to reclaim
enough memory for the allocation, the following check can fail due to
a race with another concurrent allocation:

    if (mem_cgroup_margin(mem_over_limit) >=3D nr_pages)
        goto retry;

For regular pages the following condition will save us from triggering
the OOM:

   if (nr_reclaimed && nr_pages <=3D (1 << PAGE_ALLOC_COSTLY_ORDER))
       goto retry;

But for high-order allocation this condition will intentionally fail.
The reason behind is that we'll likely fall to regular pages anyway,
so it's ok and even preferred to return ENOMEM.

In this case the idea of raising MEMCG_OOM looks dubious.

Fix this by moving MEMCG_OOM raising to mem_cgroup_oom() after
allocation order check, so that the event won't be raised for high
order allocations. This change doesn't affect regular pages allocation
and charging.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
---
 Documentation/admin-guide/cgroup-v2.rst | 4 ++++
 mm/memcontrol.c                         | 4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-=
guide/cgroup-v2.rst
index 8389d6f72a77..8384c681a4b2 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1133,6 +1133,10 @@ PAGE_SIZE multiple when read back.
 		disk readahead.  For now OOM in memory cgroup kills
 		tasks iff shortage has happened inside page fault.
=20
+		This event is not raised if the OOM killer is not
+		considered as an option, e.g. for failed high-order
+		allocations.
+
 	  oom_kill
 		The number of processes belonging to this cgroup
 		killed by any kind of OOM killer.
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7bebe2ddec05..81b47d0b14d7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1669,6 +1669,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgro=
up *memcg, gfp_t mask, int
 	if (order > PAGE_ALLOC_COSTLY_ORDER)
 		return OOM_SKIPPED;
=20
+	memcg_memory_event(memcg, MEMCG_OOM);
+
 	/*
 	 * We are in the middle of the charge context here, so we
 	 * don't want to block when potentially sitting on a callstack
@@ -2250,8 +2252,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t=
 gfp_mask,
 	if (fatal_signal_pending(current))
 		goto force;
=20
-	memcg_memory_event(mem_over_limit, MEMCG_OOM);
-
 	/*
 	 * keep retrying as long as the memcg oom killer is able to make
 	 * a forward progress or bypass the charge if the oom killer
--=20
2.17.1
