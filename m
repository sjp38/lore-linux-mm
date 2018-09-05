Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFEB26B7590
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 19:09:04 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d18-v6so9526641qtj.20
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 16:09:04 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l15-v6si2321225qvh.192.2018.09.05.16.09.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 16:09:03 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH v3] mm: slowly shrink slabs with a relatively small number of objects
Date: Wed, 5 Sep 2018 16:07:59 -0700
Message-ID: <20180905230759.12236-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, Roman Gushchin <guro@fb.com>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>

Commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
changed the way how the target slab pressure is calculated and
made it priority-based:

    delta = freeable >> priority;
    delta *= 4;
    do_div(delta, shrinker->seeks);

The problem is that on a default priority (which is 12) no pressure
is applied at all, if the number of potentially reclaimable objects
is less than 4096 (1<<12).

This causes the last objects on slab caches of no longer used cgroups
to (almost) never get reclaimed. It's obviously a waste of memory.

It can be especially painful, if these stale objects are holding
a reference to a dying cgroup. Slab LRU lists are reparented on memcg
offlining, but corresponding objects are still holding a reference
to the dying cgroup. If we don't scan these objects, the dying cgroup
can't go away. Most likely, the parent cgroup hasn't any directly
charged objects, only remaining objects from dying children cgroups.
So it can easily hold a reference to hundreds of dying cgroups.

If there are no big spikes in memory pressure, and new memory cgroups
are created and destroyed periodically, this causes the number of
dying cgroups grow steadily, causing a slow-ish and hard-to-detect
memory "leak". It's not a real leak, as the memory can be eventually
reclaimed, but it could not happen in a real life at all. I've seen
hosts with a steadily climbing number of dying cgroups, which doesn't
show any signs of a decline in months, despite the host is loaded
with a production workload.

It is an obvious waste of memory, and to prevent it, let's apply
a minimal pressure even on small shrinker lists. E.g. if there are
freeable objects, let's scan at least min(freeable, scan_batch)
objects.

This fix significantly improves a chance of a dying cgroup to be
reclaimed, and together with some previous patches stops the steady
growth of the dying cgroups number on some of our hosts.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Rik van Riel <riel@surriel.com>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/vmscan.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa2c150ab7b9..858d7558909e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -476,6 +476,17 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	delta = freeable >> priority;
 	delta *= 4;
 	do_div(delta, shrinker->seeks);
+
+	/*
+	 * Make sure we apply some minimal pressure on default priority
+	 * even on small cgroups. Stale objects are not only consuming memory
+	 * by themselves, but can also hold a reference to a dying cgroup,
+	 * preventing it from being reclaimed. A dying cgroup with all
+	 * corresponding structures like per-cpu stats and kmem caches
+	 * can be really big, so it may lead to a significant waste of memory.
+	 */
+	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
+
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
-- 
2.17.1
