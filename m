Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 094356B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 00:47:32 -0400 (EDT)
From: Neil Brown <neilb@suse.de>
Date: Fri, 2 Oct 2009 14:54:21 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <19141.34685.863491.329836@notabene.brown>
Subject: Re: [PATCH 30/31] Fix use of uninitialized variable in
 cache_grow()
In-Reply-To: message from David Rientjes on Thursday October 1
References: <1254406257-16735-1-git-send-email-sjayaraman@suse.de>
	<alpine.DEB.1.00.0910011341280.27559@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Thursday October 1, rientjes@google.com wrote:
> On Thu, 1 Oct 2009, Suresh Jayaraman wrote:
> 
> > From: Miklos Szeredi <mszeredi@suse.cz>
> > 
> > This fixes a bug in reserve-slub.patch.
> > 
> > If cache_grow() was called with objp != NULL then the 'reserve' local
> > variable wasn't initialized. This resulted in ac->reserve being set to
> > a rubbish value.  Due to this in some circumstances huge amounts of
> > slab pages were allocated (due to slab_force_alloc() returning true),
> > which caused atomic page allocation failures and slowdown of the
> > system.
> > 
> > Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> > Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> > ---
> >  mm/slab.c |    5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > Index: mmotm/mm/slab.c
> > ===================================================================
> > --- mmotm.orig/mm/slab.c
> > +++ mmotm/mm/slab.c
> > @@ -2760,7 +2760,7 @@ static int cache_grow(struct kmem_cache
> >  	size_t offset;
> >  	gfp_t local_flags;
> >  	struct kmem_list3 *l3;
> > -	int reserve;
> > +	int reserve = -1;
> >  
> >  	/*
> >  	 * Be lazy and only check for valid flags here,  keeping it out of the
> > @@ -2816,7 +2816,8 @@ static int cache_grow(struct kmem_cache
> >  	if (local_flags & __GFP_WAIT)
> >  		local_irq_disable();
> >  	check_irq_off();
> > -	slab_set_reserve(cachep, reserve);
> > +	if (reserve != -1)
> > +		slab_set_reserve(cachep, reserve);
> >  	spin_lock(&l3->list_lock);
> >  
> >  	/* Make slab active. */
> 
> Given the patch description, shouldn't this be a test for objp != NULL 
> instead, then?

In between those to patch hunks, cache_grow contains the code:
	if (!objp)
		objp = kmem_getpages(cachep, local_flags, nodeid, &reserve);
	if (!objp)
		goto failed;

We can no longer test if objp was NULL on entry to the function.
We could take a copy of objp on entry to the function, and test it
here.  But initialising 'reserve' to an invalid value is easier.



> 
> If so, it doesn't make sense because reserve will only be initialized when 
> objp == NULL in the call to kmem_getpages() from cache_grow().
> 
> 
> The title of the patch suggests this is just dealing with an uninitialized 
> auto variable so the anticipated change would be from "int reserve" to 
> "int uninitialized_var(result)".

That change is only appropriate when the compiler is issuing a
warning that the variable is used before it is initialised, but we
know that not to be the case.
In this situation, we know it *is* being used before it is
initialised, and so we need to initialise it to something.

Thanks,
NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
