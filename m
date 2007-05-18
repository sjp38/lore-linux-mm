Date: Fri, 18 May 2007 08:23:53 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
In-Reply-To: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
Message-ID: <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


On Fri, 18 May 2007, akpm@linux-foundation.org wrote:
>
> From: Nick Piggin <npiggin@suse.de>
> 
> Remove ->nopfn and reimplement the existing handlers with ->fault

So this is why you kept address.

No no no.

If we are changing the calling semantics of "nopage", then we should also 
remove the horrible, horrible hack of making the "nopfn" function itself 
do the "populate the page tables".

It would be *much* better to just

> +static struct page *spufs_mem_mmap_fault(struct vm_area_struct *vma,
> +					  struct fault_data *fdata)
>  {
>  	struct spu_context *ctx	= vma->vm_file->private_data;
>  	unsigned long pfn, offset, addr0 = address;
> @@ -137,9 +137,11 @@ static unsigned long spufs_mem_mmap_nopf
>  	}
>  #endif /* CONFIG_SPU_FS_64K_LS */
>  
> -	offset = (address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
> -	if (offset >= LS_SIZE)
> -		return NOPFN_SIGBUS;
> +	offset = fdata->pgoff << PAGE_SHIFT
> +	if (offset >= LS_SIZE) {
> +		fdata->type = VM_FAULT_SIGBUS;
> +		return NULL;
> +	}

	if (offset >= LS_SIZE)
		return -EINVAL; /* or whatever error value */

and *remove* the "vm_insert_pfn":

> -	vm_insert_pfn(vma, address, pfn);
> +	vm_insert_pfn(vma, fdata->address, pfn);
>  
>  	spu_release(ctx);
>  
> -	return NOPFN_REFAULT;
> +	fdata->type = VM_FAULT_MINOR;
> +	return NULL;
>  }

And instead on success do

	fdata->pfn = pfn;
	/* Or: 'fdata->pte = pte' */
	return VM_FAULT_MINOR;

and let the caller always insert the thing into the page tables.

Wouldn't it be nice if we never had drivers etc modifying page tables 
directly? Even with helpers like "vm_insert_pfn()"?

And once you don't return "struct page *", the return values can be a lot 
more descriptive too.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
