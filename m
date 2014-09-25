Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id DC4186B0038
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:57:33 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so8528968wgg.2
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 10:57:33 -0700 (PDT)
Received: from cpsmtpb-ews09.kpnxchange.com (cpsmtpb-ews09.kpnxchange.com. [213.75.39.14])
        by mx.google.com with ESMTP id xv4si3653883wjb.86.2014.09.25.10.57.32
        for <linux-mm@kvack.org>;
        Thu, 25 Sep 2014 10:57:32 -0700 (PDT)
Message-ID: <1411667851.2020.6.camel@x41>
Subject: [PATCH] mm/slab: use IS_ENABLED() instead of ZONE_DMA_FLAG
From: Paul Bolle <pebolle@tiscali.nl>
Date: Thu, 25 Sep 2014 19:57:31 +0200
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The Kconfig symbol ZONE_DMA_FLAG probably predates the introduction of
IS_ENABLED(). Remove it and replace its two uses with the equivalent
IS_ENABLED(CONFIG_ZONE_DMA).

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Build tested on x86_64 (on top of next-20140925).

Run tested on i686 (on top of v3.17-rc6). That test required me to
switch from SLUB (Fedora's default) to SLAB. That makes running this
patch both more scary and less informative. Besides, I have no idea how
to hit the codepaths I just changed. You'd expect this to not actually
change slab.o, but I'm not sure how to check that. So, in short: review
very much appreciated.

 mm/Kconfig | 5 -----
 mm/slab.c  | 4 ++--
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 886db21..8e860c7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -273,11 +273,6 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 
-config ZONE_DMA_FLAG
-	int
-	default "0" if !ZONE_DMA
-	default "1"
-
 config BOUNCE
 	bool "Enable bounce buffers"
 	default y
diff --git a/mm/slab.c b/mm/slab.c
index 628f2b5..766c90e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2243,7 +2243,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	cachep->freelist_size = freelist_size;
 	cachep->flags = flags;
 	cachep->allocflags = __GFP_COMP;
-	if (CONFIG_ZONE_DMA_FLAG && (flags & SLAB_CACHE_DMA))
+	if (IS_ENABLED(CONFIG_ZONE_DMA) && (flags & SLAB_CACHE_DMA))
 		cachep->allocflags |= GFP_DMA;
 	cachep->size = size;
 	cachep->reciprocal_buffer_size = reciprocal_value(size);
@@ -2516,7 +2516,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 {
-	if (CONFIG_ZONE_DMA_FLAG) {
+	if (IS_ENABLED(CONFIG_ZONE_DMA)) {
 		if (flags & GFP_DMA)
 			BUG_ON(!(cachep->allocflags & GFP_DMA));
 		else
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
