Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43CBD6B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 01:55:52 -0400 (EDT)
Subject: Re: [PATCH] mm: Make it easier to catch NULL cache names
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090728170632.2d136ce6.akpm@linux-foundation.org>
References: <1248754289.30993.45.camel@pasglop>
	 <20090728170632.2d136ce6.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 29 Jul 2009 15:55:46 +1000
Message-Id: <1248846946.17395.59.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-07-28 at 17:06 -0700, Andrew Morton wrote:
> On Tue, 28 Jul 2009 14:11:29 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > Right now, if you inadvertently pass NULL to kmem_cache_create() at boot
> > time, it crashes much later after boot somewhere deep inside sysfs which
> > makes it very non obvious to figure out what's going on.
> 
> That must have been a pretty dumb piece of kernel code.  It's a bit
> questionable (IMO) whether we need to cater for really exceptional
> bugs.  But whatever.

 :-)

It was an array of caches created from something like an enum and the
array of names got out of sync :-)

> slab used to have a check (__get_user) to see whether the ->name field
> was still readable.  This was to detect the case where the slab cache
> was created from a kernel module and the module forgot to remove the
> cache at rmmod-time.  Subsequent reads of /proc/slabinfo would
> confusingly go splat.  The check seems to have been removed (from
> slab.c, at least).  If it is still there then it should be applied
> consistently and across all slab versions.  In which case that check
> would make your patch arguably-unneeded.  But it seems to have got
> itself zapped.

That sounds like a better idea. However, it looks like we create sysfs
things and pass that pointer down to sysfs nowadays, so that's going to
blow up somewhere in the guts of sysfs unless we duplicate the string.

The advantage of duplicating the string would also be that we could
blow up right away if it's NULL :-)

Cheers,
Ben.

> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> > ---
> > 
> > Yes, I did hit that :-) Something in ppc land using an array of caches
> > and got the names array out of sync with changes to the list of indices.
> > 
> >  mm/slub.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index b9f1491..e31fbe6 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -3292,6 +3292,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> >  {
> >  	struct kmem_cache *s;
> >  
> > +	if (WARN_ON(!name))
> > +		return NULL;
> > +
> >  	down_write(&slub_lock);
> >  	s = find_mergeable(size, align, flags, name, ctor);
> >  	if (s) {
> 
> Let's see:
> 
> slab.c: goes BUG
> slob.c: will apparently go oops at some later time
> slqb.c: does dump_stack(), returns NULL from kmem_cache_create()
> slub.c: does WARN(), returns NULL from kmem_cache_create()
> 
> 
> I think I'll apply the patch, cc Pekka then run away.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
