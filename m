Date: Sun, 7 Sep 2008 14:06:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: rewrite vmap layer
Message-ID: <20080907120604.GA25927@wotan.suse.de>
References: <20080818133224.GA5258@wotan.suse.de> <20080904200625.a926e274.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080904200625.a926e274.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Dave Airlie <airlied@linux.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 04, 2008 at 08:06:25PM -0700, Andrew Morton wrote:
> On Mon, 18 Aug 2008 15:32:24 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Rewrite the vmap allocator to use rbtrees and lazy tlb flushing, and provide a
> > fast, scalable percpu frontend for small vmaps (requires a slightly different
> > API, though).
> 
> With the full -mm lineup my ancient PIII machine is saying
> 
> calling agp_init+0x0/0x30
> Linux agpgart interface v0.103
> initcall agp_init+0x0/0x30 returned 0 after 0 msecs
> calling agp_intel_init+0x0/0x30
> agpgart-intel 0000:00:00.0: Intel 440BX Chipset
> ------------[ cut here ]------------
> WARNING: at mm/vmalloc.c:105 vmap_page_range+0xea/0x130()
> Modules linked in:
> Pid: 1, comm: swapper Not tainted 2.6.27-rc5-mm1 #1
>  [<c0126404>] warn_on_slowpath+0x54/0x70
>  [<c016dce9>] ? rmqueue_bulk+0x69/0x80
>  [<c014666b>] ? trace_hardirqs_on+0xb/0x10
>  [<c01465d4>] ? trace_hardirqs_on_caller+0xd4/0x160
>  [<c016ece9>] ? get_page_from_freelist+0x229/0x4f0
>  [<c018278a>] vmap_page_range+0xea/0x130
>  [<c0182801>] map_vm_area+0x31/0x50
>  [<c01828d4>] __vmalloc_area_node+0xb4/0x110
>  [<c01829c9>] __vmalloc_node+0x99/0xa0
>  [<c02c4040>] ? agp_add_bridge+0x1e0/0x4b0
>  [<c02c4040>] ? agp_add_bridge+0x1e0/0x4b0
>  [<c0182a23>] vmalloc+0x23/0x30
>  [<c02c4040>] ? agp_add_bridge+0x1e0/0x4b0
>  [<c02c4040>] agp_add_bridge+0x1e0/0x4b0
>  [<c03d70c5>] agp_intel_probe+0x145/0x2d0
>  [<c029f81e>] pci_device_probe+0x5e/0x80
>  [<c02d4ef4>] driver_probe_device+0x84/0x180
>  [<c02d5065>] __driver_attach+0x75/0x80
>  [<c02d45a9>] bus_for_each_dev+0x49/0x70
>  [<c029f760>] ? pci_device_remove+0x0/0x40
>  [<c02d4d69>] driver_attach+0x19/0x20
>  [<c02d4ff0>] ? __driver_attach+0x0/0x80
>  [<c02d49ff>] bus_add_driver+0xaf/0x220
>  [<c028e46f>] ? kset_find_obj+0x5f/0x80
>  [<c029f760>] ? pci_device_remove+0x0/0x40
>  [<c02d51ff>] driver_register+0x4f/0x120
>  [<c02974a2>] ? __spin_lock_init+0x32/0x60
>  [<c054f2c0>] ? agp_intel_init+0x0/0x30
>  [<c029fa8b>] __pci_register_driver+0x5b/0xb0
>  [<c054f2c0>] ? agp_intel_init+0x0/0x30
>  [<c054f2e5>] agp_intel_init+0x25/0x30
>  [<c010102a>] _stext+0x2a/0x150
>  [<c054f2c0>] ? agp_intel_init+0x0/0x30
>  [<c011deff>] ? wake_up_process+0xf/0x20
>  [<c0135d3d>] ? start_workqueue_thread+0x1d/0x20
>  [<c0136103>] ? __create_workqueue_key+0x143/0x190
>  [<c0532732>] kernel_init+0x182/0x280
>  [<c05325b0>] ? kernel_init+0x0/0x280
>  [<c0103fff>] kernel_thread_helper+0x7/0x18
>  =======================
> ---[ end trace e9106f0cfec79452 ]---
> agpgart-intel 0000:00:00.0: can't allocate memory for key lists
> agpgart-intel 0000:00:00.0: agp_backend_initialize() failed
> agpgart-intel: probe of 0000:00:00.0 failed with error -12
> initcall agp_intel_init+0x0/0x30 returned 0 after 10 msecs
> 
> : static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
> : 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
> : {
> : 	pte_t *pte;
> : 
> : 	/*
> : 	 * nr is a running index into the array which helps higher level
> : 	 * callers keep track of where we're up to.
> : 	 */
> : 
> : 	pte = pte_alloc_kernel(pmd, addr);
> : 	if (!pte)
> : 		return -ENOMEM;
> : 	do {
> : 		struct page *page = pages[*nr];
> : 
> : -->>		if (WARN_ON(!pte_none(*pte)))
> : 			return -EBUSY;
> : 		if (WARN_ON(!page))
> : 			return -ENOMEM;
> : 		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
> : 		(*nr)++;
> : 	} while (pte++, addr += PAGE_SIZE, addr != end);
> : 	return 0;
> : }
> : 
> 
> wanna take a look please?
> 
> config: http://userweb.kernel.org/~akpm/config-vmm.txt
> dmesg: http://userweb.kernel.org/~akpm/dmesg-vmm.txt

Yeah... Happens every time at boot, does it? I could write a patch for you
to try (give me an hour or few, I just got off a plane...)

Did we see a vmap conflict recently like this in mainline? (or IIRC was that
one warning on unmap?)

Anyway, thanks for the report. I'll be back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
