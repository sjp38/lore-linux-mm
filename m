Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 908E36B0005
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 16:21:00 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so137441058wmp.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:21:00 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id di9si4884975wjc.18.2016.02.02.13.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 13:20:59 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id l66so42336436wml.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 13:20:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YHX-P0X8Y8530FoG2weg39edujD=1JyXZf6c67FM_xzw@mail.gmail.com>
References: <CACT4Y+ZqQte+9Uk2FsixfWw7sAR7E5rK_BBr8EJe1M+Sv-i_RQ@mail.gmail.com>
 <alpine.LNX.2.00.1602022204190.22727@cbobk.fhfr.pm> <CACT4Y+YHX-P0X8Y8530FoG2weg39edujD=1JyXZf6c67FM_xzw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 2 Feb 2016 22:20:39 +0100
Message-ID: <CACT4Y+Z=qaJjzOFsksSHur-kED=Jf-JFk_M0jnMNq1y5RG278A@mail.gmail.com>
Subject: Re: mm: uninterruptable tasks hanged on mmap_sem
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Takashi Iwai <tiwai@suse.de>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Tue, Feb 2, 2016 at 10:14 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Feb 2, 2016 at 10:08 PM, Jiri Kosina <jikos@kernel.org> wrote:
>> On Tue, 2 Feb 2016, Dmitry Vyukov wrote:
>>
>>> Hello,
>>>
>>> If the following program run in a parallel loop, eventually it leaves
>>> hanged uninterruptable tasks on mmap_sem.
>>>
>>> [ 4074.740298] sysrq: SysRq : Show Locks Held
>>> [ 4074.740780] Showing all locks held in the system:
>>> ...
>>> [ 4074.762133] 1 lock held by a.out/1276:
>>> [ 4074.762427]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>>> __mm_populate+0x25c/0x350
>>> [ 4074.763149] 1 lock held by a.out/1147:
>>> [ 4074.763438]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816b3bbc>]
>>> vm_mmap_pgoff+0x12c/0x1b0
>>> [ 4074.764164] 1 lock held by a.out/1284:
>>> [ 4074.764447]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff816df89c>]
>>> __mm_populate+0x25c/0x350
>>> [ 4074.765287]



Original log from fuzzer contained the following WARNING in
mm/rmap.c:412. But when I tried to reproduce it, I hit these hanged
processes instead. I can't reliably detect what program triggered
what. So it may be related, or maybe a separate issue.

------------[ cut here ]------------
kernel BUG at mm/rmap.c:412!
invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN
Modules linked in:
CPU: 2 PID: 20110 Comm: udevd Tainted: G        W       4.5.0-rc2+ #306
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff880031c32f80 ti: ffff8800376e0000 task.ti: ffff8800376e0000
RIP: 0010:[<ffffffff81715dd7>]  [<ffffffff81715dd7>]
unlink_anon_vmas+0x407/0x600
RSP: 0018:ffff8800376e7ba0  EFLAGS: 00010297
RAX: ffff880031c32f80 RBX: ffff88003d81f448 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88003e39408c
RBP: ffff8800376e7be8 R08: ffff880034dc35e8 R09: 00000001001d001a
R10: ffff880031c32f80 R11: 0000000000000000 R12: ffff880034dc2908
R13: ffff880034dc2908 R14: ffff880034dc28f8 R15: ffff88003e394000
FS:  0000000000000000(0000) GS:ffff88006d600000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f12dbfbe140 CR3: 000000003552a000 CR4: 00000000000006e0
Stack:
 ffff88003d81f3e0 ffff88003d81f458 ffff88003d81f458 ffff88005e516580
 ffff880039e1df20 ffff88003d81f3e0 dffffc0000000000 00007f12dc802000
 ffff88003d81f430 ffff8800376e7c48 ffffffff816e50ad 0000000000000000
Call Trace:
 [<ffffffff816e50ad>] free_pgtables+0x1bd/0x3b0 mm/memory.c:555
 [<ffffffff81703613>] exit_mmap+0x233/0x410 mm/mmap.c:2850
 [<ffffffff8134bf05>] mmput+0x95/0x230 kernel/fork.c:706
 [<     inline     >] exit_mm kernel/exit.c:436
 [<ffffffff8135e3b2>] do_exit+0x7b2/0x2cb0 kernel/exit.c:735
 [<ffffffff81360a28>] do_group_exit+0x108/0x330 kernel/exit.c:878
 [<     inline     >] SYSC_exit_group kernel/exit.c:889
 [<ffffffff81360c6d>] SyS_exit_group+0x1d/0x20 kernel/exit.c:887
 [<ffffffff86660276>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185
Code: 07 83 c2 03 38 ca 7c 08 84 c9 0f 85 9e 01 00 00 41 8b 87 8c 00
00 00 49 89 de 48 8b 5d d0 85 c0 0f 84 43 ff ff ff e8 d9 5d e5 ff <0f>
0b e8 d2 5d e5 ff 4c 89 ff e8 fa e5 ff ff e9 42 ff ff ff e8
RIP  [<ffffffff81715dd7>] unlink_anon_vmas+0x407/0x600 mm/rmap.c:412
 RSP <ffff8800376e7ba0>
---[ end trace 5282279c07ce8f67 ]---
Fixing recursive fault but reboot is needed!
floppy0: disk absent or changed during operation
blk_update_request: I/O error, dev fd0, sector 0
floppy0: disk absent or changed during operation
blk_update_request: I/O error, dev fd0, sector 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
