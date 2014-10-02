Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C047C6B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 01:35:37 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so1669973pac.14
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 22:35:37 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zo3si2810118pac.176.2014.10.01.22.35.34
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 22:35:36 -0700 (PDT)
Date: Thu, 2 Oct 2014 14:35:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mm/slab] BUG: unable to handle kernel paging request at 00010023
Message-ID: <20141002053544.GB7433@js1304-P5Q-DELUXE>
References: <20140930075624.GA9561@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140930075624.GA9561@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 30, 2014 at 03:56:24PM +0800, Fengguang Wu wrote:
> Hi Joonsoo,
> 
> 0day kernel testing robot got the below dmesg and the first bad commit is
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> 
> commit 36fbfebe776eb5871d61e7a755c9feb1c96cc4aa
> Author:     Joonsoo Kim <iamjoonsoo.kim@lge.com>
> AuthorDate: Tue Sep 23 11:52:35 2014 +1000
> Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> CommitDate: Tue Sep 23 11:52:35 2014 +1000
> 
>     mm/slab: support slab merge
>     
>     Slab merge is good feature to reduce fragmentation.  If new creating slab
>     have similar size and property with exsitent slab, this feature reuse it
>     rather than creating new one.  As a result, objects are packed into fewer
>     slabs so that fragmentation is reduced.
>     
>     Below is result of my testing.
>     
>     * After boot, sleep 20; cat /proc/meminfo | grep Slab
>     
>     <Before>
>     Slab: 25136 kB
>     
>     <After>
>     Slab: 24364 kB
>     
>     We can save 3% memory used by slab.
>     
>     For supporting this feature in SLAB, we need to implement SLAB specific
>     kmem_cache_flag() and __kmem_cache_alias(), because SLUB implements some
>     SLUB specific processing related to debug flag and object size change on
>     these functions.
>     
>     Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>     Cc: Christoph Lameter <cl@linux.com>
>     Cc: Pekka Enberg <penberg@kernel.org>
>     Cc: David Rientjes <rientjes@google.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> +----------------------------------------------+------------+------------+---------------+
> |                                              | 8c087489b8 | 36fbfebe77 | next-20140923 |
> +----------------------------------------------+------------+------------+---------------+
> | boot_successes                               | 60         | 0          | 1             |
> | boot_failures                                | 0          | 20         | 314           |
> | BUG:unable_to_handle_kernel                  | 0          | 20         | 312           |
> | Oops                                         | 0          | 20         | 312           |
> | EIP_is_at_kernfs_link_sibling                | 0          | 4          | 14            |
> | Kernel_panic-not_syncing:Fatal_exception     | 0          | 20         | 312           |
> | backtrace:acpi_bus_scan                      | 0          | 4          | 14            |
> | backtrace:acpi_scan_init                     | 0          | 20         | 45            |
> | backtrace:acpi_init                          | 0          | 20         | 45            |
> | backtrace:kernel_init_freeable               | 0          | 20         | 312           |
> | EIP_is_at_kernfs_add_one                     | 0          | 16         | 298           |
> | backtrace:kobject_add_internal               | 0          | 16         | 31            |
> | backtrace:kobject_init_and_add               | 0          | 16         | 31            |
> | backtrace:acpi_scan_add_handler_with_hotplug | 0          | 16         | 31            |
> | backtrace:acpi_pci_root_init                 | 0          | 16         | 31            |
> | backtrace:tty_register_driver                | 0          | 0          | 106           |
> | backtrace:pty_init                           | 0          | 0          | 106           |
> | backtrace:acpi_bus_register_driver           | 0          | 0          | 1             |
> | backtrace:acpi_button_driver_init            | 0          | 0          | 1             |
> | BUG:kernel_boot_crashed                      | 0          | 0          | 1             |
> | BUG:kernel_test_crashed                      | 0          | 0          | 1             |
> | backtrace:subsys_system_register             | 0          | 0          | 160           |
> | backtrace:container_dev_init                 | 0          | 0          | 160           |
> | backtrace:driver_init                        | 0          | 0          | 160           |
> +----------------------------------------------+------------+------------+---------------+
> 
> [    0.463788] ACPI: (supports S0 S5)
> [    0.464003] ACPI: Using IOAPIC for interrupt routing
> [    0.464738] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
> [    0.466034] BUG: unable to handle kernel paging request at 00010023
> [    0.466989] IP: [<c117dcf9>] kernfs_add_one+0x89/0x130
> [    0.467812] *pdpt = 0000000000000000 *pde = f000ff53f000ff53 
> [    0.468000] Oops: 0002 [#1] SMP 
> [    0.468000] Modules linked in:
> [    0.468000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0-rc6-00089-g36fbfeb #1
> [    0.468000] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [    0.468000] task: d303ec90 ti: d3040000 task.ti: d3040000
> [    0.468000] EIP: 0060:[<c117dcf9>] EFLAGS: 00010286 CPU: 0
> [    0.468000] EIP is at kernfs_add_one+0x89/0x130
> [    0.468000] EAX: 542572cb EBX: 00010003 ECX: 00000008 EDX: 2c8de598
> [    0.468000] ESI: d311de10 EDI: d311de70 EBP: d3041dd8 ESP: d3041db4
> [    0.468000]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [    0.468000] CR0: 8005003b CR2: 00010023 CR3: 01a8a000 CR4: 000006f0
> [    0.468000] Stack:
> [    0.468000]  d3006f00 00000202 d311de70 d311de10 d3041dd8 c117dba0 d311de10 c159a5c0
> [    0.468000]  c1862a00 d3041df0 c117f0f2 00000000 c18629f4 d311de70 00000000 d3041e2c
> [    0.468000]  c117f8b5 00001000 00000000 c159a5c0 c18629f4 00000000 00000001 c1862a00
> [    0.468000] Call Trace:
> [    0.468000]  [<c117dba0>] ? kernfs_new_node+0x30/0x40
> [    0.468000]  [<c117f0f2>] __kernfs_create_file+0x92/0xc0
> [    0.468000]  [<c117f8b5>] sysfs_add_file_mode_ns+0x95/0x190
> [    0.468000]  [<c117f9d7>] sysfs_create_file_ns+0x27/0x40
> [    0.468000]  [<c1252ef6>] kobject_add_internal+0x136/0x2c0
> [    0.468000]  [<c125e360>] ? kvasprintf+0x40/0x50
> [    0.468000]  [<c1252a92>] ? kobject_set_name_vargs+0x42/0x60
> [    0.468000]  [<c12530b5>] kobject_init_and_add+0x35/0x50
> [    0.468000]  [<c12ad04f>] acpi_sysfs_add_hotplug_profile+0x24/0x4a
> [    0.468000]  [<c12a7280>] acpi_scan_add_handler_with_hotplug+0x21/0x28
> [    0.468000]  [<c18df524>] acpi_pci_root_init+0x20/0x22
> [    0.468000]  [<c18df0e1>] acpi_scan_init+0x24/0x16d
> [    0.468000]  [<c18def73>] acpi_init+0x20c/0x224
> [    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
> [    0.468000]  [<c100041e>] do_one_initcall+0x7e/0x1b0
> [    0.468000]  [<c18ded67>] ? acpi_sleep_init+0xab/0xab
> [    0.468000]  [<c18b24ba>] ? repair_env_string+0x12/0x54
> [    0.468000]  [<c18b24a8>] ? initcall_blacklist+0x7c/0x7c
> [    0.468000]  [<c105e100>] ? parse_args+0x160/0x3f0
> [    0.468000]  [<c18b2bd1>] kernel_init_freeable+0xfc/0x179
> [    0.468000]  [<c156782b>] kernel_init+0xb/0xd0
> [    0.468000]  [<c1574601>] ret_from_kernel_thread+0x21/0x30
> [    0.468000]  [<c1567820>] ? rest_init+0xb0/0xb0
> [    0.468000] Code: 26 00 83 e1 10 75 5b 8b 46 24 e8 b3 ea ff ff 89 46 38 89 f0 e8 d9 f9 ff ff 85 c0 89 c3 75 ca 8b 5f 5c 85 db 74 11 e8 97 90 f1 ff <89> 43 20 89 53 24 89 43 28 89 53 2c b8 c0 2f 85 c1 e8 d1 36 3f
> [    0.468000] EIP: [<c117dcf9>] kernfs_add_one+0x89/0x130 SS:ESP 0068:d3041db4
> [    0.468000] CR2: 0000000000010023
> [    0.468000] ---[ end trace 4fa173691404b63f ]---
> [    0.468000] Kernel panic - not syncing: Fatal exception
> 
> git bisect start 55f21306900abf9f9d2a087a127ff49c6d388ad2 0f33be009b89d2268e94194dc4fd01a7851b6d51 --
> git bisect good 18c13e2d9b75e2760e6520f2fde00401192956f3  # 17:56     20+      0  Merge remote-tracking branch 'bluetooth/master'
> git bisect good abf79495f38ba66f750566b3f0a8da8dd94b4dc3  # 18:03     20+      0  Merge remote-tracking branch 'ftrace/for-next'
> git bisect good 0bed22034e26a3c37ee4407fccffa8c095d5e144  # 18:09     20+      0  Merge remote-tracking branch 'pinctrl/for-next'
> git bisect good 15c9281a15ed7718868d115d4d00619b0b7a2624  # 18:14     20+      0  Merge remote-tracking branch 'clk/clk-next'
> git bisect good 50939531dea1b913b7fa29f9bbc69feafefd090c  # 18:23     20+      0  Merge branch 'rd-docs/master'
> git bisect good aa881e3c5e87c8aa23519f40554897d56f32b935  # 18:49     20+      0  Merge remote-tracking branch 'powerpc-mpe/next'
> git bisect  bad 81b63d14db32bd7706c955d1e04e65b152b2277a  # 18:57      0-      2  Merge branch 'akpm-current/current'
> git bisect  bad f313ca82d72066a3c44fd6c66cee57b25de43aa9  # 19:31      0-      1  introduce-dump_vma-fix
> git bisect good 2c5fe9213048c5640b8e46407f5614038c03ad93  # 20:16     20+      0  mm: fix kmemcheck.c build errors
> git bisect  bad 69454f8be7f621ac8c3c6c9763bb70e116988942  # 20:35      0-     18  block_dev: implement readpages() to optimize sequential read
> git bisect  bad 66a31d528a1e3d483be2b1c993ec1268412f0074  # 20:40      0-      1  memory-hotplug-add-sysfs-zones_online_to-attribute-fix-2
> git bisect good 5e8acb68610c077b08cb3f16305aa3cc22e5d2a8  # 21:07     20+      0  kernel/kthread.c: partial revert of 81c98869faa5 ("kthread: ensure locality of task_struct allocations")
> git bisect  bad 36fbfebe776eb5871d61e7a755c9feb1c96cc4aa  # 22:06      0-     10  mm/slab: support slab merge
> git bisect good 11e57381eced875ef5a6fea4005fdf72b6f68eff  # 22:19     20+      0  mm/slab_common: commonize slab merge logic
> git bisect good 8c087489b8a32b9235f7f9417390c62d93aba522  # 22:24     20+      0  mm/slab_common: fix build failure if CONFIG_SLUB
> # first bad commit: [36fbfebe776eb5871d61e7a755c9feb1c96cc4aa] mm/slab: support slab merge
> git bisect good 8c087489b8a32b9235f7f9417390c62d93aba522  # 22:26     60+      0  mm/slab_common: fix build failure if CONFIG_SLUB
> git bisect  bad 55f21306900abf9f9d2a087a127ff49c6d388ad2  # 22:26      0-    314  Add linux-next specific files for 20140923
> git bisect good f4cb707e7ad9727a046b463232f2de166e327d3e  # 22:32     60+      0  Merge tag 'pm+acpi-3.17-rc7' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
> git bisect  bad 4d8426f9ac601db2a64fa7be64051d02b9c9fe01  # 22:36      0-     60  Add linux-next specific files for 20140926
> 
> 
> This script may reproduce the error.
> 
> ----------------------------------------------------------------------------
> #!/bin/bash
> 
> kernel=$1
> 
> kvm=(
> 	qemu-system-x86_64
> 	-cpu kvm64
> 	-enable-kvm
> 	-kernel $kernel
> 	-m 320
> 	-smp 1
> 	-net nic,vlan=1,model=e1000
> 	-net user,vlan=1
> 	-boot order=nc
> 	-no-reboot
> 	-watchdog i6300esb
> 	-rtc base=localtime
> 	-serial stdio
> 	-display none
> 	-monitor null 
> )
> 
> append=(
> 	hung_task_panic=1
> 	earlyprintk=ttyS0,115200
> 	debug
> 	apic=debug
> 	sysrq_always_enabled
> 	rcupdate.rcu_cpu_stall_timeout=100
> 	panic=-1
> 	softlockup_panic=1
> 	nmi_watchdog=panic
> 	oops=panic
> 	load_ramdisk=2
> 	prompt_ramdisk=0
> 	console=ttyS0,115200
> 	console=tty0
> 	vga=normal
> 	root=/dev/ram0
> 	rw
> 	drbd.minor_count=8
> )
> 
> "${kvm[@]}" --append "${append[*]}"
> ----------------------------------------------------------------------------

Thanks Fengguang.
I can reproduce this bug in my system with your configuration.
Below is fix for this bug.

Hello Andrew,

Could you take this patch?

Thanks.

----------->8------------------
