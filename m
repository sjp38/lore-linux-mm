Date: Fri, 29 Sep 2000 16:56:00 -0500
From: Timur Tabi <ttabi@interactivesi.com>
Subject: iounmap() - can't always unmap memory I've mapped
Message-Id: <20000929215548Z131165-245+29@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing list <linux-kernel@vger.kernel.org>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I'm using kernel 2.4.0-test2.  I have a driver for a memory controller-like
device that our company is developing.  We need to test random memory locations
throughout all of physical RAM, and the tests involve reading and writing to
those memory locations, bypassing the cache.  Basically, we pick a memory
location, read its value, write it back, and then query our hardware to provide
us information on that write.  

To do this, we allocate the memory with ioremap_nocache().  In order for
ioremap_nocache() to work, the physical address must be marked as PG_Reserved
in the mem_map structure.  I achieve this by temporarily setting the bit to
PG_Reserved, like this:

    unsigned long flags[num_pages];

    mem_map_t *mm = phys_to_mem_map(phys);

    save_flags(reg_flags);
    cli();

    for (i=0; i<num_pages; i++)
    {
	flags[i] = mm[i].flags;
	SetPageReserved(mm+i);
    }

    restore_flags(reg_flags);

    flush_cache();
    v = ioremap_nocache(phys, num_pages * PAGE_SIZE);
    if (!v)
	printk("uncache_pages() for physical addresses %08lx - %08lx failed!\n", phys,
phys+num_pages*PAGE_SIZE);
    flush_cache();


    save_flags(reg_flags);
    cli();

    for (i=0; i<num_pages; i++)
	mm[i].flags = flags[i];

    restore_flags(reg_flags);

"num_pages" is usually just equal to 1.  This code appears to work very well.
However, when I call the iounmap function on the memory obtained via
ioremap_nocache, sometimes I hit a kernel BUG().  The code which causes the bug
is in page_alloc.c, line 85 (in function  __free_pages_ok):

	if (page->buffers)
		BUG();

Now, the first that strikes me as odd is that all I need to do to map any
physical page of RAM is make sure the PG_Reserved bit is set.  But to unmap it,
several other things need to be true.  In my case, the "buffers" field needs to
be zero.  There are several other tests:

	if (page->mapping)
		BUG();
	if (page-mem_map >= max_mapnr)
		BUG();
	if (PageSwapCache(page))
		BUG();
	if (PageLocked(page))
		BUG();
	if (PageDecrAfter(page))
		BUG();

On a whim, I tried creating a wrapper function to iounmap that temporarily sets
page->buffers to zero for each page I'm unmapping.  Unfortunately, this causes
the kernel to crash very hard, with various errors.  I have not been able to
find a solution to this problem.

So, what I do now is if I need to iounmap() any memory where page->buffers is
non-zero, I simply do not call iounmap().  I just pretend the memory is
unmapped.  This seems to work as long as the driver is loaded.  After I unload
the driver, however, the kernel will eventually crash with a "Bad slab magic"
error message.

My guess is that the problem is the dangling virtual memory blocks that the
kernel can't clean up, but I'm not sure why it's a problem.  After all, it's
just virtual memory, and there's 4GB of that.  Also, the physical memory has
not been modified, so I can't be corrupting anything.  Is there something
fundamental I'm missing?



-- 
Timur Tabi - ttabi@interactivesi.com
Interactive Silicon - http://www.interactivesi.com

When replying to a mailing-list message, please don't cc: me, because then I'll just get two copies of the same message.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
