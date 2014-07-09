Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CB4706B003D
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:38 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so8871403pdb.35
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:38 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id sm5si42993505pbc.42.2014.07.09.04.36.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:36 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G0083T08XL860@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:33 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 10/21] mm: slab: share virt_to_cache() between
 slab and slub
Date: Wed, 09 Jul 2014 15:30:04 +0400
Message-id: <1404905415-9046-11-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

This patch shares virt_to_cache() between slab and slub and
it used in cache_from_obj() now.
Later virt_to_cache() will be kernel address sanitizer also.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slab.c |  6 ------
 mm/slab.h | 10 +++++++---
 2 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index e7763db..fa4f840 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -433,12 +433,6 @@ static inline void set_obj_status(struct page *page, int idx, int val) {}
 static int slab_max_order = SLAB_MAX_ORDER_LO;
 static bool slab_max_order_set __initdata;
 
-static inline struct kmem_cache *virt_to_cache(const void *obj)
-{
-	struct page *page = virt_to_head_page(obj);
-	return page->slab_cache;
-}
-
 static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
 				 unsigned int idx)
 {
diff --git a/mm/slab.h b/mm/slab.h
index 84c160a..1257ade 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -260,10 +260,15 @@ static inline void memcg_uncharge_slab(struct kmem_cache *s, int order)
 }
 #endif
 
+static inline struct kmem_cache *virt_to_cache(const void *obj)
+{
+	struct page *page = virt_to_head_page(obj);
+	return page->slab_cache;
+}
+
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
-	struct page *page;
 
 	/*
 	 * When kmemcg is not being used, both assignments should return the
@@ -275,8 +280,7 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	if (!memcg_kmem_enabled() && !unlikely(s->flags & SLAB_DEBUG_FREE))
 		return s;
 
-	page = virt_to_head_page(x);
-	cachep = page->slab_cache;
+	cachep = virt_to_cache(x);
 	if (slab_equal_or_root(cachep, s))
 		return cachep;
 
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
