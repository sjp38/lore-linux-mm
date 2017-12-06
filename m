Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFC736B0309
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 20:43:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id m9so1794832pff.0
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 17:43:48 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id t7si971889pgs.6.2017.12.05.17.43.46
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 17:43:47 -0800 (PST)
Date: Wed, 6 Dec 2017 12:36:48 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171206012901.GZ4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206004159.3755-73-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 04:41:58PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This eliminates a call to radix_tree_preload().

.....

>  void
> @@ -431,24 +424,24 @@ xfs_mru_cache_insert(
>  	unsigned long		key,
>  	struct xfs_mru_cache_elem *elem)
>  {
> +	XA_STATE(xas, &mru->store, key);
>  	int			error;
>  
>  	ASSERT(mru && mru->lists);
>  	if (!mru || !mru->lists)
>  		return -EINVAL;
>  
> -	if (radix_tree_preload(GFP_NOFS))
> -		return -ENOMEM;
> -
>  	INIT_LIST_HEAD(&elem->list_node);
>  	elem->key = key;
>  
> -	spin_lock(&mru->lock);
> -	error = radix_tree_insert(&mru->store, key, elem);
> -	radix_tree_preload_end();
> -	if (!error)
> -		_xfs_mru_cache_list_insert(mru, elem);
> -	spin_unlock(&mru->lock);
> +	do {
> +		xas_lock(&xas);
> +		xas_store(&xas, elem);
> +		error = xas_error(&xas);
> +		if (!error)
> +			_xfs_mru_cache_list_insert(mru, elem);
> +		xas_unlock(&xas);
> +	} while (xas_nomem(&xas, GFP_NOFS));

Ok, so why does this have a retry loop on ENOMEM despite the
existing code handling that error? And why put such a loop in this
code and not any of the other XFS code that used
radix_tree_preload() and is arguably much more important to avoid
ENOMEM on insert (e.g. the inode cache)?

Also, I really don't like the pattern of using xa_lock()/xa_unlock()
to protect access to an external structure. i.e. the mru->lock
context is protecting multiple fields and operations in the MRU
structure, not just the radix tree operations. Turning that around
so that a larger XFS structure and algorithm is now protected by an
opaque internal lock from generic storage structure the forms part
of the larger structure seems like a bad design pattern to me...

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
