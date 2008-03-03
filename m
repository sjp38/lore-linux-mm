Date: Mon, 3 Mar 2008 06:29:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
Message-ID: <20080303052959.GB32555@wotan.suse.de>
References: <20080118045649.334391000@suse.de> <20080118045755.735923000@suse.de> <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 01, 2008 at 12:14:35AM -0800, Jared Hulbert wrote:
> >  (The kaddr->pfn conversion may not be quite right for all architectures or XIP
> >  memory mappings, and the cacheflushing may need to be added for some archs).
> >
> >  This scheme has been tested and works for Jared's work-in-progress filesystem,
> 
> Opps.  I screwed up testing this.  It doesn't work with MTD devices and ARM....
> 
> The problem is that virt_to_phys() gives bogus answer for a
> mtd->point()'ed address.  It's a ioremap()'ed address which doesn't
> work with the ARM virt_to_phys().  I can get a physical address from
> mtd->point() with a patch I dropped a little while back.

Yeah, I thought that virt_to_phys was going to be problematic...

 
> So I was thinking how about instead of:
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> void * get_xip_address(struct address_space *mapping, pgoff_t pgoff,
> int create);
> 
> xip_mem = mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0);
> pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
> err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
> <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> 
> Could we do?
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> int get_xip_address(struct address_space *mapping, pgoff_t pgoff, int
> create, unsigned long *address);
> 
> if(mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &xip_mem)){
>      /* virtual address */
>      pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
> } else {
>      /* physical address */
>      pfn = xip_mem >> PAGE_SHIFT;
> }
> err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
> <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> Or maybe like...
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> unsigned long get_xip_address(struct address_space *mapping, pgoff_t
> pgoff, int create, int *switch);
> 
> xip_mem = mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &switch);
> if(switch){
>      /* virtual address */
>      pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
> } else {
>      /* physical address */
>      pfn = xip_mem >> PAGE_SHIFT;
> }
> err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
> <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> 
> Or...
> 
> >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> void get_xip_address(struct address_space *mapping, pgoff_t pgoff, int
> create, unsigned long *phys, void **virt);
> 
> mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &phys, &virt);
> if(phys){
>      /* physical address */
>      pfn = phys >> PAGE_SHIFT;
> } else {
>      /* physical address */
>      pfn = virt_to_phys(virt) >> PAGE_SHIFT;
> }
> err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
> <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

OK right... one problem is that we need an address for the kernel to
manipulate the memory with, but we also need a pfn to insert into user
page tables. So I like your last suggestion, but I think we always
need both address and pfn.

What about 
int get_xip_mem(mapping, pgoff, create, void **kaddr, unsigned long *pfn)

get_xip_mem(mapping, pgoff, create, &addr, &pfn);
if (pagefault)
    vm_insert_mixed(vma, vaddr, pfn);
else if (read/write) {
    memcpy(kaddr, blah, sizeof);

My simple brd driver can easily do
 *kaddr = page_address(page);
 *pfn = page_to_pfn(page);

This should work for you too?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
