Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4FD6B0069
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:45 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so9009128pad.41
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:45 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id lx8si4425461pab.115.2014.07.09.04.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:42 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G009DT08NMK60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:24 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 14/21] mm: slub: kasan: disable kasan when
 touching unaccessible memory
Date: Wed, 09 Jul 2014 15:30:08 +0400
Message-id: <1404905415-9046-15-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Some code in slub could validly touch memory marked by kasan as unaccessible.
Even though slub.c doesn't instrumented, functions called in it are instrumented,
so to avoid false positive reports such places are protected by
kasan_disable_local()/kasan_enable_local() calls.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slub.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 6ddedf9..c8dbea7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -560,8 +560,10 @@ static void print_tracking(struct kmem_cache *s, void *object)
 	if (!(s->flags & SLAB_STORE_USER))
 		return;
 
+	kasan_disable_local();
 	print_track("Allocated", get_track(s, object, TRACK_ALLOC));
 	print_track("Freed", get_track(s, object, TRACK_FREE));
+	kasan_enable_local();
 }
 
 static void print_page_info(struct page *page)
@@ -604,6 +606,8 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	unsigned int off;	/* Offset of last byte */
 	u8 *addr = page_address(page);
 
+	kasan_disable_local();
+
 	print_tracking(s, p);
 
 	print_page_info(page);
@@ -632,6 +636,8 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		/* Beginning of the filler is the free pointer */
 		print_section("Padding ", p + off, s->size - off);
 
+	kasan_enable_local();
+
 	dump_stack();
 }
 
@@ -1012,6 +1018,8 @@ static noinline int alloc_debug_processing(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
 {
+
+	kasan_disable_local();
 	if (!check_slab(s, page))
 		goto bad;
 
@@ -1028,6 +1036,7 @@ static noinline int alloc_debug_processing(struct kmem_cache *s,
 		set_track(s, object, TRACK_ALLOC, addr);
 	trace(s, page, object, 1);
 	init_object(s, object, SLUB_RED_ACTIVE);
+	kasan_enable_local();
 	return 1;
 
 bad:
@@ -1041,6 +1050,7 @@ bad:
 		page->inuse = page->objects;
 		page->freelist = NULL;
 	}
+	kasan_enable_local();
 	return 0;
 }
 
@@ -1052,6 +1062,7 @@ static noinline struct kmem_cache_node *free_debug_processing(
 
 	spin_lock_irqsave(&n->list_lock, *flags);
 	slab_lock(page);
+	kasan_disable_local();
 
 	if (!check_slab(s, page))
 		goto fail;
@@ -1088,6 +1099,7 @@ static noinline struct kmem_cache_node *free_debug_processing(
 	trace(s, page, object, 0);
 	init_object(s, object, SLUB_RED_INACTIVE);
 out:
+	kasan_enable_local();
 	slab_unlock(page);
 	/*
 	 * Keep node_lock to preserve integrity
@@ -1096,6 +1108,7 @@ out:
 	return n;
 
 fail:
+	kasan_enable_local();
 	slab_unlock(page);
 	spin_unlock_irqrestore(&n->list_lock, *flags);
 	slab_fix(s, "Object at 0x%p not freed", object);
@@ -1371,8 +1384,11 @@ static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
 	setup_object_debug(s, page, object);
-	if (unlikely(s->ctor))
+	if (unlikely(s->ctor)) {
+		kasan_disable_local();
 		s->ctor(object);
+		kasan_enable_local();
+	}
 }
 
 static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
@@ -1425,11 +1441,12 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	if (kmem_cache_debug(s)) {
 		void *p;
-
+		kasan_disable_local();
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
 						page->objects)
 			check_object(s, page, p, SLUB_RED_INACTIVE);
+		kasan_enable_local();
 	}
 
 	kmemcheck_free_shadow(page, compound_order(page));
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
