Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A0F6A6B006C
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 16:47:29 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so400077pad.27
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 13:47:29 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id vb9si1808719pac.60.2014.10.09.13.47.27
        for <linux-mm@kvack.org>;
        Thu, 09 Oct 2014 13:47:28 -0700 (PDT)
Date: Thu, 9 Oct 2014 16:47:16 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v1 5/7] dax: Add huge page fault support
Message-ID: <20141009204716.GQ5098@wil.cx>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-6-git-send-email-matthew.r.wilcox@intel.com>
 <20141008201100.GB9232@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141008201100.GB9232@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Wed, Oct 08, 2014 at 11:11:00PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 08, 2014 at 09:25:27AM -0400, Matthew Wilcox wrote:
> > +	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > +	if (pgoff >= size)
> > +		return VM_FAULT_SIGBUS;
> > +	/* If the PMD would cover blocks out of the file */
> > +	if ((pgoff | PG_PMD_COLOUR) >= size)
> > +		return VM_FAULT_FALLBACK;
> 
> IIUC, zero pading would work too.

The blocks after this file might be allocated to another file already.
I suppose we could ask the filesystem if it wants to allocate them to
this file.

Dave, Jan, is it acceptable to call get_block() for blocks that extend
beyond the current i_size?

> > +
> > +	memset(&bh, 0, sizeof(bh));
> > +	block = ((sector_t)pgoff & ~PG_PMD_COLOUR) << (PAGE_SHIFT - blkbits);
> > +
> > +	/* Start by seeing if we already have an allocated block */
> > +	bh.b_size = PMD_SIZE;
> > +	length = get_block(inode, block, &bh, 0);
> 
> This makes me confused. get_block() return zero on success, right?
> Why the var called 'lenght'?

Historical reasons.  I can go back and change the name of the variable.

> > +	sector = bh.b_blocknr << (blkbits - 9);
> > +	length = bdev_direct_access(bh.b_bdev, sector, &kaddr, &pfn, bh.b_size);
> > +	if (length < 0)
> > +		goto sigbus;
> > +	if (length < PMD_SIZE)
> > +		goto fallback;
> > +	if (pfn & PG_PMD_COLOUR)
> > +		goto fallback;	/* not aligned */
> 
> So, are you rely on pure luck to make get_block() allocate 2M aligned pfn?
> Not really productive. You would need assistance from fs and
> arch_get_unmapped_area() sides.

Certainly ext4 and XFS will align their allocations; if you ask it for a
2MB block, it will try to allocate a 2MB block aligned on a 2MB boundary.

I started looking into the get_unampped_area (and have the code sitting
around to align specially marked files on special boundaries), but when
I mentioned it to the author of the NVM Library, he said "Oh, I'll just
pick a 1GB aligned area to request it be mapped at", so I haven't taken
it any further.

The upshot is that (confirmed with debugging code), when the tests run,
they pretty much always get a correctly aligned block.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
