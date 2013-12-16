Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A5A576B0035
	for <linux-mm@kvack.org>; Sun, 15 Dec 2013 19:24:29 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so4631141pdj.11
        for <linux-mm@kvack.org>; Sun, 15 Dec 2013 16:24:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wm3si7368486pab.107.2013.12.15.16.24.27
        for <linux-mm@kvack.org>;
        Sun, 15 Dec 2013 16:24:28 -0800 (PST)
Date: Sun, 15 Dec 2013 16:26:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: kernel BUG at mm/mempolicy.c:1203!
Message-Id: <20131215162604.526d86ce.akpm@linux-foundation.org>
In-Reply-To: <52AE3D45.8000100@oracle.com>
References: <52AE3D45.8000100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, dan.carpenter@oracle.com, Dave Jones <davej@codemonkey.org.uk>

On Sun, 15 Dec 2013 18:37:41 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel, I've
> stumbled on the following spew.
> 
> This seems to be due to commit 0bf598d863e "mbind: add BUG_ON(!vma) in new_vma_page()"
> which added that BUG_ON.
> 
> [  538.836802] kernel BUG at mm/mempolicy.c:1203!
> [  538.838245] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  538.838507] Dumping ftrace buffer:
> [  538.840150]    (ftrace buffer empty)
> [  538.840150] Modules linked in:
> [  538.840256] CPU: 15 PID: 21136 Comm: trinity-child96 Tainted: G        W    3.13.0-rc
> 3-next-20131213-sasha-00010-g6749b49-dirty #4104
> [  538.840256] task: ffff880e73288000 ti: ffff880e73290000 task.ti: ffff880e73290000
> [  538.840256] RIP: 0010:[<ffffffff812a4092>]  [<ffffffff812a4092>] new_vma_page+0x52/0x
> b0
> [  538.840256] RSP: 0000:ffff880e73291d38  EFLAGS: 00010246
> [  538.840256] RAX: fffffffffffffff2 RBX: 0000000000000000 RCX: 0000000000000000
> [  538.840256] RDX: 0000000008040075 RSI: ffff880dc59ebe00 RDI: ffffea003e017c00
> [  538.840256] RBP: ffff880e73291d58 R08: 0000000000000002 R09: 0000000000000001
> [  538.840256] R10: 0000000000000001 R11: 0000000000000000 R12: fffffffffffffff2
> [  538.840256] R13: ffffea003e017c00 R14: 0000000000000002 R15: 00000000fffffff4
> [  538.840256] FS:  00007f43832a3700(0000) GS:ffff880fe7400000(0000) knlGS:0000000000000
> 000
> [  538.840256] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  538.840256] CR2: 0000000002083be8 CR3: 0000000ec894e000 CR4: 00000000000006e0
> [  538.840256] Stack:
> [  538.840256]  0000000000000000 ffffea003e017c00 0000000000000000 ffff880e73291e58
> [  538.840256]  ffff880e73291da8 ffffffff812b5664 000000000000044e 0000000000000000
> [  538.840256]  ffff880e73291da8 ffffea003e017c00 ffffea003e017c40 ffff880e73291e58
> [  538.840256] Call Trace:
> [  538.840256]  [<ffffffff812b5664>] unmap_and_move+0x44/0x180
> [  538.840256]  [<ffffffff812b588b>] migrate_pages+0xeb/0x2f0
> [  538.840256]  [<ffffffff812a4040>] ? alloc_pages_vma+0x220/0x220
> [  538.840256]  [<ffffffff812a4ba3>] do_mbind+0x283/0x340
> [  538.840256]  [<ffffffff812794af>] ? might_fault+0x9f/0xb0
> [  538.840256]  [<ffffffff81279466>] ? might_fault+0x56/0xb0
> [  538.840256]  [<ffffffff81249a98>] ? context_tracking_user_exit+0xb8/0x1d0
> [  538.840256]  [<ffffffff812a4ce9>] SYSC_mbind+0x89/0xb0
> [  538.840256]  [<ffffffff81249b75>] ? context_tracking_user_exit+0x195/0x1d0
> [  538.840256]  [<ffffffff812a4d1e>] SyS_mbind+0xe/0x10
> [  538.840256]  [<ffffffff843bc489>] ia32_do_call+0x13/0x13
> [  538.840256] Code: 95 58 fe ff 49 89 c4 48 83 f8 f2 75 14 48 8b 5b 10 48 85 db 75 e3 0f 1f 00 eb 
> 10 66 0f 1f 44 00 00 48 85 db 0f 1f 44 00 00 75 0e <0f> 0b 0f 1f 40 00 eb fe 66 0f 1f 44 00 00 4c 89 
> ef e8 68 6a ff
> [  538.840256] RIP  [<ffffffff812a4092>] new_vma_page+0x52/0xb0
> [  538.840256]  RSP <ffff880e73291d38>

Davej reported this as well.

I don't see how we can make this assertion - queue_pages_range() walks
off the end of the vma list, returns NULL and boom?

btw, perhaps it would be useful if the fuzzer were to generate a log of
the syscalls it is performing so people could replay them to reproduce
the bug?  Not easy when it's a multi-threaded thing I guess..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
