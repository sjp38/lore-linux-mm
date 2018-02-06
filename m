Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9949A6B0009
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 05:20:06 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y13so732739pfl.16
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 02:20:06 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20122.outbound.protection.outlook.com. [40.107.2.122])
        by mx.google.com with ESMTPS id v22si1335982pfd.22.2018.02.06.02.20.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 02:20:05 -0800 (PST)
Subject: [PATCH 2/2] mm: Use kvfree_rcu() in update_memcg_params()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 06 Feb 2018 13:19:56 +0300
Message-ID: <151791239671.5994.2058061081618636334.stgit@localhost.localdomain>
In-Reply-To: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Make update_memcg_params() to use generic kvfree_rcu()
helper and remove free_memcg_params() code.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/slab_common.c |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 10f127b2de7c..92d4a3a9471d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -190,14 +190,6 @@ static void destroy_memcg_params(struct kmem_cache *s)
 		kvfree(rcu_access_pointer(s->memcg_params.memcg_caches));
 }
 
-static void free_memcg_params(struct rcu_head *rcu)
-{
-	struct memcg_cache_array *old;
-
-	old = container_of(rcu, struct memcg_cache_array, rcu);
-	kvfree(old);
-}
-
 static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 {
 	struct memcg_cache_array *old, *new;
@@ -215,7 +207,7 @@ static int update_memcg_params(struct kmem_cache *s, int new_array_size)
 
 	rcu_assign_pointer(s->memcg_params.memcg_caches, new);
 	if (old)
-		call_rcu(&old->rcu, free_memcg_params);
+		kvfree_rcu(old, rcu);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
