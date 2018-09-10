Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0A4C8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:30:55 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id m13-v6so3293970ioq.9
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 01:30:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e185-v6sor12233821ith.43.2018.09.10.01.30.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 01:30:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000000000000be864405758022a2@google.com>
References: <000000000000be864405758022a2@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 10 Sep 2018 10:30:33 +0200
Message-ID: <CACT4Y+aFhrSaTv7nb7UybqKh_K0yhEcrNP0iUB8_7fgvdSXNEA@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in __do_page_cache_readahead
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+d47b586c9bc26763ffce@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, "Darrick J. Wong" <darrick.wong@oracle.com>, dchinner@redhat.com, Josef Bacik <jbacik@fb.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Matthew Wilcox <mawilcox@microsoft.com>, stockhausen@collogia.de, syzkaller-bugs <syzkaller-bugs@googlegroups.com>

On Mon, Sep 10, 2018 at 10:28 AM, syzbot
<syzbot+d47b586c9bc26763ffce@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    3d0e7a9e00fd Merge tag 'md/4.19-rc2' of git://git.kernel.o..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=1654ac21400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=8f59875069d721b6
> dashboard link: https://syzkaller.appspot.com/bug?extid=d47b586c9bc26763ffce
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+d47b586c9bc26763ffce@syzkaller.appspotmail.com
>
> EXT4-fs (sda1): warning: refusing change of dax flag with busy inodes while
> remounting
> EXT4-fs (sda1): re-mounted. Opts: dax,,errors=continue
> EXT4-fs (sda1): DAX enabled. Warning: EXPERIMENTAL, use at your own risk
> EXT4-fs (sda1): warning: refusing change of dax flag with busy inodes while
> remounting
> EXT4-fs (sda1): re-mounted. Opts: dax,,errors=continue
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> PGD 1cf0bc067 P4D 1cf0bc067 PUD 1c8d95067 PMD 0
> Oops: 0010 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 9112 Comm: syz-executor2 Not tainted 4.19.0-rc2+ #6
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:          (null)
> Code: Bad RIP value.
> RSP: 0018:ffff880184436a28 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: dffffc0000000000 RCX: ffffc900062fe000
> RDX: 1ffffffff1036431 RSI: ffffea000602f280 RDI: ffff8801c86ce780
> RBP: ffff880184436c08 R08: ffff8801bf28a0c0 R09: fffff94000c05e56
> R10: fffff94000c05e56 R11: ffffea000602f2b7 R12: ffffea000602f288
> R13: ffffea000602f280 R14: 0000000000000000 R15: ffffed0030886d74
> FS:  00007f9fe8e5f700(0000) GS:ffff8801daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffffffffffffffd6 CR3: 000000018aff0000 CR4: 00000000001406e0
> Call Trace:
>  __do_page_cache_readahead+0x56d/0x980 mm/readahead.c:210
>  ra_submit mm/internal.h:66 [inline]
>  do_sync_mmap_readahead mm/filemap.c:2444 [inline]
>  filemap_fault+0xf4d/0x25f0 mm/filemap.c:2520
>  ext4_filemap_fault+0x82/0xad fs/ext4/inode.c:6257
>  __do_fault+0x100/0x6b0 mm/memory.c:3240
>  do_read_fault mm/memory.c:3652 [inline]
>  do_fault mm/memory.c:3752 [inline]
>  handle_pte_fault mm/memory.c:3983 [inline]
>  __handle_mm_fault+0x3709/0x53e0 mm/memory.c:4107
>  handle_mm_fault+0x54f/0xc70 mm/memory.c:4144
>  faultin_page mm/gup.c:518 [inline]
>  __get_user_pages+0x806/0x1b30 mm/gup.c:718
>  populate_vma_page_range+0x2db/0x3d0 mm/gup.c:1222
>  __mm_populate+0x286/0x4d0 mm/gup.c:1270
>  mm_populate include/linux/mm.h:2307 [inline]
>  vm_mmap_pgoff+0x27f/0x2c0 mm/util.c:362
>  ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1585
>  __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
>  __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
>  __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
>  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x457099
> Code: fd b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7
> 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff
> 0f 83 cb b4 fb ff c3 66 2e 0f 1f 84 00 00 00 00
> RSP: 002b:00007f9fe8e5ec78 EFLAGS: 00000246 ORIG_RAX: 0000000000000009
> RAX: ffffffffffffffda RBX: 00007f9fe8e5f6d4 RCX: 0000000000457099
> RDX: 00000000007ffffe RSI: 0000000000600000 RDI: 0000000020000000
> RBP: 0000000000930140 R08: 0000000000000005 R09: 0000000000000000
> R10: 0000000004002011 R11: 0000000000000246 R12: 00000000ffffffff
> R13: 00000000004d3168 R14: 00000000004c8161 R15: 0000000000000001
> Modules linked in:
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> CR2: 0000000000000000
> ---[ end trace e3fb6a18760358f2 ]---
> RIP: 0010:          (null)
> Code: Bad RIP value.
> RSP: 0018:ffff880184436a28 EFLAGS: 00010246
> RAX: 0000000000000000 RBX: dffffc0000000000 RCX: ffffc900062fe000
> RDX: 1ffffffff1036431 RSI: ffffea000602f280 RDI: ffff8801c86ce780
> RBP: ffff880184436c08 R08: ffff8801bf28a0c0 R09: fffff94000c05e56
> R10: fffff94000c05e56 R11: ffffea000602f2b7 R12: ffffea000602f288
> R13: ffffea000602f280 R14: 0000000000000000 R15: ffffed0030886d74
> FS:  00007f9fe8e5f700(0000) GS:ffff8801dae00000(0000) knlGS:0000000000000000


>From the log the program that triggered this is:

13:40:47 executing program 2:
perf_event_open(&(0x7f0000000040)={0x1, 0x70, 0x0, 0x0, 0x0, 0x0, 0x0,
0x50d}, 0x0, 0xffffffffffffffff, 0xffffffffffffffff, 0x0)
r0 = creat(&(0x7f0000000700)='./bus\x00', 0x0)
ftruncate(r0, 0x208200)
r1 = open(&(0x7f0000000780)='./bus\x00', 0x14103e, 0x0)
ioctl$EXT4_IOC_SETFLAGS(r1, 0x40086602, &(0x7f00000000c0))
mmap(&(0x7f0000000000/0x600000)=nil, 0x600000, 0x7ffffe, 0x4002011, r1, 0x0)
sendfile(0xffffffffffffffff, 0xffffffffffffffff, &(0x7f0000000100), 0x9)
ioctl$EXT4_IOC_SWAP_BOOT(r1, 0x6611)

Most likely there is some race involved.
