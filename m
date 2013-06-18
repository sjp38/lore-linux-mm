Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D472C6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 16:19:13 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id x12so11330872ief.12
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 13:19:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130618171036.GD4553@dhcp-192-168-178-175.profitbricks.localdomain>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
	<20130618171036.GD4553@dhcp-192-168-178-175.profitbricks.localdomain>
Date: Tue, 18 Jun 2013 13:19:12 -0700
Message-ID: <CAE9FiQW2CMfNOTNM1MRCZo-ZQuQgj=JQtXLZ3eUxF7dQ8qukTA@mail.gmail.com>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Tue, Jun 18, 2013 at 10:10 AM, Vasilis Liaskovitis
<vasilis.liaskovitis@profitbricks.com> wrote:
>> could be found at:
>>         git://git.kernel.org/pub/scm/linux/kernel/git/yinghai/linux-yinghai.git for-x86-mm
>>
>> and it is based on today's Linus tree.
>>
>
> Has this patchset been tested on various numa configs?
> I am using linux-next next-20130607 + part1 with qemu/kvm/seabios VMs. The kernel
> boots successfully in many numa configs but while trying different memory sizes
> for a 2 numa node VM, I noticed that booting does not complete in all cases
> (bootup screen appears to hang but there is no output indicating an early panic)
>
> node0   node1    boots
> 1G      1G       yes
> 1G      2G       yes
> 1G      0.5G     yes
> 3G      2.5G     yes
> 3G      3G       yes
> 4G      0G       yes
> 4G      4G       yes
> 1.5G    1G       no
> 2G      1G       no
> 2G      2G       no
> 2.5G    2G       no
> 2.5G    2.5G     no
>
> linux-next next-20130607 boots al of these configs fine.
>
> Looks odd, perhaps I have something wrong in my setup or maybe there is a
> seabios/qemu interaction with this patchset. I will update if I find something.

just tried 2g/2g, and it works on qemu-kvm:

early console in setup code
Probing EDD (edd=off to disable)... ok
early console in decompress_kernel
decompress_kernel:
  input: [0x2a8e2c2-0x3393991], output: 0x1000000, heap: [0x339b200-0x33a31ff]

Decompressing Linux... xz... Parsing ELF... done.
Booting the kernel.
[    0.000000] bootconsole [uart0] enabled
[    0.000000]    real_mode_data :      phys 0000000000014490
[    0.000000]    real_mode_data :      virt ffff880000014490
[    0.000000]       boot_params : init virt ffffffff82f869a0
[    0.000000]       boot_params :      phys 0000000002f869a0
[    0.000000]       boot_params :      virt ffff880002f869a0
[    0.000000] boot_command_line : init virt ffffffff82e53020
[    0.000000] boot_command_line :      phys 0000000002e53020
[    0.000000] boot_command_line :      virt ffff880002e53020
[    0.000000] Kernel Layout:
[    0.000000]   .text: [0x01000000-0x020b8840]
[    0.000000] .rodata: [0x02200000-0x029d3fff]
[    0.000000]   .data: [0x02a00000-0x02bd4d7f]
[    0.000000]   .init: [0x02bd6000-0x02f71fff]
[    0.000000]    .bss: [0x02f80000-0x03c20fff]
[    0.000000]    .brk: [0x03c21000-0x03c45fff]
[    0.000000] memblock_reserve: [0x0009f000-0x000fffff] * BIOS reserved
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 3.10.0-rc6-yh-01398-ga6660aa-dirty
(yhlu@linux-siqj.site) (gcc version 4.7.2 20130108 [gcc-4_7-branch
revision 195012] (SUSE Linux) ) #1754 SMP Tue Jun 18 13:10:47 PDT 2013
[    0.000000] memblock_reserve: [0x01000000-0x03c20fff] TEXT DATA BSS
[    0.000000] memblock_reserve: [0x7dcef000-0x7fffefff] RAMDISK
[    0.000000] Command line: BOOT_IMAGE=linux debug ignore_loglevel
initcall_debug pci=routeirq ramdisk_size=262144 root=/dev/ram0 rw
ip=dhcp console=uart8250,io,0x3f8,115200 initrd=initrd.img
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] Physical RAM map:
[    0.000000] raw: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] raw: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] raw: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] raw: [mem 0x0000000000100000-0x00000000dfffdfff] usable
[    0.000000] raw: [mem 0x00000000dfffe000-0x00000000dfffffff] reserved
[    0.000000] raw: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] raw: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] raw: [mem 0x0000000100000000-0x000000011fffffff] usable
[    0.000000] e820: BIOS-provided physical RAM map (sanitized by setup):
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000dfffdfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000dfffe000-0x00000000dfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000011fffffff] usable
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x120000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 [00E0000000-00FFFFFFFF] mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] PAT not supported by CPU.
[    0.000000] e820: last_pfn = 0xdfffe max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef]
mapped at [ffff8800000fdae0]
[    0.000000] memblock_reserve: [0x000fdae0-0x000fdaef] * MP-table mpf
[    0.000000] memblock_reserve: [0x000fdaf0-0x000fdbe3] * MP-table mpc
[    0.000000] memblock_reserve: [0x03c21000-0x03c26fff] BRK
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0xfff9cc00 reserved size = 0x4f98000
[    0.000000]  memory.cnt  = 0x3
[    0.000000]  memory[0x0]    [0x00001000-0x0009efff], 0x9e000 bytes
[    0.000000]  memory[0x1]    [0x00100000-0xdfffdfff], 0xdfefe000 bytes
[    0.000000]  memory[0x2]    [0x100000000-0x11fffffff], 0x20000000 bytes
[    0.000000]  reserved.cnt  = 0x3
[    0.000000]  reserved[0x0]    [0x0009f000-0x000fffff], 0x61000 bytes
[    0.000000]  reserved[0x1]    [0x01000000-0x03c26fff], 0x2c27000 bytes
[    0.000000]  reserved[0x2]    [0x7dcef000-0x7fffefff], 0x2310000 bytes
[    0.000000] memblock_reserve: [0x00099000-0x0009efff] TRAMPOLINE
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] memblock_reserve: [0x00000000-0x0000ffff] RESERVELOW
[    0.000000] ACPI: RSDP 00000000000fd8d0 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 00000000dfffe270 00038 (v01 BOCHS  BXPCRSDT
00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 00000000dfffff80 00074 (v01 BOCHS  BXPCFACP
00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 00000000dfffe2b0 011A9 (v01   BXPC   BXDSDT
00000001 INTL 20100528)
[    0.000000] ACPI: FACS 00000000dfffff40 00040
[    0.000000] ACPI: SSDT 00000000dffff6e0 00858 (v01 BOCHS  BXPCSSDT
00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 00000000dffff5b0 00090 (v01 BOCHS  BXPCAPIC
00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 00000000dffff570 00038 (v01 BOCHS  BXPCHPET
00000001 BXPC 00000001)
[    0.000000] ACPI: SRAT 00000000dffff460 00110 (v01 BOCHS  BXPCSRAT
00000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
[    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
[    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
[    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00100000-0x7fffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x80000000-0xdfffffff]
[    0.000000] SRAT: Node 1 PXM 1 [mem 0x100000000-0x11fffffff]
[    0.000000] NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem
0x00100000-0x7fffffff] -> [mem 0x00000000-0x7fffffff]
[    0.000000] NUMA: Node 1 [mem 0x80000000-0xdfffffff] + [mem
0x100000000-0x11fffffff] -> [mem 0x80000000-0x11fffffff]
[    0.000000] Node 0: [mem 0x00000000000000-0x0000007fffffff]
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x03c22000, 0x03c22fff] PGTABLE
[    0.000000] BRK [0x03c23000, 0x03c23fff] PGTABLE
[    0.000000] BRK [0x03c24000, 0x03c24fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x7da00000-0x7dbfffff]
[    0.000000]  [mem 0x7da00000-0x7dbfffff] page 2M
[    0.000000] BRK [0x03c25000, 0x03c25fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x7c000000-0x7d9fffff]
[    0.000000]  [mem 0x7c000000-0x7d9fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x7bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x7bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x7dc00000-0x7fffffff]
[    0.000000]  [mem 0x7dc00000-0x7fffffff] page 2M
[    0.000000] Node 1: [mem 0x00000080000000-0x0000011fffffff]
[    0.000000] init_memory_mapping: [mem 0x11fe00000-0x11fffffff]
[    0.000000]  [mem 0x11fe00000-0x11fffffff] page 2M
[    0.000000] BRK [0x03c26000, 0x03c26fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11c000000-0x11fdfffff]
[    0.000000]  [mem 0x11c000000-0x11fdfffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x100000000-0x11bffffff]
[    0.000000]  [mem 0x100000000-0x11bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x80000000-0xdfffdfff]
[    0.000000]  [mem 0x80000000-0xdfdfffff] page 2M
[    0.000000]  [mem 0xdfe00000-0xdfffdfff] page 4k
[    0.000000] memblock_reserve: [0x11ffff000-0x11fffffff] PGTABLE
[    0.000000] memblock_reserve: [0x11fffe000-0x11fffefff] PGTABLE
[    0.000000] memblock_reserve: [0x11fffd000-0x11fffdfff] PGTABLE
[    0.000000] RAMDISK: [mem 0x7dcef000-0x7fffefff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x7fffffff]
[    0.000000] memblock_reserve: [0x7dcc8000-0x7dceefff]
[    0.000000]   NODE_DATA [mem 0x7dcc8000-0x7dceefff]
[    0.000000] Initmem setup node 1 [mem 0x80000000-0x11fffffff]
[    0.000000] memblock_reserve: [0x11ffd6000-0x11fffcfff]
[    0.000000]   NODE_DATA [mem 0x11ffd6000-0x11fffcfff]
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0xfff9cc00 reserved size = 0x4fff000
[    0.000000]  memory.cnt  = 0x4
[    0.000000]  memory[0x0]    [0x00001000-0x0009efff], 0x9e000 bytes on node 0
[    0.000000]  memory[0x1]    [0x00100000-0x7fffffff], 0x7ff00000
bytes on node 0
[    0.000000]  memory[0x2]    [0x80000000-0xdfffdfff], 0x5fffe000
bytes on node 1
[    0.000000]  memory[0x3]    [0x100000000-0x11fffffff], 0x20000000
bytes on node 1
[    0.000000]  reserved.cnt  = 0x5
[    0.000000]  reserved[0x0]    [0x00000000-0x0000ffff], 0x10000 bytes
[    0.000000]  reserved[0x1]    [0x00099000-0x000fffff], 0x67000 bytes
[    0.000000]  reserved[0x2]    [0x01000000-0x03c26fff], 0x2c27000 bytes
[    0.000000]  reserved[0x3]    [0x7dcc8000-0x7fffefff], 0x2337000 bytes
[    0.000000]  reserved[0x4]    [0x11ffd6000-0x11fffffff], 0x2a000 bytes
[    0.000000] memblock_reserve: [0x7ffff000-0x7fffffff] sparse section
[    0.000000] memblock_reserve: [0x11fbd6000-0x11ffd5fff] usemap_map
[    0.000000] memblock_reserve: [0x7dcc7e00-0x7dcc7fff] usemap section
[    0.000000] memblock_reserve: [0x11fbd5e00-0x11fbd5fff] usemap section
[    0.000000] memblock_reserve: [0x11f7d5e00-0x11fbd5dff] map_map
[    0.000000] memblock_reserve: [0x7bc00000-0x7dbfffff] vmemmap buf
[    0.000000] memblock_reserve: [0x7dcc6000-0x7dcc6fff] vmemmap block
[    0.000000]  [ffffea0000000000-ffffea7fffffffff] PGD @
ffff88007dcc6000 on node 0
[    0.000000] memblock_reserve: [0x7dcc5000-0x7dcc5fff] vmemmap block
[    0.000000]  [ffffea0000000000-ffffea003fffffff] PUD @
ffff88007dcc5000 on node 0
[    0.000000]    memblock_free: [0x7dc00000-0x7dbfffff]
[    0.000000] memblock_reserve: [0x11d600000-0x11f5fffff] vmemmap buf
[    0.000000]  [ffffea0000000000-ffffea0001ffffff] PMD ->
[ffff88007bc00000-ffff88007dbfffff] on node 0
[    0.000000]    memblock_free: [0x11f600000-0x11f5fffff]
[    0.000000]  [ffffea0002000000-ffffea00047fffff] PMD ->
[ffff88011d600000-ffff88011f5fffff] on node 1
[    0.000000]    memblock_free: [0x11f7d5e00-0x11fbd5dff]
[    0.000000]    memblock_free: [0x11fbd6000-0x11ffd5fff]Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x11fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x7fffffff]
[    0.000000]   node   1: [mem 0x80000000-0xdfffdfff]
[    0.000000]   node   1: [mem 0x100000000-0x11fffffff]
[    0.000000] start - node_states[2]:
[    0.000000] On node 0 totalpages: 524190
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000] memblock_reserve: [0x7dc6d000-0x7dcc4fff] pgdat
[    0.000000]   DMA32 zone: 8128 pages used for memmap
[    0.000000]   DMA32 zone: 520192 pages, LIFO batch:31
[    0.000000] memblock_reserve: [0x7dc15000-0x7dc6cfff] pgdat
[    0.000000] On node 1 totalpages: 524286
[    0.000000]   DMA32 zone: 6144 pages used for memmap
[    0.000000]   DMA32 zone: 393214 pages, LIFO batch:31
[    0.000000] memblock_reserve: [0x11ff7e000-0x11ffd5fff] pgdat
[    0.000000]   Normal zone: 2048 pages used for memmap
[    0.000000]   Normal zone: 131072 pages, LIFO batch:31
[    0.000000] memblock_reserve: [0x11ff26000-0x11ff7dfff] pgdat
[    0.000000] after - node_states[2]: 0-1
[    0.000000] memblock_reserve: [0x11ff25000-0x11ff25fff] pgtable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
