Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 938B26B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 07:26:58 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so685678pab.26
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 04:26:58 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id wn5si2932307pbc.94.2014.11.05.04.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Nov 2014 04:26:57 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] memcg: don't check mm in __memcg_kmem_{get_cache,newpage_charge}
Date: Wed, 5 Nov 2014 15:26:47 +0300
Message-ID: <1415190408-4921-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We already assured the current task has mm in memcg_kmem_should_charge,
no need to double check.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/memcontrol.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 95ee47c0f0a2..f61ecbc97d30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2687,7 +2687,7 @@ struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
 	VM_BUG_ON(!cachep->memcg_params);
 	VM_BUG_ON(!cachep->memcg_params->is_root_cache);
 
-	if (!current->mm || current->memcg_kmem_skip_account)
+	if (current->memcg_kmem_skip_account)
 		return cachep;
 
 	rcu_read_lock();
@@ -2773,7 +2773,7 @@ __memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **_memcg, int order)
 	 * allocations are extremely rare but can happen, for instance, for the
 	 * cache arrays. We bring this test here.
 	 */
-	if (!current->mm || current->memcg_kmem_skip_account)
+	if (current->memcg_kmem_skip_account)
 		return true;
 
 	memcg = get_mem_cgroup_from_mm(current->mm);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
