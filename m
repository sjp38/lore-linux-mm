Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 135EB6B032C
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 22:15:02 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id a12so172932pll.21
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 19:15:02 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id n18si1196220pfh.268.2017.12.05.19.14.59
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 19:15:00 -0800 (PST)
Date: Wed, 6 Dec 2017 14:14:56 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171206031456.GE4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206020208.GK26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 06:02:08PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 06, 2017 at 12:36:48PM +1100, Dave Chinner wrote:
> > > -	if (radix_tree_preload(GFP_NOFS))
> > > -		return -ENOMEM;
> > > -
> > >  	INIT_LIST_HEAD(&elem->list_node);
> > >  	elem->key = key;
> > >  
> > > -	spin_lock(&mru->lock);
> > > -	error = radix_tree_insert(&mru->store, key, elem);
> > > -	radix_tree_preload_end();
> > > -	if (!error)
> > > -		_xfs_mru_cache_list_insert(mru, elem);
> > > -	spin_unlock(&mru->lock);
> > > +	do {
> > > +		xas_lock(&xas);
> > > +		xas_store(&xas, elem);
> > > +		error = xas_error(&xas);
> > > +		if (!error)
> > > +			_xfs_mru_cache_list_insert(mru, elem);
> > > +		xas_unlock(&xas);
> > > +	} while (xas_nomem(&xas, GFP_NOFS));
> > 
> > Ok, so why does this have a retry loop on ENOMEM despite the
> > existing code handling that error? And why put such a loop in this
> > code and not any of the other XFS code that used
> > radix_tree_preload() and is arguably much more important to avoid
> > ENOMEM on insert (e.g. the inode cache)?
> 
> If we need more nodes in the tree, xas_store() will try to allocate them
> with GFP_NOWAIT | __GFP_NOWARN.  If that fails, it signals it in xas_error().
> xas_nomem() will notice that we're in an ENOMEM situation, and allocate
> a node using your preferred GFP flags (NOIO in your case).  Then we retry,
> guaranteeing forward progress. [1]
> 
> The other conversions use the normal API instead of the advanced API, so
> all of this gets hidden away.  For example, the inode cache does this:
> 
> +       curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);
> 
> and xa_cmpxchg internally does:
> 
>         do {
>                 xa_lock_irqsave(xa, flags);
>                 curr = xas_create(&xas);
>                 if (curr == old)
>                         xas_store(&xas, entry);
>                 xa_unlock_irqrestore(xa, flags);
>         } while (xas_nomem(&xas, gfp));

Ah, OK, that's not obvious from the code changes. :/

However, it's probably overkill for XFS. In all the cases, when we
insert there should be no entry in the tree - the
radix tree insert error handling code there was simply catching
"should never happen" cases and handling it without crashing.

Now that I've looked at this, I have to say that having a return
value of NULL meaning "success" is quite counter-intuitive. That's
going to fire my "that looks so wrong" detector every time I look at
the code and notice it's erroring out on a non-null return value
that isn't a PTR_ERR case....

Also, there's no need for irqsave/restore() locking contexts here as
we never access these caches from interrupt contexts. That's just
going to be extra overhead, especially on workloads that run 10^6
inodes inodes through the cache every second. That's a problem
caused by driving the locks into the XA structure and then needing
to support callers that require irq safety....

> > Also, I really don't like the pattern of using xa_lock()/xa_unlock()
> > to protect access to an external structure. i.e. the mru->lock
> > context is protecting multiple fields and operations in the MRU
> > structure, not just the radix tree operations. Turning that around
> > so that a larger XFS structure and algorithm is now protected by an
> > opaque internal lock from generic storage structure the forms part
> > of the larger structure seems like a bad design pattern to me...
> 
> It's the design pattern I've always intended to use.  Naturally, the
> xfs radix trees weren't my initial target; it was the page cache, and
> the page cache does the same thing; uses the tree_lock to protect both
> the radix tree and several other fields in that same data structure.
> 
> I'm open to argument on this though ... particularly if you have a better
> design pattern in mind!

I don't mind structures having internal locking - I have a problem
with leaking them into contexts outside the structure they protect.
That way lies madness - you can't change the internal locking in
future because of external dependencies, and the moment you need
something different externally we've got to go back to an external
lock anyway.

This is demonstrated by the way you converted the XFS dquot tree -
you didn't replace the dquot tree lock with the internal xa_lock
because it's a mutex and we have to sleep holding it. IOWs, we've
added another layer of locking here, not simplified the code.

What I really see here is that  we have inconsistent locking
patterns w.r.t. XA stores inside XFS - some have an external mutex
to cover a wider scope, some use xa_lock/xa_unlock to span multiple
operations, some directly access the internal xa lock via direct
spin_lock/unlock(...xa_lock) calls and non-locking XA call variants.
In some places you remove explicit rcu_read_lock() calls because the
internal xa_lock implies RCU, but in other places we still need them
because we have to protect the objects the tree points to, not just
the tree....

IOWs, there's no consistent pattern to the changes you've made to
the XFS code. The existing radix tree code has clear, consistent
locking, tagging and lookup patterns. In contrast, each conversion
to the XA code has resulted in a different solution for each radix
tree conversion. Yes, there's been a small reduction in the amoutn
of code in converting to the XA API, but it comes at the cost of
consistency and ease of understanding the code that uses the radix
tree API.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
