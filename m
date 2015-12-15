Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id C622B6B0257
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 07:02:41 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id o67so16428752iof.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 04:02:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a196si4319871ioe.161.2015.12.15.04.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 04:02:40 -0800 (PST)
Date: Tue, 15 Dec 2015 13:02:35 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH V2 8/9] slab: implement bulk free in SLAB allocator
Message-ID: <20151215130235.10e92367@redhat.com>
In-Reply-To: <20151214161958.1a8edf79@redhat.com>
References: <20151208161751.21945.53936.stgit@firesoul>
	<20151208161903.21945.33876.stgit@firesoul>
	<alpine.DEB.2.20.1512090945570.30894@east.gentwo.org>
	<20151214161958.1a8edf79@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com


On Mon, 14 Dec 2015 16:19:58 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Wed, 9 Dec 2015 10:06:39 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:
> 
> > From: Christoph Lameter <cl@linux.com>
> > Subject: slab bulk api: Remove the kmem_cache parameter from kmem_cache_bulk_free()
> > 
> > It is desirable and necessary to free objects from different kmem_caches.
> > It is required in order to support memcg object freeing across different5
> > cgroups.
> > 
> > So drop the pointless parameter and allow freeing of arbitrary lists
> > of slab allocated objects.
> > 
> > This patch also does the proper compound page handling so that
> > arbitrary objects allocated via kmalloc() can be handled by
> > kmem_cache_bulk_free().
> > 
> > Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> I've modified this patch, to instead introduce a kfree_bulk() and keep
> the old behavior of kmem_cache_free_bulk().  This allow us to easier
> compare the two impl. approaches.
> 
> [...]
> > Index: linux/mm/slub.c
> > ===================================================================
> > --- linux.orig/mm/slub.c
> > +++ linux/mm/slub.c
> > @@ -2887,23 +2887,30 @@ static int build_detached_freelist(struc
> > 
> > 
> >  /* Note that interrupts must be enabled when calling this function. */
> > -void kmem_cache_free_bulk(struct kmem_cache *orig_s, size_t size, void **p) 
> > +void kmem_cache_free_bulk(size_t size, void **p)
> 
> Renamed to kfree_bulk(size_t size, void **p)
> 
> >  {
> >  	if (WARN_ON(!size))
> >  		return;
> > 
> >  	do {
> >  		struct detached_freelist df;
> > -		struct kmem_cache *s;
> > +		struct page *page;
> > 
> > -		/* Support for memcg */
> > -		s = cache_from_obj(orig_s, p[size - 1]);
> > +		page = virt_to_head_page(p[size - 1]);
> > 
> > -		size = build_detached_freelist(s, size, p, &df);
> > +		if (unlikely(!PageSlab(page))) {
> > +			BUG_ON(!PageCompound(page));
> > +			kfree_hook(p[size - 1]);
> > +			__free_kmem_pages(page, compound_order(page));
> > +			p[--size] = NULL;
> > +			continue;
> > +		}
> > +
> > +		size = build_detached_freelist(page->slab_cache, size, p, &df);
> > 		if (unlikely(!df.page))
> >  			continue;
> > 
> > -		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
> > +		slab_free(page->slab_cache, df.page, df.freelist,
> > + 			df.tail, df.cnt, _RET_IP_);
> > 	} while (likely(size));
> >  }
> >  EXPORT_SYMBOL(kmem_cache_free_bulk);
> 
> This specific implementation was too slow, mostly because we call
> virt_to_head_page() both in this function and inside build_detached_freelist().
> 
> After integrating this directly into build_detached_freelist() I'm
> getting more comparative results.
> 
> Results with disabled CONFIG_MEMCG_KMEM, and SLUB (and slab_nomerge for
> more accurate results between runs):
> 
>  bulk- fallback          - kmem_cache_free_bulk - kfree_bulk
>  1 - 58 cycles 14.735 ns -  55 cycles 13.880 ns -  59 cycles 14.843 ns
>  2 - 53 cycles 13.298 ns -  32 cycles  8.037 ns -  34 cycles 8.592 ns
>  3 - 51 cycles 12.837 ns -  25 cycles  6.442 ns -  27 cycles 6.794 ns
>  4 - 50 cycles 12.514 ns -  23 cycles  5.952 ns -  23 cycles 5.958 ns
>  8 - 48 cycles 12.097 ns -  20 cycles  5.160 ns -  22 cycles 5.505 ns
>  16 - 47 cycles 11.888 ns -  19 cycles 4.900 ns -  19 cycles 4.969 ns
>  30 - 47 cycles 11.793 ns -  18 cycles 4.688 ns -  18 cycles 4.682 ns
>  32 - 47 cycles 11.926 ns -  18 cycles 4.674 ns -  18 cycles 4.702 ns
>  34 - 95 cycles 23.823 ns -  24 cycles 6.068 ns -  24 cycles 6.058 ns
>  48 - 81 cycles 20.258 ns -  21 cycles 5.360 ns -  21 cycles 5.338 ns
>  64 - 73 cycles 18.414 ns -  20 cycles 5.160 ns -  20 cycles 5.140 ns
>  128 - 90 cycles 22.563 ns -  27 cycles 6.765 ns -  27 cycles 6.801 ns
>  158 - 99 cycles 24.831 ns -  30 cycles 7.625 ns -  30 cycles 7.720 ns
>  250 - 104 cycles 26.173 ns -  37 cycles 9.271 ns -  37 cycles 9.371 ns
> 
> As can been seen the old kmem_cache_free_bulk() is faster than the new
> kfree_bulk() (which omits the kmem_cache pointer and need to derive it
> from the page->slab_cache). The base (bulk=1) extra cost is 4 cycles,
> which then gets amortized as build_detached_freelist() combines objects
> belonging to same page.
> 
> This is likely because the compiler, with disabled CONFIG_MEMCG_KMEM=n,
> can optimize and avoid doing the lookup of the kmem_cache structure.
> 
> I'll start doing testing with CONFIG_MEMCG_KMEM enabled...

Enabling CONFIG_MEMCG_KMEM didn't change the performance, likely
because memcg_kmem_enabled() uses a static_key_false() construct.

Implemented kfree_bulk() as an inline function just calling
kmem_cache_free_bulk(NULL, size, p) run with CONFIG_MEMCG_KMEM=y (but
no "user" of memcg):

 bulk- fallback          - kmem_cache_free_bulk - kmem_cache_free_bulk(s=NULL)
 1 - 60 cycles 15.232 ns -  52 cycles 13.124 ns -  58 cycles 14.562 ns
 2 - 54 cycles 13.678 ns -  31 cycles 7.875 ns -  34 cycles 8.509 ns
 3 - 52 cycles 13.112 ns -  25 cycles 6.406 ns -  28 cycles 7.045 ns
 4 - 51 cycles 12.833 ns -  24 cycles 6.036 ns -  24 cycles 6.076 ns
 8 - 49 cycles 12.367 ns -  21 cycles 5.404 ns -  22 cycles 5.522 ns
 16 - 48 cycles 12.144 ns -  19 cycles 4.934 ns -  19 cycles 4.967 ns
 30 - 50 cycles 12.542 ns -  18 cycles 4.685 ns -  18 cycles 4.687 ns
 32 - 48 cycles 12.234 ns -  18 cycles 4.661 ns -  18 cycles 4.662 ns
 34 - 96 cycles 24.204 ns -  24 cycles 6.068 ns -  24 cycles 6.067 ns
 48 - 82 cycles 20.553 ns -  21 cycles 5.410 ns -  21 cycles 5.433 ns
 64 - 74 cycles 18.743 ns -  20 cycles 5.171 ns -  20 cycles 5.179 ns
 128 - 91 cycles 22.791 ns -  26 cycles 6.601 ns -  26 cycles 6.600 ns
 158 - 100 cycles 25.191 ns -  30 cycles 7.569 ns -  30 cycles 7.617 ns
 250 - 106 cycles 26.535 ns -  37 cycles 9.426 ns -  37 cycles 9.427 ns

As can be seen, it is still more costly to get the kmem_cache pointer
via the object->slab_cache, even when compiled with CONFIG_MEMCG_KMEM.


But what happen when enabling a "user" of kmemcg, which modify the
static_key_false() in function call memcg_kmem_enabled().

First notice normal kmem fastpath cost increased: 70 cycles(tsc) 17.640 ns

 bulk- fallback          - kmem_cache_free_bulk - kmem_cache_free_bulk(s=NULL)
 1 - 85 cycles 21.351 ns -  76 cycles 19.086 ns -  74 cycles 18.701 ns
 2 - 79 cycles 19.907 ns -  43 cycles 10.848 ns -  41 cycles 10.467 ns
 3 - 77 cycles 19.310 ns -  32 cycles 8.132 ns -  31 cycles 7.880 ns
 4 - 76 cycles 19.017 ns -  28 cycles 7.195 ns -  28 cycles 7.050 ns
 8 - 77 cycles 19.443 ns -  23 cycles 5.838 ns -  23 cycles 5.782 ns
 16 - 75 cycles 18.815 ns -  20 cycles 5.174 ns -  20 cycles 5.127 ns
 30 - 74 cycles 18.719 ns -  19 cycles 4.870 ns -  19 cycles 4.816 ns
 32 - 75 cycles 18.917 ns -  19 cycles 4.850 ns -  19 cycles 4.800 ns
 34 - 119 cycles 29.878 ns -  25 cycles 6.312 ns -  25 cycles 6.282 ns
 48 - 106 cycles 26.536 ns -  21 cycles 5.471 ns -  21 cycles 5.448 ns
 64 - 98 cycles 24.635 ns -  20 cycles 5.239 ns -  20 cycles 5.224 ns
 128 - 114 cycles 28.586 ns -  27 cycles 6.768 ns -  26 cycles 6.736 ns
 158 - 124 cycles 31.173 ns -  30 cycles 7.668 ns -  30 cycles 7.611 ns
 250 - 129 cycles 32.336 ns -  37 cycles 9.460 ns -  37 cycles 9.468 ns

With kmemcg runtime-enabled, I was expecting to see a bigger win for
the case of kmem_cache_free_bulk(s=NULL).

Implemented a function kfree_bulk_export(), which inlines build_detached_freelist()
and which avoids including the code path for memcg.  But result is almost the same:

 bulk- fallback          - kmem_cache_free_bulk - kfree_bulk_export
 1 - 84 cycles 21.221 ns -  77 cycles 19.324 ns -  74 cycles 18.515 ns
 2 - 79 cycles 19.963 ns -  44 cycles 11.120 ns -  41 cycles 10.329 ns
 3 - 77 cycles 19.471 ns -  33 cycles 8.291 ns -  31 cycles 7.771 ns
 4 - 76 cycles 19.191 ns -  28 cycles 7.100 ns -  27 cycles 6.765 ns
 8 - 78 cycles 19.525 ns -  23 cycles 5.781 ns -  22 cycles 5.737 ns
 16 - 75 cycles 18.922 ns -  20 cycles 5.152 ns -  20 cycles 5.092 ns
 30 - 75 cycles 18.812 ns -  19 cycles 4.864 ns -  19 cycles 4.833 ns
 32 - 75 cycles 18.807 ns -  19 cycles 4.852 ns -  23 cycles 5.896 ns
 34 - 119 cycles 29.989 ns -  25 cycles 6.258 ns -  25 cycles 6.411 ns
 48 - 106 cycles 26.677 ns -  28 cycles 7.182 ns -  22 cycles 5.651 ns
 64 - 98 cycles 24.716 ns -  20 cycles 5.245 ns -  21 cycles 5.425 ns
 128 - 115 cycles 28.905 ns -  26 cycles 6.748 ns -  27 cycles 6.787 ns
 158 - 124 cycles 31.039 ns -  30 cycles 7.604 ns -  30 cycles 7.629 ns
 250 - 129 cycles 32.372 ns -  37 cycles 9.475 ns -  37 cycles 9.325 ns

I took a closer look with perf, and it looks like the extra cost from
enabling kmemcg originates from the alloc code path.  Specifically the
function call get_mem_cgroup_from_mm(9.95%) is the costly part, plus
__memcg_kmem_get_cache(4.84%) and __memcg_kmem_put_cache(1.35%)


(Added current code as a patch below signature)
- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[PATCH] New API kfree_bulk()

---
 include/linux/slab.h |   14 +++++++++++++
 mm/slab_common.c     |    8 ++++++--
 mm/slub.c            |   52 +++++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 67 insertions(+), 7 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 2037a861e367..9dd353215c2b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -317,6 +317,20 @@ void kmem_cache_free(struct kmem_cache *, void *);
  */
 void kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);
 int kmem_cache_alloc_bulk(struct kmem_cache *, gfp_t, size_t, void **);
+void kfree_bulk_export(size_t, void **);
+
+static __always_inline void kfree_bulk(size_t size, void **p)
+{
+	/* Reusing call to kmem_cache_free_bulk() allow kfree_bulk to
+	 * use same code icache
+	 */
+	kmem_cache_free_bulk(NULL, size, p);
+	/*
+	 * Inlining in kfree_bulk_export() generate smaller code size
+	 * than more generic kmem_cache_free_bulk().
+	 */
+	// kfree_bulk_export(size, p);
+}
 
 #ifdef CONFIG_NUMA
 void *__kmalloc_node(size_t size, gfp_t flags, int node) __assume_kmalloc_alignment;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3c6a86b4ec25..963c25589949 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -108,8 +108,12 @@ void __kmem_cache_free_bulk(struct kmem_cache *s, size_t nr, void **p)
 {
 	size_t i;
 
-	for (i = 0; i < nr; i++)
-		kmem_cache_free(s, p[i]);
+	for (i = 0; i < nr; i++) {
+		if (s)
+			kmem_cache_free(s, p[i]);
+		else
+			kfree(p[i]);
+	}
 }
 
 int __kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t nr,
diff --git a/mm/slub.c b/mm/slub.c
index 4e4dfc4cdd0c..1675f42f17b5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2833,29 +2833,46 @@ struct detached_freelist {
  * synchronization primitive.  Look ahead in the array is limited due
  * to performance reasons.
  */
-static int build_detached_freelist(struct kmem_cache **s, size_t size,
-				   void **p, struct detached_freelist *df)
+static inline
+int build_detached_freelist(struct kmem_cache **s, size_t size,
+			    void **p, struct detached_freelist *df)
 {
 	size_t first_skipped_index = 0;
 	int lookahead = 3;
 	void *object;
+	struct page *page;
 
 	/* Always re-init detached_freelist */
 	df->page = NULL;
 
 	do {
 		object = p[--size];
+		/* Do we need !ZERO_OR_NULL_PTR(object) here? (for kfree) */
 	} while (!object && size);
 
 	if (!object)
 		return 0;
 
-	/* Support for memcg, compiler can optimize this out */
-	*s = cache_from_obj(*s, object);
+	page = virt_to_head_page(object);
+	if (!*s) {
+		/* Handle kalloc'ed objects */
+		if (unlikely(!PageSlab(page))) {
+			BUG_ON(!PageCompound(page));
+			kfree_hook(object);
+			__free_kmem_pages(page, compound_order(page));
+			p[size] = NULL; /* mark object processed */
+			return size;
+		}
+		/* Derive kmem_cache from object */
+		*s = page->slab_cache;
+	} else {
+		/* Support for memcg, compiler can optimize this out */
+		*s = cache_from_obj(*s, object);
+	}
 
 	/* Start new detached freelist */
+	df->page = page;
 	set_freepointer(*s, object, NULL);
-	df->page = virt_to_head_page(object);
 	df->tail = object;
 	df->freelist = object;
 	p[size] = NULL; /* mark object processed */
@@ -2906,6 +2923,31 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
+/* Note that interrupts must be enabled when calling this function.
+ * This function can also handle kmem_cache allocated object arrays
+ */
+// Will likely remove this function
+void kfree_bulk_export(size_t size, void **p)
+{
+	if (WARN_ON(!size))
+		return;
+
+	do {
+		struct detached_freelist df;
+		/* NULL here removes code in inlined build_detached_freelist */
+		struct kmem_cache *s = NULL;
+
+		size = build_detached_freelist(&s, size, p, &df);
+		if (unlikely(!df.page))
+			continue;
+
+		slab_free(s, df.page, df.freelist, df.tail, df.cnt, _RET_IP_);
+//		slab_free(df.page->slab_cache, df.page, df.freelist, df.tail,
+//			  df.cnt, _RET_IP_);
+	} while (likely(size));
+}
+EXPORT_SYMBOL(kfree_bulk_export);
+
 /* Note that interrupts must be enabled when calling this function. */
 int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			  void **p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
