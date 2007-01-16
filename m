Message-Id: <20070116101815.999600000@taijtu.programming.kicks-ass.net>
References: <20070116094557.494892000@taijtu.programming.kicks-ass.net>
Date: Tue, 16 Jan 2007 10:46:05 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 8/9] slab: kmem_cache_objs_to_pages()
Content-Disposition: inline; filename=kmem_cache_objs_to_pages.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org
Cc: David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Provide a method to calculate the number of pages needed to store a given
number of slab objects (upper bound when considering possible partial and
free slabs).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/slab.h |    1 +
 mm/slab.c            |    6 ++++++
 2 files changed, 7 insertions(+)

Index: linux-2.6-git/include/linux/slab.h
===================================================================
--- linux-2.6-git.orig/include/linux/slab.h	2007-01-09 11:28:32.000000000 +0100
+++ linux-2.6-git/include/linux/slab.h	2007-01-09 11:30:16.000000000 +0100
@@ -43,6 +43,7 @@ typedef struct kmem_cache kmem_cache_t _
  */
 void __init kmem_cache_init(void);
 extern int slab_is_available(void);
+extern unsigned int kmem_cache_objs_to_pages(struct kmem_cache *, int);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
Index: linux-2.6-git/mm/slab.c
===================================================================
--- linux-2.6-git.orig/mm/slab.c	2007-01-09 11:30:00.000000000 +0100
+++ linux-2.6-git/mm/slab.c	2007-01-09 11:30:16.000000000 +0100
@@ -4482,3 +4482,9 @@ unsigned int ksize(const void *objp)
 
 	return obj_size(virt_to_cache(objp));
 }
+
+unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
+{
+	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;
+}
+EXPORT_SYMBOL_GPL(kmem_cache_objs_to_pages);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
