Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 12C946B00EA
	for <linux-mm@kvack.org>; Wed, 16 May 2012 10:33:45 -0400 (EDT)
Date: Wed, 16 May 2012 09:33:42 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC] SL[AUO]B common code 8/9] slabs: list addition move to
 slab_common
In-Reply-To: <4FB37CC9.3060102@parallels.com>
Message-ID: <alpine.DEB.2.00.1205160932201.25603@router.home>
References: <20120514201544.334122849@linux.com> <20120514201613.467708800@linux.com> <4FB37CC9.3060102@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

On Wed, 16 May 2012, Glauber Costa wrote:

> > Index: linux-2.6/mm/slab_common.c
> > ===================================================================
> > --- linux-2.6.orig/mm/slab_common.c	2012-05-14 08:39:27.859145830 -0500
> > +++ linux-2.6/mm/slab_common.c	2012-05-14 08:39:29.827145790 -0500
> > @@ -98,6 +98,9 @@ struct kmem_cache *kmem_cache_create(con
> >
> >   	s = __kmem_cache_create(name, size, align, flags, ctor);
> >
> > +	if (s&&  s->refcount == 1)
> > +		list_add(&s->list,&slab_caches);
> > +
> >   oops:
>
> I personally think that the refcount == 1 test is too fragile.
> It happens to be true, and is likely to be true in the future, but there is no
> particular reason that is *has* to be true forever.

Its not fragile since a refcount will always be one for a slab that was
just created. There is no possible other reference to it since the
subsystem using it has never received a pointer to the kmem_cache struct
yet.

> Also, the only reasons it exists, seems to be to go around the fact that the
> slab already adds the kmalloc caches to a list in a slightly different way.
> And there has to be cleaner ways to achieve that.

The reason it exists is to distinguish the case of an alias creation from
a true kmem_cache instatiation. The alias does not need to be added to the
list of slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
