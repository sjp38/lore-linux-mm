Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3931A8E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:11:19 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id m128so5837401itd.3
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:11:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f191sor8677340itc.25.2018.12.14.05.11.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 05:11:17 -0800 (PST)
MIME-Version: 1.0
References: <0000000000004ea80b057cfae21e@google.com>
In-Reply-To: <0000000000004ea80b057cfae21e@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 14 Dec 2018 14:11:05 +0100
Message-ID: <CACT4Y+Z+AhQxf6=ecOkX1bOU5h7kMHYnR6CAhBv9eO5jQVeG3g@mail.gmail.com>
Subject: Re: general protection fault in watchdog
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, rafael.j.wysocki@intel.com, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, vkuznets@redhat.com, Linux-MM <linux-mm@kvack.org>

On Fri, Dec 14, 2018 at 1:51 PM syzbot
<syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    f5d582777bcb Merge branch 'for-linus' of git://git.kernel...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=16aca143400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=c8970c89a0efbb23
> dashboard link: https://syzkaller.appspot.com/bug?extid=7713f3aa67be76b1552c
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1131381b400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=13bae593400000
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

+linux-mm for memcg question

What the repro does is effectively just
setsockopt(EBT_SO_SET_ENTRIES). This eats all machine memory and
causes OOMs. Somehow it also caused the GPF in watchdog when it
iterates over task list, perhaps some scheduler code leaves a dangling
pointer on OOM failures.

But what bothers me is a different thing. syzkaller test processes are
sandboxed with a restrictive memcg which should prevent them from
eating all memory. do_replace_finish calls vmalloc, which uses
GFP_KERNEL, which does not include GFP_ACCOUNT (GFP_KERNEL_ACCOUNT
does). And page alloc seems to change memory against memcg iff
GFP_ACCOUNT is provided.
Am I missing something or vmalloc is indeed not accounted (DoS)? I see
some explicit uses of GFP_KERNEL_ACCOUNT, e.g. the one below, but they
seem to be very sparse.

static void *seq_buf_alloc(unsigned long size)
{
     return kvmalloc(size, GFP_KERNEL_ACCOUNT);
}

Now looking at the code I also don't see how kmalloc(GFP_KERNEL) is
accounted... Which makes me think I am still missing something.




> Node 0 DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
> free_cma:0kB
> kasan: CONFIG_KASAN_INLINE enabled
> kasan: GPF could be caused by NULL-ptr deref or user memory access
> general protection fault: 0000 [#1] PREEMPT SMP KASAN
> CPU: 1 PID: 1019 Comm: khungtaskd Not tainted 4.20.0-rc6+ #150
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> RIP: 0010:check_hung_uninterruptible_tasks kernel/hung_task.c:197 [inline]
> RIP: 0010:watchdog+0x492/0x1060 kernel/hung_task.c:289
> Code: 44 89 b5 30 fe ff ff 48 c1 e8 03 4c 01 e8 48 89 85 e8 fd ff ff e9 f8
> 00 00 00 e8 29 f3 ff ff 48 8d 7b 10 48 89 f8 48 c1 e8 03 <42> 80 3c 28 00
> 0f 85 70 0a 00 00 4c 8b 73 10 bf 02 00 00 00 4c 89
> RSP: 0018:ffff8881d7b37cc8 EFLAGS: 00010202
> RAX: 01a5bfffffffff51 RBX: 0d2dfffffffffa7a RCX: ffffffff817f9259
> RDX: 0000000000000000 RSI: ffffffff817f9147 RDI: 0d2dfffffffffa8a
> xt_bpf: check failed: parse error
> RBP: ffff8881d7b37f00 R08: ffff8881d7bae140 R09: ffffed103b5e5b5f
> R10: ffffed103b5e5b5f R11: ffff8881daf2dafb R12: 00000000000003d6
> R13: dffffc0000000000 R14: 1ffff1103af66fbb R15: 00000000003fffd7
> FS:  0000000000000000(0000) GS:ffff8881daf00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f98b2d7c324 CR3: 00000001931bf000 CR4: 00000000001406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> Call Trace:
> lowmem_reserve[]: 0 2818 6321 6321
> Node 0 DMA32 free:43812kB min:30052kB low:37564kB high:45076kB
> active_anon:6236kB inactive_anon:0kB active_file:0kB inactive_file:80kB
> unevictable:0kB writepending:0kB present:3129332kB managed:2888780kB
> mlocked:0kB kernel_stack:32kB pagetables:0kB bounce:0kB free_pcp:200kB
> local_pcp:200kB free_cma:0kB
>   kthread+0x35a/0x440 kernel/kthread.c:246
>   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
> Modules linked in:
> lowmem_reserve[]: 0 0 3503 3503
> Node 0 Normal free:158644kB min:37364kB low:46704kB high:56044kB
> active_anon:4768kB inactive_anon:768kB active_file:556kB
> inactive_file:1936kB unevictable:0kB writepending:0kB present:4718592kB
> managed:3587816kB mlocked:0kB kernel_stack:5952kB pagetables:1172kB
> bounce:0kB free_pcp:2416kB local_pcp:604kB free_cma:0kB
> lowmem_reserve[]: 0 0 0 0
> Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U)
> 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (M) 3*4096kB (M) = 15908kB
> Node 0 DMA32: 21*4kB (UM) 19*8kB (ME) 17*16kB (UM) 15*32kB (UME) 13*64kB
> (ME) 4*128kB (M) 3*256kB (UM) 16*512kB (UM) 12*1024kB (UME) 6*2048kB (UME)
> 2*4096kB (UM) = 44060kB
> Node 0 Normal: 366*4kB (UME) 308*8kB (UME) 615*16kB (UME) 146*32kB (UME)
> 467*64kB (UME) 43*128kB (UM) 4*256kB (UM) 2*512kB (ME) 2*1024kB (ME)
> 0*2048kB 0*4096kB = 57928kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> 591 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 1965979 pages RAM
> 0 pages HighMem/MovableOnly
> 342853 pages reserved
> 0 pages cma reserved
> Unreclaimable slab info:
> Name                      Used          Total
> TIPC                       1KB          7KB
> SCTPv6                     2KB          6KB
> DCCPv6                     2KB          7KB
> DCCP                       2KB          6KB
> fib6_nodes                 0KB          4KB
> ip6_dst_cache              4KB          7KB
> RAWv6                      9KB         19KB
> UDPv6                     14KB         14KB
> TCPv6                     23KB         29KB
> nf_conntrack               0KB          3KB
> sd_ext_cdb                 0KB          3KB
> scsi_sense_cache        1056KB       1060KB
> virtio_scsi_cmd           16KB         16KB
> ---[ end trace 92ff4e73865c48e6 ]---
> sgpool-128                 8KB          8KB
> RIP: 0010:check_hung_uninterruptible_tasks kernel/hung_task.c:197 [inline]
> RIP: 0010:watchdog+0x492/0x1060 kernel/hung_task.c:289
> sgpool-64                  4KB          6KB
> sgpool-32                  2KB          7KB
> Code: 44 89 b5 30 fe ff ff 48 c1 e8 03 4c 01 e8 48 89 85 e8 fd ff ff e9 f8
> 00 00 00 e8 29 f3 ff ff 48 8d 7b 10 48 89 f8 48 c1 e8 03 <42> 80 3c 28 00
> 0f 85 70 0a 00 00 4c 8b 73 10 bf 02 00 00 00 4c 89
> sgpool-16                  1KB          3KB
> RSP: 0018:ffff8881d7b37cc8 EFLAGS: 00010202
> RAX: 01a5bfffffffff51 RBX: 0d2dfffffffffa7a RCX: ffffffff817f9259
> RDX: 0000000000000000 RSI: ffffffff817f9147 RDI: 0d2dfffffffffa8a
> RBP: ffff8881d7b37f00 R08: ffff8881d7bae140 R09: ffffed103b5e5b5f
> sgpool-8                   0KB          3KB
> mqueue_inode_cache          1KB          7KB
> R10: ffffed103b5e5b5f R11: ffff8881daf2dafb R12: 00000000000003d6
> R13: dffffc0000000000 R14: 1ffff1103af66fbb R15: 00000000003fffd7
> bio_post_read_ctx         14KB         15KB
> FS:  0000000000000000(0000) GS:ffff8881dae00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> bio-2                     14KB         15KB
> jfs_mp                     7KB          7KB
> nfs_commit_data            3KB          7KB
> CR2: 00000000004376a0 CR3: 000000016845e000 CR4: 00000000001406f0
> nfs_write_data            32KB         32KB
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> ext4_system_zone           0KB          3KB
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
