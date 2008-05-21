Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
	ksize().
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <48343884.7060708@cs.helsinki.fi>
References: <20080520095935.GB18633@linux-sh.org>
	 <48343884.7060708@cs.helsinki.fi>
Content-Type: text/plain
Date: Wed, 21 May 2008 10:06:07 -0500
Message-Id: <1211382367.18026.239.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-21 at 17:58 +0300, Pekka Enberg wrote:
> (Not really sure if we came to a conclusion with the discussion.)
> 
> Paul Mundt wrote:
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index ef8c62c..3e11814 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -112,13 +112,7 @@ unsigned int kobjsize(const void *objp)
> >  	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
> >  		return 0;
> >  
> > -	if (PageSlab(page))
> > -		return ksize(objp);
> > -
> > -	BUG_ON(page->index < 0);
> > -	BUG_ON(page->index >= MAX_ORDER);
> > -
> > -	return (PAGE_SIZE << page->index);
> > +	return ksize(objp);
> >  }
> >  
> >  /*
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 06236e4..7a012bb 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -4472,10 +4472,16 @@ const struct seq_operations slabstats_op = {
> >   */
> >  size_t ksize(const void *objp)
> >  {
> > +	struct page *page;
> > +
> >  	BUG_ON(!objp);
> >  	if (unlikely(objp == ZERO_SIZE_PTR))
> >  		return 0;
> >  
> > +	page = virt_to_head_page(objp);
> > +	if (unlikely(!PageSlab(page)))
> > +		return PAGE_SIZE << compound_order(page);
> > +
> >  	return obj_size(virt_to_cache(objp));
> >  }
> >  EXPORT_SYMBOL(ksize);
> 
> The patch looks good to me. Christoph, Matt, NAK/ACK?

I did ack this, as I think it's a step in the right direction and it
will get nommu running. But I do think nommu's ksize() usage needs a
major rework.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
