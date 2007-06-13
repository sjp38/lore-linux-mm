Date: Wed, 13 Jun 2007 15:47:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
In-Reply-To: <20070613131549.GZ11115@waste.org>
Message-ID: <Pine.LNX.4.64.0706131546380.32399@schroedinger.engr.sgi.com>
References: <20070613031203.GB15009@linux-sh.org> <20070613032857.GN11115@waste.org>
 <20070613092109.GA16526@linux-sh.org> <20070613131549.GZ11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Paul Mundt <lethal@linux-sh.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Matt Mackall wrote:

> On Wed, Jun 13, 2007 at 06:21:09PM +0900, Paul Mundt wrote:
> > Here's an updated copy with the node variants always defined.
> > 
> > I've left the nid=-1 case in as the default for the non-node variants, as
> > this is the approach also used by SLUB. alloc_pages() is special cased
> > for NUMA, and takes the memory policy under advisement when doing the
> > allocation, so the page ends up in a reasonable place.
> > 
> 
> > +void *__kmalloc(size_t size, gfp_t gfp)
> > +{
> > +	return __kmalloc_node(size, gfp, -1);
> > +}
> >  EXPORT_SYMBOL(__kmalloc);
> 
> > +void *kmem_cache_alloc(struct kmem_cache *c, gfp_t flags)
> > +{
> > +	return kmem_cache_alloc_node(c, flags, -1);
> > +}
> >  EXPORT_SYMBOL(kmem_cache_alloc);
> 
> Now promote these guys to inlines in slab.h. At which point all the
> new NUMA code become a no-op on !NUMA.

The fallback code already exists in kmalloc.h for SLAB/SLUB. You just need 
to enable the #ifdefs for SLOB.

Fallback is for kmem_cache_alloc_node to kmem_cache_alloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
