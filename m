Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4576B006E
	for <linux-mm@kvack.org>; Sun,  4 Jan 2015 20:37:41 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so27056979pdi.7
        for <linux-mm@kvack.org>; Sun, 04 Jan 2015 17:37:41 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id d6si81233515pdm.104.2015.01.04.17.37.37
        for <linux-mm@kvack.org>;
        Sun, 04 Jan 2015 17:37:39 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/6] mm/slab: fix gfp flags of percpu allocation at boot phase
Date: Mon,  5 Jan 2015 10:37:26 +0900
Message-Id: <1420421851-3281-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

__alloc_percpu() passed GFP_KERNEL implicitly to core function of
percpu allocator. At boot phase, it's not valid gfp flag so change it.

Without this change, while implementing new feature, I found that
__alloc_percpu() calls kmalloc() which is not initialized at this time
and the system fail to boot. percpu allocator regards GFP_KERNEL as
the sign of the system fully initialized so aggressively try to make
spare room. With GFP_NOWAIT, it doesn't do that so succeed to boot.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 65b5dcb..1150c8b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1990,9 +1990,12 @@ static struct array_cache __percpu *alloc_kmem_cache_cpus(
 	int cpu;
 	size_t size;
 	struct array_cache __percpu *cpu_cache;
+	gfp_t gfp_flags = GFP_KERNEL;
 
 	size = sizeof(void *) * entries + sizeof(struct array_cache);
-	cpu_cache = __alloc_percpu(size, sizeof(void *));
+	if (slab_state < FULL)
+		gfp_flags = GFP_NOWAIT;
+	cpu_cache = __alloc_percpu_gfp(size, sizeof(void *), gfp_flags);
 
 	if (!cpu_cache)
 		return NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
