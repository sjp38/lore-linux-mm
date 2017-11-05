Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 71CDA6B0253
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 05:39:55 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 134so18709900ioo.22
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 02:39:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e189sor5083082ioe.155.2017.11.05.02.39.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 02:39:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <94eb2c05f6a018dc21055d39c05b@google.com>
References: <94eb2c05f6a018dc21055d39c05b@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Sun, 5 Nov 2017 13:39:32 +0300
Message-ID: <CACT4Y+aOa8e48zEU=yqtnva73WpbiNzRXR7Qb82h6GfqemovPA@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Al Viro <viro@zeniv.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org

On Sun, Nov 5, 2017 at 1:25 PM, syzbot
<bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 7a95bdb092c66b6473aa2fc848862ae557ab08f7
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>
> ======================================================
> WARNING: possible circular locking dependency detected
> 4.13.0+ #84 Not tainted
> ------------------------------------------------------
> loop0/2986 is trying to acquire lock:
>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>] inode_lock
> include/linux/fs.h:712 [inline]
>  (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff8186f9ec>]
> generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3151
>
> but now in release context of a crosslock acquired at the following:
>  ((complete)&ret.event){+.+.}, at: [<ffffffff822a055e>]
> submit_bio_wait+0x15e/0x200 block/bio.c:953
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #4 ((complete)&ret.event){+.+.}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        complete_acquire include/linux/completion.h:39 [inline]
>        __wait_for_common kernel/sched/completion.c:108 [inline]
>        wait_for_common_io kernel/sched/completion.c:128 [inline]
>        wait_for_completion_io+0xc8/0x770 kernel/sched/completion.c:176
>        submit_bio_wait+0x15e/0x200 block/bio.c:953
>        blkdev_issue_zeroout+0x13c/0x1d0 block/blk-lib.c:370
>        sb_issue_zeroout include/linux/blkdev.h:1367 [inline]
>        ext4_init_inode_table+0x4fd/0xdb1 fs/ext4/ialloc.c:1447
>        ext4_run_li_request fs/ext4/super.c:2867 [inline]
>        ext4_lazyinit_thread+0x81a/0xd40 fs/ext4/super.c:2961
>        kthread+0x39c/0x470 kernel/kthread.c:231
>        ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431
>
> -> #3 (&meta_group_info[i]->alloc_sem){++++}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        down_read+0x96/0x150 kernel/locking/rwsem.c:23
>        __ext4_new_inode+0x26dc/0x4f00 fs/ext4/ialloc.c:1056
>        ext4_symlink+0x2d9/0xae0 fs/ext4/namei.c:3118
>        vfs_symlink+0x323/0x560 fs/namei.c:4116
>        SYSC_symlinkat fs/namei.c:4143 [inline]
>        SyS_symlinkat fs/namei.c:4123 [inline]
>        SYSC_symlink fs/namei.c:4156 [inline]
>        SyS_symlink+0x134/0x200 fs/namei.c:4154
>        entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> -> #2 (jbd2_handle){.+.+}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        start_this_handle+0x4b8/0x1080 fs/jbd2/transaction.c:390
>        jbd2__journal_start+0x389/0x9f0 fs/jbd2/transaction.c:444
>        __ext4_journal_start_sb+0x15f/0x550 fs/ext4/ext4_jbd2.c:80
>        __ext4_journal_start fs/ext4/ext4_jbd2.h:314 [inline]
>        ext4_dirty_inode+0x56/0xa0 fs/ext4/inode.c:5859
>        __mark_inode_dirty+0x912/0x1170 fs/fs-writeback.c:2096
>        generic_update_time+0x1b2/0x270 fs/inode.c:1649
>        update_time fs/inode.c:1665 [inline]
>        touch_atime+0x26d/0x2f0 fs/inode.c:1737
>        file_accessed include/linux/fs.h:2036 [inline]
>        ext4_file_mmap+0x161/0x1b0 fs/ext4/file.c:350
>        call_mmap include/linux/fs.h:1748 [inline]
>        mmap_region+0xa99/0x15a0 mm/mmap.c:1690
>        do_mmap+0x6a1/0xd50 mm/mmap.c:1468
>        do_mmap_pgoff include/linux/mm.h:2150 [inline]
>        vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
>        SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
>        SyS_mmap_pgoff+0x462/0x5f0 mm/mmap.c:1476
>        SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
>        SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
>        entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> -> #1 (&mm->mmap_sem){++++}:
>        check_prevs_add kernel/locking/lockdep.c:2020 [inline]
>        validate_chain kernel/locking/lockdep.c:2469 [inline]
>        __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
>        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
>        __might_fault+0x13a/0x1d0 mm/memory.c:4502
>        _copy_to_user+0x2c/0xc0 lib/usercopy.c:24
>        copy_to_user include/linux/uaccess.h:154 [inline]
>        filldir+0x1a7/0x320 fs/readdir.c:196
>        dir_emit_dot include/linux/fs.h:3314 [inline]
>        dir_emit_dots include/linux/fs.h:3325 [inline]
>        dcache_readdir+0x12d/0x5e0 fs/libfs.c:192
>        iterate_dir+0x4b2/0x5d0 fs/readdir.c:51
>        SYSC_getdents fs/readdir.c:231 [inline]
>        SyS_getdents+0x225/0x450 fs/readdir.c:212
>        entry_SYSCALL_64_fastpath+0x1f/0xbe
>
> -> #0 (&sb->s_type->i_mutex_key#9){++++}:
>        down_write+0x87/0x120 kernel/locking/rwsem.c:53
>        inode_lock include/linux/fs.h:712 [inline]
>        generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3151
>        call_write_iter include/linux/fs.h:1743 [inline]
>        do_iter_readv_writev+0x531/0x7f0 fs/read_write.c:650
>        do_iter_write+0x15a/0x540 fs/read_write.c:929
>        vfs_iter_write+0x77/0xb0 fs/read_write.c:942
>
> other info that might help us debug this:
>
> Chain exists of:
>   &sb->s_type->i_mutex_key#9 --> &meta_group_info[i]->alloc_sem -->
> (complete)&ret.event
>
>  Possible unsafe locking scenario by crosslock:
>
>        CPU0                    CPU1
>        ----                    ----
>   lock(&meta_group_info[i]->alloc_sem);
>   lock((complete)&ret.event);
>                                lock(&sb->s_type->i_mutex_key#9);
>                                unlock((complete)&ret.event);
>
>  *** DEADLOCK ***
>
> 1 lock held by loop0/2986:
>  #0:  (&x->wait#14){..-.}, at: [<ffffffff815263f8>] complete+0x18/0x80
> kernel/sched/completion.c:34
>
> stack backtrace:
> CPU: 1 PID: 2986 Comm: loop0 Not tainted 4.13.0+ #84
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  print_circular_bug+0x503/0x710 kernel/locking/lockdep.c:1259
>  check_prev_add+0x865/0x1520 kernel/locking/lockdep.c:1894
>  commit_xhlock kernel/locking/lockdep.c:5015 [inline]
>  commit_xhlocks kernel/locking/lockdep.c:5059 [inline]
>  lock_commit_crosslock+0xe73/0x1d10 kernel/locking/lockdep.c:5098
>  complete_release_commit include/linux/completion.h:49 [inline]
>  complete+0x24/0x80 kernel/sched/completion.c:39
>  submit_bio_wait_endio+0x9c/0xd0 block/bio.c:930
>  bio_endio+0x2f8/0x8d0 block/bio.c:1843
>  req_bio_endio block/blk-core.c:204 [inline]
>  blk_update_request+0x2a6/0xe20 block/blk-core.c:2743
>  blk_mq_end_request+0x54/0x120 block/blk-mq.c:509
>  lo_complete_rq+0xbe/0x1f0 drivers/block/loop.c:463
>  __blk_mq_complete_request+0x38f/0x6c0 block/blk-mq.c:550
>  blk_mq_complete_request+0x4f/0x60 block/blk-mq.c:570
>  loop_handle_cmd drivers/block/loop.c:1710 [inline]
>  loop_queue_work+0x26b/0x3900 drivers/block/loop.c:1719
>  kthread_worker_fn+0x340/0x9b0 kernel/kthread.c:635


This also happens on more recent commits. E.g. on upstream
42b76d0e6b1fe0fcb90e0ff6b4d053d50597b031:

======================================================
WARNING: possible circular locking dependency detected
4.14.0-rc3+ #116 Not tainted
------------------------------------------------------
loop6/10331 is trying to acquire lock:
 (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818756bc>]
inode_lock include/linux/fs.h:712 [inline]
 (&sb->s_type->i_mutex_key#9){++++}, at: [<ffffffff818756bc>]
generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3175

but now in release context of a crosslock acquired at the following:
 ((complete)&ret.event){+.+.}, at: [<ffffffff822ac9fe>]
submit_bio_wait+0x15e/0x200 block/bio.c:953

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #4 ((complete)&ret.event){+.+.}:
       check_prevs_add kernel/locking/lockdep.c:2020 [inline]
       validate_chain kernel/locking/lockdep.c:2469 [inline]
       __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
       lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
       complete_acquire include/linux/completion.h:39 [inline]
       __wait_for_common kernel/sched/completion.c:108 [inline]
       wait_for_common_io kernel/sched/completion.c:128 [inline]
       wait_for_completion_io+0xcb/0x7b0 kernel/sched/completion.c:176
       submit_bio_wait+0x15e/0x200 block/bio.c:953
       blkdev_issue_zeroout+0x13c/0x1d0 block/blk-lib.c:370
       sb_issue_zeroout include/linux/blkdev.h:1368 [inline]
       ext4_init_inode_table+0x4fd/0xdb1 fs/ext4/ialloc.c:1447
       ext4_run_li_request fs/ext4/super.c:2866 [inline]
       ext4_lazyinit_thread+0x808/0xd30 fs/ext4/super.c:2960
       kthread+0x39c/0x470 kernel/kthread.c:231
       ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431

-> #3 (&meta_group_info[i]->alloc_sem){++++}:
       check_prevs_add kernel/locking/lockdep.c:2020 [inline]
       validate_chain kernel/locking/lockdep.c:2469 [inline]
       __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
       lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
       down_read+0x96/0x150 kernel/locking/rwsem.c:23
       __ext4_new_inode+0x26dc/0x4f00 fs/ext4/ialloc.c:1056
       ext4_symlink+0x2d9/0xae0 fs/ext4/namei.c:3118
       vfs_symlink+0x323/0x560 fs/namei.c:4115
       SYSC_symlinkat fs/namei.c:4142 [inline]
       SyS_symlinkat fs/namei.c:4122 [inline]
       SYSC_symlink fs/namei.c:4155 [inline]
       SyS_symlink+0x134/0x200 fs/namei.c:4153
       entry_SYSCALL_64_fastpath+0x1f/0xbe

-> #2 (jbd2_handle){++++}:
       check_prevs_add kernel/locking/lockdep.c:2020 [inline]
       validate_chain kernel/locking/lockdep.c:2469 [inline]
       __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
       lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
       start_this_handle+0x4b8/0x1080 fs/jbd2/transaction.c:390
       jbd2__journal_start+0x389/0x9f0 fs/jbd2/transaction.c:444
       __ext4_journal_start_sb+0x15f/0x550 fs/ext4/ext4_jbd2.c:80
       __ext4_journal_start fs/ext4/ext4_jbd2.h:314 [inline]
       ext4_dirty_inode+0x56/0xa0 fs/ext4/inode.c:5859
       __mark_inode_dirty+0x912/0x1170 fs/fs-writeback.c:2096
       generic_update_time+0x1b2/0x270 fs/inode.c:1649
       update_time fs/inode.c:1665 [inline]
       touch_atime+0x26d/0x2f0 fs/inode.c:1737
       file_accessed include/linux/fs.h:2061 [inline]
       ext4_file_mmap+0x161/0x1b0 fs/ext4/file.c:352
       call_mmap include/linux/fs.h:1775 [inline]
       mmap_region+0xa99/0x15a0 mm/mmap.c:1690
       do_mmap+0x6a1/0xd50 mm/mmap.c:1468
       do_mmap_pgoff include/linux/mm.h:2150 [inline]
       vm_mmap_pgoff+0x1de/0x280 mm/util.c:333
       SYSC_mmap_pgoff mm/mmap.c:1518 [inline]
       SyS_mmap_pgoff+0x462/0x5f0 mm/mmap.c:1476
       SYSC_mmap arch/x86/kernel/sys_x86_64.c:99 [inline]
       SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:90
       entry_SYSCALL_64_fastpath+0x1f/0xbe

-> #1 (&mm->mmap_sem){++++}:
       check_prevs_add kernel/locking/lockdep.c:2020 [inline]
       validate_chain kernel/locking/lockdep.c:2469 [inline]
       __lock_acquire+0x328f/0x4620 kernel/locking/lockdep.c:3498
       lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:4002
       __might_fault+0x13a/0x1d0 mm/memory.c:4502
       _copy_to_user+0x2c/0xc0 lib/usercopy.c:24
       copy_to_user include/linux/uaccess.h:154 [inline]
       filldir+0x1a7/0x320 fs/readdir.c:196
       dir_emit_dot include/linux/fs.h:3339 [inline]
       dir_emit_dots include/linux/fs.h:3350 [inline]
       dcache_readdir+0x12d/0x5e0 fs/libfs.c:192
       iterate_dir+0x4b2/0x5d0 fs/readdir.c:51
       SYSC_getdents fs/readdir.c:231 [inline]
       SyS_getdents+0x225/0x450 fs/readdir.c:212
       entry_SYSCALL_64_fastpath+0x1f/0xbe

-> #0 (&sb->s_type->i_mutex_key#9){++++}:
       down_write+0x87/0x120 kernel/locking/rwsem.c:53
       inode_lock include/linux/fs.h:712 [inline]
       generic_file_write_iter+0xdc/0x7a0 mm/filemap.c:3175
       call_write_iter include/linux/fs.h:1770 [inline]
       do_iter_readv_writev+0x531/0x7f0 fs/read_write.c:673
       do_iter_write+0x15a/0x540 fs/read_write.c:952
       vfs_iter_write+0x77/0xb0 fs/read_write.c:965



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
> Note: all commands must start from beginning of the line.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/94eb2c05f6a018dc21055d39c05b%40google.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
