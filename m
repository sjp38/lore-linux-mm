Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0D4276B0071
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 16:53:40 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so6119132pab.0
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 13:53:39 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id u12si28514586pdj.73.2015.01.13.13.53.37
        for <linux-mm@kvack.org>;
        Tue, 13 Jan 2015 13:53:38 -0800 (PST)
Date: Tue, 13 Jan 2015 16:53:34 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 08/20] dax,ext2: Replace the XIP page fault handler
 with the DAX page fault handler
Message-ID: <20150113215334.GK5661@wil.cx>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-9-git-send-email-matthew.r.wilcox@intel.com>
 <20150112150952.b44ee750a6292284e7a909ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150112150952.b44ee750a6292284e7a909ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

On Mon, Jan 12, 2015 at 03:09:52PM -0800, Andrew Morton wrote:
> On Fri, 24 Oct 2014 17:20:40 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> 
> > Instead of calling aops->get_xip_mem from the fault handler, the
> > filesystem passes a get_block_t that is used to find the appropriate
> > blocks.
> > 
> > ...
> >
> > +static int copy_user_bh(struct page *to, struct buffer_head *bh,
> > +			unsigned blkbits, unsigned long vaddr)
> > +{
> > +	void *vfrom, *vto;
> > +	if (dax_get_addr(bh, &vfrom, blkbits) < 0)
> > +		return -EIO;
> > +	vto = kmap_atomic(to);
> > +	copy_user_page(vto, vfrom, vaddr, to);
> > +	kunmap_atomic(vto);
> 
> Again, please check the cache-flush aspects.  copy_user_page() appears
> to be reponsible for handling coherency issues on the destination
> vaddr, but what about *vto?

vto is a new kernel address ... if there's any dirty data for that
address, it should have been flushed by the prior kunmap_atomic(), right?

> > +	mutex_lock(&mapping->i_mmap_mutex);
> > +
> > +	/*
> > +	 * Check truncate didn't happen while we were allocating a block.
> > +	 * If it did, this block may or may not be still allocated to the
> > +	 * file.  We can't tell the filesystem to free it because we can't
> > +	 * take i_mutex here.
> 
> (what's preventing us from taking i_mutex?)

We're in a page fault handler, and we may already be holding i_mutex.
We're definitely holding mmap_sem, and to quote from mm/rmap.c:

/*
 * Lock ordering in mm:
 *
 * inode->i_mutex       (while writing or truncating, not reading or faulting)
 *   mm->mmap_sem

> >  	   In the worst case, the file still has blocks
> > +	 * allocated past the end of the file.
> > +	 */
> > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +	if (unlikely(vmf->pgoff >= size)) {
> > +		error = -EIO;
> > +		goto out;
> > +	}
> 
> How does this play with holepunching?  Checking i_size won't work there?

It doesn't.  But the same problem exists with non-DAX files too, and
when I pointed it out, it was met with a shrug from the crowd.  I saw a
patch series just recently that fixes it for XFS, but as far as I know,
btrfs and ext4 still don't play well with pagefault vs hole-punch races.

> > +	memset(&bh, 0, sizeof(bh));
> > +	block = (sector_t)vmf->pgoff << (PAGE_SHIFT - blkbits);
> > +	bh.b_size = PAGE_SIZE;
> 
> ah, there.
> 
> PAGE_SIZE varies a lot between architectures.  What are the
> implications of this>?

At the moment, you can only do DAX for blocksizes that are equal to
PAGE_SIZE.  That's a restriction that existed for the previous XIP code,
and I haven't fixed it all for DAX yet.  I'd like to, but it's not high on
my list of things to fix.  Since these are in-mmeory filesystems, there's
not likely to be high demand to move the filesystem between machines.

> > + repeat:
> > +	page = find_get_page(mapping, vmf->pgoff);
> > +	if (page) {
> > +		if (!lock_page_or_retry(page, vma->vm_mm, vmf->flags)) {
> > +			page_cache_release(page);
> > +			return VM_FAULT_RETRY;
> > +		}
> > +		if (unlikely(page->mapping != mapping)) {
> > +			unlock_page(page);
> > +			page_cache_release(page);
> > +			goto repeat;
> > +		}
> > +		size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +		if (unlikely(vmf->pgoff >= size)) {
> > +			error = -EIO;
> 
> What happened when this happens?

This case is where we have a struct page covering a hole in the file from
a read fault and we've raced with a truncate.  It's basically the same code
that's in filemap_fault().

> > +			goto unlock_page;
> > +		}
> > +	}
> > +
> > +	error = get_block(inode, block, &bh, 0);
> > +	if (!error && (bh.b_size < PAGE_SIZE))
> > +		error = -EIO;
> 
> How could this happen?

The only way I can think of is if the filesystem was corrupted.  But it's
worth programming defensively, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
