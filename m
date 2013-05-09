Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 3FC8B6B00A0
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:07:46 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 28/31] memcg: move initialization to memcg creation
Date: Thu,  9 May 2013 10:06:45 +0400
Message-Id: <1368079608-5611-29-git-send-email-glommer@openvz.org>
In-Reply-To: <1368079608-5611-1-git-send-email-glommer@openvz.org>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

Those structures are only used for memcgs that are effectively using
kmemcg. However, in a later patch I intend to use scan that list
inconditionally (list empty meaning no kmem caches present), which
simplifies the code a lot.

So move the initialization to early kmem creation.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e6a7848..1ff72f9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3249,9 +3249,7 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 
 	memcg_update_array_size(num + 1);
 
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
 	INIT_WORK(&memcg->kmemcg_shrink_work, kmemcg_shrink_work_fn);
-	mutex_init(&memcg->slab_caches_mutex);
 
 	return 0;
 out:
@@ -6121,6 +6119,8 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
 
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	mutex_init(&memcg->slab_caches_mutex);
 	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
