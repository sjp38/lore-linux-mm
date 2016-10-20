Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3C16B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 04:48:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so26654895lfn.5
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 01:48:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jn10si52304038wjb.274.2016.10.20.01.48.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 01:48:48 -0700 (PDT)
Date: Thu, 20 Oct 2016 10:48:45 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 16/20] mm: Provide helper for finishing mkwrite faults
Message-ID: <20161020084845.GA22614@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-17-git-send-email-jack@suse.cz>
 <20161018183525.GC7796@linux.intel.com>
 <20161019071600.GG29967@quack2.suse.cz>
 <20161019172152.GC22463@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019172152.GC22463@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 19-10-16 11:21:52, Ross Zwisler wrote:
> On Wed, Oct 19, 2016 at 09:16:00AM +0200, Jan Kara wrote:
> > > > @@ -2315,26 +2335,17 @@ static int wp_page_shared(struct vm_fault *vmf)
> > > >  			put_page(vmf->page);
> > > >  			return tmp;
> > > >  		}
> > > > -		/*
> > > > -		 * Since we dropped the lock we need to revalidate
> > > > -		 * the PTE as someone else may have changed it.  If
> > > > -		 * they did, we just return, as we can count on the
> > > > -		 * MMU to tell us if they didn't also make it writable.
> > > > -		 */
> > > > -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> > > > -						vmf->address, &vmf->ptl);
> > > > -		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
> > > > +		tmp = finish_mkwrite_fault(vmf);
> > > > +		if (unlikely(!tmp || (tmp &
> > > > +				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> > > 
> > > The 'tmp' return from finish_mkwrite_fault() can only be 0 or VM_FAULT_WRITE.
> > > I think this test should just be 
> > > 
> > > 		if (unlikely(!tmp)) {
> > 
> > Right, finish_mkwrite_fault() cannot currently throw other errors than
> > "retry needed" which is indicated by tmp == 0. However I'd prefer to keep
> > symmetry with finish_fault() handler which can throw other errors and
> > better be prepared to handle them from finish_mkwrite_fault() as well.
> 
> Fair enough.  You can add:
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Thanks. Actually, your question made me have a harder look at return values
from finish_mkwrite_fault() and I've added one more commit switching the
return values so that finish_mkwrite_fault() returns 0 on success and
VM_FAULT_NOPAGE if PTE changed. That is less confusing and even more
consistent with what finish_fault() returns.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
