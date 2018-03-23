Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 774886B0008
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:14:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g66so6801810pfj.11
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:14:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c9si6180045pge.2.2018.03.23.08.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Mar 2018 08:14:22 -0700 (PDT)
Date: Fri, 23 Mar 2018 08:14:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180323151421.GC5624@bombadil.infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <6fd1bba1-e60c-e5b3-58be-52e991cda74f@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6fd1bba1-e60c-e5b3-58be-52e991cda74f@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Mar 23, 2018 at 04:33:24PM +0300, Kirill Tkhai wrote:
> > +	page = virt_to_head_page(ptr);
> > +	if (likely(PageSlab(page)))
> > +		return kmem_cache_free(page->slab_cache, (void *)ptr);
> 
> It seems slab_cache is not generic for all types of slabs. SLOB does not care about it:

Oof.  I was sure I checked that.  You're quite right that it doesn't ...
this should fix that problem:

diff --git a/mm/slob.c b/mm/slob.c
index 623e8a5c46ce..96339420c6fc 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -266,7 +266,7 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node, void *c)
 {
 	struct page *sp;
 	struct list_head *prev;
@@ -324,6 +324,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
 		INIT_LIST_HEAD(&sp->lru);
+		sp->slab_cache = c;
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
@@ -440,7 +441,7 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-		m = slob_alloc(size + align, gfp, align, node);
+		m = slob_alloc(size + align, gfp, align, node, NULL);
 
 		if (!m)
 			return NULL;
@@ -544,7 +545,7 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 	fs_reclaim_release(flags);
 
 	if (c->size < PAGE_SIZE) {
-		b = slob_alloc(c->size, flags, c->align, node);
+		b = slob_alloc(c->size, flags, c->align, node, c);
 		trace_kmem_cache_alloc_node(_RET_IP_, b, c->object_size,
 					    SLOB_UNITS(c->size) * SLOB_UNIT,
 					    flags, node);
@@ -600,6 +601,8 @@ static void kmem_rcu_free(struct rcu_head *head)
 
 void kmem_cache_free(struct kmem_cache *c, void *b)
 {
+	if (!c)
+		return kfree(b);
 	kmemleak_free_recursive(b, c->flags);
 	if (unlikely(c->flags & SLAB_TYPESAFE_BY_RCU)) {
 		struct slob_rcu *slob_rcu;

> Also, using kmem_cache_free() for kmalloc()'ed memory will connect them hardly,
> and this may be difficult to maintain in the future.

I think the win from being able to delete all the little RCU callbacks
that just do a kmem_cache_free() is big enough to outweigh the
disadvantage of forcing slab allocators to support kmem_cache_free()
working on kmalloced memory.

> One more thing, there is
> some kasan checks on the main way of kfree(), and there is no guarantee they
> reflected in kmem_cache_free() identical.

Which function are you talking about here?

slub calls slab_free() for both kfree() and kmem_cache_free().
slab calls __cache_free() for both kfree() and kmem_cache_free().
Each of them do their kasan handling in the called function.
