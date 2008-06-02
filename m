From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: faulting kmalloced buffers into userspace through mmap()
References: <4842B4C3.1070506@brontes3d.com>
Date: Mon, 02 Jun 2008 07:38:59 +0200
In-Reply-To: <4842B4C3.1070506@brontes3d.com> (Daniel Drake's message of "Sun,
	01 Jun 2008 15:40:03 +0100")
Message-ID: <87mym4tmz0.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Drake <ddrake@brontes3d.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Daniel Drake <ddrake@brontes3d.com> writes:

> Hi,
>
> I am developing a driver for an under-development PCI frame grabber,
> which will be released as GPL once the hardware is complete.
>
> The character device driver basically operates as follows:
>  - userspace uses an ioctl to request a certain number of buffers
>  - driver allocates the buffers
>  - userspace calls mmap() to gain direct access to those buffers
>  - driver pushes physical addresses of those buffers to the device,
>    which DMAs data into them and generates interrupts accordingly
>  - userspace uses ioctls to monitor buffer status (i.e. check when
>    frame data has arrived) and then reads the data out.

Why the first ioctl?  The mmap() handler can set up the buffers.  You
can also implement a poll handler that sleeps until the interrupt
handler wakes it up.

> The buffers are allocated with kmalloc(.., GFP_KERNEL). I use a .fault
> vm operation to implement mmap. The memory space presented by mmap is
> as if all the individual buffers were laid out contiguously in memory.
>
> Fault handler is pretty much as follows:
>
> static int vma_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
> {
> 	struct page *page;
>
> 	/* find kernel-virtual address of requested data page */
> 	unsigned char *addr = find_address(foo);
>
> 	/* some locking and sanity/safety checks omitted */
>
> 	page = virt_to_page(addr);
> 	get_page(page);
> 	vmf->page = page;
> 	return 0;
> }
>
> The mapping seems to work fine, data is accessible as you'd
> expect. However, during the munmap() operation, hundreds of bad page
> state messages are generated:
>
> Bad page state in process 'lt-capture_fram'
> page:ffffe20005254300 flags:0x0148300000000084
> mapping:0000000000000000 mapcount:0 count:0
> Trying to fix it up, but a reboot is needed
> Backtrace:
> Pid: 5603, comm: lt-capture_fram Tainted: P    B    2.6.25.4 #5
>
> Call Trace:
>  [<ffffffff803e8813>] vt_console_print+0x223/0x310
>  [<ffffffff80266b5d>] bad_page+0x6d/0xb0
>  [<ffffffff802677c8>] free_hot_cold_page+0x178/0x190
>  [<ffffffff8026780a>] __pagevec_free+0x2a/0x40
>  [<ffffffff8026acb1>] release_pages+0x171/0x1b0
>  [<ffffffff8027c66d>] free_pages_and_swap_cache+0x8d/0xb0
>  [<ffffffff80271628>] unmap_vmas+0x578/0x800
>  [<ffffffff8027584a>] unmap_region+0xca/0x160
>  [<ffffffff802767e3>] do_munmap+0x223/0x2d0
>  [<ffffffff80519ca3>] __down_write_nested+0xa3/0xc0
>  [<ffffffff802768d8>] sys_munmap+0x48/0x80
>  [<ffffffff8020c03b>] system_call_after_swapgs+0x7b/0x80
>
> The bad_page() call comes from the inline function
> free_pages_check(). It triggers bad_page() because the PG_slab bit is
> set on the page.
> Presumably this is set by the __SetPageSlab() call inside slab's
> kmem_getpages() function, but I haven't traced it. What does this flag
> indicate?
>
> I also did an experiment where I kmalloced some memory and then
> immediately used virt_to_page() to get the struct page pointer for
> that memory. It already had the PG_slab bit set at that stage, so it
> does not appear to be later-occurring corruption causing this flag to
> be set at munmap() time.

You broke the abstraction here.  There are no pages from kmalloc(), it
gives you other memory objects.  And on munmapping the region, the
kmalloc objects are passed back to the buddy allocator which then blows
the whistle with bad_page() on it.

> So, am I right in saying that it is not legal to use a page fault
> handler to remap kmalloced memory in this way? I guess I need to use
> alloc_pages() or something instead?

Yes.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
