Date: Sat, 19 May 2007 03:46:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070519014623.GF15569@wotan.suse.de>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 08:23:53AM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
> >
> > From: Nick Piggin <npiggin@suse.de>
> > 
> > Remove ->nopfn and reimplement the existing handlers with ->fault
> 
> So this is why you kept address.

Ah yeah..

 
> No no no.
> 
> If we are changing the calling semantics of "nopage", then we should also 
> remove the horrible, horrible hack of making the "nopfn" function itself 
> do the "populate the page tables".

Hey, just now you wanted me to pass down a bloody pte_t! :)


> It would be *much* better to just
> 
> > +static struct page *spufs_mem_mmap_fault(struct vm_area_struct *vma,
> > +					  struct fault_data *fdata)
> >  {
> >  	struct spu_context *ctx	= vma->vm_file->private_data;
> >  	unsigned long pfn, offset, addr0 = address;
> > @@ -137,9 +137,11 @@ static unsigned long spufs_mem_mmap_nopf
> >  	}
> >  #endif /* CONFIG_SPU_FS_64K_LS */
> >  
> > -	offset = (address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
> > -	if (offset >= LS_SIZE)
> > -		return NOPFN_SIGBUS;
> > +	offset = fdata->pgoff << PAGE_SHIFT
> > +	if (offset >= LS_SIZE) {
> > +		fdata->type = VM_FAULT_SIGBUS;
> > +		return NULL;
> > +	}
> 
> 	if (offset >= LS_SIZE)
> 		return -EINVAL; /* or whatever error value */
> 
> and *remove* the "vm_insert_pfn":
> 
> > -	vm_insert_pfn(vma, address, pfn);
> > +	vm_insert_pfn(vma, fdata->address, pfn);
> >  
> >  	spu_release(ctx);
> >  
> > -	return NOPFN_REFAULT;
> > +	fdata->type = VM_FAULT_MINOR;
> > +	return NULL;
> >  }
> 
> And instead on success do
> 
> 	fdata->pfn = pfn;
> 	/* Or: 'fdata->pte = pte' */
> 	return VM_FAULT_MINOR;
> 
> and let the caller always insert the thing into the page tables.
> 
> Wouldn't it be nice if we never had drivers etc modifying page tables 
> directly? Even with helpers like "vm_insert_pfn()"?

Yeah it would be logically nicer, but it puts more code and branches
in the ->fault fastpaths, which I was trying to  avoid.

However, if you are willing to make that small tradeoff, and we have
handlers signal back to the caller that they are returning a pfn, then
OK.

But I don't think this is nearly so bad a violation than filesystems
doing ->populate or calculating their own pgoff. The reason? If the
driver is messing with pfns itself, then it already knows about some
aspect of memory management internals. At that point, I think it is
clean enough to have it call the vm_insert_pfn helper.


> And once you don't return "struct page *", the return values can be a lot 
> more descriptive too.

That I agree with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
