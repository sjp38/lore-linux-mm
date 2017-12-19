Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63D3A6B0268
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:17:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n187so14501544pfn.10
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:17:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n34sor5376285pld.24.2017.12.19.04.17.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 04:17:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1145ee7044b823055f705381@google.com>
References: <001a1145ee7044b823055f705381@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 13:17:37 +0100
Message-ID: <CACT4Y+ZOLYBxSSK=g=RHooe7AYhxpPyGA7fxmHaO3z5CL56H9Q@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel paging request in lock_release
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+3e48074b1463877e511f85af54e539b79d2ee258@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, James Morse <james.morse@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Lorenzo Stoakes <lstoakes@gmail.com>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Sun, Dec 3, 2017 at 3:22 PM, syzbot
<bot+3e48074b1463877e511f85af54e539b79d2ee258@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> fb20eb9d798d2f4c1a75b7fe981d72dfa8d7270d
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
>
> Unfortunately, I don't have any reproducer for this bug yet.
>
>
> device gre0 entered promiscuous mode
> netlink: 17 bytes leftover after parsing attributes in process
> `syz-executor1'.
> BUG: unable to handle kernel paging request at 00000000b787a3be
> IP: lock_release+0x195/0xda0 kernel/locking/lockdep.c:4021
> PGD 5e28067 P4D 5e28067 PUD 5e2a067 PMD 0
> Oops: 0002 [#1] SMP KASAN
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 1 PID: 24792 Comm: syz-executor7 Not tainted 4.15.0-rc1-next-20171201+
> #57
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> task: 00000000227b6d08 task.stack: 00000000c319d6d9
> RIP: 0010:lock_release+0x195/0xda0 kernel/locking/lockdep.c:4021
> RSP: 0018:ffff8801d84263b8 EFLAGS: 00010046
> RAX: 0000000000000007 RBX: 1ffff1003b084c7c RCX: ffffffff819988f5
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff8801c1910b04
> RBP: ffff8801d8426528 R08: 0000000000000003 R09: 0000000000000004
> R10: 0000000000000000 R11: ffffffff8748cd60 R12: ffff8801c1910280
> R13: ffff8801d8426500 R14: ffff8801d51a5df8 R15: ffff8801c1910280
> FS:  00007fe539a7e700(0000) GS:ffff8801db500000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: fffffffffffffff8 CR3: 00000001d9117000 CR4: 00000000001426e0
> Call Trace:
>  __raw_spin_unlock include/linux/spinlock_api_smp.h:150 [inline]
>  _raw_spin_unlock+0x1a/0x30 kernel/locking/spinlock.c:183
>  spin_unlock include/linux/spinlock.h:355 [inline]
>  follow_page_pte+0xa8a/0x1730 mm/gup.c:202
>  follow_pmd_mask mm/gup.c:271 [inline]
>  follow_pud_mask mm/gup.c:339 [inline]
>  follow_p4d_mask mm/gup.c:365 [inline]
>  follow_page_mask+0xb80/0x17f0 mm/gup.c:418
>  __get_user_pages+0x423/0x15f0 mm/gup.c:696
>  __get_user_pages_locked mm/gup.c:870 [inline]
>  get_user_pages+0x9a/0xc0 mm/gup.c:1092
>  get_user_page_nowait arch/x86/kvm/../../../virt/kvm/kvm_main.c:1325
> [inline]
>  hva_to_pfn_slow arch/x86/kvm/../../../virt/kvm/kvm_main.c:1386 [inline]
>  hva_to_pfn arch/x86/kvm/../../../virt/kvm/kvm_main.c:1503 [inline]
>  __gfn_to_pfn_memslot+0x3c2/0x10c0
> arch/x86/kvm/../../../virt/kvm/kvm_main.c:1559
>  try_async_pf+0x13b/0xc40 arch/x86/kvm/mmu.c:3801
>  tdp_page_fault+0x40a/0xa70 arch/x86/kvm/mmu.c:3897
>  kvm_mmu_page_fault+0x10d/0x2f0 arch/x86/kvm/mmu.c:4927
>  handle_ept_violation+0x198/0x550 arch/x86/kvm/vmx.c:6544
>  vmx_handle_exit+0x25d/0x1ce0 arch/x86/kvm/vmx.c:8893
>  vcpu_enter_guest arch/x86/kvm/x86.c:7084 [inline]
>  vcpu_run arch/x86/kvm/x86.c:7146 [inline]
>  kvm_arch_vcpu_ioctl_run+0x1cb4/0x5c60 arch/x86/kvm/x86.c:7314
>  kvm_vcpu_ioctl+0x64c/0x1010 arch/x86/kvm/../../../virt/kvm/kvm_main.c:2574
>  vfs_ioctl fs/ioctl.c:46 [inline]
>  do_vfs_ioctl+0x1b1/0x1530 fs/ioctl.c:686
>  SYSC_ioctl fs/ioctl.c:701 [inline]
>  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
>  entry_SYSCALL_64_fastpath+0x1f/0x96
> RIP: 0033:0x4529d9
> RSP: 002b:00007fe539a7dc58 EFLAGS: 00000212 ORIG_RAX: 0000000000000010
> RAX: ffffffffffffffda RBX: 0000000020a24000 RCX: 00000000004529d9
> RDX: 0000000000000000 RSI: 000000000000ae80 RDI: 0000000000000017
> RBP: 0000000020a24800 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000000019
> R13: 0000000020a23000 R14: 00007fe539a7e6d4 R15: 0000000000000000
> Code: 48 89 fa 48 c1 ea 03 0f b6 14 02 48 89 f8 83 e0 07 83 c0 03 38 d0 7c
> 08 84 d2 0f 85 c4 08 00 00 41 c7 87 84 08 00 00 01 00 00 00 <cc> 3f 05 00 00
> 65 8b 05 3f d7 aa 7e 89 c0 48 0f a3 05 c5 6c 08
> RIP: lock_release+0x195/0xda0 kernel/locking/lockdep.c:4021 RSP:
> ffff8801d84263b8
> CR2: fffffffffffffff8
> ---[ end trace 6fd2aef65db10860 ]---

#syz dup: BUG: unable to handle kernel paging request in __switch_to

> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
> Please credit me with: Reported-by: syzbot <syzkaller@googlegroups.com>
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
> Note: all commands must start from beginning of the line in the email body.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a1145ee7044b823055f705381%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
