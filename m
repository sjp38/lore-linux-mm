Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5897C6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 11:19:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e190so34618118pfe.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:19:20 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id d68si9029630pfc.68.2016.04.19.08.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 08:19:19 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id fs9so7658480pac.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 08:19:19 -0700 (PDT)
Date: Tue, 19 Apr 2016 11:19:04 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 17/18] dax: Use radix tree entry lock to protect cow
 faults
Message-ID: <20160419151904.GA17318@gmail.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
 <1461015341-20153-18-git-send-email-jack@suse.cz>
 <20160419114609.GA13932@gmail.com>
 <20160419143343.GC22413@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160419143343.GC22413@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, Apr 19, 2016 at 04:33:43PM +0200, Jan Kara wrote:
> On Tue 19-04-16 07:46:09, Jerome Glisse wrote:
> > On Mon, Apr 18, 2016 at 11:35:40PM +0200, Jan Kara wrote:
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 93897f23cc11..f09cdb8d48fa 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -63,6 +63,7 @@
> > >  #include <linux/dma-debug.h>
> > >  #include <linux/debugfs.h>
> > >  #include <linux/userfaultfd_k.h>
> > > +#include <linux/dax.h>
> > >  
> > >  #include <asm/io.h>
> > >  #include <asm/mmu_context.h>
> > > @@ -2785,7 +2786,8 @@ oom:
> > >   */
> > >  static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> > >  			pgoff_t pgoff, unsigned int flags,
> > > -			struct page *cow_page, struct page **page)
> > > +			struct page *cow_page, struct page **page,
> > > +			void **entry)
> > >  {
> > >  	struct vm_fault vmf;
> > >  	int ret;
> > > @@ -2800,8 +2802,10 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
> > >  	ret = vma->vm_ops->fault(vma, &vmf);
> > >  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
> > >  		return ret;
> > > -	if (!vmf.page)
> > > -		goto out;
> > 
> > Removing the above sounds seriously bogus to me as it means that below
> > if (unlikely(PageHWPoison(vmf.page))) could dereference a NULL pointer.
> 
> If you do not return a valid page, you must return appropriate return code
> from the ->fault handler. That being VM_FAULT_NOPAGE, VM_FAULT_DAX_LOCKED,
> or some error. That has always been the case except for DAX abuse which was
> added by commit 2e4cdab0584f "mm: allow page fault handlers to perform the
> COW" about an year ago. And my patch fixes this abuse.
> 
> I'm not aware of any other code that would start abusing the return value
> from the ->fault handler. If some such code indeed got merged during the
> last year, it should be fixed as well.
> 

Ok my bad i missed that.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
