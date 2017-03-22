Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA08A6B0343
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 20:53:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g10so34955074wrg.5
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 17:53:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j137si197221wmj.0.2017.03.21.17.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 17:53:25 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: workingset: fix premature shadow node shrinking with cgroups
Date: Tue, 21 Mar 2017 20:53:20 -0400
Message-Id: <20170322005320.8165-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
enabled cgroup-awareness in the shadow node shrinker, but forgot to
also enable cgroup-awareness in the list_lru the shadow nodes sit on.

Consequently, all shadow nodes are sitting on a global (per-NUMA node)
list, while the shrinker applies the limits according to the amount of
cache in the cgroup its shrinking. The result is excessive pressure on
the shadow nodes from cgroups that have very little cache.

Enable memcg-mode on the shadow node LRUs, such that per-cgroup limits
are applied to per-cgroup lists.

Fixes: 0a6b76dd23fa ("mm: workingset: make shadow node shrinker memcg aware")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org> # 4.6+
---
 mm/workingset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index ac839fca0e76..eda05c71fa49 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -532,7 +532,7 @@ static int __init workingset_init(void)
 	pr_info("workingset: timestamp_bits=%d max_order=%d bucket_order=%u\n",
 	       timestamp_bits, max_order, bucket_order);
 
-	ret = list_lru_init_key(&shadow_nodes, &shadow_nodes_key);
+	ret = __list_lru_init(&shadow_nodes, true, &shadow_nodes_key);
 	if (ret)
 		goto err;
 	ret = register_shrinker(&workingset_shadow_shrinker);
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
