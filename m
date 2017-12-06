Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1CF46B0310
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:02:12 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id b192so1201195yba.20
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:02:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j3si362362ywa.746.2017.12.05.18.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 18:02:11 -0800 (PST)
Date: Tue, 5 Dec 2017 18:02:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171206020208.GK26021@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206012901.GZ4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 06, 2017 at 12:36:48PM +1100, Dave Chinner wrote:
> > -	if (radix_tree_preload(GFP_NOFS))
> > -		return -ENOMEM;
> > -
> >  	INIT_LIST_HEAD(&elem->list_node);
> >  	elem->key = key;
> >  
> > -	spin_lock(&mru->lock);
> > -	error = radix_tree_insert(&mru->store, key, elem);
> > -	radix_tree_preload_end();
> > -	if (!error)
> > -		_xfs_mru_cache_list_insert(mru, elem);
> > -	spin_unlock(&mru->lock);
> > +	do {
> > +		xas_lock(&xas);
> > +		xas_store(&xas, elem);
> > +		error = xas_error(&xas);
> > +		if (!error)
> > +			_xfs_mru_cache_list_insert(mru, elem);
> > +		xas_unlock(&xas);
> > +	} while (xas_nomem(&xas, GFP_NOFS));
> 
> Ok, so why does this have a retry loop on ENOMEM despite the
> existing code handling that error? And why put such a loop in this
> code and not any of the other XFS code that used
> radix_tree_preload() and is arguably much more important to avoid
> ENOMEM on insert (e.g. the inode cache)?

If we need more nodes in the tree, xas_store() will try to allocate them
with GFP_NOWAIT | __GFP_NOWARN.  If that fails, it signals it in xas_error().
xas_nomem() will notice that we're in an ENOMEM situation, and allocate
a node using your preferred GFP flags (NOIO in your case).  Then we retry,
guaranteeing forward progress. [1]

The other conversions use the normal API instead of the advanced API, so
all of this gets hidden away.  For example, the inode cache does this:

+       curr = xa_cmpxchg(&pag->pag_ici_xa, agino, NULL, ip, GFP_NOFS);

and xa_cmpxchg internally does:

        do {
                xa_lock_irqsave(xa, flags);
                curr = xas_create(&xas);
                if (curr == old)
                        xas_store(&xas, entry);
                xa_unlock_irqrestore(xa, flags);
        } while (xas_nomem(&xas, gfp));


> Also, I really don't like the pattern of using xa_lock()/xa_unlock()
> to protect access to an external structure. i.e. the mru->lock
> context is protecting multiple fields and operations in the MRU
> structure, not just the radix tree operations. Turning that around
> so that a larger XFS structure and algorithm is now protected by an
> opaque internal lock from generic storage structure the forms part
> of the larger structure seems like a bad design pattern to me...

It's the design pattern I've always intended to use.  Naturally, the
xfs radix trees weren't my initial target; it was the page cache, and
the page cache does the same thing; uses the tree_lock to protect both
the radix tree and several other fields in that same data structure.

I'm open to argument on this though ... particularly if you have a better
design pattern in mind!

[1] I actually have this documented!  It's in the xas_nomem() kernel-doc:

 * If we need to add new nodes to the XArray, we try to allocate memory
 * with GFP_NOWAIT while holding the lock, which will usually succeed.
 * If it fails, @xas is flagged as needing memory to continue.  The caller
 * should drop the lock and call xas_nomem().  If xas_nomem() succeeds,
 * the caller should retry the operation.
 *
 * Forward progress is guaranteed as one node is allocated here and
 * stored in the xa_state where it will be found by xas_alloc().  More
 * nodes will likely be found in the slab allocator, but we do not tie
 * them up here.
 *
 * Return: true if memory was needed, and was successfully allocated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
