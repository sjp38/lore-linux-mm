Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C50896B0313
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 23:21:35 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id u47so4150465uau.15
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 20:21:35 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id g23si2001283uab.253.2017.06.07.20.21.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 20:21:34 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id p85so12309450vkd.3
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 20:21:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170608030339.GC20010@bombadil.infradead.org>
References: <CACbyUSpTZBVa0MTvScqVmN3Mg8j0b9QDkzGZ08c7zQiH-wRy3g@mail.gmail.com>
 <CACbyUSoEZCW0oATVgk4z0z9M=KX3jxw5p+coN-xSSeCpmqGZQw@mail.gmail.com> <20170608030339.GC20010@bombadil.infradead.org>
From: Gene Blue <geneblue.mail@gmail.com>
Date: Thu, 8 Jun 2017 11:21:34 +0800
Message-ID: <CACbyUSoaaAr7EepDcyHPu5C7ff8DyEA6Z546hFXmdLafk2G5mg@mail.gmail.com>
Subject: Re: Fwd: kernel BUG at lib/radix-tree.c:1008!
Content-Type: multipart/alternative; boundary="001a114bc9e28efc8205516a5953"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: hughd@google.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, syzkaller <syzkaller@googlegroups.com>

--001a114bc9e28efc8205516a5953
Content-Type: text/plain; charset="UTF-8"

Yes, this bug is reproducible.

2017-06-08 11:03 GMT+08:00 Matthew Wilcox <willy@infradead.org>:

> On Thu, Jun 08, 2017 at 10:31:39AM +0800, Gene Blue wrote:
> > kernel BUG at lib/radix-tree.c:1008!
>
> Well, that's interesting.  The BUG at that line is:
>
>                 BUG_ON(root_tags_get(root));
>
> which indicates we just inserted an entry into the radix tree at root, and
> found out that the entry was already tagged!
>
> That shouldn't be happening.  We clear the tags (all the way up to the
> root)
> when deleting entries from the tree.  Is this at all reproducible?
>
> > invalid opcode: 0000 [#1] SMP KASAN
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Modules linked in:
> > CPU: 1 PID: 7809 Comm: syz-executor2 Not tainted 4.11.0-rc1 #7
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs
> 01/01/2011
> > task: ffff88006a1bdb40 task.stack: ffff88006b348000
> > RIP: 0010:__radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008
> > RSP: 0018:ffff88006b34f760 EFLAGS: 00010087
> > RAX: ffff88006a1bdb40 RBX: 1ffff1000d669eee RCX: 0000000000000001
> > RDX: 0000000000000000 RSI: ffffffff81bd50fb RDI: ffffc90004032000
> > RBP: ffff88006b34f838 R08: 00000000000000fa R09: 0000000000010000
> > R10: 0000000000000003 R11: ffff8800605b8ed0 R12: 0000000000000000
> > R13: 1ffff1000c0b71da R14: 0000000000000000 R15: ffff8800605b8ed0
> > FS:  00007f8722b38700(0000) GS:ffff88003ed00000(0000)
> knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000020001ff4 CR3: 000000003c6d6000 CR4: 00000000000006e0
> > Call Trace:
> >  radix_tree_insert include/linux/radix-tree.h:297 [inline]
> >  shmem_add_to_page_cache+0x2fe/0x420 mm/shmem.c:591
> >  shmem_getpage_gfp.isra.49+0x110a/0x1c90 mm/shmem.c:1792
> >  shmem_fault+0x21f/0x690 mm/shmem.c:1985
> >  __do_fault+0x83/0x210 mm/memory.c:2888
> >  do_read_fault mm/memory.c:3270 [inline]
> >  do_fault mm/memory.c:3370 [inline]
> >  handle_pte_fault mm/memory.c:3600 [inline]
> >  __handle_mm_fault+0x8d5/0x1bc0 mm/memory.c:3714
> >  handle_mm_fault+0x1ea/0x4c0 mm/memory.c:3751
> >  __do_page_fault+0x508/0xb00 arch/x86/mm/fault.c:1397
> >  trace_do_page_fault+0x93/0x450 arch/x86/mm/fault.c:1490
> >  do_async_page_fault+0x14/0x60 arch/x86/kernel/kvm.c:264
> >  async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1014
> > RIP: 0010:do_strncpy_from_user lib/strncpy_from_user.c:44 [inline]
> > RIP: 0010:strncpy_from_user+0xa9/0x2b0 lib/strncpy_from_user.c:117
> > RSP: 0018:ffff88006b34fdc0 EFLAGS: 00010246
> > RAX: ffff88006a1bdb40 RBX: 0000000000000fe4 RCX: 0000000000000001
> > RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc90004032000
> > RBP: ffff88006b34fe00 R08: 0000000000000017 R09: 0000000000010000
> > R10: ffff88003a9568ff R11: ffffed000752ad20 R12: 0000000000000fe4
> > R13: 0000000020001ff4 R14: 0000000000000fe4 R15: fffffffffffffff2
> >  getname_flags+0x113/0x580 fs/namei.c:148
> >  getname+0x19/0x20 fs/namei.c:208
> >  do_sys_open+0x1c7/0x450 fs/open.c:1045
> >  SYSC_openat fs/open.c:1078 [inline]
> >  SyS_openat+0x30/0x40 fs/open.c:1072
> >  entry_SYSCALL_64_fastpath+0x1f/0xc2
> > RIP: 0033:0x4458d9
> > RSP: 002b:00007f8722b37b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000101
> > RAX: ffffffffffffffda RBX: 00000000007080a8 RCX: 00000000004458d9
> > RDX: 0000000000010100 RSI: 0000000020001ff4 RDI: ffffffffffffff9c
> > RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000
> > R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000
> > R13: 0000000000000000 R14: 00007f8722b389c0 R15: 00007f8722b38700
> > Code: 38 ca 7c 0d 45 84 c9 74 08 4c 89 ff e8 8f a5 97 ff 4c 8b 9d 30 ff
> ff
> > ff 41 8b 03 c1 e8 1a 85 c0 0f 84 8b fe ff ff e8 15 52 78 ff <0f> 0b e8 0e
> > 52 78 ff 49 8d 7d 03 48 b9 00 00 00 00 00 fc ff df
> > RIP: __radix_tree_insert+0x26b/0x2f0 lib/radix-tree.c:1008 RSP:
> > ffff88006b34f760
> > ---[ end trace c1b7be537b8a3b4a ]---
> > Kernel panic - not syncing: Fatal exception
> > Dumping ftrace buffer:
> >    (ftrace buffer empty)
> > Kernel Offset: disabled
> > Rebooting in 86400 seconds..
>

--001a114bc9e28efc8205516a5953
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Yes, this bug is=C2=A0reproducible.<br><div class=3D"gmail=
_extra"><br><div class=3D"gmail_quote">2017-06-08 11:03 GMT+08:00 Matthew W=
ilcox <span dir=3D"ltr">&lt;<a href=3D"mailto:willy@infradead.org" target=
=3D"_blank">willy@infradead.org</a>&gt;</span>:<br><blockquote class=3D"gma=
il_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,2=
04,204);padding-left:1ex"><span class=3D"gmail-">On Thu, Jun 08, 2017 at 10=
:31:39AM +0800, Gene Blue wrote:<br>
&gt; kernel BUG at lib/radix-tree.c:1008!<br>
<br>
</span>Well, that&#39;s interesting.=C2=A0 The BUG at that line is:<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(root_tags_ge=
t(root));<br>
<br>
which indicates we just inserted an entry into the radix tree at root, and<=
br>
found out that the entry was already tagged!<br>
<br>
That shouldn&#39;t be happening.=C2=A0 We clear the tags (all the way up to=
 the root)<br>
when deleting entries from the tree.=C2=A0 Is this at all reproducible?<br>
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5"><br>
&gt; invalid opcode: 0000 [#1] SMP KASAN<br>
&gt; Dumping ftrace buffer:<br>
&gt;=C2=A0 =C2=A0 (ftrace buffer empty)<br>
&gt; Modules linked in:<br>
&gt; CPU: 1 PID: 7809 Comm: syz-executor2 Not tainted 4.11.0-rc1 #7<br>
&gt; Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/0=
1/2011<br>
&gt; task: ffff88006a1bdb40 task.stack: ffff88006b348000<br>
&gt; RIP: 0010:__radix_tree_insert+<wbr>0x26b/0x2f0 lib/radix-tree.c:1008<b=
r>
&gt; RSP: 0018:ffff88006b34f760 EFLAGS: 00010087<br>
&gt; RAX: ffff88006a1bdb40 RBX: 1ffff1000d669eee RCX: 0000000000000001<br>
&gt; RDX: 0000000000000000 RSI: ffffffff81bd50fb RDI: ffffc90004032000<br>
&gt; RBP: ffff88006b34f838 R08: 00000000000000fa R09: 0000000000010000<br>
&gt; R10: 0000000000000003 R11: ffff8800605b8ed0 R12: 0000000000000000<br>
&gt; R13: 1ffff1000c0b71da R14: 0000000000000000 R15: ffff8800605b8ed0<br>
&gt; FS:=C2=A0 00007f8722b38700(0000) GS:ffff88003ed00000(0000) knlGS:00000=
00000000000<br>
&gt; CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
&gt; CR2: 0000000020001ff4 CR3: 000000003c6d6000 CR4: 00000000000006e0<br>
&gt; Call Trace:<br>
&gt;=C2=A0 radix_tree_insert include/linux/radix-tree.h:297 [inline]<br>
&gt;=C2=A0 shmem_add_to_page_cache+0x2fe/<wbr>0x420 mm/shmem.c:591<br>
&gt;=C2=A0 shmem_getpage_gfp.isra.49+<wbr>0x110a/0x1c90 mm/shmem.c:1792<br>
&gt;=C2=A0 shmem_fault+0x21f/0x690 mm/shmem.c:1985<br>
&gt;=C2=A0 __do_fault+0x83/0x210 mm/memory.c:2888<br>
&gt;=C2=A0 do_read_fault mm/memory.c:3270 [inline]<br>
&gt;=C2=A0 do_fault mm/memory.c:3370 [inline]<br>
&gt;=C2=A0 handle_pte_fault mm/memory.c:3600 [inline]<br>
&gt;=C2=A0 __handle_mm_fault+0x8d5/0x1bc0 mm/memory.c:3714<br>
&gt;=C2=A0 handle_mm_fault+0x1ea/0x4c0 mm/memory.c:3751<br>
&gt;=C2=A0 __do_page_fault+0x508/0xb00 arch/x86/mm/fault.c:1397<br>
&gt;=C2=A0 trace_do_page_fault+0x93/0x450 arch/x86/mm/fault.c:1490<br>
&gt;=C2=A0 do_async_page_fault+0x14/0x60 arch/x86/kernel/kvm.c:264<br>
&gt;=C2=A0 async_page_fault+0x28/0x30 arch/x86/entry/entry_64.S:1014<br>
&gt; RIP: 0010:do_strncpy_from_user lib/strncpy_from_user.c:44 [inline]<br>
&gt; RIP: 0010:strncpy_from_user+0xa9/<wbr>0x2b0 lib/strncpy_from_user.c:11=
7<br>
&gt; RSP: 0018:ffff88006b34fdc0 EFLAGS: 00010246<br>
&gt; RAX: ffff88006a1bdb40 RBX: 0000000000000fe4 RCX: 0000000000000001<br>
&gt; RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc90004032000<br>
&gt; RBP: ffff88006b34fe00 R08: 0000000000000017 R09: 0000000000010000<br>
&gt; R10: ffff88003a9568ff R11: ffffed000752ad20 R12: 0000000000000fe4<br>
&gt; R13: 0000000020001ff4 R14: 0000000000000fe4 R15: fffffffffffffff2<br>
&gt;=C2=A0 getname_flags+0x113/0x580 fs/namei.c:148<br>
&gt;=C2=A0 getname+0x19/0x20 fs/namei.c:208<br>
&gt;=C2=A0 do_sys_open+0x1c7/0x450 fs/open.c:1045<br>
&gt;=C2=A0 SYSC_openat fs/open.c:1078 [inline]<br>
&gt;=C2=A0 SyS_openat+0x30/0x40 fs/open.c:1072<br>
&gt;=C2=A0 entry_SYSCALL_64_fastpath+<wbr>0x1f/0xc2<br>
&gt; RIP: 0033:0x4458d9<br>
&gt; RSP: 002b:00007f8722b37b58 EFLAGS: 00000292 ORIG_RAX: 0000000000000101=
<br>
&gt; RAX: ffffffffffffffda RBX: 00000000007080a8 RCX: 00000000004458d9<br>
&gt; RDX: 0000000000010100 RSI: 0000000020001ff4 RDI: ffffffffffffff9c<br>
&gt; RBP: 0000000000000046 R08: 0000000000000000 R09: 0000000000000000<br>
&gt; R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000000000<br>
&gt; R13: 0000000000000000 R14: 00007f8722b389c0 R15: 00007f8722b38700<br>
&gt; Code: 38 ca 7c 0d 45 84 c9 74 08 4c 89 ff e8 8f a5 97 ff 4c 8b 9d 30 f=
f ff<br>
&gt; ff 41 8b 03 c1 e8 1a 85 c0 0f 84 8b fe ff ff e8 15 52 78 ff &lt;0f&gt;=
 0b e8 0e<br>
&gt; 52 78 ff 49 8d 7d 03 48 b9 00 00 00 00 00 fc ff df<br>
&gt; RIP: __radix_tree_insert+0x26b/<wbr>0x2f0 lib/radix-tree.c:1008 RSP:<b=
r>
&gt; ffff88006b34f760<br>
&gt; ---[ end trace c1b7be537b8a3b4a ]---<br>
&gt; Kernel panic - not syncing: Fatal exception<br>
&gt; Dumping ftrace buffer:<br>
&gt;=C2=A0 =C2=A0 (ftrace buffer empty)<br>
&gt; Kernel Offset: disabled<br>
&gt; Rebooting in 86400 seconds..<br>
</div></div></blockquote></div><br></div></div>

--001a114bc9e28efc8205516a5953--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
