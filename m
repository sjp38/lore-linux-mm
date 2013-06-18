Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 538866B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:05:21 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id jf17so1890007bkc.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 10:05:19 -0700 (PDT)
Date: Tue, 18 Jun 2013 19:05:15 +0200
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: Re: [Part3 PATCH v2 0/4] Support hot-remove local pagetable pages.
Message-ID: <20130618170515.GC4553@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

On Thu, Jun 13, 2013 at 09:03:52PM +0800, Tang Chen wrote:
> The following patch-set from Yinghai allocates pagetables to local nodes.
> v1: https://lkml.org/lkml/2013/3/7/642
> v2: https://lkml.org/lkml/2013/3/10/47
> v3: https://lkml.org/lkml/2013/4/4/639
> v4: https://lkml.org/lkml/2013/4/11/829
> 
> Since pagetable pages are used by the kernel, they cannot be offlined.
> As a result, they cannot be hot-remove.
> 
> This patch fix this problem with the following solution:
> 
>      1.   Introduce a new bootmem type LOCAL_NODE_DATAL, and register local
>           pagetable pages as LOCAL_NODE_DATAL by setting page->lru.next to
>           LOCAL_NODE_DATAL, just like we register SECTION_INFO pages.
> 
>      2.   Skip LOCAL_NODE_DATAL pages in offline/online procedures. When the
>           whole memory block they reside in is offlined, the kernel can
>           still access the pagetables.
>           (This changes the semantics of offline/online a little bit.)

This could be a design problem of part3: if we allow local pagetable memory
to not be offlined but allow the offlining to return successfully, then
hot-remove is going to succeed. But the direct mapped pagetable pages are still
mapped in the kernel. The hot-removed memblocks will suddenly disappear (think
physical DIMMs getting disabled in real hardware, or in a VM case the
corresponding guest memory getting freed from the emulator e.g. qemu/kvm). The
system can crash as a result.

I think these local pagetables do need to be unmapped from kernel, offlined and
removed somehow - otherwise hot-remove should fail. Could they be migrated
alternatively e.g. to node 0 memory?  But Iiuc direct mapped pages cannot be
migrated, correct?

What is the original reason for local node pagetable allocation with regards
to memory hotplug? I assume we want to have hotplugged nodes use only their local
memory, so that there are no inter-node memory dependencies for hot-add/remove.
Are there other reasons that I am missing?


I get a crash with the following:
- boot 2-node VM with 4G on node0 and 0G on node1
- guest kernel linux_next20130607 + part1 + part2 + part3 patchsets
- hotplugged 2 dimms on node1 (previosuly node 1 had no memory)
- reboot with movablecore=acpi, ZONE_MOVABLE is created for node1
- I verified that in this case LOCAL_NODE_DATA pages are allocated on node1
- remove a dimm on node1

[  260.615677] Offlined Pages 32768
[  260.619650] Offlined Pages 32768
[  260.630514] Offlined Pages 32768
[  260.634342] Offlined Pages 32768
[  260.637989] Offlined Pages 32768
[  260.642021] Offlined Pages 32768
[  260.643852] Offlined Pages 32768
[  260.645555] Offlined Pages 32768
[  260.817960] general protection fault: 0000 [#1] SMP 
[  260.818384] Modules linked in: netconsole pci_hotplug lp loop kvm_amd kvm ppdev psmouse parport_pc i2c_piix4 parport i2c_core serio_raw evdev processor microcode button thermal_sys ext3 jbd mbcache sr_mod cdrom ata_generic virtio_blk virtio_net ata_piix libata scsi_mod virtio_pci virtio_ring virtio
[  260.820449] CPU: 0 PID: 177 Comm: kworker/0:2 Not tainted 3.10.0-rc4-next-20130607-guest #1
[  260.820449] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  260.820449] Workqueue: kacpi_hotplug acpi_os_execute_deferred
[  260.820449] task: ffff880115c80080 ti: ffff880115564000 task.ti: ffff880115564000
[  260.820449] RIP: 0010:[<ffffffff812b92b9>]  [<ffffffff812b92b9>] memchr_inv+0x89/0x110
[  260.820449] RSP: 0018:ffff880115565b90  EFLAGS: 00010206
[  260.820449] RAX: 0000000008000000 RBX: ffff8801e0000000 RCX: 0000000000000000
[  260.820449] RDX: 0000000040000000 RSI: 00000000000000fd RDI: 7fff8801c0000000
[  260.820449] RBP: ffff8801e0000000 R08: 00000000000000fd R09: 0101010101010101
[  260.820449] R10: 0000000000000000 R11: ffff880116e38e50 R12: ffff880220000000
[  260.820449] R13: ffff8801c0000000 R14: 00003ffffffff000 R15: ffff880116e38e01
[  260.820449] FS:  00007fa6d8de37c0(0000) GS:ffff88011f000000(0000) knlGS:0000000000000000
[  260.820449] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  260.820449] CR2: 00007fa6d8dea000 CR3: 000000000180b000 CR4: 00000000000006f0
[  260.820449] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  260.820449] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  260.820449] Stack:
[  260.820449]  ffffffff8151e3bc 0000160000000000 ffffc00000000fff ffff880001a5d038
[  260.820449]  ffffffff8150e39e ffff880116e38e50 0000000000000100 0000000000000000
[  260.820449]  ffff8801e0000000 ffff8801181fb060 ffffffff8150e424 ffff88021ffff000
[  260.820449] Call Trace:
[  260.820449]  [<ffffffff8151e3bc>] ? remove_pagetable+0x20c/0x7f7
[  260.820449]  [<ffffffff8150e39e>] ? klist_put+0x4e/0xc0
[  260.820449]  [<ffffffff8150e424>] ? klist_iter_exit+0x14/0x20
[  260.820449]  [<ffffffff8150f385>] ? arch_remove_memory+0x75/0xd0
[  260.820449]  [<ffffffff81510e18>] ? remove_memory+0x68/0x80
[  260.820449]  [<ffffffff8132baa5>] ? acpi_memory_device_remove+0x90/0xea
[  260.820449]  [<ffffffff81308157>] ? acpi_bus_device_detach+0x37/0x5c
[  260.820449]  [<ffffffff813081b5>] ? acpi_bus_trim+0x39/0x6e
[  260.820449]  [<ffffffff81308c74>] ? acpi_scan_hot_remove+0x136/0x264
[  260.820449]  [<ffffffff81304b15>] ? acpi_evaluate_hotplug_ost+0x86/0x8b
[  260.820449]  [<ffffffff81308e3a>] ? acpi_bus_device_eject+0x98/0xcc
[  260.820449]  [<ffffffff813042ea>] ? acpi_os_execute_deferred+0x1f/0x2b
[  260.820449]  [<ffffffff8105a183>] ? process_one_work+0x153/0x480
[  260.820449]  [<ffffffff8105b2b6>] ? worker_thread+0x116/0x3d0
[  260.820449]  [<ffffffff8105b1a0>] ? manage_workers+0x2b0/0x2b0
[  260.820449]  [<ffffffff8105b1a0>] ? manage_workers+0x2b0/0x2b0
[  260.820449]  [<ffffffff81060b56>] ? kthread+0xc6/0xd0
[  260.820449]  [<ffffffff81060a90>] ? kthread_freezable_should_stop+0x60/0x60
[  260.820449]  [<ffffffff8152c6ec>] ? ret_from_fork+0x7c/0xb0
[  260.820449]  [<ffffffff81060a90>] ? kthread_freezable_should_stop+0x60/0x60
[  260.820449] Code: 75 f0 45 89 c0 4c 01 c7 4c 29 c2 0f 1f 80 00 00 00 00 48 89 d0 48 c1 e8 03 85 c0 74 2a 44 0f b6 c6 49 b9 01 01 01 01 01 01 01 01 <48> 8b 0f 4d 0f af c1 4c 39 c1 74 08 eb 41 90 48 3b 0f 75 3b 48 
[  260.820449] RIP  [<ffffffff812b92b9>] memchr_inv+0x89/0x110
[  260.820449]  RSP <ffff880115565b90>
[  260.852908] ---[ end trace 5e9b131e0294cfb6 ]---

I haven't analyzed more yet.

Other times instead of a crash on hot-remove I get a "fork: cannot allocate memory"
always after hot-remove.

thanks,

- Vasilis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
