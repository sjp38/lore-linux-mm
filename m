Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B4D006B0069
	for <linux-mm@kvack.org>; Sun, 12 Oct 2014 21:13:40 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so4692602pdi.24
        for <linux-mm@kvack.org>; Sun, 12 Oct 2014 18:13:40 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id ip5si8887655pbc.246.2014.10.12.18.13.38
        for <linux-mm@kvack.org>;
        Sun, 12 Oct 2014 18:13:39 -0700 (PDT)
Date: Mon, 13 Oct 2014 12:13:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v1 5/7] dax: Add huge page fault support
Message-ID: <20141013011315.GB4503@dastard>
References: <1412774729-23956-1-git-send-email-matthew.r.wilcox@intel.com>
 <1412774729-23956-6-git-send-email-matthew.r.wilcox@intel.com>
 <20141008201100.GB9232@node.dhcp.inet.fi>
 <20141009204716.GQ5098@wil.cx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141009204716.GQ5098@wil.cx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 09, 2014 at 04:47:16PM -0400, Matthew Wilcox wrote:
> On Wed, Oct 08, 2014 at 11:11:00PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Oct 08, 2014 at 09:25:27AM -0400, Matthew Wilcox wrote:
> > > +	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > > +	if (pgoff >= size)
> > > +		return VM_FAULT_SIGBUS;
> > > +	/* If the PMD would cover blocks out of the file */
> > > +	if ((pgoff | PG_PMD_COLOUR) >= size)
> > > +		return VM_FAULT_FALLBACK;
> > 
> > IIUC, zero pading would work too.
> 
> The blocks after this file might be allocated to another file already.
> I suppose we could ask the filesystem if it wants to allocate them to
> this file.
> 
> Dave, Jan, is it acceptable to call get_block() for blocks that extend
> beyond the current i_size?

In what context? XFS basically does nothing for certain cases (e.g.
read mapping for direct IO) where zeroes are always going to be
returned, so essentially filesystems right now may actually just
return a "hole" for any read mapping request beyond EOF.

If "create" is set, then we'll either create or map existing blocks
beyond EOF because the we have to reserve space or allocate blocks
before the EOF gets extended when the write succeeds fully...

> > > +	if (length < PMD_SIZE)
> > > +		goto fallback;
> > > +	if (pfn & PG_PMD_COLOUR)
> > > +		goto fallback;	/* not aligned */
> > 
> > So, are you rely on pure luck to make get_block() allocate 2M aligned pfn?
> > Not really productive. You would need assistance from fs and
> > arch_get_unmapped_area() sides.
> 
> Certainly ext4 and XFS will align their allocations; if you ask it for a
> 2MB block, it will try to allocate a 2MB block aligned on a 2MB boundary.

As a sweeping generalisation, that's wrong. Empty filesystems might
behave that way, but we don't *guarantee* that this sort of
alignment will occur.

XFS has several different extent alignment strategies and
none of them will always work that way. Many of them are dependent
on mkfs parameters, and even then are used only as *guidelines*.
Further, alignment is dependent on the size of the write being done
- on some filesystem configs a 2MB write might be aligned, but on
others it won't be. More complex still is that mount options can
change alignment behaviour, as can per-file extent size hints, as
can truncation that removes post-eof blocks...

IOWs, if you want the filesystem to guarantee alignment to the
underlying hardware in this way for DAX, we're going to need to make
some modifications to the allocator alignment strategy.

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
