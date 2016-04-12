Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AD26F6B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:35 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id td3so6070404pab.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:35 -0700 (PDT)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id z4si7897599par.198.2016.04.11.21.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:34 -0700 (PDT)
Received: by mail-pf0-x231.google.com with SMTP id c20so6236406pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:34 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 02/11] mm/slab: remove BAD_ALIEN_MAGIC again
Date: Tue, 12 Apr 2016 13:50:57 +0900
Message-Id: <1460436666-20462-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Initial attemp to remove BAD_ALIEN_MAGIC is once reverted by 'commit
edcad2509550 ("Revert "slab: remove BAD_ALIEN_MAGIC"")' because it causes
a problem on m68k which has many node but !CONFIG_NUMA.  In this case,
although alien cache isn't used at all but to cope with some
initialization path, garbage value is used and that is BAD_ALIEN_MAGIC.
Now, this patch set use_alien_caches to 0 when !CONFIG_NUMA, there is no
initialization path problem so we don't need BAD_ALIEN_MAGIC at all.  So
remove it.

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index d8746c0..373b8be 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -421,8 +421,6 @@ static struct kmem_cache kmem_cache_boot = {
 	.name = "kmem_cache",
 };
 
-#define BAD_ALIEN_MAGIC 0x01020304ul
-
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -637,7 +635,7 @@ static int transfer_objects(struct array_cache *to,
 static inline struct alien_cache **alloc_alien_cache(int node,
 						int limit, gfp_t gfp)
 {
-	return (struct alien_cache **)BAD_ALIEN_MAGIC;
+	return NULL;
 }
 
 static inline void free_alien_cache(struct alien_cache **ac_ptr)
@@ -1205,7 +1203,7 @@ void __init kmem_cache_init(void)
 					sizeof(struct rcu_head));
 	kmem_cache = &kmem_cache_boot;
 
-	if (num_possible_nodes() == 1)
+	if (!IS_ENABLED(CONFIG_NUMA) || num_possible_nodes() == 1)
 		use_alien_caches = 0;
 
 	for (i = 0; i < NUM_INIT_LISTS; i++)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
