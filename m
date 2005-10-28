From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Fri, 28 Oct 2005 13:03:56 +0200
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org>
In-Reply-To: <20051028034616.GA14511@ccure.user-mode-linux.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510281303.56688.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 28 October 2005 05:46, Jeff Dike wrote:
> On Wed, Oct 26, 2005 at 03:49:55PM -0700, Badari Pulavarty wrote:
> > Basically, I added "truncate_range" inode operation to provide
> > opportunity for the filesystem to zero the blocks and/or free
> > them up.
> >
> > I also attempted to implement shmem_truncate_range() which
> > needs lots of testing before I work out bugs :(
>
> I added memory hotplug to UML to check this out.  It seems to be freeing
> pages that are outside the desired range.  I'm doing the simplest possible
> thing - grabbing a bunch of pages that are most likely not dirty yet,
> and MADV_TRUNCATEing them one at a time.  Everything in UML goes harwire
> after that, and the cases that I've looked at involve pages being suddenly
> zero.

Thanks for CC'ing me, Jeff.

I've just read the whole thread, and I'd thank you for this effort. I've also 
found a couple of bugs I think (see below).

It seems you completely missed the purpose of vma->vm_pgoff.

Jeff, I think this is enough to explain the problem in UML. See below.

On the plan, however, I have a concern: VM_NONLINEAR.

For now it can be ok to leave madvise(REMOVE) unimplemented for that, but if 
and when I'll get the time to finish the remap_file_pages changes* for UML to 
use it, UML will _require_ this to be implemented too.

However, looking at the patch, the implementation would boil down to something 
like

for each page in range {
	start = page->index;
	end = start + PAGE_SIZE;
	call truncate_inode_pages_range(mapping, offset, end);
	inode->i_op->truncate_range(inode, offset, end);
}

unmap_mapping_range() should be done at once for the whole range.

While looking at these, here's what I'd call "strange" in the patch:

Also, why is unmap_mapping_range done with the inode semaphore held? I don't 
remember locking rule but conceptually this has no point, IMHO.

Btw, why I don't see vm_pgoff mentioned in these lines of the patch (nor 
anywhere else in the patch)?

You call truncate_inode_pages_range(mapping, offset, endoff), so I think 
you're really burned here.

+offset = (loff_t)(start - vma->vm_start);
+endoff = (loff_t)(end - vma->vm_start);

* UML uses mmap()/munmap()/mprotect() to implement the virtual "hardware MMU", 
which means we have one vma per page usually and that we can call hundred of 
unmaps on process exit. Ingo Molnar implemented time ago remap_file_pages() 
prot support (see around 2.6.4/2.6.5 -mm trees) and I recovered and completed 
it (and posted for review) during last summer.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
