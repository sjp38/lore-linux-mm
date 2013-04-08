Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 894566B0073
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:34:18 -0400 (EDT)
Message-ID: <516264AF.1040906@huawei.com>
Date: Mon, 8 Apr 2013 14:33:19 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 02/12] memcg: avoid accessing memcg after releasing reference
References: <5162648B.9070802@huawei.com>
In-Reply-To: <5162648B.9070802@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

This might cause use-after-free bug.

Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e054ac0..2364f4e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3192,12 +3192,12 @@ void memcg_release_cache(struct kmem_cache *s)
 
 	root = s->memcg_params->root_cache;
 	root->memcg_params->memcg_caches[id] = NULL;
-	mem_cgroup_put(memcg);
 
 	mutex_lock(&memcg->slab_caches_mutex);
 	list_del(&s->memcg_params->list);
 	mutex_unlock(&memcg->slab_caches_mutex);
 
+	mem_cgroup_put(memcg);
 out:
 	kfree(s->memcg_params);
 }
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
