Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 977B46B0083
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 18:24:22 -0500 (EST)
Date: Sat, 28 Feb 2009 18:24:21 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch][rfc] mm: new address space calls
Message-ID: <20090228232421.GB11191@infradead.org>
References: <20090225104839.GG22785@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090225104839.GG22785@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2009 at 11:48:39AM +0100, Nick Piggin wrote:
> This is about the last change to generic code I need for fsblock.
> Comments?
> 
> Introduce new address space operations sync and release, which can be used
> by a filesystem to synchronize and release per-address_space private metadata.
> They generalise sync_mapping_buffers, invalidate_inode_buffers, and
> remove_inode_buffers calls, and get another step closer to divorcing
> buffer heads from core mm/fs code.

>  void invalidate_inode_buffers(struct inode *inode)
>  {
> -	if (inode_has_buffers(inode)) {
> -		struct address_space *mapping = &inode->i_data;
> +	struct address_space *mapping = &inode->i_data;
> +
> +	if (mapping_has_private(mapping)) {
>  		struct list_head *list = &mapping->private_list;
>  		struct address_space *buffer_mapping = mapping->assoc_mapping;

I'ts not really helping much here as we still directly poke into the
buffer_head list.

> --- linux-2.6.orig/fs/fs-writeback.c
> +++ linux-2.6/fs/fs-writeback.c
> @@ -782,9 +782,15 @@ int generic_osync_inode(struct inode *in
>  	if (what & OSYNC_DATA)
>  		err = filemap_fdatawrite(mapping);
>  	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
> -		err2 = sync_mapping_buffers(mapping);
> -		if (!err)
> -			err = err2;
> +		if (!mapping->a_ops->sync) {
> +			err2 = sync_mapping_buffers(mapping);
> +			if (!err)
> +				err = err2;
> +		} else {
> +			err2 = mapping->a_ops->sync(mapping);
> +			if (!err)
> +				err = err2;
> +		}
>  	}
>  	if (what & OSYNC_DATA) {
>  		err2 = filemap_fdatawait(mapping);

I'd really prefer not having the default fallbacks, these kinds
of implicit fallbacks make the code really hard to maintain over
long term.

I also wonder if moving the filemap_fdatawrite/filemap_fdatawait
into the method would help.  In fact it's surprisingly similar
to ->fsync in many ways, that I wonder if these should be one
operation.

>   */
>  void clear_inode(struct inode *inode)
>  {
> +	struct address_space *mapping = &inode->i_data;
> +
>  	might_sleep();
> -	invalidate_inode_buffers(inode);
> +	if (!mapping->a_ops->release)
> +		invalidate_inode_buffers(inode);

That's a weird one.  The implict default shouldn't be in a different
place from the method.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
