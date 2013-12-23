Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 424E36B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 12:24:14 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id x10so5320017pdj.19
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 09:24:13 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id im7si13182503pbd.11.2013.12.23.09.24.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 09:24:13 -0800 (PST)
Message-ID: <52B871B2.7040409@oracle.com>
Date: Mon, 23 Dec 2013 12:24:02 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
References: <52B1C143.8080301@oracle.com>
In-Reply-To: <52B1C143.8080301@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Ping?

I've also Cc'ed the "this page shouldn't be locked at all" team.

On 12/18/2013 10:37 AM, Sasha Levin wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel, I've stumbled on
> the following spew.
>
> The code is in zap_pte_range():
>
>                  if (!non_swap_entry(entry))
>                          rss[MM_SWAPENTS]--;
>                  else if (is_migration_entry(entry)) {
>                          struct page *page;
>
>                          page = migration_entry_to_page(entry);    <==== HERE
>
>                          if (PageAnon(page))
>                                  rss[MM_ANONPAGES]--;
>                          else
>                                  rss[MM_FILEPAGES]--;
>
>
> [ 2622.589064] kernel BUG at include/linux/swapops.h:131!
> [ 2622.589064] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [ 2622.589064] Dumping ftrace buffer:
> [ 2622.589064]    (ftrace buffer empty)
> [ 2622.589064] Modules linked in:
> [ 2622.589064] CPU: 9 PID: 15984 Comm: trinity-child16 Tainted: G        W    3.13.0-rc
> 4-next-20131217-sasha-00013-ga878504-dirty #4150
> [ 2622.589064] task: ffff88168346b000 ti: ffff8816561d8000 task.ti: ffff8816561d8000
> [ 2622.589064] RIP: 0010:[<ffffffff8127c730>]  [<ffffffff8127c730>] zap_pte_range+0x360
> /0x4a0
> [ 2622.589064] RSP: 0018:ffff8816561d9c18  EFLAGS: 00010246
> [ 2622.589064] RAX: ffffea00736a6600 RBX: ffff88200299d068 RCX: 0000000000000009
> [ 2622.589064] RDX: 022fffff80380000 RSI: ffffea0000000000 RDI: 3c00000001cda998
> [ 2622.589064] RBP: ffff8816561d9cb8 R08: 0000000000000000 R09: 0000000000000000
> [ 2622.589064] R10: 0000000000000001 R11: 0000000000000000 R12: 00007fc7ee20d000
> [ 2622.589064] R13: ffff8816561d9de8 R14: 000000039b53303c R15: 00007fc7ee29b000
> [ 2622.589064] FS:  00007fc7eeceb700(0000) GS:ffff882011a00000(0000) knlGS:000000000000
> 0000
> [ 2622.589064] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [ 2622.589064] CR2: 000000000068c000 CR3: 0000000005c26000 CR4: 00000000000006e0
> [ 2622.589064] Stack:
> [ 2622.589064]  ffff8816561d9c58 0000000000000286 ffff88168327b060 ffff88168327b060
> [ 2622.589064]  00007fc700000160 ffff881667067b88 00000000c8f4b120 00ff88168327b060
> [ 2622.589064]  ffff88168327b060 ffff8820051a8600 0000000000000000 ffff88168327b000
> [ 2622.589064] Call Trace:
> [ 2622.589064]  [<ffffffff8127cc5e>] unmap_page_range+0x3ee/0x400
> [ 2622.589064]  [<ffffffff8127cd71>] unmap_single_vma+0x101/0x120
> [ 2622.589064]  [<ffffffff8127cdf1>] unmap_vmas+0x61/0xa0
> [ 2622.589064]  [<ffffffff81283980>] exit_mmap+0xd0/0x170
> [ 2622.589064]  [<ffffffff8112d430>] mmput+0x70/0xe0
> [ 2622.589064]  [<ffffffff8113144d>] exit_mm+0x18d/0x1a0
> [ 2622.589064]  [<ffffffff811defb5>] ? acct_collect+0x175/0x1b0
> [ 2622.589064]  [<ffffffff8113389f>] do_exit+0x24f/0x500
> [ 2622.589064]  [<ffffffff81133bf9>] do_group_exit+0xa9/0xe0
> [ 2622.589064]  [<ffffffff81133c47>] SyS_exit_group+0x17/0x20
> [ 2622.589064]  [<ffffffff843a6150>] tracesys+0xdd/0xe2
> [ 2622.589064] Code: 83 f8 1f 75 46 48 b8 ff ff ff ff ff ff ff 01 48 be 00 00 00 00 00 ea ff ff 48
> 21 f8 48 c1 e0 06 48 01 f0 48 8b 10 80 e2 01 75 0a <0f> 0b 66 0f 1f 44 00 00 eb fe f6 40 08 01 74 05
> ff 4d c4 eb 0b
> [ 2622.589064] RIP  [<ffffffff8127c730>] zap_pte_range+0x360/0x4a0
> [ 2622.589064]  RSP <ffff8816561d9c18>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
