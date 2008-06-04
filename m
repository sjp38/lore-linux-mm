From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: faulting kmalloced buffers into userspace through mmap()
Date: Wed, 4 Jun 2008 21:00:39 +1000
References: <4842B4C3.1070506@brontes3d.com> <87mym4tmz0.fsf@saeurebad.de> <484662E3.40902@brontes3d.com>
In-Reply-To: <484662E3.40902@brontes3d.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806042100.39345.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: Johannes Weiner <hannes@saeurebad.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 04 June 2008 19:39, Daniel Drake wrote:
> Hi Johannes,
>
> Johannes Weiner wrote:
> > You broke the abstraction here.  There are no pages from kmalloc(), it
> > gives you other memory objects.  And on munmapping the region, the
> > kmalloc objects are passed back to the buddy allocator which then blows
> > the whistle with bad_page() on it.
>
> Thanks for the explanation, I attempted to document this here:
> http://linux-mm.org/DeviceDriverMmap
> Comments/edits are welcome!

You can map it with a pfn mapping / vm_insert_pfn / remap_pfn_range etc.
which does not touch the underlying struct pages. You must then ensure
you deallocate the memory yourself after it is finished with.


> One more quick question: if pages that were mapped are "passed back to
> the buddy allocator" during munmap() does that mean that the pages get
> freed too?

They get their refcount decremented if they were inserted with
vm_insert_page or ->fault page fault handler.


> i.e. if I allocate some pages with alloc_pages(), remap them into
> userspace in my VM .fault handler, and then userspace munmaps them, is
> it still legal for my driver to use those pages internally after the
> munmap? Do I still need to call __free_pages() on them when done?

Provided you increment the refcount on the pages in your fault
handler, munmap will not free them, and it is still legal for
your driver to touch them (and must free them itself).


> Also, it is possible to get the physical address of a kmalloc region
> with virt_to_phys(). Is it also illegal to pass this physical address to
> remap_pfn_range() to implement mmap in that fashion? Can't find any
> in-kernel code that does this, but google brings up a few hits such as
> http://www.opentech.at/papers/embedded_resources/node21.html

I think (__pa(address) >> PAGE_SIZE) should get you the pfn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
