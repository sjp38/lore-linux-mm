Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f54.google.com (mail-qe0-f54.google.com [209.85.128.54])
	by kanga.kvack.org (Postfix) with ESMTP id C97F26B0031
	for <linux-mm@kvack.org>; Tue, 24 Dec 2013 10:21:11 -0500 (EST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so6576047qeb.13
        for <linux-mm@kvack.org>; Tue, 24 Dec 2013 07:21:11 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b6si7965945qca.27.2013.12.24.07.21.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Dec 2013 07:21:10 -0800 (PST)
Message-ID: <52B9A65D.8060300@oracle.com>
Date: Tue, 24 Dec 2013 10:21:01 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/thp: fix vmas tear down race with thp splitting
References: <1387850059-18525-1-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1387850059-18525-1-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/23/2013 08:54 PM, Wanpeng Li wrote:
> Sasha reports unmap_page_range tears down pmd range which is race with thp
> splitting during page reclaim. Transparent huge page will be splitting
> during page reclaim. However, split pmd lock which held by __split_trans_huge_lock
> can't prevent __split_huge_page_refcount running in parallel. This patch fix
> it by hold compound lock to check if __split_huge_page_refcount is running
> underneath, in that case zap huge pmd range should be fallback.
>
> [  265.474585] kernel BUG at mm/huge_memory.c:1440!
> [  265.475129] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  265.476684] Dumping ftrace buffer:
> [  265.477144]    (ftrace buffer empty)
> [  265.478398] Modules linked in:
> [  265.478807] CPU: 8 PID: 11344 Comm: trinity-c206 Tainted: G        W    3.13.0-rc5-next-20131223-sasha-00015-gec22156-dirty #8
> [  265.480172] task: ffff8801cb573000 ti: ffff8801cbd3a000 task.ti: ffff8801cbd3a000
> [  265.480172] RIP: 0010:[<ffffffff812c7f70>]  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
> [  265.480172] RSP: 0000:ffff8801cbd3bc78  EFLAGS: 00010246
> [  265.480172] RAX: 015fffff80090018 RBX: ffff8801cbd3bde8 RCX: ffffffffffffff9c
> [  265.480172] RDX: ffffffffffffffff RSI: 0000000000000008 RDI: ffff8800bffd2000
> [  265.480172] RBP: ffff8801cbd3bcb8 R08: 0000000000000000 R09: 0000000000000000
> [  265.480172] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0002856740
> [  265.480172] R13: ffffea0002d50000 R14: 00007ff915000000 R15: 00007ff930e48fff
> [  265.480172] FS:  00007ff934899700(0000) GS:ffff88014d400000(0000) knlGS:0000000000000000
> [  265.480172] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  265.480172] CR2: 00007ff93428a000 CR3: 000000010babe000 CR4: 00000000000006e0
> [  265.480172] Stack:
> [  265.480172]  00000000000004dd ffff8801ccbfbb60 ffff8801cbd3bcb8 ffff8801cbb15540
> [  265.480172]  00007ff915000000 00007ff930e49000 ffff8801cbd3bde8 00007ff930e48fff
> [  265.480172]  ffff8801cbd3bd48 ffffffff812885b6 ffff88005f5d20c0 00007ff915200000
> [  265.480172] Call Trace:
> [  265.480172]  [<ffffffff812885b6>] unmap_page_range+0x2c6/0x410
> [  265.480172]  [<ffffffff81288801>] unmap_single_vma+0x101/0x120
> [  265.480172]  [<ffffffff81288881>] unmap_vmas+0x61/0xa0
> [  265.480172]  [<ffffffff8128f730>] exit_mmap+0xd0/0x170
> [  265.480172]  [<ffffffff81138860>] mmput+0x70/0xe0
> [  265.480172]  [<ffffffff8113c89d>] exit_mm+0x18d/0x1a0
> [  265.480172]  [<ffffffff811ea355>] ? acct_collect+0x175/0x1b0
> [  265.480172]  [<ffffffff8113ed0f>] do_exit+0x26f/0x520
> [  265.480172]  [<ffffffff8113f069>] do_group_exit+0xa9/0xe0
> [  265.480172]  [<ffffffff8113f0b7>] SyS_exit_group+0x17/0x20
> [  265.480172]  [<ffffffff845f10d0>] tracesys+0xdd/0xe2
> [  265.480172] Code: 0f 0b 66 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f
> 44 00 00 48 8b 03 f0 48 81 80 50 03 00 00 00 fe ff ff 49 8b 45 00 f6
> c4 40 75 10 <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 8b 03
> f0 48
> [  265.480172] RIP  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
> [  265.480172]  RSP <ffff8801cbd3bc78>
>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---

Ran a round of testing overnight. While the BUG seems to be gone I'm now getting:

[  879.815434] BUG: Bad page state in process trinity-c115  pfn:29a00
[  879.816430] page:ffffea0000a68000 count:0 mapcount:0 mapping:          (null) index:
0x7f2f20000
[  879.817654] page flags: 0x5fffff81084008(uptodate|head|swapbacked|compound_lock)
[  879.818848] Modules linked in:
[  879.819340] CPU: 1 PID: 18824 Comm: trinity-c115 Tainted: G        W    3.13.0-rc5-n
ext-20131223-sasha-00016-g3010ae9-dirty #13
[  879.821142]  ffffea0000a68000 ffff880188345a58 ffffffff845e014c 0000000000000009
[  879.822492]  ffffea0000a68000 ffff880188345a78 ffffffff8125c301 ffff880188345a78
[  879.823858]  0000000000000200 ffff880188345ac8 ffffffff8125cd83 ffff880100000000
[  879.825128] Call Trace:
[  879.825568]  [<ffffffff845e014c>] dump_stack+0x52/0x7f
[  879.826425]  [<ffffffff8125c301>] bad_page+0xf1/0x120
[  879.827296]  [<ffffffff8125cd83>] free_pages_prepare+0x133/0x1f0
[  879.828276]  [<ffffffff8125f254>] __free_pages_ok+0x24/0x150
[  879.829267]  [<ffffffff8125f39b>] free_compound_page+0x1b/0x20
[  879.830547]  [<ffffffff81267ebc>] __put_compound_page+0x1c/0x30
[  879.831360]  [<ffffffff81267f60>] put_compound_page+0x60/0x2e0
[  879.832284]  [<ffffffff8126824b>] release_pages+0x6b/0x230
[  879.833230]  [<ffffffff8129ef46>] free_pages_and_swap_cache+0xa6/0xd0
[  879.834297]  [<ffffffff81285dff>] tlb_flush_mmu+0x6f/0x90
[  879.835146]  [<ffffffff812c8078>] zap_huge_pmd+0x308/0x410
[  879.836097]  [<ffffffff81288526>] unmap_page_range+0x2c6/0x410
[  879.837034]  [<ffffffff81288771>] unmap_single_vma+0x101/0x120
[  879.838027]  [<ffffffff812887f1>] unmap_vmas+0x61/0xa0
[  879.838892]  [<ffffffff8128f6a0>] exit_mmap+0xd0/0x170
[  879.839794]  [<ffffffff81138860>] mmput+0x70/0xe0
[  879.841079]  [<ffffffff8113c89d>] exit_mm+0x18d/0x1a0
[  879.841565]  [<ffffffff811ea355>] ? acct_collect+0x175/0x1b0
[  879.842411]  [<ffffffff8113ed0f>] do_exit+0x26f/0x520
[  879.843169]  [<ffffffff8113f069>] do_group_exit+0xa9/0xe0
[  879.844033]  [<ffffffff8113f0b7>] SyS_exit_group+0x17/0x20
[  879.844967]  [<ffffffff845f1290>] tracesys+0xdd/0xe2


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
