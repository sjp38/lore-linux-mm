Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABF0280251
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:32:53 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n3so8524638lfn.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 03:32:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l18si22028824lfi.388.2016.10.18.03.32.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 03:32:51 -0700 (PDT)
Date: Tue, 18 Oct 2016 12:32:48 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 10/20] mm: Move handling of COW faults into DAX code
Message-ID: <20161018103248.GO3359@quack2.suse.cz>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-11-git-send-email-jack@suse.cz>
 <20161017192949.GA21002@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017192949.GA21002@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon 17-10-16 13:29:49, Ross Zwisler wrote:
> On Tue, Sep 27, 2016 at 06:08:14PM +0200, Jan Kara wrote:
> > Move final handling of COW faults from generic code into DAX fault
> > handler. That way generic code doesn't have to be aware of peculiarities
> > of DAX locking so remove that knowledge.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/dax.c            | 22 ++++++++++++++++------
> >  include/linux/dax.h |  7 -------
> >  include/linux/mm.h  |  9 +--------
> >  mm/memory.c         | 14 ++++----------
> >  4 files changed, 21 insertions(+), 31 deletions(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index 0dc251ca77b8..b1c503930d1d 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -876,10 +876,15 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  			goto unlock_entry;
> >  		if (!radix_tree_exceptional_entry(entry)) {
> >  			vmf->page = entry;
> > -			return VM_FAULT_LOCKED;
> > +			if (unlikely(PageHWPoison(entry))) {
> > +				put_locked_mapping_entry(mapping, vmf->pgoff,
> > +							 entry);
> > +				return VM_FAULT_HWPOISON;
> > +			}
> >  		}
> > -		vmf->entry = entry;
> > -		return VM_FAULT_DAX_LOCKED;
> > +		error = finish_fault(vmf);
> > +		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
> > +		return error ? error : VM_FAULT_DONE_COW;
> >  	}
> >  
> >  	if (!buffer_mapped(&bh)) {
> > @@ -1430,10 +1435,15 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  			goto unlock_entry;
> >  		if (!radix_tree_exceptional_entry(entry)) {
> >  			vmf->page = entry;
> 
> In __do_fault() we explicitly clear vmf->page in the case where PageHWPoison()
> is set.  I think we can get the same behavior here by moving the call that
> sets vmf->page after the PageHWPoison() check.

Actually, the whole HWPoison checking was non-sensical for DAX. We want to
check for HWPoison to avoid reading from poisoned pages. However for DAX we
either use copy_user_dax() which takes care of IO errors / poisoning itself
or we use clear_user_highpage() which doesn't touch the source page. So we
don't have to check for HWPoison at all. Fixed.

> > -			return VM_FAULT_LOCKED;
> > +			if (unlikely(PageHWPoison(entry))) {
> > +				put_locked_mapping_entry(mapping, vmf->pgoff,
> > +							 entry);
> > +				return VM_FAULT_HWPOISON;
> > +			}
> >  		}
> > -		vmf->entry = entry;
> > -		return VM_FAULT_DAX_LOCKED;
> 
> I think we're missing a call to 
> 
> 	__SetPageUptodate(new_page);

> before finish_fault()?  This call currently lives in do_cow_fault(), and
> is part of the path that we don't skip as part of the VM_FAULT_DAX_LOCKED
> logic.

Ah, great catch. I wonder how the DAX COW test could have passed with this?
Maybe PageUptodate is not used much for anon pages... Anyway thanks for
spotting this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
