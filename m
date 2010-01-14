Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC0976B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 15:32:24 -0500 (EST)
Date: Thu, 14 Jan 2010 13:32:21 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100114203221.GI4545@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Pekka Enberg <penberg@cs.helsinki.fi>:
> >
> > Pid: 6234, CPU 14, comm:             modprobe
> > psr : 0000101008526030 ifs : 8000000000000b1d ip  : [<a0000001001a9ca0>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
> > ip is at kmem_cache_open+0x420/0xb20
> 
> I don't speak ia-64 so I'm having difficulties figuring out where
> exactly it's crashing. Can you use addr2line or similar tool to show
> us the exact location of the oops?

In the meantime, I rebuilt the kernel with vm and slub debugging
turned on, but actually nothing really informative came out
during dmesg.

Anyhow, it still oopsed, but obviously the IP was different.

Here's the new oops, with addr2line output below.

Unable to handle kernel paging request at virtual address a07ffffe5a7838a8
modprobe[6151]: Oops 8813272891392 [1]
Modules linked in: sr_mod(+) sg button container(+) usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6151, CPU 9, comm:             modprobe
psr : 0000101008526010 ifs : 8000000000000b1d ip  : [<a0000001001add60>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
ip is at kmem_cache_open+0x420/0xb20
unat: 0000000000000000 pfs : 0000000000000b1d rsc : 0000000000000003
rnat: a0000001009cfb98 bsps: a00000010123b5d0 pr  : aa99aaa6aa566659
ldrs: 0000000000000000 ccv : 00000000000000c2 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001ada80 b6  : a000000100362280 b7  : a000000100685b20
f6  : 0fff5e070381c00000000 f7  : 0ffeb8000000000000000
f8  : 1000f8000000000000000 f9  : 100089200000000000000
f10 : 10005e070381c00000000 f11 : 1003e0000000000000070
r1  : a0000001014480f0 r2  : 0000000000010008 r3  : 0000000000080800
r8  : 0000000000000001 r9  : a0000001010375f8 r10 : 0000000000000000
r11 : a0000001012661b8 r12 : e00007061a02fdf0 r13 : e00007061a020000
r14 : 0000000000000009 r15 : a000000101037668 r16 : 00000000c0014d00
r17 : 0000000000000009 r18 : 0000000000000fff r19 : 0000000000000000
r20 : a000000101037658 r21 : 00000000000003ff r22 : 0000000000003fff
r23 : 0000000000003fff r24 : 0000000000001b5f r25 : 00000000000036bf
r26 : a000000101037604 r27 : a000000101037600 r28 : a000000101037604
r29 : a000000101037610 r30 : 0000000000000070 r31 : 0000000000000070

Call Trace:
 [<a000000100016950>] show_stack+0x50/0xa0
                                sp=e00007061a02f9c0 bsp=e00007061a0214b8
 [<a0000001000171c0>] show_regs+0x820/0x860
                                sp=e00007061a02fb90 bsp=e00007061a021460
 [<a00000010003bc40>] die+0x1a0/0x300
                                sp=e00007061a02fb90 bsp=e00007061a021420
 [<a000000100068940>] ia64_do_page_fault+0x8c0/0x9e0
                                sp=e00007061a02fb90 bsp=e00007061a0213c8
 [<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e00007061a02fc20 bsp=e00007061a0213c8
 [<a0000001001add60>] kmem_cache_open+0x420/0xb20
                                sp=e00007061a02fdf0 bsp=e00007061a0212e0
 [<a0000001001aec70>] dma_kmalloc_cache+0x2d0/0x440
                                sp=e00007061a02fdf0 bsp=e00007061a021290
 [<a0000001001aeef0>] get_slab+0x110/0x1a0
                                sp=e00007061a02fdf0 bsp=e00007061a021268
 [<a0000001001af6c0>] __kmalloc+0xa0/0x260
                                sp=e00007061a02fdf0 bsp=e00007061a021230
 [<a000000207dd16d0>] sr_probe+0x3b0/0xf20 [sr_mod]
                                sp=e00007061a02fdf0 bsp=e00007061a0211c8
 [<a00000010048ab20>] driver_probe_device+0x180/0x300
                                sp=e00007061a02fe20 bsp=e00007061a021190
 [<a00000010048ad80>] __driver_attach+0xe0/0x140
                                sp=e00007061a02fe20 bsp=e00007061a021160
 [<a000000100489780>] bus_for_each_dev+0xa0/0x140
                                sp=e00007061a02fe20 bsp=e00007061a021128
 [<a00000010048a740>] driver_attach+0x40/0x60
                                sp=e00007061a02fe30 bsp=e00007061a021108
 [<a0000001004885a0>] bus_add_driver+0x180/0x520
                                sp=e00007061a02fe30 bsp=e00007061a0210c0
 [<a00000010048b540>] driver_register+0x260/0x400
                                sp=e00007061a02fe30 bsp=e00007061a021078
 [<a0000001004df520>] scsi_register_driver+0x40/0x60
                                sp=e00007061a02fe30 bsp=e00007061a021058
 [<a000000207e00070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e00007061a02fe30 bsp=e00007061a021038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e00007061a02fe30 bsp=e00007061a020ff0
 [<a000000100106040>] sys_init_module+0x1e0/0x4c0
                                sp=e00007061a02fe30 bsp=e00007061a020f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e00007061a02fe30 bsp=e00007061a020f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e00007061a030000 bsp=e00007061a020f78
Disabling lock debugging due to kernel taint
udevd-event[6150]: '/sbin/modprobe' abnormal exit


coffee0:/usr/src/linux-2.6 # addr2line 0xa0000001001add60 -e vmlinux
/usr/src/linux-2.6/include/linux/mm.h:543

 538 #ifdef NODE_NOT_IN_PAGE_FLAGS
 539 extern int page_to_nid(struct page *page);
 540 #else
 541 static inline int page_to_nid(struct page *page)
 542 {
 543         return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
 544 }
 545 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
