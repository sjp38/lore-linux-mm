Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 312D46B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 00:31:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s12so24738971pgc.2
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 21:31:09 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id p2si32333406pgf.30.2017.06.05.21.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Jun 2017 21:31:08 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node counters
In-Reply-To: <20170605183511.GA8915@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org> <20170530181724.27197-3-hannes@cmpxchg.org> <20170531091256.GA5914@osiris> <20170531113900.GB5914@osiris> <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad> <87mv9s2f8f.fsf@concordia.ellerman.id.au> <20170605183511.GA8915@cmpxchg.org>
Date: Tue, 06 Jun 2017 14:31:01 +1000
Message-ID: <87k24prb3u.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yury Norov <ynorov@caviumnetworks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

Johannes Weiner <hannes@cmpxchg.org> writes:
> From 89ed86b5b538d8debd3c29567d7e1d31257fa577 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 5 Jun 2017 14:12:15 -0400
> Subject: [PATCH] mm: vmstat: move slab statistics from zone to node counters
>  fix
>
> Unable to handle kernel paging request at virtual address 2e116007
> pgd = c0004000
> [2e116007] *pgd=00000000
> Internal error: Oops: 5 [#1] SMP ARM
> Modules linked in:
> CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-00153-gb6bc6724488a #200
> Hardware name: Generic DRA74X (Flattened Device Tree)
> task: c0d0adc0 task.stack: c0d00000
> PC is at __mod_node_page_state+0x2c/0xc8
> LR is at __per_cpu_offset+0x0/0x8
> pc : [<c0271de8>]    lr : [<c0d07da4>]    psr: 600000d3
> sp : c0d01eec  ip : 00000000  fp : c15782f4
> r10: 00000000  r9 : c1591280  r8 : 00004000
> r7 : 00000001  r6 : 00000006  r5 : 2e116000  r4 : 00000007
> r3 : 00000007  r2 : 00000001  r1 : 00000006  r0 : c0dc27c0
> Flags: nZCv  IRQs off  FIQs off  Mode SVC_32  ISA ARM  Segment none
> Control: 10c5387d  Table: 8000406a  DAC: 00000051
> Process swapper (pid: 0, stack limit = 0xc0d00218)
> Stack: (0xc0d01eec to 0xc0d02000)
> 1ee0:                            600000d3 c0dc27c0 c0271efc 00000001 c0d58864
> 1f00: ef470000 00008000 00004000 c029fbb0 01000000 c1572b5c 00002000 00000000
> 1f20: 00000001 00000001 00008000 c029f584 00000000 c0d58864 00008000 00008000
> 1f40: 01008000 c0c23790 c15782f4 a00000d3 c0d58864 c02a0364 00000000 c0819388
> 1f60: c0d58864 000000c0 01000000 c1572a58 c0aa57a4 00000080 00002000 c0dca000
> 1f80: efffe980 c0c53a48 00000000 c0c23790 c1572a58 c0c59e48 c0c59de8 c1572b5c
> 1fa0: c0dca000 c0c257a4 00000000 ffffffff c0dca000 c0d07940 c0dca000 c0c00a9c
> 1fc0: ffffffff ffffffff 00000000 c0c00680 00000000 c0c53a48 c0dca214 c0d07958
> 1fe0: c0c53a44 c0d0caa4 8000406a 412fc0f2 00000000 8000807c 00000000 00000000
> [<c0271de8>] (__mod_node_page_state) from [<c0271efc>] (mod_node_page_state+0x2c/0x4c)
> [<c0271efc>] (mod_node_page_state) from [<c029fbb0>] (cache_alloc_refill+0x5b8/0x828)
> [<c029fbb0>] (cache_alloc_refill) from [<c02a0364>] (kmem_cache_alloc+0x24c/0x2d0)
> [<c02a0364>] (kmem_cache_alloc) from [<c0c23790>] (create_kmalloc_cache+0x20/0x8c)
> [<c0c23790>] (create_kmalloc_cache) from [<c0c257a4>] (kmem_cache_init+0xac/0x11c)
> [<c0c257a4>] (kmem_cache_init) from [<c0c00a9c>] (start_kernel+0x1b8/0x3c0)
> [<c0c00a9c>] (start_kernel) from [<8000807c>] (0x8000807c)
> Code: e79e5103 e28c3001 e0833001 e1a04003 (e19440d5)
> ---[ end trace 0000000000000000 ]---

Just to be clear that's not my call trace.

> The zone counters work earlier than the node counters because the
> zones have special boot pagesets, whereas the nodes do not.
>
> Add boot nodestats against which we account until the dynamic per-cpu
> allocator is available.

This isn't working for me. I applied it on top of next-20170605, I still
get an oops:

  $ qemu-system-ppc64 -M pseries -m 1G  -kernel build/vmlinux -vga none -nographic
  SLOF **********************************************************************
  QEMU Starting
  ...
  Linux version 4.12.0-rc3-gcc-5.4.1-next-20170605-dirty (michael@ka3.ozlabs.ibm.com) (gcc version 5.4.1 20170214 (Custom 2af61cd06c9fd8f5) ) #352 SMP Tue Jun 6 14:09:57 AEST 2017
  ...
  PID hash table entries: 4096 (order: -1, 32768 bytes)
  Memory: 1014592K/1048576K available (9920K kernel code, 1536K rwdata, 2608K rodata, 832K init, 1420K bss, 33984K reserved, 0K cma-reserved)
  Unable to handle kernel paging request for data at address 0x00000338
  Faulting instruction address: 0xc0000000002cf338
  Oops: Kernel access of bad area, sig: 11 [#1]
  SMP NR_CPUS=2048 
  NUMA 
  pSeries
  Modules linked in:
  CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-gcc-5.4.1-next-20170605-dirty #352
  task: c000000000d11080 task.stack: c000000000e24000
  NIP: c0000000002cf338 LR: c0000000002cf0dc CTR: 0000000000000000
  REGS: c000000000e279a0 TRAP: 0380   Not tainted  (4.12.0-rc3-gcc-5.4.1-next-20170605-dirty)
  MSR: 8000000002001033 <SF,VEC,ME,IR,DR,RI,LE>
    CR: 22482242  XER: 00000000
  CFAR: c0000000002cf6a0 SOFTE: 0 
  GPR00: c0000000002cf0dc c000000000e27c20 c000000000e28300 c00000003ffc6300 
  GPR04: c000000000e556f8 0000000000000000 000000003f120000 0000000000000000 
  GPR08: c000000000ed3058 0000000000000330 0000000000000000 ffffffffffffff80 
  GPR12: 0000000028402824 c00000000fd40000 0000000000000060 0000000000f540a8 
  GPR16: 0000000000f540d8 fffffffffffffffd 000000003dc54ee0 0000000000000014 
  GPR20: c000000000b90e60 c000000000b90e90 0000000000002000 0000000000000000 
  GPR24: 0000000000000401 0000000000000000 0000000000000001 c00000003e000000 
  GPR28: 0000000080010400 f0000000000f8000 0000000000000006 c000000000cb4270 
  NIP [c0000000002cf338] new_slab+0x338/0x770
  LR [c0000000002cf0dc] new_slab+0xdc/0x770
  Call Trace:
  [c000000000e27c20] [c0000000002cf0dc] new_slab+0xdc/0x770 (unreliable)
  [c000000000e27cf0] [c0000000002d6bb4] __kmem_cache_create+0x1a4/0x6a0
  [c000000000e27e00] [c000000000c73098] create_boot_cache+0x98/0xdc
  [c000000000e27e80] [c000000000c77608] kmem_cache_init+0x5c/0x160
  [c000000000e27f00] [c000000000c43ec8] start_kernel+0x290/0x51c
  [c000000000e27f90] [c00000000000b070] start_here_common+0x1c/0x4ac
  Instruction dump:
  419e0388 893d0007 3d02000b 3908ad58 79291f24 7c68482a 60000000 3d230001 
  e9299a42 39290066 79291f24 7d2a4a14 <eb890008> e93c0080 7fa34800 409e03b0 
  ---[ end trace 0000000000000000 ]---


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
