Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7C3E46B007D
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:33:28 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2263349ghr.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 14:33:27 -0700 (PDT)
Message-ID: <1339709672.3321.11.camel@lappy>
Subject: Re: Early boot panic on machine with lots of memory
From: Sasha Levin <levinsasha928@gmail.com>
Date: Thu, 14 Jun 2012 23:34:32 +0200
In-Reply-To: <CAE9FiQVJ-q3gQxfBqfRnG+RvEh2bZ2-Ki=CRUATmCKjJp8MNuw@mail.gmail.com>
References: <1339623535.3321.4.camel@lappy>
	 <20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	 <1339667440.3321.7.camel@lappy>
	 <CAE9FiQVJ-q3gQxfBqfRnG+RvEh2bZ2-Ki=CRUATmCKjJp8MNuw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 2012-06-14 at 13:56 -0700, Yinghai Lu wrote:
> On Thu, Jun 14, 2012 at 2:50 AM, Sasha Levin <levinsasha928@gmail.com> wrote:
> > On Thu, 2012-06-14 at 12:20 +0900, Tejun Heo wrote:
> >> On Wed, Jun 13, 2012 at 11:38:55PM +0200, Sasha Levin wrote:
> >> > Hi all,
> >> >
> >> > I'm seeing the following when booting a KVM guest with 65gb of RAM, on latest linux-next.
> >> >
> >> > Note that it happens with numa=off.
> >> >
> >> > [    0.000000] BUG: unable to handle kernel paging request at ffff88102febd948
> >> > [    0.000000] IP: [<ffffffff836a6f37>] __next_free_mem_range+0x9b/0x155
> >>
> >> Can you map it back to the source line please?
> >
> > mm/memblock.c:583
> >
> >                        phys_addr_t r_start = ri ? r[-1].base + r[-1].size : 0;
> >  97:   85 d2                   test   %edx,%edx
> >  99:   74 08                   je     a3 <__next_free_mem_range+0xa3>
> >  9b:   49 8b 48 f0             mov    -0x10(%r8),%rcx
> >  9f:   49 03 48 e8             add    -0x18(%r8),%rcx
> >
> > It's the deref on 9b (r8=ffff88102febd958).
> 
> that reserved.region is allocated by memblock.
> 
> can you boot with "memblock=debug debug ignore_loglevel" and post
> whole boot log?

Attached below. I've also noticed it doesn't always happen, but
increasing the vcpu count (to something around 254) makes it happen
almost every time.

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.5.0-rc2-next-20120614-sasha (sasha@lappy) (gcc version 4.4.5 (Debian 4.4.5-8) ) #447 SMP PREEMPT Thu Jun 14 17:17:56 EDT 2012
[    0.000000] Command line: noapic noacpi pci=conf1 reboot=k panic=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 console=ttyS0 earlyprintk=serial i8042.noaux=1 sched_debug slub_debug=FZPU init=/virt/init numa=off memblock=debug debug ignore_loglevel root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L rootfstype=9p init=/virt/init
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000ffffe] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000cfffffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000102fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI not present or invalid.
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0x1030000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges disabled:
[    0.000000]   00000-FFFFF uncachable
[    0.000000] MTRR variable ranges disabled:
[    0.000000]   0 disabled
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70106, new 0x7010600070106
[    0.000000] CPU MTRRs all blank - virtualized system.
[    0.000000] e820: last_pfn = 0xd0000 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f1740-0x000f174f] mapped at [ffff8800000f1740]
[    0.000000] memblock_reserve: [0x000000000f1740-0x000000000f1750] smp_scan_config+0xd1/0x10e
[    0.000000] memblock_reserve: [0x000000000f02f0-0x000000000f173c] smp_scan_config+0xef/0x10e
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0xffff8fc00 reserved size = 0x5282000
[    0.000000]  memory.cnt  = 0x3
[    0.000000]  memory[0x0]	[0x00000000010000-0x0000000009fbff], 0x8fc00 bytes
[    0.000000]  memory[0x1]	[0x00000000100000-0x000000cfffffff], 0xcff00000 bytes
[    0.000000]  memory[0x2]	[0x00000100000000-0x0000102fffffff], 0xf30000000 bytes
[    0.000000]  reserved.cnt  = 0x2
[    0.000000]  reserved[0x0]	[0x0000000009f000-0x000000000fffff], 0x61000 bytes
[    0.000000]  reserved[0x1]	[0x00000001000000-0x00000006220fff], 0x5221000 bytes
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] memblock_reserve: [0x00000000099000-0x0000000009f000] setup_real_mode+0x69/0x1b7
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0xcfffffff]
[    0.000000]  [mem 0x00000000-0xcfffffff] page 4k
[    0.000000] kernel direct mapping tables up to 0xcfffffff @ [mem 0x1f97b000-0x1fffffff]
[    0.000000] memblock_reserve: [0x0000001f97b000-0x0000001fffe000] native_pagetable_reserve+0xc/0xe
[    0.000000] init_memory_mapping: [mem 0x100000000-0x102fffffff]
[    0.000000]  [mem 0x100000000-0x102fffffff] page 4k
[    0.000000] kernel direct mapping tables up to 0x102fffffff @ [mem 0xc7e3e000-0xcfffffff]
[    0.000000] memblock_reserve: [0x000000c7e3e000-0x000000cf7fb000] native_pagetable_reserve+0xc/0xe
[    0.000000] ACPI Error: A valid RSDP was not found (20120518/tbxfroot-219)
[    0.000000] NUMA turned off
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000102fffffff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x102fffffff]
[    0.000000] memblock_reserve: [0x0000102ffcf000-0x00001030000000] memblock_alloc_base_nid+0x3d/0x50
[    0.000000]   NODE_DATA [mem 0x102ffcf000-0x102fffffff]
[    0.000000] MEMBLOCK configuration:
[    0.000000]  memory size = 0xffff8fc00 reserved size = 0xd2f9000
[    0.000000]  memory.cnt  = 0x3
[    0.000000]  memory[0x0]	[0x00000000010000-0x0000000009fbff], 0x8fc00 bytes on node 0
[    0.000000]  memory[0x1]	[0x00000000100000-0x000000cfffffff], 0xcff00000 bytes on node 0
[    0.000000]  memory[0x2]	[0x00000100000000-0x0000102fffffff], 0xf30000000 bytes on node 0
[    0.000000]  reserved.cnt  = 0x5
[    0.000000]  reserved[0x0]	[0x00000000099000-0x000000000fffff], 0x67000 bytes
[    0.000000]  reserved[0x1]	[0x00000001000000-0x00000006220fff], 0x5221000 bytes
[    0.000000]  reserved[0x2]	[0x0000001f97b000-0x0000001fffdfff], 0x683000 bytes
[    0.000000]  reserved[0x3]	[0x000000c7e3e000-0x000000cf7fafff], 0x79bd000 bytes
[    0.000000]  reserved[0x4]	[0x0000102ffcf000-0x0000102fffffff], 0x31000 bytes
[    0.000000] memblock_reserve: [0x0000102ffce000-0x0000102ffcf000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102ffcd000-0x0000102ffce000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102ffcc000-0x0000102ffcd000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fbcc000-0x0000102ffcc000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fbc9000-0x0000102fbcc000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102f7c9000-0x0000102fbc9000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x00000fef600000-0x0000102f600000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102f7c8000-0x0000102f7c9000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102f7c7000-0x0000102f7c8000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102f7c6000-0x0000102f7c7000] __alloc_memory_core_early+0x5c/0x73
[    0.000000]    memblock_free: [0x0000102f600000-0x0000102f600000] free_bootmem+0x2b/0x30
[    0.000000]  [ffffea0000000000-ffffea0040bfffff] PMD -> [ffff880fef600000-ffff88102f5fffff] on node 0
[    0.000000]    memblock_free: [0x0000102f7c9000-0x0000102fbc9000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x0000102fbcc000-0x0000102ffcc000] free_bootmem+0x2b/0x30
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x102fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xcfffffff]
[    0.000000]   node   0: [mem 0x100000000-0x102fffffff]
[    0.000000] On node 0 totalpages: 16777103
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000] memblock_reserve: [0x0000102ff74000-0x0000102ffcc000] __alloc_memory_core_early+0x5c/0x73
[    0.000000]   DMA32 zone: 16320 pages used for memmap
[    0.000000]   DMA32 zone: 831552 pages, LIFO batch:31
[    0.000000] memblock_reserve: [0x0000102ff1c000-0x0000102ff74000] __alloc_memory_core_early+0x5c/0x73
[    0.000000]   Normal zone: 248832 pages used for memmap
[    0.000000]   Normal zone: 15676416 pages, LIFO batch:31
[    0.000000] memblock_reserve: [0x0000102fec4000-0x0000102ff1c000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec3000-0x0000102fec4000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] SFI: Simple Firmware Interface v0.81 http://simplefirmware.org
[    0.000000] Intel MultiProcessor Specification v1.4
[    0.000000] MPTABLE: OEM ID: KVMCPU00
[    0.000000] MPTABLE: Product ID: 0.1         
[    0.000000] MPTABLE: APIC at: 0xFEE00000
[    0.000000] Processor #0 (Bootup-CPU)
[    0.000000] Processor #1
[    0.000000] Processor #2
[    0.000000] Processor #3
[    0.000000] Processor #4
[    0.000000] Processor #5
[    0.000000] Processor #6
[    0.000000] Processor #7
[    0.000000] Processor #8
[    0.000000] Processor #9
[    0.000000] Processor #10
[    0.000000] Processor #11
[    0.000000] Processor #12
[    0.000000] Processor #13
[    0.000000] Processor #14
[    0.000000] Processor #15
[    0.000000] Processor #16
[    0.000000] Processor #17
[    0.000000] Processor #18
[    0.000000] Processor #19
[    0.000000] Processor #20
[    0.000000] Processor #21
[    0.000000] Processor #22
[    0.000000] Processor #23
[    0.000000] Processor #24
[    0.000000] Processor #25
[    0.000000] Processor #26
[    0.000000] Processor #27
[    0.000000] Processor #28
[    0.000000] Processor #29
[    0.000000] Processor #30
[    0.000000] Processor #31
[    0.000000] Processor #32
[    0.000000] Processor #33
[    0.000000] Processor #34
[    0.000000] Processor #35
[    0.000000] Processor #36
[    0.000000] Processor #37
[    0.000000] Processor #38
[    0.000000] Processor #39
[    0.000000] Processor #40
[    0.000000] Processor #41
[    0.000000] Processor #42
[    0.000000] Processor #43
[    0.000000] Processor #44
[    0.000000] Processor #45
[    0.000000] Processor #46
[    0.000000] Processor #47
[    0.000000] Processor #48
[    0.000000] Processor #49
[    0.000000] Processor #50
[    0.000000] Processor #51
[    0.000000] Processor #52
[    0.000000] Processor #53
[    0.000000] Processor #54
[    0.000000] Processor #55
[    0.000000] Processor #56
[    0.000000] Processor #57
[    0.000000] Processor #58
[    0.000000] Processor #59
[    0.000000] Processor #60
[    0.000000] Processor #61
[    0.000000] Processor #62
[    0.000000] Processor #63
[    0.000000] Processor #64
[    0.000000] Processor #65
[    0.000000] Processor #66
[    0.000000] Processor #67
[    0.000000] Processor #68
[    0.000000] Processor #69
[    0.000000] Processor #70
[    0.000000] Processor #71
[    0.000000] Processor #72
[    0.000000] Processor #73
[    0.000000] Processor #74
[    0.000000] Processor #75
[    0.000000] Processor #76
[    0.000000] Processor #77
[    0.000000] Processor #78
[    0.000000] Processor #79
[    0.000000] Processor #80
[    0.000000] Processor #81
[    0.000000] Processor #82
[    0.000000] Processor #83
[    0.000000] Processor #84
[    0.000000] Processor #85
[    0.000000] Processor #86
[    0.000000] Processor #87
[    0.000000] Processor #88
[    0.000000] Processor #89
[    0.000000] Processor #90
[    0.000000] Processor #91
[    0.000000] Processor #92
[    0.000000] Processor #93
[    0.000000] Processor #94
[    0.000000] Processor #95
[    0.000000] Processor #96
[    0.000000] Processor #97
[    0.000000] Processor #98
[    0.000000] Processor #99
[    0.000000] Processor #100
[    0.000000] Processor #101
[    0.000000] Processor #102
[    0.000000] Processor #103
[    0.000000] Processor #104
[    0.000000] Processor #105
[    0.000000] Processor #106
[    0.000000] Processor #107
[    0.000000] Processor #108
[    0.000000] Processor #109
[    0.000000] Processor #110
[    0.000000] Processor #111
[    0.000000] Processor #112
[    0.000000] Processor #113
[    0.000000] Processor #114
[    0.000000] Processor #115
[    0.000000] Processor #116
[    0.000000] Processor #117
[    0.000000] Processor #118
[    0.000000] Processor #119
[    0.000000] Processor #120
[    0.000000] Processor #121
[    0.000000] Processor #122
[    0.000000] Processor #123
[    0.000000] Processor #124
[    0.000000] Processor #125
[    0.000000] Processor #126
[    0.000000] Processor #127
[    0.000000] Processor #128
[    0.000000] Processor #129
[    0.000000] Processor #130
[    0.000000] Processor #131
[    0.000000] Processor #132
[    0.000000] Processor #133
[    0.000000] Processor #134
[    0.000000] Processor #135
[    0.000000] Processor #136
[    0.000000] Processor #137
[    0.000000] Processor #138
[    0.000000] Processor #139
[    0.000000] Processor #140
[    0.000000] Processor #141
[    0.000000] Processor #142
[    0.000000] Processor #143
[    0.000000] Processor #144
[    0.000000] Processor #145
[    0.000000] Processor #146
[    0.000000] Processor #147
[    0.000000] Processor #148
[    0.000000] Processor #149
[    0.000000] Processor #150
[    0.000000] Processor #151
[    0.000000] Processor #152
[    0.000000] Processor #153
[    0.000000] Processor #154
[    0.000000] Processor #155
[    0.000000] Processor #156
[    0.000000] Processor #157
[    0.000000] Processor #158
[    0.000000] Processor #159
[    0.000000] Processor #160
[    0.000000] Processor #161
[    0.000000] Processor #162
[    0.000000] Processor #163
[    0.000000] Processor #164
[    0.000000] Processor #165
[    0.000000] Processor #166
[    0.000000] Processor #167
[    0.000000] Processor #168
[    0.000000] Processor #169
[    0.000000] Processor #170
[    0.000000] Processor #171
[    0.000000] Processor #172
[    0.000000] Processor #173
[    0.000000] Processor #174
[    0.000000] Processor #175
[    0.000000] Processor #176
[    0.000000] Processor #177
[    0.000000] Processor #178
[    0.000000] Processor #179
[    0.000000] Processor #180
[    0.000000] Processor #181
[    0.000000] Processor #182
[    0.000000] Processor #183
[    0.000000] Processor #184
[    0.000000] Processor #185
[    0.000000] Processor #186
[    0.000000] Processor #187
[    0.000000] Processor #188
[    0.000000] Processor #189
[    0.000000] Processor #190
[    0.000000] Processor #191
[    0.000000] Processor #192
[    0.000000] Processor #193
[    0.000000] Processor #194
[    0.000000] Processor #195
[    0.000000] Processor #196
[    0.000000] Processor #197
[    0.000000] Processor #198
[    0.000000] Processor #199
[    0.000000] Processor #200
[    0.000000] Processor #201
[    0.000000] Processor #202
[    0.000000] Processor #203
[    0.000000] Processor #204
[    0.000000] Processor #205
[    0.000000] Processor #206
[    0.000000] Processor #207
[    0.000000] Processor #208
[    0.000000] Processor #209
[    0.000000] Processor #210
[    0.000000] Processor #211
[    0.000000] Processor #212
[    0.000000] Processor #213
[    0.000000] Processor #214
[    0.000000] Processor #215
[    0.000000] Processor #216
[    0.000000] Processor #217
[    0.000000] Processor #218
[    0.000000] Processor #219
[    0.000000] Processor #220
[    0.000000] Processor #221
[    0.000000] Processor #222
[    0.000000] Processor #223
[    0.000000] Processor #224
[    0.000000] Processor #225
[    0.000000] Processor #226
[    0.000000] Processor #227
[    0.000000] Processor #228
[    0.000000] Processor #229
[    0.000000] Processor #230
[    0.000000] Processor #231
[    0.000000] Processor #232
[    0.000000] Processor #233
[    0.000000] Processor #234
[    0.000000] Processor #235
[    0.000000] Processor #236
[    0.000000] Processor #237
[    0.000000] Processor #238
[    0.000000] Processor #239
[    0.000000] Processor #240
[    0.000000] Processor #241
[    0.000000] Processor #242
[    0.000000] Processor #243
[    0.000000] Processor #244
[    0.000000] Processor #245
[    0.000000] Processor #246
[    0.000000] Processor #247
[    0.000000] Processor #248
[    0.000000] Processor #249
[    0.000000] Processor #250
[    0.000000] Processor #251
[    0.000000] Processor #252
[    0.000000] Processor #253
[    0.000000] IOAPIC[0]: apic_id 255, version 17, address 0xfec00000, GSI 0-23
[    0.000000] Processors: 254
[    0.000000] smpboot: Allowing 254 CPUs, 0 hotplug CPUs
[    0.000000] memblock_reserve: [0x0000102fec2f80-0x0000102fec2fc3] __alloc_memory_core_early+0x5c/0x73
[    0.000000] nr_irqs_gsi: 40
[    0.000000] memblock_reserve: [0x0000102fec2e00-0x0000102fec2f50] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2d80-0x0000102fec2de8] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2d00-0x0000102fec2d68] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2c80-0x0000102fec2ce8] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2c00-0x0000102fec2c68] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2b80-0x0000102fec2be8] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2b40-0x0000102fec2b60] __alloc_memory_core_early+0x5c/0x73
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000000ff000
[    0.000000] PM: Registered nosave memory: 00000000000ff000 - 0000000000100000
[    0.000000] memblock_reserve: [0x0000102fec2b00-0x0000102fec2b20] __alloc_memory_core_early+0x5c/0x73
[    0.000000] PM: Registered nosave memory: 00000000d0000000 - 0000000100000000
[    0.000000] e820: [mem 0xd0000000-0xffffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] memblock_reserve: [0x0000102fec29c0-0x0000102fec2afa] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2880-0x0000102fec29ba] __alloc_memory_core_early+0x5c/0x73
[    0.000000] setup_percpu: NR_CPUS:4096 nr_cpumask_bits:254 nr_cpu_ids:254 nr_node_ids:1
[    0.000000] memblock_reserve: [0x0000102fec1880-0x0000102fec2880] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec0880-0x0000102fec1880] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x00000fcfa00000-0x00000fef600000] __alloc_memory_core_early+0x5c/0x73
[    0.000000]    memblock_free: [0x00000fcfbdd000-0x00000fcfc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fcfddd000-0x00000fcfe00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fcffdd000-0x00000fd0000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd01dd000-0x00000fd0200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd03dd000-0x00000fd0400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd05dd000-0x00000fd0600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd07dd000-0x00000fd0800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd09dd000-0x00000fd0a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd0bdd000-0x00000fd0c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd0ddd000-0x00000fd0e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd0fdd000-0x00000fd1000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd11dd000-0x00000fd1200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd13dd000-0x00000fd1400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd15dd000-0x00000fd1600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd17dd000-0x00000fd1800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd19dd000-0x00000fd1a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd1bdd000-0x00000fd1c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd1ddd000-0x00000fd1e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd1fdd000-0x00000fd2000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd21dd000-0x00000fd2200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd23dd000-0x00000fd2400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd25dd000-0x00000fd2600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd27dd000-0x00000fd2800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd29dd000-0x00000fd2a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd2bdd000-0x00000fd2c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd2ddd000-0x00000fd2e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd2fdd000-0x00000fd3000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd31dd000-0x00000fd3200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd33dd000-0x00000fd3400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd35dd000-0x00000fd3600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd37dd000-0x00000fd3800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd39dd000-0x00000fd3a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd3bdd000-0x00000fd3c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd3ddd000-0x00000fd3e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd3fdd000-0x00000fd4000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd41dd000-0x00000fd4200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd43dd000-0x00000fd4400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd45dd000-0x00000fd4600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd47dd000-0x00000fd4800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd49dd000-0x00000fd4a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd4bdd000-0x00000fd4c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd4ddd000-0x00000fd4e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd4fdd000-0x00000fd5000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd51dd000-0x00000fd5200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd53dd000-0x00000fd5400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd55dd000-0x00000fd5600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd57dd000-0x00000fd5800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd59dd000-0x00000fd5a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd5bdd000-0x00000fd5c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd5ddd000-0x00000fd5e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd5fdd000-0x00000fd6000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd61dd000-0x00000fd6200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd63dd000-0x00000fd6400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd65dd000-0x00000fd6600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd67dd000-0x00000fd6800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd69dd000-0x00000fd6a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd6bdd000-0x00000fd6c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd6ddd000-0x00000fd6e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd6fdd000-0x00000fd7000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd71dd000-0x00000fd7200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd73dd000-0x00000fd7400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd75dd000-0x00000fd7600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd77dd000-0x00000fd7800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd79dd000-0x00000fd7a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd7bdd000-0x00000fd7c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd7ddd000-0x00000fd7e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd7fdd000-0x00000fd8000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd81dd000-0x00000fd8200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd83dd000-0x00000fd8400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd85dd000-0x00000fd8600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd87dd000-0x00000fd8800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd89dd000-0x00000fd8a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd8bdd000-0x00000fd8c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd8ddd000-0x00000fd8e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd8fdd000-0x00000fd9000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd91dd000-0x00000fd9200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd93dd000-0x00000fd9400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd95dd000-0x00000fd9600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd97dd000-0x00000fd9800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd99dd000-0x00000fd9a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd9bdd000-0x00000fd9c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd9ddd000-0x00000fd9e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fd9fdd000-0x00000fda000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fda1dd000-0x00000fda200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fda3dd000-0x00000fda400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fda5dd000-0x00000fda600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fda7dd000-0x00000fda800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fda9dd000-0x00000fdaa00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdabdd000-0x00000fdac00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdaddd000-0x00000fdae00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdafdd000-0x00000fdb000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdb1dd000-0x00000fdb200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdb3dd000-0x00000fdb400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdb5dd000-0x00000fdb600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdb7dd000-0x00000fdb800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdb9dd000-0x00000fdba00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdbbdd000-0x00000fdbc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdbddd000-0x00000fdbe00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdbfdd000-0x00000fdc000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdc1dd000-0x00000fdc200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdc3dd000-0x00000fdc400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdc5dd000-0x00000fdc600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdc7dd000-0x00000fdc800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdc9dd000-0x00000fdca00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdcbdd000-0x00000fdcc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdcddd000-0x00000fdce00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdcfdd000-0x00000fdd000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdd1dd000-0x00000fdd200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdd3dd000-0x00000fdd400000] free_bootmem+0x2b/0x30
[    0.000000] memblock: reserved array is doubled to 256 at [0x102febf080-0x102fec087f]
[    0.000000] memblock_reserve: [0x0000102febf080-0x0000102fec0880] memblock_double_array+0x1c5/0x1e2
[    0.000000]    memblock_free: [0x00000fdd5dd000-0x00000fdd600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdd7dd000-0x00000fdd800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdd9dd000-0x00000fdda00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fddbdd000-0x00000fddc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fddddd000-0x00000fdde00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fddfdd000-0x00000fde000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fde1dd000-0x00000fde200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fde3dd000-0x00000fde400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fde5dd000-0x00000fde600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fde7dd000-0x00000fde800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fde9dd000-0x00000fdea00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdebdd000-0x00000fdec00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdeddd000-0x00000fdee00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdefdd000-0x00000fdf000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdf1dd000-0x00000fdf200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdf3dd000-0x00000fdf400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdf5dd000-0x00000fdf600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdf7dd000-0x00000fdf800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdf9dd000-0x00000fdfa00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdfbdd000-0x00000fdfc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdfddd000-0x00000fdfe00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fdffdd000-0x00000fe0000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe01dd000-0x00000fe0200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe03dd000-0x00000fe0400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe05dd000-0x00000fe0600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe07dd000-0x00000fe0800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe09dd000-0x00000fe0a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe0bdd000-0x00000fe0c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe0ddd000-0x00000fe0e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe0fdd000-0x00000fe1000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe11dd000-0x00000fe1200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe13dd000-0x00000fe1400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe15dd000-0x00000fe1600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe17dd000-0x00000fe1800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe19dd000-0x00000fe1a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe1bdd000-0x00000fe1c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe1ddd000-0x00000fe1e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe1fdd000-0x00000fe2000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe21dd000-0x00000fe2200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe23dd000-0x00000fe2400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe25dd000-0x00000fe2600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe27dd000-0x00000fe2800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe29dd000-0x00000fe2a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe2bdd000-0x00000fe2c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe2ddd000-0x00000fe2e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe2fdd000-0x00000fe3000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe31dd000-0x00000fe3200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe33dd000-0x00000fe3400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe35dd000-0x00000fe3600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe37dd000-0x00000fe3800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe39dd000-0x00000fe3a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe3bdd000-0x00000fe3c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe3ddd000-0x00000fe3e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe3fdd000-0x00000fe4000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe41dd000-0x00000fe4200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe43dd000-0x00000fe4400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe45dd000-0x00000fe4600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe47dd000-0x00000fe4800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe49dd000-0x00000fe4a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe4bdd000-0x00000fe4c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe4ddd000-0x00000fe4e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe4fdd000-0x00000fe5000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe51dd000-0x00000fe5200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe53dd000-0x00000fe5400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe55dd000-0x00000fe5600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe57dd000-0x00000fe5800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe59dd000-0x00000fe5a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe5bdd000-0x00000fe5c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe5ddd000-0x00000fe5e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe5fdd000-0x00000fe6000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe61dd000-0x00000fe6200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe63dd000-0x00000fe6400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe65dd000-0x00000fe6600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe67dd000-0x00000fe6800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe69dd000-0x00000fe6a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe6bdd000-0x00000fe6c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe6ddd000-0x00000fe6e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe6fdd000-0x00000fe7000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe71dd000-0x00000fe7200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe73dd000-0x00000fe7400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe75dd000-0x00000fe7600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe77dd000-0x00000fe7800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe79dd000-0x00000fe7a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe7bdd000-0x00000fe7c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe7ddd000-0x00000fe7e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe7fdd000-0x00000fe8000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe81dd000-0x00000fe8200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe83dd000-0x00000fe8400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe85dd000-0x00000fe8600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe87dd000-0x00000fe8800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe89dd000-0x00000fe8a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe8bdd000-0x00000fe8c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe8ddd000-0x00000fe8e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe8fdd000-0x00000fe9000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe91dd000-0x00000fe9200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe93dd000-0x00000fe9400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe95dd000-0x00000fe9600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe97dd000-0x00000fe9800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe99dd000-0x00000fe9a00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe9bdd000-0x00000fe9c00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe9ddd000-0x00000fe9e00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fe9fdd000-0x00000fea000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fea1dd000-0x00000fea200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fea3dd000-0x00000fea400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fea5dd000-0x00000fea600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fea7dd000-0x00000fea800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fea9dd000-0x00000feaa00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feabdd000-0x00000feac00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feaddd000-0x00000feae00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feafdd000-0x00000feb000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feb1dd000-0x00000feb200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feb3dd000-0x00000feb400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feb5dd000-0x00000feb600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feb7dd000-0x00000feb800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feb9dd000-0x00000feba00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000febbdd000-0x00000febc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000febddd000-0x00000febe00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000febfdd000-0x00000fec000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fec1dd000-0x00000fec200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fec3dd000-0x00000fec400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fec5dd000-0x00000fec600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fec7dd000-0x00000fec800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fec9dd000-0x00000feca00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fecbdd000-0x00000fecc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fecddd000-0x00000fece00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fecfdd000-0x00000fed000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fed1dd000-0x00000fed200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fed3dd000-0x00000fed400000] free_bootmem+0x2b/0x30
[    0.000000] memblock: reserved array is doubled to 512 at [0x102febc080-0x102febf07f]
[    0.000000]    memblock_free: [0x0000102febf080-0x0000102fec0880] memblock_double_array+0x1b0/0x1e2
[    0.000000] memblock_reserve: [0x0000102febc080-0x0000102febf080] memblock_double_array+0x1c5/0x1e2
[    0.000000]    memblock_free: [0x00000fed5dd000-0x00000fed600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fed7dd000-0x00000fed800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fed9dd000-0x00000feda00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fedbdd000-0x00000fedc00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fedddd000-0x00000fede00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fedfdd000-0x00000fee000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fee1dd000-0x00000fee200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fee3dd000-0x00000fee400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fee5dd000-0x00000fee600000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fee7dd000-0x00000fee800000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fee9dd000-0x00000feea00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feebdd000-0x00000feec00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feeddd000-0x00000feee00000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000feefdd000-0x00000fef000000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fef1dd000-0x00000fef200000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fef3dd000-0x00000fef400000] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x00000fef5dd000-0x00000fef600000] free_bootmem+0x2b/0x30
[    0.000000] PERCPU: Embedded 477 pages/cpu @ffff880fcfa00000 s1930264 r0 d23528 u2097152
[    0.000000] memblock_reserve: [0x0000102fec0840-0x0000102fec0848] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec0800-0x0000102fec0808] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec0400-0x0000102fec07f8] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102febfc00-0x0000102fec03f0] __alloc_memory_core_early+0x5c/0x73
[    0.000000] pcpu-alloc: s1930264 r0 d23528 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 000 [0] 001 [0] 002 [0] 003 
[    0.000000] pcpu-alloc: [0] 004 [0] 005 [0] 006 [0] 007 
[    0.000000] pcpu-alloc: [0] 008 [0] 009 [0] 010 [0] 011 
[    0.000000] pcpu-alloc: [0] 012 [0] 013 [0] 014 [0] 015 
[    0.000000] pcpu-alloc: [0] 016 [0] 017 [0] 018 [0] 019 
[    0.000000] pcpu-alloc: [0] 020 [0] 021 [0] 022 [0] 023 
[    0.000000] pcpu-alloc: [0] 024 [0] 025 [0] 026 [0] 027 
[    0.000000] pcpu-alloc: [0] 028 [0] 029 [0] 030 [0] 031 
[    0.000000] pcpu-alloc: [0] 032 [0] 033 [0] 034 [0] 035 
[    0.000000] pcpu-alloc: [0] 036 [0] 037 [0] 038 [0] 039 
[    0.000000] pcpu-alloc: [0] 040 [0] 041 [0] 042 [0] 043 
[    0.000000] pcpu-alloc: [0] 044 [0] 045 [0] 046 [0] 047 
[    0.000000] pcpu-alloc: [0] 048 [0] 049 [0] 050 [0] 051 
[    0.000000] pcpu-alloc: [0] 052 [0] 053 [0] 054 [0] 055 
[    0.000000] pcpu-alloc: [0] 056 [0] 057 [0] 058 [0] 059 
[    0.000000] pcpu-alloc: [0] 060 [0] 061 [0] 062 [0] 063 
[    0.000000] pcpu-alloc: [0] 064 [0] 065 [0] 066 [0] 067 
[    0.000000] pcpu-alloc: [0] 068 [0] 069 [0] 070 [0] 071 
[    0.000000] pcpu-alloc: [0] 072 [0] 073 [0] 074 [0] 075 
[    0.000000] pcpu-alloc: [0] 076 [0] 077 [0] 078 [0] 079 
[    0.000000] pcpu-alloc: [0] 080 [0] 081 [0] 082 [0] 083 
[    0.000000] pcpu-alloc: [0] 084 [0] 085 [0] 086 [0] 087 
[    0.000000] pcpu-alloc: [0] 088 [0] 089 [0] 090 [0] 091 
[    0.000000] pcpu-alloc: [0] 092 [0] 093 [0] 094 [0] 095 
[    0.000000] pcpu-alloc: [0] 096 [0] 097 [0] 098 [0] 099 
[    0.000000] pcpu-alloc: [0] 100 [0] 101 [0] 102 [0] 103 
[    0.000000] pcpu-alloc: [0] 104 [0] 105 [0] 106 [0] 107 
[    0.000000] pcpu-alloc: [0] 108 [0] 109 [0] 110 [0] 111 
[    0.000000] pcpu-alloc: [0] 112 [0] 113 [0] 114 [0] 115 
[    0.000000] pcpu-alloc: [0] 116 [0] 117 [0] 118 [0] 119 
[    0.000000] pcpu-alloc: [0] 120 [0] 121 [0] 122 [0] 123 
[    0.000000] pcpu-alloc: [0] 124 [0] 125 [0] 126 [0] 127 
[    0.000000] pcpu-alloc: [0] 128 [0] 129 [0] 130 [0] 131 
[    0.000000] pcpu-alloc: [0] 132 [0] 133 [0] 134 [0] 135 
[    0.000000] pcpu-alloc: [0] 136 [0] 137 [0] 138 [0] 139 
[    0.000000] pcpu-alloc: [0] 140 [0] 141 [0] 142 [0] 143 
[    0.000000] pcpu-alloc: [0] 144 [0] 145 [0] 146 [0] 147 
[    0.000000] pcpu-alloc: [0] 148 [0] 149 [0] 150 [0] 151 
[    0.000000] pcpu-alloc: [0] 152 [0] 153 [0] 154 [0] 155 
[    0.000000] pcpu-alloc: [0] 156 [0] 157 [0] 158 [0] 159 
[    0.000000] pcpu-alloc: [0] 160 [0] 161 [0] 162 [0] 163 
[    0.000000] pcpu-alloc: [0] 164 [0] 165 [0] 166 [0] 167 
[    0.000000] pcpu-alloc: [0] 168 [0] 169 [0] 170 [0] 171 
[    0.000000] pcpu-alloc: [0] 172 [0] 173 [0] 174 [0] 175 
[    0.000000] pcpu-alloc: [0] 176 [0] 177 [0] 178 [0] 179 
[    0.000000] pcpu-alloc: [0] 180 [0] 181 [0] 182 [0] 183 
[    0.000000] pcpu-alloc: [0] 184 [0] 185 [0] 186 [0] 187 
[    0.000000] pcpu-alloc: [0] 188 [0] 189 [0] 190 [0] 191 
[    0.000000] pcpu-alloc: [0] 192 [0] 193 [0] 194 [0] 195 
[    0.000000] pcpu-alloc: [0] 196 [0] 197 [0] 198 [0] 199 
[    0.000000] pcpu-alloc: [0] 200 [0] 201 [0] 202 [0] 203 
[    0.000000] pcpu-alloc: [0] 204 [0] 205 [0] 206 [0] 207 
[    0.000000] pcpu-alloc: [0] 208 [0] 209 [0] 210 [0] 211 
[    0.000000] pcpu-alloc: [0] 212 [0] 213 [0] 214 [0] 215 
[    0.000000] pcpu-alloc: [0] 216 [0] 217 [0] 218 [0] 219 
[    0.000000] pcpu-alloc: [0] 220 [0] 221 [0] 222 [0] 223 
[    0.000000] pcpu-alloc: [0] 224 [0] 225 [0] 226 [0] 227 
[    0.000000] pcpu-alloc: [0] 228 [0] 229 [0] 230 [0] 231 
[    0.000000] pcpu-alloc: [0] 232 [0] 233 [0] 234 [0] 235 
[    0.000000] pcpu-alloc: [0] 236 [0] 237 [0] 238 [0] 239 
[    0.000000] pcpu-alloc: [0] 240 [0] 241 [0] 242 [0] 243 
[    0.000000] pcpu-alloc: [0] 244 [0] 245 [0] 246 [0] 247 
[    0.000000] pcpu-alloc: [0] 248 [0] 249 [0] 250 [0] 251 
[    0.000000] pcpu-alloc: [0] 252 [0] 253 
[    0.000000] memblock_reserve: [0x0000102febfa80-0x0000102febfbd0] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102febfa00-0x0000102febfa80] __alloc_memory_core_early+0x5c/0x73
[    0.000000]    memblock_free: [0x0000102fec1880-0x0000102fec2880] free_bootmem+0x2b/0x30
[    0.000000]    memblock_free: [0x0000102fec0880-0x0000102fec1880] free_bootmem+0x2b/0x30
[    0.000000] memblock_reserve: [0x0000102fec2680-0x0000102fec2880] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2480-0x0000102fec2680] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2280-0x0000102fec2480] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec2080-0x0000102fec2280] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fec1e80-0x0000102fec2080] __alloc_memory_core_early+0x5c/0x73
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 16511881
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: noapic noacpi pci=conf1 reboot=k panic=1 i8042.direct=1 i8042.dumbkbd=1 i8042.nopnp=1 console=ttyS0 earlyprintk=serial i8042.noaux=1 sched_debug slub_debug=FZPU init=/virt/init numa=off memblock=debug debug ignore_loglevel root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L rootfstype=9p init=/virt/init
[    0.000000] memblock_reserve: [0x0000102feb4080-0x0000102febc080] __alloc_memory_core_early+0x5c/0x73
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] memblock_reserve: [0x000000c3e3e000-0x000000c7e3e000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fe94000-0x0000102feb4000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x0000102fe54000-0x0000102fe94000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] memblock_reserve: [0x000000cfff8000-0x000000d0000000] __alloc_memory_core_early+0x5c/0x73
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000]    memblock_free: [0x0000102febc080-0x0000102febf080] memblock_free_reserved_regions+0x37/0x39
[    0.000000] BUG: unable to handle kernel paging request at ffff88102febd948
[    0.000000] IP: [<ffffffff836a5774>] __next_free_mem_range+0x9b/0x155
[    0.000000] PGD 4826063 PUD cf67a067 PMD cf7fa067 PTE 800000102febd160
[    0.000000] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[    0.000000] CPU 0 
[    0.000000] Pid: 0, comm: swapper Not tainted 3.5.0-rc2-next-20120614-sasha #447  
[    0.000000] RIP: 0010:[<ffffffff836a5774>]  [<ffffffff836a5774>] __next_free_mem_range+0x9b/0x155
[    0.000000] RSP: 0000:ffffffff84801db8  EFLAGS: 00010006
[    0.000000] RAX: 0000000000000109 RBX: 000000000000011a RCX: 0000000000000000
[    0.000000] RDX: 0000000000000109 RSI: 0000000000000400 RDI: ffffffff84801e60
[    0.000000] RBP: ffffffff84801e18 R08: ffff88102febd958 R09: 0000000100000000
[    0.000000] R10: 0000001030000000 R11: 0000000000000119 R12: ffff88102febc080
[    0.000000] R13: ffffffff84e215d0 R14: 0000000000000000 R15: 0000000000000002
[    0.000000] FS:  0000000000000000(0000) GS:ffff880fcfa00000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.000000] CR2: ffff88102febd948 CR3: 0000000004825000 CR4: 00000000000006b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[    0.000000] Process swapper (pid: 0, threadinfo ffffffff84800000, task ffffffff8482d400)
[    0.000000] Stack:
[    0.000000]  0000000000000000 ffffffff84801e68 ffffffff84801e70 ffffffff84801e60
[    0.000000]  ffffffff84e215a0 0000000000000003 0000010900000002 0000000000f9122a
[    0.000000]  ffffffff84801e60 ffffffff84801e70 ffffffff84801e68 ffffea0000000000
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff850eea74>] free_low_memory_core_early+0x1e4/0x206
[    0.000000]  [<ffffffff850e0adf>] numa_free_all_bootmem+0x82/0x8e
[    0.000000]  [<ffffffff836b2b92>] ? bad_to_user+0x149c/0x149c
[    0.000000]  [<ffffffff850def88>] mem_init+0x1e/0xec
[    0.000000]  [<ffffffff850c6eb9>] start_kernel+0x209/0x3e9
[    0.000000]  [<ffffffff850c6ade>] ? kernel_init+0x28a/0x28a
[    0.000000]  [<ffffffff850c6324>] x86_64_start_reservations+0xff/0x104
[    0.000000]  [<ffffffff850c647e>] x86_64_start_kernel+0x155/0x164
[    0.000000] Code: 55 08 81 fe 00 04 00 00 0f 84 9a 00 00 00 41 3b 75 10 0f 85 9c 00 00 00 e9 8b 00 00 00 4c 6b c0 18 31 c9 4f 8d 04 04 85 d2 74 08 <49> 8b 48 f0 49 03 48 e8 48 83 cf ff 4c 39 d8 73 03 49 8b 38 4c 
[    0.000000] RIP  [<ffffffff836a5774>] __next_free_mem_range+0x9b/0x155
[    0.000000]  RSP <ffffffff84801db8>
[    0.000000] CR2: ffff88102febd948
[    0.000000] ---[ end trace a7919e7f17c0a725 ]---
[    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
