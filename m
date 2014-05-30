Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBB16B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:51:18 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id ec20so1047990lab.33
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:51:17 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id nv6si11116835lbb.29.2014.05.30.06.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 06:51:16 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 8/8] slab: reap dead memcg caches aggressively
Date: Fri, 30 May 2014 17:51:11 +0400
Message-ID: <23a736c90a81e13a2252d35d9fc3dc04a9ed7d7c.1401457502.git.vdavydov@parallels.com>
In-Reply-To: <cover.1401457502.git.vdavydov@parallels.com>
References: <cover.1401457502.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

There is no use in keeping free objects/slabs on dead memcg caches,
because they will never be allocated. So let's make cache_reap() shrink
as many free objects from such caches as possible.

Note the difference between SLAB and SLUB handling of dead memcg caches.
For SLUB, dead cache destruction is scheduled as soon as the last object
is freed, because dead caches do not cache free objects. For SLAB, dead
caches can keep some free objects on per cpu arrays, so that an empty
dead cache will be hanging around until cache_reap() drains it.

We don't disable free objects caching for SLAB, because it would force
kfree to always take a spin lock, which would degrade performance
significantly.

Since cache_reap() drains all caches once ~4 secs on each CPU, empty
dead caches will die quickly.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index cecc01bba389..d81e46316c99 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3985,6 +3985,11 @@ static void cache_reap(struct work_struct *w)
 		goto out;
 
 	list_for_each_entry(searchp, &slab_caches, list) {
+		int force = 0;
+
+		if (memcg_cache_dead(searchp))
+			force = 1;
+
 		check_irq_on();
 
 		/*
@@ -3996,7 +4001,7 @@ static void cache_reap(struct work_struct *w)
 
 		reap_alien(searchp, n);
 
-		drain_array(searchp, n, cpu_cache_get(searchp), 0, node);
+		drain_array(searchp, n, cpu_cache_get(searchp), force, node);
 
 		/*
 		 * These are racy checks but it does not matter
@@ -4007,15 +4012,17 @@ static void cache_reap(struct work_struct *w)
 
 		n->next_reap = jiffies + REAPTIMEOUT_NODE;
 
-		drain_array(searchp, n, n->shared, 0, node);
+		drain_array(searchp, n, n->shared, force, node);
 
 		if (n->free_touched)
 			n->free_touched = 0;
 		else {
-			int freed;
+			int freed, tofree;
+
+			tofree = force ? slabs_tofree(searchp, n) :
+				DIV_ROUND_UP(n->free_limit, 5 * searchp->num);
 
-			freed = drain_freelist(searchp, n, (n->free_limit +
-				5 * searchp->num - 1) / (5 * searchp->num));
+			freed = drain_freelist(searchp, n, tofree);
 			STATS_ADD_REAPED(searchp, freed);
 		}
 next:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
