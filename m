Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 848646B0003
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 08:58:17 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id v186-v6so8368996vkv.1
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 05:58:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d94-v6sor1193807uad.101.2018.06.11.05.58.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Jun 2018 05:58:16 -0700 (PDT)
MIME-Version: 1.0
References: <CAB+yDaY7jk1E4=iDO3_F_3di3-k1WA7cU8qGpJLzZjBoo-_73w@mail.gmail.com>
 <CACT4Y+YcaXt1ATjFfgEFEzHcXZP7FfgJnkJ8PxS2152f8RCe8w@mail.gmail.com>
In-Reply-To: <CACT4Y+YcaXt1ATjFfgEFEzHcXZP7FfgJnkJ8PxS2152f8RCe8w@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Mon, 11 Jun 2018 14:58:02 +0200
Message-ID: <CAG_fn=URhSOj9DScoP+bEJoy5GVn_9wQRuFGn2q1ZFD4sPjDZg@mail.gmail.com>
Subject: Re: KMSAN: kernel-infoleak in copyout lib/iov_iter.c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitriy Vyukov <dvyukov@google.com>
Cc: shankarapailoor@gmail.com, kasan-dev <kasan-dev@googlegroups.com>, mhocko@suse.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, jglisse@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, dan.j.williams@intel.com, ying.huang@intel.com, ross.zwisler@linux.intel.com, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>

On Mon, Jun 11, 2018 at 7:43 AM 'Dmitry Vyukov' via syzkaller
<syzkaller@googlegroups.com> wrote:
>
> On Sun, Jun 10, 2018 at 11:28 PM, shankarapailoor
> <shankarapailoor@gmail.com> wrote:
> > Hi,
> >
Hi Shankara,

> > I have been fuzzing Linux 4.17 with KMSAN
> > (https://github.com/google/kmsan/)  and I found the following crash:
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> > BUG: KMSAN: kernel-infoleak in copyout lib/iov_iter.c:140 [inline]
I couldn't reproduce the report on a KMSAN tree. Could you please
share your .config file?
I've seen similar reports on syzbot and think that the problem is in
KMSAN missing the initialization in copy_user_page()
The speculative fix is here:
https://github.com/google/kmsan/commit/5cdf0501ac1bdc9ba2844d17b2665c7881cb=
2ac7,
could you please try that out?

Overall, it's usually unlikely that there're big infoleaks in trivial
places like a plain process_vm_readv() call.
Because KMSAN is still in development, it's better to validate the
reports manually by e.g. filling the suspect memory with some constant
and printing its contents in the reproducer.

> > BUG: KMSAN: kernel-infoleak in copy_page_to_iter_iovec
> > lib/iov_iter.c:212 [inline]
> > BUG: KMSAN: kernel-infoleak in copy_page_to_iter+0x754/0x1b70 lib/iov_i=
ter.c:716
> >  CPU: 2 PID: 21280 Comm: syz-executor3 Not tainted 4.17.0+ #4 Hardware
> > name: Google Google Compute Engine/Google Compute Engine, BIOS Google
> > 01/01/2011
> > Call Trace:
> > __dump_stack lib/dump_stack.c:77 [inline]
> > dump_stack+0x185/0x1d0 lib/dump_stack.c:113 kmsan_report+0x188/0x2a0
> > mm/kmsan/kmsan.c:1117 kmsan_internal_check_memory+0x17e/0x1f0
> > mm/kmsan/kmsan.c:1230 kmsan_copy_to_user+0x7a/0x160
> > mm/kmsan/kmsan.c:1253 copyout lib/iov_iter.c:140 [inline]
> > copy_page_to_iter_iovec lib/iov_iter.c:212 [inline]
> > copy_page_to_iter+0x754/0x1b70 lib/iov_iter.c:716 process_vm_rw_pages
> > mm/process_vm_access.c:53 [inline] process_vm_rw_single_vec
> > mm/process_vm_access.c:124 [inline] process_vm_rw_core+0xf6a/0x1930
> > mm/process_vm_access.c:220 process_vm_rw+0x3d0/0x500
> > mm/process_vm_access.c:288 __do_sys_process_vm_readv
> > mm/process_vm_access.c:302 [inline] __se_sys_process_vm_readv
> > mm/process_vm_access.c:298 [inline]
> > __x64_sys_process_vm_readv+0x1a0/0x200 mm/process_vm_access.c:298
> > do_syscall_64+0x15b/0x230 arch/x86/entry/common.c:287
> > entry_SYSCALL_64_after_hwframe+0x44/0xa9RIP: 0033:0x455a09RSP:
> > 002b:00007f621260ec68 EFLAGS: 00000246 ORIG_RAX: 0000000000000136RAX:
> > ffffffffffffffda RBX: 00007f621260f6d4 RCX: 0000000000455a09RDX:
> > 0000000000000007 RSI: 0000000020001b00 RDI: 000000000000070aRBP:
> > 000000000072bea0 R08: 0000000000000001 R09: 0000000000000000R10:
> > 0000000020001c80 R11: 0000000000000246 R12: 00000000ffffffffR13:
> > 0000000000000524 R14: 00000000006fbc00 R15: 0000000000000000
> >
> > Uninit was created at: kmsan_save_stack_with_flags
> > mm/kmsan/kmsan.c:279 [inline] kmsan_alloc_meta_for_pages+0x161/0x3a0
> > mm/kmsan/kmsan.c:815 kmsan_alloc_page+0x82/0xe0 mm/kmsan/kmsan.c:885
> > __alloc_pages_nodemask+0xe02/0x5c80 mm/page_alloc.c:4402 __alloc_pages
> > include/linux/gfp.h:458 [inline] __alloc_pages_node
> > include/linux/gfp.h:471 [inline]
> > alloc_pages_vma+0x1555/0x17f0 mm/mempolicy.c:2049
> > do_huge_pmd_wp_page+0x3026/0x4f50 mm/huge_memory.c:1296 wp_huge_pmd
> > mm/memory.c:3866 [inline]
> > __handle_mm_fault mm/memory.c:4079 [inline]
> > handle_mm_fault+0x22aa/0x7c40 mm/memory.c:4126
>
> /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
>
> User pages must be initialized. Alex, do we handle clear_huge_page alread=
y?
>
>
> > __do_page_fault+0xec6/0x1a10 arch/x86/mm/fault.c:1400
> > do_page_fault+0xb7/0x250 arch/x86/mm/fault.c:1477 page_fault+0x1e/0x30
> > arch/x86/entry/entry_64.S:1160
> > Bytes 0-204 of 205 are uninitialized
> > Memory access starts at ffff880029601b80
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > I am able to reliably reproduce the crash using ./syz-repro on the
> > following program:
> >
> > r0 =3D gettid()
> > process_vm_readv(r0, &(0x7f0000001b00)=3D[{&(0x7f00000006c0)=3D""/221,
> > 0xdd}, {&(0x7f00000007c0)=3D""/248, 0xf8}, {&(0x7f00000008c0)=3D""/254,
> > 0xfe}, {&(0x7f00000009c0)=3D""/4096, 0x1000}, {&(0x7f00000019c0)},
> > {&(0x7f0000001a00)=3D""/184, 0xb8}, {&(0x7f0000001ac0)=3D""/26, 0x1a}],
> > 0x7, &(0x7f0000001c80)=3D[{&(0x7f0000001b80)=3D""/205, 0xcd}], 0x1, 0x0=
)
> > r1 =3D socket$inet(0x2, 0x1, 0x0)
> > fcntl$setown(r1, 0x8, 0xffffffffffffffff)
> > fcntl$getownex(r1, 0x10, &(0x7f00000000c0)=3D{0x0,<r2=3D>0x0})
> > process_vm_writev(r2, &(0x7f0000000080)=3D[{&(0x7f0000000000)=3D""/99,
I've seen similar reports from process_vm_readv() on Friday (
> > 0x63}], 0x1, &(0x7f00000003c0)=3D[{&(0x7f0000000100)=3D""/157, 0x9d},
> > {&(0x7f00000001c0)=3D""/22, 0x16}, {&(0x7f0000000200)=3D""/137, 0x89},
> > {&(0x7f00000002c0)=3D""/51, 0x33}, {&(0x7f0000000300)=3D""/134, 0x86}],
> > 0x5, 0x0)
> >
> > Here is a C program that can (inconsistently) trigger the crash:
> > https://pastebin.com/pRBptS9X
> > My kernel configs are here: https://pastebin.com/KGjTG2Yd
> > Log context around crash: https://pastebin.com/f5BsDUpV
> >
> >
> > Regards,
> > Shankara Pailoor
> >
> > --
> > You received this message because you are subscribed to the Google Grou=
ps "syzkaller" group.
> > To unsubscribe from this group and stop receiving emails from it, send =
an email to syzkaller+unsubscribe@googlegroups.com.
> > For more options, visit https://groups.google.com/d/optout.
>
> --
> You received this message because you are subscribed to the Google Groups=
 "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.



--
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg
