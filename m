Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9SGGfD8005335
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:16:41 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9SGGfk9513636
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 10:16:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9SGGfcv001914
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 10:16:41 -0600
Message-ID: <43624EE6.8000605@us.ibm.com>
Date: Fri, 28 Oct 2005 09:16:38 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <200510281303.56688.blaisorblade@yahoo.it>
In-Reply-To: <200510281303.56688.blaisorblade@yahoo.it>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Blaisorblade wrote:
> On Friday 28 October 2005 05:46, Jeff Dike wrote:
> 
>>On Wed, Oct 26, 2005 at 03:49:55PM -0700, Badari Pulavarty wrote:
>>
>>>Basically, I added "truncate_range" inode operation to provide
>>>opportunity for the filesystem to zero the blocks and/or free
>>>them up.
>>>
>>>I also attempted to implement shmem_truncate_range() which
>>>needs lots of testing before I work out bugs :(
>>
>>I added memory hotplug to UML to check this out.  It seems to be freeing
>>pages that are outside the desired range.  I'm doing the simplest possible
>>thing - grabbing a bunch of pages that are most likely not dirty yet,
>>and MADV_TRUNCATEing them one at a time.  Everything in UML goes harwire
>>after that, and the cases that I've looked at involve pages being suddenly
>>zero.
> 
> 
> Thanks for CC'ing me, Jeff.
> 
> I've just read the whole thread, and I'd thank you for this effort. I've also 
> found a couple of bugs I think (see below).
> 
> It seems you completely missed the purpose of vma->vm_pgoff.
> 
> Jeff, I think this is enough to explain the problem in UML. See below.
> 
> On the plan, however, I have a concern: VM_NONLINEAR.
> 
> For now it can be ok to leave madvise(REMOVE) unimplemented for that, but if 
> and when I'll get the time to finish the remap_file_pages changes* for UML to 
> use it, UML will _require_ this to be implemented too.
> 
> However, looking at the patch, the implementation would boil down to something 
> like
> 
> for each page in range {
> 	start = page->index;
> 	end = start + PAGE_SIZE;
> 	call truncate_inode_pages_range(mapping, offset, end);
> 	inode->i_op->truncate_range(inode, offset, end);
> }
> 
> unmap_mapping_range() should be done at once for the whole range.
> 

patch does

for all the pages in the given vma {
	unmap_mapping_range(mapping, offset, end);
	truncate_inode_pages_range(mapping, offset, end);
	inode->op->truncate_range(inode, offset, end)
}

It operates on bunch of pages in the given VMA. Since UML has
one page for VMA, it operates on one page at a time - do you
see anything wrong here ?

> While looking at these, here's what I'd call "strange" in the patch:
> 
> Also, why is unmap_mapping_range done with the inode semaphore held? I don't 
> remember locking rule but conceptually this has no point, IMHO.

I am not sure either, let me look at it. (I thought we should hold it
for truncate()).

> Btw, why I don't see vm_pgoff mentioned in these lines of the patch (nor 
> anywhere else in the patch)?

vm_pgoff - don't remember what that supposed to represent...


> You call truncate_inode_pages_range(mapping, offset, endoff), so I think 
> you're really burned here.
> 
> +offset = (loff_t)(start - vma->vm_start);
> +endoff = (loff_t)(end - vma->vm_start);

"end" here is not end of VMA - its end of the region we want to discard
(in UML case its start + PAGE_SIZE). Anything wrong ?
> 
> * UML uses mmap()/munmap()/mprotect() to implement the virtual "hardware MMU", 
> which means we have one vma per page usually and that we can call hundred of 
> unmaps on process exit. Ingo Molnar implemented time ago remap_file_pages() 
> prot support (see around 2.6.4/2.6.5 -mm trees) and I recovered and completed 
> it (and posted for review) during last summer.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
