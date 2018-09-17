Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84DFB8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 19:11:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 13-v6so64438oiq.1
        for <linux-mm@kvack.org>; Mon, 17 Sep 2018 16:11:09 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k13-v6si5615788otb.239.2018.09.17.16.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Sep 2018 16:11:08 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH RESEND] mm: don't raise MEMCG_OOM event due to failed
 high-order allocation
Date: Mon, 17 Sep 2018 23:10:59 +0000
Message-ID: <20180917230846.31027-1-guro@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

The memcg OOM killer is never invoked due to a failed high-order
allocation, however the MEMCG_OOM event can be raised.

As shown below, it can happen under conditions, which are very
far from a real OOM: e.g. there is plenty of clean pagecache
and low memory pressure.

There is no sense in raising an OOM event in such a case,
as it might confuse a user and lead to wrong and excessive actions.

Let's look at the charging path in try_caharge(). If the memory usage
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
