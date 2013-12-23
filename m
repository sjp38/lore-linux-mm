Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2329A6B0031
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 15:19:27 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so2523097ead.20
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 12:19:26 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id p9si21776464eew.160.2013.12.23.12.19.26
        for <linux-mm@kvack.org>;
        Mon, 23 Dec 2013 12:19:26 -0800 (PST)
Date: Mon, 23 Dec 2013 22:02:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1440!
Message-ID: <20131223200255.GA18521@node.dhcp.inet.fi>
References: <52B88F6E.8070909@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B88F6E.8070909@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, Dec 23, 2013 at 02:30:54PM -0500, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next
> kernel, I've stumbled on the following spew.
> 
> 	page = pmd_page(orig_pmd);
> 	page_remove_rmap(page);
> 	VM_BUG_ON(page_mapcount(page) < 0);
> 	add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> 	VM_BUG_ON(!PageHead(page));		<=== HERE
> 	atomic_long_dec(&tlb->mm->nr_ptes);
> 	spin_unlock(ptl);
> 	tlb_remove_page(tlb, page);
> 
> [  265.474585] kernel BUG at mm/huge_memory.c:1440!

Could you dump_page() on the bug?

> [  265.475129] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  265.476684] Dumping ftrace buffer:
> [  265.477144]    (ftrace buffer empty)
> [  265.478398] Modules linked in:
> [  265.478807] CPU: 8 PID: 11344 Comm: trinity-c206 Tainted: G        W    3.13.0-rc5-ne
> xt-20131223-sasha-00015-gec22156-dirty #8
> [  265.480172] task: ffff8801cb573000 ti: ffff8801cbd3a000 task.ti: ffff8801cbd3a000
> [  265.480172] RIP: 0010:[<ffffffff812c7f70>]  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0
> x1f0
> [  265.480172] RSP: 0000:ffff8801cbd3bc78  EFLAGS: 00010246
> [  265.480172] RAX: 015fffff80090018 RBX: ffff8801cbd3bde8 RCX: ffffffffffffff9c
> [  265.480172] RDX: ffffffffffffffff RSI: 0000000000000008 RDI: ffff8800bffd2000
> [  265.480172] RBP: ffff8801cbd3bcb8 R08: 0000000000000000 R09: 0000000000000000
> [  265.480172] R10: 0000000000000001 R11: 0000000000000000 R12: ffffea0002856740
> [  265.480172] R13: ffffea0002d50000 R14: 00007ff915000000 R15: 00007ff930e48fff
> [  265.480172] FS:  00007ff934899700(0000) GS:ffff88014d400000(0000) knlGS:0000000000000
> 000
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
> [  265.480172] Code: 0f 0b 66 0f 1f 84 00 00 00 00 00 eb fe 66 0f 1f 44 00
> 00 48 8b 03 f0 48 81 80 50 03 00 00 00 fe ff ff 49 8b 45 00 f6 c4 40 75 10
> <0f> 0b 66 0f 1f 44 00 00 eb fe 66 0f 1f 44 00 00 48 8b 03 f0 48
> [  265.480172] RIP  [<ffffffff812c7f70>] zap_huge_pmd+0x170/0x1f0
> [  265.480172]  RSP <ffff8801cbd3bc78>
> 
> 
> Thanks,
> Sasha
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
