Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1826B0062
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 07:17:29 -0500 (EST)
Received: by mail-lb0-f171.google.com with SMTP id w7so830370lbi.16
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:17:28 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si3526039lbb.56.2013.12.16.04.17.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 04:17:27 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v14 18/18] memcg: flush memcg items upon memcg destruction
Date: Mon, 16 Dec 2013 16:17:07 +0400
Message-ID: <1c6f53ea78febe5b5f370356fa9b7a21af19104f.1387193771.git.vdavydov@parallels.com>
In-Reply-To: <cover.1387193771.git.vdavydov@parallels.com>
References: <cover.1387193771.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, mhocko@suse.cz, hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

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
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 963285f..28d5472 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -6162,12 +6162,40 @@ static void memcg_destroy_kmem(struct mem_cgroup *memcg)
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
