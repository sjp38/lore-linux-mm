Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id D5A426B0055
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:18 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id n7so1266340lam.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:18 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 9si3284884las.24.2013.12.09.00.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:17 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 16/16] memcg: flush memcg items upon memcg destruction
Date: Mon, 9 Dec 2013 12:05:57 +0400
Message-ID: <790660d8826b95b3b6bd5d7ee0c7510dc70b1a58.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

When a memcg is destroyed, it won't be imediately released until all
objects are gone. This means that if a memcg is restarted with the very
same workload - a very common case, the objects already cached won't be
billed to the new memcg. This is mostly undesirable since a container
can exploit this by restarting itself every time it reaches its limit,
and then coming up again with a fresh new limit.

Since now we have targeted reclaim, I sustain that we should assume that
a memcg that is destroyed should be flushed away. It makes perfect sense
if we assume that a memcg that goes away most likely indicates an
isolated workload that is terminated.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 182199f..65ef284 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6171,12 +6171,40 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
 	memcg_destroy_all_lrus(memcg);
 }
 
+static void memcg_drop_slab(struct mem_cgroup *memcg)
+{
+	struct shrink_control shrink = {
+		.gfp_mask = GFP_KERNEL,
+		.target_mem_cgroup = memcg,
+	};
+	unsigned long nr_objects;
+
+	nodes_setall(shrink.nodes_to_scan);
+	do {
+		nr_objects = shrink_slab(&shrink, 1000, 1000);
+	} while (nr_objects > 0);
+}
+
 static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
 {
 	if (!memcg_kmem_is_active(memcg))
 		return;
 
 	/*
+	 * When a memcg is destroyed, it won't be imediately released until all
+	 * objects are gone. This means that if a memcg is restarted with the
+	 * very same workload - a very common case, the objects already cached
+	 * won't be billed to the new memcg. This is mostly undesirable since a
+	 * container can exploit this by restarting itself every time it
+	 * reaches its limit, and then coming up again with a fresh new limit.
+	 *
+	 * Therefore a memcg that is destroyed should be flushed away. It makes
+	 * perfect sense if we assume that a memcg that goes away indicates an
+	 * isolated workload that is terminated.
+	 */
+	memcg_drop_slab(memcg);
+
+	/*
 	 * kmem charges can outlive the cgroup. In the case of slab
 	 * pages, for instance, a page contain objects from various
 	 * processes. As we prevent from taking a reference for every
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
