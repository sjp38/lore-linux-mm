Received: from rp073a.halls.manchester.ac.uk ([130.88.180.73])
	by tranquility.mcc.ac.uk with esmtp (Exim 4.69 (FreeBSD))
	(envelope-from <ddrake@brontes3d.com>)
	id 1K2oiY-0005vC-Dr
	for linux-mm@kvack.org; Sun, 01 Jun 2008 15:39:30 +0100
Message-ID: <4842B4C3.1070506@brontes3d.com>
Date: Sun, 01 Jun 2008 15:40:03 +0100
From: Daniel Drake <ddrake@brontes3d.com>
MIME-Version: 1.0
Subject: faulting kmalloced buffers into userspace through mmap()
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am developing a driver for an under-development PCI frame grabber, 
which will be released as GPL once the hardware is complete.

The character device driver basically operates as follows:
  - userspace uses an ioctl to request a certain number of buffers
  - driver allocates the buffers
  - userspace calls mmap() to gain direct access to those buffers
  - driver pushes physical addresses of those buffers to the device,
    which DMAs data into them and generates interrupts accordingly
  - userspace uses ioctls to monitor buffer status (i.e. check when
    frame data has arrived) and then reads the data out.

The buffers are allocated with kmalloc(.., GFP_KERNEL). I use a .fault 
vm operation to implement mmap. The memory space presented by mmap is as 
if all the individual buffers were laid out contiguously in memory.

Fault handler is pretty much as follows:

static int vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
{
	struct page *page;

	/* find kernel-virtual address of requested data page */
	unsigned char *addr = find_address(foo);

	/* some locking and sanity/safety checks omitted */

	page = virt_to_page(addr);
	get_page(page);
	vmf->page = page;
	return 0;
}

The mapping seems to work fine, data is accessible as you'd expect. 
However, during the munmap() operation, hundreds of bad page state 
messages are generated:

Bad page state in process 'lt-capture_fram'
page:ffffe20005254300 flags:0x0148300000000084 mapping:0000000000000000 
mapcount:0 count:0
Trying to fix it up, but a reboot is needed
Backtrace:
Pid: 5603, comm: lt-capture_fram Tainted: P    B    2.6.25.4 #5

Call Trace:
  [<ffffffff803e8813>] vt_console_print+0x223/0x310
  [<ffffffff80266b5d>] bad_page+0x6d/0xb0
  [<ffffffff802677c8>] free_hot_cold_page+0x178/0x190
  [<ffffffff8026780a>] __pagevec_free+0x2a/0x40
  [<ffffffff8026acb1>] release_pages+0x171/0x1b0
  [<ffffffff8027c66d>] free_pages_and_swap_cache+0x8d/0xb0
  [<ffffffff80271628>] unmap_vmas+0x578/0x800
  [<ffffffff8027584a>] unmap_region+0xca/0x160
  [<ffffffff802767e3>] do_munmap+0x223/0x2d0
  [<ffffffff80519ca3>] __down_write_nested+0xa3/0xc0
  [<ffffffff802768d8>] sys_munmap+0x48/0x80
  [<ffffffff8020c03b>] system_call_after_swapgs+0x7b/0x80

The bad_page() call comes from the inline function free_pages_check(). 
It triggers bad_page() because the PG_slab bit is set on the page.
Presumably this is set by the __SetPageSlab() call inside slab's 
kmem_getpages() function, but I haven't traced it. What does this flag 
indicate?

I also did an experiment where I kmalloced some memory and then 
immediately used virt_to_page() to get the struct page pointer for that 
memory. It already had the PG_slab bit set at that stage, so it does not 
appear to be later-occurring corruption causing this flag to be set at 
munmap() time.

So, am I right in saying that it is not legal to use a page fault 
handler to remap kmalloced memory in this way? I guess I need to use 
alloc_pages() or something instead?

If I switched to remap_pfn_range(), would it be OK to use kmalloced 
memory in this way? I chose to use fault because the mapping I am 
presenting to userspace is actually composed of a number of separate 
kmalloced buffers, whereas remap_pfn_range() looks best suited for where 
you just have one buffer you want to map.

I'll document any resultant findings on the linux-mm wiki.

Thanks,
-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
