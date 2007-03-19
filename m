Message-ID: <45FE2F8F.6010603@yahoo.com.au>
Date: Mon, 19 Mar 2007 17:37:03 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 1 of 2] block_page_mkwrite() Implementation V2
References: <20070318233008.GA32597093@melbourne.sgi.com>
In-Reply-To: <20070318233008.GA32597093@melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

David Chinner wrote:
> Generic page_mkwrite functionality.
> 
> Filesystems that make use of the VM ->page_mkwrite() callout will generally use
> the same core code to implement it. There are several tricky truncate-related
> issues that we need to deal with here as we cannot take the i_mutex as we
> normally would for these paths.  These issues are not documented anywhere yet
> so block_page_mkwrite() seems like the best place to start.



> 
> Version 2:
> 
> - read inode size only once
> - more comments explaining implementation restrictions
> 
> Signed-Off-By: Dave Chinner <dgc@sgi.com>
> 
> ---
>  fs/buffer.c                 |   47 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/buffer_head.h |    2 +
>  2 files changed, 49 insertions(+)
> 
> Index: 2.6.x-xfs-new/fs/buffer.c
> ===================================================================
> --- 2.6.x-xfs-new.orig/fs/buffer.c	2007-03-17 10:55:32.291414968 +1100
> +++ 2.6.x-xfs-new/fs/buffer.c	2007-03-19 08:13:54.519909087 +1100
> @@ -2194,6 +2194,52 @@ int generic_commit_write(struct file *fi
>  	return 0;
>  }
>  
> +/*
> + * block_page_mkwrite() is not allowed to change the file size as it gets
> + * called from a page fault handler when a page is first dirtied. Hence we must
> + * be careful to check for EOF conditions here. We set the page up correctly
> + * for a written page which means we get ENOSPC checking when writing into
> + * holes and correct delalloc and unwritten extent mapping on filesystems that
> + * support these features.
> + *
> + * We are not allowed to take the i_mutex here so we have to play games to
> + * protect against truncate races as the page could now be beyond EOF.  Because
> + * vmtruncate() writes the inode size before removing pages, once we have the
> + * page lock we can determine safely if the page is beyond EOF. If it is not
> + * beyond EOF, then the page is guaranteed safe against truncation until we
> + * unlock the page.
> + */
> +int
> +block_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> +		   get_block_t get_block)
> +{
> +	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
> +	unsigned long end;
> +	loff_t size;
> +	int ret = -EINVAL;
> +
> +	lock_page(page);
> +	size = i_size_read(inode);
> +	if ((page->mapping != inode->i_mapping) ||
> +	    ((page->index << PAGE_CACHE_SHIFT) > size)) {
> +		/* page got truncated out from underneath us */
> +		goto out_unlock;
> +	}

I see your explanation above, but I still don't see why this can't
just follow the conventional if (!page->mapping) check for truncation.
If the test happens to be performed after truncate concurrently
decreases i_size, then the blocks are going to get truncated by the
truncate afterwards anyway.

> +
> +	/* page is wholly or partially inside EOF */
> +	if (((page->index + 1) << PAGE_CACHE_SHIFT) > size)
> +		end = size & ~PAGE_CACHE_MASK;
> +	else
> +		end = PAGE_CACHE_SIZE;
> +
> +	ret = block_prepare_write(page, 0, end, get_block);
> +	if (!ret)
> +		ret = block_commit_write(page, 0, end);
> +
> +out_unlock:
> +	unlock_page(page);
> +	return ret;
> +}

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
