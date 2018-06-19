Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCF46B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:34:01 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t17-v6so502491ply.13
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 14:34:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v41-v6sor236721plg.73.2018.06.19.14.34.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 14:34:00 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
Date: Tue, 19 Jun 2018 14:33:52 -0700
Message-Id: <20180619213352.71740-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A . Donenfeld" <Jason@zx2c4.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
allocated per node for a kmem_cache. Thus, slabs_node() in
__kmem_cache_empty() will always return 0. So, in such situation, it is
required to check per-cpu slabs to make sure if a kmem_cache is empty or
not.

Please note that __kmem_cache_shutdown() and __kmem_cache_shrink() are
not affected by !CONFIG_SLUB_DEBUG as they call flush_all() to clear
per-cpu slabs.

Fixes: f9e13c0a5a33 ("slab, slub: skip unnecessary kasan_cache_shutdown()")
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Reported-by: Jason A . Donenfeld <Jason@zx2c4.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <stable@vger.kernel.org>
---
 mm/slub.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index a3b8467c14af..731c02b371ae 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3673,9 +3673,23 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 
 bool __kmem_cache_empty(struct kmem_cache *s)
 {
-	int node;
+	int cpu, node;
 	struct kmem_cache_node *n;
 
+	/*
+	 * slabs_node will always be 0 for !CONFIG_SLUB_DEBUG. So, manually
+	 * check slabs for all cpus.
+	 */
+	if (!IS_ENABLED(CONFIG_SLUB_DEBUG)) {
+		for_each_online_cpu(cpu) {
+			struct kmem_cache_cpu *c;
+
+			c = per_cpu_ptr(s->cpu_slab, cpu);
+			if (c->page || slub_percpu_partial(c))
+				return false;
+		}
+	}
+
 	for_each_kmem_cache_node(s, node, n)
 		if (n->nr_partial || slabs_node(s, node))
 			return false;
-- 
2.18.0.rc1.244.gcf134e6275-goog
