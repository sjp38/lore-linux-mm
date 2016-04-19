Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E63BA6B0253
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:33:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id w143so17127397wmw.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:33:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k71si4545433wmg.79.2016.04.19.07.33.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Apr 2016 07:33:49 -0700 (PDT)
Date: Tue, 19 Apr 2016 16:33:43 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 17/18] dax: Use radix tree entry lock to protect cow
 faults
Message-ID: <20160419143343.GC22413@quack2.suse.cz>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-18-git-send-email-jack@suse.cz>
 <20160419114609.GA13932@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160419114609.GA13932@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Tue 19-04-16 07:46:09, Jerome Glisse wrote:
> On Mon, Apr 18, 2016 at 11:35:40PM +0200, Jan Kara wrote:
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 93897f23cc11..f09cdb8d48fa 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -63,6 +63,7 @@
> >  #include <linux/dma-debug.h>
> >  #include <linux/debugfs.h>
> >  #include <linux/userfaultfd_k.h>
> > +#include <linux/dax.h>
> >  
> >  #include <asm/io.h>
> >  #include <asm/mmu_context.h>
> > @@ -2785,7 +2786,8 @@ oom:
> >   */
> >  static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> >  			pgoff_t pgoff, unsigned int flags,
> > -			struct page *cow_page, struct page **page)
> > +			struct page *cow_page, struct page **page,
> > +			void **entry)
> >  {
> >  	struct vm_fault vmf;
> >  	int ret;
> > @@ -2800,8 +2802,10 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> >  	ret = vma->vm_ops->fault(vma, &vmf);
> >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> >  		return ret;
> > -	if (!vmf.page)
> > -		goto out;
> 
> Removing the above sounds seriously bogus to me as it means that below
> if (unlikely(PageHWPoison(vmf.page))) could dereference a NULL pointer.

If you do not return a valid page, you must return appropriate return code
from the ->fault handler. That being VM_FAULT_NOPAGE, VM_FAULT_DAX_LOCKED,
or some error. That has always been the case except for DAX abuse which was
added by commit 2e4cdab0584f "mm: allow page fault handlers to perform the
COW" about an year ago. And my patch fixes this abuse.

I'm not aware of any other code that would start abusing the return value
from the ->fault handler. If some such code indeed got merged during the
last year, it should be fixed as well.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
