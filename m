Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC5266B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:20:59 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id q12so5252770plk.16
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:20:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor513568plk.42.2018.01.15.21.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 21:20:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1144593661efb50562d9624f@google.com>
References: <001a1144593661efb50562d9624f@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 16 Jan 2018 06:20:37 +0100
Message-ID: <CACT4Y+as7aok3Yr6t2-7RZP7o5RCK4eWvbysncxSwXeLT1Nxbg@mail.gmail.com>
Subject: Re: WARNING in __vm_enough_memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+cc298e15b6a571ba0c55@syzkaller.appspotmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, tkjos@android.com, maco@android.com, devel@driverdev.osuosl.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, syzkaller-bugs@googlegroups.com, Vlastimil Babka <vbabka@suse.cz>

On Tue, Jan 16, 2018 at 12:58 AM, syzbot
<syzbot+cc298e15b6a571ba0c55@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzkaller hit the following crash on
> 8418f88764046d0e8ca6a3c04a69a0e57189aa1e
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers


Most likely it is drivers/staging/android/ashmem.c which is guilty. So
+ashmem maintainers.


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+cc298e15b6a571ba0c55@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.
>
> audit: type=1400 audit(1515720420.441:8): avc:  denied  { sys_admin } for
> pid=3511 comm="syzkaller485245" capability=21
> scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023 tclass=cap_userns
> permissive=1
> audit: type=1400 audit(1515720420.495:9): avc:  denied  { sys_chroot } for
> pid=3512 comm="syzkaller485245" capability=18
> scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023 tclass=cap_userns
> permissive=1
> ------------[ cut here ]------------
> memory commitment underflow
> WARNING: CPU: 0 PID: 3512 at mm/util.c:606 __vm_enough_memory+0x5a6/0x810
> mm/util.c:604
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 0 PID: 3512 Comm: syzkaller485245 Not tainted 4.15.0-rc7-next-20180111+
> #94
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  panic+0x1e4/0x41c kernel/panic.c:183
>  __warn+0x1dc/0x200 kernel/panic.c:547
>  report_bug+0x211/0x2d0 lib/bug.c:184
>  fixup_bug.part.11+0x37/0x80 arch/x86/kernel/traps.c:178
>  fixup_bug arch/x86/kernel/traps.c:247 [inline]
>  do_error_trap+0x2d7/0x3e0 arch/x86/kernel/traps.c:296
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:315
>  invalid_op+0x22/0x40 arch/x86/entry/entry_64.S:1102
> RIP: 0010:__vm_enough_memory+0x5a6/0x810 mm/util.c:604
> RSP: 0018:ffff8801bfbaf8e0 EFLAGS: 00010282
> RAX: dffffc0000000008 RBX: 1ffff10037f75f21 RCX: ffffffff815a613e
> RDX: 0000000000000000 RSI: 1ffff10037e84d3b RDI: 0000000000000293
> RBP: ffff8801bfbafa90 R08: 1ffff10037f75eaf R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801bfbafa68
> R13: ffffffff869b8c80 R14: 0000000000000fff R15: dffffc0000000000
>  security_vm_enough_memory_mm+0x90/0xb0 security/security.c:327
>  mmap_region+0x321/0x15a0 mm/mmap.c:1666
>  do_mmap+0x73c/0xf70 mm/mmap.c:1494
>  do_mmap_pgoff include/linux/mm.h:2224 [inline]
>  vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>  SYSC_mmap_pgoff mm/mmap.c:1544 [inline]
>  SyS_mmap_pgoff+0x23b/0x5f0 mm/mmap.c:1502
>  SYSC_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
>  SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:91
>  entry_SYSCALL_64_fastpath+0x29/0xa0
> RIP: 0033:0x440ac9
> RSP: 002b:00000000007dff58 EFLAGS: 00000212 ORIG_RAX: 0000000000000009
> RAX: ffffffffffffffda RBX: ffffffffffffffff RCX: 0000000000440ac9
> RDX: 0000000000000003 RSI: 0000000000fff000 RDI: 0000000020000000
> RBP: 7fffffffffffffff R08: 00000000ffffffff R09: 0000000000000000
> R10: 0000000000000032 R11: 0000000000000212 R12: 6873612f7665642f
> R13: 6c616b7a79732f2e R14: 0000000000000000 R15: 0000000000000000
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> If you forgot to add the Reported-by tag, once the fix for this bug is
> merged
> into any tree, please reply to this email with:
> #syz fix: exact-commit-title
> If you want to test a patch for this bug, please reply with:
> #syz test: git://repo/address.git branch
> and provide the patch inline or as an attachment.
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
> https://groups.google.com/d/msgid/syzkaller-bugs/001a1144593661efb50562d9624f%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
