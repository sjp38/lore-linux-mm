Date: Tue, 19 Dec 2006 11:35:02 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: mmap abuse in ehca, was Re: [PATCH] ehca: fix do_mmap() error check
Message-ID: <20061219113502.GA1416@infradead.org>
References: <20061219084357.GG4049@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061219084357.GG4049@APFDCB5C>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>, Christoph Raisch <raisch@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Index: 2.6-mm/drivers/infiniband/hw/ehca/ehca_uverbs.c
> ===================================================================
> --- 2.6-mm.orig/drivers/infiniband/hw/ehca/ehca_uverbs.c
> +++ 2.6-mm/drivers/infiniband/hw/ehca/ehca_uverbs.c
> @@ -321,14 +321,14 @@ int ehca_mmap_nopage(u64 foffset, u64 le
>  		     struct vm_area_struct **vma)
>  {
>  	down_write(&current->mm->mmap_sem);
> -	*mapped = (void*)do_mmap(NULL,0, length, PROT_WRITE,
> +	*mapped = (void*)do_mmap(NULL, 0, length, PROT_WRITE,
>  				 MAP_SHARED | MAP_ANONYMOUS,
>  				 foffset);
>  	up_write(&current->mm->mmap_sem);
> -	if (!(*mapped)) {
> +	if (IS_ERR(*mapped)) {
>  		ehca_gen_err("couldn't mmap foffset=%lx length=%lx",
>  			     foffset, length);
> -		return -EINVAL;
> +		return PTR_ERR(*mmaped);

Folks, could you explain what this code is actually trying to do.
Just to quote it in a little more detail the code looks like this:

int ehca_mmap_nopage(u64 foffset, u64 length, void **mapped,
                     struct vm_area_struct **vma)
{
	down_write(&current->mm->mmap_sem);
	*mapped = (void*)do_mmap(NULL,0, length, PROT_WRITE,
			         MAP_SHARED | MAP_ANONYMOUS,
				 foffset);
	up_write(&current->mm->mmap_sem);
	
	if (!(*mapped)) {
		ehca_gen_err("couldn't mmap foffset=%lx length=%lx",
			     foffset, length);
		return -EINVAL;
	}
G
	*vma = find_vma(current->mm, (u64)*mapped);
	if (!(*vma)) {
		down_write(&current->mm->mmap_sem);
		do_munmap(current->mm, 0, length);
		up_write(&current->mm->mmap_sem);
		ehca_gen_err("couldn't find vma queue=%p", *mapped);
		return -EINVAL;
	}

	(*vma)->vm_flags |= VM_RESERVED;
	(*vma)->vm_ops = &ehcau_vm_ops;

	return 0;
}

the worst caller then continues as:

int ehca_mmap_register(u64 physical, void **mapped,
                       struct vm_area_struct **vma)
{
	int ret;
	unsigned long vsize;
	/* ehca hw supports only 4k page */
	ret = ehca_mmap_nopage(0, EHCA_PAGESIZE, mapped, vma);

	(*vma)->vm_flags |= VM_RESERVED;
	vsize = (*vma)->vm_end - (*vma)->vm_start;
	if (vsize != EHCA_PAGESIZE) {
		ehca_gen_err("invalid vsize=%lx",
			     (*vma)->vm_end - (*vma)->vm_start);
		return -EINVAL;
	}

	(*vma)->vm_page_prot = pgprot_noncached((*vma)->vm_page_prot);
	(*vma)->vm_flags |= VM_IO | VM_RESERVED;

	ret = remap_pfn_range((*vma), (*vma)->vm_start,
			      physical >> PAGE_SHIFT,
			      vsize,
			      (*vma)->vm_page_prot);

Aside from the very questionably naming of ehca_mmap_nopage this maps
anonymous shared memory into a random location in the calling process
from something that is not defined to change the callers address space,
then racy looks up the vma for it and sets the VM_RESERVED flags and
vm ops on this anonoymous vma.  Not enough ehca_mmap_register then does
a remap_pfn_range into that anonymous vma.  This is definitly not
how the mmap infrastructure should be used.

I'd go as far as saying do_mmap(_pgoff) should not be exported at all,
but we'd need to fix similar braindamage in drm first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
