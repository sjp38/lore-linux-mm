Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4D29C6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 15:02:31 -0500 (EST)
Date: Tue, 19 Jan 2010 13:02:28 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-ID: <20100119200228.GE11010@ldl.fc.hp.com>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net> <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001191252370.25101@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux-foundation.org>:
> On Fri, 15 Jan 2010, Christoph Lameter wrote:
> 
> > An allocated kmem_cache structure is definitely not in the range of the
> > kmalloc_caches array. This is basically checking if s is pointing to the
> > static kmalloc array.
> 
> Check was wrong.. Sigh...
> 
> ---
>  mm/slub.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2010-01-19 12:50:20.000000000 -0600
> +++ linux-2.6/mm/slub.c	2010-01-19 12:51:30.000000000 -0600
> @@ -2148,7 +2148,8 @@ static int init_kmem_cache_nodes(struct
>  	int node;
>  	int local_node;
> 
> -	if (slab_state >= UP)
> +	if (slab_state >= UP && (s < kmalloc_caches ||
> +			s > kmalloc_caches + KMALLOC_CACHES))
>  		local_node = page_to_nid(virt_to_page(s));
>  	else
>  		local_node = 0;

Well, making progress (maybe?).

Now we're hitting a BUG_ON().

Interestingly, the machine now boots all the way to a login
prompt, whereas previously, it would simply hang.

/ac

kernel BUG at mm/slub.c:2839!
modprobe[6015]: bugcheck! 0 [1]
Modules linked in: sr_mod(+) button container(+) usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6015, CPU 0, comm:             modprobe
psr : 00001010085a6010 ifs : 8000000000000289 ip  : [<a0000001001ae800>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
ip is at kfree+0xe0/0x260
unat: 0000000000000000 pfs : 0000000000000289 rsc : 0000000000000003
rnat: e0000786165b1720 bsps: aa99aaa6aa595999 pr  : aa99aaa6aa565959
ldrs: 0000000000000000 ccv : 00000000000000c2 fpsr: 0009804c8a70433f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a0000001001ae800 b6  : a0000001005e4360 b7  : a00000010046de40
f6  : 1003e0000000cb95d6936 f7  : 1003e0000000000000190
f8  : 1003e0000000cb95d67a6 f9  : 1003e0000000000000001
f10 : 100079cfffffffc583503 f11 : 1003e0000000000000000
r1  : a0000001014480f0 r2  : 00000000000017ec r3  : 000000000000fffe
r8  : 0000000000000021 r9  : 000000000000ffff r10 : ffffffffffff41ef
r11 : 0000000000000000 r12 : e0000786165bfdf0 r13 : e0000786165b0000
r14 : 00000000000017ec r15 : 0000000000004000 r16 : a00000010119c62c
r17 : a000000101265d70 r18 : 0000000000000000 r19 : a0000001005e4360
r20 : a0000001018edb38 r21 : 000000000000bdf3 r22 : 00000000000fffff
r23 : 0000000000100000 r24 : a000000102a3ddc8 r25 : a000000100a0dca8
r26 : a00000010046de40 r27 : a000000102a3ddc8 r28 : a000000102a3dec0
r29 : a000000100a0dc98 r30 : a00000010046dd80 r31 : a000000102a3ddc0

Call Trace:
 [<a000000100016950>] show_stack+0x50/0xa0
                                sp=e0000786165bf9c0 bsp=e0000786165b1368
 [<a0000001000171c0>] show_regs+0x820/0x860
                                sp=e0000786165bfb90 bsp=e0000786165b1310
 [<a00000010003bc40>] die+0x1a0/0x300
                                sp=e0000786165bfb90 bsp=e0000786165b12d0
 [<a00000010003bdf0>] die_if_kernel+0x50/0x80
                                sp=e0000786165bfb90 bsp=e0000786165b12a0
 [<a00000010003d460>] ia64_bad_break+0x220/0x440
                                sp=e0000786165bfb90 bsp=e0000786165b1278
 [<a00000010000c8a0>] ia64_native_leave_kernel+0x0/0x270
                                sp=e0000786165bfc20 bsp=e0000786165b1278
 [<a0000001001ae800>] kfree+0xe0/0x260
                                sp=e0000786165bfdf0 bsp=e0000786165b1230
 [<a000000207ce1df0>] sr_probe+0xad0/0xf20 [sr_mod]
                                sp=e0000786165bfdf0 bsp=e0000786165b11c8
 [<a00000010048ab40>] driver_probe_device+0x180/0x300
                                sp=e0000786165bfe20 bsp=e0000786165b1190
 [<a00000010048ada0>] __driver_attach+0xe0/0x140
                                sp=e0000786165bfe20 bsp=e0000786165b1160
 [<a0000001004897a0>] bus_for_each_dev+0xa0/0x140
                                sp=e0000786165bfe20 bsp=e0000786165b1128
 [<a00000010048a760>] driver_attach+0x40/0x60
                                sp=e0000786165bfe30 bsp=e0000786165b1108
 [<a0000001004885c0>] bus_add_driver+0x180/0x520
                                sp=e0000786165bfe30 bsp=e0000786165b10c0
 [<a00000010048b560>] driver_register+0x260/0x400
                                sp=e0000786165bfe30 bsp=e0000786165b1078
 [<a0000001004df540>] scsi_register_driver+0x40/0x60
                                sp=e0000786165bfe30 bsp=e0000786165b1058
 [<a000000207d10070>] init_sr+0x70/0x140 [sr_mod]
                                sp=e0000786165bfe30 bsp=e0000786165b1038
 [<a00000010000a960>] do_one_initcall+0xe0/0x360
                                sp=e0000786165bfe30 bsp=e0000786165b0ff0
 [<a000000100106040>] sys_init_module+0x1e0/0x4c0
                                sp=e0000786165bfe30 bsp=e0000786165b0f78
 [<a00000010000c700>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000786165bfe30 bsp=e0000786165b0f78
 [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
                                sp=e0000786165c0000 bsp=e0000786165b0f78
Disabling lock debugging due to kernel taint

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
