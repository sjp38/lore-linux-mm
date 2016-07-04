Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE016B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 10:18:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so395199124pfx.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 07:18:43 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id f15si4543467pfk.58.2016.07.04.07.18.42
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 07:18:42 -0700 (PDT)
From: Mathias Nyman <mathias.nyman@linux.intel.com>
Subject: kmem_cache_alloc fail with unable to handle paging request after pci
 hotplug remove.
Message-ID: <577A7203.9010305@linux.intel.com>
Date: Mon, 4 Jul 2016 17:26:11 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-pci@vger.kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, USB <linux-usb@vger.kernel.org>, acelan@gmail.com

Hi

AceLan Kao can get his DELL XPS 13 laptop to hang by plugging/un-plugging
a USB 3.1 key via thunderbolt port.

Allocating memory fails after this, always pointing to NULL pointer or
page request failing in get_freepointer() called by kmalloc/kmem_cache_alloc.

Unplugging a usb type-c device from the thunderbolt port on Alpine Ridge based
systems like this one will hotplug remove PCI bridges together with the USB xhci
controller behind them.

[   61.969221] usb 4-1: USB disconnect, device number 2
[   61.992892] xhci_hcd 0000:39:00.0: Host not halted after 16000 microseconds.
[   61.994002] xhci_hcd 0000:39:00.0: USB bus 4 deregistered
[   61.994013] xhci_hcd 0000:39:00.0: remove, state 4
[   61.994022] usb usb3: USB disconnect, device number 1
[   61.995317] xhci_hcd 0000:39:00.0: USB bus 3 deregistered
[   61.995949] pci_bus 0000:03: busn_res: [bus 03] is released
[   61.996022] pci_bus 0000:04: busn_res: [bus 04-38] is released
[   62.016460] pci_bus 0000:39: busn_res: [bus 39] is released
[   62.016515] pci_bus 0000:02: busn_res: [bus 02-39] is released
[   62.103618] BUG: unable to handle kernel NULL pointer dereference at 0000000000000001
[   62.103651] IP: [<ffffffff811eb67b>] kmem_cache_alloc_trace+0x7b/0x1f0
[   62.103681] PGD 0
[   62.103689] Oops: 0000 [#1] SMP
[   62.103702] Modules linked in:

[   62.104303] CPU: 3 PID: 993 Comm: Xorg Tainted: G           OE   4.4.0-28-generic #47-Ubuntu
[   62.104345] Hardware name: Dell Inc. XPS 13 9360/      , BIOS 0.1.7 06/22/2016
[   62.104383] task: ffff88006f3a8000 ti: ffff880078fa0000 task.ti: ffff880078fa0000
[   62.104420] RIP: 0010:[<ffffffff811eb67b>]  [<ffffffff811eb67b>] kmem_cache_alloc_trace+0x7b/0x1f0
[   62.104468] RSP: 0018:ffff880078fa3c70  EFLAGS: 00010202
[   62.104495] RAX: 0000000000000000 RBX: 00000000024000c0 RCX: 0000000000010d87
[   62.104530] RDX: 0000000000010d86 RSI: 00000000024000c0 RDI: 0000000000019f80
[   62.104565] RBP: ffff880078fa3cb0 R08: ffff88017e599f80 R09: ffff880179801b00
[   62.104603] R10: 0000000000000001 R11: 000000000000007c R12: 00000000024000c0
[   62.104641] R13: ffffffffc00c1b1a R14: ffff88017485a000 R15: ffff880179801b00
[   62.104680] FS:  00007fe6a0241a00(0000) GS:ffff88017e580000(0000) knlGS:0000000000000000
[   62.104722] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   62.104752] CR2: 0000000000000001 CR3: 0000000177234000 CR4: 00000000003406e0
[   62.104789] Stack:
[   62.104801]  ffff880078fa3cd8 ffffffff813ec8ee 0000000000000028 ffff8801759d4fd8
[   62.104847]  ffff8801785d8b00 ffff880174f9be60 ffff88017485a000 000000000000007c
[   62.104892]  ffff880078fa3cd8 ffffffffc00c1b1a ffff8801759d4fc0 ffff880174f9be00
[   62.104938] Call Trace:
[   62.104956]  [<ffffffff813ec8ee>] ? idr_alloc+0x9e/0x110
[   62.105005]  [<ffffffffc00c1b1a>] drm_vma_node_allow+0x2a/0xc0 [drm]
[   62.105047]  [<ffffffffc00a7d43>] drm_gem_handle_create_tail+0xc3/0x190 [drm]
[   62.105088]  [<ffffffffc00a7e45>] drm_gem_handle_create+0x35/0x40 [drm]
[   62.105145]  [<ffffffffc01cf531>] i915_gem_userptr_ioctl+0x271/0x350 [i915_bpo]
[   62.105190]  [<ffffffffc00a8742>] drm_ioctl+0x152/0x540 [drm]
[   62.105235]  [<ffffffffc01cf2c0>] ? __i915_gem_userptr_get_pages_worker+0x320/0x320 [i915_bpo]
[   62.105262]  [<ffffffff81220b6f>] do_vfs_ioctl+0x29f/0x490
[   62.105281]  [<ffffffff81701610>] ? __sys_recvmsg+0x80/0x90
[   62.105298]  [<ffffffff81220dd9>] SyS_ioctl+0x79/0x90
[   62.105319]  [<ffffffff818276b2>] entry_SYSCALL_64_fastpath+0x16/0x71
[   62.105346] Code: 08 65 4c 03 05 2f eb e1 7e 49 83 78 10 00 4d 8b 10 0f 84 21 01 00 00 4d 85 d2 0f 84 18 01 00 00 49 63 41 20 48 8d 4a 01 49 8b 39 <49> 8b 1c 02 4c 89 d0 65 48 0f c7 0f 0f 94 c0 84 c0 74 bb 49 63
[   62.105520] RIP  [<ffffffff811eb67b>] kmem_cache_alloc_trace+0x7b/0x1f0
[   62.105543]  RSP <ffff880078fa3c70>
[   62.105554] CR2: 0000000000000001
[   62.113016] ---[ end trace 4f9991d2eebd1637 ]---

(gdb) list *(kmem_cache_alloc_trace+0x7b)
0xffffffff811eb67b is in kmem_cache_alloc_trace (/build/linux-BvkamA/linux-4.4.0/mm/slub.c:247).
242		return 1;
243	}
244	
245	static inline void *get_freepointer(struct kmem_cache *s, void *object)
246	{
247		return *(void **)(object + s->offset);
248	}
249	
250	static void prefetch_freepointer(const struct kmem_cache *s, void *object)
251	{

More logs can be found at
https://bugzilla.kernel.org/show_bug.cgi?id=120241

This log was from a 4.4 based ubuntu kernel, but the same issue was reproduced
with 4.7-rc5. Call trace often point to various graphics related drivers, but
also xhci and acpi_hotplug_work_fn.
Only thing they have in common is that they fail while trying to allocate memory.

A log of acpi_hotplug_work_fn failing to allocate memory while removing pci
devices:
https://bugzilla.kernel.org/attachment.cgi?id=221561

I've been looking at this from xhci perspective, but it starts to go too deep
into mm, pci hotplug etc for my understanding.

Any ideas?

-Mathias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
