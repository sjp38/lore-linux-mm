Message-ID: <48AB1769.3040703@linux-foundation.org>
Date: Tue, 19 Aug 2008 13:56:41 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with	_RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost>
In-Reply-To: <20080819182423.GA5520@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> On Tue, Aug 19, 2008 at 01:14:01PM -0500, Christoph Lameter wrote:
>> Eduard - Gabriel Munteanu wrote:
>>
>>>  void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
>>>  {
>>> -	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
>>> +	return slab_alloc(s, gfpflags, -1, (void *) _RET_IP_);
>>>  }
>> Could you get rid of the casts by changing the type of parameter of slab_alloc()?
> 
> I just looked at it and it isn't a trivial change. slab_alloc() calls
> other functions which expect a void ptr. Even if slab_alloc() were to
> take an unsigned long and then cast it to a void ptr, other functions do
> call slab_alloc() with void ptr arguments (so the casts would move
> there).
> 
> I'd rather have this merged as it is and change things later, so that
> kmemtrace gets some testing from Pekka and others. 
> 

Well maybe this patch will do it then:

Subject: slub: Use _RET_IP and use "unsigned long" for kernel text addresses

Use _RET_IP_ instead of buildint_return_address() and make slub use unsigned long
instead of void * for addresses.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/slub.c |   46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2008-08-19 11:40:52.332357770 -0700
+++ linux-2.6/mm/slub.c	2008-08-19 11:52:17.479064425 -0700
@@ -177,7 +177,7 @@ static LIST_HEAD(slab_caches);
  * Tracking user of a slab.
  */
 struct track {
-	void *addr;		/* Called from address */
+	unsigned long addr;	/* Called from address */
 	int cpu;		/* Was running on cpu */
 	int pid;		/* Pid context */
 	unsigned long when;	/* When did the operation occur */
@@ -366,7 +366,7 @@ static struct track *get_track(struct km
 }

 static void set_track(struct kmem_cache *s, void *object,
-				enum track_item alloc, void *addr)
+				enum track_item alloc, unsigned long addr)
 {
 	struct track *p;

@@ -390,8 +390,8 @@ static void init_tracking(struct kmem_ca
 	if (!(s->flags & SLAB_STORE_USER))
 		return;

-	set_track(s, object, TRACK_FREE, NULL);
-	set_track(s, object, TRACK_ALLOC, NULL);
+	set_track(s, object, TRACK_FREE, 0L);
+	set_track(s, object, TRACK_ALLOC, 0L);
 }

 static void print_track(const char *s, struct track *t)
@@ -399,7 +399,7 @@ static void print_track(const char *s, s
 	if (!t->addr)
 		return;

-	printk(KERN_ERR "INFO: %s in %pS age=%lu cpu=%u pid=%d\n",
+	printk(KERN_ERR "INFO: %s in %lxS age=%lu cpu=%u pid=%d\n",
 		s, t->addr, jiffies - t->when, t->cpu, t->pid);
 }

@@ -865,7 +865,7 @@ static void setup_object_debug(struct km
 }

 static int alloc_debug_processing(struct kmem_cache *s, struct page *page,
-						void *object, void *addr)
+						void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
 		goto bad;
@@ -905,7 +905,7 @@ bad:
 }

 static int free_debug_processing(struct kmem_cache *s, struct page *page,
-						void *object, void *addr)
+						void *object, unsigned long addr)
 {
 	if (!check_slab(s, page))
 		goto fail;
@@ -1028,10 +1028,10 @@ static inline void setup_object_debug(st
 			struct page *page, void *object) {}

 static inline int alloc_debug_processing(struct kmem_cache *s,
-	struct page *page, void *object, void *addr) { return 0; }
+	struct page *page, void *object, unsigned long addr) { return 0; }

 static inline int free_debug_processing(struct kmem_cache *s,
-	struct page *page, void *object, void *addr) { return 0; }
+	struct page *page, void *object, unsigned long) { return 0; }

 static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
 			{ return 1; }
@@ -1499,7 +1499,7 @@ static inline int node_match(struct kmem
  * a call to the page allocator and the setup of a new slab.
  */
 static void *__slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr, struct kmem_cache_cpu *c)
+		gfp_t gfpflags, int node, unsigned long addr, struct kmem_cache_cpu *c)
 {
 	void **object;
 	struct page *new;
@@ -1583,7 +1583,7 @@ debug:
  * Otherwise we can simply pick the next object from the lockless free list.
  */
 static __always_inline void *slab_alloc(struct kmem_cache *s,
-		gfp_t gfpflags, int node, void *addr)
+		gfp_t gfpflags, int node, unsigned long addr)
 {
 	void **object;
 	struct kmem_cache_cpu *c;
@@ -1612,14 +1612,14 @@ static __always_inline void *slab_alloc(

 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, -1, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc);

 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
+	return slab_alloc(s, gfpflags, node, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
@@ -1633,7 +1633,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  * handling required then we can return immediately.
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-				void *x, void *addr, unsigned int offset)
+				void *x, unsigned long addr, unsigned int offset)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1703,7 +1703,7 @@ debug:
  * with all sorts of special processing.
  */
 static __always_inline void slab_free(struct kmem_cache *s,
-			struct page *page, void *x, void *addr)
+			struct page *page, void *x, unsigned long addr)
 {
 	void **object = (void *)x;
 	struct kmem_cache_cpu *c;
@@ -1730,7 +1730,7 @@ void kmem_cache_free(struct kmem_cache *

 	page = virt_to_head_page(x);

-	slab_free(s, page, x, __builtin_return_address(0));
+	slab_free(s, page, x, _RET_IP_);
 }
 EXPORT_SYMBOL(kmem_cache_free);

@@ -2657,7 +2657,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	return slab_alloc(s, flags, -1, __builtin_return_address(0));
+	return slab_alloc(s, flags, -1, _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc);

@@ -2685,7 +2685,7 @@ void *__kmalloc_node(size_t size, gfp_t
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	return slab_alloc(s, flags, node, __builtin_return_address(0));
+	return slab_alloc(s, flags, node, _RET_IP_);
 }
 EXPORT_SYMBOL(__kmalloc_node);
 #endif
@@ -2742,7 +2742,7 @@ void kfree(const void *x)
 		put_page(page);
 		return;
 	}
-	slab_free(page->slab, page, object, __builtin_return_address(0));
+	slab_free(page->slab, page, object, _RET_IP_);
 }
 EXPORT_SYMBOL(kfree);

@@ -3210,7 +3210,7 @@ void *__kmalloc_track_caller(size_t size
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	return slab_alloc(s, gfpflags, -1, caller);
+	return slab_alloc(s, gfpflags, -1, (unsigned long)caller);
 }

 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
@@ -3226,7 +3226,7 @@ void *__kmalloc_node_track_caller(size_t
 	if (unlikely(ZERO_OR_NULL_PTR(s)))
 		return s;

-	return slab_alloc(s, gfpflags, node, caller);
+	return slab_alloc(s, gfpflags, node, (unsigned long)caller);
 }

 #ifdef CONFIG_SLUB_DEBUG
@@ -3425,7 +3425,7 @@ static void resiliency_test(void) {};

 struct location {
 	unsigned long count;
-	void *addr;
+	unsigned long addr;
 	long long sum_time;
 	long min_time;
 	long max_time;
@@ -3473,7 +3473,7 @@ static int add_location(struct loc_track
 {
 	long start, end, pos;
 	struct location *l;
-	void *caddr;
+	unsigned long caddr;
 	unsigned long age = jiffies - track->when;

 	start = -1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
