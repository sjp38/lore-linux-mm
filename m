Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A2B5C6B01F1
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 17:16:26 -0500 (EST)
Received: by bkbzt12 with SMTP id zt12so7605566bkb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 14:16:24 -0800 (PST)
Message-ID: <4EE67D35.5000307@gmail.com>
Date: Mon, 12 Dec 2011 23:16:21 +0100
From: roel <roel.kluin@gmail.com>
MIME-Version: 1.0
Subject: slab: too much allocated in bootstrap head arrays?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

In mm/slab.c kmem_cache_init() at /* 4) Replace the bootstrap head arrays */
it kmallocs *ptr and memcpy's with sizeof(struct arraycache_init). Is this
correct or should it maybe be with sizeof(struct arraycache) instead?

Please review, i.e. this change:
---
It appears we allocated and copied too much.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 mm/slab.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 83311c9a..6978cbf 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1617,11 +1617,11 @@ void __init kmem_cache_init(void)
 	{
 		struct array_cache *ptr;
 
-		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
+		ptr = kmalloc(sizeof(struct arraycache), GFP_NOWAIT);
 
 		BUG_ON(cpu_cache_get(&cache_cache) != &initarray_cache.cache);
 		memcpy(ptr, cpu_cache_get(&cache_cache),
-		       sizeof(struct arraycache_init));
+		       sizeof(struct arraycache));
 		/*
 		 * Do not assume that spinlocks can be initialized via memcpy:
 		 */
@@ -1629,12 +1629,12 @@ void __init kmem_cache_init(void)
 
 		cache_cache.array[smp_processor_id()] = ptr;
 
-		ptr = kmalloc(sizeof(struct arraycache_init), GFP_NOWAIT);
+		ptr = kmalloc(sizeof(struct arraycache), GFP_NOWAIT);
 
 		BUG_ON(cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep)
 		       != &initarray_generic.cache);
 		memcpy(ptr, cpu_cache_get(malloc_sizes[INDEX_AC].cs_cachep),
-		       sizeof(struct arraycache_init));
+		       sizeof(struct arraycache));
 		/*
 		 * Do not assume that spinlocks can be initialized via memcpy:
 		 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
