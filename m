Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 573C86B004D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 05:53:41 -0400 (EDT)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n92A5Cgc001024
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 11:05:13 +0100
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by zps38.corp.google.com with ESMTP id n92A5Ac8022799
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 03:05:10 -0700
Received: by pzk31 with SMTP id 31so1033476pzk.26
        for <linux-mm@kvack.org>; Fri, 02 Oct 2009 03:05:10 -0700 (PDT)
Date: Fri, 2 Oct 2009 03:05:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 30/31] Fix use of uninitialized variable in
 cache_grow()
In-Reply-To: <19141.34685.863491.329836@notabene.brown>
Message-ID: <alpine.DEB.1.00.0910020258190.25369@chino.kir.corp.google.com>
References: <1254406257-16735-1-git-send-email-sjayaraman@suse.de> <alpine.DEB.1.00.0910011341280.27559@chino.kir.corp.google.com> <19141.34685.863491.329836@notabene.brown>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Suresh Jayaraman <sjayaraman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>, Wouter Verhelst <w@uter.be>, Peter Zijlstra <a.p.zijlstra@chello.nl>, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009, Neil Brown wrote:

> > > Index: mmotm/mm/slab.c
> > > ===================================================================
> > > --- mmotm.orig/mm/slab.c
> > > +++ mmotm/mm/slab.c
> > > @@ -2760,7 +2760,7 @@ static int cache_grow(struct kmem_cache
> > >  	size_t offset;
> > >  	gfp_t local_flags;
> > >  	struct kmem_list3 *l3;
> > > -	int reserve;
> > > +	int reserve = -1;
> > >  
> > >  	/*
> > >  	 * Be lazy and only check for valid flags here,  keeping it out of the
> > > @@ -2816,7 +2816,8 @@ static int cache_grow(struct kmem_cache
> > >  	if (local_flags & __GFP_WAIT)
> > >  		local_irq_disable();
> > >  	check_irq_off();
> > > -	slab_set_reserve(cachep, reserve);
> > > +	if (reserve != -1)
> > > +		slab_set_reserve(cachep, reserve);
> > >  	spin_lock(&l3->list_lock);
> > >  
> > >  	/* Make slab active. */
> > 
> > Given the patch description, shouldn't this be a test for objp != NULL 
> > instead, then?
> 
> In between those to patch hunks, cache_grow contains the code:
> 	if (!objp)
> 		objp = kmem_getpages(cachep, local_flags, nodeid, &reserve);
> 	if (!objp)
> 		goto failed;
> 
> We can no longer test if objp was NULL on entry to the function.
> We could take a copy of objp on entry to the function, and test it
> here.  But initialising 'reserve' to an invalid value is easier.
> 

Seems like you could do all this in kmem_getpages(), then, by calling 
slab_set_reserve(cachep, page->reserve) before returning the new page?

 [ I'd also drop the branch in slab_set_reserve(), it's faster to just 
   assign it unconditionally. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
