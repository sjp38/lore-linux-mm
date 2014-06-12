Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id AE53E6B00A1
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 16:38:58 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so972741lab.15
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 13:38:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id j8si28093766laf.12.2014.06.12.13.38.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jun 2014 13:38:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v3 7/8] slub: make dead memcg caches discard free slabs immediately
Date: Fri, 13 Jun 2014 00:38:21 +0400
Message-ID: <d4608a7a00080a51740d747703af5462f1255176.1402602126.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402602126.git.vdavydov@parallels.com>
References: <cover.1402602126.git.vdavydov@parallels.com>
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
 mm/slub.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 52565a9426ef..0d2d1978e62c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2064,6 +2064,14 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 
 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
 								!= oldpage);
+
+	if (memcg_cache_dead(s)) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
+		local_irq_restore(flags);
+	}
 #endif
 }
 
@@ -3409,6 +3417,9 @@ int __kmem_cache_shrink(struct kmem_cache *s)
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
