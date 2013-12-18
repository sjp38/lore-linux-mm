Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id A59726B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:43:06 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so130118yha.26
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:43:06 -0800 (PST)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id v65si1178442yhp.233.2013.12.18.14.43.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 14:43:05 -0800 (PST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so285256pbb.17
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:43:04 -0800 (PST)
Date: Wed, 18 Dec 2013 14:42:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: mm: kernel BUG at mm/rmap.c:1663!
In-Reply-To: <52B206F4.2010706@oracle.com>
Message-ID: <alpine.LNX.2.00.1312181430050.1087@eggly.anvils>
References: <52B206F4.2010706@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 18 Dec 2013, Sasha Levin wrote:

> Hi all,
> 
> As a side note, I seem to be hitting various VM_BUG_ON(!PageLocked(page)) all
> over the code, is it
> possible that something major broke that's causing this fallout?
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next
> kernel, I've stumbled on the following spew.
> 
> [  588.698828] kernel BUG at mm/rmap.c:1663!
> [  588.699380] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
> [  588.700347] Dumping ftrace buffer:
> [  588.701186]    (ftrace buffer empty)
> [  588.702062] Modules linked in:
> [  588.702759] CPU: 0 PID: 4647 Comm: kswapd0 Tainted: G      D W
> 3.13.0-rc4-next-20
> 131218-sasha-00012-g1962367-dirty #4155
> [  588.704330] task: ffff880062bcb000 ti: ffff880062450000 task.ti:
> ffff880062450000
> [  588.705507] RIP: 0010:[<ffffffff81289c80>]  [<ffffffff81289c80>]
> rmap_walk+0x10/0x50
> [  588.706800] RSP: 0018:ffff8800624518d8  EFLAGS: 00010246
> [  588.707515] RAX: 000fffff80080048 RBX: ffffea00000227c0 RCX:
> 0000000000000000
> [  588.707515] RDX: 0000000000000000 RSI: ffff8800624518e8 RDI:
> ffffea00000227c0
> [  588.707515] RBP: ffff8800624518d8 R08: ffff8800624518e8 R09:
> 0000000000000000
> [  588.707515] R10: 0000000000000000 R11: 0000000000000000 R12:
> ffff8800624519d8
> [  588.707515] R13: 0000000000000000 R14: ffffea00000227e0 R15:
> 0000000000000000
> [  588.707515] FS:  0000000000000000(0000) GS:ffff880065200000(0000)
> knlGS:000000000000
> 0000
> [  588.707515] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  588.707515] CR2: 00007fec40cbe0f8 CR3: 00000000c2382000 CR4:
> 00000000000006f0
> [  588.707515] Stack:
> [  588.707515]  ffff880062451958 ffffffff81289f4b ffff880062451918
> ffffffff81289f80
> [  588.707515]  0000000000000000 0000000000000000 ffffffff8128af60
> 0000000000000000
> [  588.707515]  0000000000000024 0000000000000000 0000000000000000
> 0000000000000286
> [  588.707515] Call Trace:
> [  588.707515]  [<ffffffff81289f4b>] page_referenced+0xcb/0x100
> [  588.707515]  [<ffffffff81289f80>] ? page_referenced+0x100/0x100
> [  588.707515]  [<ffffffff8128af60>] ?
> invalid_page_referenced_vma+0x170/0x170
> [  588.707515]  [<ffffffff81264302>] shrink_active_list+0x212/0x330
> [  588.707515]  [<ffffffff81260e23>] ? inactive_file_is_low+0x33/0x50
> [  588.707515]  [<ffffffff812646f5>] shrink_lruvec+0x2d5/0x300
> [  588.707515]  [<ffffffff812647b6>] shrink_zone+0x96/0x1e0
> [  588.707515]  [<ffffffff81265b06>] kswapd_shrink_zone+0xf6/0x1c0
> [  588.707515]  [<ffffffff81265f43>] balance_pgdat+0x373/0x550
> [  588.707515]  [<ffffffff81266d63>] kswapd+0x2f3/0x350
> [  588.707515]  [<ffffffff81266a70>] ?
> perf_trace_mm_vmscan_lru_isolate_template+0x120/
> 0x120
> [  588.707515]  [<ffffffff8115c9c5>] kthread+0x105/0x110
> [  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
> [  588.707515]  [<ffffffff843a6a7c>] ret_from_fork+0x7c/0xb0
> [  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
> [  588.707515] Code: c0 48 83 c4 18 89 d0 5b 41 5c 41 5d 41 5e 41 5f c9 c3 66
> 0f 1f 84
> 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 48 8b 07 a8 01 75 10 <0f> 0b 66 0f
> 1f 44 00 0
> 0 eb fe 66 0f 1f 44 00 00 f6 47 08 01 74
> [  588.707515] RIP  [<ffffffff81289c80>] rmap_walk+0x10/0x50
> [  588.707515]  RSP <ffff8800624518d8>

Yes, I hit that on starting swap load on Monday's mmotm: sighed and
moved on.  I've not investigated: as you'll have noticed from other
unreplied (but not ignored) fallocate mail, I've not had much time
to spare.  Finger of probable but unsubstantiated blame points to
the rmap_walk patches, Joonsoo Cc'ed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
