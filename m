Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1B3738D001E
	for <linux-mm@kvack.org>; Sun,  9 Jun 2013 08:46:15 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id fe20so4930549lab.20
        for <linux-mm@kvack.org>; Sun, 09 Jun 2013 05:46:13 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v2 2/2] memcg: do not account memory used for cache creation
Date: Sun,  9 Jun 2013 16:45:54 +0400
Message-Id: <1370781954-9972-3-git-send-email-glommer@openvz.org>
In-Reply-To: <1370781954-9972-1-git-send-email-glommer@openvz.org>
References: <1370781954-9972-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suze.cz, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@openvz.org>, Michal Hocko <mhocko@suse.cz>

The memory we used to hold the memcg arrays is currently accounted to
the current memcg. But that creates a problem, because that memory can
only be freed after the last user is gone. Our only way to know which is
the last user, is to hook up to freeing time, but the fact that we still
have some in flight kmallocs will prevent freeing to happen. I believe
therefore to be just easier to account this memory as global overhead.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dbabe4d..e3fd671 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5670,7 +5670,9 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
 	static_key_slow_inc(&memcg_kmem_enabled_key);
 
 	mutex_lock(&set_limit_mutex);
+	memcg_stop_kmem_account();
 	ret = memcg_update_cache_sizes(memcg);
+	memcg_resume_kmem_account();
 	mutex_unlock(&set_limit_mutex);
 out:
 	return ret;
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
