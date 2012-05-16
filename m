Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E91B86B0092
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:31:06 -0400 (EDT)
Date: Wed, 16 May 2012 09:31:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 5/9] slabs: Common definition for
 boot state of the slab allocators
In-Reply-To: <4FB36318.30600@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160928490.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201611.710540961@linux.com> <4FB36318.30600@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> > Index: linux-2.6/mm/slab.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slab.c	2012-05-11 09:43:33.160436947 -0500
> > +++ linux-2.6/mm/slab.c	2012-05-11 09:43:53.448436526 -0500
> > @@ -87,6 +87,7 @@
> >    */
> >
> >   #include	<linux/slab.h>
> > +#include	"slab.h"
>
> Why do we need a separate file for that?
> I know some people do prefer it... I am not being one of them, just feel
> forced to ask =)

These are local definitons only relevant for slab allocators using the
common slab code.

> >   static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t
> > gfp)
> >   {
> > -	if (g_cpucache_up == FULL)
> > +	if (slab_state == FULL)
> >   		return enable_cpucache(cachep, gfp);
> >
> > -	if (g_cpucache_up == NONE) {
> > +	if (slab_state == DOWN) {
>
> Can we avoid doing == tests here?

We could.

> There are a couple of places where that test seems to be okay (I remember 1 in
> the slub), but at least for the "FULL" test here, we should be testing >=
> FULL.
>
> Also, I don't like the name FULL too much, since I do intend to add a new one
> soon (MEMCG, as you can see in my series)

Ok. Why would memcg need an additional state?

> Since we are using slab-specific states like PARTIAL_L3 here, maybe we can use
> slub's like SYSFS here with no problem.

Sure. I thought there would only be special states before UP.

> If we stick to >= and <= whenever needed, that should reflect a lot better
> what the algorithm is really doing

How so?

> > Index: linux-2.6/include/linux/slab.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/slab.h	2012-05-11 09:43:33.164436947
> > -0500
> > +++ linux-2.6/include/linux/slab.h	2012-05-11 09:43:53.448436526 -0500
> > @@ -117,10 +117,6 @@ int kmem_cache_shrink(struct kmem_cache
> >   void kmem_cache_free(struct kmem_cache *, void *);
> >   unsigned int kmem_cache_size(struct kmem_cache *);
> >
> > -/* Slab internal function */
> > -struct kmem_cache *__kmem_cache_create(const char *, size_t, size_t,
> > -			unsigned long,
> > -			void (*)(void *));
> >   /*
> >    * Please use this macro to create slab caches. Simply specify the
> >    * name of the structure and maybe some flags that are listed above.
> >
>
> Should be in an earlier patch...

Yup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
