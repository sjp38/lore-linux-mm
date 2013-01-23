Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 3F3076B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 00:15:45 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 23 Jan 2013 15:11:41 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 411AD2BB004A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:15:39 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0N5FapB66912388
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:15:38 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0N5FafW018522
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:15:37 +1100
Date: Wed, 23 Jan 2013 13:15:34 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/3] slub: correct to calculate num of acquired
 objects in get_partial_node()
Message-ID: <20130123051534.GB29207@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 21, 2013 at 05:01:25PM +0900, Joonsoo Kim wrote:
>There is a subtle bug when calculating a number of acquired objects.
>
>Currently, we calculate "available = page->objects - page->inuse",
>after acquire_slab() is called in get_partial_node().
>
>In acquire_slab() with mode = 1, we always set new.inuse = page->objects.
>So,
>
>	acquire_slab(s, n, page, object == NULL);
>
>	if (!object) {
>		c->page = page;
>		stat(s, ALLOC_FROM_PARTIAL);
>		object = t;
>		available = page->objects - page->inuse;
>
>		!!! availabe is always 0 !!!
>	...
>
>Therfore, "available > s->cpu_partial / 2" is always false and
>we always go to second iteration.
>This patch correct this problem.
>
>After that, we don't need return value of put_cpu_partial().
>So remove it.
>
>v2: calculate nr of objects using new.objects and new.inuse.
>It is more accurate way than before.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/slub.c b/mm/slub.c
>index ba2ca53..7204c74 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1493,7 +1493,7 @@ static inline void remove_partial(struct kmem_cache_node *n,
>  */
> static inline void *acquire_slab(struct kmem_cache *s,
> 		struct kmem_cache_node *n, struct page *page,
>-		int mode)
>+		int mode, int *objects)
> {
> 	void *freelist;
> 	unsigned long counters;
>@@ -1507,6 +1507,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
> 	freelist = page->freelist;
> 	counters = page->counters;
> 	new.counters = counters;
>+	*objects = new.objects - new.inuse;
> 	if (mode) {
> 		new.inuse = page->objects;
> 		new.freelist = NULL;
>@@ -1528,7 +1529,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
> 	return freelist;
> }
>
>-static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
>+static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
> static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags);
>
> /*
>@@ -1539,6 +1540,8 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
> {
> 	struct page *page, *page2;
> 	void *object = NULL;
>+	int available = 0;
>+	int objects;
>
> 	/*
> 	 * Racy check. If we mistakenly see no partial slabs then we
>@@ -1552,22 +1555,21 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
> 	spin_lock(&n->list_lock);
> 	list_for_each_entry_safe(page, page2, &n->partial, lru) {
> 		void *t;
>-		int available;
>
> 		if (!pfmemalloc_match(page, flags))
> 			continue;
>
>-		t = acquire_slab(s, n, page, object == NULL);
>+		t = acquire_slab(s, n, page, object == NULL, &objects);
> 		if (!t)
> 			break;
>
>+		available += objects;
> 		if (!object) {
> 			c->page = page;
> 			stat(s, ALLOC_FROM_PARTIAL);
> 			object = t;
>-			available =  page->objects - page->inuse;
> 		} else {
>-			available = put_cpu_partial(s, page, 0);
>+			put_cpu_partial(s, page, 0);
> 			stat(s, CPU_PARTIAL_NODE);
> 		}
> 		if (kmem_cache_debug(s) || available > s->cpu_partial / 2)
>@@ -1946,7 +1948,7 @@ static void unfreeze_partials(struct kmem_cache *s,
>  * If we did not find a slot then simply move all the partials to the
>  * per node partial list.
>  */
>-static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>+static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> {
> 	struct page *oldpage;
> 	int pages;
>@@ -1984,7 +1986,6 @@ static int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> 		page->next = oldpage;
>
> 	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
>-	return pobjects;
> }
>
> static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
