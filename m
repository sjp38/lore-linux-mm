Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C2F646B006E
	for <linux-mm@kvack.org>; Fri, 26 Dec 2014 09:40:27 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so13282636pad.41
        for <linux-mm@kvack.org>; Fri, 26 Dec 2014 06:40:27 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id yg8si42082469pab.86.2014.12.26.06.40.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 26 Dec 2014 06:40:26 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NH70064F2A5N210@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 26 Dec 2014 14:44:29 +0000 (GMT)
From: "Stefan I. Strogin" <s.strogin@partner.samsung.com>
Subject: [PATCH 0/3] mm: cma: /proc/cmainfo
Date: Fri, 26 Dec 2014 17:39:01 +0300
Message-id: <cover.1419602920.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Stefan I. Strogin" <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>

Hello all,

Here is a patch set that adds /proc/cmainfo.

When compiled with CONFIG_CMA_DEBUG /proc/cmainfo will contain information
about about total, used, maximum free contiguous chunk and all currently
allocated contiguous buffers in CMA regions. The information about allocated
CMA buffers includes pid, comm, allocation latency and stacktrace at the
moment of allocation.

Example:

# cat /proc/cmainfo 
CMARegion stat:    65536 kB total,      248 kB used,    65216 kB max contiguous chunk

0x32400000 - 0x32401000 (4 kB), allocated by pid 63 (systemd-udevd), latency 74 us
 [<c1006e96>] dma_generic_alloc_coherent+0x86/0x160
 [<c13093af>] rpm_idle+0x1f/0x1f0
 [<c1006e10>] dma_generic_alloc_coherent+0x0/0x160
 [<f80a533e>] ohci_init+0x1fe/0x430 [ohci_hcd]
 [<c1006e10>] dma_generic_alloc_coherent+0x0/0x160
 [<f801404f>] ohci_pci_reset+0x4f/0x60 [ohci_pci]
 [<f80f165c>] usb_add_hcd+0x1fc/0x900 [usbcore]
 [<c1256158>] pcibios_set_master+0x38/0x90
 [<f8101ea6>] usb_hcd_pci_probe+0x176/0x4f0 [usbcore]
 [<c125852f>] pci_device_probe+0x6f/0xd0
 [<c1199495>] sysfs_create_link+0x25/0x50
 [<c1300522>] driver_probe_device+0x92/0x3b0
 [<c14564fb>] __mutex_lock_slowpath+0x5b/0x90
 [<c1300880>] __driver_attach+0x0/0x80
 [<c13008f9>] __driver_attach+0x79/0x80
 [<c1300880>] __driver_attach+0x0/0x80

0x32401000 - 0x32402000 (4 kB), allocated by pid 58 (systemd-udevd), latency 17 us
 [<c130e370>] dmam_coherent_release+0x0/0x90
 [<c112d76c>] __kmalloc_track_caller+0x31c/0x380
 [<c1006e96>] dma_generic_alloc_coherent+0x86/0x160
 [<c1006e10>] dma_generic_alloc_coherent+0x0/0x160
 [<c130e226>] dmam_alloc_coherent+0xb6/0x100
 [<f8125153>] ata_bmdma_port_start+0x43/0x60 [libata]
 [<f8113068>] ata_host_start.part.29+0xb8/0x190 [libata]
 [<c13624a0>] pci_read+0x30/0x40
 [<f8124eb9>] ata_pci_sff_activate_host+0x29/0x220 [libata]
 [<f8127050>] ata_bmdma_interrupt+0x0/0x1f0 [libata]
 [<c1256158>] pcibios_set_master+0x38/0x90
 [<f80ad9be>] piix_init_one+0x44e/0x630 [ata_piix]
 [<c1455ef0>] mutex_lock+0x10/0x20
 [<c1197093>] kernfs_activate+0x63/0xd0
 [<c11971c3>] kernfs_add_one+0xc3/0x130
 [<c125852f>] pci_device_probe+0x6f/0xd0
<...>

Dmitry Safonov (1):
  cma: add functions to get region pages counters

Stefan I. Strogin (2):
  stacktrace: add seq_print_stack_trace()
  mm: cma: introduce /proc/cmainfo

 include/linux/cma.h        |   2 +
 include/linux/stacktrace.h |   4 +
 kernel/stacktrace.c        |  17 ++++
 mm/cma.c                   | 236 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 259 insertions(+)

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
