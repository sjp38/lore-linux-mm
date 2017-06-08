Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAB536B0279
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 23:03:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q78so5540128pfj.9
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 20:03:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l63si3288451pfb.315.2017.06.07.20.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 20:03:40 -0700 (PDT)
Date: Wed, 7 Jun 2017 20:03:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Fwd: kernel BUG at lib/radix-tree.c:1008!
Message-ID: <20170608030339.GC20010@bombadil.infradead.org>
References: <CACbyUSpTZBVa0MTvScqVmN3Mg8j0b9QDkzGZ08c7zQiH-wRy3g@mail.gmail.com>
 <CACbyUSoEZCW0oATVgk4z0z9M=KX3jxw5p+coN-xSSeCpmqGZQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACbyUSoEZCW0oATVgk4z0z9M=KX3jxw5p+coN-xSSeCpmqGZQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gene Blue <geneblue.mail@gmail.com>
Cc: hughd@google.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>

On Thu, Jun 08, 2017 at 10:31:39AM +0800, Gene Blue wrote:
> kernel BUG at lib/radix-tree.c:1008!

Well, that's interesting.  The BUG at that line is:

		BUG_ON(root_tags_get(root));

which indicates we just inserted an entry into the radix tree at root, and
found out that the entry was already tagged!

That shouldn't be happening.  We clear the tags (all the way up to the root)
when deleting entries from the tree.  Is this at all reproducible?

> invalid opcode: 0000 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 7809 Comm: syz-executor2 Not tainted 4.11.0-rc1 #7
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88006a1bdb40 task.stack: ffff88006b348000
> RIP: 0010:__radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008
> RSP: 0018:ffff88006b34f760 EFLAGS: 00010087
> RAX: ffff88006a1bdb40 RBX: 1ffff1000d669eee RCX: 0000000000000001
> RDX: 0000000000000000 RSI: ffffffff81bd50fb RDI: ffffc90004032000
> RBP: ffff88006b34f838 R08: 00000000000000fa R09: 0000000000010000
> R10: 0000000000000003 R11: ffff8800605b8ed0 R12: 0000000000000000
> R13: 1ffff1000c0b71da R14: 0000000000000000 R15: ffff8800605b8ed0
> FS:  00007f8722b38700(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000020001ff4 CR3: 000000003c6d6000 CR4: 00000000000006e0
> Call Trace:
>  radix_tree_insert include/linux/radix-tree.h:297 [inline]
>  shmem_add_to_page_cache+0x2fe/0x420 mm/shmem.c:591
>  shmem_getpage_gfp.isra.49+0x110a/0x1c90 mm/shmem.c:1792
>  shmem_fault+0x21f/0x690 mm/shmem.c:1985
>  __do_fault+0x83/0x210 mm/memory.c:2888
>  do_read_fault mm/memory.c:3270 [inline]
>  do_fault mm/memory.c:3370 [inline]
>  handle_pte_fault mm/memory.c:3600 [inline]
>  __handle_mm_fault+0x8d5/0x1bc0 mm/memory.c:3714
>  handle_mm_fault+0x1ea/0x4c0 mm/memory.c:3751
>  __do_page_fault+0x508/0xb00 arch/x86/mm/fault.c:1397
>  trace_do_page_fault+0x93/0x450 arch/x86/mm/fault.c:1490
>  do_async_page_fault+0x14/0x60 arch/x86/kernel/kvm.c:264
>  async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1014
> RIP: 0010:do_strncpy_from_user lib/strncpy_from_user.c:44 [inline]
> RIP: 0010:strncpy_from_user+0xa9/0x2b0 lib/strncpy_from_user.c:117
> RSP: 0018:ffff88006b34fdc0 EFLAGS: 00010246
> RAX: ffff88006a1bdb40 RBX: 0000000000000fe4 RCX: 0000000000000001
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc90004032000
> RBP: ffff88006b34fe00 R08: 0000000000000017 R09: 0000000000010000
> R10: ffff88003a9568ff R11: ffffed000752ad20 R12: 0000000000000fe4
> R13: 0000000020001ff4 R14: 0000000000000fe4 R15: fffffffffffffff2
>  getname_flags+0x113/0x580 fs/namei.c:148
>  getname+0x19/0x20 fs/namei.c:208
>  do_sys_open+0x1c7/0x450 fs/open.c:1045
>  SYSC_openat fs/open.c:1078 [inline]
>  SyS_openat+0x30/0x40 fs/open.c:1072
>  entry_SYSCALL_64_fastpath+0x1f/0xc2
> RIP: 0033:0x4458d9
> RSP: 002b:00007f8722b37b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000101
> RAX: ffffffffffffffda RBX: 00000000007080a8 RCX: 00000000004458d9
> RDX: 0000000000010100 RSI: 0000000020001ff4 RDI: ffffffffffffff9c
> RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000
> R13: 0000000000000000 R14: 00007f8722b389c0 R15: 00007f8722b38700
> Code: 38 ca 7c 0d 45 84 c9 74 08 4c 89 ff e8 8f a5 97 ff 4c 8b 9d 30 ff ff
> ff 41 8b 03 c1 e8 1a 85 c0 0f 84 8b fe ff ff e8 15 52 78 ff <0f> 0b e8 0e
> 52 78 ff 49 8d 7d 03 48 b9 00 00 00 00 00 fc ff df
> RIP: __radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008 RSP:
> ffff88006b34f760
> ---[ end trace c1b7be537b8a3b4a ]---
> Kernel panic - not syncing: Fatal exception
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
