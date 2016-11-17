Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57D386B031D
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 04:36:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so43981482wms.7
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 01:36:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l6si1422609wje.169.2016.11.17.01.36.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 01:36:53 -0800 (PST)
Date: Thu, 17 Nov 2016 10:36:52 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 10/21] mm: Move handling of COW faults into DAX code
Message-ID: <20161117093652.GS21785@quack2.suse.cz>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-11-git-send-email-jack@suse.cz>
 <20161116212820.GE31337@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161116212820.GE31337@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed 16-11-16 14:28:20, Ross Zwisler wrote:
> On Fri, Nov 04, 2016 at 05:25:06AM +0100, Jan Kara wrote:
> > Move final handling of COW faults from generic code into DAX fault
> > handler. That way generic code doesn't have to be aware of peculiarities
> > of DAX locking so remove that knowledge and make locking functions
> > private to fs/dax.c.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> 
> > @@ -1006,13 +1007,14 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  
> >  		if (error)
> >  			goto finish_iomap;
> > -		if (!radix_tree_exceptional_entry(entry)) {
> > +
> > +		__SetPageUptodate(vmf->cow_page);
> > +		if (!radix_tree_exceptional_entry(entry))
> >  			vmf->page = entry;
> 
> I don't think we need to set vmf->page anymore.  We would clear it to NULL in
> a few lines anyway, and the only call in between is finish_fault(), which
> only cares about vmf->cow_page().  This allows us to remove the vmf->page =
> NULL line a few lines below as well.

Well, I would not like to depend too much on which fields of vm_fault
finish_fault() actually uses - we should fill in as much as we have
available. But the truth is we sometime have page to fill in into vmf->page
and sometimes we don't so in this case I agree filling it in is pointless.
Changed.

> > @@ -1051,7 +1053,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
> >  		}
> >  	}
> >   unlock_entry:
> > -	if (!locked_status || error)
> > +	if (vmf_ret != VM_FAULT_LOCKED || error)
> >  		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
> 
> I don't think this is quite right.  For example, for dax_load_hole(), if we
> can't get a page we put_locked_mapping_entry() and return VM_FAULT_OOM.
> Previously this logic would have skipped the second call to
> put_locked_mapping_entry(), but now with the strict check against
> VM_FAULT_LOCKED put the entry twice.
> 
> Maybe the right thing to do is just fix dax_load_hole() so it never calls
> put_locked_mapping_entry(), and leave this check as you have it?

Yeah, good catch. Actually I have follow up patches which somewhat clean up
dax_iomap_fault() so that page fault is fully completed within
dax_iomap_fault() even when instantiating a hole page which makes error
handling simpler. But I didn't want to complicate this series with it. So
for now I'll do what you suggest. Thanks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
