Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9SIv25E016443
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 14:57:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9SIw2Ef535918
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:58:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9SIv1BO005590
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:57:02 -0600
Message-ID: <4362747A.5060700@us.ibm.com>
Date: Fri, 28 Oct 2005 11:56:58 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <1130366995.23729.38.camel@localhost.localdomain> <200510281303.56688.blaisorblade@yahoo.it> <43624EE6.8000605@us.ibm.com> <200510282040.29856.blaisorblade@yahoo.it>
In-Reply-To: <200510282040.29856.blaisorblade@yahoo.it>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Blaisorblade wrote:

> On Friday 28 October 2005 18:16, Badari Pulavarty wrote:
> 
>>Blaisorblade wrote:
>>
>>>On Friday 28 October 2005 05:46, Jeff Dike wrote:
>>>
>>>>On Wed, Oct 26, 2005 at 03:49:55PM -0700, Badari Pulavarty wrote:
> 
> 
>>>On the plan, however, I have a concern: VM_NONLINEAR.
> 
> 
>>>However, looking at the patch, the implementation would boil down to
>>>something like
>>>
>>>for each page in range {
>>>	start = page->index;
>>>	end = start + PAGE_SIZE;
>>>	call truncate_inode_pages_range(mapping, offset, end);
>>>	inode->i_op->truncate_range(inode, offset, end);
>>>}
>>>
>>>unmap_mapping_range() should be done at once for the whole range.
>>
>>patch does
>>
>>for all the pages in the given vma {
>>	unmap_mapping_range(mapping, offset, end);
>>	truncate_inode_pages_range(mapping, offset, end);
>>	inode->op->truncate_range(inode, offset, end)
>>}
> 
> 
>>It operates on bunch of pages in the given VMA. Since UML has
>>one page for VMA, it operates on one page at a time - do you
>>see anything wrong here ?
> 
> 
> My point was the support to VM_NONLINEAR. In the future, UML will have one big 
> VMA, but different pages will be remapped with different offsets (already in 
> mainline) and different protections (I have patches, I sent an earlier 
> version, still revising).
> 
> In that case, you could really truncate (in one single call) pages which are 
> one at the start of the file and one at the end. That's why with VM_NONLINEAR 
> it wouldn't work.
> 
> However, Jeff made me note that we'd probably call madvise() on the linear 
> kernel mapping (the kernel maps pages from the RAM file all at once, 
> linearly). So you can safely just refuse operating on VM_NONLINEAR vmas.
> 
> 
>>>While looking at these, here's what I'd call "strange" in the patch:
> 
> 
>>>Also, why is unmap_mapping_range done with the inode semaphore held? I
>>>don't remember locking rule but conceptually this has no point, IMHO.
> 
> 
>>I am not sure either, let me look at it. (I thought we should hold it
>>for truncate()).
> 
> 
> Ok, do_truncate() uses the semaphore around the whole ops, because it's 
> implemented in a radically different way (through notify_change()).
> 
> We don't need IMHO to do things that way; we don't even change i_size - not 
> even when at the end of the file, as we don't want SIGBUS.
> 
> And anyway FS's must already handle holes at the end of a file.
> 
> Btw, when truncating, notify_change does:
> 
>         if (ia_valid & ATTR_SIZE)
>                 down_write(&dentry->d_inode->i_alloc_sem);
> 
> (which I suppose is used to protect against concurrent file extensions - page 
> allocations in previous holes - and such). You should probably take that too 
> (nest it inside mapping->host->i_sem).
> 
> Also, vmtruncate is called with the semaphore held because it must call 
> truncate_inode_pages(), and because even the calls to i_size_write() must be 
> atomic with the rest. But other than that, there's no reason. Especially, 
> unmap_mapping_range() does purely pagetable operations.
> 
> 
>>>Btw, why I don't see vm_pgoff mentioned in these lines of the patch (nor
>>>anywhere else in the patch)?
> 
> 
>>vm_pgoff - don't remember what that supposed to represent...
> 
> 
> Call mmap() with non-0 pgoff (i.e. offset in the file), say the second file 
> page. You're gonna store the pgoff parameter in vma->vm_pgoff (in PAGE_SHIFT 
> units).
> 
> If I then request you to truncate the first page in the VMA, how does your 
> code realize that it should punch the second page rather than the first?
> 
> However, Jeff said this _isn't_ the bug he's hitting - in his case the VMA has 
> a 0 initial offset (for the same reason we don't need VM_NONLINEAR support).
> 
> 
>>>You call truncate_inode_pages_range(mapping, offset, endoff), so I think
>>>you're really burned here.
> 
> 
>>>+offset = (loff_t)(start - vma->vm_start);
>>>+endoff = (loff_t)(end - vma->vm_start);
> 
> 
> So they would become:
> 
> offset = (loff_t)(start - vma->vm_start) + vma->vm_pgoff << PAGE_SHIFT; 
> 
> or with page_offset(). Btw, shouldn't this be done by some macro in 
> <linux/pagemap.h>, as page_offset() and linear_page_index()?
> 
> Btw, also compare with mm/rmap.c:vma_address()/page_address_in_vma().
> 
> 
>>"end" here is not end of VMA - its end of the region we want to discard
>>(in UML case its start + PAGE_SIZE). Anything wrong ?
> 
> 
> All ok for that, I was complaining about not using ->vm_pgoff.
> 
> I had the doubt that vm_pgoff entered the picture later, but I'm sure 
> truncate_inode_pages{_range} wants file offsets, so it wasn't something I was 
> missing.

Thank you for your comments. I need sometime to digest all these,
make changes and debug the current problem. For now, I am going
to restrict/ignore VM_NONLINEAR case.

I will get back to you on Monday.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
