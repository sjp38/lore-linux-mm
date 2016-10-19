Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 862546B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:16:05 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so10062186wme.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:16:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 185si3194553wmc.63.2016.10.19.00.16.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 00:16:03 -0700 (PDT)
Date: Wed, 19 Oct 2016 09:16:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 16/20] mm: Provide helper for finishing mkwrite faults
Message-ID: <20161019071600.GG29967@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-17-git-send-email-jack@suse.cz>
 <20161018183525.GC7796@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018183525.GC7796@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue 18-10-16 12:35:25, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:20PM +0200, Jan Kara wrote:
> > Provide a helper function for finishing write faults due to PTE being
> > read-only. The helper will be used by DAX to avoid the need of
> > complicating generic MM code with DAX locking specifics.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  include/linux/mm.h |  1 +
> >  mm/memory.c        | 65 +++++++++++++++++++++++++++++++-----------------------
> >  2 files changed, 39 insertions(+), 27 deletions(-)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 1055f2ece80d..e5a014be8932 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -617,6 +617,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
> >  int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
> >  		struct page *page);
> >  int finish_fault(struct vm_fault *vmf);
> > +int finish_mkwrite_fault(struct vm_fault *vmf);
> >  #endif
> >  
> >  /*
> > diff --git a/mm/memory.c b/mm/memory.c
> > index f49e736d6a36..8c8cb7f2133e 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2266,6 +2266,36 @@ oom:
> >  	return VM_FAULT_OOM;
> >  }
> >  
> > +/**
> > + * finish_mkrite_fault - finish page fault making PTE writeable once the page
>       finish_mkwrite_fault

Fixed, thanks.

> > @@ -2315,26 +2335,17 @@ static int wp_page_shared(struct vm_fault *vmf)
> >  			put_page(vmf->page);
> >  			return tmp;
> >  		}
> > -		/*
> > -		 * Since we dropped the lock we need to revalidate
> > -		 * the PTE as someone else may have changed it.  If
> > -		 * they did, we just return, as we can count on the
> > -		 * MMU to tell us if they didn't also make it writable.
> > -		 */
> > -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> > -						vmf->address, &vmf->ptl);
> > -		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
> > +		tmp = finish_mkwrite_fault(vmf);
> > +		if (unlikely(!tmp || (tmp &
> > +				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> 
> The 'tmp' return from finish_mkwrite_fault() can only be 0 or VM_FAULT_WRITE.
> I think this test should just be 
> 
> 		if (unlikely(!tmp)) {

Right, finish_mkwrite_fault() cannot currently throw other errors than
"retry needed" which is indicated by tmp == 0. However I'd prefer to keep
symmetry with finish_fault() handler which can throw other errors and
better be prepared to handle them from finish_mkwrite_fault() as well.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
