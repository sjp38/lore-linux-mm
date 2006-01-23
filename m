Date: Sun, 22 Jan 2006 22:39:31 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] use 32 bit division in slab_put_obj()
Message-Id: <20060122223931.2500b08e.akpm@osdl.org>
In-Reply-To: <20060121011245.GA24301@linux.intel.com>
References: <20060121011245.GA24301@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise <bcrl@linux.intel.com> wrote:
>
> The patch below improves the performance of slab_put_obj().  Without the 
> cast, gcc considers ptrdiff_t a 64 bit signed integer and ends up emitting 
> code to use a full signed 128 bit divide on EM64T, which is substantially 
> slower than a 32 bit unsigned divide.  I noticed this when looking at the 
> profile of a case where the slab balance is just on edge and thrashes back 
> and forth freeing a block.
> 
> Signed-off-by: Benjamin LaHaise <benjamin.c.lahaise@intel.com>
> diff -X work-2.6.16-rc1-mm2/Documentation/dontdiff -urP /home/bcrl/kernels/v2.6/linux-2.6.16-rc1-mm2/mm/slab.c work-2.6.16-rc1-mm2/mm/slab.c
> --- /home/bcrl/kernels/v2.6/linux-2.6.16-rc1-mm2/mm/slab.c	2006-01-20 15:20:16.000000000 -0500
> +++ work-2.6.16-rc1-mm2/mm/slab.c	2006-01-20 16:41:59.000000000 -0500
> @@ -2267,8 +2267,12 @@
>  static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp, void *objp,
>  			  int nodeid)
>  {
> -	unsigned int objnr = (objp - slabp->s_mem) / cachep->buffer_size;
> +	/* Slabs are always <4GB in size, so use a less expensive division. */
> +	unsigned objnr = (unsigned)(objp - slabp->s_mem) / cachep->buffer_size;
>  
> +#if DEBUG
> +	WARN_ON((unsigned long)(objp - slabp->s_mem) > ~0U);
> +#endif
>  #if 0
>  	/* Verify that the slab belongs to the intended node */
>  	WARN_ON(slabp->nodeid != nodeid);

There were actually three places in slab.c which were doing this, so I
updated all of them and then redid all the other slab patches in the-mm
queue.

diff -puN mm/slab.c~use-32-bit-division-in-slab_put_obj mm/slab.c
--- devel/mm/slab.c~use-32-bit-division-in-slab_put_obj	2006-01-22 22:34:48.000000000 -0800
+++ devel-akpm/mm/slab.c	2006-01-22 22:38:19.000000000 -0800
@@ -1398,7 +1398,7 @@ static void check_poison_obj(kmem_cache_
 		struct slab *slabp = page_get_slab(virt_to_page(objp));
 		int objnr;
 
-		objnr = (objp - slabp->s_mem) / cachep->objsize;
+		objnr = (unsigned)(objp - slabp->s_mem) / cachep->objsize;
 		if (objnr) {
 			objp = slabp->s_mem + (objnr - 1) * cachep->objsize;
 			realobj = (char *)objp + obj_dbghead(cachep);
@@ -2341,7 +2341,7 @@ static void *cache_free_debugcheck(kmem_
 	if (cachep->flags & SLAB_STORE_USER)
 		*dbg_userword(cachep, objp) = caller;
 
-	objnr = (objp - slabp->s_mem) / cachep->objsize;
+	objnr = (unsigned)(objp - slabp->s_mem) / cachep->objsize;
 
 	BUG_ON(objnr >= cachep->num);
 	BUG_ON(objp != slabp->s_mem + objnr * cachep->objsize);
@@ -2699,7 +2699,7 @@ static void free_block(kmem_cache_t *cac
 		slabp = page_get_slab(virt_to_page(objp));
 		l3 = cachep->nodelists[node];
 		list_del(&slabp->list);
-		objnr = (objp - slabp->s_mem) / cachep->objsize;
+		objnr = (unsigned)(objp - slabp->s_mem) / cachep->objsize;
 		check_spinlock_acquired_node(cachep, node);
 		check_slabp(cachep, slabp);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
