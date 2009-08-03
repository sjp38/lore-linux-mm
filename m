Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 558326B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 16:15:44 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:37:55 -0700 (PDT)
From: Sage Weil <sage@newdream.net>
Subject: Re: [PATCH] mempool: launder reused items from kzalloc pool
In-Reply-To: <20090803132011.5a84bc8a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0908031330460.7580@cobra.newdream.net>
References: <1248813967-27448-1-git-send-email-sage@newdream.net>
 <20090803132011.5a84bc8a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, neilb@suse.de, linux-raid@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, Matthew Dobson <colpatch@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Aug 2009, Andrew Morton wrote:

> On Tue, 28 Jul 2009 13:46:07 -0700
> Sage Weil <sage@newdream.net> wrote:
> 
> > The kzalloc pool created by mempool_create_kzalloc_pool() only zeros items
> > the first time they are allocated; it doesn't re-zero freed items that are
> > returned to the pool.  This only comes up when the pool is used in the
> > first place (when memory is very low).
> > 
> > Fix this by adding a mempool_launder_t method that is called before
> > returning items to the pool, and set it in mempool_create_kzalloc_pool.
> > This preserves the use of __GFP_ZERO in the common case where the pool
> > isn't touched at all.
> > 
> > There are currently two in-tree users of mempool_create_kzalloc_pool:
> > 	drivers/md/multipath.c
> > 	drivers/scsi/ibmvscsi/ibmvfc.c
> > The first appears to be affected by this bug.  The second manually zeros
> > each allocation, and can stop doing so after this is fixed.
> > 
> > Alternatively, mempool_create_kzalloc_pool() could be removed entirely and
> > the callers could zero allocations themselves.
> 
> I must say that it does all seem a bit too fancy.  Removal of that code
> and changing the callers to zero the memory seems a nice and simple fix
> to me.

Yep.

> > diff --git a/include/linux/mempool.h b/include/linux/mempool.h
> > index 9be484d..889c7e1 100644
> > --- a/include/linux/mempool.h
> > +++ b/include/linux/mempool.h
> > @@ -10,6 +10,7 @@ struct kmem_cache;
> >  
> >  typedef void * (mempool_alloc_t)(gfp_t gfp_mask, void *pool_data);
> >  typedef void (mempool_free_t)(void *element, void *pool_data);
> > +typedef void (mempool_launder_t)(void *element, void *pool_data);
> >  
> >  typedef struct mempool_s {
> >  	spinlock_t lock;
> > @@ -20,6 +21,7 @@ typedef struct mempool_s {
> >  	void *pool_data;
> >  	mempool_alloc_t *alloc;
> >  	mempool_free_t *free;
> > +	mempool_launder_t *launder;
> >  	wait_queue_head_t wait;
> >  } mempool_t;
> 
> Yes, but we've added larger data structures and expensive indirect calls.
> 
> Also, the code now zeroes the memory at deallocation time.  Slab used
> to do this but we ended up deciding it was a bad thing from a cache
> hotness POV and that it is better to zero the memory immediately before
> the caller starts to use it.

I considered that, but there's no simple way to get GFP_ZERO on new 
allocations and memset on reuse without more weirdness.

> So my vote would be to zap all that stuff.  We could perhaps do
> 
> static void *mempool_zalloc(mempool_t *pool, gfp_t gfp_mask, size_t size)
> {
> 	void *ret = mempool_alloc(pool, gfp_mask);
> 
> 	if (ret)
> 		memset(ret, 0, size);
> 	return ret;
> }
> 
> but it's unobvious that even this is worth doing.

Yeah.

I'll just send patches to clean up/fix those two callers and remove the 
kzalloc pool; that's just simpler.

sage

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
