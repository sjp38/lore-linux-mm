Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 652036B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 04:08:44 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so628111pad.22
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 01:08:43 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id xg3si905996pab.211.2014.10.23.01.08.41
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 01:08:43 -0700 (PDT)
Date: Thu, 23 Oct 2014 17:09:42 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/4] [RFC] slub: Fastpath optimization (especially for RT)
Message-ID: <20141023080942.GA7598@js1304-P5Q-DELUXE>
References: <20141022155517.560385718@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141022155517.560385718@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com

On Wed, Oct 22, 2014 at 10:55:17AM -0500, Christoph Lameter wrote:
> We had to insert a preempt enable/disable in the fastpath a while ago. This
> was mainly due to a lot of state that is kept to be allocating from the per
> cpu freelist. In particular the page field is not covered by
> this_cpu_cmpxchg used in the fastpath to do the necessary atomic state
> change for fast path allocation and freeing.
> 
> This patch removes the need for the page field to describe the state of the
> per cpu list. The freelist pointer can be used to determine the page struct
> address if necessary.
> 
> However, currently this does not work for the termination value of a list
> which is NULL and the same for all slab pages. If we use a valid pointer
> into the page as well as set the last bit then all freelist pointers can
> always be used to determine the address of the page struct and we will not
> need the page field anymore in the per cpu are for a slab. Testing for the
> end of the list is a test if the first bit is set.
> 
> So the first patch changes the termination pointer for freelists to do just
> that. The second removes the page field and then third can then remove the
> preempt enable/disable.
> 
> There are currently a number of caveats because we are adding calls to
> page_address() and virt_to_head_page() in a number of code paths. These
> can hopefully be removed one way or the other.
> 
> Removing the ->page field reduces the cache footprint of the fastpath so hopefully overall
> allocator effectiveness will increase further. Also RT uses full preemption which means
> that currently pretty expensive code has to be inserted into the fastpath. This approach
> allows the removal of that code and a corresponding performance increase.
> 

Hello, Christoph.

Preemption disable during very short code would cause large problem for RT?

And, if page_address() and virt_to_head_page() remain as current patchset
implementation, this would work worse than before.

I looked at the patchset quickly and found another idea to remove
preemption disable. How about just retrieving s->cpu_slab->tid first,
before accessing s->cpu_slab, in slab_alloc() and slab_free()?
Retrieved tid may ensure that we aren't migrated to other CPUs so that
we can remove code for preemption disable.

Following is the patch implementing above idea.

Thanks.

------------->8------------------------
diff --git a/mm/slub.c b/mm/slub.c
index ae7b9f1..af622d8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2386,28 +2386,21 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	s = memcg_kmem_get_cache(s, gfpflags);
 redo:
 	/*
+	 * The transaction ids are globally unique per cpu and per operation on
+	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_double
+	 * occurs on the right processor and that there was no operation on the
+	 * linked list in between.
+	 */
+	tid = this_cpu_read(s->cpu_slab->tid);
+
+	/*
 	 * Must read kmem_cache cpu data via this cpu ptr. Preemption is
 	 * enabled. We may switch back and forth between cpus while
 	 * reading from one cpu area. That does not matter as long
 	 * as we end up on the original cpu again when doing the cmpxchg.
-	 *
-	 * Preemption is disabled for the retrieval of the tid because that
-	 * must occur from the current processor. We cannot allow rescheduling
-	 * on a different processor between the determination of the pointer
-	 * and the retrieval of the tid.
 	 */
-	preempt_disable();
 	c = this_cpu_ptr(s->cpu_slab);
 
-	/*
-	 * The transaction ids are globally unique per cpu and per operation on
-	 * a per cpu queue. Thus they can be guarantee that the cmpxchg_double
-	 * occurs on the right processor and that there was no operation on the
-	 * linked list in between.
-	 */
-	tid = c->tid;
-	preempt_enable();
-
 	object = c->freelist;
 	page = c->page;
 	if (unlikely(!object || !node_match(page, node))) {
@@ -2646,18 +2639,16 @@ static __always_inline void slab_free(struct kmem_cache *s,
 	slab_free_hook(s, x);
 
 redo:
+	tid = this_cpu_read(s->cpu_slab->tid);
+
 	/*
 	 * Determine the currently cpus per cpu slab.
 	 * The cpu may change afterward. However that does not matter since
 	 * data is retrieved via this pointer. If we are on the same cpu
 	 * during the cmpxchg then the free will succedd.
 	 */
-	preempt_disable();
 	c = this_cpu_ptr(s->cpu_slab);
 
-	tid = c->tid;
-	preempt_enable();
-
 	if (likely(page == c->page)) {
 		set_freepointer(s, object, c->freelist);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
