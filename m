Received: by ug-out-1314.google.com with SMTP id u40so673731ugc.29
        for <linux-mm@kvack.org>; Sat, 01 Mar 2008 00:14:37 -0800 (PST)
Message-ID: <6934efce0803010014p2cc9a5edu5fee2029c0104a07@mail.gmail.com>
Date: Sat, 1 Mar 2008 00:14:35 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [patch 4/6] xip: support non-struct page backed memory
In-Reply-To: <20080118045755.735923000@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080118045649.334391000@suse.de>
	 <20080118045755.735923000@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>  (The kaddr->pfn conversion may not be quite right for all architectures or XIP
>  memory mappings, and the cacheflushing may need to be added for some archs).
>
>  This scheme has been tested and works for Jared's work-in-progress filesystem,

Opps.  I screwed up testing this.  It doesn't work with MTD devices and ARM....

The problem is that virt_to_phys() gives bogus answer for a
mtd->point()'ed address.  It's a ioremap()'ed address which doesn't
work with the ARM virt_to_phys().  I can get a physical address from
mtd->point() with a patch I dropped a little while back.

So I was thinking how about instead of:

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
void * get_xip_address(struct address_space *mapping, pgoff_t pgoff,
int create);

xip_mem = mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0);
pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Could we do?

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
int get_xip_address(struct address_space *mapping, pgoff_t pgoff, int
create, unsigned long *address);

if(mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &xip_mem)){
     /* virtual address */
     pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
} else {
     /* physical address */
     pfn = xip_mem >> PAGE_SHIFT;
}
err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Or maybe like...

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
unsigned long get_xip_address(struct address_space *mapping, pgoff_t
pgoff, int create, int *switch);

xip_mem = mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &switch);
if(switch){
     /* virtual address */
     pfn = virt_to_phys((void *)xip_mem) >> PAGE_SHIFT;
} else {
     /* physical address */
     pfn = xip_mem >> PAGE_SHIFT;
}
err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Or...

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
void get_xip_address(struct address_space *mapping, pgoff_t pgoff, int
create, unsigned long *phys, void **virt);

mapping->a_ops->get_xip_address(mapping, vmf->pgoff, 0, &phys, &virt);
if(phys){
     /* physical address */
     pfn = phys >> PAGE_SHIFT;
} else {
     /* physical address */
     pfn = virt_to_phys(virt) >> PAGE_SHIFT;
}
err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address, pfn);
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
