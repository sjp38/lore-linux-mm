Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id A5ADC6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:24:10 -0400 (EDT)
Received: by qged89 with SMTP id d89so12254432qge.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:24:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g125si3434664qhc.41.2015.06.16.23.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 23:24:09 -0700 (PDT)
Date: Wed, 17 Jun 2015 08:24:03 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/7] slub bulk alloc: extract objects from the per cpu
 slab
Message-ID: <20150617082403.65d9cf5a@redhat.com>
In-Reply-To: <20150616144840.1b669e149d937365a4b54c1c@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155207.18824.8674.stgit@devil>
	<20150616144840.1b669e149d937365a4b54c1c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com

On Tue, 16 Jun 2015 14:48:40 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Jun 2015 17:52:07 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > From: Christoph Lameter <cl@linux.com>
> > 
> > [NOTICE: Already in AKPM's quilt-queue]
> > 
> > First piece: acceleration of retrieval of per cpu objects
> > 
> > If we are allocating lots of objects then it is advantageous to disable
> > interrupts and avoid the this_cpu_cmpxchg() operation to get these objects
> > faster.
> > 
> > Note that we cannot do the fast operation if debugging is enabled, because
> > we would have to add extra code to do all the debugging checks.  And it
> > would not be fast anyway.
> > 
> > Note also that the requirement of having interrupts disabled
> > avoids having to do processor flag operations.
> > 
> > Allocate as many objects as possible in the fast way and then fall back to
> > the generic implementation for the rest of the objects.
> > 
> > ...
> >
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2759,7 +2759,32 @@ EXPORT_SYMBOL(kmem_cache_free_bulk);
> >  bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> >  								void **p)
> >  {
> > -	return kmem_cache_alloc_bulk(s, flags, size, p);
> > +	if (!kmem_cache_debug(s)) {
> > +		struct kmem_cache_cpu *c;
> > +
> > +		/* Drain objects in the per cpu slab */
> > +		local_irq_disable();
> > +		c = this_cpu_ptr(s->cpu_slab);
> > +
> > +		while (size) {
> > +			void *object = c->freelist;
> > +
> > +			if (!object)
> > +				break;
> > +
> > +			c->freelist = get_freepointer(s, object);
> > +			*p++ = object;
> > +			size--;
> > +
> > +			if (unlikely(flags & __GFP_ZERO))
> > +				memset(object, 0, s->object_size);
> > +		}
> > +		c->tid = next_tid(c->tid);
> > +
> > +		local_irq_enable();
> 
> It might be worth adding
> 
> 		if (!size)
> 			return true;
> 
> here.  To avoid the pointless call to __kmem_cache_alloc_bulk().

The pointless call did present a measurable performance hit (2ns), and
I've removed it in the next patches, which fixes the error/exit path.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
