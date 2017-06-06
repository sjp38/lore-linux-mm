Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57EE86B02FD
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:15:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e8so160917726pfl.4
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:15:53 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id l8si9227054pln.84.2017.06.06.04.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Jun 2017 04:15:52 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node counters
In-Reply-To: <87k24prb3u.fsf@concordia.ellerman.id.au>
References: <20170530181724.27197-1-hannes@cmpxchg.org> <20170530181724.27197-3-hannes@cmpxchg.org> <20170531091256.GA5914@osiris> <20170531113900.GB5914@osiris> <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad> <87mv9s2f8f.fsf@concordia.ellerman.id.au> <20170605183511.GA8915@cmpxchg.org> <87k24prb3u.fsf@concordia.ellerman.id.au>
Date: Tue, 06 Jun 2017 21:15:48 +1000
Message-ID: <87mv9lpdsr.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yury Norov <ynorov@caviumnetworks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

Michael Ellerman <mpe@ellerman.id.au> writes:

> Johannes Weiner <hannes@cmpxchg.org> writes:
>> From 89ed86b5b538d8debd3c29567d7e1d31257fa577 Mon Sep 17 00:00:00 2001
>> From: Johannes Weiner <hannes@cmpxchg.org>
>> Date: Mon, 5 Jun 2017 14:12:15 -0400
>> Subject: [PATCH] mm: vmstat: move slab statistics from zone to node counters
>>  fix
>>
>> Unable to handle kernel paging request at virtual address 2e116007
>> pgd = c0004000
>> [2e116007] *pgd=00000000
>> Internal error: Oops: 5 [#1] SMP ARM
>> Modules linked in:
>> CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-00153-gb6bc6724488a #200
>> Hardware name: Generic DRA74X (Flattened Device Tree)
>> task: c0d0adc0 task.stack: c0d00000
>> PC is at __mod_node_page_state+0x2c/0xc8
>> LR is at __per_cpu_offset+0x0/0x8
>> pc : [<c0271de8>]    lr : [<c0d07da4>]    psr: 600000d3
>> sp : c0d01eec  ip : 00000000  fp : c15782f4
>> r10: 00000000  r9 : c1591280  r8 : 00004000
>> r7 : 00000001  r6 : 00000006  r5 : 2e116000  r4 : 00000007
>> r3 : 00000007  r2 : 00000001  r1 : 00000006  r0 : c0dc27c0
>> Flags: nZCv  IRQs off  FIQs off  Mode SVC_32  ISA ARM  Segment none
>> Control: 10c5387d  Table: 8000406a  DAC: 00000051
>> Process swapper (pid: 0, stack limit = 0xc0d00218)
>> Stack: (0xc0d01eec to 0xc0d02000)
>> 1ee0:                            600000d3 c0dc27c0 c0271efc 00000001 c0d58864
>> 1f00: ef470000 00008000 00004000 c029fbb0 01000000 c1572b5c 00002000 00000000
>> 1f20: 00000001 00000001 00008000 c029f584 00000000 c0d58864 00008000 00008000
>> 1f40: 01008000 c0c23790 c15782f4 a00000d3 c0d58864 c02a0364 00000000 c0819388
>> 1f60: c0d58864 000000c0 01000000 c1572a58 c0aa57a4 00000080 00002000 c0dca000
>> 1f80: efffe980 c0c53a48 00000000 c0c23790 c1572a58 c0c59e48 c0c59de8 c1572b5c
>> 1fa0: c0dca000 c0c257a4 00000000 ffffffff c0dca000 c0d07940 c0dca000 c0c00a9c
>> 1fc0: ffffffff ffffffff 00000000 c0c00680 00000000 c0c53a48 c0dca214 c0d07958
>> 1fe0: c0c53a44 c0d0caa4 8000406a 412fc0f2 00000000 8000807c 00000000 00000000
>> [<c0271de8>] (__mod_node_page_state) from [<c0271efc>] (mod_node_page_state+0x2c/0x4c)
>> [<c0271efc>] (mod_node_page_state) from [<c029fbb0>] (cache_alloc_refill+0x5b8/0x828)
>> [<c029fbb0>] (cache_alloc_refill) from [<c02a0364>] (kmem_cache_alloc+0x24c/0x2d0)
>> [<c02a0364>] (kmem_cache_alloc) from [<c0c23790>] (create_kmalloc_cache+0x20/0x8c)
>> [<c0c23790>] (create_kmalloc_cache) from [<c0c257a4>] (kmem_cache_init+0xac/0x11c)
>> [<c0c257a4>] (kmem_cache_init) from [<c0c00a9c>] (start_kernel+0x1b8/0x3c0)
>> [<c0c00a9c>] (start_kernel) from [<8000807c>] (0x8000807c)
>> Code: e79e5103 e28c3001 e0833001 e1a04003 (e19440d5)
>> ---[ end trace 0000000000000000 ]---
>
> Just to be clear that's not my call trace.
>
>> The zone counters work earlier than the node counters because the
>> zones have special boot pagesets, whereas the nodes do not.
>>
>> Add boot nodestats against which we account until the dynamic per-cpu
>> allocator is available.
>
> This isn't working for me. I applied it on top of next-20170605, I still
> get an oops:

But today's linux-next is OK. So I must have missed a fix when testing
this in isolation.

commit d94b69d9a3f8139e6d5f5d03c197d8004de3905a
Author:     Johannes Weiner <hannes@cmpxchg.org>
AuthorDate: Tue Jun 6 09:19:50 2017 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Tue Jun 6 09:19:50 2017 +1000

    mm: vmstat: move slab statistics from zone to node counters fix
    
    Unable to handle kernel paging request at virtual address 2e116007
    pgd = c0004000
    [2e116007] *pgd=00000000
    Internal error: Oops: 5 [#1] SMP ARM

...

Booted to userspace:

$ uname -a
Linux buildroot 4.12.0-rc4-gcc-5.4.1-00130-gd94b69d9a3f8 #354 SMP Tue Jun 6 20:44:42 AEST 2017 ppc64le GNU/Linux


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
