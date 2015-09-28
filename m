Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id ABCBD6B0256
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 11:51:20 -0400 (EDT)
Received: by qgt47 with SMTP id 47so124185594qgt.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:51:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q191si16034146qha.128.2015.09.28.08.51.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 08:51:20 -0700 (PDT)
Date: Mon, 28 Sep 2015 17:51:14 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Message-ID: <20150928175114.07e85114@redhat.com>
In-Reply-To: <alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon>
	<20150928122629.15409.69466.stgit@canyon>
	<alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com

On Mon, 28 Sep 2015 10:16:49 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 1cf98d89546d..13b5f53e4840 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -675,11 +675,18 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
> >  {
> >  	u8 *p = object;
> >
> > +	/* Freepointer not overwritten as SLAB_POISON moved it after object */
> >  	if (s->flags & __OBJECT_POISON) {
> >  		memset(p, POISON_FREE, s->object_size - 1);
> >  		p[s->object_size - 1] = POISON_END;
> >  	}
> >
> > +	/*
> > +	 * If both SLAB_RED_ZONE and SLAB_POISON are enabled, then
> > +	 * freepointer is still safe, as then s->offset equals
> > +	 * s->inuse and below redzone is after s->object_size and only
> > +	 * area between s->object_size and s->inuse.
> > +	 */
> >  	if (s->flags & SLAB_RED_ZONE)
> >  		memset(p + s->object_size, val, s->inuse - s->object_size);
> >  }
> 
> Are these comments really adding something? This is basic metadata
> handling for SLUB that is commented on elsehwere.

Not knowing SLUB as well as you, it took me several hours to realize
init_object() didn't overwrite the freepointer in the object.  Thus, I
think these comments make the reader aware of not-so-obvious
side-effects of SLAB_POISON and SLAB_RED_ZONE.


> > @@ -2584,9 +2646,14 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
> >   * So we still attempt to reduce cache line usage. Just take the slab
> >   * lock and free the item. If there is no additional partial page
> >   * handling required then we can return immediately.
> > + *
> > + * Bulk free of a freelist with several objects (all pointing to the
> > + * same page) possible by specifying freelist_head ptr and object as
> > + * tail ptr, plus objects count (cnt).
> >   */
> >  static void __slab_free(struct kmem_cache *s, struct page *page,
> > -			void *x, unsigned long addr)
> > +			void *x, unsigned long addr,
> > +			void *freelist_head, int cnt)
> 
> Do you really need separate parameters for freelist_head? If you just want
> to deal with one object pass it as freelist_head and set cnt = 1?

Yes, I need it.  We need to know both the head and tail of the list to
splice it.

See:

> @@ -2612,7 +2681,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
                prior = page->freelist;
		counters = page->counters;
>  		set_freepointer(s, object, prior);
                                   ^^^^^^ 
Here we update the tail ptr (object) to point to "prior" (page->freelist).

>  		new.counters = counters;
>  		was_frozen = new.frozen;
> -		new.inuse--;
> +		new.inuse -= cnt;
>  		if ((!new.inuse || !prior) && !was_frozen) {
>  
>  			if (kmem_cache_has_cpu_partial(s) && !prior) {
> @@ -2643,7 +2712,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
>  
>  	} while (!cmpxchg_double_slab(s, page,
>  		prior, counters,
> -		object, new.counters,
> +		new_freelist, new.counters,
>  		"__slab_free"));

Here we update page->freelist ("prior") to point to the head. Thus,
splicing the list.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
