Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C61EF6B0466
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 14:00:27 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id c13so86666061lfg.4
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 11:00:27 -0800 (PST)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id v8si19661947lfa.125.2016.12.23.11.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 11:00:26 -0800 (PST)
Received: by mail-lf0-x242.google.com with SMTP id d16so7966661lfb.1
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 11:00:26 -0800 (PST)
Date: Fri, 23 Dec 2016 20:00:23 +0100
From: Grygorii Maistrenko <grygoriimkd@gmail.com>
Subject: Re: [PATCH] slub: do not merge cache if slub_debug contains a
 never-merge flag
Message-ID: <20161223190023.GA9644@lp-laptop-d>
References: <20161222235959.GC6871@lp-laptop-d>
 <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Dec 23, 2016 at 12:30:02PM -0600, Christoph Lameter wrote:
> 
> On Fri, 23 Dec 2016, Grygorii Maistrenko wrote:
> 
> > In case CONFIG_SLUB_DEBUG_ON=n find_mergeable() gets debug features
> > from commandline but never checks if there are features from the
> > SLAB_NEVER_MERGE set.
> > As a result selected by slub_debug caches are always mergeable if they
> > have been created without a custom constructor set or without one of the
> > SLAB_* debug features on.
> 
> WTF is this nonsense? That check is done a few lines earlier!
> 
> struct kmem_cache *ind_mergeable(size_t size, size_t align,
>                 unsigned long flags, const char *name, void (*ctor)(void *))
> {
>         struct kmem_cache *s;
> 
>         if (slab_nomerge || (flags & SLAB_NEVER_MERGE))    <----- !!!!!!
>                 return NULL;

This one check is done on flags passed to kmem_cache_create().

> 
>         if (ctor)
>                 return NULL;
> 
>         size = ALIGN(size, sizeof(void *));
>         align = calculate_alignment(flags,
	flags = kmem_cache_flags(size, flags, name, NULL);

I added here the missing line. This updates flags from commandline and
after this we do not check it.

> 
> 
> >
> > This adds the necessary check and makes selected slab caches unmergeable
> > if one of the SLAB_NEVER_MERGE features is set from commandline.
> >
> > Signed-off-by: Grygorii Maistrenko <grygoriimkd@gmail.com>
> > ---
> >  mm/slab_common.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index 329b03843863..7341cba8c58b 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -266,6 +266,9 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
> >  	size = ALIGN(size, align);
> >  	flags = kmem_cache_flags(size, flags, name, NULL);
> >
> > +	if (flags & SLAB_NEVER_MERGE)
> > +		return NULL;
> > +
> >  	list_for_each_entry_reverse(s, &slab_caches, list) {
> >  		if (slab_unmergeable(s))
> >  			continue;
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
