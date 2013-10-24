Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2A26B00E4
	for <linux-mm@kvack.org>; Thu, 24 Oct 2013 08:05:29 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so2347424pde.1
        for <linux-mm@kvack.org>; Thu, 24 Oct 2013 05:05:28 -0700 (PDT)
Received: from psmtp.com ([74.125.245.117])
        by mx.google.com with SMTP id ad7si776689pbd.328.2013.10.24.05.05.27
        for <linux-mm@kvack.org>;
        Thu, 24 Oct 2013 05:05:28 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v11 04/15] memcg: move initialization to memcg creation
Date: Thu, 24 Oct 2013 16:04:55 +0400
Message-ID: <958291b8ed92e5b9f857a633a2f64e58fca6a23a.1382603434.git.vdavydov@parallels.com>
In-Reply-To: <cover.1382603434.git.vdavydov@parallels.com>
References: <cover.1382603434.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: glommer@openvz.org, khorenko@parallels.com, devel@openvz.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

From: Glauber Costa <glommer@openvz.org>

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
 mm/memcontrol.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 41c216a..5104d1f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3120,8 +3120,6 @@ int memcg_update_cache_sizes(struct mem_cgroup *memcg)
 	}
 
 	memcg->kmemcg_id = num;
-	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
-	mutex_init(&memcg->slab_caches_mutex);
 	return 0;
 }
 
@@ -5916,6 +5914,8 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 {
 	int ret;
 
+	INIT_LIST_HEAD(&memcg->memcg_slab_caches);
+	mutex_init(&memcg->slab_caches_mutex);
 	memcg->kmemcg_id = -1;
 	ret = memcg_propagate_kmem(memcg);
 	if (ret)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
