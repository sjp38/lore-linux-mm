Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 055DE6B0081
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:49:00 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so1533945pdj.24
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:49:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id iu4si2527242pbc.430.2014.05.07.14.48.59
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 14:49:00 -0700 (PDT)
Date: Wed, 7 May 2014 14:48:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, slab: suppress out of memory warning unless debug
 is enabled
Message-Id: <20140507144858.9aee4e420908ccf9334dfdf2@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405071431580.8454@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com>
	<20140507142925.b0e31514d4cd8d5857b10850@linux-foundation.org>
	<alpine.DEB.2.02.1405071431580.8454@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014 14:36:34 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> On Wed, 7 May 2014, Andrew Morton wrote:
> 
> > > When the slab or slub allocators cannot allocate additional slab pages, they 
> > > emit diagnostic information to the kernel log such as current number of slabs, 
> > > number of objects, active objects, etc.  This is always coupled with a page 
> > > allocation failure warning since it is controlled by !__GFP_NOWARN.
> > > 
> > > Suppress this out of memory warning if the allocator is configured without debug 
> > > supported.  The page allocation failure warning will indicate it is a failed 
> > > slab allocation, so this is only useful to diagnose allocator bugs.
> > > 
> > > Since CONFIG_SLUB_DEBUG is already enabled by default for the slub allocator, 
> > > there is no functional change with this patch.  If debug is disabled, however, 
> > > the warnings are now suppressed.
> > > 
> > 
> > I'm not seeing any reason for making this change.
> > 
> 
> You think the spam in http://marc.info/?l=linux-kernel&m=139927773010514 
> is meaningful?  It also looks like two different errors when in reality it 
> is a single allocation.
> 
> Unless you're debugging a slab issue, all the pertinent information is 
> already available in the page allocation failure warning emitted by the 
> page allocator: we already have the order and gfp mask.  We also know it's 
> a slab allocation because of the __kmalloc in the call trace.
> 
> Does this user care about that there are 207 slabs on node 0 with 207 
> objects?  Probably only if they are diagnosing a slab problem.

I'd prefer something which can be added to the changelog to address
this omission over a series of rhetorical questions.

> > > @@ -1621,11 +1621,17 @@ __initcall(cpucache_init);
> > >  static noinline void
> > >  slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
> > >  {
> > > +#if DEBUG
> > >  	struct kmem_cache_node *n;
> > >  	struct page *page;
> > >  	unsigned long flags;
> > >  	int node;
> > >  
> > > +	if (gfpflags & __GFP_NOWARN)
> > > +		return;
> > > +	if (!printk_ratelimit())
> > > +		return;
> > 
> > printk_ratelimit() is lame - it uses a single global state.  So if
> > random net driver is using printk_ratelimit(), that driver and slab
> > will interfere with each other.
> > 
> 
> Agreed, but it is a testiment to the uselessness of this information 
> already.  The page allocation failure warnings are controlled by their own 
> ratelimiter, nopage_rs, but that's local to the page allocator.  Do you 
> prefer that all these ratelimiters be moved to the global namespace for 
> generic use?

As these messages are related then it probably makes sense for them to
use a common ratelimit_state, hopefully local to slab.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
