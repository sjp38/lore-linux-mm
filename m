Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8C28A6B003B
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 03:06:15 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so1299168lab.32
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 00:06:14 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 6si3273097laz.110.2013.12.09.00.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 00:06:14 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v13 04/16] memcg: move memcg_caches_array_size() function
Date: Mon, 9 Dec 2013 12:05:45 +0400
Message-ID: <efacba489a23b3a87321a02828ed1a5094e5c490.1386571280.git.vdavydov@parallels.com>
In-Reply-To: <cover.1386571280.git.vdavydov@parallels.com>
References: <cover.1386571280.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dchinner@redhat.com, hannes@cmpxchg.org, mhocko@suse.cz, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, glommer@openvz.org, glommer@gmail.com, vdavydov@parallels.com, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I need to move this up a bit, and I am doing in a separate patch just to
reduce churn in the patch that needs it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3a4e2f8..220b463 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2983,6 +2983,21 @@ static int memcg_cache_idx(struct mem_cgroup *memcg)
 	return ret;
 }
 
+static size_t memcg_caches_array_size(int num_groups)
+{
+	ssize_t size;
+	if (num_groups <= 0)
+		return 0;
+
+	size = 2 * num_groups;
+	if (size < MEMCG_CACHES_MIN_SIZE)
+		size = MEMCG_CACHES_MIN_SIZE;
+	else if (size > MEMCG_CACHES_MAX_SIZE)
+		size = MEMCG_CACHES_MAX_SIZE;
+
+	return size;
+}
+
 /*
  * This is a bit cumbersome, but it is rarely used and avoids a backpointer
  * in the memcg_cache_params struct.
@@ -3125,21 +3140,6 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	return 0;
 }
 
-static size_t memcg_caches_array_size(int num_groups)
-{
-	ssize_t size;
-	if (num_groups <= 0)
-		return 0;
-
-	size = 2 * num_groups;
-	if (size < MEMCG_CACHES_MIN_SIZE)
-		size = MEMCG_CACHES_MIN_SIZE;
-	else if (size > MEMCG_CACHES_MAX_SIZE)
-		size = MEMCG_CACHES_MAX_SIZE;
-
-	return size;
-}
-
 /*
  * We should update the current array size iff all caches updates succeed. This
  * can only be done from the slab side. The slab mutex needs to be held when
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
