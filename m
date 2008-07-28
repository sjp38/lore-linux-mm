Received: by rv-out-0708.google.com with SMTP id f25so4951354rvb.26
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 12:38:11 -0700 (PDT)
Message-ID: <86802c440807281238u63770318s8e665754f666c602@mail.gmail.com>
Date: Mon, 28 Jul 2008 12:38:10 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm tree
In-Reply-To: <20080728191518.GA5352@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org>
	 <20080728091655.GC7965@csn.ul.ie>
	 <86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com>
	 <20080728113836.GE7965@csn.ul.ie>
	 <86802c440807281125g7d424f17v4b7c512929f45367@mail.gmail.com>
	 <20080728191518.GA5352@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 28, 2008 at 12:15 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On (28/07/08 11:25), Yinghai Lu didst pronounce:
>> On Mon, Jul 28, 2008 at 4:38 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > On (28/07/08 04:15), Yinghai Lu didst pronounce:
>> >> On Mon, Jul 28, 2008 at 2:16 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> >> > On (27/07/08 20:13), akpm@linux-foundation.org didst pronounce:
>> >> >>
>> >> >> The patch titled
>> >> >>      mm: remove find_max_pfn_with_active_regions
>> >> >> has been added to the -mm tree.  Its filename is
>> >> >>      mm-remove-find_max_pfn_with_active_regions.patch
>> >> >>
>> >> >> Before you just go and hit "reply", please:
>> >> >>    a) Consider who else should be cc'ed
>> >> >>    b) Prefer to cc a suitable mailing list as well
>> >> >>    c) Ideally: find the original patch on the mailing list and do a
>> >> >>       reply-to-all to that, adding suitable additional cc's
>> >> >>
>> >> >> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>> >> >>
>> >> >> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
>> >> >> out what to do about this
>> >> >>
>> >> >> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
>> >> >>
>> >> >> ------------------------------------------------------
>> >> >> Subject: mm: remove find_max_pfn_with_active_regions
>> >> >> From: Yinghai Lu <yhlu.kernel@gmail.com>
>> >> >>
>> >> >> It has no user now
>> >> >>
>> >> >> Also print out info about adding/removing active regions.
>> >> >>
>> >> >> Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
>> >> >> Cc: Mel Gorman <mel@csn.ul.ie>
>> >> >> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> >> >> ---
>> >> >>
>> >> >>  include/linux/mm.h |    1 -
>> >> >>  mm/page_alloc.c    |   22 ++--------------------
>> >> >>  2 files changed, 2 insertions(+), 21 deletions(-)
>> >> >>
>> >> >> diff -puN include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions include/linux/mm.h
>> >> >> --- a/include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions
>> >> >> +++ a/include/linux/mm.h
>> >> >> @@ -1041,7 +1041,6 @@ extern unsigned long absent_pages_in_ran
>> >> >>  extern void get_pfn_range_for_nid(unsigned int nid,
>> >> >>                       unsigned long *start_pfn, unsigned long *end_pfn);
>> >> >>  extern unsigned long find_min_pfn_with_active_regions(void);
>> >> >> -extern unsigned long find_max_pfn_with_active_regions(void);
>> >> >>  extern void free_bootmem_with_active_regions(int nid,
>> >> >>                                               unsigned long max_low_pfn);
>> >> >>  typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
>> >> >> diff -puN mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions mm/page_alloc.c
>> >> >> --- a/mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions
>> >> >> +++ a/mm/page_alloc.c
>> >> >> @@ -3572,8 +3572,7 @@ void __init add_active_range(unsigned in
>> >> >>  {
>> >> >>       int i;
>> >> >>
>> >> >> -     mminit_dprintk(MMINIT_TRACE, "memory_register",
>> >> >> -                     "Entering add_active_range(%d, %#lx, %#lx) "
>> >> >> +     printk(KERN_INFO "Adding active range (%d, %#lx, %#lx) "
>> >> >>                       "%d entries of %d used\n",
>> >> >>                       nid, start_pfn, end_pfn,
>> >> >>                       nr_nodemap_entries, MAX_ACTIVE_REGIONS);
>> >> >
>> >> > Why are the mminit_dprintk() calls being converted to printk(KERN_INFO)?  On
>> >> > some machines, this will be very noisy. For example, some POWER configurations
>> >> > will print out one line for every 16MB of memory with this patch.
>> >>
>> >> I don't know, on x86 esp the first node, that is some informative.
>> >> or change that back to printk(KERN_DEBUG) ?
>> >>
>> >> hope the user put debug on command_line to get enough info.
>> >>
>> >> otherwise without "mminit_loglevel=" will get that debug info.
>> >>
>> >
>> > It's the type of information that is only useful when debugging memory
>> > initialisation problems. The more friendly information can be found at
>> > the lines starting with
>> >
>> > early_node_map[1] active PFN ranges
>> >
>> > and this is already logged. The fact that mminit_loglevel needs loglevel
>> > needs to be at KERN_DEBUG level is already documented for the mminit_loglevel=
>> > parameter. I still am not convinced that these needs to be logged at
>> > KERN_INFO level.
>>
>> I hope: when ask user to append "debug" we can get enough debug info
>> without other extra ...
>>
>
> I disagree. The memory init output is very verbose, which is why the
> mminit_debug framework was made quiet by default.  In the event it is useful,
> it is because memory initialisation broken and at that point, it's simple
> enough to request the user to add the necessary options. It shouldn't be
> visible by default. This is similar in principal to acpi.debug_level for
> example.

not that verbose,  on my 8 sockets system

LBSuse:/x/kernel.org # ./kexec -e
Starting new kernel
Initializing cgroup subsys cpuset
Linux version 2.6.26-tip-01876-g0609af7-dirty (yhlu@linux-zpir) (gcc
version 4.3.1 20080507 (prerelease) [gcc-4_3-branch revision 135036]
(SUSE Linux) ) #509 SMP Sun Jul 27 17:47:45 PDT 2008
Command line: apic=verbose show_msr=1 debug mminit_loglevel=4
initcall_debug pci=routeirq lpfc.lpfc_use_msi=1 ramdisk_size=131072
root=/dev/ram0 rw ip=dhcp console=uart8250,io,0x3f8,115200n8
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000100 - 0000000000095800 (usable)
 BIOS-e820: 0000000000095800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e6000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000d7fa0000 (usable)
 BIOS-e820: 00000000d7fae000 - 00000000d7fb0000 (reserved)
 BIOS-e820: 00000000d7fb0000 - 00000000d7fbe000 (ACPI data)
 BIOS-e820: 00000000d7fbe000 - 00000000d7ff0000 (ACPI NVS)
 BIOS-e820: 00000000d7ff0000 - 00000000d8000000 (reserved)
 BIOS-e820: 00000000dc000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ff700000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000004028000000 (usable)
Early serial console at I/O port 0x3f8 (options '115200n8')
console [uart0] enabled
last_pfn = 0x4028000 max_arch_pfn = 0x3ffffffff
x86 PAT enabled: cpu 0, old 0x7010600070106, new 0x7010600070106
last_pfn = 0xd7fa0 max_arch_pfn = 0x3ffffffff
init_memory_mapping
Using GB pages for direct mapping
 0000000000 - 00c0000000 page 1G
 00c0000000 - 00d7e00000 page 2M
 00d7e00000 - 00d7fa0000 page 4k
kernel direct mapping tables up to d7fa0000 @ 8000-b000
last_map_addr: d7fa0000 end: d7fa0000
init_memory_mapping
Using GB pages for direct mapping
 0100000000 - 4000000000 page 1G
 4000000000 - 4028000000 page 2M
kernel direct mapping tables up to 4028000000 @ a000-c000
last_map_addr: 4028000000 end: 4028000000
RAMDISK: 7e6cb000 - 7fff3e0b
DMI present.
ACPI: RSDP 000F99A0, 0024 (r2 SUN   )
ACPI: XSDT D7FB0100, 009C (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: FACP D7FB0290, 00F4 (r3 SUN    X4600 M2       98 MSFT       97)
ACPI: DSDT D7FB0710, 718F (r1 SUN    X4600 M2       98 INTL 20051117)
ACPI: FACS D7FBE000, 0040
ACPI: APIC D7FB0390, 0170 (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: SPCR D7FB0500, 0050 (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: MCFG D7FB0550, 003C (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: SLIT D7FB064C, 006C (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: SPMI D7FB06C0, 0041 (r5 SUN    OEMSPMI        98 MSFT       97)
ACPI: OEMB D7FBE040, 0063 (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: SRAT D7FB78A0, 03C0 (r1 AMD    HAMMER          1 AMD         1)
ACPI: HPET D7FB7C60, 0038 (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: IPET D7FB7CA0, 0038 (r1 SUN    X4600 M2       98 MSFT       97)
ACPI: EINJ D7FB7CE0, 0130 (r1  AMIER AMI_EINJ  7000808 MSFT       97)
ACPI: BERT D7FB7E70, 0030 (r1  AMIER AMI_BERT  7000808 MSFT       97)
ACPI: ERST D7FB7EA0, 01B0 (r1  AMIER AMI_ERST  7000808 MSFT       97)
ACPI: HEST D7FB8050, 00A8 (r1  AMIER AMI_HEST  7000808 MSFT       97)
ACPI: SSDT D7FB8100, 5084 (r1 A M I  POWERNOW        1 AMD         1)
SRAT: PXM 0 -> APIC 4 -> Node 0
SRAT: PXM 0 -> APIC 5 -> Node 0
SRAT: PXM 0 -> APIC 6 -> Node 0
SRAT: PXM 0 -> APIC 7 -> Node 0
SRAT: PXM 1 -> APIC 8 -> Node 1
SRAT: PXM 1 -> APIC 9 -> Node 1
SRAT: PXM 1 -> APIC 10 -> Node 1
SRAT: PXM 1 -> APIC 11 -> Node 1
SRAT: PXM 2 -> APIC 12 -> Node 2
SRAT: PXM 2 -> APIC 13 -> Node 2
SRAT: PXM 2 -> APIC 14 -> Node 2
SRAT: PXM 2 -> APIC 15 -> Node 2
SRAT: PXM 3 -> APIC 16 -> Node 3
SRAT: PXM 3 -> APIC 17 -> Node 3
SRAT: PXM 3 -> APIC 18 -> Node 3
SRAT: PXM 3 -> APIC 19 -> Node 3
SRAT: PXM 4 -> APIC 20 -> Node 4
SRAT: PXM 4 -> APIC 21 -> Node 4
SRAT: PXM 4 -> APIC 22 -> Node 4
SRAT: PXM 4 -> APIC 23 -> Node 4
SRAT: PXM 5 -> APIC 24 -> Node 5
SRAT: PXM 5 -> APIC 25 -> Node 5
SRAT: PXM 5 -> APIC 26 -> Node 5
SRAT: PXM 5 -> APIC 27 -> Node 5
SRAT: PXM 6 -> APIC 28 -> Node 6
SRAT: PXM 6 -> APIC 29 -> Node 6
SRAT: PXM 6 -> APIC 30 -> Node 6
SRAT: PXM 6 -> APIC 31 -> Node 6
SRAT: PXM 7 -> APIC 32 -> Node 7
SRAT: PXM 7 -> APIC 33 -> Node 7
SRAT: PXM 7 -> APIC 34 -> Node 7
SRAT: PXM 7 -> APIC 35 -> Node 7
SRAT: Node 0 PXM 0 0-a0000
Adding active range (0, 0x1, 0x95) 0 entries of 3200 used
 ======> hope to see the difference with mminit_loglevel=4

SRAT: Node 0 PXM 0 100000-d8000000
Adding active range (0, 0x100, 0xd7fa0) 1 entries of 3200 used
 ======> hope to see the difference with mminit_loglevel=4

SRAT: Node 0 PXM 0 100000000-828000000
Adding active range (0, 0x100000, 0x828000) 2 entries of 3200 used
SRAT: Node 1 PXM 1 828000000-1028000000
Adding active range (1, 0x828000, 0x1028000) 3 entries of 3200 used
SRAT: Node 2 PXM 2 1028000000-1828000000
Adding active range (2, 0x1028000, 0x1828000) 4 entries of 3200 used
SRAT: Node 3 PXM 3 1828000000-2028000000
Adding active range (3, 0x1828000, 0x2028000) 5 entries of 3200 used
SRAT: Node 4 PXM 4 2028000000-2828000000
Adding active range (4, 0x2028000, 0x2828000) 6 entries of 3200 used
SRAT: Node 5 PXM 5 2828000000-3028000000
Adding active range (5, 0x2828000, 0x3028000) 7 entries of 3200 used
SRAT: Node 6 PXM 6 3028000000-3828000000
Adding active range (6, 0x3028000, 0x3828000) 8 entries of 3200 used
SRAT: Node 7 PXM 7 3828000000-4028000000
Adding active range (7, 0x3828000, 0x4028000) 9 entries of 3200 used
ACPI: SLIT: nodes = 8
 10 12 12 14 14 14 14 16
 12 10 14 12 14 14 12 14
 12 14 10 14 12 12 14 14
 14 12 14 10 12 12 14 14
 14 14 12 12 10 14 12 14
 14 14 12 12 14 10 14 12
 14 12 14 14 12 14 10 12
 16 14 14 14 14 12 12 10
NUMA: Allocated memnodemap from b000 - 8b580
NUMA: Using 20 for the hash shift.
Bootmem setup node 0 0000000000000000-0000000828000000
  NODE_DATA [000000000008b580 - 000000000009057f]
  bootmap [0000000001078000 -  000000000117cfff] pages 105
(9 early reservations) ==> bootmem [0000000000 - 0828000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0000200000 - 0001077c64]    TEXT DATA BSS ==> [0000200000 - 0001077c64]
  #3 [007e6cb000 - 007fff3e0b]          RAMDISK ==> [007e6cb000 - 007fff3e0b]
  #4 [0000095400 - 0000100000]    BIOS reserved ==> [0000095400 - 0000100000]
  #5 [0000008000 - 000000a000]          PGTABLE ==> [0000008000 - 000000a000]
  #6 [000000a000 - 000000b000]          PGTABLE ==> [000000a000 - 000000b000]
  #7 [0000001000 - 000000106c]        ACPI SLIT ==> [0000001000 - 000000106c]
  #8 [000000b000 - 000008b580]       MEMNODEMAP ==> [000000b000 - 000008b580]
Bootmem setup node 1 0000000828000000-0000001028000000
  NODE_DATA [0000000828000000 - 0000000828004fff]
  bootmap [0000000828005000 -  0000000828104fff] pages 100
...
Scan SMP from ffff880000000000 for 1024 bytes.
Scan SMP from ffff88000009fc00 for 1024 bytes.
Scan SMP from ffff8800000f0000 for 65536 bytes.
found SMP MP-table at [ffff8800000ff780] 000ff780
 [ffffe20000000000-ffffe27fffffffff] PGD ->ffff88002810e000 on node 0
 [ffffe20000000000-ffffe2003fffffff] PUD ->ffff88002810f000 on node 0
[ffffe2001c8c0000-ffffe2001c9fffff] potential offnode page_structs
 [ffffe20000000000-ffffe2001c9fffff] PMD ->
[ffff880028200000-ffff8800443fffff] on node 0
[ffffe200388c0000-ffffe200389fffff] potential offnode page_structs
 [ffffe2001ca00000-ffffe200389fffff] PMD ->
[ffff880828200000-ffff8808441fffff] on node 1
 [ffffe20040000000-ffffe2007fffffff] PUD ->ffff88102f800000 on node 2
 [ffffe20038a00000-ffffe2003fffffff] PMD ->
[ffff881028200000-ffff88102f7fffff] on node 2
[ffffe200548c0000-ffffe200549fffff] potential offnode page_structs
 [ffffe20040000000-ffffe200549fffff] PMD ->
[ffff88102fa00000-ffff8810443fffff] on node 2
[ffffe200708c0000-ffffe200709fffff] potential offnode page_structs
 [ffffe20054a00000-ffffe200709fffff] PMD ->
[ffff881828200000-ffff8818441fffff] on node 3
 [ffffe20080000000-ffffe200bfffffff] PUD ->ffff882037800000 on node 4
 [ffffe20070a00000-ffffe2007fffffff] PMD ->
[ffff882028200000-ffff8820377fffff] on node 4
[ffffe2008c8c0000-ffffe2008c9fffff] potential offnode page_structs
 [ffffe20080000000-ffffe2008c9fffff] PMD ->
[ffff882037a00000-ffff8820443fffff] on node 4
[ffffe200a88c0000-ffffe200a89fffff] potential offnode page_structs
 [ffffe2008ca00000-ffffe200a89fffff] PMD ->
[ffff882828200000-ffff8828441fffff] on node 5
 [ffffe200c0000000-ffffe200ffffffff] PUD ->ffff88303f800000 on node 6
 [ffffe200a8a00000-ffffe200bfffffff] PMD ->
[ffff883028200000-ffff88303f7fffff] on node 6
[ffffe200c48c0000-ffffe200c49fffff] potential offnode page_structs
 [ffffe200c0000000-ffffe200c49fffff] PMD ->
[ffff88303fa00000-ffff8830443fffff] on node 6
 [ffffe200c4a00000-ffffe200e09fffff] PMD ->
[ffff883828200000-ffff8838441fffff] on node 7
Zone PFN ranges:
  DMA      0x00000001 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x04028000
Movable zone start PFN for each node
early_node_map[10] active PFN ranges
    0: 0x00000001 -> 0x00000095
    0: 0x00000100 -> 0x000d7fa0
    0: 0x00100000 -> 0x00828000
    1: 0x00828000 -> 0x01028000
    2: 0x01028000 -> 0x01828000
    3: 0x01828000 -> 0x02028000
    4: 0x02028000 -> 0x02828000
    5: 0x02828000 -> 0x03028000
    6: 0x03028000 -> 0x03828000
    7: 0x03828000 -> 0x04028000
mminit::pageflags_layout_widths Section 0 Node 6 Zone 2 Flags 19
mminit::pageflags_layout_shifts Section 17 Node 6 Zone 2
mminit::pageflags_layout_offsets Section 0 Node 58 Zone 56
mminit::pageflags_layout_zoneid Zone ID: 56 -> 64
mminit::pageflags_layout_usage location: 64 -> 56 unused 56 -> 19 flags 19 -> 0
On node 0 totalpages: 8388404
mminit::memmap_init DMA zone: 56 pages used for memmap
mminit::memmap_init DMA zone: 242 pages reserved
=====> hope to see the memmap pages used here with mminit_loglevel

  DMA zone: 3690 pages, LIFO batch:0
mminit::memmap_init Initialising map node 0 zone 0 pfns 1 -> 4096
mminit::memmap_init DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 866264 pages, LIFO batch:31
mminit::memmap_init Initialising map node 0 zone 1 pfns 4096 -> 1048576
mminit::memmap_init Normal zone: 102592 pages used for memmap
  Normal zone: 7401280 pages, LIFO batch:31
mminit::memmap_init Initialising map node 0 zone 2 pfns 1048576 -> 8552448
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 1 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 1 zone 2 pfns 8552448 -> 16941056
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 2 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 2 zone 2 pfns 16941056 -> 25329664
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 3 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 3 zone 2 pfns 25329664 -> 33718272
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 4 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 4 zone 2 pfns 33718272 -> 42106880
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 5 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 5 zone 2 pfns 42106880 -> 50495488
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 6 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 6 zone 2 pfns 50495488 -> 58884096
mminit::memmap_init Movable zone: 0 pages used for memmap
On node 7 totalpages: 8388608
mminit::memmap_init DMA zone: 0 pages used for memmap
mminit::memmap_init DMA32 zone: 0 pages used for memmap
mminit::memmap_init Normal zone: 114688 pages used for memmap
  Normal zone: 8273920 pages, LIFO batch:31
mminit::memmap_init Initialising map node 7 zone 2 pfns 58884096 -> 67272704
mminit::memmap_init Movable zone: 0 pages used for memmap

BTW, please check if mminit_loglevel=3 and mminit_loglevel=4 is the same?

suggest to switch to mminit_debug, and that will be used in addition
to "debug" to print out spew info for ...

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
