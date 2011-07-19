Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B3F7E6B004A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 02:53:32 -0400 (EDT)
Received: by eyg7 with SMTP id 7so3160158eyg.41
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 23:53:29 -0700 (PDT)
Date: Tue, 19 Jul 2011 10:53:22 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC v2] implement SL*B and stack usercopy runtime checks
Message-ID: <20110719065322.GA3228@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110718183951.GA3748@albatros>
 <alpine.DEB.2.00.1107181610350.31576@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1107181610350.31576@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 18, 2011 at 16:18 -0500, Christoph Lameter wrote:
> On Mon, 18 Jul 2011, Vasiliy Kulikov wrote:
> 
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -3844,6 +3844,40 @@ unsigned int kmem_cache_size(struct kmem_cache *cachep)
> >  EXPORT_SYMBOL(kmem_cache_size);
> >
> >  /*
> > + * Returns false if and only if [ptr; ptr+len) touches the slab,
> > + * but breaks objects boundaries.  It doesn't check whether the
> > + * accessed object is actually allocated.
> > + */
> > +bool slab_access_ok(const void *ptr, unsigned long len)
> > +{
> > +	struct page *page;
> > +	struct kmem_cache *cachep = NULL;
> 
> Why = NULL?

Indeed, redundant.

> > +	struct slab *slabp;
> > +	unsigned int objnr;
> > +	unsigned long offset;
> > +
> > +	if (!len)
> > +		return true;
> > +	if (!virt_addr_valid(ptr))
> > +		return true;
> > +	page = virt_to_head_page(ptr);
> > +	if (!PageSlab(page))
> > +		return true;
> > +
> > +	cachep = page_get_cache(page);
> > +	slabp = page_get_slab(page);
> > +	objnr = obj_to_index(cachep, slabp, (void *)ptr);
> > +	BUG_ON(objnr >= cachep->num);
> > +	offset = (const char *)ptr - obj_offset(cachep) -
> > +	    (const char *)index_to_obj(cachep, slabp, objnr);
> > +	if (offset <= obj_size(cachep) && len <= obj_size(cachep) - offset)
> > +		return true;
> > +
> > +	return false;
> > +}
> > +EXPORT_SYMBOL(slab_access_ok);
> > +
> > +/*
> >   * This initializes kmem_list3 or resizes various caches for all nodes.
> >   */
> >  static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
> 
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2623,6 +2623,34 @@ unsigned int kmem_cache_size(struct kmem_cache *s)
> >  }
> >  EXPORT_SYMBOL(kmem_cache_size);
> >
> > +/*
> > + * Returns false if and only if [ptr; ptr+len) touches the slab,
> > + * but breaks objects boundaries.  It doesn't check whether the
> > + * accessed object is actually allocated.
> > + */
> > +bool slab_access_ok(const void *ptr, unsigned long len)
> > +{
> > +	struct page *page;
> > +	struct kmem_cache *s = NULL;
> 
> No need to assign NULL.

Ditto.

> > +	unsigned long offset;
> > +
> > +	if (len == 0)
> > +		return true;
> > +	if (!virt_addr_valid(ptr))
> > +		return true;
> > +	page = virt_to_head_page(ptr);
> > +	if (!PageSlab(page))
> > +		return true;
> > +
> > +	s = page->slab;
> > +	offset = ((const char *)ptr - (const char *)page_address(page)) % s->size;
> 
> Are the casts necessary? Both are pointers to void *

Is it normal kernel style to use void* pointer arithmetic?

> > +	if (offset <= s->objsize && len <= s->objsize - offset)
> 
> If offset == s->objsize then we access the first byte after the object.

Well, then objsize - offset == 0 and len can be 0 only to pass the right
part of && check.  But (len == 0) case is already handled above.

But yes, for better readability it should be "<".


Thank you,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
