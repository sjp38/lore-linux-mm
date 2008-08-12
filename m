Received: from edge01.upc.biz ([192.168.13.236]) by viefep15-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080812081056.UZEK27596.viefep15-int.chello.at@edge01.upc.biz>
          for <linux-mm@kvack.org>; Tue, 12 Aug 2008 10:10:56 +0200
Subject: Re: [PATCH 12/30] mm: memory reserve management
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18593.11340.609526.649904@notabene.brown>
References: <20080724140042.408642539@chello.nl>
	 <20080724141530.127530749@chello.nl>
	 <18593.11340.609526.649904@notabene.brown>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 10:10:58 +0200
Message-Id: <1218528658.10800.173.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 16:23 +1000, Neil Brown wrote:
> On Thursday July 24, a.p.zijlstra@chello.nl wrote:
> > Generic reserve management code. 
> > 
> > It provides methods to reserve and charge. Upon this, generic alloc/free style
> > reserve pools could be build, which could fully replace mempool_t
> > functionality.
> 
> This looks quite different to last time I looked at the code (I
> think).
> 
> You now have a more structured "kmalloc_reserve" interface which
> returns a flag to say if the allocation was from an emergency pool.  I
> think this will be a distinct improvement at the call sites, though I
> haven't looked at them yet. :-)
> 
> > +
> > +struct mem_reserve {
> > +	struct mem_reserve *parent;
> > +	struct list_head children;
> > +	struct list_head siblings;
> > +
> > +	const char *name;
> > +
> > +	long pages;
> > +	long limit;
> > +	long usage;
> > +	spinlock_t lock;	/* protects limit and usage */
>                                             ^^^^^
> > +
> > +	wait_queue_head_t waitqueue;
> > +};
> 
> .....
> > +static void __calc_reserve(struct mem_reserve *res, long pages, long limit)
> > +{
> > +	unsigned long flags;
> > +
> > +	for ( ; res; res = res->parent) {
> > +		res->pages += pages;
> > +
> > +		if (limit) {
> > +			spin_lock_irqsave(&res->lock, flags);
> > +			res->limit += limit;
> > +			spin_unlock_irqrestore(&res->lock, flags);
> > +		}
> > +	}
> > +}
> 
> I cannot figure out why the spinlock is being used to protect updates
> to 'limit'.
> As far as I can see, mem_reserve_mutex already protects all those
> updates.
> Certainly we need the spinlock for usage, but why for limit??

against __mem_reserve_charge(), granted, the race would be minimal at
best - but it seemed better this way.

> > +
> > +void *___kmalloc_reserve(size_t size, gfp_t flags, int node, void *ip,
> > +			 struct mem_reserve *res, int *emerg)
> > +{
> .....
> > +	if (emerg)
> > +		*emerg |= 1;
> 
> Why not just
> 
> 	if (emerg)
> 		*emerg = 1.
> 
> I can't we where '*emerg' can have any value but 0 or 1, so the '|' is
> pointless ???

weirdness in my brain when I wrote that I guess, shall ammend!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
