Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 623DE6B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 07:53:05 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q3-v6so10626134wrm.8
        for <linux-mm@kvack.org>; Wed, 23 May 2018 04:53:05 -0700 (PDT)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id x42-v6si16228063wrb.411.2018.05.23.04.53.03
        for <linux-mm@kvack.org>;
        Wed, 23 May 2018 04:53:04 -0700 (PDT)
Date: Wed, 23 May 2018 13:53:03 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [RFC] Checking for error code in __offline_pages
Message-ID: <20180523115303.GA29492@techadventures.net>
References: <20180523073547.GA29266@techadventures.net>
 <20180523075239.GF20441@dhcp22.suse.cz>
 <20180523081609.GG20441@dhcp22.suse.cz>
 <20180523102642.GA27700@techadventures.net>
 <20180523113857.GO20441@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523113857.GO20441@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, vbabka@suse.cz, pasha.tatashin@oracle.com, akpm@linux-foundation.org

On Wed, May 23, 2018 at 01:38:57PM +0200, Michal Hocko wrote:
> On Wed 23-05-18 12:26:43, Oscar Salvador wrote:
> > On Wed, May 23, 2018 at 10:16:09AM +0200, Michal Hocko wrote:
> > > On Wed 23-05-18 09:52:39, Michal Hocko wrote:
> > > [...]
> > > > Yeah, the current code is far from optimal. We
> > > > used to have a retry count but that one was removed exactly because of
> > > > premature failures. There are three things here
> > > > 1) zone_movable should contain any bootmem or otherwise non-migrateable
> > > >    pages
> > > > 2) start_isolate_page_range should fail when seeing such pages - maybe
> > > >    has_unmovable_pages is overly optimistic and it should check all
> > > >    pages even in movable zones.
> > > > 3) migrate_pages should really tell us whether the failure is temporal
> > > >    or permanent. I am not sure we can do that easily though.
> > > 
> > > 2) should be the most simple one for now. Could you give it a try? Btw.
> > > the exact configuration that led to boothmem pages in zone_movable would
> > > be really appreciated:
> >  
> > Here is some information:
> > 
> > ** Qemu cmdline:
> > 
> > # qemu-system-x86_64 -enable-kvm -smp 2  -monitor pty -m 6G,slots=8,maxmem=8G -numa node,mem=4096M -numa node,mem=2048M ...
> > # Option movablecore=4G (cmdline)
> > 
> > ** e820 map and some numa information:
> > 
> > linux kernel: BIOS-provided physical RAM map:
> > linux kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > linux kernel: BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > linux kernel: BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
> > linux kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
> > linux kernel: BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
> > linux kernel: BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
> > linux kernel: BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
> > linux kernel: BIOS-e820: [mem 0x0000000100000000-0x00000001bfffffff] usable
> > linux kernel: NX (Execute Disable) protection: active
> > linux kernel: SMBIOS 2.8 present.
> > linux kernel: DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org 
> > linux kernel: Hypervisor detected: KVM
> > linux kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
> > linux kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
> > linux kernel: last_pfn = 0x1c0000 max_arch_pfn = 0x400000000
> > 
> > linux kernel: SRAT: PXM 0 -> APIC 0x00 -> Node 0
> > linux kernel: SRAT: PXM 1 -> APIC 0x01 -> Node 1
> > linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
> > linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0xbfffffff]
> > linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x13fffffff]
> > linux kernel: ACPI: SRAT: Node 1 PXM 1 [mem 0x140000000-0x1bfffffff]
> > linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x1c0000000-0x43fffffff] hotplug
> > linux kernel: NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0xbfffffff] -> [mem 0x0
> > linux kernel: NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x13fffffff] -> [mem 0
> > linux kernel: NODE_DATA(0) allocated [mem 0x13ffd6000-0x13fffffff]
> > linux kernel: NODE_DATA(1) allocated [mem 0x1bffd3000-0x1bfffcfff]
> 
> Could you also paste
> "Zone ranges:"
> and the follow up messages?

Michal, here is the output about "Zone ranges:"

linux kernel: Zone ranges:
linux kernel:   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
linux kernel:   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
linux kernel:   Normal   [mem 0x0000000100000000-0x00000001bfffffff]
linux kernel:   Device   empty
linux kernel: Movable zone start for each node
linux kernel:   Node 0: 0x0000000100000000
linux kernel:   Node 1: 0x0000000140000000
linux kernel: Early memory node ranges
linux kernel:   node   0: [mem 0x0000000000001000-0x000000000009efff]
linux kernel:   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
linux kernel:   node   0: [mem 0x0000000100000000-0x000000013fffffff]
linux kernel:   node   1: [mem 0x0000000140000000-0x00000001bfffffff]
linux kernel: Initmem setup node 0 [mem 0x0000000000001000-0x000000013fffffff]
linux kernel: On node 0 totalpages: 1048446
linux kernel:   DMA zone: 64 pages used for memmap
linux kernel:   DMA zone: 21 pages reserved
linux kernel:   DMA zone: 3998 pages, LIFO batch:0
linux kernel:   DMA32 zone: 12224 pages used for memmap
linux kernel:   DMA32 zone: 782304 pages, LIFO batch:31
linux kernel:   Movable zone: 4096 pages used for memmap
linux kernel:   Movable zone: 262144 pages, LIFO batch:31
linux kernel: Initmem setup node 1 [mem 0x0000000140000000-0x00000001bfffffff]
linux kernel: On node 1 totalpages: 524288
linux kernel:   Movable zone: 8192 pages used for memmap
linux kernel:   Movable zone: 524288 pages, LIFO batch:31
linux kernel: Reserved but unavailable: 98 pages

 
Oscar Salvador
