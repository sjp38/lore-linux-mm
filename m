Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id kBK8aPCA062976
	for <linux-mm@kvack.org>; Wed, 20 Dec 2006 08:36:25 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBK8aPSI2789376
	for <linux-mm@kvack.org>; Wed, 20 Dec 2006 09:36:25 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBK8aPKG022797
	for <linux-mm@kvack.org>; Wed, 20 Dec 2006 09:36:25 +0100
In-Reply-To: <20061219113502.GA1416@infradead.org>
Subject: Re: do we have mmap abuse in ehca ?, was Re:  mmap abuse in ehca
Message-ID: <OF78487656.FBBD715F-ONC125724A.00287BE6-C125724A.002F4756@de.ibm.com>
From: Christoph Raisch <RAISCH@de.ibm.com>
Date: Wed, 20 Dec 2006 09:36:23 +0100
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

let me first try to show what functionality we need...
The ehca userspace driver needs 2 types of kernel/hw memory mapped into
userspace,

1) 4k pages provided by HW, one per queue, mostly used for signalling
   from userspace to hardware that new send/receive/poll queue entries are
   available. In kernel that's the typical candidate for ioremap.
   For these areas we use ehca_mmap_register to do the actual mapping into
   a mm
2) the actual queue memory itself, which has been allocated by
   get_zeroed_page(GPF_KERNEL). These pages need to be written by userspace
and
   read by the ehca, or the other way around
   For these areas we use ehca_mmap_nopage to do the mapping into
   a mm



let me try to explain what we thought this code should do....

Christoph Hellwig wrote on 19.12.2006 12:35:02:
>
> Folks, could you explain what this code is actually trying to do.
> Just to quote it in a little more detail the code looks like this:
>
> int ehca_mmap_nopage(u64 foffset, u64 length, void **mapped,
>                      struct vm_area_struct **vma)
> {
this is what a anonymous mapping request from userspace would do.
We didn't want to reimplement the complete mmap code in a driver
>    down_write(&current->mm->mmap_sem);
>    *mapped = (void*)do_mmap(NULL,0, length, PROT_WRITE,
>                   MAP_SHARED | MAP_ANONYMOUS,
>              foffset);
>    up_write(&current->mm->mmap_sem);
>
>    if (!(*mapped)) {
>       ehca_gen_err("couldn't mmap foffset=%lx length=%lx",
>               foffset, length);
>       return -EINVAL;
>    }
>
unfortunately you don't get back a vma ...
...but you need the vma for installing nopage handlers
therefore:
>    *vma = find_vma(current->mm, (u64)*mapped);
>    if (!(*vma)) {
>       down_write(&current->mm->mmap_sem);
>       do_munmap(current->mm, 0, length);
>       up_write(&current->mm->mmap_sem);
>       ehca_gen_err("couldn't find vma queue=%p", *mapped);
>       return -EINVAL;
>    }
>
...that should be straight forward file mmap code
The memory we're using shouldn't be handled by copy on write,
should not be swapped, its used by DMA from the hardware.
And it shouldn't get merged
In case of a fork we would like to get a pagefault in the new process if
he accesses this queue and a unchanged forking process.
Is VM_RESERVED ok for that type of vma?
>    (*vma)->vm_flags |= VM_RESERVED;
>    (*vma)->vm_ops = &ehcau_vm_ops;
>
>    return 0;
> }
>
> the worst caller then continues as:
>
> int ehca_mmap_register(u64 physical, void **mapped,
>                        struct vm_area_struct **vma)
> {
>    int ret;
>    unsigned long vsize;
>    /* ehca hw supports only 4k page */
>    ret = ehca_mmap_nopage(0, EHCA_PAGESIZE, mapped, vma);
>
>    (*vma)->vm_flags |= VM_RESERVED;
>    vsize = (*vma)->vm_end - (*vma)->vm_start;
>    if (vsize != EHCA_PAGESIZE) {
>       ehca_gen_err("invalid vsize=%lx",
>               (*vma)->vm_end - (*vma)->vm_start);
>       return -EINVAL;
>    }
>
>    (*vma)->vm_page_prot = pgprot_noncached((*vma)->vm_page_prot);
>    (*vma)->vm_flags |= VM_IO | VM_RESERVED;
>
>    ret = remap_pfn_range((*vma), (*vma)->vm_start,
>                physical >> PAGE_SHIFT,
>                vsize,
>                (*vma)->vm_page_prot);
>
> Aside from the very questionably naming of ehca_mmap_nopage this maps
> anonymous shared memory into a random location in the calling process
> from something that is not defined to change the callers address space,

these mappings occur exactly when the user calls create_qp and create_cq,
an ib user actually "wants" to have these queues in its adress space.
We though that the closest we could get to a mmap(NULL,...) from userspace.

> then racy looks up the vma for it and sets the VM_RESERVED flags and
> vm ops on this anonoymous vma.
could you explain where the race comes in?
How would that be different from a user calling mmap?

> Not enough ehca_mmap_register then does
> a remap_pfn_range into that anonymous vma.
We want to map bus adresses into userspace in this case...
...just as mmap from userspace... ?

> This is definitly not
> how the mmap infrastructure should be used.
>
> I'd go as far as saying do_mmap(_pgoff) should not be exported at all,
> but we'd need to fix similar braindamage in drm first.
Maybe we shouldn't have looked at that driver how to use mmap
within the kernel while examining HOW to implement what we needed.
What other methods would you suggest?
Is there already a "proper" usage pattern for what we need in the
kernel?

Christoph Raisch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
