Date: Wed, 27 Jun 2007 23:09:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 06/26] Slab allocators: Replace explicit zeroing with
 __GFP_ZERO
Message-Id: <20070627230943.83b5db1f.akpm@linux-foundation.org>
In-Reply-To: <20070618095914.862238426@sgi.com>
References: <20070618095838.238615343@sgi.com>
	<20070618095914.862238426@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jun 2007 02:58:44 -0700 clameter@sgi.com wrote:

> kmalloc_node() and kmem_cache_alloc_node() were not available in
> a zeroing variant in the past. But with __GFP_ZERO it is possible
> now to do zeroing while allocating.
> 
> Use __GFP_ZERO to remove the explicit clearing of memory via memset whereever
> we can.

I'm geting random ugly slab corruptions from this, with CONFIG_SLAB=y, an
excerpt of which is below.

It could be damage from Paul's numa-for-slob patch, dunno.  I don't think
I've runtime tested
slab-allocators-replace-explicit-zeroing-with-__gfp_zero.patch before.

I'll keep shedding sl[aou]b patches until this lot stabilises, sorry.


initcall 0xc0513de0 ran for 0 msecs: cn_proc_init+0x0/0x40()
Calling initcall 0xc0513f20: serial8250_init+0x0/0x130()
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
slab error in cache_alloc_debugcheck_after(): cache `size-32': double free, or memory outside object was overwritten
 [<c0103e9a>] show_trace_log_lvl+0x1a/0x30
 [<c0104b42>] show_trace+0x12/0x20
 [<c0104bb6>] dump_stack+0x16/0x20
 [<c0177266>] __slab_error+0x26/0x30
 [<c017780a>] cache_alloc_debugcheck_after+0xda/0x1c0
 [<c0178c3d>] __kmalloc_track_caller+0xbd/0x150
 [<c0164429>] __kzalloc+0x19/0x50
 [<c02849fd>] kobject_get_path+0x5d/0xc0
 [<c02d1968>] dev_uevent+0x108/0x390
 [<c02856be>] kobject_uevent_env+0x24e/0x470
 [<c02858ea>] kobject_uevent+0xa/0x10
 [<c02d16cf>] device_add+0x45f/0x5d0
 [<c02d1852>] device_register+0x12/0x20
 [<c02d1e56>] device_create+0x86/0xb0
 [<c02afacf>] tty_register_device+0x6f/0xf0
 [<c02cb207>] uart_add_one_port+0x1f7/0x2f0
 [<c0514007>] serial8250_init+0xe7/0x130
 [<c04fc622>] kernel_init+0x132/0x300
 [<c0103ad7>] kernel_thread_helper+0x7/0x10
 =======================
c2e8aba8: redzone 1:0x0, redzone 2:0x9f911029d74e35b
initcall 0xc0513f20: serial8250_init+0x0/0x130() returned 0.
initcall 0xc0513f20 ran for 4 msecs: serial8250_init+0x0/0x130()
Calling initcall 0xc0514050: serial8250_pnp_init+0x0/0x10()
00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:0c: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
initcall 0xc0514050: serial8250_pnp_init+0x0/0x10() returned 0.
initcall 0xc0514050 ran for 3 msecs: serial8250_pnp_init+0x0/0x10()
Calling initcall 0xc0514060: serial8250_pci_init+0x0/0x20()
initcall 0xc0514060: serial8250_pci_init+0x0/0x20() returned 0.
initcall 0xc0514060 ran for 0 msecs: serial8250_pci_init+0x0/0x20()
Calling initcall 0xc05141e0: isa_bus_init+0x0/0x40()
initcall 0xc05141e0: isa_bus_init+0x0/0x40() returned 0.
initcall 0xc05141e0 ran for 0 msecs: isa_bus_init+0x0/0x40()
Calling initcall 0xc02d94f0: topology_sysfs_init+0x0/0x50()
initcall 0xc02d94f0: topology_sysfs_init+0x0/0x50() returned 0.
initcall 0xc02d94f0 ran for 0 msecs: topology_sysfs_init+0x0/0x50()
Calling initcall 0xc0514590: floppy_init+0x0/0xf10()
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
initcall 0xc0514590: floppy_init+0x0/0xf10() returned 0.
initcall 0xc0514590 ran for 20 msecs: floppy_init+0x0/0xf10()
Calling initcall 0xc05154f0: rd_init+0x0/0x1e0()
slab error in cache_alloc_debugcheck_after(): cache `size-64': double free, or memory outside object was overwritten
 [<c0103e9a>] show_trace_log_lvl+0x1a/0x30
 [<c0104b42>] show_trace+0x12/0x20
 [<c0104bb6>] dump_stack+0x16/0x20
 [<c0177266>] __slab_error+0x26/0x30
 [<c017780a>] cache_alloc_debugcheck_after+0xda/0x1c0
 [<c0178af0>] __kmalloc+0xc0/0x150
 [<c017a712>] percpu_populate+0x22/0x30
 [<c017a75f>] __percpu_populate_mask+0x3f/0x80
 [<c017a7e4>] __percpu_alloc_mask+0x44/0x80
 [<c027d130>] alloc_disk_node+0x30/0xb0
 [<c027d1bd>] alloc_disk+0xd/0x10
 [<c051552a>] rd_init+0x3a/0x1e0
 [<c04fc622>] kernel_init+0x132/0x300
 [<c0103ad7>] kernel_thread_helper+0x7/0x10
 =======================
c2f7fbd0: redzone 1:0x0, redzone 2:0x9f911029d74e35b
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
initcall 0xc05154f0: rd_init+0x0/0x1e0() returned 0.
initcall 0xc05154f0 ran for 8 msecs: rd_init+0x0/0x1e0()
Calling initcall 0xc05156f0: loop_init+0x0/0x180()
slab error in cache_alloc_debugcheck_after(): cache `size-64': double free, or memory outside object was overwritten
 [<c0103e9a>] show_trace_log_lvl+0x1a/0x30
 [<c0104b42>] show_trace+0x12/0x20
 [<c0104bb6>] dump_stack+0x16/0x20
 [<c0177266>] __slab_error+0x26/0x30
 [<c017780a>] cache_alloc_debugcheck_after+0xda/0x1c0
 [<c0178af0>] __kmalloc+0xc0/0x150
 [<c017a712>] percpu_populate+0x22/0x30
 [<c017a75f>] __percpu_populate_mask+0x3f/0x80
 [<c017a7e4>] __percpu_alloc_mask+0x44/0x80
 [<c027d130>] alloc_disk_node+0x30/0xb0
 [<c027d1bd>] alloc_disk+0xd/0x10
 [<c02e16a1>] loop_alloc+0x51/0x110
 [<c0515781>] loop_init+0x91/0x180
 [<c04fc622>] kernel_init+0x132/0x300
 [<c0103ad7>] kernel_thread_helper+0x7/0x10
 =======================
c2f28650: redzone 1:0x0, redzone 2:0x9f911029d74e35b
loop: module loaded
initcall 0xc05156f0: loop_init+0x0/0x180() returned 0.
initcall 0xc05156f0 ran for 7 msecs: loop_init+0x0/0x180()
Calling initcall 0xc0515870: e100_init_module+0x0/0x60()
e100: Intel(R) PRO/100 Network Driver, 3.5.17-k4-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100: eth0: e100_probe: addr 0xfc5ff000, irq 11, MAC addr 00:90:27:70:14:CD
initcall 0xc0515870: e100_init_module+0x0/0x60() returned 0.
initcall 0xc0515870 ran for 22 msecs: e100_init_module+0x0/0x60()
Calling initcall 0xc0515940: net_olddevs_init+0x0/0x90()
initcall 0xc0515940: net_olddevs_init+0x0/0x90() returned 0.
initcall 0xc0515940 ran for 0 msecs: net_olddevs_init+0x0/0x90()
Calling initcall 0xc05159d0: loopback_init+0x0/0x10()
initcall 0xc05159d0: loopback_init+0x0/0x10() returned 0.
initcall 0xc05159d0 ran for 0 msecs: loopback_init+0x0/0x10()
Calling initcall 0xc05159e0: dummy_init_module+0x0/0x140()
initcall 0xc05159e0: dummy_init_module+0x0/0x140() returned 0.
initcall 0xc05159e0 ran for 0 msecs: dummy_init_module+0x0/0x140()
Calling initcall 0xc0515b20: rtl8169_init_module+0x0/0x20()
initcall 0xc0515b20: rtl8169_init_module+0x0/0x20() returned 0.
initcall 0xc0515b20 ran for 0 msecs: rtl8169_init_module+0x0/0x20()
Calling initcall 0xc02e9d70: init_netconsole+0x0/0x80()
netconsole: device eth0 not up yet, forcing it
e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
netconsole: carrier detect appears untrustworthy, waiting 4 seconds
console [netcon0] enabled
netconsole: network logging started
initcall 0xc02e9d70: init_netconsole+0x0/0x80() returned 0.
initcall 0xc02e9d70 ran for 3965 msecs: init_netconsole+0x0/0x80()
Calling initcall 0xc0515b40: piix_ide_init+0x0/0xd0()
initcall 0xc0515b40: piix_ide_init+0x0/0xd0() returned 0.
initcall 0xc0515b40 ran for 0 msecs: piix_ide_init+0x0/0xd0()
Calling initcall 0xc0515c10: generic_ide_init+0x0/0x20()
initcall 0xc0515c10: generic_ide_init+0x0/0x20() returned 0.
initcall 0xc0515c10 ran for 0 msecs: generic_ide_init+0x0/0x20()
Calling initcall 0xc0515e40: ide_init+0x0/0x70()
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
PIIX4: IDE controller at PCI slot 0000:00:07.1
PIIX4: chipset revision 1
PIIX4: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xffa0-0xffa7, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0xffa8-0xffaf, BIOS settings: hdc:DMA, hdd:pio
Clocksource tsc unstable (delta = 68016953 ns)
Time: jiffies clocksource has been installed.
hdc: MAXTOR 6L080J4, ATA DISK drive
ide1 at 0x170-0x177,0x376 on irq 15
slab error in cache_alloc_debugcheck_after(): cache `size-64': double free, or memory outside object was overwritten
 [<c0103e9a>] show_trace_log_lvl+0x1a/0x30
 [<c0104b42>] show_trace+0x12/0x20
 [<c0104bb6>] dump_stack+0x16/0x20
 [<c0177266>] __slab_error+0x26/0x30
 [<c017780a>] cache_alloc_debugcheck_after+0xda/0x1c0
 [<c0178d4d>] kmem_cache_zalloc+0x7d/0x120
 [<c02f64d8>] __ide_add_setting+0x68/0x130
 [<c02f6699>] ide_add_generic_settings+0xf9/0x2e0
 [<c02f182d>] hwif_init+0xfd/0x360
 [<c02f1c76>] probe_hwif_init_with_fixup+0x16/0x90
 [<c02f4203>] ide_setup_pci_device+0x83/0xb0
 [<c02e9f7d>] piix_init_one+0x1d/0x20
 [<c05164a9>] ide_scan_pcidev+0x39/0x70
 [<c0516507>] ide_scan_pcibus+0x27/0xf0
 [<c0515e83>] ide_init+0x43/0x70
 [<c04fc622>] kernel_init+0x132/0x300
 [<c0103ad7>] kernel_thread_helper+0x7/0x10
 =======================
c2f28bd0: redzone 1:0x0, redzone 2:0x9f911029d74e35b
initcall 0xc0515e40: ide_init+0x0/0x70() returned 0.
initcall 0xc0515e40 ran for 1462 msecs: ide_init+0x0/0x70()
Calling initcall 0xc05165d0: ide_generic_init+0x0/0x10()
initcall 0xc05165d0: ide_generic_init+0x0/0x10() returned 0.
initcall 0xc05165d0 ran for 545 msecs: ide_generic_init+0x0/0x10()
Calling initcall 0xc05165e0: idedisk_init+0x0/0x10()
hdc: max request size: 128KiB
hdc: 156355584 sectors (80054 MB) w/1819KiB Cache, CHS=65535/16/63, UDMA(33)<3>slab error in cache_alloc_debugcheck_after(): cache `size-256': double free, or memory outside object was overwritten
 [<c0103e9a>] show_trace_log_lvl+0x1a/0x30
 [<c0104b42>] show_trace+0x12/0x20
 [<c0104bb6>] dump_stack+0x16/0x20
 [<c0177266>] __slab_error+0x26/0x30
 [<c017780a>] cache_alloc_debugcheck_after+0xda/0x1c0
 [<c0178c3d>] __kmalloc_track_caller+0xbd/0x150
 [<c034b62b>] __alloc_skb+0x4b/0x100
 [<c035cecc>] find_skb+0x3c/0x80
 [<c035db8b>] netpoll_send_udp+0x2b/0x280
 [<c02e9e3c>] write_msg+0x4c/0x80
 [<c011fec0>] __call_console_drivers+0x60/0x70
 [<c011ff1b>] _call_console_drivers+0x4b/0x90
 [<c0120274>] release_console_sem+0x1b4/0x240
 [<c0120733>] vprintk+0x1e3/0x350
 [<c01208bb>] printk+0x1b/0x20
 [<c02f4c4f>] ide_dma_verbose+0x11f/0x190
 [<c02f8173>] ide_disk_probe+0x5f3/0x6f0
 [<c02ea972>] generic_ide_probe+0x22/0x30
 [<c02d3a0d>] driver_probe_device+0x8d/0x190
 [<c02d3c9b>] __driver_attach+0xbb/0xc0
 [<c02d2d59>] bus_for_each_dev+0x49/0x70
 [<c02d3879>] driver_attach+0x19/0x20
 [<c02d315f>] bus_add_driver+0x7f/0x1b0
 [<c02d3e65>] driver_register+0x45/0x80
 [<c05165ed>] idedisk_init+0xd/0x10
 [<c04fc622>] kernel_init+0x132/0x300
 [<c0103ad7>] kernel_thread_helper+0x7/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
