Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3FE16B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 03:02:23 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q12so7464321plk.16
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 00:02:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b64sor1724760pfm.56.2018.01.10.00.02.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 00:02:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a1144d6e854b3c90562668d74@google.com>
References: <001a1144d6e854b3c90562668d74@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 10 Jan 2018 09:02:00 +0100
Message-ID: <CACT4Y+bxZ+Y3i1Pe4J=7EhGL=cNQ3vBTc2uXfk4rdDTxnaOQRA@mail.gmail.com>
Subject: Re: possible deadlock in shmem_file_llseek
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, arve@android.com, tkjos@android.com, maco@android.com, devel@driverdev.osuosl.org
Cc: Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

On Wed, Jan 10, 2018 at 7:58 AM, syzbot
<syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com> wrote:
> Hello,
>
> syzkaller hit the following crash on
> d476c5334f1dee122534b29639f8d46a85ecbb9d
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers

I think this is drivers/staging/android/ashmem.c, +android maintainers.


> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for
> details.
> If you forward the report, please keep this part and the footer.
>
>
> ======================================================
> audit: type=1400 audit(1515535006.781:8): avc:  denied  { map } for
> pid=3497 comm="syzkaller303685" path="/dev/ashmem" dev="devtmpfs" ino=178
> scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=system_u:object_r:device_t:s0 tclass=chr_file permissive=1
> WARNING: possible circular locking dependency detected
> 4.15.0-rc7+ #255 Not tainted
> ------------------------------------------------------
> syzkaller303685/3497 is trying to acquire lock:
>  (&sb->s_type->i_mutex_key#11){++++}, at: [<000000006886b3fb>] inode_lock
> include/linux/fs.h:713 [inline]
>  (&sb->s_type->i_mutex_key#11){++++}, at: [<000000006886b3fb>]
> shmem_file_llseek+0xef/0x240 mm/shmem.c:2579
>
> but task is already holding lock:
>  (ashmem_mutex){+.+.}, at: [<00000000a44304a8>] ashmem_llseek+0x56/0x1f0
> drivers/staging/android/ashmem.c:334
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #2 (ashmem_mutex){+.+.}:
>        __mutex_lock_common kernel/locking/mutex.c:756 [inline]
>        __mutex_lock+0x16f/0x1a80 kernel/locking/mutex.c:893
>        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
>        ashmem_mmap+0x53/0x410 drivers/staging/android/ashmem.c:370
>        call_mmap include/linux/fs.h:1777 [inline]
>        mmap_region+0xa99/0x15a0 mm/mmap.c:1705
>        do_mmap+0x6c0/0xe00 mm/mmap.c:1483
>        do_mmap_pgoff include/linux/mm.h:2217 [inline]
>        vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>        SYSC_mmap_pgoff mm/mmap.c:1533 [inline]
>        SyS_mmap_pgoff+0x462/0x5f0 mm/mmap.c:1491
>        SYSC_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
>        SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:91
>        entry_SYSCALL_64_fastpath+0x23/0x9a
>
> -> #1 (&mm->mmap_sem){++++}:
>        __might_fault+0x13a/0x1d0 mm/memory.c:4529
>        _copy_to_user+0x2c/0xc0 lib/usercopy.c:25
>        copy_to_user include/linux/uaccess.h:155 [inline]
>        filldir+0x1a7/0x320 fs/readdir.c:196
>        dir_emit_dot include/linux/fs.h:3374 [inline]
>        dir_emit_dots include/linux/fs.h:3385 [inline]
>        dcache_readdir+0x12d/0x5e0 fs/libfs.c:192
>        iterate_dir+0x1ca/0x530 fs/readdir.c:51
>        SYSC_getdents fs/readdir.c:231 [inline]
>        SyS_getdents+0x225/0x450 fs/readdir.c:212
>        entry_SYSCALL_64_fastpath+0x23/0x9a
>
> -> #0 (&sb->s_type->i_mutex_key#11){++++}:
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3914
>        down_write+0x87/0x120 kernel/locking/rwsem.c:70
>        inode_lock include/linux/fs.h:713 [inline]
>        shmem_file_llseek+0xef/0x240 mm/shmem.c:2579
>        vfs_llseek+0xa2/0xd0 fs/read_write.c:300
>        ashmem_llseek+0xe7/0x1f0 drivers/staging/android/ashmem.c:346
>        vfs_llseek fs/read_write.c:300 [inline]
>        SYSC_lseek fs/read_write.c:313 [inline]
>        SyS_lseek+0xeb/0x170 fs/read_write.c:304
>        entry_SYSCALL_64_fastpath+0x23/0x9a
>
> other info that might help us debug this:
>
> Chain exists of:
>   &sb->s_type->i_mutex_key#11 --> &mm->mmap_sem --> ashmem_mutex
>
>  Possible unsafe locking scenario:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(ashmem_mutex);
>                                lock(&mm->mmap_sem);
>                                lock(ashmem_mutex);
>   lock(&sb->s_type->i_mutex_key#11);
>
>  *** DEADLOCK ***
>
> 1 lock held by syzkaller303685/3497:
>  #0:  (ashmem_mutex){+.+.}, at: [<00000000a44304a8>]
> ashmem_llseek+0x56/0x1f0 drivers/staging/android/ashmem.c:334
>
> stack backtrace:
> CPU: 0 PID: 3497 Comm: syzkaller303685 Not tainted 4.15.0-rc7+ #255
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:17 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:53
>  print_circular_bug.isra.37+0x2cd/0x2dc kernel/locking/lockdep.c:1218
>  check_prev_add kernel/locking/lockdep.c:1858 [inline]
>  check_prevs_add kernel/locking/lockdep.c:1971 [inline]
>  validate_chain kernel/locking/lockdep.c:2412 [inline]
>  __lock_acquire+0x30a8/0x3e00 kernel/locking/lockdep.c:3426
>  lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3914
>  down_write+0x87/0x120 kernel/locking/rwsem.c:70
>  inode_lock include/linux/fs.h:713 [inline]
>  shmem_file_llseek+0xef/0x240 mm/shmem.c:2579
>  vfs_llseek+0xa2/0xd0 fs/read_write.c:300
>  ashmem_llseek+0xe7/0x1f0 drivers/staging/android/ashmem.c:346
>  vfs_llseek fs/read_write.c:300 [inline]
>  SYSC_lseek fs/read_write.c:313 [inline]
>  SyS_lseek+0xeb/0x170 fs/read_write.c:304
>  entry_SYSCALL_64_fastpath+0x23/0x9a
> RIP: 0033:0x444aa9
> RSP: 002b:00007ffd2bec96f8 EFLAGS: 00000217 ORIG_RAX: 0000000000000008
> RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 0000000000444aa9
> RDX: 0000000000000003 RSI: fffffffffffffffc RDI: 0000000000000004
> RBP: 00000000
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
> https://groups.google.com/d/msgid/syzkaller-bugs/001a1144d6e854b3c90562668d74%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
