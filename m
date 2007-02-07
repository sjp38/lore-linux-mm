Date: Wed, 7 Feb 2007 10:18:23 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Implement ->page_mkwrite for XFS
Message-ID: <20070207101823.GA2703@infradead.org>
References: <20070206225325.GP33919298@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206225325.GP33919298@melbourne.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 07, 2007 at 09:53:25AM +1100, David Chinner wrote:
> Folks,
> 
> I'm not sure of the exact locking rules and constraints for
> ->page_mkwrite(), so I thought I better fish around for comments.
> 
> With XFS, we need to hook pages being dirtied by mmap writes so that
> we can attach buffers of the correct state tothe pages.  This means
> that when we write them back, the correct thing happens.
> 
> For example, if you mmap an unwritten extent (preallocated),
> currently your data will get written to disk but the extent will not
> get converted to a written extent. IOWs, you lose the data because
> when you read it back it will seen as unwritten and treated as a
> hole.
> 
> AFAICT, it is safe to lock the page during ->page_mkwrite and that
> it is safe to issue I/O (e.g. metadata reads) to determine the
> current state of the file.  I am also assuming that, at this point,
> we are not allowed to change the file size and so we have to be
> careful in ->page_mkwrite we don't do that. What else have I missed
> here?
> 
> IOWs, I've basically treated ->page_mkwrite() as wrapper for
> block_prepare_write/block_commit_write because they do all the
> buffer mapping and state manipulation I think is necessary.  Is it
> safe to call these functions, or are there some other constraints we
> have to work under here?
> 
> Patch below. Comments?
> 
> Cheers,
> 
> Dave.
> -- 
> Dave Chinner
> Principal Engineer
> SGI Australian Software Group
> 
> 
> ---
>  fs/xfs/linux-2.6/xfs_file.c |   34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
> 
> Index: 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c
> ===================================================================
> --- 2.6.x-xfs-new.orig/fs/xfs/linux-2.6/xfs_file.c	2007-01-16 10:54:15.000000000 +1100
> +++ 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_file.c	2007-02-07 09:49:00.508017483 +1100
> @@ -446,6 +446,38 @@ xfs_file_open_exec(
>  }
>  #endif /* HAVE_FOP_OPEN_EXEC */
>  
> +/*
> + * mmap()d file has taken write protection fault and is being made
> + * writable. We can set the page state up correctly for a writable
> + * page, which means we can do correct delalloc accounting (ENOSPC
> + * checking!) and unwritten extent mapping.
> + */
> +STATIC int
> +xfs_vm_page_mkwrite(
> +	struct vm_area_struct	*vma,
> +	struct page		*page)
> +{
> +	struct inode	*inode = vma->vm_file->f_path.dentry->d_inode;
> +	unsigned long	end;
> +	int		ret = 0;
> +
> +	end = page->index + 1;
> +	end <<= PAGE_CACHE_SHIFT;
> +	if (end > i_size_read(inode))
> +		end = i_size_read(inode) & ~PAGE_CACHE_MASK;
> +	else
> +		end = PAGE_CACHE_SIZE;
> +
> +	lock_page(page);
> +	ret = block_prepare_write(page, 0, end, xfs_get_blocks);
> +	if (!ret)
> +		ret = block_commit_write(page, 0, end);
> +	unlock_page(page);
> +
> +	return ret;
> +}

This looks to me.  But given that this is generic code except for the
get_block callback, shouldn't we put the guts into buffer.c and wire
all filesystems up to use it? e.g.


int block_page_mkwrite(struct vm_area_struct  *vma, struct page *page,
		get_block_t get_block)
{
	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
	unsigned long end;
	int ret = 0;

	if ((page->index + 1) << PAGE_CACHE_SHIFT > i_size_read(inode))
		end = i_size_read(inode) & ~PAGE_CACHE_MASK;
	else
		end = PAGE_CACHE_SIZE;

	lock_page(page);
	ret = block_prepare_write(page, 0, end, block);
	if (!ret)
		ret = block_commit_write(page, 0, end);
	unlock_page(page);
	return ret;
}

and then in xfs and similar in other filesystems:

STATIC int
xfs_vm_page_mkwrite(
	struct vm_area_struct	*vma,
	struct page		*page)
{
	return block_page_mkwrite(vma, page, xfs_get_blocks);
}

BTW, why is xfs_get_blocks not called xfs_get_block?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
