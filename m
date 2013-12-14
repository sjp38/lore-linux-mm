Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECCD26B0031
	for <linux-mm@kvack.org>; Sat, 14 Dec 2013 03:15:49 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id q8so148021lbi.26
        for <linux-mm@kvack.org>; Sat, 14 Dec 2013 00:15:49 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y7si2313266lal.164.2013.12.14.00.15.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Dec 2013 00:15:48 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/2] memcg: do not use vmalloc for mem_cgroup allocations
Date: Sat, 14 Dec 2013 12:15:34 +0400
Message-ID: <ce02d52baac3730d659c046a181c2784c6cee2c4.1387007793.git.vdavydov@parallels.com>
In-Reply-To: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
References: <965cbb70fb55fe50a77382537b9a1b7455deac86.1387007793.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: glommer@gmail.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

The vmalloc was introduced by patch 333279 ("memcgroup: use vmalloc for
mem_cgroup allocation"), because at that time MAX_NUMNODES was used for
defining the per-node array in the mem_cgroup structure so that the
structure could be huge even if the system had the only NUMA node.

The situation was significantly improved by patch 45cf7e ("memcg: reduce
the size of struct memcg 244-fold"), which made the size of the
mem_cgroup structure calculated dynamically depending on the real number
of NUMA nodes installed on the system (nr_node_ids), so now there is no
point in using vmalloc here: the structure is allocated rarely and on
most systems its size is about 1K.

Personally I'd like to remove this vmalloc, because I'm considering
using wait_on_bit() on mem_cgroup::kmem_account_flags in the kmemcg
shrinkers implementation, which is impossible on vmalloc'd areas.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   28 ++++++----------------------
 1 file changed, 6 insertions(+), 22 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7f1a356..205eb7b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -48,7 +48,6 @@
 #include <linux/sort.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
-#include <linux/vmalloc.h>
 #include <linux/vmpressure.h>
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
@@ -335,12 +334,6 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
-static size_t memcg_size(void)
-{
-	return sizeof(struct mem_cgroup) +
-		nr_node_ids * sizeof(struct mem_cgroup_per_node *);
-}
-
 /* internal only representation about the status of kmem accounting. */
 enum {
 	KMEM_ACCOUNTED_ACTIVE = 0, /* accounted by this cgroup itself */
@@ -6139,14 +6132,12 @@ static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
 static struct mem_cgroup *mem_cgroup_alloc(void)
 {
 	struct mem_cgroup *memcg;
-	size_t size = memcg_size();
+	size_t size;
 
-	/* Can be very big if nr_node_ids is very big */
-	if (size < PAGE_SIZE)
-		memcg = kzalloc(size, GFP_KERNEL);
-	else
-		memcg = vzalloc(size);
+	size = sizeof(struct mem_cgroup);
+	size += nr_node_ids * sizeof(struct mem_cgroup_per_node *);
 
+	memcg = kzalloc(size, GFP_KERNEL);
 	if (!memcg)
 		return NULL;
 
@@ -6157,10 +6148,7 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	return memcg;
 
 out_free:
-	if (size < PAGE_SIZE)
-		kfree(memcg);
-	else
-		vfree(memcg);
+	kfree(memcg);
 	return NULL;
 }
 
@@ -6178,7 +6166,6 @@ out_free:
 static void __mem_cgroup_free(struct mem_cgroup *memcg)
 {
 	int node;
-	size_t size = memcg_size();
 
 	mem_cgroup_remove_from_trees(memcg);
 
@@ -6199,10 +6186,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	 * the cgroup_lock.
 	 */
 	disarm_static_keys(memcg);
-	if (size < PAGE_SIZE)
-		kfree(memcg);
-	else
-		vfree(memcg);
+	kfree(memcg);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
