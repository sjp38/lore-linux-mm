Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l7G003Dw284932
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 00:00:03 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7G003PM2396188
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 01:00:03 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7FNxuGK015189
	for <linux-mm@kvack.org>; Thu, 16 Aug 2007 00:59:57 +0100
Date: Thu, 16 Aug 2007 01:59:56 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] dm: Fix deadlock under high i/o load in raid1 setup.
Message-ID: <20070815235956.GD8741@osiris.ibm.com>
References: <20070813113340.GB30198@osiris.boeblingen.de.ibm.com> <20070815155604.87318305.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070815155604.87318305.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, Daniel Kobras <kobras@linux.de>, Alasdair G Kergon <agk@redhat.com>, Stefan Weinhuber <wein@de.ibm.com>, Stefan Bader <shbader@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 15, 2007 at 03:56:04PM -0700, Andrew Morton wrote:
> On Mon, 13 Aug 2007 13:33:40 +0200
> Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> > the patch below went into 2.6.18. Now my question is: why doesn't it check
> > if kmalloc(..., GFP_NOIO) returns with a NULL pointer?
> > Did I miss anything that guarentees that this will always succeed or is it
> > just a bug?
> > --- a/drivers/md/dm-raid1.c
> > +++ b/drivers/md/dm-raid1.c
> > @@ -255,7 +255,9 @@ static struct region *__rh_alloc(struct region_hash *rh, region_t region)
> >  	struct region *reg, *nreg;
> >  
> >  	read_unlock(&rh->hash_lock);
> > -	nreg = mempool_alloc(rh->region_pool, GFP_NOIO);
> > +	nreg = mempool_alloc(rh->region_pool, GFP_ATOMIC);
> > +	if (unlikely(!nreg))
> > +		nreg = kmalloc(sizeof(struct region), GFP_NOIO);
> >  	nreg->state = rh->log->type->in_sync(rh->log, region, 1) ?
> >  		RH_CLEAN : RH_NOSYNC;
> >  	nreg->rh = rh;
> > 
> 
> Yeah, that's a bug.
> 
> kmalloc(small_amount, GFP_NOIO) can fail if the calling process gets
> oom-killed, and it can fail if the system is using fault-injection.
> 
> One could say "don't use fault injection" and, perhaps, "this is only
> ever called by a kernel thread and kernel threads don't get oom-killed". 
> But the former is lame and the latter assumes current implementation
> details which could change (and indeed have in the past).

Thanks for clarifying!

> So yes, I'd say this is a bug in DM.
> 
> Also, __rh_alloc() is called under read_lock(), via __rh_find().  If
> __rh_alloc()'s mempool_alloc() fails, it will perform a sleeping allocation
> under read_lock(), which is deadlockable and will generate might_sleep()
> warnings

The read_lock() is unlocked at the beginning of the function. Unless
you're talking of a different lock, but I couldn't find any.

So at least _currently_ this should work unless somebody uses fault
injection. Would it make sense then to add the __GFP_NOFAIL flag to
the kmalloc call?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
