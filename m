Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 67A536B0009
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 22:41:05 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id uo6so5039760pac.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:05 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id xe7si856688pab.3.2015.12.21.19.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 19:41:00 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id cy9so27687408pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 19:41:00 -0800 (PST)
From: Laura Abbott <laura@labbott.name>
Subject: [RFC][PATCH 4/7] slob: Add support for sanitization
Date: Mon, 21 Dec 2015 19:40:38 -0800
Message-Id: <1450755641-7856-5-git-send-email-laura@labbott.name>
In-Reply-To: <1450755641-7856-1-git-send-email-laura@labbott.name>
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com


The SLOB allocator does not clear objects on free. This is a security
risk since sensitive data may exist long past its expected life
span. Add support for clearing objects on free.

All credit for the original work should be given to Brad Spengler and
the PaX Team.

Signed-off-by: Laura Abbott <laura@labbott.name>
---
 mm/slob.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 17e8f8c..37a4ecb 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -334,10 +334,21 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	return b;
 }
 
+static void slob_sanitize(struct kmem_cache *c, slob_t *b, int size)
+{
+#ifdef CONFIG_SLAB_MEMORY_SANITIZE
+	if (c && (c->flags & SLAB_NO_SANITIZE))
+		return;
+
+	if (sanitize_slab)
+		memset(b, SLAB_MEMORY_SANITIZE_VALUE, size);
+#endif
+}
+
 /*
  * slob_free: entry point into the slob allocator.
  */
-static void slob_free(void *block, int size)
+static void slob_free(struct kmem_cache *c, void *block, int size)
 {
 	struct page *sp;
 	slob_t *prev, *next, *b = (slob_t *)block;
@@ -365,6 +376,8 @@ static void slob_free(void *block, int size)
 		return;
 	}
 
+	slob_sanitize(c, block, size);
+
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
@@ -495,7 +508,7 @@ void kfree(const void *block)
 	if (PageSlab(sp)) {
 		int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 		unsigned int *m = (unsigned int *)(block - align);
-		slob_free(m, *m + align);
+		slob_free(NULL, m, *m + align);
 	} else
 		__free_pages(sp, compound_order(sp));
 }
@@ -579,10 +592,10 @@ void *kmem_cache_alloc_node(struct kmem_cache *cachep, gfp_t gfp, int node)
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
 
-static void __kmem_cache_free(void *b, int size)
+static void __kmem_cache_free(struct kmem_cache *c, void *b, int size)
 {
 	if (size < PAGE_SIZE)
-		slob_free(b, size);
+		slob_free(c, b, size);
 	else
 		slob_free_pages(b, get_order(size));
 }
@@ -592,7 +605,7 @@ static void kmem_rcu_free(struct rcu_head *head)
 	struct slob_rcu *slob_rcu = (struct slob_rcu *)head;
 	void *b = (void *)slob_rcu - (slob_rcu->size - sizeof(struct slob_rcu));
 
-	__kmem_cache_free(b, slob_rcu->size);
+	__kmem_cache_free(NULL, b, slob_rcu->size);
 }
 
 void kmem_cache_free(struct kmem_cache *c, void *b)
@@ -604,7 +617,7 @@ void kmem_cache_free(struct kmem_cache *c, void *b)
 		slob_rcu->size = c->size;
 		call_rcu(&slob_rcu->head, kmem_rcu_free);
 	} else {
-		__kmem_cache_free(b, c->size);
+		__kmem_cache_free(NULL, b, c->size);
 	}
 
 	trace_kmem_cache_free(_RET_IP_, b);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
