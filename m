Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3E5828E1
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:37:18 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g13so299908111ioj.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 23:37:18 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c65si2568391itg.39.2016.06.19.23.37.16
        for <linux-mm@kvack.org>;
        Sun, 19 Jun 2016 23:37:17 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:39:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Boot failure on emev2/kzm9d (was: Re: [PATCH v2 11/11] mm/slab:
 lockless decision to grow cache)
Message-ID: <20160620063942.GA13747@js1304-P5Q-DELUXE>
References: <CAMuHMdXC=zEjbZADE5wELjOq_kBiFNewpdUrMCe8d3Utu98h8A@mail.gmail.com>
 <20160614062456.GB13753@js1304-P5Q-DELUXE>
 <CAMuHMdWipquaVFKYLd=2KhTx6djwH7NXpzL-RjtikCE=G8KTbA@mail.gmail.com>
 <20160614081125.GA17700@js1304-P5Q-DELUXE>
 <CAMuHMdXc=XN4z96vr_FNcUzFb0203ovHgcfD95Q5LPebr1z0ZQ@mail.gmail.com>
 <20160615022325.GA19863@js1304-P5Q-DELUXE>
 <CAMuHMdVi-F0n-GjnUqEEd58UcWxw67g8ZJO838fvo31Ttr5E1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdVi-F0n-GjnUqEEd58UcWxw67g8ZJO838fvo31Ttr5E1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-renesas-soc@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

CCing Paul to ask some question.

On Wed, Jun 15, 2016 at 10:39:47AM +0200, Geert Uytterhoeven wrote:
> Hi Joonsoo,
> 
> On Wed, Jun 15, 2016 at 4:23 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > On Tue, Jun 14, 2016 at 12:45:14PM +0200, Geert Uytterhoeven wrote:
> >> On Tue, Jun 14, 2016 at 10:11 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> > On Tue, Jun 14, 2016 at 09:31:23AM +0200, Geert Uytterhoeven wrote:
> >> >> On Tue, Jun 14, 2016 at 8:24 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >> >> > On Mon, Jun 13, 2016 at 09:43:13PM +0200, Geert Uytterhoeven wrote:
> >> >> >> On Tue, Apr 12, 2016 at 6:51 AM,  <js1304@gmail.com> wrote:
> >> >> >> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> >> >> > To check whther free objects exist or not precisely, we need to grab a
> >> >> >> > lock.  But, accuracy isn't that important because race window would be
> >> >> >> > even small and if there is too much free object, cache reaper would reap
> >> >> >> > it.  So, this patch makes the check for free object exisistence not to
> >> >> >> > hold a lock.  This will reduce lock contention in heavily allocation case.
> 
> >> >> >> I've bisected a boot failure (no output at all) in v4.7-rc2 on emev2/kzm9d
> >> >> >> (Renesas dual Cortex A9) to this patch, which is upstream commit
> >> >> >> 801faf0db8947e01877920e848a4d338dd7a99e7.
> 
> > It's curious that synchronize_sched() has some effect in this early
> > phase. In synchronize_sched(), rcu_blocking_is_gp() is called and
> > it checks num_online_cpus <= 1. If so, synchronize_sched() does nothing.
> >
> > It would be related to might_sleep() in rcu_blocking_is_gp() but I'm not sure now.
> >
> > First, I'd like to confirm that num_online_cpus() is correct.
> > Could you try following patch and give me a dmesg?
> >
> > Thanks.
> >
> > ------->8----------
> > diff --git a/mm/slab.c b/mm/slab.c
> > index 763096a..5b7300a 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -964,8 +964,10 @@ static int setup_kmem_cache_node(struct kmem_cache *cachep,
> >          * guaranteed to be valid until irq is re-enabled, because it will be
> >          * freed after synchronize_sched().
> >          */
> > -       if (force_change)
> > -               synchronize_sched();
> > +       if (force_change) {
> > +               WARN_ON_ONCE(num_online_cpus() <= 1);
> > +               WARN_ON_ONCE(num_online_cpus() > 1);
> > +       }
> 
> Full dmesg output below.
> 
> I also tested whether it's the call to synchronize_sched() before or after
> secondary CPU bringup that hangs.
> 
>         if (force_change && num_online_cpus() <= 1)
>                 synchronize_sched();
> 
> boots.
> 
>         if (force_change && num_online_cpus() > 1)
>                 synchronize_sched();
> 
> hangs.

Hello, Paul.

I changed slab.c to use synchronize_sched() for full memory barrier. First
call happens on kmem_cache_init_late() and it would not be a problem
because, at this time, num_online_cpus() <= 1 and synchronize_sched()
would return immediately. Second call site would be shmem_init()
and it seems that system hangs on it. Since smp is already initialized
at that time, there would be some effect of synchronize_sched() but I
can't imagine what's wrong here. Is it invalid moment to call
synchronize_sched()?

Note that my x86 virtual machine works fine even if
synchronize_sched() is called in shmem_init() but Geert's some ARM
machines (not all ARM machine) don't work well with it.

Thanks.

> 
> Booting Linux on physical CPU 0x0
> Linux version 4.6.0-kzm9d-05060-g801faf0db8947e01-dirty (geert@ramsan)
> (gcc version 4.9.0 (GCC) ) #84 SMP Wed Jun 15 10:20:12 CEST 2016
> CPU: ARMv7 Processor [411fc093] revision 3 (ARMv7), cr=10c5387d
> CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
> Machine model: EMEV2 KZM9D Board
> debug: ignoring loglevel setting.
> Memory policy: Data cache writealloc
> On node 0 totalpages: 32768
> free_area_init_node: node 0, pgdat c09286c0, node_mem_map c7efa000
>   Normal zone: 256 pages used for memmap
>   Normal zone: 0 pages reserved
>   Normal zone: 32768 pages, LIFO batch:7
> percpu: Embedded 12 pages/cpu @c7ed9000 s19264 r8192 d21696 u49152
> pcpu-alloc: s19264 r8192 d21696 u49152 alloc=12*4096
> pcpu-alloc: [0] 0 [0] 1
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 32512
> Kernel command line: console=ttyS1,115200n81 ignore_loglevel
> root=/dev/nfs ip=dhcp
> PID hash table entries: 512 (order: -1, 2048 bytes)
> Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
> Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
> Memory: 121144K/131072K available (4243K kernel code, 165K rwdata,
> 1344K rodata, 2048K init, 264K bss, 9928K reserved, 0K cma-reserved,
> 0K highmem)
> Virtual kernel memory layout:
>     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
>     fixmap  : 0xffc00000 - 0xfff00000   (3072 kB)
>     vmalloc : 0xc8800000 - 0xff800000   ( 880 MB)
>     lowmem  : 0xc0000000 - 0xc8000000   ( 128 MB)
>     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
>     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
>       .text : 0xc0008000 - 0xc0674eb8   (6580 kB)
>       .init : 0xc0700000 - 0xc0900000   (2048 kB)
>       .data : 0xc0900000 - 0xc0929420   ( 166 kB)
>        .bss : 0xc092b000 - 0xc096d1e8   ( 265 kB)
> Hierarchical RCU implementation.
>  Build-time adjustment of leaf fanout to 32.
>  RCU restricting CPUs from NR_CPUS=4 to nr_cpu_ids=2.
> RCU: Adjusting geometry for rcu_fanout_leaf=32, nr_cpu_ids=2
> NR_IRQS:16 nr_irqs:16 16
> clocksource_probe: no matching clocksources found
> sched_clock: 32 bits at 100 Hz, resolution 10000000ns, wraps every
> 21474836475000000ns
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 0 at mm/slab.c:975 setup_kmem_cache_node+0x160/0x1c8
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.6.0-kzm9d-05060-g801faf0db8947e01-dirty #84
> Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
> [<c010de08>] (unwind_backtrace) from [<c010a620>] (show_stack+0x10/0x14)
> [<c010a620>] (show_stack) from [<c02b3178>] (dump_stack+0x7c/0x9c)
> [<c02b3178>] (dump_stack) from [<c011f9fc>] (__warn+0xcc/0xfc)
> [<c011f9fc>] (__warn) from [<c011fad0>] (warn_slowpath_null+0x1c/0x24)
> [<c011fad0>] (warn_slowpath_null) from [<c01ced4c>]
> (setup_kmem_cache_node+0x160/0x1c8)
> [<c01ced4c>] (setup_kmem_cache_node) from [<c01cf02c>]
> (__do_tune_cpucache+0xf4/0x114)
> [<c01cf02c>] (__do_tune_cpucache) from [<c01cf0b0>] (enable_cpucache+0x64/0xb4)
> [<c01cf0b0>] (enable_cpucache) from [<c0710324>]
> (kmem_cache_init_late+0x40/0x84)
> [<c0710324>] (kmem_cache_init_late) from [<c0700af8>] (start_kernel+0x238/0x36c)
> [<c0700af8>] (start_kernel) from [<4000807c>] (0x4000807c)
> ---[ end trace cb88537fdc8fa200 ]---
> Console: colour dummy device 80x30
> Calibrating delay loop (skipped) preset value.. 1066.00 BogoMIPS (lpj=5330000)
> pid_max: default: 32768 minimum: 301
> Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
> Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
> CPU: Testing write buffer coherency: ok
> CPU0: thread -1, cpu 0, socket 0, mpidr 80000000
> Setting up static identity map for 0x40100000 - 0x40100058
> CPU1: thread -1, cpu 1, socket 0, mpidr 80000001
> Brought up 2 CPUs
> SMP: Total of 2 processors activated (2132.00 BogoMIPS).
> CPU: All CPU(s) started in SVC mode.
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 1 at mm/slab.c:976 setup_kmem_cache_node+0x198/0x1c8
> Modules linked in:
> CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W
> 4.6.0-kzm9d-05060-g801faf0db8947e01-dirty #84
> Hardware name: Generic Emma Mobile EV2 (Flattened Device Tree)
> [<c010de08>] (unwind_backtrace) from [<c010a620>] (show_stack+0x10/0x14)
> [<c010a620>] (show_stack) from [<c02b3178>] (dump_stack+0x7c/0x9c)
> [<c02b3178>] (dump_stack) from [<c011f9fc>] (__warn+0xcc/0xfc)
> [<c011f9fc>] (__warn) from [<c011fad0>] (warn_slowpath_null+0x1c/0x24)
> [<c011fad0>] (warn_slowpath_null) from [<c01ced84>]
> (setup_kmem_cache_node+0x198/0x1c8)
> [<c01ced84>] (setup_kmem_cache_node) from [<c01cf02c>]
> (__do_tune_cpucache+0xf4/0x114)
> [<c01cf02c>] (__do_tune_cpucache) from [<c01cf0b0>] (enable_cpucache+0x64/0xb4)
> [<c01cf0b0>] (enable_cpucache) from [<c01cf4cc>]
> (__kmem_cache_create+0x1a0/0x1c8)
> [<c01cf4cc>] (__kmem_cache_create) from [<c01b2904>]
> (kmem_cache_create+0xbc/0x190)
> [<c01b2904>] (kmem_cache_create) from [<c070d724>] (shmem_init+0x34/0xb0)
> [<c070d724>] (shmem_init) from [<c0700cc4>] (kernel_init_freeable+0x98/0x1ec)
> [<c0700cc4>] (kernel_init_freeable) from [<c0497760>] (kernel_init+0x8/0x110)
> [<c0497760>] (kernel_init) from [<c0106c78>] (ret_from_fork+0x14/0x3c)
> ---[ end trace cb88537fdc8fa201 ]---
> devtmpfs: initialized
> VFP support v0.3: implementor 41 architecture 3 part 30 variant 9 rev 1
> clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff,
> max_idle_ns: 19112604462750000 ns
> pinctrl core: initialized pinctrl subsystem
> NET: Registered protocol family 16
> DMA: preallocated 256 KiB pool for atomic coherent allocations
> sh-pfc e0140200.pfc: emev2_pfc support registered
> gpiochip_find_base: found new base at 992
> gpio gpiochip0: (e0050000.gpio): created GPIO range 0->31 ==>
> e0140200.pfc PIN 0->31
> gpio gpiochip0: (e0050000.gpio): added GPIO chardev (254:0)
> gpiochip_setup_dev: registered GPIOs 992 to 1023 on device: gpiochip0
> (e0050000.gpio)
> gpiochip_find_base: found new base at 960
> gpio gpiochip1: (e0050080.gpio): created GPIO range 0->31 ==>
> e0140200.pfc PIN 32->63
> gpio gpiochip1: (e0050080.gpio): added GPIO chardev (254:1)
> gpiochip_setup_dev: registered GPIOs 960 to 991 on device: gpiochip1
> (e0050080.gpio)
> gpiochip_find_base: found new base at 928
> gpio gpiochip2: (e0050100.gpio): created GPIO range 0->31 ==>
> e0140200.pfc PIN 64->95
> gpio gpiochip2: (e0050100.gpio): added GPIO chardev (254:2)
> gpiochip_setup_dev: registered GPIOs 928 to 959 on device: gpiochip2
> (e0050100.gpio)
> gpiochip_find_base: found new base at 896
> gpio gpiochip3: (e0050180.gpio): created GPIO range 0->31 ==>
> e0140200.pfc PIN 96->127
> gpio gpiochip3: (e0050180.gpio): added GPIO chardev (254:3)
> gpiochip_setup_dev: registered GPIOs 896 to 927 on device: gpiochip3
> (e0050180.gpio)
> gpiochip_find_base: found new base at 865
> gpio gpiochip4: (e0050200.gpio): created GPIO range 0->30 ==>
> e0140200.pfc PIN 128->158
> gpio gpiochip4: (e0050200.gpio): added GPIO chardev (254:4)
> gpiochip_setup_dev: registered GPIOs 865 to 895 on device: gpiochip4
> (e0050200.gpio)
> gio: map hw irq = 1, irq = 35
> gio: sense irq = 1, mode = 8
> No ATAGs?
> hw-breakpoint: found 5 (+1 reserved) breakpoint and 1 watchpoint registers.
> hw-breakpoint: maximum watchpoint size is 4 bytes.
> of_get_named_gpiod_flags: can't parse 'gpio' property of node '/regulator@0[0]'
> of_get_named_gpiod_flags: can't parse 'gpio' property of node '/regulator@1[0]'
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> em_sti e0180000.timer: used for clock events
> em_sti e0180000.timer: used for oneshot clock events
> em_sti e0180000.timer: used as clock source
> clocksource: e0180000.timer: mask: 0xffffffffffff max_cycles:
> 0x1ef4687b1, max_idle_ns: 3697658158765000000 ns
> Advanced Linux Sound Architecture Driver Initialized.
> NET: Registered protocol family 23
> clocksource: e0180000.timer: mask: 0xffffffffffff max_cycles:
> 0x1ef4687b1, max_idle_ns: 112843571739654 ns
> clocksource: Switched to clocksource e0180000.timer
> NET: Registered protocol family 2
> TCP established hash table entries: 1024 (order: 0, 4096 bytes)
> TCP bind hash table entries: 1024 (order: 2, 20480 bytes)
> TCP: Hash tables configured (established 1024 bind 1024)
> UDP hash table entries: 256 (order: 1, 12288 bytes)
> UDP-Lite hash table entries: 256 (order: 1, 12288 bytes)
> NET: Registered protocol family 1
> RPC: Registered named UNIX socket transport module.
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> Clockevents: could not switch to one-shot mode:
> Clockevents: could not switch to one-shot mode: dummy_timer is not functional.
> Could not switch to high resolution mode on CPU 0
>  dummy_timer is not functional.
> Could not switch to high resolution mode on CPU 1
> hw perfevents: enabled with armv7_cortex_a9 PMU driver, 7 counters available
> futex hash table entries: 512 (order: 3, 32768 bytes)
> workingset: timestamp_bits=28 max_order=15 bucket_order=0
> NFS: Registering the id_resolver key type
> Key type id_resolver registered
> Key type id_legacy registered
> nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> io scheduler noop registered (default)
> Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
> e1020000.serial: ttyS0 at MMIO 0xe1020000 (irq = 19, base_baud =
> 796444) is a 16550A
> e1030000.serial: ttyS1 at MMIO 0xe1030000 (irq = 20, base_baud =
> 7168000) is a 16550A
> console [ttyS1] enabled
> e1040000.serial: ttyS2 at MMIO 0xe1040000 (irq = 21, base_baud =
> 14336000) is a 16550A
> e1050000.serial: ttyS3 at MMIO 0xe1050000 (irq = 22, base_baud =
> 2389333) is a 16550A
> gio: sense irq = 1, mode = 8
> libphy: smsc911x-mdio: probed
> Generic PHY 20000000.etherne:01: attached PHY driver [Generic PHY]
> (mii_bus:phy_addr=20000000.etherne:01, irq=-1)
> smsc911x 20000000.ethernet eth0: MAC Address: 00:01:9b:04:03:cf
> usbcore: registered new interface driver usb-storage
> i2c /dev entries driver
> em-i2c e0070000.i2c: Added i2c controller 0, irq 33
> em-i2c e10a0000.i2c: Added i2c controller 1, irq 34
> cpu cpu0: failed to get clock: -2
> cpufreq-dt: probe of cpufreq-dt failed with error -2
> ledtrig-cpu: registered to indicate activity on CPUs
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> NET: Registered protocol family 17
> Key type dns_resolver registered
> Registering SWP/SWPB emulation handler
> of_get_named_gpiod_flags: parsed 'gpios' property of node
> '/gpio_keys/button@1[0]' - status (0)
> of_get_named_gpiod_flags: parsed 'gpios' property of node
> '/gpio_keys/button@2[0]' - status (0)
> of_get_named_gpiod_flags: parsed 'gpios' property of node
> '/gpio_keys/button@3[0]' - status (0)
> of_get_named_gpiod_flags: parsed 'gpios' property of node
> '/gpio_keys/button@4[0]' - status (0)
> gpio-1006 (DSW2-1): gpiod_set_debounce: missing set() or
> set_debounce() operations
> gio: map hw irq = 14, irq = 36
> gio: sense irq = 14, mode = 12
> gpio-1007 (DSW2-2): gpiod_set_debounce: missing set() or
> set_debounce() operations
> gio: map hw irq = 15, irq = 37
> gio: sense irq = 15, mode = 12
> gpio-1008 (DSW2-3): gpiod_set_debounce: missing set() or
> set_debounce() operations
> gio: map hw irq = 16, irq = 38
> gio: sense irq = 16, mode = 12
> gpio-1009 (DSW2-4): gpiod_set_debounce: missing set() or
> set_debounce() operations
> gio: map hw irq = 17, irq = 39
> gio: sense irq = 17, mode = 12
> input: gpio_keys as /devices/platform/gpio_keys/input/input0
> hctosys: unable to open rtc device (rtc0)
> smsc911x 20000000.ethernet eth0: SMSC911x/921x identified at 0xc8880000, IRQ: 35
> Sending DHCP requests .., OK
> IP-Config: Got DHCP answer from 192.168.97.254, my address is 192.168.97.215
> IP-Config: Complete:
>      device=eth0, hwaddr=00:01:9b:04:03:cf, ipaddr=192.168.97.215,
> mask=255.255.255.0, gw=192.168.97.254
>      host=192.168.97.215, domain=of.borg, nis-domain=(none)
>      bootserver=192.168.97.254, rootserver=192.168.97.254, rootpath=
>   nameserver0=192.168.97.254
> ALSA device list:
>   No soundcards found.
> Freeing unused kernel memory: 2048K (c0700000 - c0900000)
> sysctl: error: 'kernel.hotplug' is an unknown key
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
