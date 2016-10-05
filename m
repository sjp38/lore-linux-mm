Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B27B6B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 10:13:56 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n202so9847551oig.2
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 07:13:56 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0049.outbound.protection.outlook.com. [104.47.32.49])
        by mx.google.com with ESMTPS id k187si10087277oih.172.2016.10.05.07.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Oct 2016 07:13:25 -0700 (PDT)
Date: Wed, 5 Oct 2016 16:13:13 +0200
From: Robert Richter <robert.richter@cavium.com>
Subject: arm64: kernel BUG at mm/page_alloc.c:1844!
Message-ID: <20161005141313.GF22012@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux@arm.linux.org.uk, linux-efi@vger.kernel.org, David Daney <david.daney@cavium.com>, Mark Salter <msalter@redhat.com>

Hi all,

I am looking into a memory setup problem on ThunderX systems under
certain memory configurations. The symptom is

 kernel BUG at mm/page_alloc.c:1848!

It happens for some configs with 64k page size enabled (at least since
4.5). The bug triggers for page zones with some pages in the zone not
assigned to this particular zone. In my case some pages that are
marked as nomap were not reassigned to the new zone of node 1, so
those are still assigned to node 0. Mark also reported something
similar for non-numa configs. I think this is a related problem where
not all pages of a zone have been reassigned to the new zone during
setup.

Now, the reason for the mis-configuration is a change in pfn_valid()
which reports pages marked nomap as invalid. In memmap_init_zone()
nomap-pages are not reassigned to that node (__init_single_pfn()).

I tried various changes to fix that, but without success so far:

a) I modified reserve_regions() to use memblock_reserve() instead of
memblock_mark_nomap(). This marked efi regions as reserved instead of
unmap. pfn_valid() now worked as before the nomap change. I could boot
the system but noticed the following malloc assertion which looks like
there is some mem corruption:

  emacs: malloc.c:2395: sysmalloc: Assertion `(old_top == initial_top (av) && old_size == 0) || ((unsigned long) (old_size) >= MINSIZE && prev_inuse (old_top) && ((unsigned long) old_end & (pagesize - 1)) == 0)' failed.

Other than that the system looked ok so far.

I checked pfn used by the process with kmem:mm_page_alloc_zone_locked,
it looked correct with all pfn allocated from free memory, mem ranges
reported by efi as reserved were not used.

b) I found a quote that for sparsemem the entire memmap (all pages have a
struct *page) for single section (include/linux/mmzone.h):

 "In SPARSEMEM, it is assumed that a valid section has a memmap for
 the entire section."

So I implemented a arm64 private __early_pfn_valid() function that
uses memblock_is_memory() to setup all pages of a zone. I got the same
result as for a).

c) I modified (almost) all arch arm64 users of pfn_valid() to use
memblock_mark_nomap() instead of pfn_valid() and changed pfn_valid()
to use memblock_is_memory(). Same problem as a).

d) Enabling HOLES_IN_ZONE config option does not looks correct for
sparsemem, trying it anyway causes VM_BUG_ON_PAGE() in in line 1849
since (uninitialized) struct *page is accessed. This did not work
either.

I also noticed the efi ranges to be only 4k page aligned, I checked
reserved mem regions, its transformation to 64k alignment looked ok
too. See below for efi and memblock address ranges.

Is there anything else I could do here? Am I missing something? Could
the malloc assertion be another bug which was uncovered after fixing
the first? Any help is appreciated.

Thanks,

-Robert




[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi:   System Table: 0x0000010fffffef18
[    0.000000] efi:   MemMap Address: 0x0000010ff788e018
[    0.000000] efi:   MemMap Size: 0x000006c0
[    0.000000] efi:   MemMap Desc. Size: 0x00000030
[    0.000000] efi:   MemMap Desc. Version: 0x00000001
[    0.000000] efi: EFI v2.40 by Cavium Thunder cn88xx EFI ThunderX-Firmware-Release-1.22.10-0-g4e85766 Aug 24 2016 15:59:03
[    0.000000] efi:  ACPI=0xfffff000  ACPI 2.0=0xfffff014  SMBIOS 3.0=0x10ffafcf000 
[    0.000000] efi: Processing EFI memory map:
[    0.000000] efi:   0x000001400000-0x00000147ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000001480000-0x0000024affff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x0000024b0000-0x0000211fffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000021200000-0x00002121ffff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000021220000-0x0000fffecfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x0000fffed000-0x0000ffff4fff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x0000ffff5000-0x0000ffff5fff [ACPI Memory NVS    |   |  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x0000ffff6000-0x0000ffffffff [ACPI Reclaim Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x000100000000-0x000ff7ffffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000ff8000000-0x000ff801ffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000ff8020000-0x000fffa9cfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x000fffa9d000-0x000fffffffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010000400000-0x010f8465ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010f84660000-0x010f8568ffff [Loader Code        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010f85690000-0x010ff788afff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ff788b000-0x010ff788dfff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ff788e000-0x010ff7890fff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ff7891000-0x010ff78adfff [Loader Code        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ff78ae000-0x010ff9e97fff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ff9e98000-0x010ff9f20fff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ff9f21000-0x010ffaeb5fff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ffaeb6000-0x010ffafc8fff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ffafc9000-0x010ffafccfff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ffafcd000-0x010ffaff4fff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ffaff5000-0x010ffb008fff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ffb009000-0x010ffeb6cfff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ffeb6d000-0x010ffec94fff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ffec95000-0x010fffe28fff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010fffe29000-0x010fffe3ffff [Conventional Memory|   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010fffe40000-0x010fffe53fff [Loader Data        |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010fffe54000-0x010ffffb8fff [Boot Code          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x010ffffb9000-0x010ffffccfff [Runtime Code       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ffffcd000-0x010fffffefff [Runtime Data       |RUN|  |  |  |  |  |  |   |WB|WT|WC|UC]*
[    0.000000] efi:   0x010ffffff000-0x010fffffffff [Boot Data          |   |  |  |  |  |  |  |   |WB|WT|WC|UC]
[    0.000000] efi:   0x804000001000-0x804000001fff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]
[    0.000000] efi:   0x87e0d0001000-0x87e0d0001fff [Memory Mapped I/O  |RUN|  |  |  |  |  |  |   |  |  |  |UC]

[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0x1ffe800000 reserved size = 0x36506a21
[    0.000000]  memory.cnt  = 0x9
[    0.000000]  memory[0x0]     [0x00000001400000-0x000000fffdffff], 0xfebe0000 bytes on node 0 flags: 0x0
[    0.000000]  memory[0x1]     [0x000000fffe0000-0x000000ffffffff], 0x20000 bytes on node 0 flags: 0x4
[    0.000000]  memory[0x2]     [0x00000100000000-0x00000fffffffff], 0xf00000000 bytes on node 0 flags: 0x0
[    0.000000]  memory[0x3]     [0x00010000400000-0x00010ff9e8ffff], 0xff9a90000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x4]     [0x00010ff9e90000-0x00010ff9f2ffff], 0xa0000 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x5]     [0x00010ff9f30000-0x00010ffaeaffff], 0xf80000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x6]     [0x00010ffaeb0000-0x00010ffaffffff], 0x150000 bytes on node 1 flags: 0x4
[    0.000000]  memory[0x7]     [0x00010ffb000000-0x00010ffffaffff], 0x4fb0000 bytes on node 1 flags: 0x0
[    0.000000]  memory[0x8]     [0x00010ffffb0000-0x00010fffffffff], 0x50000 bytes on node 1 flags: 0x4
[    0.000000]  reserved.cnt  = 0xd
[    0.000000]  reserved[0x0]   [0x00000001480000-0x0000000248ffff], 0x1010000 bytes flags: 0x0
[    0.000000]  reserved[0x1]   [0x00000021200000-0x00000021210536], 0x10537 bytes flags: 0x0
[    0.000000]  reserved[0x2]   [0x000000c0000000-0x000000dfffffff], 0x20000000 bytes flags: 0x0
[    0.000000]  reserved[0x3]   [0x00000ffbfb8000-0x00000ffffdffff], 0x4028000 bytes flags: 0x0
[    0.000000]  reserved[0x4]   [0x00000ffffecb00-0x00000fffffffff], 0x13500 bytes flags: 0x0
[    0.000000]  reserved[0x5]   [0x00010f856a0000-0x00010f92a6ffff], 0xd3d0000 bytes flags: 0x0
[    0.000000]  reserved[0x6]   [0x00010ff7880000-0x00010ff788ffff], 0x10000 bytes flags: 0x0
[    0.000000]  reserved[0x7]   [0x00010ffbce0000-0x00010fffceffff], 0x4010000 bytes flags: 0x0
[    0.000000]  reserved[0x8]   [0x00010fffee6d80-0x00010ffff2fffb], 0x4927c bytes flags: 0x0
[    0.000000]  reserved[0x9]   [0x00010ffff30000-0x00010ffffa000f], 0x70010 bytes flags: 0x0
[    0.000000]  reserved[0xa]   [0x00010ffffae280-0x00010ffffaff7f], 0x1d00 bytes flags: 0x0
[    0.000000]  reserved[0xb]   [0x00010ffffaffa0-0x00010ffffaffce], 0x2f bytes flags: 0x0
[    0.000000]  reserved[0xc]   [0x00010ffffaffd0-0x00010ffffafffe], 0x2f bytes flags: 0x0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
