Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6BD6B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 10:10:12 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2425306eae.27
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 07:10:11 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id s8si20401055eeh.80.2013.12.23.07.10.10
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 07:10:10 -0800 (PST)
Date: Mon, 23 Dec 2013 17:10:03 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 21/22] Add support for pmd_faults
Message-ID: <20131223151003.GA15744@node.dhcp.inet.fi>
References: <cover.1387748521.git.matthew.r.wilcox@intel.com>
 <e944917f571781b46ca4dbb789ae8a86c5166059.1387748521.git.matthew.r.wilcox@intel.com>
 <20131223134113.GA14806@node.dhcp.inet.fi>
 <20131223145031.GB11091@parisc-linux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131223145031.GB11091@parisc-linux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Dec 23, 2013 at 07:50:31AM -0700, Matthew Wilcox wrote:
> On Mon, Dec 23, 2013 at 03:41:13PM +0200, Kirill A. Shutemov wrote:
> > > +	/* Fall back to PTEs if we're going to COW */
> > > +	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
> > > +		return VM_FAULT_FALLBACK;
> > 
> > Why?
> 
> If somebody mmaps a file with MAP_PRIVATE and changes a single byte, I
> think we should allocate a single page to hold that change, not a PMD's
> worth of pages.

We try allocate new huge page in the same situation for AnonTHP. I don't
see a reason why not to do the same here. It would be much harder (if
possible) to collapse small page into a huge one later.

> > > +	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> > > +	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
> > > +	if (pgoff >= size)
> > > +		return VM_FAULT_SIGBUS;
> > > +	if ((pgoff | PG_PMD_COLOUR) >= size)
> > > +		return VM_FAULT_FALLBACK;
> > 
> > I don't think it's necessary to fallback in this case.
> > Do you care about SIGBUS behaviour or what?
> 
> I'm looking to preserve the same behaviour we see with PTE mappings.  I mean,
> it's supposed to be _transparent_ huge pages, right?

We can't be totally transparent. At least from performance point of view.

The question is whether it's critical to preserve SIGBUS beheviour. I
would prefer to map last page in mapping with huge pages too, if it's
possible.

Do you know anyone who relay on SIGBUS for correctness?

> 
> > > + insert:
> > > +	length = xip_get_pfn(inode, &bh, &pfn);
> > > +	if (length < 0)
> > > +		return VM_FAULT_SIGBUS;
> > > +	if (length < PMD_SIZE)
> > > +		return VM_FAULT_FALLBACK;
> > > +	if (pfn & PG_PMD_COLOUR)
> > > +		return VM_FAULT_FALLBACK;	/* not aligned */
> > 
> > Without assistance from get_unmapped_area() you will hit this all the time
> > (511 of 512 on x86_64).
> 
> Yes ... I thought you were working on that part for your transparent huge
> page cache patchset?

Yeah, I have patch for x86-64. Just a side note.

> 
> > And the check should be moved before get_block(), I think.
> 
> Can't.  The PFN we're checking is the PFN of the storage.  We have to
> call get_block() to find out where it's going to be.

I see.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
