Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6F686B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 17:34:06 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t87so59973413ioe.7
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 14:34:06 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h92si1317782iod.181.2017.06.13.14.34.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 14:34:05 -0700 (PDT)
Date: Tue, 13 Jun 2017 15:34:01 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 1/2] mm: improve readability of
 transparent_hugepage_enabled()
Message-ID: <20170613213401.GA17972@linux.intel.com>
References: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149713137177.17377.6712234218256825718.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170613210630.GA5135@linux.intel.com>
 <CAPcyv4jjx3QpAMgpRx0h+8bUkcKC0DhW-3Bds0T8K1Z8kgw=xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jjx3QpAMgpRx0h+8bUkcKC0DhW-3Bds0T8K1Z8kgw=xA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jun 13, 2017 at 02:16:49PM -0700, Dan Williams wrote:
> On Tue, Jun 13, 2017 at 2:06 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > So, if the VM_NOHUGEPAGE flag is set or if the vma is for a temporary stack,
> > we always bail.  Also, we only care about the VM_HUGEPAGE flag in the presence
> > of TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG.
> >
> > I think this static inline is logically equivalent (untested):
> >
> > static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
> > {
> >         if ((vma->vm_flags & VM_NOHUGEPAGE) || is_vma_temporary_stack(vma))
> >                 return false;
> >
> >         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> >                 return true;
> >
> >         if ((transparent_hugepage_flags &
> >                                 (1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
> >                         && vma->vm_flags & VM_HUGEPAGE)
> >                 return true;
> 
> We can clean this up a bit and do:
> 
>    return !!(vma->vm_flags & VM_HUGEPAGE)
> 
> ...to drop the &&

Sure, that'll read better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
