Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A78196B0080
	for <linux-mm@kvack.org>; Tue, 11 Mar 2014 07:47:28 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so8655052pab.40
        for <linux-mm@kvack.org>; Tue, 11 Mar 2014 04:47:28 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wh10si19976827pab.104.2014.03.11.04.47.26
        for <linux-mm@kvack.org>;
        Tue, 11 Mar 2014 04:47:27 -0700 (PDT)
Date: Tue, 11 Mar 2014 19:47:21 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [vma caching] BUG: unable to handle kernel paging request at
 ffff880008142f40
Message-ID: <20140311114721.GA29461@localhost>
References: <20140310024356.GB9322@localhost>
 <1394485688.3867.13.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394485688.3867.13.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Davidlohr,

On Mon, Mar 10, 2014 at 02:08:08PM -0700, Davidlohr Bueso wrote:
> On Mon, 2014-03-10 at 10:43 +0800, Fengguang Wu wrote:
> > Hi Davidlohr,
> > 
> > I got the below dmesg and the first bad commit is
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > commit 0d9ad4220e6d73f63a9eeeaac031b92838f75bb3
> > Author:     Davidlohr Bueso <davidlohr@hp.com>
> > AuthorDate: Thu Mar 6 11:01:48 2014 +1100
> > Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
> > CommitDate: Thu Mar 6 11:01:48 2014 +1100
> > 
> >     mm: per-thread vma caching
> >     
> > hwclock: can't open '/dev/misc/rtc': No such file or directory
> > Running postinst /etc/rpm-postinsts/100...
> 
> Hmm this kind of errors strike me as dealing with some bogus vma from a
> stale cache.
> 
> > [    3.658976] BUG: unable to handle kernel paging request at ffff880008142f40
> > [    3.661422] IP: [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
> > [    3.662223] PGD 2542067 PUD 2543067 PMD fba5067 PTE 8000000008142060
> > [    3.662223] Oops: 0000 [#1] DEBUG_PAGEALLOC
> > [    3.662223] Modules linked in:
> > [    3.662223] CPU: 0 PID: 326 Comm: 90-trinity Not tainted 3.14.0-rc5-next-20140307 #1
> 
> Have you only seen this through DEBUG_PAGEALLOC + trinity?

Yes.

> > [    3.662223] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [    3.662223] task: ffff8800083020d0 ti: ffff8800082a0000 task.ti: ffff8800082a0000
> > [    3.662223] RIP: 0010:[<ffffffff8111a1d8>]  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
> > [    3.662223] RSP: 0000:ffff8800082a1e00  EFLAGS: 00010282
> > [    3.662223] RAX: ffff880008142f40 RBX: 00000000000000a9 RCX: ffff8800083020d0
> > [    3.662223] RDX: 0000000000000002 RSI: 00007fff8a141698 RDI: ffff880008124bc0
> > [    3.662223] RBP: ffff8800082a1e00 R08: 0000000000000000 R09: 0000000000000001
> > [    3.662223] R10: ffff8800083020d0 R11: 0000000000000000 R12: 00007fff8a141698
> > [    3.662223] R13: ffff880008124bc0 R14: ffff8800082a1f58 R15: ffff8800083020d0
> > [    3.662223] FS:  00007fe3ca364700(0000) GS:ffffffff81a06000(0000) knlGS:0000000000000000
> > [    3.662223] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [    3.662223] CR2: ffff880008142f40 CR3: 000000000824c000 CR4: 00000000000006b0
> > [    3.662223] Stack:
> > [    3.662223]  ffff8800082a1e28 ffffffff81125219 00000000000000a9 00007fff8a141698
> > [    3.662223]  ffff880008124bc0 ffff8800082a1f28 ffffffff816d71fe 0000000000000246
> > [    3.662223]  0000000000000002 ffff880008124c58 0000000000000006 0000000000000010
> > [    3.662223] Call Trace:
> > [    3.662223]  [<ffffffff81125219>] find_vma+0x19/0x70
> > [    3.662223]  [<ffffffff816d71fe>] __do_page_fault+0x29e/0x560
> > [    3.662223]  [<ffffffff8116cc6f>] ? mntput_no_expire+0x6f/0x1a0
> > [    3.662223]  [<ffffffff8116cc11>] ? mntput_no_expire+0x11/0x1a0
> > [    3.662223]  [<ffffffff8116cdd5>] ? mntput+0x35/0x40
> > [    3.662223]  [<ffffffff8114f51f>] ? __fput+0x24f/0x290
> > [    3.662223]  [<ffffffff812794ca>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> > [    3.662223]  [<ffffffff816d74ce>] do_page_fault+0xe/0x10
> > [    3.662223]  [<ffffffff816d6ad5>] do_async_page_fault+0x35/0x90
> > [    3.662223]  [<ffffffff816d3b05>] async_page_fault+0x25/0x30
> > [    3.662223] Code: c7 81 b0 02 00 00 00 00 00 00 eb 32 0f 1f 80 00 00 00 00 31 d2 66 0f 1f 44 00 00 48 63 c2 48 8b 84 c1 98 02 00 00 48 85 c0 74 0b <48> 39 30 77 06 48 3b 70 08 72 0a 83 c2 01 83 fa 04 75 dd 31 c0 
> > [    3.662223] RIP  [<ffffffff8111a1d8>] vmacache_find+0x78/0x90
> 
> So this is:
>    0:   c7 81 b0 02 00 00 00    movl   $0x0,0x2b0(%rcx)
>    7:   00 00 00 
>    a:   eb 32                   jmp    0x3e
>    c:   0f 1f 80 00 00 00 00    nopl   0x0(%rax)
>   13:   31 d2                   xor    %edx,%edx
>   15:   66 0f 1f 44 00 00       nopw   0x0(%rax,%rax,1)
>   1b:   48 63 c2                movslq %edx,%rax
>   1e:   48 8b 84 c1 98 02 00    mov    0x298(%rcx,%rax,8),%rax
>   25:   00 
>   26:   48 85 c0                test   %rax,%rax
>   29:   74 0b                   je     0x36
>   2b:*  48 39 30                cmp    %rsi,(%rax)              <-- trapping instruction
> 
> 
> which seems to be the following, where vma is stale:
> 		if (vma && vma->vm_start <= addr && vma->vm_end > addr)
> 			return vma;
> 
> 
>   2e:   77 06                   ja     0x36
>   30:   48 3b 70 08             cmp    0x8(%rax),%rsi
>   34:   72 0a                   jb     0x40
>   36:   83 c2 01                add    $0x1,%edx
>   39:   83 fa 04                cmp    $0x4,%edx
>   3c:   75 dd                   jne    0x1b
>   3e:   31 c0                   xor    %eax,%eax
> 
> Could you please try this fix: https://lkml.org/lkml/2014/3/10/505 - it
> is fix for a race Oleg found that can cause us to keep bogus vmas in the
> cache under certain VM_CLONE scenarios.

With the patch applied on top of 0d9ad4220e6d73f63a9eeeaac031b92838f75bb3
I still get this:

sed: /lib/modules/3.14.0-rc5-00226-g0d9ad422-dirty/modules.dep: No such file or directory
xargs: modprobe: No such file or directory
run-parts: /etc/kernel-tests/01-modprobe exited with code 127
[    3.807108] BUG: unable to handle kernel paging request at ffff8800060d4f40
[    3.807408] IP: [<ffffffff81111438>] vmacache_find+0x78/0x90
[    3.807408] PGD 23f9067 PUD 23fa067 PMD fbb5067 PTE 80000000060d4060
[    3.807408] Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[    3.807408] CPU: 0 PID: 428 Comm: 90-trinity Not tainted 3.14.0-rc5-00226-g0d9ad422-dirty #5
[    3.807408] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    3.807408] task: ffff88000ca1e050 ti: ffff8800060ce000 task.ti: ffff8800060ce000
[    3.807408] RIP: 0010:[<ffffffff81111438>]  [<ffffffff81111438>] vmacache_find+0x78/0x90
[    3.807408] RSP: 0000:ffff8800060cfde8  EFLAGS: 00010282
[    3.807408] RAX: ffff8800060d4f40 RBX: 00007f2c1d835190 RCX: ffff88000ca1e050
[    3.807408] RDX: 0000000000000002 RSI: 00007f2c1d835190 RDI: ffff880006721b80
[    3.807408] RBP: ffff8800060cfde8 R08: 0000000000000001 R09: 0000000000000000
[    3.807408] R10: 0000000000000000 R11: 0000000000000156 R12: ffff880006721b80
[    3.807408] R13: 00000000ffffffff R14: ffff880006721c18 R15: 00007f2c1d835190
[    3.807408] FS:  00007f2c1dd87700(0000) GS:ffffffff8187d000(0000) knlGS:0000000000000000
[    3.807408] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    3.807408] CR2: ffff8800060d4f40 CR3: 000000000829d000 CR4: 00000000000006f0
[    3.807408] Stack:
[    3.807408]  ffff8800060cfe18 ffffffff8111d08b ffffffff810378b5 0000000000000246
[    3.807408]  ffff880006721b80 00000000000000a8 ffff8800060cff28 ffffffff81037926
[    3.807408]  0000000000000000 ffff88000ca1e050 ffff8800060cff58 0000000000000014

> Also, how frequently are you able to trigger this?

This one is very reproducible:

+--------------------------------------------+---+
| boot_successes                             | 2 |
| boot_failures                              | 7 |
+--------------------------------------------+---+
| BUG:unable_to_handle_kernel_paging_request | 7 |
| Oops:PREEMPT_DEBUG_PAGEALLOC               | 7 |
| RIP:vmacache_find                          | 7 |
| Kernel_panic-not_syncing:Fatal_exception   | 7 |
+--------------------------------------------+---+

[    1.641026] BUG: unable to handle kernel paging request at ffff88000926af38
[    1.642202] IP: [<ffffffff8dce4834>] vmacache_find+0x59/0x69
[    1.643172] PGD eee4067 PUD eee5067 PMD fb9c067 PTE 800000000926a060
[    1.644024] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[    1.644024] Modules linked in:
[    1.644024] CPU: 1 PID: 190 Comm: 90-trinity Not tainted 3.14.0-rc5-next-20140306-06952-g0ffb2fe #3
[    1.644024] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    1.644024] task: ffff8800093ba010 ti: ffff880009340000 task.ti: ffff880009340000
[    1.644024] RIP: 0010:[<ffffffff8dce4834>]  [<ffffffff8dce4834>] vmacache_find+0x59/0x69
[    1.644024] RSP: 0000:ffff880009341dc8  EFLAGS: 00010282
[    1.644024] RAX: ffff8800093ba010 RBX: 00007fffd108de78 RCX: ffff88000926af38
[    1.644024] RDX: 0000000000000002 RSI: 00007fffd108de78 RDI: ffff8800091cdb80
[    1.644024] RBP: ffff880009341dc8 R08: 0000000000000000 R09: 0000000000000000
[    1.644024] R10: 00007fffd108e200 R11: 00007fa9ab552190 R12: 00007fffd108de78
[    1.644024] R13: ffff8800091cdb80 R14: 00000000000000a9 R15: ffff8800093ba010
[    1.644024] FS:  00007fa9abaa4700(0000) GS:ffff88000f900000(0000) knlGS:0000000000000000
[    1.644024] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.644024] CR2: ffff88000926af38 CR3: 000000000931a000 CR4: 00000000000006a0
[    1.644024] Stack:
[    1.644024]  ffff880009341df0 ffffffff8dcec5d5 ffff880009341f58 00007fffd108de78
[    1.644024]  0000000000000006 ffff880009341ef8 ffffffff8e11c375 ffff88000c285c70
[    1.644024]  ffff880000000000 0000000000000002 ffff8800091cdc18 ffff8800091cdb80
[    1.644024] Call Trace:
[    1.644024]  [<ffffffff8dcec5d5>] find_vma+0x14/0x5b
[    1.644024]  [<ffffffff8e11c375>] __do_page_fault+0x211/0x399
[    1.644024]  [<ffffffff8dc97214>] ? lock_release+0x150/0x16a
[    1.644024]  [<ffffffff8dd1bd6c>] ? rcu_read_unlock+0x1c/0x26
[    1.644024]  [<ffffffff8dca347a>] ? rcu_eqs_exit_common.isra.63+0x18/0xb3
[    1.644024]  [<ffffffff8dca3591>] ? rcu_eqs_exit+0x7c/0x83
[    1.644024]  [<ffffffff8e11c52f>] do_page_fault+0x32/0x4b
[    1.644024]  [<ffffffff8e11bd2c>] do_async_page_fault+0x2d/0x89
[    1.644024]  [<ffffffff8e119588>] async_page_fault+0x28/0x30
[    1.644024] Code: b9 08 00 00 00 31 c0 48 89 d7 f3 ab eb 19 31 d2 48 63 ca 48 8b 8c c8 90 02 00 00 48 85 c9 75 0b ff c2 83 fa 04 75 e9 31 c0 eb 0e <48> 39 31 77 f0 48 39 71 08 76 ea 48 89 c8 5d c3 48 8b 47 08 48 
[    1.644024] RIP  [<ffffffff8dce4834>] vmacache_find+0x59/0x69
[    1.644024]  RSP <ffff880009341dc8>
[    1.644024] CR2: ffff88000926af38
[    1.644024] ---[ end trace 672cd9b20daaa00f ]---
[    1.644031] BUG: unable to handle kernel paging request at ffff880008c19f38

While this one only shows up once:

[    7.074732] uname (237) used greatest stack depth: 5224 bytes left
Kernel tests: Boot OK!
[    7.446110] BUG: Bad rss-counter state mm:ffff88000ae8e400 idx:0 val:-16
[    7.453003] BUG: Bad rss-counter state mm:ffff88000ae8ea00 idx:0 val:-16
[    7.458563] BUG: Bad rss-counter state mm:ffff88000ae8c000 idx:0 val:48
[    7.462573] BUG: Bad rss-counter state mm:ffff88000ae8c600 idx:0 val:-16
[    7.467516] BUG: unable to handle kernel paging request at ffff88000ae12000
[    7.470027] IP: [<ffffffff88388fbf>] vmacache_find+0xaf/0x110
[    7.470027] PGD a0bf067 PUD a0c0067 PMD fb8e067 PTE 800000000ae12060
[    7.470027] Oops: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[    7.470027] Modules linked in:
[    7.470027] CPU: 0 PID: 280 Comm: 90-trinity Not tainted 3.14.0-rc5-next-20140306-06952-g0ffb2fe #1
[    7.470027] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    7.470027] task: ffff88000ae094f0 ti: ffff88000ae48000 task.ti: ffff88000ae48000
[    7.470027] RIP: 0010:[<ffffffff88388fbf>]  [<ffffffff88388fbf>] vmacache_find+0xaf/0x110
[    7.470027] RSP: 0000:ffff88000ae49df8  EFLAGS: 00010206
[    7.470027] RAX: ffff88000ae12000 RBX: 000000000043b2f2 RCX: 000000000000e8f5
[    7.470027] RDX: 000000000000e8f8 RSI: 000000000043b2f2 RDI: ffff88000ae094f0
[    7.470027] RBP: ffff88000ae49df8 R08: 000000000000e8f9 R09: 0000000000000000
[    7.470027] R10: 0000000000000001 R11: 0000000000000001 R12: ffff88000ae8f600
[    7.470027] R13: 00000000000000a8 R14: ffff88000ae8f600 R15: ffff88000ae49f58
[    7.470027] FS:  00007f582c3bd700(0000) GS:ffffffff88ef7000(0000) knlGS:0000000000000000
[    7.470027] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    7.470027] CR2: ffff88000ae12000 CR3: 000000000ae52000 CR4: 00000000000006f0
[    7.470027] Stack:
[    7.470027]  ffff88000ae49e18 ffffffff88397e22 000000000043b2f2 0000000000000014
[    7.470027]  ffff88000ae49f18 ffffffff8829be64 0000000000000202 ffff88000ae094f0
[    7.470027]  0000000000000000 ffff88000ae8f6a8 0000000000000028 ffffffffff0a0000
[    7.470027] Call Trace:
[    7.470027]  [<ffffffff88397e22>] find_vma+0x22/0xc0
[    7.470027]  [<ffffffff8829be64>] __do_page_fault+0x374/0x7d0
[    7.470027]  [<ffffffff885afd80>] ? snprintf+0x40/0x50
[    7.470027]  [<ffffffff885bf692>] ? __this_cpu_preempt_check+0x32/0x40
[    7.470027]  [<ffffffff8829c300>] do_page_fault+0x10/0x20
[    7.470027]  [<ffffffff8829805e>] do_async_page_fault+0x3e/0xe0
[    7.470027]  [<ffffffff889e64f8>] async_page_fault+0x28/0x30
[    7.470027] Code: a7 01 48 98 48 8b 84 c7 c8 02 00 00 48 85 c0 75 13 0f 1f 00 48 ff 05 d9 7c a7 01 4c 39 c2 75 d4 eb 29 66 90 48 ff 05 b9 7c a7 01 <48> 39 30 77 e4 48 ff 05 b5 7c a7 01 48 3b 70 08 73 d7 eb 3d 0f 
[    7.470027] RIP  [<ffffffff88388fbf>] vmacache_find+0xaf/0x110
[    7.470027]  RSP <ffff88000ae49df8>
[    7.470027] CR2: ffff88000ae12000
[    7.470027] ---[ end trace 979b97a5e66af41a ]---
[    7.470027] BUG: sleeping function called from invalid context at kernel/locking/rwsem.c:20

> Thanks for the report.

You are welcome.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
