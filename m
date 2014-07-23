Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8A08C6B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 09:55:21 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1760560pad.22
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 06:55:21 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q9si1320123pdj.265.2014.07.23.06.55.20
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 06:55:20 -0700 (PDT)
Date: Wed, 23 Jul 2014 09:55:14 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 10/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140723135514.GB6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <00ad731b459e32ce965af8530bcd611a141e41b6.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723121025.GE10317@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723121025.GE10317@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 03:10:25PM +0300, Kirill A. Shutemov wrote:
> > +int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +			get_block_t get_block)
> > +{
> > +	int result;
> > +	struct super_block *sb = file_inode(vma->vm_file)->i_sb;
> > +
> > +	if (vmf->flags & FAULT_FLAG_WRITE) {
> 
> Nobody seems calls sb_start_pagefault() in fault handler.
> Do you mean FAULT_FLAG_MKWRITE?

We need to call sb_start_pagefault() if we're going to make a modification
to the filesystem.  Admittedly, we don't know if we're going to make a
modification at this point, but if we're taking a write fault on a hole,
we will be.  We can skip the call to sb_start_pagefault() if we're taking
a read fault.

> > +int dax_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
> > +			get_block_t get_block)
> > +{
> > +	return dax_fault(vma, vmf, get_block);
> > +}
> > +EXPORT_SYMBOL_GPL(dax_mkwrite);
> 
> I don't think we want to introduce new exported symbol just for dummy
> wrapper. Just use ".page_mkwrite = foo_fault,". perf and selinux do
> this.
> Or add #define into header file if you want better readability.

They were different at one time ... agreed, I can just make them an alias
for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
