Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id C1AF76B0070
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 10:18:35 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:18:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [08/20] Extract common code for kmem_cache_create()
In-Reply-To: <4FD99D9B.6060000@parallels.com>
Message-ID: <alpine.DEB.2.00.1206140912250.32075@router.home>
References: <20120613152451.465596612@linux.com> <20120613152519.255119144@linux.com> <4FD99D9B.6060000@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 14 Jun 2012, Glauber Costa wrote:

> On 06/13/2012 07:24 PM, Christoph Lameter wrote:
> > +struct kmem_cache *kmem_cache_create(const char *name, size_t size, size_t
> > align,
> > +		unsigned long flags, void (*ctor)(void *))
> > +{
> > +	struct kmem_cache *s = NULL;
> > +
> > +#ifdef CONFIG_DEBUG_VM
> > +	if (!name || in_interrupt() || size<  sizeof(void *) ||
> > +		size>  KMALLOC_MAX_SIZE) {
> > +		printk(KERN_ERR "kmem_cache_create(%s) integrity check"
> > +			" failed\n", name);
> > +		goto out;
> > +	}
> > +#endif
>
> Not really a BUG, but label out is not used if !CONFIG_DEBUG_VM. Suggest
> testing for the slab panic flag here, and panicing if we need to.

Hmmm.. That is quite sensitive. A change here will cause later patches in
the series to have issues. Maybe its best to put an #ifdef around the
label until a later patch that makes use of out: from code that is not
#ifdefed.


Subject: Add #ifdef to avoid warning about unused label

out: is only used if CONFIG_DEBUG_VM is enabled.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux-2.6/mm/slab_common.c
===================================================================
--- linux-2.6.orig/mm/slab_common.c	2012-06-14 03:16:06.778702087 -0500
+++ linux-2.6/mm/slab_common.c	2012-06-14 03:16:01.054702201 -0500
@@ -57,7 +57,9 @@ struct kmem_cache *kmem_cache_create(con

 	s = __kmem_cache_create(name, size, align, flags, ctor);

+#ifdef CONFIG_DEBUG_VM
 out:
+#endif
 	if (!s && (flags & SLAB_PANIC))
 		panic("kmem_cache_create: Failed to create slab '%s'\n", name);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
