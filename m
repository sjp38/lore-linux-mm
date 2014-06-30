Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 86ADA6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 19:42:42 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id at1so7672040iec.28
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:42:42 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id wo18si31774141icb.48.2014.06.30.16.42.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 16:42:41 -0700 (PDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so7645342ieb.1
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 16:42:41 -0700 (PDT)
Date: Mon, 30 Jun 2014 16:42:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86: numa: setup_node_data(): drop dead code and rename
 function
In-Reply-To: <20140619222019.3db6ad7e@redhat.com>
Message-ID: <alpine.DEB.2.02.1406301639390.1327@chino.kir.corp.google.com>
References: <20140619222019.3db6ad7e@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, andi@firstfloor.org, akpm@linux-foundation.org

On Thu, 19 Jun 2014, Luiz Capitulino wrote:

> The setup_node_data() function allocates a pg_data_t object, inserts it
> into the node_data[] array and initializes the following fields:
> node_id, node_start_pfn and node_spanned_pages.
> 
> However, a few function calls later during the kernel boot,
> free_area_init_node() re-initializes those fields, possibly with
> different values. This means that the initialization done by
> setup_node_data() is not used.
> 
> This causes a small glitch when running Linux as a hyperv numa guest:
> 
> [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x80200000-0xf7ffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x100000000-0x1081fffff]
> [    0.000000] NUMA: Node 1 [mem 0x80200000-0xf7ffffff] + [mem 0x100000000-0x1081fffff] -> [mem 0x80200000-0x1081fffff]
> [    0.000000] Initmem setup node 0 [mem 0x00000000-0x7fffffff]
> [    0.000000]   NODE_DATA [mem 0x7ffec000-0x7ffeffff]
> [    0.000000] Initmem setup node 1 [mem 0x80800000-0x1081fffff]
> [    0.000000]   NODE_DATA [mem 0x1081fa000-0x1081fdfff]
> [    0.000000] crashkernel: memory value expected
> [    0.000000]  [ffffea0000000000-ffffea0001ffffff] PMD -> [ffff88007de00000-ffff88007fdfffff] on node 0
> [    0.000000]  [ffffea0002000000-ffffea00043fffff] PMD -> [ffff880105600000-ffff8801077fffff] on node 1
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   [mem 0x100000000-0x1081fffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00001000-0x0009efff]
> [    0.000000]   node   0: [mem 0x00100000-0x7ffeffff]
> [    0.000000]   node   1: [mem 0x80200000-0xf7ffffff]
> [    0.000000]   node   1: [mem 0x100000000-0x1081fffff]
> [    0.000000] On node 0 totalpages: 524174
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 21 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 8128 pages used for memmap
> [    0.000000]   DMA32 zone: 520176 pages, LIFO batch:31
> [    0.000000] On node 1 totalpages: 524288
> [    0.000000]   DMA32 zone: 7672 pages used for memmap
> [    0.000000]   DMA32 zone: 491008 pages, LIFO batch:31
> [    0.000000]   Normal zone: 520 pages used for memmap
> [    0.000000]   Normal zone: 33280 pages, LIFO batch:7
> 
> In this dmesg, the SRAT table reports that the memory range for node 1
> starts at 0x80200000. However, the line starting with "Initmem" reports
> that node 1 memory range starts at 0x80800000. The "Initmem" line is
> reported by setup_node_data() and is wrong, because the kernel ends up
> using the range as reported in the SRAT table.
> 
> This commit drops all that dead code from setup_node_data(), renames it
> to alloc_node_data() and adds a printk() to free_area_init_node() so
> that we report a node's memory range accurately.
> 
> Here's the same dmesg section with this patch applied:
> 
> [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> [    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
> [    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
> [    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x80200000-0xf7ffffff]
> [    0.000000] SRAT: Node 1 PXM 1 [mem 0x100000000-0x1081fffff]
> [    0.000000] NUMA: Node 1 [mem 0x80200000-0xf7ffffff] + [mem 0x100000000-0x1081fffff] -> [mem 0x80200000-0x1081fffff]
> [    0.000000] NODE_DATA(0) allocated [mem 0x7ffec000-0x7ffeffff]
> [    0.000000] NODE_DATA(1) allocated [mem 0x1081fa000-0x1081fdfff]
> [    0.000000] crashkernel: memory value expected
> [    0.000000]  [ffffea0000000000-ffffea0001ffffff] PMD -> [ffff88007de00000-ffff88007fdfffff] on node 0
> [    0.000000]  [ffffea0002000000-ffffea00043fffff] PMD -> [ffff880105600000-ffff8801077fffff] on node 1
> [    0.000000] Zone ranges:
> [    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
> [    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
> [    0.000000]   Normal   [mem 0x100000000-0x1081fffff]
> [    0.000000] Movable zone start for each node
> [    0.000000] Early memory node ranges
> [    0.000000]   node   0: [mem 0x00001000-0x0009efff]
> [    0.000000]   node   0: [mem 0x00100000-0x7ffeffff]
> [    0.000000]   node   1: [mem 0x80200000-0xf7ffffff]
> [    0.000000]   node   1: [mem 0x100000000-0x1081fffff]
> [    0.000000] Node 0 memory range 0x00001000-0x7ffeffff
> [    0.000000] On node 0 totalpages: 524174
> [    0.000000]   DMA zone: 64 pages used for memmap
> [    0.000000]   DMA zone: 21 pages reserved
> [    0.000000]   DMA zone: 3998 pages, LIFO batch:0
> [    0.000000]   DMA32 zone: 8128 pages used for memmap
> [    0.000000]   DMA32 zone: 520176 pages, LIFO batch:31
> [    0.000000] Node 1 memory range 0x80200000-0x1081fffff
> [    0.000000] On node 1 totalpages: 524288
> [    0.000000]   DMA32 zone: 7672 pages used for memmap
> [    0.000000]   DMA32 zone: 491008 pages, LIFO batch:31
> [    0.000000]   Normal zone: 520 pages used for memmap
> [    0.000000]   Normal zone: 33280 pages, LIFO batch:7
> 
> This commit was tested on a two node bare-metal NUMA machine and Linux
> as a numa guest on hyperv and qemu/kvm.
> 
> PS: The wrong memory range reported by setup_node_data() seems to be
>     harmless in the current kernel because it's just not used. However,
>     that bad range is used in kernel 2.6.32 to initialize the old boot
>     memory allocator, which causes a crash during boot.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

With this patch, the dmesg changes break one of my scripts that we use to 
determine the start and end address of a node (doubly bad because there's 
no sysfs interface to determine this otherwise and we have to do this at 
boot to acquire the system topology).

Specifically, the removal of the

	"Initmem setup node X [mem 0xstart-0xend]"

lines that are replaced when each node is onlined to

	"Node 0 memory range 0xstart-0xend"

And if I just noticed this breakage when booting the latest -mm kernel, 
I'm assuming I'm not the only person who is going to run into it.  Is it 
possible to not change the dmesg output?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
