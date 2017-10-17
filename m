Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 522F26B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 11:56:16 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y15so2025566ita.22
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:56:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k191sor5796368ita.88.2017.10.17.08.56.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Oct 2017 08:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGHG8Fcnzck+_uOW7rQHBKM4bkC+b2KGBzDPKmMyqp5LQ5t+qQ@mail.gmail.com>
References: <CAGHG8Fcnzck+_uOW7rQHBKM4bkC+b2KGBzDPKmMyqp5LQ5t+qQ@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 17 Oct 2017 17:55:54 +0200
Message-ID: <CACT4Y+Yx+e+cKiQ7dvXAC-=TeFHGdZGsqE6grgiZEY-sC_e4+w@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in do_get_mempolicy
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chase Bertke <ceb2817@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Oct 17, 2017 at 5:38 PM, Chase Bertke <ceb2817@gmail.com> wrote:
> Hello,
>
> I would like to report a bug found via syzkaller on version 4.13.0-rc4. I
> have searched the syzkaller mailing list and did not see any other reports
> for this bug.
>
> Please see below:
>
> ==================================================================
> BUG: KASAN: use-after-free in do_get_mempolicy+0x1d4/0x740
> Read of size 8 at addr ffff88006d32fb28 by task syz-executor0/1422
>
> CPU: 0 PID: 1422 Comm: syz-executor0 Not tainted 4.13.0-rc4+ #0
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> Call Trace:
>  dump_stack+0x83/0xb7
>  print_address_description+0x6b/0x280
>  kasan_report+0x260/0x340
>  __asan_load8+0x54/0x90
>  do_get_mempolicy+0x1d4/0x740
>  SyS_get_mempolicy+0xcf/0x180
>  entry_SYSCALL_64_fastpath+0x1a/0xa5
> RIP: 0033:0x4512e9
> RSP: 002b:00007f17246b4c08 EFLAGS: 00000216 ORIG_RAX: 00000000000000ef
> RAX: ffffffffffffffda RBX: 0000000000000012 RCX: 00000000004512e9
> RDX: 0000000049ee0985 RSI: 0000000020006ff8 RDI: 0000000020002ffc
> RBP: 0000000000ebaca0 R08: 0000000000000003 R09: 0000000000000000
> R10: 0000000020004000 R11: 0000000000000216 R12: 0000000000000012
> R13: 0000000000000001 R14: 00000000006f1340 R15: 0000000000000002
>
> Allocated by task 1421:
>  save_stack_trace+0x16/0x20
>  save_stack+0x46/0xd0
>  kasan_kmalloc+0xad/0xe0
>  kasan_slab_alloc+0x12/0x20
>  kmem_cache_alloc+0xa8/0x170
>  __mpol_dup+0x78/0x1e0
>  do_mbind+0x591/0x7d0
>  SyS_mbind+0x13d/0x150
>  entry_SYSCALL_64_fastpath+0x1a/0xa5
>
> Freed by task 1421:
>  save_stack_trace+0x16/0x20
>  save_stack+0x46/0xd0
>  kasan_slab_free+0x70/0xc0
>  kmem_cache_free+0x69/0x1a0
>  __mpol_put+0x33/0x40
>  do_mbind+0x639/0x7d0
>  SyS_mbind+0x13d/0x150
>  entry_SYSCALL_64_fastpath+0x1a/0xa5
>
> The buggy address belongs to the object at ffff88006d32fb18
>  which belongs to the cache numa_policy of size 24
> The buggy address is located 16 bytes inside of
>  24-byte region [ffff88006d32fb18, ffff88006d32fb30)
> The buggy address belongs to the page:
> page:ffffea0001b4cbc0 count:1 mapcount:0 mapping:          (null)
> index:0xffff88006d32f1e0
> flags: 0x500000000000100(slab)
> raw: 0500000000000100 0000000000000000 ffff88006d32f1e0 000000018066005a
> raw: dead000000000100 dead000000000200 ffff88003e80ea00 0000000000000000
> page dumped because: kasan: bad access detected
>
> Memory state around the buggy address:
>  ffff88006d32fa00: 00 00 00 fc fc fb fb fb fc fc fb fb fb fc fc 00
>  ffff88006d32fa80: 00 00 fc fc 00 00 00 fc fc 00 00 00 fc fc fb fb
>>ffff88006d32fb00: fb fc fc fb fb fb fc fc fb fb fb fc fc fb fb fb
>                                   ^
>  ffff88006d32fb80: fc fc fb fb fb fc fc fb fb fb fc fc fb fb fb fc
>  ffff88006d32fc00: fc fb fb fb fc fc fb fb fb fc fc fb fb fb fc fc
> ==================================================================
>
> Report and log attached.
>
> Thank you,
> Chase

+mm mailing list and maintainers

Chase, you can find some info on how to find right kernel maintainers here:
https://github.com/google/syzkaller/blob/master/docs/linux_kernel_reporting_bugs.md

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
