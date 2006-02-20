Subject: VM_PFNMAP and do_no_pfn handler
From: Jes Sorensen <jes@sgi.com>
Date: 20 Feb 2006 09:20:50 -0500
Message-ID: <yq0y806qfgd.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@osdl.org>, Carsten Otte <cotte@de.ibm.com>, roe@sgi.com, Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

I am looking at implementing a do_no_pfn handler similar to
do_no_page, but for pages which are not backed by a struct page. I'd
like to use it for the mspec driver which maps uncached pages to
userland. The reason we need the do_no_pfn handler is to get the first
touch locality of the mapping on NUMA systems.

I have it all working, however I have a question about the VM_PFNMAP
flag. Right now mm/memory.c claims the following above
vm_normal_page():

 * NOTE! Some mappings do not have "struct pages". A raw PFN mapping
 * will have each page table entry just pointing to a raw page frame
 * number, and as far as the VM layer is concerned, those do not have
 * pages associated with them - even if the PFN might point to memory
 * that otherwise is perfectly fine and has a "struct page".
 *
 * The way we recognize those mappings is through the rules set up
 * by "remap_pfn_range()": the vma will have the VM_PFNMAP bit set,
 * and the vm_pgoff will point to the first PFN mapped: thus every
 * page that is a raw mapping will always honor the rule
 *
 *      pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)

vm_normal_page() then does this:

        if (vma->vm_flags & VM_PFNMAP) {
                unsigned long off = (addr - vma->vm_start) >> PAGE_SHIFT;
                if (pfn == vma->vm_pgoff + off)
                        return NULL;
                if (!is_cow_mapping(vma->vm_flags))
                        return NULL;
        }

Everywhere else it is stated that the VM_PFNMAP flag is only set for
pages without a struct page backing it. In other words, are there any
cases where the above requirement is really needed? Wouldn't it be
sufficient to simply return NULL in vm_normal_page() if VM_PFNMAP is
set?

The problem I have is that it the uncached pages in the mspec driver
aren't physically contiguous and the above rule doesn't match for
us. Right now we are safe since the mspec driver doesn't allow cow
mappings, but I fear that something could change in vm_normal_page()
that would make the behavior change underneath us. Alternatively one
could add yet another flag for this, but it seems somewhat overkill
for something which is so similar in behavior?

Any suggestions? (or rather, what obvious thing did I miss? ;-)

Thanks,
Jes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
