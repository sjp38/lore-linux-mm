Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFBA6B004F
	for <linux-mm@kvack.org>; Mon,  6 Jul 2009 12:44:41 -0400 (EDT)
Date: Mon, 6 Jul 2009 13:22:41 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090706172241.GA26042@infradead.org>
References: <20090706165438.GQ2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090706165438.GQ2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 06, 2009 at 06:54:38PM +0200, Nick Piggin wrote:
> +int inode_truncate_ok(struct inode *inode, loff_t offset)
> +{
> +	if (inode->i_size < offset) {
> +		unsigned long limit;
> +
> +		limit = current->signal->rlim[RLIMIT_FSIZE].rlim_cur;
> +		if (limit != RLIM_INFINITY && offset > limit)
> +			goto out_sig;
> +		if (offset > inode->i_sb->s_maxbytes)
> +			goto out_big;
> +	} else {
> +		/*
> +		 * truncation of in-use swapfiles is disallowed - it would
> +		 * cause subsequent swapout to scribble on the now-freed
> +		 * blocks.
> +		 */
> +		if (IS_SWAPFILE(inode))
> +			return -ETXTBSY;
> +	}
> +
> +	return 0;
> +out_sig:
> +	send_sig(SIGXFSZ, current, 0);
> +out_big:
> +	return -EFBIG;
> +}
> +EXPORT_SYMBOL(inode_truncate_ok);

This one needs a good kernel doc comment I think.

>  int inode_setattr(struct inode * inode, struct iattr * attr)
>  {
>  	unsigned int ia_valid = attr->ia_valid;
>  
> -	if (ia_valid & ATTR_SIZE &&
> -	    attr->ia_size != i_size_read(inode)) {
> -		int error = vmtruncate(inode, attr->ia_size);
> -		if (error)
> -			return error;
> +	if (ia_valid & ATTR_SIZE) {
> +		loff_t offset = attr->ia_size;
> +
> +		if (offset != inode->i_size) {
> +			int error;
> +
> +			if (inode->i_op->ftruncate) {
> +				struct file *filp = NULL;
> +				int open = 0;
> +
> +				if (ia_valid & ATTR_FILE)
> +					filp = attr->ia_file;
> +				if (ia_valid & ATTR_OPEN)
> +					open = 1;
> +				error = inode->i_op->ftruncate(filp, open,
> +							inode, offset);
> +			} else

This is layered quite horribly.  The new truncate method should be
called from notify_change. not inode_setattr which is the default
implementation for ->setattr.

ftruncate as a name for a method also used for truncate without a file
is also not so good naming.  I'd also pass down the dentry as some thing
like cifs want this (requires calling it from notify_change instead of
inode_setattr, too), and turn the open boolean into a flags value.

Also passing file as the first argument when it's optional is a quite
ugly calling convention, the fundamental object we operate on is the
dentry.

> + * truncate_pagecache - unmap mappings "freed" by truncate() syscall
> + * @inode: inode
> + * @old: old file offset
> + * @new: new file offset
> + *
> + * inode's new i_size must already be written before truncate_pagecache
> + * is called.
> + */
> +void truncate_pagecache(struct inode * inode, loff_t old, loff_t new)
> +{
> +	VM_BUG_ON(inode->i_size != new);
> +
> +	if (new < old) {
> +		struct address_space *mapping = inode->i_mapping;
> +
> +#ifdef CONFIG_MMU
> +		/*
> +		 * unmap_mapping_range is called twice, first simply for
> +		 * efficiency so that truncate_inode_pages does fewer
> +		 * single-page unmaps.  However after this first call, and
> +		 * before truncate_inode_pages finishes, it is possible for
> +		 * private pages to be COWed, which remain after
> +		 * truncate_inode_pages finishes, hence the second
> +		 * unmap_mapping_range call must be made for correctness.
> +		 */
> +		unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> +		truncate_inode_pages(mapping, new);
> +		unmap_mapping_range(mapping, new + PAGE_SIZE - 1, 0, 1);
> +#else
> +		truncate_inode_pages(mapping, new);
> +#endif
> +	}
> +}
> +EXPORT_SYMBOL(truncate_pagecache);

unmap_mapping_range is a noop stub for !CONFIG_MMU so we can just use
the mmu version unconditionally.

> +int truncate_blocks(struct inode *inode, loff_t offset)
> +{
> +	if (inode->i_op->ftruncate) /* these guys handle it themselves */
> +		return 0;
> +
> +	return vmtruncate(inode, offset);
> +}
> +EXPORT_SYMBOL(truncate_blocks);

Even if this one is temporary it probably needs a small comment
explaining it

> @@ -1992,9 +1992,12 @@ int block_write_begin(struct file *file,
>  			 * prepare_write() may have instantiated a few blocks
>  			 * outside i_size.  Trim these off again. Don't need
>  			 * i_size_read because we hold i_mutex.
> +			 *
> +			 * Filesystems which define ->ftruncate must handle
> +			 * this themselves.
>  			 */
>  			if (pos + len > inode->i_size)
> -				vmtruncate(inode, inode->i_size);
> +				truncate_blocks(inode, inode->i_size);

How would they do that?

>  	if (pos + len > inode->i_size)
> -		vmtruncate(inode, inode->i_size);
> +		truncate_blocks(inode, inode->i_size);

Same here.

>  		if (end > isize && dio_lock_type == DIO_LOCKING)
> -			vmtruncate(inode, isize);
> +			truncate_blocks(inode, isize);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
