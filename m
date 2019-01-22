Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A37C78E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 13:50:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so65937qkb.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:50:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 130sor28132465qkl.33.2019.01.22.10.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 10:49:59 -0800 (PST)
Date: Tue, 22 Jan 2019 13:49:56 -0500
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: possible deadlock in shmem_fallocate (2)
Message-ID: <20190122184956.GA258314@google.com>
References: <0000000000004024240573137822@google.com>
 <20180810161848.GB16533@bombadil.infradead.org>
 <CACT4Y+bEsav4r82z5rE1b0rH==VpU7FEK7DzuqTu3AV+w0Ve9g@mail.gmail.com>
 <20190122153414.GB191275@google.com>
 <CACT4Y+ZP9VOjJc3U0d2iNWc_dCC=hQtK+dGYv-Z9=0cGoMmAyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZP9VOjJc3U0d2iNWc_dCC=hQtK+dGYv-Z9=0cGoMmAyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, syzbot <syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yisheng Xie <xieyisheng1@huawei.com>, Todd Kjos <tkjos@google.com>, Arve Hjonnevag <arve@android.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue, Jan 22, 2019 at 04:40:57PM +0100, Dmitry Vyukov wrote:
> On Tue, Jan 22, 2019 at 4:34 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > On Tue, Jan 22, 2019 at 02:59:29PM +0100, Dmitry Vyukov wrote:
> > > On Fri, Aug 10, 2018 at 6:18 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > >
> > > >
> > > > This is another ashmem lockdep splat.  Forwarding to the appropriate ashmem
> > > > people.
> > >
> > >
> > > Let's test Tetsuo's patch
> > >
> > > #syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> > > master
> >
> > Just to clarify, the following patch only went in, in September:
> > mm: shmem.c: Correctly annotate new inodes for lockdep
> 
> Is it supposed to fix this bug? This bug still happens: last time 5 hours ago:
> 
> https://syzkaller.appspot.com/bug?extid=4b8b031b89e6b96c4b2e

Ok, thanks for confirming. It looks like there is more than one issue causing
the same splat. It fixes one subset of the issues.

Tetsuo's patch will fix it for sure though, lets discuss that on the other
thread. Thanks,

 - Joel


> > thanks,
> >
> >  - Joel
> >
> >
> > > > On Fri, Aug 10, 2018 at 04:59:02AM -0700, syzbot wrote:
> > > > > Hello,
> > > > >
> > > > > syzbot found the following crash on:
> > > > >
> > > > > HEAD commit:    4110b42356f3 Add linux-next specific files for 20180810
> > > > > git tree:       linux-next
> > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=1411d6e2400000
> > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=1d80606e3795a4f5
> > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=4b8b031b89e6b96c4b2e
> > > > > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > > > > syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=175052f8400000
> > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11873622400000
> > > > >
> > > > > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > > > > Reported-by: syzbot+4b8b031b89e6b96c4b2e@syzkaller.appspotmail.com
> > > > >
> > > > > random: sshd: uninitialized urandom read (32 bytes read)
> > > > > random: sshd: uninitialized urandom read (32 bytes read)
> > > > > random: sshd: uninitialized urandom read (32 bytes read)
> > > > >
> > > > > ======================================================
> > > > > WARNING: possible circular locking dependency detected
> > > > > 4.18.0-rc8-next-20180810+ #36 Not tainted
> > > > > ------------------------------------------------------
> > > > > syz-executor900/4483 is trying to acquire lock:
> > > > > 00000000d2bfc8fe (&sb->s_type->i_mutex_key#9){++++}, at: inode_lock
> > > > > include/linux/fs.h:765 [inline]
> > > > > 00000000d2bfc8fe (&sb->s_type->i_mutex_key#9){++++}, at:
> > > > > shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> > > > >
> > > > > but task is already holding lock:
> > > > > 0000000025208078 (ashmem_mutex){+.+.}, at: ashmem_shrink_scan+0xb4/0x630
> > > > > drivers/staging/android/ashmem.c:448
> > > > >
> > > > > which lock already depends on the new lock.
> > > > >
> > > > >
> > > > > the existing dependency chain (in reverse order) is:
> > > > >
> > > > > -> #2 (ashmem_mutex){+.+.}:
> > > > >        __mutex_lock_common kernel/locking/mutex.c:925 [inline]
> > > > >        __mutex_lock+0x171/0x1700 kernel/locking/mutex.c:1073
> > > > >        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:1088
> > > > >        ashmem_mmap+0x55/0x520 drivers/staging/android/ashmem.c:361
> > > > >        call_mmap include/linux/fs.h:1844 [inline]
> > > > >        mmap_region+0xf27/0x1c50 mm/mmap.c:1762
> > > > >        do_mmap+0xa10/0x1220 mm/mmap.c:1535
> > > > >        do_mmap_pgoff include/linux/mm.h:2298 [inline]
> > > > >        vm_mmap_pgoff+0x213/0x2c0 mm/util.c:357
> > > > >        ksys_mmap_pgoff+0x4da/0x660 mm/mmap.c:1585
> > > > >        __do_sys_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
> > > > >        __se_sys_mmap arch/x86/kernel/sys_x86_64.c:91 [inline]
> > > > >        __x64_sys_mmap+0xe9/0x1b0 arch/x86/kernel/sys_x86_64.c:91
> > > > >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> > > > >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > >
> > > > > -> #1 (&mm->mmap_sem){++++}:
> > > > >        __might_fault+0x155/0x1e0 mm/memory.c:4568
> > > > >        _copy_to_user+0x30/0x110 lib/usercopy.c:25
> > > > >        copy_to_user include/linux/uaccess.h:155 [inline]
> > > > >        filldir+0x1ea/0x3a0 fs/readdir.c:196
> > > > >        dir_emit_dot include/linux/fs.h:3464 [inline]
> > > > >        dir_emit_dots include/linux/fs.h:3475 [inline]
> > > > >        dcache_readdir+0x13a/0x620 fs/libfs.c:193
> > > > >        iterate_dir+0x48b/0x5d0 fs/readdir.c:51
> > > > >        __do_sys_getdents fs/readdir.c:231 [inline]
> > > > >        __se_sys_getdents fs/readdir.c:212 [inline]
> > > > >        __x64_sys_getdents+0x29f/0x510 fs/readdir.c:212
> > > > >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> > > > >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > >
> > > > > -> #0 (&sb->s_type->i_mutex_key#9){++++}:
> > > > >        lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
> > > > >        down_write+0x8f/0x130 kernel/locking/rwsem.c:70
> > > > >        inode_lock include/linux/fs.h:765 [inline]
> > > > >        shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> > > > >        ashmem_shrink_scan+0x236/0x630 drivers/staging/android/ashmem.c:455
> > > > >        ashmem_ioctl+0x3ae/0x13a0 drivers/staging/android/ashmem.c:797
> > > > >        vfs_ioctl fs/ioctl.c:46 [inline]
> > > > >        file_ioctl fs/ioctl.c:501 [inline]
> > > > >        do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
> > > > >        ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
> > > > >        __do_sys_ioctl fs/ioctl.c:709 [inline]
> > > > >        __se_sys_ioctl fs/ioctl.c:707 [inline]
> > > > >        __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
> > > > >        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> > > > >        entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > >
> > > > > other info that might help us debug this:
> > > > >
> > > > > Chain exists of:
> > > > >   &sb->s_type->i_mutex_key#9 --> &mm->mmap_sem --> ashmem_mutex
> > > > >
> > > > >  Possible unsafe locking scenario:
> > > > >
> > > > >        CPU0                    CPU1
> > > > >        ----                    ----
> > > > >   lock(ashmem_mutex);
> > > > >                                lock(&mm->mmap_sem);
> > > > >                                lock(ashmem_mutex);
> > > > >   lock(&sb->s_type->i_mutex_key#9);
> > > > >
> > > > >  *** DEADLOCK ***
> > > > >
> > > > > 1 lock held by syz-executor900/4483:
> > > > >  #0: 0000000025208078 (ashmem_mutex){+.+.}, at:
> > > > > ashmem_shrink_scan+0xb4/0x630 drivers/staging/android/ashmem.c:448
> > > > >
> > > > > stack backtrace:
> > > > > CPU: 1 PID: 4483 Comm: syz-executor900 Not tainted 4.18.0-rc8-next-20180810+
> > > > > #36
> > > > > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > > > > Google 01/01/2011
> > > > > Call Trace:
> > > > >  __dump_stack lib/dump_stack.c:77 [inline]
> > > > >  dump_stack+0x1c9/0x2b4 lib/dump_stack.c:113
> > > > >  print_circular_bug.isra.37.cold.58+0x1bd/0x27d
> > > > > kernel/locking/lockdep.c:1227
> > > > >  check_prev_add kernel/locking/lockdep.c:1867 [inline]
> > > > >  check_prevs_add kernel/locking/lockdep.c:1980 [inline]
> > > > >  validate_chain kernel/locking/lockdep.c:2421 [inline]
> > > > >  __lock_acquire+0x3449/0x5020 kernel/locking/lockdep.c:3435
> > > > >  lock_acquire+0x1e4/0x540 kernel/locking/lockdep.c:3924
> > > > >  down_write+0x8f/0x130 kernel/locking/rwsem.c:70
> > > > >  inode_lock include/linux/fs.h:765 [inline]
> > > > >  shmem_fallocate+0x18b/0x12e0 mm/shmem.c:2602
> > > > >  ashmem_shrink_scan+0x236/0x630 drivers/staging/android/ashmem.c:455
> > > > >  ashmem_ioctl+0x3ae/0x13a0 drivers/staging/android/ashmem.c:797
> > > > >  vfs_ioctl fs/ioctl.c:46 [inline]
> > > > >  file_ioctl fs/ioctl.c:501 [inline]
> > > > >  do_vfs_ioctl+0x1de/0x1720 fs/ioctl.c:685
> > > > >  ksys_ioctl+0xa9/0xd0 fs/ioctl.c:702
> > > > >  __do_sys_ioctl fs/ioctl.c:709 [inline]
> > > > >  __se_sys_ioctl fs/ioctl.c:707 [inline]
> > > > >  __x64_sys_ioctl+0x73/0xb0 fs/ioctl.c:707
> > > > >  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
> > > > >  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> > > > > RIP: 0033:0x440099
> > > > > Code: 18 89 d0 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 00 48 89 f8 48 89 f7
> > > > > 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff
> > > > > 0f 83 fb 13 fc ff c3 66 2e 0f 1f 84 00 00 00 00
> > > > > RSP: 002b:00007fff3613dbf8 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
> > > > > RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 0000000000440099
> > > > > RDX: 00000
> > > > >
> > > > >
> > > > > ---
> > > > > This bug is generated by a bot. It may contain errors.
> > > > > See https://goo.gl/tpsmEJ for more information about syzbot.
> > > > > syzbot engineers can be reached at syzkaller@googlegroups.com.
> > > > >
> > > > > syzbot will keep track of this bug report. See:
> > > > > https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> > > > > syzbot.
> > > > > syzbot can test patches for this bug, for details see:
> > > > > https://goo.gl/tpsmEJ#testing-patches
> > > > >
> > > >
> > > > --
> > > > You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> > > > To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> > > > To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/20180810161848.GB16533%40bombadil.infradead.org.
> > > > For more options, visit https://groups.google.com/d/optout.
> >
> > > diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
> > > index 90a8a9f1ac7d..1a890c43a10a 100644
> > > --- a/drivers/staging/android/ashmem.c
> > > +++ b/drivers/staging/android/ashmem.c
> > > @@ -75,6 +75,17 @@ struct ashmem_range {
> > >  /* LRU list of unpinned pages, protected by ashmem_mutex */
> > >  static LIST_HEAD(ashmem_lru_list);
> > >
> > > +static struct workqueue_struct *ashmem_wq;
> > > +static atomic_t ashmem_shrink_inflight = ATOMIC_INIT(0);
> > > +static DECLARE_WAIT_QUEUE_HEAD(ashmem_shrink_wait);
> > > +
> > > +struct ashmem_shrink_work {
> > > +     struct work_struct work;
> > > +     struct file *file;
> > > +     loff_t start;
> > > +     loff_t end;
> > > +};
> > > +
> > >  /*
> > >   * long lru_count - The count of pages on our LRU list.
> > >   *
> > > @@ -292,6 +303,7 @@ static ssize_t ashmem_read_iter(struct kiocb *iocb, struct iov_iter *iter)
> > >       int ret = 0;
> > >
> > >       mutex_lock(&ashmem_mutex);
> > > +     wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
> > >
> > >       /* If size is not set, or set to 0, always return EOF. */
> > >       if (asma->size == 0)
> > > @@ -359,6 +371,7 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
> > >       int ret = 0;
> > >
> > >       mutex_lock(&ashmem_mutex);
> > > +     wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
> > >
> > >       /* user needs to SET_SIZE before mapping */
> > >       if (!asma->size) {
> > > @@ -421,6 +434,19 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
> > >       return ret;
> > >  }
> > >
> > > +static void ashmem_shrink_worker(struct work_struct *work)
> > > +{
> > > +     struct ashmem_shrink_work *w = container_of(work, typeof(*w), work);
> > > +
> > > +     w->file->f_op->fallocate(w->file,
> > > +                              FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > > +                              w->start, w->end - w->start);
> > > +     fput(w->file);
> > > +     kfree(w);
> > > +     if (atomic_dec_and_test(&ashmem_shrink_inflight))
> > > +             wake_up_all(&ashmem_shrink_wait);
> > > +}
> > > +
> > >  /*
> > >   * ashmem_shrink - our cache shrinker, called from mm/vmscan.c
> > >   *
> > > @@ -449,12 +475,18 @@ ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
> > >               return -1;
> > >
> > >       list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
> > > -             loff_t start = range->pgstart * PAGE_SIZE;
> > > -             loff_t end = (range->pgend + 1) * PAGE_SIZE;
> > > +             struct ashmem_shrink_work *w = kzalloc(sizeof(*w), GFP_ATOMIC);
> > > +
> > > +             if (!w)
> > > +                     break;
> > > +             INIT_WORK(&w->work, ashmem_shrink_worker);
> > > +             w->file = range->asma->file;
> > > +             get_file(w->file);
> > > +             w->start = range->pgstart * PAGE_SIZE;
> > > +             w->end = (range->pgend + 1) * PAGE_SIZE;
> > > +             atomic_inc(&ashmem_shrink_inflight);
> > > +             queue_work(ashmem_wq, &w->work);
> > >
> > > -             range->asma->file->f_op->fallocate(range->asma->file,
> > > -                             FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > > -                             start, end - start);
> > >               range->purged = ASHMEM_WAS_PURGED;
> > >               lru_del(range);
> > >
> > > @@ -713,6 +745,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
> > >               return -EFAULT;
> > >
> > >       mutex_lock(&ashmem_mutex);
> > > +     wait_event(ashmem_shrink_wait, !atomic_read(&ashmem_shrink_inflight));
> > >
> > >       if (!asma->file)
> > >               goto out_unlock;
> > > @@ -883,8 +916,15 @@ static int __init ashmem_init(void)
> > >               goto out_free2;
> > >       }
> > >
> > > +     ashmem_wq = alloc_workqueue("ashmem_wq", WQ_MEM_RECLAIM, 0);
> > > +     if (!ashmem_wq) {
> > > +             pr_err("failed to create workqueue\n");
> > > +             goto out_demisc;
> > > +     }
> > > +
> > >       ret = register_shrinker(&ashmem_shrinker);
> > >       if (ret) {
> > > +             destroy_workqueue(ashmem_wq);
> > >               pr_err("failed to register shrinker!\n");
> > >               goto out_demisc;
> > >       }
> >
