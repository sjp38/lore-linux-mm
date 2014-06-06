Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id D31B86B003C
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:55 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id e16so1521710lan.14
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:55 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id j3si21301388lba.59.2014.06.06.06.22.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:54 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 7/8] slub: make dead memcg caches discard free slabs immediately
Date: Fri, 6 Jun 2014 17:22:44 +0400
Message-ID: <3b53266b76556dd042bbf6147207c70473572a7e.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since a dead memcg cache is destroyed only after the last slab allocated
to it is freed, we must disable caching of empty slabs for such caches,
otherwise they will be hanging around forever.

This patch makes SLUB discard dead memcg caches' slabs as soon as they
become empty. To achieve that, it disables per cpu partial lists for
dead caches (see put_cpu_partial) and forbids keeping empty slabs on per
node partial lists by setting cache's min_partial to 0 on
kmem_cache_shrink, which is always called on memcg offline (see
memcg_unregister_all_caches).

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Thanks-to: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slub.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index e46d6abe8a68..1dad7e2c586a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2015,6 +2015,8 @@ static void unfreeze_partials(struct kmem_cache *s,
 #endif
 }
 
+static void flush_all(struct kmem_cache *s);
+
 /*
  * Put a page that was just frozen (in __slab_free) into a partial page
  * slot if available. This is done without interrupts disabled and without
@@ -2064,6 +2066,21 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
 								!= oldpage);
+
+	if (memcg_cache_dead(s)) {
+               bool done = false;
+               unsigned long flags;
+
+               local_irq_save(flags);
+               if (this_cpu_read(s->cpu_slab->partial) == page) {
+                       unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
+                       done = true;
+               }
+               local_irq_restore(flags);
+
+               if (!done)
+                       flush_all(s);
+	}
 #endif
 }
 
@@ -3403,6 +3420,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
 	unsigned long flags;
 
+	if (memcg_cache_dead(s))
+		s->min_partial = 0;
+
 	if (!slabs_by_inuse) {
 		/*
 		 * Do not fail shrinking empty slabs if allocation of the
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
