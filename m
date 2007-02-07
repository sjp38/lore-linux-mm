Date: Wed, 7 Feb 2007 22:55:21 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] Implement ->page_mkwrite for XFS
Message-ID: <20070207115521.GH44411608@melbourne.sgi.com>
References: <20070206225325.GP33919298@melbourne.sgi.com> <20070207101823.GA2703@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070207101823.GA2703@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Chinner <dgc@sgi.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 07, 2007 at 10:18:23AM +0000, Christoph Hellwig wrote:
> 
> This looks to me.  But given that this is generic code except for the
> get_block callback, shouldn't we put the guts into buffer.c and wire
> all filesystems up to use it? e.g.
> 
> 
> int block_page_mkwrite(struct vm_area_struct  *vma, struct page *page,
> 		get_block_t get_block)
> {
> 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
> 	unsigned long end;
> 	int ret = 0;
> 
> 	if ((page->index + 1) << PAGE_CACHE_SHIFT > i_size_read(inode))
> 		end = i_size_read(inode) & ~PAGE_CACHE_MASK;
> 	else
> 		end = PAGE_CACHE_SIZE;
> 
> 	lock_page(page);
> 	ret = block_prepare_write(page, 0, end, block);
> 	if (!ret)
> 		ret = block_commit_write(page, 0, end);
> 	unlock_page(page);
> 	return ret;
> }
> 
> and then in xfs and similar in other filesystems:
> 
> STATIC int
> xfs_vm_page_mkwrite(
> 	struct vm_area_struct	*vma,
> 	struct page		*page)
> {
> 	return block_page_mkwrite(vma, page, xfs_get_blocks);
> }

Yes, that can be done. block_page_mkwrite() would then go into
fs/buffer.c? My patch originally had a bunch of other stuff and
i wasn't sure that it could be done with generic code.

I'll send an updated patch in a little while.

> BTW, why is xfs_get_blocks not called xfs_get_block?

<shrug>

I presume because it replaced the xfs_get_block() function when the
block mapping callouts were modified to support mapping of multiple
blocks. Maybe you should ask Nathan that question. ;)

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
