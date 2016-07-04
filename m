Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBBD6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 10:57:13 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so395530755pfa.2
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 07:57:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id l82si4542782pfa.120.2016.07.04.07.57.12
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 07:57:12 -0700 (PDT)
Subject: Re: kmem_cache_alloc fail with unable to handle paging request after
 pci hotplug remove.
References: <577A7203.9010305@linux.intel.com>
 <CAJZ5v0ji9pVgAZZJT+RG83RNE4-GgJAp88Mw2ddVt3H6eHG72g@mail.gmail.com>
From: Mathias Nyman <mathias.nyman@linux.intel.com>
Message-ID: <577A7B0A.4090107@linux.intel.com>
Date: Mon, 4 Jul 2016 18:04:42 +0300
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0ji9pVgAZZJT+RG83RNE4-GgJAp88Mw2ddVt3H6eHG72g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux PCI <linux-pci@vger.kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, USB <linux-usb@vger.kernel.org>, acelan@gmail.com

On 04.07.2016 17:25, Rafael J. Wysocki wrote:
> On Mon, Jul 4, 2016 at 4:26 PM, Mathias Nyman
> <mathias.nyman@linux.intel.com> wrote:
>> Hi
>>
>> AceLan Kao can get his DELL XPS 13 laptop to hang by plugging/un-plugging
>> a USB 3.1 key via thunderbolt port.
>>
>> Allocating memory fails after this, always pointing to NULL pointer or
>> page request failing in get_freepointer() called by
>> kmalloc/kmem_cache_alloc.
>>
>> Unplugging a usb type-c device from the thunderbolt port on Alpine Ridge
>> based
>> systems like this one will hotplug remove PCI bridges together with the USB
>> xhci
>> controller behind them.
>>
>> [   61.969221] usb 4-1: USB disconnect, device number 2
>> [   61.992892] xhci_hcd 0000:39:00.0: Host not halted after 16000
>> microseconds.
>> [   61.994002] xhci_hcd 0000:39:00.0: USB bus 4 deregistered
>> [   61.994013] xhci_hcd 0000:39:00.0: remove, state 4
>> [   61.994022] usb usb3: USB disconnect, device number 1
>> [   61.995317] xhci_hcd 0000:39:00.0: USB bus 3 deregistered
>> [   61.995949] pci_bus 0000:03: busn_res: [bus 03] is released
>> [   61.996022] pci_bus 0000:04: busn_res: [bus 04-38] is released
>> [   62.016460] pci_bus 0000:39: busn_res: [bus 39] is released
>> [   62.016515] pci_bus 0000:02: busn_res: [bus 02-39] is released
>> [   62.103618] BUG: unable to handle kernel NULL pointer dereference at
>> 0000000000000001
>> [   62.103651] IP: [<ffffffff811eb67b>] kmem_cache_alloc_trace+0x7b/0x1f0
>> [   62.103681] PGD 0
>> [   62.103689] Oops: 0000 [#1] SMP
>> [   62.103702] Modules linked in:
>>
>> [   62.104303] CPU: 3 PID: 993 Comm: Xorg Tainted: G           OE
>> 4.4.0-28-generic #47-Ubuntu
>> [   62.104345] Hardware name: Dell Inc. XPS 13 9360/      , BIOS 0.1.7
>> 06/22/2016
>> [   62.104383] task: ffff88006f3a8000 ti: ffff880078fa0000 task.ti:
>> ffff880078fa0000
>> [   62.104420] RIP: 0010:[<ffffffff811eb67b>]  [<ffffffff811eb67b>]
>> kmem_cache_alloc_trace+0x7b/0x1f0
>> [   62.104468] RSP: 0018:ffff880078fa3c70  EFLAGS: 00010202
>> [   62.104495] RAX: 0000000000000000 RBX: 00000000024000c0 RCX:
>> 0000000000010d87
>> [   62.104530] RDX: 0000000000010d86 RSI: 00000000024000c0 RDI:
>> 0000000000019f80
>> [   62.104565] RBP: ffff880078fa3cb0 R08: ffff88017e599f80 R09:
>> ffff880179801b00
>> [   62.104603] R10: 0000000000000001 R11: 000000000000007c R12:
>> 00000000024000c0
>> [   62.104641] R13: ffffffffc00c1b1a R14: ffff88017485a000 R15:
>> ffff880179801b00
>> [   62.104680] FS:  00007fe6a0241a00(0000) GS:ffff88017e580000(0000)
>> knlGS:0000000000000000
>> [   62.104722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   62.104752] CR2: 0000000000000001 CR3: 0000000177234000 CR4:
>> 00000000003406e0
>> [   62.104789] Stack:
>> [   62.104801]  ffff880078fa3cd8 ffffffff813ec8ee 0000000000000028
>> ffff8801759d4fd8
>> [   62.104847]  ffff8801785d8b00 ffff880174f9be60 ffff88017485a000
>> 000000000000007c
>> [   62.104892]  ffff880078fa3cd8 ffffffffc00c1b1a ffff8801759d4fc0
>> ffff880174f9be00
>> [   62.104938] Call Trace:
>> [   62.104956]  [<ffffffff813ec8ee>] ? idr_alloc+0x9e/0x110
>> [   62.105005]  [<ffffffffc00c1b1a>] drm_vma_node_allow+0x2a/0xc0 [drm]
>> [   62.105047]  [<ffffffffc00a7d43>] drm_gem_handle_create_tail+0xc3/0x190
>> [drm]
>> [   62.105088]  [<ffffffffc00a7e45>] drm_gem_handle_create+0x35/0x40 [drm]
>> [   62.105145]  [<ffffffffc01cf531>] i915_gem_userptr_ioctl+0x271/0x350
>> [i915_bpo]
>> [   62.105190]  [<ffffffffc00a8742>] drm_ioctl+0x152/0x540 [drm]
>> [   62.105235]  [<ffffffffc01cf2c0>] ?
>> __i915_gem_userptr_get_pages_worker+0x320/0x320 [i915_bpo]
>> [   62.105262]  [<ffffffff81220b6f>] do_vfs_ioctl+0x29f/0x490
>> [   62.105281]  [<ffffffff81701610>] ? __sys_recvmsg+0x80/0x90
>> [   62.105298]  [<ffffffff81220dd9>] SyS_ioctl+0x79/0x90
>> [   62.105319]  [<ffffffff818276b2>] entry_SYSCALL_64_fastpath+0x16/0x71
>> [   62.105346] Code: 08 65 4c 03 05 2f eb e1 7e 49 83 78 10 00 4d 8b 10 0f
>> 84 21 01 00 00 4d 85 d2 0f 84 18 01 00 00 49 63 41 20 48 8d 4a 01 49 8b 39
>> <49> 8b 1c 02 4c 89 d0 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63
>> [   62.105520] RIP  [<ffffffff811eb67b>] kmem_cache_alloc_trace+0x7b/0x1f0
>> [   62.105543]  RSP <ffff880078fa3c70>
>> [   62.105554] CR2: 0000000000000001
>> [   62.113016] ---[ end trace 4f9991d2eebd1637 ]---
>>
>> (gdb) list *(kmem_cache_alloc_trace+0x7b)
>> 0xffffffff811eb67b is in kmem_cache_alloc_trace
>> (/build/linux-BvkamA/linux-4.4.0/mm/slub.c:247).
>> 242             return 1;
>> 243     }
>> 244
>> 245     static inline void *get_freepointer(struct kmem_cache *s, void
>> *object)
>> 246     {
>> 247             return *(void **)(object + s->offset);
>> 248     }
>> 249
>> 250     static void prefetch_freepointer(const struct kmem_cache *s, void
>> *object)
>> 251     {
>>
>> More logs can be found at
>> https://bugzilla.kernel.org/show_bug.cgi?id=120241
>>
>> This log was from a 4.4 based ubuntu kernel, but the same issue was
>> reproduced
>> with 4.7-rc5. Call trace often point to various graphics related drivers,
>> but
>> also xhci and acpi_hotplug_work_fn.
>> Only thing they have in common is that they fail while trying to allocate
>> memory.
>>
>> A log of acpi_hotplug_work_fn failing to allocate memory while removing pci
>> devices:
>> https://bugzilla.kernel.org/attachment.cgi?id=221561
>>
>> I've been looking at this from xhci perspective, but it starts to go too
>> deep
>> into mm, pci hotplug etc for my understanding.
>>
>> Any ideas?
>
> Are you able to reproduce this by unplugging and replugging the entire
> Thunderbolt link?

As I understood it should be gone as well,
I can't reproduce this myself, I have a slightly different DELL XPS
than AceLan Kao. For me lspci looks like this:

** lspci before usb remove: **

-[0000:00]-+-00.0
            +-01.0-[01]----00.0
            +-02.0
            +-04.0
            +-14.0
            +-14.2
            +-15.0
            +-15.1
            +-16.0
            +-17.0
            +-1c.0-[02]----00.0
            +-1c.1-[03]----00.0
            +-1d.0-[04]--
            +-1d.4-[05]--
            +-1d.6-[06-3e]----00.0-[07-3e]--+-00.0-[08]--
            |                               +-01.0-[09-3d]--
            |                               \-02.0-[3e]----00.0
            +-1f.0
            +-1f.2
            +-1f.3
            \-1f.4

00:00.0 Host bridge: Intel Corporation Sky Lake Host Bridge/DRAM Registers (rev 07)
00:01.0 PCI bridge: Intel Corporation Sky Lake PCIe Controller (x16) (rev 07)
00:02.0 VGA compatible controller: Intel Corporation Skylake Integrated Graphics (rev 06)
00:04.0 Signal processing controller: Intel Corporation Skylake Processor Thermal Subsystem (rev 07)
00:14.0 USB controller: Intel Corporation Sunrise Point-H USB 3.0 xHCI Controller (rev 31)
00:14.2 Signal processing controller: Intel Corporation Sunrise Point-H Thermal subsystem (rev 31)
00:15.0 Signal processing controller: Intel Corporation Sunrise Point-H LPSS I2C Controller #0 (rev 31)
00:15.1 Signal processing controller: Intel Corporation Sunrise Point-H LPSS I2C Controller #1 (rev 31)
00:16.0 Communication controller: Intel Corporation Sunrise Point-H CSME HECI #1 (rev 31)
00:17.0 SATA controller: Intel Corporation Sunrise Point-H SATA Controller [AHCI mode] (rev 31)
00:1c.0 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #1 (rev f1)
00:1c.1 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #2 (rev f1)
00:1d.0 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #9 (rev f1)
00:1d.4 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #13 (rev f1)
00:1d.6 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #15 (rev f1)
00:1f.0 ISA bridge: Intel Corporation Sunrise Point-H LPC Controller (rev 31)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-H PMC (rev 31)
00:1f.3 Audio device: Intel Corporation Sunrise Point-H HD Audio (rev 31)
00:1f.4 SMBus: Intel Corporation Sunrise Point-H SMBus (rev 31)
01:00.0 3D controller: NVIDIA Corporation GM107M [GeForce GTX 960M] (rev a2)
02:00.0 Network controller: Broadcom Corporation BCM43602 802.11ac Wireless LAN SoC (rev 01)
03:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS525A PCI Express Card Reader (rev 01)
06:00.0 PCI bridge: Intel Corporation Device 1576
07:00.0 PCI bridge: Intel Corporation Device 1576
07:01.0 PCI bridge: Intel Corporation Device 1576
07:02.0 PCI bridge: Intel Corporation Device 1576
3e:00.0 USB controller: Intel Corporation Device 15b5

** lspci after unplug **

-[0000:00]-+-00.0
            +-01.0-[01]----00.0
            +-02.0
            +-04.0
            +-14.0
            +-14.2
            +-15.0
            +-15.1
            +-16.0
            +-17.0
            +-1c.0-[02]----00.0
            +-1c.1-[03]----00.0
            +-1d.0-[04]--
            +-1d.4-[05]--
            +-1d.6-[06-3e]--
            +-1f.0
            +-1f.2
            +-1f.3
            \-1f.4

00:00.0 Host bridge: Intel Corporation Sky Lake Host Bridge/DRAM Registers (rev 07)
00:01.0 PCI bridge: Intel Corporation Sky Lake PCIe Controller (x16) (rev 07)
00:02.0 VGA compatible controller: Intel Corporation Skylake Integrated Graphics (rev 06)
00:04.0 Signal processing controller: Intel Corporation Skylake Processor Thermal Subsystem (rev 07)
00:14.0 USB controller: Intel Corporation Sunrise Point-H USB 3.0 xHCI Controller (rev 31)
00:14.2 Signal processing controller: Intel Corporation Sunrise Point-H Thermal subsystem (rev 31)
00:15.0 Signal processing controller: Intel Corporation Sunrise Point-H LPSS I2C Controller #0 (rev 31)
00:15.1 Signal processing controller: Intel Corporation Sunrise Point-H LPSS I2C Controller #1 (rev 31)
00:16.0 Communication controller: Intel Corporation Sunrise Point-H CSME HECI #1 (rev 31)
00:17.0 SATA controller: Intel Corporation Sunrise Point-H SATA Controller [AHCI mode] (rev 31)
00:1c.0 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #1 (rev f1)
00:1c.1 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #2 (rev f1)
00:1d.0 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #9 (rev f1)
00:1d.4 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #13 (rev f1)
00:1d.6 PCI bridge: Intel Corporation Sunrise Point-H PCI Express Root Port #15 (rev f1)
00:1f.0 ISA bridge: Intel Corporation Sunrise Point-H LPC Controller (rev 31)
00:1f.2 Memory controller: Intel Corporation Sunrise Point-H PMC (rev 31)
00:1f.3 Audio device: Intel Corporation Sunrise Point-H HD Audio (rev 31)
00:1f.4 SMBus: Intel Corporation Sunrise Point-H SMBus (rev 31)
01:00.0 3D controller: NVIDIA Corporation GM107M [GeForce GTX 960M] (rev a2)
02:00.0 Network controller: Broadcom Corporation BCM43602 802.11ac Wireless LAN SoC (rev 01)
03:00.0 Unassigned class [ff00]: Realtek Semiconductor Co., Ltd. RTS525A PCI Express Card Reader (rev 01)

-Mathias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
