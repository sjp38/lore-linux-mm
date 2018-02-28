Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF2D56B0008
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 12:30:59 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g69so3222667ita.9
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 09:30:59 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u16sor1232702ite.23.2018.02.28.09.30.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 09:30:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180227100508.GG15357@dhcp22.suse.cz>
References: <f403043d0f180bb28505662ead84@google.com> <20180227100508.GG15357@dhcp22.suse.cz>
From: Todd Kjos <tkjos@google.com>
Date: Wed, 28 Feb 2018 09:30:52 -0800
Message-ID: <CAHRSSEy6dHFaLQtA+Pfn1cL7Keb6faoK07bM9+8cm__HnBffQw@mail.gmail.com>
Subject: Re: possible deadlock in __might_fault
Content-Type: multipart/alternative; boundary="94eb2c07da3aeb84c40566491a3a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Joel Fernandes <joelaf@google.com>
Cc: syzbot <syzbot+d7a918a7a8e1c952bc36@syzkaller.appspotmail.com>, akpm@linux-foundation.org, dan.j.williams@intel.com, hughd@google.com, jglisse@redhat.com, kirill.shutemov@linux.intel.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, minchan@kernel.org, mingo@kernel.org, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, ying.huang@intel.com, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>

--94eb2c07da3aeb84c40566491a3a
Content-Type: text/plain; charset="UTF-8"

Joel- can you look into this one?

On Tue, Feb 27, 2018 at 2:05 AM, Michal Hocko <mhocko@kernel.org> wrote:

> [Cc ashmem maintainers]
>
> this looks like an ashmem bug
>
> On Tue 27-02-18 01:59:01, syzbot wrote:
> > Hello,
> >
> > syzbot hit the following crash on upstream commit
> > c89be5242607d8aa08a6fa45a887c68b2d4a2a2c (Sun Feb 25 21:43:18 2018
> +0000)
> > Merge tag 'nfs-for-4.16-3' of
> > git://git.linux-nfs.org/projects/trondmy/linux-nfs
> >
> > So far this crash happened 1820 times on upstream.
> > C reproducer is attached.
> > syzkaller reproducer is attached.
> > Raw console output is attached.
> > compiler: gcc (GCC) 7.1.1 20170620
> > .config is attached.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the
> commit:
> > Reported-by: syzbot+d7a918a7a8e1c952bc36@syzkaller.appspotmail.com
> > It will help syzbot understand when the bug is fixed. See footer for
> > details.
> > If you forward the report, please keep this part and the footer.
> >
> > audit: type=1400 audit(1519638766.030:7): avc:  denied  { map } for
> > pid=4243 comm="syzkaller923784" path="/root/syzkaller923784171"
> dev="sda1"
> > ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> > tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
> >
> > audit: type=1400 audit(1519638766.030:8): avc:  denied  { map } for
> > pid=4243 comm="syzkaller923784" path="/dev/ashmem" dev="devtmpfs"
> ino=9417
> > scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> > tcontext=system_u:object_r:device_t:s0 tclass=chr_file permissive=1
> > ======================================================
> > WARNING: possible circular locking dependency detected
> > 4.16.0-rc2+ #329 Not tainted
> > ------------------------------------------------------
> > syzkaller923784/4243 is trying to acquire lock:
> >  (&mm->mmap_sem){++++}, at: [<0000000074c86253>] __might_fault+0xe0/0x1d0
> > mm/memory.c:4570
> >
> > but task is already holding lock:
> >  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>] ashmem_pin_unpin
> > drivers/staging/android/ashmem.c:705 [inline]
> >  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>] ashmem_ioctl+0x3db/0x11b0
> > drivers/staging/android/ashmem.c:782
> >
> > which lock already depends on the new lock.
> >
> >
> > the existing dependency chain (in reverse order) is:
> >
> > -> #1 (ashmem_mutex){+.+.}:
> >        __mutex_lock_common kernel/locking/mutex.c:756 [inline]
> >        __mutex_lock+0x16f/0x1a80 kernel/locking/mutex.c:893
> >        mutex_lock_nested+0x16/0x20 kernel/locking/mutex.c:908
> >        ashmem_mmap+0x53/0x410 drivers/staging/android/ashmem.c:362
> >        call_mmap include/linux/fs.h:1786 [inline]
> >        mmap_region+0xa99/0x15a0 mm/mmap.c:1705
> >        do_mmap+0x6c0/0xe00 mm/mmap.c:1483
> >        do_mmap_pgoff include/linux/mm.h:2223 [inline]
> >        vm_mmap_pgoff+0x1de/0x280 mm/util.c:355
> >        SYSC_mmap_pgoff mm/mmap.c:1533 [inline]
> >        SyS_mmap_pgoff+0x462/0x5f0 mm/mmap.c:1491
> >        SYSC_mmap arch/x86/kernel/sys_x86_64.c:100 [inline]
> >        SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_64.c:91
> >        do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287
> >        entry_SYSCALL_64_after_hwframe+0x42/0xb7
> >
> > -> #0 (&mm->mmap_sem){++++}:
> >        lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3920
> >        __might_fault+0x13a/0x1d0 mm/memory.c:4571
> >        _copy_from_user+0x2c/0x110 lib/usercopy.c:10
> >        copy_from_user include/linux/uaccess.h:147 [inline]
> >        ashmem_pin_unpin drivers/staging/android/ashmem.c:710 [inline]
> >        ashmem_ioctl+0x438/0x11b0 drivers/staging/android/ashmem.c:782
> >        vfs_ioctl fs/ioctl.c:46 [inline]
> >        do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:686
> >        SYSC_ioctl fs/ioctl.c:701 [inline]
> >        SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
> >        do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287
> >        entry_SYSCALL_64_after_hwframe+0x42/0xb7
> >
> > other info that might help us debug this:
> >
> >  Possible unsafe locking scenario:
> >
> >        CPU0                    CPU1
> >        ----                    ----
> >   lock(ashmem_mutex);
> >                                lock(&mm->mmap_sem);
> >                                lock(ashmem_mutex);
> >   lock(&mm->mmap_sem);
> >
> >  *** DEADLOCK ***
> >
> > 1 lock held by syzkaller923784/4243:
> >  #0:  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>] ashmem_pin_unpin
> > drivers/staging/android/ashmem.c:705 [inline]
> >  #0:  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>]
> > ashmem_ioctl+0x3db/0x11b0 drivers/staging/android/ashmem.c:782
> >
> > stack backtrace:
> > CPU: 1 PID: 4243 Comm: syzkaller923784 Not tainted 4.16.0-rc2+ #329
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> > Google 01/01/2011
> > Call Trace:
> >  __dump_stack lib/dump_stack.c:17 [inline]
> >  dump_stack+0x194/0x24d lib/dump_stack.c:53
> >  print_circular_bug.isra.38+0x2cd/0x2dc kernel/locking/lockdep.c:1223
> >  check_prev_add kernel/locking/lockdep.c:1863 [inline]
> >  check_prevs_add kernel/locking/lockdep.c:1976 [inline]
> >  validate_chain kernel/locking/lockdep.c:2417 [inline]
> >  __lock_acquire+0x30a8/0x3e00 kernel/locking/lockdep.c:3431
> >  lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3920
> >  __might_fault+0x13a/0x1d0 mm/memory.c:4571
> >  _copy_from_user+0x2c/0x110 lib/usercopy.c:10
> >  copy_from_user include/linux/uaccess.h:147 [inline]
> >  ashmem_pin_unpin drivers/staging/android/ashmem.c:710 [inline]
> >  ashmem_ioctl+0x438/0x11b0 drivers/staging/android/ashmem.c:782
> >  vfs_ioctl fs/ioctl.c:46 [inline]
> >  do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:686
> >  SYSC_ioctl fs/ioctl.c:701 [inline]
> >  SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692
> >  do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287
> >  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> > RIP: 0033:0x43fd19
> > RSP: 002b:00007ffe04d2fda8 EFLAGS: 00000217 ORIG_RAX: 0000000000000010
> > RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fd19
> > RDX: 0000000000000000 RSI: 0000000000007709 RDI: 0000000000000003
> > RBP: 000000
> >
> >
> > ---
> > This bug is generated by a dumb bot. It may contain errors.
> > See https://goo.gl/tpsmEJ for details.
> > Direct all questions to syzkaller@googlegroups.com.
> >
> > syzbot will keep track of this bug report.
> > If you forgot to add the Reported-by tag, once the fix for this bug is
> > merged
> > into any tree, please reply to this email with:
> > #syz fix: exact-commit-title
> > If you want to test a patch for this bug, please reply with:
> > #syz test: git://repo/address.git branch
> > and provide the patch inline or as an attachment.
> > To mark this as a duplicate of another syzbot report, please reply with:
> > #syz dup: exact-subject-of-another-report
> > If it's a one-off invalid bug report, please reply with:
> > #syz invalid
> > Note: if the crash happens again, it will cause creation of a new bug
> > report.
> > Note: all commands must start from beginning of the line in the email
> body.
>
> > [....] Starting enhanced syslogd: rsyslogd[   17.353603] audit:
> type=1400 audit(1519638753.636:5): avc:  denied  { syslog } for  pid=4089
> comm="rsyslogd" capability=34  scontext=system_u:system_r:kernel_t:s0
> tcontext=system_u:system_r:kernel_t:s0 tclass=capability2 permissive=1
> >  [?25l [?1c 7 [1G[ [32m ok  [39;49m 8 [?25h [?0c.
> > [....] Starting periodic command scheduler: cron [?25l [?1c 7 [1G[ [32m
> ok  [39;49m 8 [?25h [?0c.
> > Starting mcstransd:
> > [....] Starting file context maintaining daemon: restorecond [?25l [?1c
> 7 [1G[ [32m ok  [39;49m 8 [?25h [?0c.
> > [....] Starting OpenBSD Secure Shell server: sshd [?25l [?1c 7 [1G[ [32m
> ok  [39;49m 8 [?25h [?0c.
> >
> > Debian GNU/Linux 7 syzkaller ttyS0
> >
> > syzkaller login: [   23.429793] audit: type=1400
> audit(1519638759.712:6): avc:  denied  { map } for  pid=4229 comm="bash"
> path="/bin/bash" dev="sda1" ino=1457 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=system_u:object_r:file_t:s0 tclass=file permissive=1
> > Warning: Permanently added '10.128.0.58' (ECDSA) to the list of known
> hosts.
> > executing program
> > [   29.747804] audit: type=1400 audit(1519638766.030:7): avc:  denied  {
> map } for  pid=4243 comm="syzkaller923784" path="/root/syzkaller923784171"
> dev="sda1" ino=16481 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=1
> > [   29.750248]
> > [   29.773690] audit: type=1400 audit(1519638766.030:8): avc:  denied  {
> map } for  pid=4243 comm="syzkaller923784" path="/dev/ashmem"
> dev="devtmpfs" ino=9417 scontext=unconfined_u:system_r:insmod_t:s0-s0:c0.c1023
> tcontext=system_u:object_r:device_t:s0 tclass=chr_file permissive=1
> > [   29.775275] ======================================================
> > [   29.775276] WARNING: possible circular locking dependency detected
> > [   29.775280] 4.16.0-rc2+ #329 Not tainted
> > [   29.775281] ------------------------------------------------------
> > [   29.775283] syzkaller923784/4243 is trying to acquire lock:
> > [   29.775284]  (&mm->mmap_sem){++++}, at: [<0000000074c86253>]
> __might_fault+0xe0/0x1d0
> > [   29.775302]
> > [   29.775302] but task is already holding lock:
> > [   29.842391]  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>]
> ashmem_ioctl+0x3db/0x11b0
> > [   29.850331]
> > [   29.850331] which lock already depends on the new lock.
> > [   29.850331]
> > [   29.858610]
> > [   29.858610] the existing dependency chain (in reverse order) is:
> > [   29.866195]
> > [   29.866195] -> #1 (ashmem_mutex){+.+.}:
> > [   29.871618]        __mutex_lock+0x16f/0x1a80
> > [   29.876003]        mutex_lock_nested+0x16/0x20
> > [   29.880550]        ashmem_mmap+0x53/0x410
> > [   29.884663]        mmap_region+0xa99/0x15a0
> > [   29.888950]        do_mmap+0x6c0/0xe00
> > [   29.892805]        vm_mmap_pgoff+0x1de/0x280
> > [   29.897183]        SyS_mmap_pgoff+0x462/0x5f0
> > [   29.901647]        SyS_mmap+0x16/0x20
> > [   29.905416]        do_syscall_64+0x280/0x940
> > [   29.909789]        entry_SYSCALL_64_after_hwframe+0x42/0xb7
> > [   29.915461]
> > [   29.915461] -> #0 (&mm->mmap_sem){++++}:
> > [   29.920974]        lock_acquire+0x1d5/0x580
> > [   29.925263]        __might_fault+0x13a/0x1d0
> > [   29.929638]        _copy_from_user+0x2c/0x110
> > [   29.934101]        ashmem_ioctl+0x438/0x11b0
> > [   29.938474]        do_vfs_ioctl+0x1b1/0x1520
> > [   29.942864]        SyS_ioctl+0x8f/0xc0
> > [   29.946720]        do_syscall_64+0x280/0x940
> > [   29.951094]        entry_SYSCALL_64_after_hwframe+0x42/0xb7
> > [   29.956765]
> > [   29.956765] other info that might help us debug this:
> > [   29.956765]
> > [   29.964871]  Possible unsafe locking scenario:
> > [   29.964871]
> > [   29.970893]        CPU0                    CPU1
> > [   29.975526]        ----                    ----
> > [   29.980157]   lock(ashmem_mutex);
> > [   29.983576]                                lock(&mm->mmap_sem);
> > [   29.989598]                                lock(ashmem_mutex);
> > [   29.995535]   lock(&mm->mmap_sem);
> > [   29.999051]
> > [   29.999051]  *** DEADLOCK ***
> > [   29.999051]
> > [   30.005079] 1 lock held by syzkaller923784/4243:
> > [   30.009799]  #0:  (ashmem_mutex){+.+.}, at: [<0000000024db7f7c>]
> ashmem_ioctl+0x3db/0x11b0
> > [   30.018176]
> > [   30.018176] stack backtrace:
> > [   30.022640] CPU: 1 PID: 4243 Comm: syzkaller923784 Not tainted
> 4.16.0-rc2+ #329
> > [   30.030052] Hardware name: Google Google Compute Engine/Google
> Compute Engine, BIOS Google 01/01/2011
> > [   30.039371] Call Trace:
> > [   30.041927]  dump_stack+0x194/0x24d
> > [   30.045522]  ? arch_local_irq_restore+0x53/0x53
> > [   30.050160]  print_circular_bug.isra.38+0x2cd/0x2dc
> > [   30.055142]  ? save_trace+0xe0/0x2b0
> > [   30.058822]  __lock_acquire+0x30a8/0x3e00
> > [   30.062936]  ? ashmem_ioctl+0x3db/0x11b0
> > [   30.066966]  ? debug_check_no_locks_freed+0x3c0/0x3c0
> > [   30.072132]  ? __might_sleep+0x95/0x190
> > [   30.076074]  ? ashmem_ioctl+0x3db/0x11b0
> > [   30.080102]  ? __mutex_lock+0x16f/0x1a80
> > [   30.084130]  ? ashmem_ioctl+0x3db/0x11b0
> > [   30.088160]  ? proc_nr_files+0x60/0x60
> > [   30.092015]  ? ashmem_ioctl+0x3db/0x11b0
> > [   30.096042]  ? find_held_lock+0x35/0x1d0
> > [   30.100071]  ? mutex_lock_io_nested+0x1900/0x1900
> > [   30.104880]  ? lock_downgrade+0x980/0x980
> > [   30.108995]  ? __mutex_unlock_slowpath+0xe9/0xac0
> > [   30.113807]  ? find_held_lock+0x35/0x1d0
> > [   30.117834]  ? lock_downgrade+0x980/0x980
> > [   30.121949]  ? vma_set_page_prot+0x16b/0x230
> > [   30.126324]  lock_acquire+0x1d5/0x580
> > [   30.130094]  ? lock_acquire+0x1d5/0x580
> > [   30.134034]  ? __might_fault+0xe0/0x1d0
> > [   30.137976]  ? lock_release+0xa40/0xa40
> > [   30.141921]  ? trace_event_raw_event_sched_switch+0x810/0x810
> > [   30.147774]  ? __might_sleep+0x95/0x190
> > [   30.151713]  __might_fault+0x13a/0x1d0
> > [   30.155566]  ? __might_fault+0xe0/0x1d0
> > [   30.159508]  _copy_from_user+0x2c/0x110
> > [   30.163447]  ashmem_ioctl+0x438/0x11b0
> > [   30.167302]  ? ashmem_release+0x190/0x190
> > [   30.171419]  ? trace_event_raw_event_sched_switch+0x810/0x810
> > [   30.177272]  ? down_read_killable+0x180/0x180
> > [   30.181734]  ? rcu_note_context_switch+0x710/0x710
> > [   30.186629]  ? ashmem_release+0x190/0x190
> > [   30.190742]  do_vfs_ioctl+0x1b1/0x1520
> > [   30.194597]  ? ioctl_preallocate+0x2b0/0x2b0
> > [   30.198975]  ? selinux_capable+0x40/0x40
> > [   30.203004]  ? putname+0xf3/0x130
> > [   30.206422]  ? fput+0xd2/0x140
> > [   30.209583]  ? SyS_mmap_pgoff+0x243/0x5f0
> > [   30.213700]  ? security_file_ioctl+0x7d/0xb0
> > [   30.218072]  ? security_file_ioctl+0x89/0xb0
> > [   30.222448]  SyS_ioctl+0x8f/0xc0
> > [   30.225781]  ? do_vfs_ioctl+0x1520/0x1520
> > [   30.229896]  do_syscall_64+0x280/0x940
> > [   30.233749]  ? __do_page_fault+0xc90/0xc90
> > [   30.237948]  ? trace_hardirqs_on_thunk+0x1a/0x1c
> > [   30.242671]  ? syscall_return_slowpath+0x550/0x550
> > [   30.247567]  ? syscall_return_slowpath+0x2ac/0x550
> > [   30.252464]  ? prepare_exit_to_usermode+0x350/0x350
> > [   30.257449]  ? entry_SYSCALL_64_after_hwframe+0x52/0xb7
> > [   30.262779]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> > [   30.267590]  entry_SYSCALL_64_after_hwframe+0x42/0xb7
> > [   30.272743] RIP: 0033:0x43fd19
> > [   30.275903] RSP: 002b:00007ffe04d2fda8 EFLAGS: 00000217 ORIG_RAX:
> 0000000000000010
> > [   30.283575] RAX: ffffffffffffffda RBX: 00000000004002c8 RCX:
> 000000000043fd19
> > [   30.290809] RDX: 0000000000000000 RSI: 0000000000007709 RDI:
> 0000000000000003
> > [   30.298046] RBP: 000000
>
> > # See https://goo.gl/kgGztJ for information about syzkaller reproducers.
> > #{Threaded:false Collide:false Repeat:false Procs:1 Sandbox: Fault:false
> FaultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:false HandleSegv:false
> WaitRepeat:false Debug:false Repro:false}
> > r0 = openat$ashmem(0xffffffffffffff9c, &(0x7f000059aff4)='/dev/ashmem\x00',
> 0x0, 0x0)
> > ioctl$ASHMEM_SET_SIZE(r0, 0x40087703, 0x2a)
> > mmap(&(0x7f00003f5000/0x2000)=nil, 0x2000, 0x0, 0x1011, r0, 0x0)
> > ioctl$ASHMEM_GET_PIN_STATUS(r0, 0x7709, 0x0)
>
> > // autogenerated by syzkaller (http://github.com/google/syzkaller)
> >
> > #define _GNU_SOURCE
> > #include <endian.h>
> > #include <stdint.h>
> > #include <string.h>
> > #include <sys/syscall.h>
> > #include <unistd.h>
> >
> > long r[1];
> > void loop()
> > {
> >   memset(r, -1, sizeof(r));
> >   memcpy((void*)0x2059aff4, "/dev/ashmem", 12);
> >   r[0] = syscall(__NR_openat, 0xffffffffffffff9c, 0x2059aff4, 0, 0);
> >   syscall(__NR_ioctl, r[0], 0x40087703, 0x2a);
> >   syscall(__NR_mmap, 0x203f5000, 0x2000, 0, 0x1011, r[0], 0);
> >   syscall(__NR_ioctl, r[0], 0x7709, 0);
> > }
> >
> > int main()
> > {
> >   syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);
> >   loop();
> >   return 0;
> > }
>
> > #
> > # Automatically generated file; DO NOT EDIT.
> > # Linux/x86 4.16.0-rc2 Kernel Configuration
> > #
> > CONFIG_64BIT=y
> > CONFIG_X86_64=y
> > CONFIG_X86=y
> > CONFIG_INSTRUCTION_DECODER=y
> > CONFIG_OUTPUT_FORMAT="elf64-x86-64"
> > CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
> > CONFIG_LOCKDEP_SUPPORT=y
> > CONFIG_STACKTRACE_SUPPORT=y
> > CONFIG_MMU=y
> > CONFIG_ARCH_MMAP_RND_BITS_MIN=28
> > CONFIG_ARCH_MMAP_RND_BITS_MAX=32
> > CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
> > CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
> > CONFIG_NEED_DMA_MAP_STATE=y
> > CONFIG_NEED_SG_DMA_LENGTH=y
> > CONFIG_GENERIC_ISA_DMA=y
> > CONFIG_GENERIC_BUG=y
> > CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
> > CONFIG_GENERIC_HWEIGHT=y
> > CONFIG_ARCH_MAY_HAVE_PC_FDC=y
> > CONFIG_RWSEM_XCHGADD_ALGORITHM=y
> > CONFIG_GENERIC_CALIBRATE_DELAY=y
> > CONFIG_ARCH_HAS_CPU_RELAX=y
> > CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
> > CONFIG_HAVE_SETUP_PER_CPU_AREA=y
> > CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
> > CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
> > CONFIG_ARCH_HIBERNATION_POSSIBLE=y
> > CONFIG_ARCH_SUSPEND_POSSIBLE=y
> > CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
> > CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
> > CONFIG_ZONE_DMA32=y
> > CONFIG_AUDIT_ARCH=y
> > CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
> > CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
> > CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
> > CONFIG_HAVE_INTEL_TXT=y
> > CONFIG_X86_64_SMP=y
> > CONFIG_ARCH_SUPPORTS_UPROBES=y
> > CONFIG_FIX_EARLYCON_MEM=y
> > CONFIG_PGTABLE_LEVELS=4
> > CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
> > CONFIG_CONSTRUCTORS=y
> > CONFIG_IRQ_WORK=y
> > CONFIG_BUILDTIME_EXTABLE_SORT=y
> > CONFIG_THREAD_INFO_IN_TASK=y
> >
> > #
> > # General setup
> > #
> > CONFIG_INIT_ENV_ARG_LIMIT=32
> > CONFIG_CROSS_COMPILE=""
> > # CONFIG_COMPILE_TEST is not set
> > CONFIG_LOCALVERSION=""
> > # CONFIG_LOCALVERSION_AUTO is not set
> > CONFIG_HAVE_KERNEL_GZIP=y
> > CONFIG_HAVE_KERNEL_BZIP2=y
> > CONFIG_HAVE_KERNEL_LZMA=y
> > CONFIG_HAVE_KERNEL_XZ=y
> > CONFIG_HAVE_KERNEL_LZO=y
> > CONFIG_HAVE_KERNEL_LZ4=y
> > CONFIG_KERNEL_GZIP=y
> > # CONFIG_KERNEL_BZIP2 is not set
> > # CONFIG_KERNEL_LZMA is not set
> > # CONFIG_KERNEL_XZ is not set
> > # CONFIG_KERNEL_LZO is not set
> > # CONFIG_KERNEL_LZ4 is not set
> > CONFIG_DEFAULT_HOSTNAME="(none)"
> > CONFIG_SWAP=y
> > CONFIG_SYSVIPC=y
> > CONFIG_SYSVIPC_SYSCTL=y
> > CONFIG_POSIX_MQUEUE=y
> > CONFIG_POSIX_MQUEUE_SYSCTL=y
> > CONFIG_CROSS_MEMORY_ATTACH=y
> > CONFIG_USELIB=y
> > CONFIG_AUDIT=y
> > CONFIG_HAVE_ARCH_AUDITSYSCALL=y
> > CONFIG_AUDITSYSCALL=y
> > CONFIG_AUDIT_WATCH=y
> > CONFIG_AUDIT_TREE=y
> >
> > #
> > # IRQ subsystem
> > #
> > CONFIG_GENERIC_IRQ_PROBE=y
> > CONFIG_GENERIC_IRQ_SHOW=y
> > CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
> > CONFIG_GENERIC_PENDING_IRQ=y
> > CONFIG_GENERIC_IRQ_MIGRATION=y
> > CONFIG_IRQ_DOMAIN=y
> > CONFIG_IRQ_DOMAIN_HIERARCHY=y
> > CONFIG_GENERIC_MSI_IRQ=y
> > CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
> > CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
> > CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
> > CONFIG_IRQ_FORCED_THREADING=y
> > CONFIG_SPARSE_IRQ=y
> > # CONFIG_GENERIC_IRQ_DEBUGFS is not set
> > CONFIG_CLOCKSOURCE_WATCHDOG=y
> > CONFIG_ARCH_CLOCKSOURCE_DATA=y
> > CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
> > CONFIG_GENERIC_TIME_VSYSCALL=y
> > CONFIG_GENERIC_CLOCKEVENTS=y
> > CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
> > CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
> > CONFIG_GENERIC_CMOS_UPDATE=y
> >
> > #
> > # Timers subsystem
> > #
> > CONFIG_TICK_ONESHOT=y
> > CONFIG_NO_HZ_COMMON=y
> > # CONFIG_HZ_PERIODIC is not set
> > CONFIG_NO_HZ_IDLE=y
> > # CONFIG_NO_HZ_FULL is not set
> > CONFIG_NO_HZ=y
> > CONFIG_HIGH_RES_TIMERS=y
> >
> > #
> > # CPU/Task time and stats accounting
> > #
> > CONFIG_TICK_CPU_ACCOUNTING=y
> > # CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
> > # CONFIG_IRQ_TIME_ACCOUNTING is not set
> > CONFIG_BSD_PROCESS_ACCT=y
> > # CONFIG_BSD_PROCESS_ACCT_V3 is not set
> > CONFIG_TASKSTATS=y
> > CONFIG_TASK_DELAY_ACCT=y
> > CONFIG_TASK_XACCT=y
> > CONFIG_TASK_IO_ACCOUNTING=y
> > # CONFIG_CPU_ISOLATION is not set
> >
> > #
> > # RCU Subsystem
> > #
> > CONFIG_TREE_RCU=y
> > # CONFIG_RCU_EXPERT is not set
> > CONFIG_SRCU=y
> > CONFIG_TREE_SRCU=y
> > # CONFIG_TASKS_RCU is not set
> > CONFIG_RCU_STALL_COMMON=y
> > CONFIG_RCU_NEED_SEGCBLIST=y
> > # CONFIG_BUILD_BIN2C is not set
> > # CONFIG_IKCONFIG is not set
> > CONFIG_LOG_BUF_SHIFT=18
> > CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
> > CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
> > CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
> > CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
> > CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
> > CONFIG_ARCH_SUPPORTS_INT128=y
> > CONFIG_NUMA_BALANCING=y
> > CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
> > CONFIG_CGROUPS=y
> > CONFIG_PAGE_COUNTER=y
> > CONFIG_MEMCG=y
> > CONFIG_MEMCG_SWAP=y
> > CONFIG_MEMCG_SWAP_ENABLED=y
> > CONFIG_BLK_CGROUP=y
> > # CONFIG_DEBUG_BLK_CGROUP is not set
> > CONFIG_CGROUP_WRITEBACK=y
> > CONFIG_CGROUP_SCHED=y
> > CONFIG_FAIR_GROUP_SCHED=y
> > # CONFIG_CFS_BANDWIDTH is not set
> > # CONFIG_RT_GROUP_SCHED is not set
> > CONFIG_CGROUP_PIDS=y
> > CONFIG_CGROUP_RDMA=y
> > CONFIG_CGROUP_FREEZER=y
> > CONFIG_CGROUP_HUGETLB=y
> > CONFIG_CPUSETS=y
> > CONFIG_PROC_PID_CPUSET=y
> > CONFIG_CGROUP_DEVICE=y
> > CONFIG_CGROUP_CPUACCT=y
> > CONFIG_CGROUP_PERF=y
> > CONFIG_CGROUP_BPF=y
> > # CONFIG_CGROUP_DEBUG is not set
> > CONFIG_SOCK_CGROUP_DATA=y
> > CONFIG_NAMESPACES=y
> > CONFIG_UTS_NS=y
> > CONFIG_IPC_NS=y
> > CONFIG_USER_NS=y
> > CONFIG_PID_NS=y
> > CONFIG_NET_NS=y
> > # CONFIG_SCHED_AUTOGROUP is not set
> > # CONFIG_SYSFS_DEPRECATED is not set
> > CONFIG_RELAY=y
> > CONFIG_BLK_DEV_INITRD=y
> > CONFIG_INITRAMFS_SOURCE=""
> > CONFIG_RD_GZIP=y
> > CONFIG_RD_BZIP2=y
> > CONFIG_RD_LZMA=y
> > CONFIG_RD_XZ=y
> > CONFIG_RD_LZO=y
> > CONFIG_RD_LZ4=y
> > CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
> > # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> > CONFIG_SYSCTL=y
> > CONFIG_ANON_INODES=y
> > CONFIG_HAVE_UID16=y
> > CONFIG_SYSCTL_EXCEPTION_TRACE=y
> > CONFIG_HAVE_PCSPKR_PLATFORM=y
> > CONFIG_BPF=y
> > CONFIG_EXPERT=y
> > CONFIG_UID16=y
> > CONFIG_MULTIUSER=y
> > CONFIG_SGETMASK_SYSCALL=y
> > CONFIG_SYSFS_SYSCALL=y
> > CONFIG_SYSCTL_SYSCALL=y
> > CONFIG_FHANDLE=y
> > CONFIG_POSIX_TIMERS=y
> > CONFIG_PRINTK=y
> > CONFIG_PRINTK_NMI=y
> > CONFIG_BUG=y
> > CONFIG_ELF_CORE=y
> > CONFIG_PCSPKR_PLATFORM=y
> > CONFIG_BASE_FULL=y
> > CONFIG_FUTEX=y
> > CONFIG_FUTEX_PI=y
> > CONFIG_EPOLL=y
> > CONFIG_SIGNALFD=y
> > CONFIG_TIMERFD=y
> > CONFIG_EVENTFD=y
> > CONFIG_SHMEM=y
> > CONFIG_AIO=y
> > CONFIG_ADVISE_SYSCALLS=y
> > CONFIG_MEMBARRIER=y
> > CONFIG_CHECKPOINT_RESTORE=y
> > CONFIG_KALLSYMS=y
> > CONFIG_KALLSYMS_ALL=y
> > CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
> > CONFIG_KALLSYMS_BASE_RELATIVE=y
> > CONFIG_BPF_SYSCALL=y
> > # CONFIG_BPF_JIT_ALWAYS_ON is not set
> > CONFIG_USERFAULTFD=y
> > CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
> > # CONFIG_EMBEDDED is not set
> > CONFIG_HAVE_PERF_EVENTS=y
> > # CONFIG_PC104 is not set
> >
> > #
> > # Kernel Performance Events And Counters
> > #
> > CONFIG_PERF_EVENTS=y
> > # CONFIG_DEBUG_PERF_USE_VMALLOC is not set
> > CONFIG_VM_EVENT_COUNTERS=y
> > # CONFIG_COMPAT_BRK is not set
> > CONFIG_SLAB=y
> > # CONFIG_SLUB is not set
> > # CONFIG_SLOB is not set
> > CONFIG_SLAB_MERGE_DEFAULT=y
> > # CONFIG_SLAB_FREELIST_RANDOM is not set
> > CONFIG_SYSTEM_DATA_VERIFICATION=y
> > CONFIG_PROFILING=y
> > CONFIG_TRACEPOINTS=y
> > CONFIG_CRASH_CORE=y
> > CONFIG_KEXEC_CORE=y
> > # CONFIG_OPROFILE is not set
> > CONFIG_HAVE_OPROFILE=y
> > CONFIG_OPROFILE_NMI_TIMER=y
> > CONFIG_KPROBES=y
> > CONFIG_JUMP_LABEL=y
> > # CONFIG_STATIC_KEYS_SELFTEST is not set
> > CONFIG_OPTPROBES=y
> > CONFIG_UPROBES=y
> > # CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
> > CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
> > CONFIG_ARCH_USE_BUILTIN_BSWAP=y
> > CONFIG_KRETPROBES=y
> > CONFIG_USER_RETURN_NOTIFIER=y
> > CONFIG_HAVE_IOREMAP_PROT=y
> > CONFIG_HAVE_KPROBES=y
> > CONFIG_HAVE_KRETPROBES=y
> > CONFIG_HAVE_OPTPROBES=y
> > CONFIG_HAVE_KPROBES_ON_FTRACE=y
> > CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
> > CONFIG_HAVE_NMI=y
> > CONFIG_HAVE_ARCH_TRACEHOOK=y
> > CONFIG_HAVE_DMA_CONTIGUOUS=y
> > CONFIG_GENERIC_SMP_IDLE_THREAD=y
> > CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
> > CONFIG_ARCH_HAS_SET_MEMORY=y
> > CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
> > CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
> > CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
> > CONFIG_HAVE_CLK=y
> > CONFIG_HAVE_DMA_API_DEBUG=y
> > CONFIG_HAVE_HW_BREAKPOINT=y
> > CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
> > CONFIG_HAVE_USER_RETURN_NOTIFIER=y
> > CONFIG_HAVE_PERF_EVENTS_NMI=y
> > CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
> > CONFIG_HAVE_PERF_REGS=y
> > CONFIG_HAVE_PERF_USER_STACK_DUMP=y
> > CONFIG_HAVE_ARCH_JUMP_LABEL=y
> > CONFIG_HAVE_RCU_TABLE_FREE=y
> > CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
> > CONFIG_HAVE_CMPXCHG_LOCAL=y
> > CONFIG_HAVE_CMPXCHG_DOUBLE=y
> > CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
> > CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
> > CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
> > CONFIG_SECCOMP_FILTER=y
> > CONFIG_HAVE_GCC_PLUGINS=y
> > CONFIG_GCC_PLUGINS=y
> > # CONFIG_GCC_PLUGIN_CYC_COMPLEXITY is not set
> > CONFIG_GCC_PLUGIN_SANCOV=y
> > # CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
> > # CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
> > # CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
> > CONFIG_HAVE_CC_STACKPROTECTOR=y
> > # CONFIG_CC_STACKPROTECTOR_NONE is not set
> > CONFIG_CC_STACKPROTECTOR_REGULAR=y
> > # CONFIG_CC_STACKPROTECTOR_STRONG is not set
> > # CONFIG_CC_STACKPROTECTOR_AUTO is not set
> > CONFIG_THIN_ARCHIVES=y
> > CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
> > CONFIG_HAVE_CONTEXT_TRACKING=y
> > CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
> > CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
> > CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
> > CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
> > CONFIG_HAVE_ARCH_HUGE_VMAP=y
> > CONFIG_HAVE_ARCH_SOFT_DIRTY=y
> > CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
> > CONFIG_MODULES_USE_ELF_RELA=y
> > CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
> > CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
> > CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
> > CONFIG_HAVE_EXIT_THREAD=y
> > CONFIG_ARCH_MMAP_RND_BITS=28
> > CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
> > CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
> > CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
> > CONFIG_HAVE_COPY_THREAD_TLS=y
> > CONFIG_HAVE_STACK_VALIDATION=y
> > # CONFIG_HAVE_ARCH_HASH is not set
> > # CONFIG_ISA_BUS_API is not set
> > CONFIG_OLD_SIGSUSPEND3=y
> > CONFIG_COMPAT_OLD_SIGACTION=y
> > # CONFIG_CPU_NO_EFFICIENT_FFS is not set
> > CONFIG_HAVE_ARCH_VMAP_STACK=y
> > # CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
> > # CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
> > CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
> > CONFIG_STRICT_KERNEL_RWX=y
> > CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
> > CONFIG_STRICT_MODULE_RWX=y
> > CONFIG_ARCH_HAS_PHYS_TO_DMA=y
> > CONFIG_ARCH_HAS_REFCOUNT=y
> > CONFIG_REFCOUNT_FULL=y
> >
> > #
> > # GCOV-based kernel profiling
> > #
> > # CONFIG_GCOV_KERNEL is not set
> > CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
> > # CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
> > CONFIG_RT_MUTEXES=y
> > CONFIG_BASE_SMALL=0
> > CONFIG_MODULES=y
> > # CONFIG_MODULE_FORCE_LOAD is not set
> > CONFIG_MODULE_UNLOAD=y
> > CONFIG_MODULE_FORCE_UNLOAD=y
> > # CONFIG_MODVERSIONS is not set
> > # CONFIG_MODULE_SRCVERSION_ALL is not set
> > # CONFIG_MODULE_SIG is not set
> > # CONFIG_MODULE_COMPRESS is not set
> > # CONFIG_TRIM_UNUSED_KSYMS is not set
> > CONFIG_MODULES_TREE_LOOKUP=y
> > CONFIG_BLOCK=y
> > CONFIG_BLK_SCSI_REQUEST=y
> > CONFIG_BLK_DEV_BSG=y
> > CONFIG_BLK_DEV_BSGLIB=y
> > CONFIG_BLK_DEV_INTEGRITY=y
> > CONFIG_BLK_DEV_ZONED=y
> > CONFIG_BLK_DEV_THROTTLING=y
> > # CONFIG_BLK_DEV_THROTTLING_LOW is not set
> > # CONFIG_BLK_CMDLINE_PARSER is not set
> > CONFIG_BLK_WBT=y
> > # CONFIG_BLK_WBT_SQ is not set
> > CONFIG_BLK_WBT_MQ=y
> > # CONFIG_BLK_DEBUG_FS is not set
> > # CONFIG_BLK_SED_OPAL is not set
> >
> > #
> > # Partition Types
> > #
> > CONFIG_PARTITION_ADVANCED=y
> > # CONFIG_ACORN_PARTITION is not set
> > # CONFIG_AIX_PARTITION is not set
> > CONFIG_OSF_PARTITION=y
> > CONFIG_AMIGA_PARTITION=y
> > # CONFIG_ATARI_PARTITION is not set
> > CONFIG_MAC_PARTITION=y
> > CONFIG_MSDOS_PARTITION=y
> > CONFIG_BSD_DISKLABEL=y
> > CONFIG_MINIX_SUBPARTITION=y
> > CONFIG_SOLARIS_X86_PARTITION=y
> > CONFIG_UNIXWARE_DISKLABEL=y
> > # CONFIG_LDM_PARTITION is not set
> > CONFIG_SGI_PARTITION=y
> > # CONFIG_ULTRIX_PARTITION is not set
> > CONFIG_SUN_PARTITION=y
> > CONFIG_KARMA_PARTITION=y
> > CONFIG_EFI_PARTITION=y
> > # CONFIG_SYSV68_PARTITION is not set
> > # CONFIG_CMDLINE_PARTITION is not set
> > CONFIG_BLOCK_COMPAT=y
> > CONFIG_BLK_MQ_PCI=y
> > CONFIG_BLK_MQ_VIRTIO=y
> > CONFIG_BLK_MQ_RDMA=y
> >
> > #
> > # IO Schedulers
> > #
> > CONFIG_IOSCHED_NOOP=y
> > CONFIG_IOSCHED_DEADLINE=y
> > CONFIG_IOSCHED_CFQ=y
> > CONFIG_CFQ_GROUP_IOSCHED=y
> > # CONFIG_DEFAULT_DEADLINE is not set
> > CONFIG_DEFAULT_CFQ=y
> > # CONFIG_DEFAULT_NOOP is not set
> > CONFIG_DEFAULT_IOSCHED="cfq"
> > CONFIG_MQ_IOSCHED_DEADLINE=y
> > CONFIG_MQ_IOSCHED_KYBER=y
> > CONFIG_IOSCHED_BFQ=y
> > CONFIG_BFQ_GROUP_IOSCHED=y
> > CONFIG_PREEMPT_NOTIFIERS=y
> > CONFIG_PADATA=y
> > CONFIG_ASN1=y
> > CONFIG_UNINLINE_SPIN_UNLOCK=y
> > CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
> > CONFIG_MUTEX_SPIN_ON_OWNER=y
> > CONFIG_RWSEM_SPIN_ON_OWNER=y
> > CONFIG_LOCK_SPIN_ON_OWNER=y
> > CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
> > CONFIG_QUEUED_SPINLOCKS=y
> > CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
> > CONFIG_QUEUED_RWLOCKS=y
> > CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
> > CONFIG_FREEZER=y
> >
> > #
> > # Processor type and features
> > #
> > CONFIG_ZONE_DMA=y
> > CONFIG_SMP=y
> > CONFIG_X86_FEATURE_NAMES=y
> > CONFIG_X86_FAST_FEATURE_TESTS=y
> > CONFIG_X86_X2APIC=y
> > CONFIG_X86_MPPARSE=y
> > # CONFIG_GOLDFISH is not set
> > CONFIG_RETPOLINE=y
> > # CONFIG_INTEL_RDT is not set
> > CONFIG_X86_EXTENDED_PLATFORM=y
> > # CONFIG_X86_NUMACHIP is not set
> > # CONFIG_X86_VSMP is not set
> > # CONFIG_X86_UV is not set
> > # CONFIG_X86_GOLDFISH is not set
> > # CONFIG_X86_INTEL_MID is not set
> > # CONFIG_X86_INTEL_LPSS is not set
> > # CONFIG_X86_AMD_PLATFORM_DEVICE is not set
> > CONFIG_IOSF_MBI=y
> > # CONFIG_IOSF_MBI_DEBUG is not set
> > CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
> > CONFIG_SCHED_OMIT_FRAME_POINTER=y
> > CONFIG_HYPERVISOR_GUEST=y
> > CONFIG_PARAVIRT=y
> > CONFIG_PARAVIRT_DEBUG=y
> > CONFIG_PARAVIRT_SPINLOCKS=y
> > # CONFIG_QUEUED_LOCK_STAT is not set
> > CONFIG_XEN=y
> > CONFIG_XEN_PV=y
> > CONFIG_XEN_PV_SMP=y
> > CONFIG_XEN_DOM0=y
> > CONFIG_XEN_PVHVM=y
> > CONFIG_XEN_PVHVM_SMP=y
> > CONFIG_XEN_512GB=y
> > CONFIG_XEN_SAVE_RESTORE=y
> > # CONFIG_XEN_DEBUG_FS is not set
> > CONFIG_XEN_PVH=y
> > CONFIG_KVM_GUEST=y
> > # CONFIG_KVM_DEBUG_FS is not set
> > # CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
> > CONFIG_PARAVIRT_CLOCK=y
> > # CONFIG_JAILHOUSE_GUEST is not set
> > CONFIG_NO_BOOTMEM=y
> > # CONFIG_MK8 is not set
> > # CONFIG_MPSC is not set
> > # CONFIG_MCORE2 is not set
> > # CONFIG_MATOM is not set
> > CONFIG_GENERIC_CPU=y
> > CONFIG_X86_INTERNODE_CACHE_SHIFT=6
> > CONFIG_X86_L1_CACHE_SHIFT=6
> > CONFIG_X86_TSC=y
> > CONFIG_X86_CMPXCHG64=y
> > CONFIG_X86_CMOV=y
> > CONFIG_X86_MINIMUM_CPU_FAMILY=64
> > CONFIG_X86_DEBUGCTLMSR=y
> > # CONFIG_PROCESSOR_SELECT is not set
> > CONFIG_CPU_SUP_INTEL=y
> > CONFIG_CPU_SUP_AMD=y
> > CONFIG_CPU_SUP_CENTAUR=y
> > CONFIG_HPET_TIMER=y
> > CONFIG_HPET_EMULATE_RTC=y
> > CONFIG_DMI=y
> > # CONFIG_GART_IOMMU is not set
> > CONFIG_CALGARY_IOMMU=y
> > CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
> > CONFIG_SWIOTLB=y
> > CONFIG_IOMMU_HELPER=y
> > # CONFIG_MAXSMP is not set
> > CONFIG_NR_CPUS_RANGE_BEGIN=2
> > CONFIG_NR_CPUS_RANGE_END=512
> > CONFIG_NR_CPUS_DEFAULT=64
> > CONFIG_NR_CPUS=64
> > CONFIG_SCHED_SMT=y
> > CONFIG_SCHED_MC=y
> > CONFIG_SCHED_MC_PRIO=y
> > # CONFIG_PREEMPT_NONE is not set
> > CONFIG_PREEMPT_VOLUNTARY=y
> > # CONFIG_PREEMPT is not set
> > CONFIG_PREEMPT_COUNT=y
> > CONFIG_X86_LOCAL_APIC=y
> > CONFIG_X86_IO_APIC=y
> > CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
> > CONFIG_X86_MCE=y
> > # CONFIG_X86_MCELOG_LEGACY is not set
> > CONFIG_X86_MCE_INTEL=y
> > CONFIG_X86_MCE_AMD=y
> > CONFIG_X86_MCE_THRESHOLD=y
> > CONFIG_X86_MCE_INJECT=y
> > CONFIG_X86_THERMAL_VECTOR=y
> >
> > #
> > # Performance monitoring
> > #
> > CONFIG_PERF_EVENTS_INTEL_UNCORE=y
> > CONFIG_PERF_EVENTS_INTEL_RAPL=y
> > CONFIG_PERF_EVENTS_INTEL_CSTATE=y
> > # CONFIG_PERF_EVENTS_AMD_POWER is not set
> > # CONFIG_VM86 is not set
> > CONFIG_X86_16BIT=y
> > CONFIG_X86_ESPFIX64=y
> > CONFIG_X86_VSYSCALL_EMULATION=y
> > # CONFIG_I8K is not set
> > CONFIG_MICROCODE=y
> > CONFIG_MICROCODE_INTEL=y
> > CONFIG_MICROCODE_AMD=y
> > CONFIG_MICROCODE_OLD_INTERFACE=y
> > CONFIG_X86_MSR=y
> > CONFIG_X86_CPUID=y
> > # CONFIG_X86_5LEVEL is not set
> > CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
> > CONFIG_ARCH_DMA_ADDR_T_64BIT=y
> > CONFIG_X86_DIRECT_GBPAGES=y
> > CONFIG_ARCH_HAS_MEM_ENCRYPT=y
> > # CONFIG_AMD_MEM_ENCRYPT is not set
> > CONFIG_NUMA=y
> > CONFIG_AMD_NUMA=y
> > CONFIG_X86_64_ACPI_NUMA=y
> > CONFIG_NODES_SPAN_OTHER_NODES=y
> > # CONFIG_NUMA_EMU is not set
> > CONFIG_NODES_SHIFT=6
> > CONFIG_ARCH_SPARSEMEM_ENABLE=y
> > CONFIG_ARCH_SPARSEMEM_DEFAULT=y
> > CONFIG_ARCH_SELECT_MEMORY_MODEL=y
> > CONFIG_ARCH_PROC_KCORE_TEXT=y
> > CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
> > CONFIG_SELECT_MEMORY_MODEL=y
> > CONFIG_SPARSEMEM_MANUAL=y
> > CONFIG_SPARSEMEM=y
> > CONFIG_NEED_MULTIPLE_NODES=y
> > CONFIG_HAVE_MEMORY_PRESENT=y
> > CONFIG_SPARSEMEM_EXTREME=y
> > CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
> > CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
> > CONFIG_SPARSEMEM_VMEMMAP=y
> > CONFIG_HAVE_MEMBLOCK=y
> > CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
> > CONFIG_HAVE_GENERIC_GUP=y
> > CONFIG_ARCH_DISCARD_MEMBLOCK=y
> > # CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
> > # CONFIG_MEMORY_HOTPLUG is not set
> > CONFIG_SPLIT_PTLOCK_CPUS=4
> > CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
> > CONFIG_MEMORY_BALLOON=y
> > CONFIG_BALLOON_COMPACTION=y
> > CONFIG_COMPACTION=y
> > CONFIG_MIGRATION=y
> > CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
> > CONFIG_ARCH_ENABLE_THP_MIGRATION=y
> > CONFIG_PHYS_ADDR_T_64BIT=y
> > CONFIG_BOUNCE=y
> > CONFIG_VIRT_TO_BUS=y
> > CONFIG_MMU_NOTIFIER=y
> > CONFIG_KSM=y
> > CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
> > CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> > # CONFIG_MEMORY_FAILURE is not set
> > CONFIG_TRANSPARENT_HUGEPAGE=y
> > CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
> > # CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
> > CONFIG_ARCH_WANTS_THP_SWAP=y
> > CONFIG_THP_SWAP=y
> > CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
> > # CONFIG_CLEANCACHE is not set
> > CONFIG_FRONTSWAP=y
> > # CONFIG_CMA is not set
> > # CONFIG_MEM_SOFT_DIRTY is not set
> > CONFIG_ZSWAP=y
> > CONFIG_ZPOOL=y
> > # CONFIG_ZBUD is not set
> > # CONFIG_Z3FOLD is not set
> > CONFIG_ZSMALLOC=y
> > # CONFIG_PGTABLE_MAPPING is not set
> > # CONFIG_ZSMALLOC_STAT is not set
> > CONFIG_GENERIC_EARLY_IOREMAP=y
> > # CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
> > # CONFIG_IDLE_PAGE_TRACKING is not set
> > CONFIG_ARCH_HAS_ZONE_DEVICE=y
> > CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
> > CONFIG_ARCH_HAS_PKEYS=y
> > # CONFIG_PERCPU_STATS is not set
> > # CONFIG_GUP_BENCHMARK is not set
> > # CONFIG_X86_PMEM_LEGACY is not set
> > CONFIG_X86_CHECK_BIOS_CORRUPTION=y
> > CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
> > CONFIG_X86_RESERVE_LOW=64
> > CONFIG_MTRR=y
> > CONFIG_MTRR_SANITIZER=y
> > CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
> > CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
> > CONFIG_X86_PAT=y
> > CONFIG_ARCH_USES_PG_UNCACHED=y
> > CONFIG_ARCH_RANDOM=y
> > CONFIG_X86_SMAP=y
> > # CONFIG_X86_INTEL_UMIP is not set
> > CONFIG_X86_INTEL_MPX=y
> > CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
> > CONFIG_EFI=y
> > # CONFIG_EFI_STUB is not set
> > CONFIG_SECCOMP=y
> > # CONFIG_HZ_100 is not set
> > # CONFIG_HZ_250 is not set
> > # CONFIG_HZ_300 is not set
> > CONFIG_HZ_1000=y
> > CONFIG_HZ=1000
> > CONFIG_SCHED_HRTICK=y
> > CONFIG_KEXEC=y
> > # CONFIG_KEXEC_FILE is not set
> > CONFIG_CRASH_DUMP=y
> > # CONFIG_KEXEC_JUMP is not set
> > CONFIG_PHYSICAL_START=0x1000000
> > CONFIG_RELOCATABLE=y
> > # CONFIG_RANDOMIZE_BASE is not set
> > CONFIG_PHYSICAL_ALIGN=0x200000
> > CONFIG_HOTPLUG_CPU=y
> > # CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
> > # CONFIG_DEBUG_HOTPLUG_CPU0 is not set
> > # CONFIG_COMPAT_VDSO is not set
> > # CONFIG_LEGACY_VSYSCALL_NATIVE is not set
> > CONFIG_LEGACY_VSYSCALL_EMULATE=y
> > # CONFIG_LEGACY_VSYSCALL_NONE is not set
> > # CONFIG_CMDLINE_BOOL is not set
> > CONFIG_MODIFY_LDT_SYSCALL=y
> > CONFIG_HAVE_LIVEPATCH=y
> > CONFIG_ARCH_HAS_ADD_PAGES=y
> > CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
> > CONFIG_USE_PERCPU_NUMA_NODE_ID=y
> >
> > #
> > # Power management and ACPI options
> > #
> > CONFIG_ARCH_HIBERNATION_HEADER=y
> > CONFIG_SUSPEND=y
> > CONFIG_SUSPEND_FREEZER=y
> > # CONFIG_SUSPEND_SKIP_SYNC is not set
> > CONFIG_HIBERNATE_CALLBACKS=y
> > CONFIG_HIBERNATION=y
> > CONFIG_PM_STD_PARTITION=""
> > CONFIG_PM_SLEEP=y
> > CONFIG_PM_SLEEP_SMP=y
> > # CONFIG_PM_AUTOSLEEP is not set
> > # CONFIG_PM_WAKELOCKS is not set
> > CONFIG_PM=y
> > CONFIG_PM_DEBUG=y
> > # CONFIG_PM_ADVANCED_DEBUG is not set
> > # CONFIG_PM_TEST_SUSPEND is not set
> > CONFIG_PM_SLEEP_DEBUG=y
> > CONFIG_PM_TRACE=y
> > CONFIG_PM_TRACE_RTC=y
> > CONFIG_PM_CLK=y
> > # CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
> > CONFIG_ACPI=y
> > CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
> > CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
> > CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
> > # CONFIG_ACPI_DEBUGGER is not set
> > CONFIG_ACPI_SPCR_TABLE=y
> > CONFIG_ACPI_LPIT=y
> > CONFIG_ACPI_SLEEP=y
> > # CONFIG_ACPI_PROCFS_POWER is not set
> > CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
> > # CONFIG_ACPI_EC_DEBUGFS is not set
> > CONFIG_ACPI_AC=y
> > CONFIG_ACPI_BATTERY=y
> > CONFIG_ACPI_BUTTON=y
> > CONFIG_ACPI_VIDEO=y
> > CONFIG_ACPI_FAN=y
> > CONFIG_ACPI_DOCK=y
> > CONFIG_ACPI_CPU_FREQ_PSS=y
> > CONFIG_ACPI_PROCESSOR_CSTATE=y
> > CONFIG_ACPI_PROCESSOR_IDLE=y
> > CONFIG_ACPI_CPPC_LIB=y
> > CONFIG_ACPI_PROCESSOR=y
> > CONFIG_ACPI_HOTPLUG_CPU=y
> > # CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
> > CONFIG_ACPI_THERMAL=y
> > CONFIG_ACPI_NUMA=y
> > # CONFIG_ACPI_CUSTOM_DSDT is not set
> > CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
> > CONFIG_ACPI_TABLE_UPGRADE=y
> > # CONFIG_ACPI_DEBUG is not set
> > # CONFIG_ACPI_PCI_SLOT is not set
> > CONFIG_ACPI_CONTAINER=y
> > CONFIG_ACPI_HOTPLUG_IOAPIC=y
> > # CONFIG_ACPI_SBS is not set
> > # CONFIG_ACPI_HED is not set
> > # CONFIG_ACPI_CUSTOM_METHOD is not set
> > # CONFIG_ACPI_BGRT is not set
> > # CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
> > # CONFIG_ACPI_NFIT is not set
> > CONFIG_HAVE_ACPI_APEI=y
> > CONFIG_HAVE_ACPI_APEI_NMI=y
> > # CONFIG_ACPI_APEI is not set
> > # CONFIG_DPTF_POWER is not set
> > # CONFIG_ACPI_EXTLOG is not set
> > # CONFIG_PMIC_OPREGION is not set
> > # CONFIG_ACPI_CONFIGFS is not set
> > CONFIG_X86_PM_TIMER=y
> > # CONFIG_SFI is not set
> >
> > #
> > # CPU Frequency scaling
> > #
> > CONFIG_CPU_FREQ=y
> > CONFIG_CPU_FREQ_GOV_ATTR_SET=y
> > CONFIG_CPU_FREQ_GOV_COMMON=y
> > # CONFIG_CPU_FREQ_STAT is not set
> > # CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
> > # CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
> > CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
> > # CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
> > # CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
> > # CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
> > CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
> > # CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
> > CONFIG_CPU_FREQ_GOV_USERSPACE=y
> > CONFIG_CPU_FREQ_GOV_ONDEMAND=y
> > # CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
> > # CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set
> >
> > #
> > # CPU frequency scaling drivers
> > #
> > CONFIG_X86_INTEL_PSTATE=y
> > # CONFIG_X86_PCC_CPUFREQ is not set
> > CONFIG_X86_ACPI_CPUFREQ=y
> > CONFIG_X86_ACPI_CPUFREQ_CPB=y
> > # CONFIG_X86_POWERNOW_K8 is not set
> > # CONFIG_X86_AMD_FREQ_SENSITIVITY is not set
> > # CONFIG_X86_SPEEDSTEP_CENTRINO is not set
> > # CONFIG_X86_P4_CLOCKMOD is not set
> >
> > #
> > # shared options
> > #
> > # CONFIG_X86_SPEEDSTEP_LIB is not set
> >
> > #
> > # CPU Idle
> > #
> > CONFIG_CPU_IDLE=y
> > # CONFIG_CPU_IDLE_GOV_LADDER is not set
> > CONFIG_CPU_IDLE_GOV_MENU=y
> > # CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
> > # CONFIG_INTEL_IDLE is not set
> >
> > #
> > # Bus options (PCI etc.)
> > #
> > CONFIG_PCI=y
> > CONFIG_PCI_DIRECT=y
> > CONFIG_PCI_MMCONFIG=y
> > CONFIG_PCI_XEN=y
> > CONFIG_PCI_DOMAINS=y
> > # CONFIG_PCI_CNB20LE_QUIRK is not set
> > CONFIG_PCIEPORTBUS=y
> > # CONFIG_HOTPLUG_PCI_PCIE is not set
> > CONFIG_PCIEAER=y
> > # CONFIG_PCIE_ECRC is not set
> > # CONFIG_PCIEAER_INJECT is not set
> > CONFIG_PCIEASPM=y
> > # CONFIG_PCIEASPM_DEBUG is not set
> > CONFIG_PCIEASPM_DEFAULT=y
> > # CONFIG_PCIEASPM_POWERSAVE is not set
> > # CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
> > # CONFIG_PCIEASPM_PERFORMANCE is not set
> > CONFIG_PCIE_PME=y
> > # CONFIG_PCIE_DPC is not set
> > # CONFIG_PCIE_PTM is not set
> > CONFIG_PCI_BUS_ADDR_T_64BIT=y
> > CONFIG_PCI_MSI=y
> > CONFIG_PCI_MSI_IRQ_DOMAIN=y
> > CONFIG_PCI_QUIRKS=y
> > # CONFIG_PCI_DEBUG is not set
> > # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
> > # CONFIG_PCI_STUB is not set
> > CONFIG_XEN_PCIDEV_FRONTEND=y
> > CONFIG_PCI_ATS=y
> > CONFIG_PCI_LOCKLESS_CONFIG=y
> > CONFIG_PCI_IOV=y
> > CONFIG_PCI_PRI=y
> > CONFIG_PCI_PASID=y
> > CONFIG_PCI_LABEL=y
> > CONFIG_HOTPLUG_PCI=y
> > # CONFIG_HOTPLUG_PCI_ACPI is not set
> > # CONFIG_HOTPLUG_PCI_CPCI is not set
> > # CONFIG_HOTPLUG_PCI_SHPC is not set
> >
> > #
> > # Cadence PCIe controllers support
> > #
> >
> > #
> > # DesignWare PCI Core Support
> > #
> > # CONFIG_PCIE_DW_PLAT is not set
> >
> > #
> > # PCI host controller drivers
> > #
> > # CONFIG_VMD is not set
> >
> > #
> > # PCI Endpoint
> > #
> > CONFIG_PCI_ENDPOINT=y
> > # CONFIG_PCI_ENDPOINT_CONFIGFS is not set
> > # CONFIG_PCI_EPF_TEST is not set
> >
> > #
> > # PCI switch controller drivers
> > #
> > # CONFIG_PCI_SW_SWITCHTEC is not set
> > # CONFIG_ISA_BUS is not set
> > CONFIG_ISA_DMA_API=y
> > CONFIG_AMD_NB=y
> > CONFIG_PCCARD=y
> > CONFIG_PCMCIA=y
> > CONFIG_PCMCIA_LOAD_CIS=y
> > CONFIG_CARDBUS=y
> >
> > #
> > # PC-card bridges
> > #
> > CONFIG_YENTA=y
> > CONFIG_YENTA_O2=y
> > CONFIG_YENTA_RICOH=y
> > CONFIG_YENTA_TI=y
> > CONFIG_YENTA_ENE_TUNE=y
> > CONFIG_YENTA_TOSHIBA=y
> > # CONFIG_PD6729 is not set
> > # CONFIG_I82092 is not set
> > CONFIG_PCCARD_NONSTATIC=y
> > # CONFIG_RAPIDIO is not set
> > # CONFIG_X86_SYSFB is not set
> >
> > #
> > # Executable file formats / Emulations
> > #
> > CONFIG_BINFMT_ELF=y
> > CONFIG_COMPAT_BINFMT_ELF=y
> > CONFIG_ELFCORE=y
> > CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
> > CONFIG_BINFMT_SCRIPT=y
> > # CONFIG_HAVE_AOUT is not set
> > CONFIG_BINFMT_MISC=y
> > CONFIG_COREDUMP=y
> > CONFIG_IA32_EMULATION=y
> > # CONFIG_IA32_AOUT is not set
> > CONFIG_X86_X32=y
> > CONFIG_COMPAT_32=y
> > CONFIG_COMPAT=y
> > CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
> > CONFIG_SYSVIPC_COMPAT=y
> > CONFIG_X86_DEV_DMA_OPS=y
> > CONFIG_NET=y
> > CONFIG_NET_INGRESS=y
> > CONFIG_NET_EGRESS=y
> >
> > #
> > # Networking options
> > #
> > CONFIG_PACKET=y
> > # CONFIG_PACKET_DIAG is not set
> > CONFIG_UNIX=y
> > # CONFIG_UNIX_DIAG is not set
> > CONFIG_TLS=y
> > CONFIG_XFRM=y
> > CONFIG_XFRM_OFFLOAD=y
> > CONFIG_XFRM_ALGO=y
> > CONFIG_XFRM_USER=y
> > CONFIG_XFRM_SUB_POLICY=y
> > CONFIG_XFRM_MIGRATE=y
> > CONFIG_XFRM_STATISTICS=y
> > CONFIG_XFRM_IPCOMP=y
> > CONFIG_NET_KEY=y
> > CONFIG_NET_KEY_MIGRATE=y
> > CONFIG_SMC=y
> > # CONFIG_SMC_DIAG is not set
> > CONFIG_INET=y
> > CONFIG_IP_MULTICAST=y
> > CONFIG_IP_ADVANCED_ROUTER=y
> > # CONFIG_IP_FIB_TRIE_STATS is not set
> > CONFIG_IP_MULTIPLE_TABLES=y
> > CONFIG_IP_ROUTE_MULTIPATH=y
> > CONFIG_IP_ROUTE_VERBOSE=y
> > CONFIG_IP_ROUTE_CLASSID=y
> > CONFIG_IP_PNP=y
> > CONFIG_IP_PNP_DHCP=y
> > CONFIG_IP_PNP_BOOTP=y
> > CONFIG_IP_PNP_RARP=y
> > CONFIG_NET_IPIP=y
> > CONFIG_NET_IPGRE_DEMUX=y
> > CONFIG_NET_IP_TUNNEL=y
> > CONFIG_NET_IPGRE=y
> > CONFIG_NET_IPGRE_BROADCAST=y
> > CONFIG_IP_MROUTE=y
> > CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
> > CONFIG_IP_PIMSM_V1=y
> > CONFIG_IP_PIMSM_V2=y
> > CONFIG_SYN_COOKIES=y
> > CONFIG_NET_IPVTI=y
> > CONFIG_NET_UDP_TUNNEL=y
> > CONFIG_NET_FOU=y
> > CONFIG_NET_FOU_IP_TUNNELS=y
> > # CONFIG_INET_AH is not set
> > # CONFIG_INET_ESP is not set
> > CONFIG_INET_IPCOMP=y
> > CONFIG_INET_XFRM_TUNNEL=y
> > CONFIG_INET_TUNNEL=y
> > CONFIG_INET_XFRM_MODE_TRANSPORT=y
> > CONFIG_INET_XFRM_MODE_TUNNEL=y
> > CONFIG_INET_XFRM_MODE_BEET=y
> > # CONFIG_INET_DIAG is not set
> > CONFIG_TCP_CONG_ADVANCED=y
> > # CONFIG_TCP_CONG_BIC is not set
> > CONFIG_TCP_CONG_CUBIC=y
> > # CONFIG_TCP_CONG_WESTWOOD is not set
> > # CONFIG_TCP_CONG_HTCP is not set
> > # CONFIG_TCP_CONG_HSTCP is not set
> > # CONFIG_TCP_CONG_HYBLA is not set
> > CONFIG_TCP_CONG_VEGAS=y
> > CONFIG_TCP_CONG_NV=y
> > CONFIG_TCP_CONG_SCALABLE=y
> > CONFIG_TCP_CONG_LP=y
> > CONFIG_TCP_CONG_VENO=y
> > CONFIG_TCP_CONG_YEAH=y
> > # CONFIG_TCP_CONG_ILLINOIS is not set
> > # CONFIG_TCP_CONG_DCTCP is not set
> > # CONFIG_TCP_CONG_CDG is not set
> > # CONFIG_TCP_CONG_BBR is not set
> > CONFIG_DEFAULT_CUBIC=y
> > # CONFIG_DEFAULT_VEGAS is not set
> > # CONFIG_DEFAULT_VENO is not set
> > # CONFIG_DEFAULT_RENO is not set
> > CONFIG_DEFAULT_TCP_CONG="cubic"
> > CONFIG_TCP_MD5SIG=y
> > CONFIG_IPV6=y
> > CONFIG_IPV6_ROUTER_PREF=y
> > CONFIG_IPV6_ROUTE_INFO=y
> > CONFIG_IPV6_OPTIMISTIC_DAD=y
> > CONFIG_INET6_AH=y
> > CONFIG_INET6_ESP=y
> > CONFIG_INET6_ESP_OFFLOAD=y
> > CONFIG_INET6_IPCOMP=y
> > CONFIG_IPV6_MIP6=y
> > CONFIG_IPV6_ILA=y
> > CONFIG_INET6_XFRM_TUNNEL=y
> > CONFIG_INET6_TUNNEL=y
> > CONFIG_INET6_XFRM_MODE_TRANSPORT=y
> > CONFIG_INET6_XFRM_MODE_TUNNEL=y
> > CONFIG_INET6_XFRM_MODE_BEET=y
> > CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
> > CONFIG_IPV6_VTI=y
> > CONFIG_IPV6_SIT=y
> > CONFIG_IPV6_SIT_6RD=y
> > CONFIG_IPV6_NDISC_NODETYPE=y
> > CONFIG_IPV6_TUNNEL=y
> > CONFIG_IPV6_GRE=y
> > CONFIG_IPV6_FOU=y
> > CONFIG_IPV6_FOU_TUNNEL=y
> > CONFIG_IPV6_MULTIPLE_TABLES=y
> > CONFIG_IPV6_SUBTREES=y
> > CONFIG_IPV6_MROUTE=y
> > CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
> > CONFIG_IPV6_PIMSM_V2=y
> > CONFIG_IPV6_SEG6_LWTUNNEL=y
> > CONFIG_IPV6_SEG6_HMAC=y
> > CONFIG_NETLABEL=y
> > CONFIG_NETWORK_SECMARK=y
> > CONFIG_NET_PTP_CLASSIFY=y
> > # CONFIG_NETWORK_PHY_TIMESTAMPING is not set
> > CONFIG_NETFILTER=y
> > CONFIG_NETFILTER_ADVANCED=y
> > CONFIG_BRIDGE_NETFILTER=y
> >
> > #
> > # Core Netfilter Configuration
> > #
> > CONFIG_NETFILTER_INGRESS=y
> > CONFIG_NETFILTER_NETLINK=y
> > CONFIG_NETFILTER_FAMILY_BRIDGE=y
> > CONFIG_NETFILTER_FAMILY_ARP=y
> > CONFIG_NETFILTER_NETLINK_ACCT=y
> > CONFIG_NETFILTER_NETLINK_QUEUE=y
> > CONFIG_NETFILTER_NETLINK_LOG=y
> > CONFIG_NF_CONNTRACK=y
> > CONFIG_NF_LOG_COMMON=y
> > CONFIG_NF_LOG_NETDEV=y
> > CONFIG_NETFILTER_CONNCOUNT=y
> > CONFIG_NF_CONNTRACK_MARK=y
> > CONFIG_NF_CONNTRACK_SECMARK=y
> > CONFIG_NF_CONNTRACK_ZONES=y
> > CONFIG_NF_CONNTRACK_PROCFS=y
> > CONFIG_NF_CONNTRACK_EVENTS=y
> > CONFIG_NF_CONNTRACK_TIMEOUT=y
> > CONFIG_NF_CONNTRACK_TIMESTAMP=y
> > CONFIG_NF_CONNTRACK_LABELS=y
> > CONFIG_NF_CT_PROTO_DCCP=y
> > CONFIG_NF_CT_PROTO_GRE=y
> > CONFIG_NF_CT_PROTO_SCTP=y
> > CONFIG_NF_CT_PROTO_UDPLITE=y
> > CONFIG_NF_CONNTRACK_AMANDA=y
> > CONFIG_NF_CONNTRACK_FTP=y
> > CONFIG_NF_CONNTRACK_H323=y
> > CONFIG_NF_CONNTRACK_IRC=y
> > CONFIG_NF_CONNTRACK_BROADCAST=y
> > CONFIG_NF_CONNTRACK_NETBIOS_NS=y
> > CONFIG_NF_CONNTRACK_SNMP=y
> > CONFIG_NF_CONNTRACK_PPTP=y
> > CONFIG_NF_CONNTRACK_SANE=y
> > CONFIG_NF_CONNTRACK_SIP=y
> > CONFIG_NF_CONNTRACK_TFTP=y
> > CONFIG_NF_CT_NETLINK=y
> > CONFIG_NF_CT_NETLINK_TIMEOUT=y
> > CONFIG_NF_CT_NETLINK_HELPER=y
> > CONFIG_NETFILTER_NETLINK_GLUE_CT=y
> > CONFIG_NF_NAT=y
> > CONFIG_NF_NAT_NEEDED=y
> > CONFIG_NF_NAT_PROTO_DCCP=y
> > CONFIG_NF_NAT_PROTO_UDPLITE=y
> > CONFIG_NF_NAT_PROTO_SCTP=y
> > CONFIG_NF_NAT_AMANDA=y
> > CONFIG_NF_NAT_FTP=y
> > CONFIG_NF_NAT_IRC=y
> > CONFIG_NF_NAT_SIP=y
> > CONFIG_NF_NAT_TFTP=y
> > CONFIG_NF_NAT_REDIRECT=y
> > CONFIG_NETFILTER_SYNPROXY=y
> > CONFIG_NF_TABLES=y
> > CONFIG_NF_TABLES_INET=y
> > CONFIG_NF_TABLES_NETDEV=y
> > CONFIG_NFT_EXTHDR=y
> > CONFIG_NFT_META=y
> > CONFIG_NFT_RT=y
> > CONFIG_NFT_NUMGEN=y
> > CONFIG_NFT_CT=y
> > CONFIG_NFT_FLOW_OFFLOAD=y
> > CONFIG_NFT_SET_RBTREE=y
> > CONFIG_NFT_SET_HASH=y
> > CONFIG_NFT_SET_BITMAP=y
> > CONFIG_NFT_COUNTER=y
> > CONFIG_NFT_LOG=y
> > CONFIG_NFT_LIMIT=y
> > CONFIG_NFT_MASQ=y
> > CONFIG_NFT_REDIR=y
> > CONFIG_NFT_NAT=y
> > CONFIG_NFT_OBJREF=y
> > CONFIG_NFT_QUEUE=y
> > CONFIG_NFT_QUOTA=y
> > CONFIG_NFT_REJECT=y
> > CONFIG_NFT_REJECT_INET=y
> > CONFIG_NFT_COMPAT=y
> > CONFIG_NFT_HASH=y
> > CONFIG_NFT_FIB=y
> > CONFIG_NFT_FIB_INET=y
> > CONFIG_NF_DUP_NETDEV=y
> > CONFIG_NFT_DUP_NETDEV=y
> > CONFIG_NFT_FWD_NETDEV=y
> > CONFIG_NFT_FIB_NETDEV=y
> > CONFIG_NF_FLOW_TABLE_INET=y
> > CONFIG_NF_FLOW_TABLE=y
> > CONFIG_NETFILTER_XTABLES=y
> >
> > #
> > # Xtables combined modules
> > #
> > CONFIG_NETFILTER_XT_MARK=y
> > CONFIG_NETFILTER_XT_CONNMARK=y
> > CONFIG_NETFILTER_XT_SET=y
> >
> > #
> > # Xtables targets
> > #
> > CONFIG_NETFILTER_XT_TARGET_AUDIT=y
> > CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
> > CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
> > CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
> > CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
> > CONFIG_NETFILTER_XT_TARGET_CT=y
> > CONFIG_NETFILTER_XT_TARGET_DSCP=y
> > CONFIG_NETFILTER_XT_TARGET_HL=y
> > CONFIG_NETFILTER_XT_TARGET_HMARK=y
> > CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
> > CONFIG_NETFILTER_XT_TARGET_LED=y
> > CONFIG_NETFILTER_XT_TARGET_LOG=y
> > CONFIG_NETFILTER_XT_TARGET_MARK=y
> > CONFIG_NETFILTER_XT_NAT=y
> > CONFIG_NETFILTER_XT_TARGET_NETMAP=y
> > CONFIG_NETFILTER_XT_TARGET_NFLOG=y
> > CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
> > CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
> > CONFIG_NETFILTER_XT_TARGET_RATEEST=y
> > CONFIG_NETFILTER_XT_TARGET_REDIRECT=y
> > CONFIG_NETFILTER_XT_TARGET_TEE=y
> > CONFIG_NETFILTER_XT_TARGET_TPROXY=y
> > CONFIG_NETFILTER_XT_TARGET_TRACE=y
> > CONFIG_NETFILTER_XT_TARGET_SECMARK=y
> > CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
> > CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y
> >
> > #
> > # Xtables matches
> > #
> > CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
> > CONFIG_NETFILTER_XT_MATCH_BPF=y
> > CONFIG_NETFILTER_XT_MATCH_CGROUP=y
> > CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
> > CONFIG_NETFILTER_XT_MATCH_COMMENT=y
> > CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
> > CONFIG_NETFILTER_XT_MATCH_CONNLABEL=y
> > CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
> > CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
> > CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
> > CONFIG_NETFILTER_XT_MATCH_CPU=y
> > CONFIG_NETFILTER_XT_MATCH_DCCP=y
> > CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
> > CONFIG_NETFILTER_XT_MATCH_DSCP=y
> > CONFIG_NETFILTER_XT_MATCH_ECN=y
> > CONFIG_NETFILTER_XT_MATCH_ESP=y
> > CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
> > CONFIG_NETFILTER_XT_MATCH_HELPER=y
> > CONFIG_NETFILTER_XT_MATCH_HL=y
> > CONFIG_NETFILTER_XT_MATCH_IPCOMP=y
> > CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
> > CONFIG_NETFILTER_XT_MATCH_IPVS=y
> > CONFIG_NETFILTER_XT_MATCH_L2TP=y
> > CONFIG_NETFILTER_XT_MATCH_LENGTH=y
> > CONFIG_NETFILTER_XT_MATCH_LIMIT=y
> > CONFIG_NETFILTER_XT_MATCH_MAC=y
> > CONFIG_NETFILTER_XT_MATCH_MARK=y
> > CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
> > CONFIG_NETFILTER_XT_MATCH_NFACCT=y
> > CONFIG_NETFILTER_XT_MATCH_OSF=y
> > CONFIG_NETFILTER_XT_MATCH_OWNER=y
> > CONFIG_NETFILTER_XT_MATCH_POLICY=y
> > CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
> > CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
> > CONFIG_NETFILTER_XT_MATCH_QUOTA=y
> > CONFIG_NETFILTER_XT_MATCH_RATEEST=y
> > CONFIG_NETFILTER_XT_MATCH_REALM=y
> > CONFIG_NETFILTER_XT_MATCH_RECENT=y
> > CONFIG_NETFILTER_XT_MATCH_SCTP=y
> > CONFIG_NETFILTER_XT_MATCH_SOCKET=y
> > CONFIG_NETFILTER_XT_MATCH_STATE=y
> > CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
> > CONFIG_NETFILTER_XT_MATCH_STRING=y
> > CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
> > CONFIG_NETFILTER_XT_MATCH_TIME=y
> > CONFIG_NETFILTER_XT_MATCH_U32=y
> > CONFIG_IP_SET=y
> > CONFIG_IP_SET_MAX=256
> > CONFIG_IP_SET_BITMAP_IP=y
> > CONFIG_IP_SET_BITMAP_IPMAC=y
> > CONFIG_IP_SET_BITMAP_PORT=y
> > CONFIG_IP_SET_HASH_IP=y
> > CONFIG_IP_SET_HASH_IPMARK=y
> > CONFIG_IP_SET_HASH_IPPORT=y
> > CONFIG_IP_SET_HASH_IPPORTIP=y
> > CONFIG_IP_SET_HASH_IPPORTNET=y
> > CONFIG_IP_SET_HASH_IPMAC=y
> > CONFIG_IP_SET_HASH_MAC=y
> > CONFIG_IP_SET_HASH_NETPORTNET=y
> > CONFIG_IP_SET_HASH_NET=y
> > CONFIG_IP_SET_HASH_NETNET=y
> > CONFIG_IP_SET_HASH_NETPORT=y
> > CONFIG_IP_SET_HASH_NETIFACE=y
> > CONFIG_IP_SET_LIST_SET=y
> > CONFIG_IP_VS=y
> > CONFIG_IP_VS_IPV6=y
> > # CONFIG_IP_VS_DEBUG is not set
> > CONFIG_IP_VS_TAB_BITS=12
> >
> > #
> > # IPVS transport protocol load balancing support
> > #
> > CONFIG_IP_VS_PROTO_TCP=y
> > CONFIG_IP_VS_PROTO_UDP=y
> > CONFIG_IP_VS_PROTO_AH_ESP=y
> > CONFIG_IP_VS_PROTO_ESP=y
> > CONFIG_IP_VS_PROTO_AH=y
> > CONFIG_IP_VS_PROTO_SCTP=y
> >
> > #
> > # IPVS scheduler
> > #
> > # CONFIG_IP_VS_RR is not set
> > # CONFIG_IP_VS_WRR is not set
> > # CONFIG_IP_VS_LC is not set
> > CONFIG_IP_VS_WLC=y
> > # CONFIG_IP_VS_FO is not set
> > # CONFIG_IP_VS_OVF is not set
> > # CONFIG_IP_VS_LBLC is not set
> > # CONFIG_IP_VS_LBLCR is not set
> > # CONFIG_IP_VS_DH is not set
> > # CONFIG_IP_VS_SH is not set
> > # CONFIG_IP_VS_SED is not set
> > # CONFIG_IP_VS_NQ is not set
> >
> > #
> > # IPVS SH scheduler
> > #
> > CONFIG_IP_VS_SH_TAB_BITS=8
> >
> > #
> > # IPVS application helper
> > #
> > CONFIG_IP_VS_FTP=y
> > CONFIG_IP_VS_NFCT=y
> > CONFIG_IP_VS_PE_SIP=y
> >
> > #
> > # IP: Netfilter Configuration
> > #
> > CONFIG_NF_DEFRAG_IPV4=y
> > CONFIG_NF_CONNTRACK_IPV4=y
> > CONFIG_NF_SOCKET_IPV4=y
> > CONFIG_NF_TABLES_IPV4=y
> > CONFIG_NFT_CHAIN_ROUTE_IPV4=y
> > CONFIG_NFT_REJECT_IPV4=y
> > CONFIG_NFT_DUP_IPV4=y
> > CONFIG_NFT_FIB_IPV4=y
> > CONFIG_NF_TABLES_ARP=y
> > CONFIG_NF_FLOW_TABLE_IPV4=y
> > CONFIG_NF_DUP_IPV4=y
> > CONFIG_NF_LOG_ARP=y
> > CONFIG_NF_LOG_IPV4=y
> > CONFIG_NF_REJECT_IPV4=y
> > CONFIG_NF_NAT_IPV4=y
> > CONFIG_NFT_CHAIN_NAT_IPV4=y
> > CONFIG_NF_NAT_MASQUERADE_IPV4=y
> > CONFIG_NFT_MASQ_IPV4=y
> > CONFIG_NFT_REDIR_IPV4=y
> > CONFIG_NF_NAT_SNMP_BASIC=y
> > CONFIG_NF_NAT_PROTO_GRE=y
> > CONFIG_NF_NAT_PPTP=y
> > CONFIG_NF_NAT_H323=y
> > CONFIG_IP_NF_IPTABLES=y
> > CONFIG_IP_NF_MATCH_AH=y
> > CONFIG_IP_NF_MATCH_ECN=y
> > CONFIG_IP_NF_MATCH_RPFILTER=y
> > CONFIG_IP_NF_MATCH_TTL=y
> > CONFIG_IP_NF_FILTER=y
> > CONFIG_IP_NF_TARGET_REJECT=y
> > CONFIG_IP_NF_TARGET_SYNPROXY=y
> > CONFIG_IP_NF_NAT=y
> > CONFIG_IP_NF_TARGET_MASQUERADE=y
> > CONFIG_IP_NF_TARGET_NETMAP=y
> > CONFIG_IP_NF_TARGET_REDIRECT=y
> > CONFIG_IP_NF_MANGLE=y
> > CONFIG_IP_NF_TARGET_CLUSTERIP=y
> > CONFIG_IP_NF_TARGET_ECN=y
> > CONFIG_IP_NF_TARGET_TTL=y
> > CONFIG_IP_NF_RAW=y
> > CONFIG_IP_NF_SECURITY=y
> > CONFIG_IP_NF_ARPTABLES=y
> > CONFIG_IP_NF_ARPFILTER=y
> > CONFIG_IP_NF_ARP_MANGLE=y
> >
> > #
> > # IPv6: Netfilter Configuration
> > #
> > CONFIG_NF_DEFRAG_IPV6=y
> > CONFIG_NF_CONNTRACK_IPV6=y
> > CONFIG_NF_SOCKET_IPV6=y
> > CONFIG_NF_TABLES_IPV6=y
> > CONFIG_NFT_CHAIN_ROUTE_IPV6=y
> > CONFIG_NFT_REJECT_IPV6=y
> > CONFIG_NFT_DUP_IPV6=y
> > CONFIG_NFT_FIB_IPV6=y
> > CONFIG_NF_FLOW_TABLE_IPV6=y
> > CONFIG_NF_DUP_IPV6=y
> > CONFIG_NF_REJECT_IPV6=y
> > CONFIG_NF_LOG_IPV6=y
> > CONFIG_NF_NAT_IPV6=y
> > CONFIG_NFT_CHAIN_NAT_IPV6=y
> > CONFIG_NF_NAT_MASQUERADE_IPV6=y
> > CONFIG_NFT_MASQ_IPV6=y
> > CONFIG_NFT_REDIR_IPV6=y
> > CONFIG_IP6_NF_IPTABLES=y
> > CONFIG_IP6_NF_MATCH_AH=y
> > CONFIG_IP6_NF_MATCH_EUI64=y
> > CONFIG_IP6_NF_MATCH_FRAG=y
> > CONFIG_IP6_NF_MATCH_OPTS=y
> > CONFIG_IP6_NF_MATCH_HL=y
> > CONFIG_IP6_NF_MATCH_IPV6HEADER=y
> > CONFIG_IP6_NF_MATCH_MH=y
> > CONFIG_IP6_NF_MATCH_RPFILTER=y
> > CONFIG_IP6_NF_MATCH_RT=y
> > CONFIG_IP6_NF_MATCH_SRH=y
> > CONFIG_IP6_NF_TARGET_HL=y
> > CONFIG_IP6_NF_FILTER=y
> > CONFIG_IP6_NF_TARGET_REJECT=y
> > CONFIG_IP6_NF_TARGET_SYNPROXY=y
> > CONFIG_IP6_NF_MANGLE=y
> > CONFIG_IP6_NF_RAW=y
> > CONFIG_IP6_NF_SECURITY=y
> > CONFIG_IP6_NF_NAT=y
> > CONFIG_IP6_NF_TARGET_MASQUERADE=y
> > CONFIG_IP6_NF_TARGET_NPT=y
> > CONFIG_NF_TABLES_BRIDGE=y
> > CONFIG_NFT_BRIDGE_META=y
> > CONFIG_NFT_BRIDGE_REJECT=y
> > CONFIG_NF_LOG_BRIDGE=y
> > CONFIG_BRIDGE_NF_EBTABLES=y
> > CONFIG_BRIDGE_EBT_BROUTE=y
> > CONFIG_BRIDGE_EBT_T_FILTER=y
> > CONFIG_BRIDGE_EBT_T_NAT=y
> > CONFIG_BRIDGE_EBT_802_3=y
> > CONFIG_BRIDGE_EBT_AMONG=y
> > CONFIG_BRIDGE_EBT_ARP=y
> > CONFIG_BRIDGE_EBT_IP=y
> > CONFIG_BRIDGE_EBT_IP6=y
> > CONFIG_BRIDGE_EBT_LIMIT=y
> > CONFIG_BRIDGE_EBT_MARK=y
> > CONFIG_BRIDGE_EBT_PKTTYPE=y
> > CONFIG_BRIDGE_EBT_STP=y
> > CONFIG_BRIDGE_EBT_VLAN=y
> > CONFIG_BRIDGE_EBT_ARPREPLY=y
> > CONFIG_BRIDGE_EBT_DNAT=y
> > CONFIG_BRIDGE_EBT_MARK_T=y
> > CONFIG_BRIDGE_EBT_REDIRECT=y
> > CONFIG_BRIDGE_EBT_SNAT=y
> > CONFIG_BRIDGE_EBT_LOG=y
> > CONFIG_BRIDGE_EBT_NFLOG=y
> > CONFIG_IP_DCCP=y
> >
> > #
> > # DCCP CCIDs Configuration
> > #
> > # CONFIG_IP_DCCP_CCID2_DEBUG is not set
> > CONFIG_IP_DCCP_CCID3=y
> > # CONFIG_IP_DCCP_CCID3_DEBUG is not set
> > CONFIG_IP_DCCP_TFRC_LIB=y
> >
> > #
> > # DCCP Kernel Hacking
> > #
> > # CONFIG_IP_DCCP_DEBUG is not set
> > CONFIG_IP_SCTP=y
> > # CONFIG_SCTP_DBG_OBJCNT is not set
> > CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
> > # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
> > # CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
> > CONFIG_SCTP_COOKIE_HMAC_MD5=y
> > CONFIG_SCTP_COOKIE_HMAC_SHA1=y
> > CONFIG_RDS=y
> > CONFIG_RDS_RDMA=y
> > CONFIG_RDS_TCP=y
> > # CONFIG_RDS_DEBUG is not set
> > CONFIG_TIPC=y
> > CONFIG_TIPC_MEDIA_IB=y
> > CONFIG_TIPC_MEDIA_UDP=y
> > CONFIG_ATM=y
> > CONFIG_ATM_CLIP=y
> > # CONFIG_ATM_CLIP_NO_ICMP is not set
> > CONFIG_ATM_LANE=y
> > CONFIG_ATM_MPOA=y
> > CONFIG_ATM_BR2684=y
> > # CONFIG_ATM_BR2684_IPFILTER is not set
> > CONFIG_L2TP=y
> > # CONFIG_L2TP_DEBUGFS is not set
> > # CONFIG_L2TP_V3 is not set
> > CONFIG_STP=y
> > CONFIG_GARP=y
> > CONFIG_MRP=y
> > CONFIG_BRIDGE=y
> > CONFIG_BRIDGE_IGMP_SNOOPING=y
> > CONFIG_BRIDGE_VLAN_FILTERING=y
> > CONFIG_HAVE_NET_DSA=y
> > CONFIG_NET_DSA=y
> > CONFIG_NET_DSA_LEGACY=y
> > CONFIG_VLAN_8021Q=y
> > CONFIG_VLAN_8021Q_GVRP=y
> > CONFIG_VLAN_8021Q_MVRP=y
> > # CONFIG_DECNET is not set
> > CONFIG_LLC=y
> > CONFIG_LLC2=y
> > # CONFIG_ATALK is not set
> > # CONFIG_X25 is not set
> > # CONFIG_LAPB is not set
> > # CONFIG_PHONET is not set
> > CONFIG_6LOWPAN=y
> > # CONFIG_6LOWPAN_DEBUGFS is not set
> > CONFIG_6LOWPAN_NHC=y
> > CONFIG_6LOWPAN_NHC_DEST=y
> > CONFIG_6LOWPAN_NHC_FRAGMENT=y
> > CONFIG_6LOWPAN_NHC_HOP=y
> > CONFIG_6LOWPAN_NHC_IPV6=y
> > CONFIG_6LOWPAN_NHC_MOBILITY=y
> > CONFIG_6LOWPAN_NHC_ROUTING=y
> > CONFIG_6LOWPAN_NHC_UDP=y
> > CONFIG_6LOWPAN_GHC_EXT_HDR_HOP=y
> > CONFIG_6LOWPAN_GHC_UDP=y
> > CONFIG_6LOWPAN_GHC_ICMPV6=y
> > CONFIG_6LOWPAN_GHC_EXT_HDR_DEST=y
> > CONFIG_6LOWPAN_GHC_EXT_HDR_FRAG=y
> > CONFIG_6LOWPAN_GHC_EXT_HDR_ROUTE=y
> > CONFIG_IEEE802154=y
> > CONFIG_IEEE802154_NL802154_EXPERIMENTAL=y
> > CONFIG_IEEE802154_SOCKET=y
> > CONFIG_IEEE802154_6LOWPAN=y
> > CONFIG_MAC802154=y
> > CONFIG_NET_SCHED=y
> >
> > #
> > # Queueing/Scheduling
> > #
> > CONFIG_NET_SCH_CBQ=y
> > CONFIG_NET_SCH_HTB=y
> > CONFIG_NET_SCH_HFSC=y
> > CONFIG_NET_SCH_ATM=y
> > CONFIG_NET_SCH_PRIO=y
> > CONFIG_NET_SCH_MULTIQ=y
> > CONFIG_NET_SCH_RED=y
> > CONFIG_NET_SCH_SFB=y
> > CONFIG_NET_SCH_SFQ=y
> > CONFIG_NET_SCH_TEQL=y
> > CONFIG_NET_SCH_TBF=y
> > CONFIG_NET_SCH_CBS=y
> > CONFIG_NET_SCH_GRED=y
> > CONFIG_NET_SCH_DSMARK=y
> > CONFIG_NET_SCH_NETEM=y
> > # CONFIG_NET_SCH_DRR is not set
> > # CONFIG_NET_SCH_MQPRIO is not set
> > # CONFIG_NET_SCH_CHOKE is not set
> > # CONFIG_NET_SCH_QFQ is not set
> > # CONFIG_NET_SCH_CODEL is not set
> > # CONFIG_NET_SCH_FQ_CODEL is not set
> > # CONFIG_NET_SCH_FQ is not set
> > # CONFIG_NET_SCH_HHF is not set
> > # CONFIG_NET_SCH_PIE is not set
> > CONFIG_NET_SCH_INGRESS=y
> > # CONFIG_NET_SCH_PLUG is not set
> > CONFIG_NET_SCH_DEFAULT=y
> > # CONFIG_DEFAULT_SFQ is not set
> > CONFIG_DEFAULT_PFIFO_FAST=y
> > CONFIG_DEFAULT_NET_SCH="pfifo_fast"
> >
> > #
> > # Classification
> > #
> > CONFIG_NET_CLS=y
> > CONFIG_NET_CLS_BASIC=y
> > CONFIG_NET_CLS_TCINDEX=y
> > CONFIG_NET_CLS_ROUTE4=y
> > CONFIG_NET_CLS_FW=y
> > CONFIG_NET_CLS_U32=y
> > # CONFIG_CLS_U32_PERF is not set
> > CONFIG_CLS_U32_MARK=y
> > CONFIG_NET_CLS_RSVP=y
> > CONFIG_NET_CLS_RSVP6=y
> > CONFIG_NET_CLS_FLOW=y
> > # CONFIG_NET_CLS_CGROUP is not set
> > CONFIG_NET_CLS_BPF=y
> > CONFIG_NET_CLS_FLOWER=y
> > # CONFIG_NET_CLS_MATCHALL is not set
> > CONFIG_NET_EMATCH=y
> > CONFIG_NET_EMATCH_STACK=32
> > CONFIG_NET_EMATCH_CMP=y
> > CONFIG_NET_EMATCH_NBYTE=y
> > CONFIG_NET_EMATCH_U32=y
> > CONFIG_NET_EMATCH_META=y
> > CONFIG_NET_EMATCH_TEXT=y
> > # CONFIG_NET_EMATCH_CANID is not set
> > CONFIG_NET_EMATCH_IPSET=y
> > CONFIG_NET_CLS_ACT=y
> > CONFIG_NET_ACT_POLICE=y
> > # CONFIG_NET_ACT_GACT is not set
> > # CONFIG_NET_ACT_MIRRED is not set
> > CONFIG_NET_ACT_SAMPLE=y
> > # CONFIG_NET_ACT_IPT is not set
> > CONFIG_NET_ACT_NAT=y
> > CONFIG_NET_ACT_PEDIT=y
> > CONFIG_NET_ACT_SIMP=y
> > # CONFIG_NET_ACT_SKBEDIT is not set
> > # CONFIG_NET_ACT_CSUM is not set
> > # CONFIG_NET_ACT_VLAN is not set
> > CONFIG_NET_ACT_BPF=y
> > # CONFIG_NET_ACT_CONNMARK is not set
> > # CONFIG_NET_ACT_SKBMOD is not set
> > # CONFIG_NET_ACT_IFE is not set
> > # CONFIG_NET_ACT_TUNNEL_KEY is not set
> > # CONFIG_NET_CLS_IND is not set
> > CONFIG_NET_SCH_FIFO=y
> > CONFIG_DCB=y
> > CONFIG_DNS_RESOLVER=y
> > # CONFIG_BATMAN_ADV is not set
> > CONFIG_OPENVSWITCH=y
> > CONFIG_OPENVSWITCH_GRE=y
> > CONFIG_VSOCKETS=y
> > CONFIG_VSOCKETS_DIAG=y
> > CONFIG_VIRTIO_VSOCKETS=y
> > CONFIG_VIRTIO_VSOCKETS_COMMON=y
> > # CONFIG_NETLINK_DIAG is not set
> > CONFIG_MPLS=y
> > CONFIG_NET_MPLS_GSO=y
> > CONFIG_MPLS_ROUTING=y
> > CONFIG_MPLS_IPTUNNEL=y
> > CONFIG_NET_NSH=y
> > # CONFIG_HSR is not set
> > CONFIG_NET_SWITCHDEV=y
> > CONFIG_NET_L3_MASTER_DEV=y
> > CONFIG_NET_NCSI=y
> > CONFIG_RPS=y
> > CONFIG_RFS_ACCEL=y
> > CONFIG_XPS=y
> > CONFIG_CGROUP_NET_PRIO=y
> > CONFIG_CGROUP_NET_CLASSID=y
> > CONFIG_NET_RX_BUSY_POLL=y
> > CONFIG_BQL=y
> > CONFIG_BPF_JIT=y
> > CONFIG_BPF_STREAM_PARSER=y
> > CONFIG_NET_FLOW_LIMIT=y
> >
> > #
> > # Network testing
> > #
> > # CONFIG_NET_PKTGEN is not set
> > # CONFIG_NET_DROP_MONITOR is not set
> > CONFIG_HAMRADIO=y
> >
> > #
> > # Packet Radio protocols
> > #
> > # CONFIG_AX25 is not set
> > CONFIG_CAN=y
> > CONFIG_CAN_RAW=y
> > CONFIG_CAN_BCM=y
> > CONFIG_CAN_GW=y
> >
> > #
> > # CAN Device Drivers
> > #
> > CONFIG_CAN_VCAN=y
> > CONFIG_CAN_VXCAN=y
> > CONFIG_CAN_SLCAN=y
> > CONFIG_CAN_DEV=y
> > CONFIG_CAN_CALC_BITTIMING=y
> > # CONFIG_CAN_LEDS is not set
> > # CONFIG_CAN_C_CAN is not set
> > # CONFIG_CAN_CC770 is not set
> > CONFIG_CAN_IFI_CANFD=y
> > # CONFIG_CAN_M_CAN is not set
> > # CONFIG_CAN_PEAK_PCIEFD is not set
> > # CONFIG_CAN_SJA1000 is not set
> > # CONFIG_CAN_SOFTING is not set
> >
> > #
> > # CAN USB interfaces
> > #
> > # CONFIG_CAN_EMS_USB is not set
> > # CONFIG_CAN_ESD_USB2 is not set
> > # CONFIG_CAN_GS_USB is not set
> > # CONFIG_CAN_KVASER_USB is not set
> > # CONFIG_CAN_PEAK_USB is not set
> > # CONFIG_CAN_8DEV_USB is not set
> > # CONFIG_CAN_MCBA_USB is not set
> > # CONFIG_CAN_DEBUG_DEVICES is not set
> > CONFIG_BT=y
> > CONFIG_BT_BREDR=y
> > CONFIG_BT_RFCOMM=y
> > CONFIG_BT_RFCOMM_TTY=y
> > CONFIG_BT_BNEP=y
> > CONFIG_BT_BNEP_MC_FILTER=y
> > CONFIG_BT_BNEP_PROTO_FILTER=y
> > CONFIG_BT_HIDP=y
> > CONFIG_BT_HS=y
> > CONFIG_BT_LE=y
> > # CONFIG_BT_6LOWPAN is not set
> > CONFIG_BT_LEDS=y
> > # CONFIG_BT_SELFTEST is not set
> > # CONFIG_BT_DEBUGFS is not set
> >
> > #
> > # Bluetooth device drivers
> > #
> > CONFIG_BT_INTEL=y
> > CONFIG_BT_RTL=y
> > CONFIG_BT_HCIBTUSB=y
> > # CONFIG_BT_HCIBTUSB_AUTOSUSPEND is not set
> > # CONFIG_BT_HCIBTUSB_BCM is not set
> > CONFIG_BT_HCIBTUSB_RTL=y
> > # CONFIG_BT_HCIUART is not set
> > # CONFIG_BT_HCIBCM203X is not set
> > # CONFIG_BT_HCIBFUSB is not set
> > # CONFIG_BT_HCIDTL1 is not set
> > # CONFIG_BT_HCIBT3C is not set
> > # CONFIG_BT_HCIBLUECARD is not set
> > # CONFIG_BT_HCIBTUART is not set
> > # CONFIG_BT_HCIVHCI is not set
> > # CONFIG_BT_MRVL is not set
> > # CONFIG_BT_ATH3K is not set
> > # CONFIG_AF_RXRPC is not set
> > CONFIG_AF_KCM=y
> > CONFIG_STREAM_PARSER=y
> > CONFIG_FIB_RULES=y
> > CONFIG_WIRELESS=y
> > CONFIG_CFG80211=y
> > # CONFIG_NL80211_TESTMODE is not set
> > # CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
> > # CONFIG_CFG80211_CERTIFICATION_ONUS is not set
> > CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
> > CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
> > CONFIG_CFG80211_DEFAULT_PS=y
> > # CONFIG_CFG80211_DEBUGFS is not set
> > CONFIG_CFG80211_CRDA_SUPPORT=y
> > # CONFIG_CFG80211_WEXT is not set
> > # CONFIG_LIB80211 is not set
> > CONFIG_MAC80211=y
> > CONFIG_MAC80211_HAS_RC=y
> > CONFIG_MAC80211_RC_MINSTREL=y
> > CONFIG_MAC80211_RC_MINSTREL_HT=y
> > # CONFIG_MAC80211_RC_MINSTREL_VHT is not set
> > CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
> > CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
> > # CONFIG_MAC80211_MESH is not set
> > CONFIG_MAC80211_LEDS=y
> > # CONFIG_MAC80211_DEBUGFS is not set
> > # CONFIG_MAC80211_MESSAGE_TRACING is not set
> > # CONFIG_MAC80211_DEBUG_MENU is not set
> > CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
> > CONFIG_WIMAX=y
> > CONFIG_WIMAX_DEBUG_LEVEL=8
> > CONFIG_RFKILL=y
> > CONFIG_RFKILL_LEDS=y
> > CONFIG_RFKILL_INPUT=y
> > CONFIG_NET_9P=y
> > CONFIG_NET_9P_VIRTIO=y
> > CONFIG_NET_9P_XEN=y
> > CONFIG_NET_9P_RDMA=y
> > # CONFIG_NET_9P_DEBUG is not set
> > # CONFIG_CAIF is not set
> > # CONFIG_CEPH_LIB is not set
> > CONFIG_NFC=y
> > CONFIG_NFC_DIGITAL=y
> > CONFIG_NFC_NCI=y
> > CONFIG_NFC_NCI_UART=y
> > CONFIG_NFC_HCI=y
> > CONFIG_NFC_SHDLC=y
> >
> > #
> > # Near Field Communication (NFC) devices
> > #
> > CONFIG_NFC_SIM=y
> > # CONFIG_NFC_PORT100 is not set
> > CONFIG_NFC_FDP=y
> > # CONFIG_NFC_FDP_I2C is not set
> > # CONFIG_NFC_PN544_I2C is not set
> > # CONFIG_NFC_PN533_USB is not set
> > # CONFIG_NFC_PN533_I2C is not set
> > # CONFIG_NFC_MICROREAD_I2C is not set
> > # CONFIG_NFC_MRVL_USB is not set
> > # CONFIG_NFC_MRVL_UART is not set
> > # CONFIG_NFC_ST21NFCA_I2C is not set
> > # CONFIG_NFC_ST_NCI_I2C is not set
> > # CONFIG_NFC_NXP_NCI is not set
> > # CONFIG_NFC_S3FWRN5_I2C is not set
> > CONFIG_PSAMPLE=y
> > # CONFIG_NET_IFE is not set
> > CONFIG_LWTUNNEL=y
> > CONFIG_LWTUNNEL_BPF=y
> > CONFIG_DST_CACHE=y
> > CONFIG_GRO_CELLS=y
> > # CONFIG_NET_DEVLINK is not set
> > CONFIG_MAY_USE_DEVLINK=y
> > CONFIG_HAVE_EBPF_JIT=y
> >
> > #
> > # Device Drivers
> > #
> >
> > #
> > # Generic Driver Options
> > #
> > CONFIG_UEVENT_HELPER=y
> > CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
> > CONFIG_DEVTMPFS=y
> > CONFIG_DEVTMPFS_MOUNT=y
> > CONFIG_STANDALONE=y
> > CONFIG_PREVENT_FIRMWARE_BUILD=y
> > CONFIG_FW_LOADER=y
> > CONFIG_EXTRA_FIRMWARE=""
> > # CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
> > CONFIG_ALLOW_DEV_COREDUMP=y
> > # CONFIG_DEBUG_DRIVER is not set
> > CONFIG_DEBUG_DEVRES=y
> > # CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
> > # CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
> > CONFIG_SYS_HYPERVISOR=y
> > # CONFIG_GENERIC_CPU_DEVICES is not set
> > CONFIG_GENERIC_CPU_AUTOPROBE=y
> > CONFIG_GENERIC_CPU_VULNERABILITIES=y
> > CONFIG_REGMAP=y
> > CONFIG_REGMAP_I2C=y
> > CONFIG_DMA_SHARED_BUFFER=y
> > # CONFIG_DMA_FENCE_TRACE is not set
> >
> > #
> > # Bus devices
> > #
> > CONFIG_CONNECTOR=y
> > CONFIG_PROC_EVENTS=y
> > # CONFIG_MTD is not set
> > # CONFIG_OF is not set
> > CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
> > # CONFIG_PARPORT is not set
> > CONFIG_PNP=y
> > CONFIG_PNP_DEBUG_MESSAGES=y
> >
> > #
> > # Protocols
> > #
> > CONFIG_PNPACPI=y
> > CONFIG_BLK_DEV=y
> > CONFIG_BLK_DEV_NULL_BLK=y
> > CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION=y
> > # CONFIG_BLK_DEV_FD is not set
> > CONFIG_CDROM=y
> > # CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
> > # CONFIG_ZRAM is not set
> > # CONFIG_BLK_DEV_DAC960 is not set
> > # CONFIG_BLK_DEV_UMEM is not set
> > # CONFIG_BLK_DEV_COW_COMMON is not set
> > CONFIG_BLK_DEV_LOOP=y
> > CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
> > # CONFIG_BLK_DEV_CRYPTOLOOP is not set
> > # CONFIG_BLK_DEV_DRBD is not set
> > # CONFIG_BLK_DEV_NBD is not set
> > # CONFIG_BLK_DEV_SKD is not set
> > # CONFIG_BLK_DEV_SX8 is not set
> > # CONFIG_BLK_DEV_RAM is not set
> > # CONFIG_CDROM_PKTCDVD is not set
> > # CONFIG_ATA_OVER_ETH is not set
> > CONFIG_XEN_BLKDEV_FRONTEND=y
> > # CONFIG_XEN_BLKDEV_BACKEND is not set
> > CONFIG_VIRTIO_BLK=y
> > CONFIG_VIRTIO_BLK_SCSI=y
> > # CONFIG_BLK_DEV_RBD is not set
> > # CONFIG_BLK_DEV_RSXX is not set
> >
> > #
> > # NVME Support
> > #
> > # CONFIG_BLK_DEV_NVME is not set
> > # CONFIG_NVME_RDMA is not set
> > # CONFIG_NVME_FC is not set
> > # CONFIG_NVME_TARGET is not set
> >
> > #
> > # Misc devices
> > #
> > # CONFIG_SENSORS_LIS3LV02D is not set
> > # CONFIG_AD525X_DPOT is not set
> > # CONFIG_DUMMY_IRQ is not set
> > # CONFIG_IBM_ASM is not set
> > # CONFIG_PHANTOM is not set
> > # CONFIG_SGI_IOC4 is not set
> > # CONFIG_TIFM_CORE is not set
> > # CONFIG_ICS932S401 is not set
> > # CONFIG_ENCLOSURE_SERVICES is not set
> > # CONFIG_HP_ILO is not set
> > # CONFIG_APDS9802ALS is not set
> > # CONFIG_ISL29003 is not set
> > # CONFIG_ISL29020 is not set
> > # CONFIG_SENSORS_TSL2550 is not set
> > # CONFIG_SENSORS_BH1770 is not set
> > # CONFIG_SENSORS_APDS990X is not set
> > # CONFIG_HMC6352 is not set
> > # CONFIG_DS1682 is not set
> > # CONFIG_USB_SWITCH_FSA9480 is not set
> > # CONFIG_SRAM is not set
> > # CONFIG_PCI_ENDPOINT_TEST is not set
> > # CONFIG_MISC_RTSX is not set
> > # CONFIG_C2PORT is not set
> >
> > #
> > # EEPROM support
> > #
> > # CONFIG_EEPROM_AT24 is not set
> > # CONFIG_EEPROM_LEGACY is not set
> > # CONFIG_EEPROM_MAX6875 is not set
> > # CONFIG_EEPROM_93CX6 is not set
> > # CONFIG_EEPROM_IDT_89HPESX is not set
> > # CONFIG_CB710_CORE is not set
> >
> > #
> > # Texas Instruments shared transport line discipline
> > #
> > # CONFIG_SENSORS_LIS3_I2C is not set
> > # CONFIG_ALTERA_STAPL is not set
> > # CONFIG_INTEL_MEI is not set
> > # CONFIG_INTEL_MEI_ME is not set
> > # CONFIG_INTEL_MEI_TXE is not set
> > # CONFIG_VMWARE_VMCI is not set
> >
> > #
> > # Intel MIC & related support
> > #
> >
> > #
> > # Intel MIC Bus Driver
> > #
> > # CONFIG_INTEL_MIC_BUS is not set
> >
> > #
> > # SCIF Bus Driver
> > #
> > # CONFIG_SCIF_BUS is not set
> >
> > #
> > # VOP Bus Driver
> > #
> > # CONFIG_VOP_BUS is not set
> >
> > #
> > # Intel MIC Host Driver
> > #
> >
> > #
> > # Intel MIC Card Driver
> > #
> >
> > #
> > # SCIF Driver
> > #
> >
> > #
> > # Intel MIC Coprocessor State Management (COSM) Drivers
> > #
> >
> > #
> > # VOP Driver
> > #
> > # CONFIG_GENWQE is not set
> > # CONFIG_ECHO is not set
> > # CONFIG_CXL_BASE is not set
> > # CONFIG_CXL_AFU_DRIVER_OPS is not set
> > # CONFIG_CXL_LIB is not set
> > # CONFIG_OCXL_BASE is not set
> > # CONFIG_MISC_RTSX_PCI is not set
> > # CONFIG_MISC_RTSX_USB is not set
> > CONFIG_HAVE_IDE=y
> > # CONFIG_IDE is not set
> >
> > #
> > # SCSI device support
> > #
> > CONFIG_SCSI_MOD=y
> > # CONFIG_RAID_ATTRS is not set
> > CONFIG_SCSI=y
> > CONFIG_SCSI_DMA=y
> > # CONFIG_SCSI_NETLINK is not set
> > # CONFIG_SCSI_MQ_DEFAULT is not set
> > CONFIG_SCSI_PROC_FS=y
> >
> > #
> > # SCSI support type (disk, tape, CD-ROM)
> > #
> > CONFIG_BLK_DEV_SD=y
> > # CONFIG_CHR_DEV_ST is not set
> > # CONFIG_CHR_DEV_OSST is not set
> > CONFIG_BLK_DEV_SR=y
> > CONFIG_BLK_DEV_SR_VENDOR=y
> > CONFIG_CHR_DEV_SG=y
> > # CONFIG_CHR_DEV_SCH is not set
> > CONFIG_SCSI_CONSTANTS=y
> > # CONFIG_SCSI_LOGGING is not set
> > # CONFIG_SCSI_SCAN_ASYNC is not set
> >
> > #
> > # SCSI Transports
> > #
> > CONFIG_SCSI_SPI_ATTRS=y
> > # CONFIG_SCSI_FC_ATTRS is not set
> > CONFIG_SCSI_ISCSI_ATTRS=y
> > # CONFIG_SCSI_SAS_ATTRS is not set
> > # CONFIG_SCSI_SAS_LIBSAS is not set
> > CONFIG_SCSI_SRP_ATTRS=y
> > CONFIG_SCSI_LOWLEVEL=y
> > # CONFIG_ISCSI_TCP is not set
> > # CONFIG_ISCSI_BOOT_SYSFS is not set
> > # CONFIG_SCSI_CXGB3_ISCSI is not set
> > # CONFIG_SCSI_CXGB4_ISCSI is not set
> > # CONFIG_SCSI_BNX2_ISCSI is not set
> > # CONFIG_BE2ISCSI is not set
> > # CONFIG_BLK_DEV_3W_XXXX_RAID is not set
> > # CONFIG_SCSI_HPSA is not set
> > # CONFIG_SCSI_3W_9XXX is not set
> > # CONFIG_SCSI_3W_SAS is not set
> > # CONFIG_SCSI_ACARD is not set
> > # CONFIG_SCSI_AACRAID is not set
> > # CONFIG_SCSI_AIC7XXX is not set
> > # CONFIG_SCSI_AIC79XX is not set
> > # CONFIG_SCSI_AIC94XX is not set
> > # CONFIG_SCSI_MVSAS is not set
> > # CONFIG_SCSI_MVUMI is not set
> > # CONFIG_SCSI_DPT_I2O is not set
> > # CONFIG_SCSI_ADVANSYS is not set
> > # CONFIG_SCSI_ARCMSR is not set
> > # CONFIG_SCSI_ESAS2R is not set
> > # CONFIG_MEGARAID_NEWGEN is not set
> > # CONFIG_MEGARAID_LEGACY is not set
> > # CONFIG_MEGARAID_SAS is not set
> > # CONFIG_SCSI_MPT3SAS is not set
> > # CONFIG_SCSI_MPT2SAS is not set
> > # CONFIG_SCSI_SMARTPQI is not set
> > # CONFIG_SCSI_UFSHCD is not set
> > # CONFIG_SCSI_HPTIOP is not set
> > # CONFIG_SCSI_BUSLOGIC is not set
> > # CONFIG_VMWARE_PVSCSI is not set
> > # CONFIG_XEN_SCSI_FRONTEND is not set
> > # CONFIG_SCSI_SNIC is not set
> > # CONFIG_SCSI_DMX3191D is not set
> > # CONFIG_SCSI_EATA is not set
> > # CONFIG_SCSI_FUTURE_DOMAIN is not set
> > # CONFIG_SCSI_GDTH is not set
> > # CONFIG_SCSI_ISCI is not set
> > # CONFIG_SCSI_IPS is not set
> > # CONFIG_SCSI_INITIO is not set
> > # CONFIG_SCSI_INIA100 is not set
> > # CONFIG_SCSI_STEX is not set
> > # CONFIG_SCSI_SYM53C8XX_2 is not set
> > # CONFIG_SCSI_IPR is not set
> > # CONFIG_SCSI_QLOGIC_1280 is not set
> > # CONFIG_SCSI_QLA_ISCSI is not set
> > # CONFIG_SCSI_DC395x is not set
> > # CONFIG_SCSI_AM53C974 is not set
> > # CONFIG_SCSI_WD719X is not set
> > # CONFIG_SCSI_DEBUG is not set
> > # CONFIG_SCSI_PMCRAID is not set
> > # CONFIG_SCSI_PM8001 is not set
> > CONFIG_SCSI_VIRTIO=y
> > # CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
> > # CONFIG_SCSI_DH is not set
> > # CONFIG_SCSI_OSD_INITIATOR is not set
> > CONFIG_ATA=y
> > # CONFIG_ATA_NONSTANDARD is not set
> > CONFIG_ATA_VERBOSE_ERROR=y
> > CONFIG_ATA_ACPI=y
> > # CONFIG_SATA_ZPODD is not set
> > CONFIG_SATA_PMP=y
> >
> > #
> > # Controllers with non-SFF native interface
> > #
> > CONFIG_SATA_AHCI=y
> > CONFIG_SATA_MOBILE_LPM_POLICY=0
> > # CONFIG_SATA_AHCI_PLATFORM is not set
> > # CONFIG_SATA_INIC162X is not set
> > # CONFIG_SATA_ACARD_AHCI is not set
> > # CONFIG_SATA_SIL24 is not set
> > CONFIG_ATA_SFF=y
> >
> > #
> > # SFF controllers with custom DMA interface
> > #
> > # CONFIG_PDC_ADMA is not set
> > # CONFIG_SATA_QSTOR is not set
> > # CONFIG_SATA_SX4 is not set
> > CONFIG_ATA_BMDMA=y
> >
> > #
> > # SATA SFF controllers with BMDMA
> > #
> > CONFIG_ATA_PIIX=y
> > # CONFIG_SATA_DWC is not set
> > # CONFIG_SATA_MV is not set
> > # CONFIG_SATA_NV is not set
> > # CONFIG_SATA_PROMISE is not set
> > # CONFIG_SATA_SIL is not set
> > # CONFIG_SATA_SIS is not set
> > # CONFIG_SATA_SVW is not set
> > # CONFIG_SATA_ULI is not set
> > # CONFIG_SATA_VIA is not set
> > # CONFIG_SATA_VITESSE is not set
> >
> > #
> > # PATA SFF controllers with BMDMA
> > #
> > # CONFIG_PATA_ALI is not set
> > CONFIG_PATA_AMD=y
> > # CONFIG_PATA_ARTOP is not set
> > # CONFIG_PATA_ATIIXP is not set
> > # CONFIG_PATA_ATP867X is not set
> > # CONFIG_PATA_CMD64X is not set
> > # CONFIG_PATA_CYPRESS is not set
> > # CONFIG_PATA_EFAR is not set
> > # CONFIG_PATA_HPT366 is not set
> > # CONFIG_PATA_HPT37X is not set
> > # CONFIG_PATA_HPT3X2N is not set
> > # CONFIG_PATA_HPT3X3 is not set
> > # CONFIG_PATA_IT8213 is not set
> > # CONFIG_PATA_IT821X is not set
> > # CONFIG_PATA_JMICRON is not set
> > # CONFIG_PATA_MARVELL is not set
> > # CONFIG_PATA_NETCELL is not set
> > # CONFIG_PATA_NINJA32 is not set
> > # CONFIG_PATA_NS87415 is not set
> > CONFIG_PATA_OLDPIIX=y
> > # CONFIG_PATA_OPTIDMA is not set
> > # CONFIG_PATA_PDC2027X is not set
> > # CONFIG_PATA_PDC_OLD is not set
> > # CONFIG_PATA_RADISYS is not set
> > # CONFIG_PATA_RDC is not set
> > CONFIG_PATA_SCH=y
> > # CONFIG_PATA_SERVERWORKS is not set
> > # CONFIG_PATA_SIL680 is not set
> > # CONFIG_PATA_SIS is not set
> > # CONFIG_PATA_TOSHIBA is not set
> > # CONFIG_PATA_TRIFLEX is not set
> > # CONFIG_PATA_VIA is not set
> > # CONFIG_PATA_WINBOND is not set
> >
> > #
> > # PIO-only SFF controllers
> > #
> > # CONFIG_PATA_CMD640_PCI is not set
> > # CONFIG_PATA_MPIIX is not set
> > # CONFIG_PATA_NS87410 is not set
> > # CONFIG_PATA_OPTI is not set
> > # CONFIG_PATA_PCMCIA is not set
> > # CONFIG_PATA_PLATFORM is not set
> > # CONFIG_PATA_RZ1000 is not set
> >
> > #
> > # Generic fallback / legacy drivers
> > #
> > # CONFIG_PATA_ACPI is not set
> > # CONFIG_ATA_GENERIC is not set
> > # CONFIG_PATA_LEGACY is not set
> > CONFIG_MD=y
> > CONFIG_BLK_DEV_MD=y
> > CONFIG_MD_AUTODETECT=y
> > # CONFIG_MD_LINEAR is not set
> > # CONFIG_MD_RAID0 is not set
> > # CONFIG_MD_RAID1 is not set
> > # CONFIG_MD_RAID10 is not set
> > # CONFIG_MD_RAID456 is not set
> > # CONFIG_MD_MULTIPATH is not set
> > # CONFIG_MD_FAULTY is not set
> > # CONFIG_BCACHE is not set
> > CONFIG_BLK_DEV_DM_BUILTIN=y
> > CONFIG_BLK_DEV_DM=y
> > # CONFIG_DM_MQ_DEFAULT is not set
> > # CONFIG_DM_DEBUG is not set
> > # CONFIG_DM_UNSTRIPED is not set
> > # CONFIG_DM_CRYPT is not set
> > # CONFIG_DM_SNAPSHOT is not set
> > # CONFIG_DM_THIN_PROVISIONING is not set
> > # CONFIG_DM_CACHE is not set
> > # CONFIG_DM_ERA is not set
> > CONFIG_DM_MIRROR=y
> > # CONFIG_DM_LOG_USERSPACE is not set
> > # CONFIG_DM_RAID is not set
> > CONFIG_DM_ZERO=y
> > # CONFIG_DM_MULTIPATH is not set
> > # CONFIG_DM_DELAY is not set
> > # CONFIG_DM_UEVENT is not set
> > # CONFIG_DM_FLAKEY is not set
> > # CONFIG_DM_VERITY is not set
> > # CONFIG_DM_SWITCH is not set
> > # CONFIG_DM_LOG_WRITES is not set
> > # CONFIG_DM_INTEGRITY is not set
> > # CONFIG_DM_ZONED is not set
> > # CONFIG_TARGET_CORE is not set
> > # CONFIG_FUSION is not set
> >
> > #
> > # IEEE 1394 (FireWire) support
> > #
> > # CONFIG_FIREWIRE is not set
> > # CONFIG_FIREWIRE_NOSY is not set
> > CONFIG_MACINTOSH_DRIVERS=y
> > CONFIG_MAC_EMUMOUSEBTN=y
> > CONFIG_NETDEVICES=y
> > CONFIG_MII=y
> > CONFIG_NET_CORE=y
> > CONFIG_BONDING=y
> > # CONFIG_DUMMY is not set
> > CONFIG_EQUALIZER=y
> > # CONFIG_NET_FC is not set
> > # CONFIG_IFB is not set
> > # CONFIG_NET_TEAM is not set
> > # CONFIG_MACVLAN is not set
> > # CONFIG_IPVLAN is not set
> > # CONFIG_VXLAN is not set
> > # CONFIG_GENEVE is not set
> > # CONFIG_GTP is not set
> > # CONFIG_MACSEC is not set
> > CONFIG_NETCONSOLE=y
> > # CONFIG_NETCONSOLE_DYNAMIC is not set
> > CONFIG_NETPOLL=y
> > CONFIG_NET_POLL_CONTROLLER=y
> > CONFIG_TUN=y
> > # CONFIG_TUN_VNET_CROSS_LE is not set
> > CONFIG_VETH=y
> > CONFIG_VIRTIO_NET=y
> > # CONFIG_NLMON is not set
> > # CONFIG_NET_VRF is not set
> > # CONFIG_VSOCKMON is not set
> > # CONFIG_ARCNET is not set
> > CONFIG_ATM_DRIVERS=y
> > # CONFIG_ATM_DUMMY is not set
> > CONFIG_ATM_TCP=y
> > # CONFIG_ATM_LANAI is not set
> > # CONFIG_ATM_ENI is not set
> > # CONFIG_ATM_FIRESTREAM is not set
> > # CONFIG_ATM_ZATM is not set
> > # CONFIG_ATM_NICSTAR is not set
> > # CONFIG_ATM_IDT77252 is not set
> > # CONFIG_ATM_AMBASSADOR is not set
> > # CONFIG_ATM_HORIZON is not set
> > # CONFIG_ATM_IA is not set
> > # CONFIG_ATM_FORE200E is not set
> > # CONFIG_ATM_HE is not set
> > # CONFIG_ATM_SOLOS is not set
> >
> > #
> > # CAIF transport drivers
> > #
> >
> > #
> > # Distributed Switch Architecture drivers
> > #
> > # CONFIG_B53 is not set
> > # CONFIG_NET_DSA_LOOP is not set
> > # CONFIG_NET_DSA_MT7530 is not set
> > # CONFIG_NET_DSA_MV88E6060 is not set
> > # CONFIG_MICROCHIP_KSZ is not set
> > # CONFIG_NET_DSA_MV88E6XXX is not set
> > # CONFIG_NET_DSA_QCA8K is not set
> > # CONFIG_NET_DSA_SMSC_LAN9303_I2C is not set
> > # CONFIG_NET_DSA_SMSC_LAN9303_MDIO is not set
> > CONFIG_ETHERNET=y
> > CONFIG_NET_VENDOR_3COM=y
> > # CONFIG_PCMCIA_3C574 is not set
> > # CONFIG_PCMCIA_3C589 is not set
> > # CONFIG_VORTEX is not set
> > # CONFIG_TYPHOON is not set
> > CONFIG_NET_VENDOR_ADAPTEC=y
> > # CONFIG_ADAPTEC_STARFIRE is not set
> > CONFIG_NET_VENDOR_AGERE=y
> > # CONFIG_ET131X is not set
> > CONFIG_NET_VENDOR_ALACRITECH=y
> > # CONFIG_SLICOSS is not set
> > CONFIG_NET_VENDOR_ALTEON=y
> > # CONFIG_ACENIC is not set
> > # CONFIG_ALTERA_TSE is not set
> > CONFIG_NET_VENDOR_AMAZON=y
> > # CONFIG_ENA_ETHERNET is not set
> > CONFIG_NET_VENDOR_AMD=y
> > # CONFIG_AMD8111_ETH is not set
> > # CONFIG_PCNET32 is not set
> > # CONFIG_PCMCIA_NMCLAN is not set
> > # CONFIG_AMD_XGBE is not set
> > # CONFIG_AMD_XGBE_HAVE_ECC is not set
> > # CONFIG_NET_VENDOR_AQUANTIA is not set
> > CONFIG_NET_VENDOR_ARC=y
> > CONFIG_NET_VENDOR_ATHEROS=y
> > # CONFIG_ATL2 is not set
> > # CONFIG_ATL1 is not set
> > # CONFIG_ATL1E is not set
> > # CONFIG_ATL1C is not set
> > # CONFIG_ALX is not set
> > # CONFIG_NET_VENDOR_AURORA is not set
> > CONFIG_NET_CADENCE=y
> > # CONFIG_MACB is not set
> > CONFIG_NET_VENDOR_BROADCOM=y
> > # CONFIG_B44 is not set
> > # CONFIG_BNX2 is not set
> > # CONFIG_CNIC is not set
> > CONFIG_TIGON3=y
> > CONFIG_TIGON3_HWMON=y
> > # CONFIG_BNX2X is not set
> > # CONFIG_BNXT is not set
> > CONFIG_NET_VENDOR_BROCADE=y
> > # CONFIG_BNA is not set
> > CONFIG_NET_VENDOR_CAVIUM=y
> > # CONFIG_THUNDER_NIC_PF is not set
> > # CONFIG_THUNDER_NIC_VF is not set
> > # CONFIG_THUNDER_NIC_BGX is not set
> > # CONFIG_THUNDER_NIC_RGX is not set
> > # CONFIG_CAVIUM_PTP is not set
> > # CONFIG_LIQUIDIO is not set
> > # CONFIG_LIQUIDIO_VF is not set
> > CONFIG_NET_VENDOR_CHELSIO=y
> > # CONFIG_CHELSIO_T1 is not set
> > # CONFIG_CHELSIO_T3 is not set
> > # CONFIG_CHELSIO_T4 is not set
> > # CONFIG_CHELSIO_T4VF is not set
> > CONFIG_NET_VENDOR_CISCO=y
> > CONFIG_ENIC=y
> > # CONFIG_NET_VENDOR_CORTINA is not set
> > # CONFIG_CX_ECAT is not set
> > # CONFIG_DNET is not set
> > CONFIG_NET_VENDOR_DEC=y
> > CONFIG_NET_TULIP=y
> > # CONFIG_DE2104X is not set
> > # CONFIG_TULIP is not set
> > # CONFIG_DE4X5 is not set
> > # CONFIG_WINBOND_840 is not set
> > # CONFIG_DM9102 is not set
> > # CONFIG_ULI526X is not set
> > # CONFIG_PCMCIA_XIRCOM is not set
> > CONFIG_NET_VENDOR_DLINK=y
> > # CONFIG_DL2K is not set
> > # CONFIG_SUNDANCE is not set
> > CONFIG_NET_VENDOR_EMULEX=y
> > # CONFIG_BE2NET is not set
> > CONFIG_NET_VENDOR_EZCHIP=y
> > CONFIG_NET_VENDOR_EXAR=y
> > # CONFIG_S2IO is not set
> > # CONFIG_VXGE is not set
> > CONFIG_NET_VENDOR_FUJITSU=y
> > # CONFIG_PCMCIA_FMVJ18X is not set
> > CONFIG_NET_VENDOR_HP=y
> > # CONFIG_HP100 is not set
> > # CONFIG_NET_VENDOR_HUAWEI is not set
> > CONFIG_NET_VENDOR_INTEL=y
> > CONFIG_E100=y
> > CONFIG_E1000=y
> > CONFIG_E1000E=y
> > CONFIG_E1000E_HWTS=y
> > # CONFIG_IGB is not set
> > # CONFIG_IGBVF is not set
> > # CONFIG_IXGB is not set
> > # CONFIG_IXGBE is not set
> > # CONFIG_IXGBEVF is not set
> > # CONFIG_I40E is not set
> > # CONFIG_I40EVF is not set
> > # CONFIG_FM10K is not set
> > CONFIG_NET_VENDOR_I825XX=y
> > # CONFIG_JME is not set
> > CONFIG_NET_VENDOR_MARVELL=y
> > # CONFIG_MVMDIO is not set
> > # CONFIG_SKGE is not set
> > CONFIG_SKY2=y
> > # CONFIG_SKY2_DEBUG is not set
> > CONFIG_NET_VENDOR_MELLANOX=y
> > # CONFIG_MLX4_EN is not set
> > # CONFIG_MLX4_CORE is not set
> > # CONFIG_MLX5_CORE is not set
> > # CONFIG_MLXSW_CORE is not set
> > # CONFIG_MLXFW is not set
> > CONFIG_NET_VENDOR_MICREL=y
> > # CONFIG_KS8842 is not set
> > # CONFIG_KS8851_MLL is not set
> > # CONFIG_KSZ884X_PCI is not set
> > CONFIG_NET_VENDOR_MYRI=y
> > # CONFIG_MYRI10GE is not set
> > # CONFIG_FEALNX is not set
> > CONFIG_NET_VENDOR_NATSEMI=y
> > # CONFIG_NATSEMI is not set
> > # CONFIG_NS83820 is not set
> > CONFIG_NET_VENDOR_NETRONOME=y
> > # CONFIG_NFP is not set
> > CONFIG_NET_VENDOR_8390=y
> > # CONFIG_PCMCIA_AXNET is not set
> > # CONFIG_NE2K_PCI is not set
> > # CONFIG_PCMCIA_PCNET is not set
> > CONFIG_NET_VENDOR_NVIDIA=y
> > CONFIG_FORCEDETH=y
> > CONFIG_NET_VENDOR_OKI=y
> > # CONFIG_ETHOC is not set
> > CONFIG_NET_PACKET_ENGINE=y
> > # CONFIG_HAMACHI is not set
> > # CONFIG_YELLOWFIN is not set
> > CONFIG_NET_VENDOR_QLOGIC=y
> > # CONFIG_QLA3XXX is not set
> > # CONFIG_QLCNIC is not set
> > # CONFIG_QLGE is not set
> > # CONFIG_NETXEN_NIC is not set
> > # CONFIG_QED is not set
> > CONFIG_NET_VENDOR_QUALCOMM=y
> > # CONFIG_QCOM_EMAC is not set
> > # CONFIG_RMNET is not set
> > CONFIG_NET_VENDOR_REALTEK=y
> > # CONFIG_8139CP is not set
> > CONFIG_8139TOO=y
> > CONFIG_8139TOO_PIO=y
> > # CONFIG_8139TOO_TUNE_TWISTER is not set
> > # CONFIG_8139TOO_8129 is not set
> > # CONFIG_8139_OLD_RX_RESET is not set
> > # CONFIG_R8169 is not set
> > CONFIG_NET_VENDOR_RENESAS=y
> > CONFIG_NET_VENDOR_RDC=y
> > # CONFIG_R6040 is not set
> > CONFIG_NET_VENDOR_ROCKER=y
> > # CONFIG_ROCKER is not set
> > CONFIG_NET_VENDOR_SAMSUNG=y
> > # CONFIG_SXGBE_ETH is not set
> > CONFIG_NET_VENDOR_SEEQ=y
> > CONFIG_NET_VENDOR_SILAN=y
> > # CONFIG_SC92031 is not set
> > CONFIG_NET_VENDOR_SIS=y
> > # CONFIG_SIS900 is not set
> > # CONFIG_SIS190 is not set
> > # CONFIG_NET_VENDOR_SOLARFLARE is not set
> > CONFIG_NET_VENDOR_SMSC=y
> > # CONFIG_PCMCIA_SMC91C92 is not set
> > # CONFIG_EPIC100 is not set
> > # CONFIG_SMSC911X is not set
> > # CONFIG_SMSC9420 is not set
> > # CONFIG_NET_VENDOR_SOCIONEXT is not set
> > CONFIG_NET_VENDOR_STMICRO=y
> > # CONFIG_STMMAC_ETH is not set
> > CONFIG_NET_VENDOR_SUN=y
> > # CONFIG_HAPPYMEAL is not set
> > # CONFIG_SUNGEM is not set
> > # CONFIG_CASSINI is not set
> > # CONFIG_NIU is not set
> > CONFIG_NET_VENDOR_TEHUTI=y
> > # CONFIG_TEHUTI is not set
> > CONFIG_NET_VENDOR_TI=y
> > # CONFIG_TI_CPSW_ALE is not set
> > # CONFIG_TLAN is not set
> > CONFIG_NET_VENDOR_VIA=y
> > # CONFIG_VIA_RHINE is not set
> > # CONFIG_VIA_VELOCITY is not set
> > CONFIG_NET_VENDOR_WIZNET=y
> > # CONFIG_WIZNET_W5100 is not set
> > # CONFIG_WIZNET_W5300 is not set
> > CONFIG_NET_VENDOR_XIRCOM=y
> > # CONFIG_PCMCIA_XIRC2PS is not set
> > CONFIG_NET_VENDOR_SYNOPSYS=y
> > # CONFIG_DWC_XLGMAC is not set
> > CONFIG_FDDI=y
> > # CONFIG_DEFXX is not set
> > # CONFIG_SKFP is not set
> > # CONFIG_HIPPI is not set
> > # CONFIG_NET_SB1000 is not set
> > CONFIG_MDIO_DEVICE=y
> > CONFIG_MDIO_BUS=y
> > # CONFIG_MDIO_BITBANG is not set
> > # CONFIG_MDIO_THUNDER is not set
> > CONFIG_PHYLIB=y
> > # CONFIG_LED_TRIGGER_PHY is not set
> >
> > #
> > # MII PHY device drivers
> > #
> > # CONFIG_AMD_PHY is not set
> > # CONFIG_AQUANTIA_PHY is not set
> > # CONFIG_AT803X_PHY is not set
> > # CONFIG_BCM7XXX_PHY is not set
> > # CONFIG_BCM87XX_PHY is not set
> > # CONFIG_BROADCOM_PHY is not set
> > # CONFIG_CICADA_PHY is not set
> > # CONFIG_CORTINA_PHY is not set
> > # CONFIG_DAVICOM_PHY is not set
> > # CONFIG_DP83822_PHY is not set
> > # CONFIG_DP83848_PHY is not set
> > # CONFIG_DP83867_PHY is not set
> > # CONFIG_FIXED_PHY is not set
> > # CONFIG_ICPLUS_PHY is not set
> > # CONFIG_INTEL_XWAY_PHY is not set
> > # CONFIG_LSI_ET1011C_PHY is not set
> > # CONFIG_LXT_PHY is not set
> > # CONFIG_MARVELL_PHY is not set
> > # CONFIG_MARVELL_10G_PHY is not set
> > # CONFIG_MICREL_PHY is not set
> > # CONFIG_MICROCHIP_PHY is not set
> > # CONFIG_MICROSEMI_PHY is not set
> > # CONFIG_NATIONAL_PHY is not set
> > # CONFIG_QSEMI_PHY is not set
> > # CONFIG_REALTEK_PHY is not set
> > # CONFIG_RENESAS_PHY is not set
> > # CONFIG_ROCKCHIP_PHY is not set
> > # CONFIG_SMSC_PHY is not set
> > # CONFIG_STE10XP is not set
> > # CONFIG_TERANETICS_PHY is not set
> > # CONFIG_VITESSE_PHY is not set
> > # CONFIG_XILINX_GMII2RGMII is not set
> > CONFIG_PPP=y
> > CONFIG_PPP_BSDCOMP=y
> > CONFIG_PPP_DEFLATE=y
> > CONFIG_PPP_FILTER=y
> > # CONFIG_PPP_MPPE is not set
> > # CONFIG_PPP_MULTILINK is not set
> > # CONFIG_PPPOATM is not set
> > CONFIG_PPPOE=y
> > CONFIG_PPTP=y
> > CONFIG_PPPOL2TP=y
> > CONFIG_PPP_ASYNC=y
> > # CONFIG_PPP_SYNC_TTY is not set
> > # CONFIG_SLIP is not set
> > CONFIG_SLHC=y
> > CONFIG_USB_NET_DRIVERS=y
> > # CONFIG_USB_CATC is not set
> > # CONFIG_USB_KAWETH is not set
> > # CONFIG_USB_PEGASUS is not set
> > # CONFIG_USB_RTL8150 is not set
> > # CONFIG_USB_RTL8152 is not set
> > # CONFIG_USB_LAN78XX is not set
> > # CONFIG_USB_USBNET is not set
> > # CONFIG_USB_HSO is not set
> > # CONFIG_USB_IPHETH is not set
> > CONFIG_WLAN=y
> > # CONFIG_WIRELESS_WDS is not set
> > CONFIG_WLAN_VENDOR_ADMTEK=y
> > # CONFIG_ADM8211 is not set
> > CONFIG_WLAN_VENDOR_ATH=y
> > # CONFIG_ATH_DEBUG is not set
> > # CONFIG_ATH5K is not set
> > # CONFIG_ATH5K_PCI is not set
> > # CONFIG_ATH9K is not set
> > # CONFIG_ATH9K_HTC is not set
> > # CONFIG_CARL9170 is not set
> > # CONFIG_ATH6KL is not set
> > # CONFIG_AR5523 is not set
> > # CONFIG_WIL6210 is not set
> > # CONFIG_ATH10K is not set
> > # CONFIG_WCN36XX is not set
> > CONFIG_WLAN_VENDOR_ATMEL=y
> > # CONFIG_ATMEL is not set
> > # CONFIG_AT76C50X_USB is not set
> > CONFIG_WLAN_VENDOR_BROADCOM=y
> > # CONFIG_B43 is not set
> > # CONFIG_B43LEGACY is not set
> > # CONFIG_BRCMSMAC is not set
> > # CONFIG_BRCMFMAC is not set
> > CONFIG_WLAN_VENDOR_CISCO=y
> > # CONFIG_AIRO is not set
> > # CONFIG_AIRO_CS is not set
> > CONFIG_WLAN_VENDOR_INTEL=y
> > # CONFIG_IPW2100 is not set
> > # CONFIG_IPW2200 is not set
> > # CONFIG_IWL4965 is not set
> > # CONFIG_IWL3945 is not set
> > # CONFIG_IWLWIFI is not set
> > CONFIG_WLAN_VENDOR_INTERSIL=y
> > # CONFIG_HOSTAP is not set
> > # CONFIG_HERMES is not set
> > # CONFIG_P54_COMMON is not set
> > # CONFIG_PRISM54 is not set
> > CONFIG_WLAN_VENDOR_MARVELL=y
> > # CONFIG_LIBERTAS is not set
> > # CONFIG_LIBERTAS_THINFIRM is not set
> > # CONFIG_MWIFIEX is not set
> > # CONFIG_MWL8K is not set
> > CONFIG_WLAN_VENDOR_MEDIATEK=y
> > # CONFIG_MT7601U is not set
> > # CONFIG_MT76x2E is not set
> > CONFIG_WLAN_VENDOR_RALINK=y
> > # CONFIG_RT2X00 is not set
> > CONFIG_WLAN_VENDOR_REALTEK=y
> > # CONFIG_RTL8180 is not set
> > # CONFIG_RTL8187 is not set
> > CONFIG_RTL_CARDS=y
> > # CONFIG_RTL8192CE is not set
> > # CONFIG_RTL8192SE is not set
> > # CONFIG_RTL8192DE is not set
> > # CONFIG_RTL8723AE is not set
> > # CONFIG_RTL8723BE is not set
> > # CONFIG_RTL8188EE is not set
> > # CONFIG_RTL8192EE is not set
> > # CONFIG_RTL8821AE is not set
> > # CONFIG_RTL8192CU is not set
> > # CONFIG_RTL8XXXU is not set
> > CONFIG_WLAN_VENDOR_RSI=y
> > # CONFIG_RSI_91X is not set
> > CONFIG_WLAN_VENDOR_ST=y
> > # CONFIG_CW1200 is not set
> > CONFIG_WLAN_VENDOR_TI=y
> > # CONFIG_WL1251 is not set
> > # CONFIG_WL12XX is not set
> > # CONFIG_WL18XX is not set
> > # CONFIG_WLCORE is not set
> > CONFIG_WLAN_VENDOR_ZYDAS=y
> > # CONFIG_USB_ZD1201 is not set
> > # CONFIG_ZD1211RW is not set
> > # CONFIG_WLAN_VENDOR_QUANTENNA is not set
> > # CONFIG_PCMCIA_RAYCS is not set
> > # CONFIG_PCMCIA_WL3501 is not set
> > CONFIG_MAC80211_HWSIM=y
> > # CONFIG_USB_NET_RNDIS_WLAN is not set
> >
> > #
> > # WiMAX Wireless Broadband devices
> > #
> > # CONFIG_WIMAX_I2400M_USB is not set
> > # CONFIG_WAN is not set
> > CONFIG_IEEE802154_DRIVERS=y
> > # CONFIG_IEEE802154_FAKELB is not set
> > # CONFIG_IEEE802154_ATUSB is not set
> > CONFIG_XEN_NETDEV_FRONTEND=y
> > # CONFIG_XEN_NETDEV_BACKEND is not set
> > # CONFIG_VMXNET3 is not set
> > # CONFIG_FUJITSU_ES is not set
> > # CONFIG_NETDEVSIM is not set
> > # CONFIG_ISDN is not set
> > # CONFIG_NVM is not set
> >
> > #
> > # Input device support
> > #
> > CONFIG_INPUT=y
> > CONFIG_INPUT_LEDS=y
> > CONFIG_INPUT_FF_MEMLESS=y
> > CONFIG_INPUT_POLLDEV=y
> > CONFIG_INPUT_SPARSEKMAP=y
> > # CONFIG_INPUT_MATRIXKMAP is not set
> >
> > #
> > # Userland interfaces
> > #
> > CONFIG_INPUT_MOUSEDEV=y
> > # CONFIG_INPUT_MOUSEDEV_PSAUX is not set
> > CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
> > CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
> > # CONFIG_INPUT_JOYDEV is not set
> > CONFIG_INPUT_EVDEV=y
> > # CONFIG_INPUT_EVBUG is not set
> >
> > #
> > # Input Device Drivers
> > #
> > CONFIG_INPUT_KEYBOARD=y
> > # CONFIG_KEYBOARD_ADP5588 is not set
> > # CONFIG_KEYBOARD_ADP5589 is not set
> > CONFIG_KEYBOARD_ATKBD=y
> > # CONFIG_KEYBOARD_QT1070 is not set
> > # CONFIG_KEYBOARD_QT2160 is not set
> > # CONFIG_KEYBOARD_DLINK_DIR685 is not set
> > # CONFIG_KEYBOARD_LKKBD is not set
> > # CONFIG_KEYBOARD_TCA6416 is not set
> > # CONFIG_KEYBOARD_TCA8418 is not set
> > # CONFIG_KEYBOARD_LM8323 is not set
> > # CONFIG_KEYBOARD_LM8333 is not set
> > # CONFIG_KEYBOARD_MAX7359 is not set
> > # CONFIG_KEYBOARD_MCS is not set
> > # CONFIG_KEYBOARD_MPR121 is not set
> > # CONFIG_KEYBOARD_NEWTON is not set
> > # CONFIG_KEYBOARD_OPENCORES is not set
> > # CONFIG_KEYBOARD_SAMSUNG is not set
> > # CONFIG_KEYBOARD_STOWAWAY is not set
> > # CONFIG_KEYBOARD_SUNKBD is not set
> > # CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
> > # CONFIG_KEYBOARD_XTKBD is not set
> > CONFIG_INPUT_MOUSE=y
> > CONFIG_MOUSE_PS2=y
> > CONFIG_MOUSE_PS2_ALPS=y
> > CONFIG_MOUSE_PS2_BYD=y
> > CONFIG_MOUSE_PS2_LOGIPS2PP=y
> > CONFIG_MOUSE_PS2_SYNAPTICS=y
> > CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
> > CONFIG_MOUSE_PS2_CYPRESS=y
> > CONFIG_MOUSE_PS2_LIFEBOOK=y
> > CONFIG_MOUSE_PS2_TRACKPOINT=y
> > # CONFIG_MOUSE_PS2_ELANTECH is not set
> > # CONFIG_MOUSE_PS2_SENTELIC is not set
> > # CONFIG_MOUSE_PS2_TOUCHKIT is not set
> > CONFIG_MOUSE_PS2_FOCALTECH=y
> > # CONFIG_MOUSE_PS2_VMMOUSE is not set
> > CONFIG_MOUSE_PS2_SMBUS=y
> > # CONFIG_MOUSE_SERIAL is not set
> > # CONFIG_MOUSE_APPLETOUCH is not set
> > # CONFIG_MOUSE_BCM5974 is not set
> > # CONFIG_MOUSE_CYAPA is not set
> > # CONFIG_MOUSE_ELAN_I2C is not set
> > # CONFIG_MOUSE_VSXXXAA is not set
> > # CONFIG_MOUSE_SYNAPTICS_I2C is not set
> > # CONFIG_MOUSE_SYNAPTICS_USB is not set
> > CONFIG_INPUT_JOYSTICK=y
> > # CONFIG_JOYSTICK_ANALOG is not set
> > # CONFIG_JOYSTICK_A3D is not set
> > # CONFIG_JOYSTICK_ADI is not set
> > # CONFIG_JOYSTICK_COBRA is not set
> > # CONFIG_JOYSTICK_GF2K is not set
> > # CONFIG_JOYSTICK_GRIP is not set
> > # CONFIG_JOYSTICK_GRIP_MP is not set
> > # CONFIG_JOYSTICK_GUILLEMOT is not set
> > # CONFIG_JOYSTICK_INTERACT is not set
> > # CONFIG_JOYSTICK_SIDEWINDER is not set
> > # CONFIG_JOYSTICK_TMDC is not set
> > # CONFIG_JOYSTICK_IFORCE is not set
> > # CONFIG_JOYSTICK_WARRIOR is not set
> > # CONFIG_JOYSTICK_MAGELLAN is not set
> > # CONFIG_JOYSTICK_SPACEORB is not set
> > # CONFIG_JOYSTICK_SPACEBALL is not set
> > # CONFIG_JOYSTICK_STINGER is not set
> > # CONFIG_JOYSTICK_TWIDJOY is not set
> > # CONFIG_JOYSTICK_ZHENHUA is not set
> > # CONFIG_JOYSTICK_AS5011 is not set
> > # CONFIG_JOYSTICK_JOYDUMP is not set
> > # CONFIG_JOYSTICK_XPAD is not set
> > CONFIG_INPUT_TABLET=y
> > # CONFIG_TABLET_USB_ACECAD is not set
> > # CONFIG_TABLET_USB_AIPTEK is not set
> > # CONFIG_TABLET_USB_GTCO is not set
> > # CONFIG_TABLET_USB_HANWANG is not set
> > # CONFIG_TABLET_USB_KBTAB is not set
> > # CONFIG_TABLET_USB_PEGASUS is not set
> > # CONFIG_TABLET_SERIAL_WACOM4 is not set
> > CONFIG_INPUT_TOUCHSCREEN=y
> > CONFIG_TOUCHSCREEN_PROPERTIES=y
> > # CONFIG_TOUCHSCREEN_AD7879 is not set
> > # CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
> > # CONFIG_TOUCHSCREEN_BU21013 is not set
> > # CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
> > # CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
> > # CONFIG_TOUCHSCREEN_DYNAPRO is not set
> > # CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
> > # CONFIG_TOUCHSCREEN_EETI is not set
> > # CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
> > # CONFIG_TOUCHSCREEN_EXC3000 is not set
> > # CONFIG_TOUCHSCREEN_FUJITSU is not set
> > # CONFIG_TOUCHSCREEN_HIDEEP is not set
> > # CONFIG_TOUCHSCREEN_ILI210X is not set
> > # CONFIG_TOUCHSCREEN_S6SY761 is not set
> > # CONFIG_TOUCHSCREEN_GUNZE is not set
> > # CONFIG_TOUCHSCREEN_EKTF2127 is not set
> > # CONFIG_TOUCHSCREEN_ELAN is not set
> > # CONFIG_TOUCHSCREEN_ELO is not set
> > # CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
> > # CONFIG_TOUCHSCREEN_WACOM_I2C is not set
> > # CONFIG_TOUCHSCREEN_MAX11801 is not set
> > # CONFIG_TOUCHSCREEN_MCS5000 is not set
> > # CONFIG_TOUCHSCREEN_MMS114 is not set
> > # CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
> > # CONFIG_TOUCHSCREEN_MTOUCH is not set
> > # CONFIG_TOUCHSCREEN_INEXIO is not set
> > # CONFIG_TOUCHSCREEN_MK712 is not set
> > # CONFIG_TOUCHSCREEN_PENMOUNT is not set
> > # CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
> > # CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
> > # CONFIG_TOUCHSCREEN_TOUCHWIN is not set
> > # CONFIG_TOUCHSCREEN_PIXCIR is not set
> > # CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
> > # CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
> > # CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
> > # CONFIG_TOUCHSCREEN_TSC_SERIO is not set
> > # CONFIG_TOUCHSCREEN_TSC2004 is not set
> > # CONFIG_TOUCHSCREEN_TSC2007 is not set
> > # CONFIG_TOUCHSCREEN_SILEAD is not set
> > # CONFIG_TOUCHSCREEN_ST1232 is not set
> > # CONFIG_TOUCHSCREEN_STMFTS is not set
> > # CONFIG_TOUCHSCREEN_SX8654 is not set
> > # CONFIG_TOUCHSCREEN_TPS6507X is not set
> > # CONFIG_TOUCHSCREEN_ZET6223 is not set
> > # CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
> > CONFIG_INPUT_MISC=y
> > # CONFIG_INPUT_AD714X is not set
> > # CONFIG_INPUT_BMA150 is not set
> > # CONFIG_INPUT_E3X0_BUTTON is not set
> > # CONFIG_INPUT_PCSPKR is not set
> > # CONFIG_INPUT_MMA8450 is not set
> > # CONFIG_INPUT_APANEL is not set
> > # CONFIG_INPUT_ATLAS_BTNS is not set
> > # CONFIG_INPUT_ATI_REMOTE2 is not set
> > # CONFIG_INPUT_KEYSPAN_REMOTE is not set
> > # CONFIG_INPUT_KXTJ9 is not set
> > # CONFIG_INPUT_POWERMATE is not set
> > # CONFIG_INPUT_YEALINK is not set
> > # CONFIG_INPUT_CM109 is not set
> > # CONFIG_INPUT_UINPUT is not set
> > # CONFIG_INPUT_PCF8574 is not set
> > # CONFIG_INPUT_ADXL34X is not set
> > # CONFIG_INPUT_IMS_PCU is not set
> > # CONFIG_INPUT_CMA3000 is not set
> > CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y
> > # CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
> > # CONFIG_INPUT_DRV2665_HAPTICS is not set
> > # CONFIG_INPUT_DRV2667_HAPTICS is not set
> > # CONFIG_RMI4_CORE is not set
> >
> > #
> > # Hardware I/O ports
> > #
> > CONFIG_SERIO=y
> > CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
> > CONFIG_SERIO_I8042=y
> > CONFIG_SERIO_SERPORT=y
> > # CONFIG_SERIO_CT82C710 is not set
> > # CONFIG_SERIO_PCIPS2 is not set
> > CONFIG_SERIO_LIBPS2=y
> > # CONFIG_SERIO_RAW is not set
> > # CONFIG_SERIO_ALTERA_PS2 is not set
> > # CONFIG_SERIO_PS2MULT is not set
> > # CONFIG_SERIO_ARC_PS2 is not set
> > # CONFIG_USERIO is not set
> > # CONFIG_GAMEPORT is not set
> >
> > #
> > # Character devices
> > #
> > CONFIG_TTY=y
> > CONFIG_VT=y
> > CONFIG_CONSOLE_TRANSLATIONS=y
> > CONFIG_VT_CONSOLE=y
> > CONFIG_VT_CONSOLE_SLEEP=y
> > CONFIG_HW_CONSOLE=y
> > CONFIG_VT_HW_CONSOLE_BINDING=y
> > CONFIG_UNIX98_PTYS=y
> > # CONFIG_LEGACY_PTYS is not set
> > CONFIG_SERIAL_NONSTANDARD=y
> > # CONFIG_ROCKETPORT is not set
> > # CONFIG_CYCLADES is not set
> > # CONFIG_MOXA_INTELLIO is not set
> > # CONFIG_MOXA_SMARTIO is not set
> > # CONFIG_SYNCLINK is not set
> > # CONFIG_SYNCLINKMP is not set
> > # CONFIG_SYNCLINK_GT is not set
> > # CONFIG_NOZOMI is not set
> > # CONFIG_ISI is not set
> > # CONFIG_N_HDLC is not set
> > # CONFIG_N_GSM is not set
> > # CONFIG_TRACE_SINK is not set
> > CONFIG_DEVMEM=y
> > # CONFIG_DEVKMEM is not set
> >
> > #
> > # Serial drivers
> > #
> > CONFIG_SERIAL_EARLYCON=y
> > CONFIG_SERIAL_8250=y
> > CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
> > CONFIG_SERIAL_8250_PNP=y
> > # CONFIG_SERIAL_8250_FINTEK is not set
> > CONFIG_SERIAL_8250_CONSOLE=y
> > CONFIG_SERIAL_8250_DMA=y
> > CONFIG_SERIAL_8250_PCI=y
> > # CONFIG_SERIAL_8250_EXAR is not set
> > # CONFIG_SERIAL_8250_CS is not set
> > CONFIG_SERIAL_8250_NR_UARTS=32
> > CONFIG_SERIAL_8250_RUNTIME_UARTS=4
> > CONFIG_SERIAL_8250_EXTENDED=y
> > CONFIG_SERIAL_8250_MANY_PORTS=y
> > CONFIG_SERIAL_8250_SHARE_IRQ=y
> > CONFIG_SERIAL_8250_DETECT_IRQ=y
> > CONFIG_SERIAL_8250_RSA=y
> > # CONFIG_SERIAL_8250_FSL is not set
> > # CONFIG_SERIAL_8250_DW is not set
> > # CONFIG_SERIAL_8250_RT288X is not set
> > CONFIG_SERIAL_8250_LPSS=y
> > CONFIG_SERIAL_8250_MID=y
> > # CONFIG_SERIAL_8250_MOXA is not set
> >
> > #
> > # Non-8250 serial port support
> > #
> > # CONFIG_SERIAL_UARTLITE is not set
> > CONFIG_SERIAL_CORE=y
> > CONFIG_SERIAL_CORE_CONSOLE=y
> > # CONFIG_SERIAL_JSM is not set
> > # CONFIG_SERIAL_SCCNXP is not set
> > # CONFIG_SERIAL_SC16IS7XX is not set
> > # CONFIG_SERIAL_ALTERA_JTAGUART is not set
> > # CONFIG_SERIAL_ALTERA_UART is not set
> > # CONFIG_SERIAL_ARC is not set
> > # CONFIG_SERIAL_RP2 is not set
> > # CONFIG_SERIAL_FSL_LPUART is not set
> > CONFIG_SERIAL_DEV_BUS=y
> > CONFIG_SERIAL_DEV_CTRL_TTYPORT=y
> > # CONFIG_TTY_PRINTK is not set
> > CONFIG_HVC_DRIVER=y
> > CONFIG_HVC_IRQ=y
> > CONFIG_HVC_XEN=y
> > CONFIG_HVC_XEN_FRONTEND=y
> > CONFIG_VIRTIO_CONSOLE=y
> > # CONFIG_IPMI_HANDLER is not set
> > CONFIG_HW_RANDOM=y
> > # CONFIG_HW_RANDOM_TIMERIOMEM is not set
> > # CONFIG_HW_RANDOM_INTEL is not set
> > # CONFIG_HW_RANDOM_AMD is not set
> > CONFIG_HW_RANDOM_VIA=y
> > # CONFIG_HW_RANDOM_VIRTIO is not set
> > CONFIG_NVRAM=y
> > # CONFIG_R3964 is not set
> > # CONFIG_APPLICOM is not set
> >
> > #
> > # PCMCIA character devices
> > #
> > # CONFIG_SYNCLINK_CS is not set
> > # CONFIG_CARDMAN_4000 is not set
> > # CONFIG_CARDMAN_4040 is not set
> > # CONFIG_SCR24X is not set
> > # CONFIG_IPWIRELESS is not set
> > # CONFIG_MWAVE is not set
> > # CONFIG_RAW_DRIVER is not set
> > CONFIG_HPET=y
> > # CONFIG_HPET_MMAP is not set
> > # CONFIG_HANGCHECK_TIMER is not set
> > # CONFIG_TCG_TPM is not set
> > # CONFIG_TELCLOCK is not set
> > CONFIG_DEVPORT=y
> > # CONFIG_XILLYBUS is not set
> >
> > #
> > # I2C support
> > #
> > CONFIG_I2C=y
> > CONFIG_ACPI_I2C_OPREGION=y
> > CONFIG_I2C_BOARDINFO=y
> > CONFIG_I2C_COMPAT=y
> > # CONFIG_I2C_CHARDEV is not set
> > # CONFIG_I2C_MUX is not set
> > CONFIG_I2C_HELPER_AUTO=y
> > CONFIG_I2C_SMBUS=y
> > CONFIG_I2C_ALGOBIT=y
> >
> > #
> > # I2C Hardware Bus support
> > #
> >
> > #
> > # PC SMBus host controller drivers
> > #
> > # CONFIG_I2C_ALI1535 is not set
> > # CONFIG_I2C_ALI1563 is not set
> > # CONFIG_I2C_ALI15X3 is not set
> > # CONFIG_I2C_AMD756 is not set
> > # CONFIG_I2C_AMD8111 is not set
> > CONFIG_I2C_I801=y
> > # CONFIG_I2C_ISCH is not set
> > # CONFIG_I2C_ISMT is not set
> > # CONFIG_I2C_PIIX4 is not set
> > # CONFIG_I2C_NFORCE2 is not set
> > # CONFIG_I2C_SIS5595 is not set
> > # CONFIG_I2C_SIS630 is not set
> > # CONFIG_I2C_SIS96X is not set
> > # CONFIG_I2C_VIA is not set
> > # CONFIG_I2C_VIAPRO is not set
> >
> > #
> > # ACPI drivers
> > #
> > # CONFIG_I2C_SCMI is not set
> >
> > #
> > # I2C system bus drivers (mostly embedded / system-on-chip)
> > #
> > # CONFIG_I2C_DESIGNWARE_PLATFORM is not set
> > # CONFIG_I2C_DESIGNWARE_PCI is not set
> > # CONFIG_I2C_EMEV2 is not set
> > # CONFIG_I2C_OCORES is not set
> > # CONFIG_I2C_PCA_PLATFORM is not set
> > # CONFIG_I2C_PXA_PCI is not set
> > # CONFIG_I2C_SIMTEC is not set
> > # CONFIG_I2C_XILINX is not set
> >
> > #
> > # External I2C/SMBus adapter drivers
> > #
> > # CONFIG_I2C_DIOLAN_U2C is not set
> > # CONFIG_I2C_PARPORT_LIGHT is not set
> > # CONFIG_I2C_ROBOTFUZZ_OSIF is not set
> > # CONFIG_I2C_TAOS_EVM is not set
> > # CONFIG_I2C_TINY_USB is not set
> >
> > #
> > # Other I2C/SMBus bus drivers
> > #
> > # CONFIG_I2C_MLXCPLD is not set
> > # CONFIG_I2C_STUB is not set
> > # CONFIG_I2C_SLAVE is not set
> > # CONFIG_I2C_DEBUG_CORE is not set
> > # CONFIG_I2C_DEBUG_ALGO is not set
> > # CONFIG_I2C_DEBUG_BUS is not set
> > # CONFIG_SPI is not set
> > # CONFIG_SPMI is not set
> > # CONFIG_HSI is not set
> > CONFIG_PPS=y
> > # CONFIG_PPS_DEBUG is not set
> >
> > #
> > # PPS clients support
> > #
> > # CONFIG_PPS_CLIENT_KTIMER is not set
> > # CONFIG_PPS_CLIENT_LDISC is not set
> > # CONFIG_PPS_CLIENT_GPIO is not set
> >
> > #
> > # PPS generators support
> > #
> >
> > #
> > # PTP clock support
> > #
> > CONFIG_PTP_1588_CLOCK=y
> >
> > #
> > # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional
> clocks.
> > #
> > CONFIG_PTP_1588_CLOCK_KVM=y
> > # CONFIG_PINCTRL is not set
> > # CONFIG_GPIOLIB is not set
> > # CONFIG_W1 is not set
> > # CONFIG_POWER_AVS is not set
> > # CONFIG_POWER_RESET is not set
> > CONFIG_POWER_SUPPLY=y
> > # CONFIG_POWER_SUPPLY_DEBUG is not set
> > # CONFIG_PDA_POWER is not set
> > # CONFIG_TEST_POWER is not set
> > # CONFIG_BATTERY_DS2780 is not set
> > # CONFIG_BATTERY_DS2781 is not set
> > # CONFIG_BATTERY_DS2782 is not set
> > # CONFIG_BATTERY_SBS is not set
> > # CONFIG_CHARGER_SBS is not set
> > # CONFIG_BATTERY_BQ27XXX is not set
> > # CONFIG_BATTERY_MAX17040 is not set
> > # CONFIG_BATTERY_MAX17042 is not set
> > # CONFIG_CHARGER_MAX8903 is not set
> > # CONFIG_CHARGER_LP8727 is not set
> > # CONFIG_CHARGER_BQ2415X is not set
> > # CONFIG_CHARGER_SMB347 is not set
> > # CONFIG_BATTERY_GAUGE_LTC2941 is not set
> > CONFIG_HWMON=y
> > # CONFIG_HWMON_DEBUG_CHIP is not set
> >
> > #
> > # Native drivers
> > #
> > # CONFIG_SENSORS_ABITUGURU is not set
> > # CONFIG_SENSORS_ABITUGURU3 is not set
> > # CONFIG_SENSORS_AD7414 is not set
> > # CONFIG_SENSORS_AD7418 is not set
> > # CONFIG_SENSORS_ADM1021 is not set
> > # CONFIG_SENSORS_ADM1025 is not set
> > # CONFIG_SENSORS_ADM1026 is not set
> > # CONFIG_SENSORS_ADM1029 is not set
> > # CONFIG_SENSORS_ADM1031 is not set
> > # CONFIG_SENSORS_ADM9240 is not set
> > # CONFIG_SENSORS_ADT7410 is not set
> > # CONFIG_SENSORS_ADT7411 is not set
> > # CONFIG_SENSORS_ADT7462 is not set
> > # CONFIG_SENSORS_ADT7470 is not set
> > # CONFIG_SENSORS_ADT7475 is not set
> > # CONFIG_SENSORS_ASC7621 is not set
> > # CONFIG_SENSORS_K8TEMP is not set
> > # CONFIG_SENSORS_K10TEMP is not set
> > # CONFIG_SENSORS_FAM15H_POWER is not set
> > # CONFIG_SENSORS_APPLESMC is not set
> > # CONFIG_SENSORS_ASB100 is not set
> > # CONFIG_SENSORS_ASPEED is not set
> > # CONFIG_SENSORS_ATXP1 is not set
> > # CONFIG_SENSORS_DS620 is not set
> > # CONFIG_SENSORS_DS1621 is not set
> > # CONFIG_SENSORS_DELL_SMM is not set
> > # CONFIG_SENSORS_I5K_AMB is not set
> > # CONFIG_SENSORS_F71805F is not set
> > # CONFIG_SENSORS_F71882FG is not set
> > # CONFIG_SENSORS_F75375S is not set
> > # CONFIG_SENSORS_FSCHMD is not set
> > # CONFIG_SENSORS_FTSTEUTATES is not set
> > # CONFIG_SENSORS_GL518SM is not set
> > # CONFIG_SENSORS_GL520SM is not set
> > # CONFIG_SENSORS_G760A is not set
> > # CONFIG_SENSORS_G762 is not set
> > # CONFIG_SENSORS_HIH6130 is not set
> > # CONFIG_SENSORS_I5500 is not set
> > # CONFIG_SENSORS_CORETEMP is not set
> > # CONFIG_SENSORS_IT87 is not set
> > # CONFIG_SENSORS_JC42 is not set
> > # CONFIG_SENSORS_POWR1220 is not set
> > # CONFIG_SENSORS_LINEAGE is not set
> > # CONFIG_SENSORS_LTC2945 is not set
> > # CONFIG_SENSORS_LTC2990 is not set
> > # CONFIG_SENSORS_LTC4151 is not set
> > # CONFIG_SENSORS_LTC4215 is not set
> > # CONFIG_SENSORS_LTC4222 is not set
> > # CONFIG_SENSORS_LTC4245 is not set
> > # CONFIG_SENSORS_LTC4260 is not set
> > # CONFIG_SENSORS_LTC4261 is not set
> > # CONFIG_SENSORS_MAX16065 is not set
> > # CONFIG_SENSORS_MAX1619 is not set
> > # CONFIG_SENSORS_MAX1668 is not set
> > # CONFIG_SENSORS_MAX197 is not set
> > # CONFIG_SENSORS_MAX6621 is not set
> > # CONFIG_SENSORS_MAX6639 is not set
> > # CONFIG_SENSORS_MAX6642 is not set
> > # CONFIG_SENSORS_MAX6650 is not set
> > # CONFIG_SENSORS_MAX6697 is not set
> > # CONFIG_SENSORS_MAX31790 is not set
> > # CONFIG_SENSORS_MCP3021 is not set
> > # CONFIG_SENSORS_TC654 is not set
> > # CONFIG_SENSORS_LM63 is not set
> > # CONFIG_SENSORS_LM73 is not set
> > # CONFIG_SENSORS_LM75 is not set
> > # CONFIG_SENSORS_LM77 is not set
> > # CONFIG_SENSORS_LM78 is not set
> > # CONFIG_SENSORS_LM80 is not set
> > # CONFIG_SENSORS_LM83 is not set
> > # CONFIG_SENSORS_LM85 is not set
> > # CONFIG_SENSORS_LM87 is not set
> > # CONFIG_SENSORS_LM90 is not set
> > # CONFIG_SENSORS_LM92 is not set
> > # CONFIG_SENSORS_LM93 is not set
> > # CONFIG_SENSORS_LM95234 is not set
> > # CONFIG_SENSORS_LM95241 is not set
> > # CONFIG_SENSORS_LM95245 is not set
> > # CONFIG_SENSORS_PC87360 is not set
> > # CONFIG_SENSORS_PC87427 is not set
> > # CONFIG_SENSORS_NTC_THERMISTOR is not set
> > # CONFIG_SENSORS_NCT6683 is not set
> > # CONFIG_SENSORS_NCT6775 is not set
> > # CONFIG_SENSORS_NCT7802 is not set
> > # CONFIG_SENSORS_NCT7904 is not set
> > # CONFIG_SENSORS_PCF8591 is not set
> > # CONFIG_PMBUS is not set
> > # CONFIG_SENSORS_SHT21 is not set
> > # CONFIG_SENSORS_SHT3x is not set
> > # CONFIG_SENSORS_SHTC1 is not set
> > # CONFIG_SENSORS_SIS5595 is not set
> > # CONFIG_SENSORS_DME1737 is not set
> > # CONFIG_SENSORS_EMC1403 is not set
> > # CONFIG_SENSORS_EMC2103 is not set
> > # CONFIG_SENSORS_EMC6W201 is not set
> > # CONFIG_SENSORS_SMSC47M1 is not set
> > # CONFIG_SENSORS_SMSC47M192 is not set
> > # CONFIG_SENSORS_SMSC47B397 is not set
> > # CONFIG_SENSORS_SCH5627 is not set
> > # CONFIG_SENSORS_SCH5636 is not set
> > # CONFIG_SENSORS_STTS751 is not set
> > # CONFIG_SENSORS_SMM665 is not set
> > # CONFIG_SENSORS_ADC128D818 is not set
> > # CONFIG_SENSORS_ADS1015 is not set
> > # CONFIG_SENSORS_ADS7828 is not set
> > # CONFIG_SENSORS_AMC6821 is not set
> > # CONFIG_SENSORS_INA209 is not set
> > # CONFIG_SENSORS_INA2XX is not set
> > # CONFIG_SENSORS_INA3221 is not set
> > # CONFIG_SENSORS_TC74 is not set
> > # CONFIG_SENSORS_THMC50 is not set
> > # CONFIG_SENSORS_TMP102 is not set
> > # CONFIG_SENSORS_TMP103 is not set
> > # CONFIG_SENSORS_TMP108 is not set
> > # CONFIG_SENSORS_TMP401 is not set
> > # CONFIG_SENSORS_TMP421 is not set
> > # CONFIG_SENSORS_VIA_CPUTEMP is not set
> > # CONFIG_SENSORS_VIA686A is not set
> > # CONFIG_SENSORS_VT1211 is not set
> > # CONFIG_SENSORS_VT8231 is not set
> > # CONFIG_SENSORS_W83773G is not set
> > # CONFIG_SENSORS_W83781D is not set
> > # CONFIG_SENSORS_W83791D is not set
> > # CONFIG_SENSORS_W83792D is not set
> > # CONFIG_SENSORS_W83793 is not set
> > # CONFIG_SENSORS_W83795 is not set
> > # CONFIG_SENSORS_W83L785TS is not set
> > # CONFIG_SENSORS_W83L786NG is not set
> > # CONFIG_SENSORS_W83627HF is not set
> > # CONFIG_SENSORS_W83627EHF is not set
> > # CONFIG_SENSORS_XGENE is not set
> >
> > #
> > # ACPI drivers
> > #
> > # CONFIG_SENSORS_ACPI_POWER is not set
> > # CONFIG_SENSORS_ATK0110 is not set
> > CONFIG_THERMAL=y
> > CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
> > CONFIG_THERMAL_HWMON=y
> > CONFIG_THERMAL_WRITABLE_TRIPS=y
> > CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
> > # CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
> > # CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
> > # CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
> > # CONFIG_THERMAL_GOV_FAIR_SHARE is not set
> > CONFIG_THERMAL_GOV_STEP_WISE=y
> > # CONFIG_THERMAL_GOV_BANG_BANG is not set
> > CONFIG_THERMAL_GOV_USER_SPACE=y
> > # CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
> > # CONFIG_THERMAL_EMULATION is not set
> > # CONFIG_INTEL_POWERCLAMP is not set
> > CONFIG_X86_PKG_TEMP_THERMAL=y
> > # CONFIG_INTEL_SOC_DTS_THERMAL is not set
> >
> > #
> > # ACPI INT340X thermal drivers
> > #
> > # CONFIG_INT340X_THERMAL is not set
> > # CONFIG_INTEL_PCH_THERMAL is not set
> > CONFIG_WATCHDOG=y
> > # CONFIG_WATCHDOG_CORE is not set
> > # CONFIG_WATCHDOG_NOWAYOUT is not set
> > CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
> > # CONFIG_WATCHDOG_SYSFS is not set
> >
> > #
> > # Watchdog Device Drivers
> > #
> > # CONFIG_SOFT_WATCHDOG is not set
> > # CONFIG_WDAT_WDT is not set
> > # CONFIG_XILINX_WATCHDOG is not set
> > # CONFIG_ZIIRAVE_WATCHDOG is not set
> > # CONFIG_CADENCE_WATCHDOG is not set
> > # CONFIG_DW_WATCHDOG is not set
> > # CONFIG_MAX63XX_WATCHDOG is not set
> > # CONFIG_ACQUIRE_WDT is not set
> > # CONFIG_ADVANTECH_WDT is not set
> > # CONFIG_ALIM1535_WDT is not set
> > # CONFIG_ALIM7101_WDT is not set
> > # CONFIG_F71808E_WDT is not set
> > # CONFIG_SP5100_TCO is not set
> > # CONFIG_SBC_FITPC2_WATCHDOG is not set
> > # CONFIG_EUROTECH_WDT is not set
> > # CONFIG_IB700_WDT is not set
> > # CONFIG_IBMASR is not set
> > # CONFIG_WAFER_WDT is not set
> > # CONFIG_I6300ESB_WDT is not set
> > # CONFIG_IE6XX_WDT is not set
> > # CONFIG_ITCO_WDT is not set
> > # CONFIG_IT8712F_WDT is not set
> > # CONFIG_IT87_WDT is not set
> > # CONFIG_HP_WATCHDOG is not set
> > # CONFIG_SC1200_WDT is not set
> > # CONFIG_PC87413_WDT is not set
> > # CONFIG_NV_TCO is not set
> > # CONFIG_60XX_WDT is not set
> > # CONFIG_CPU5_WDT is not set
> > # CONFIG_SMSC_SCH311X_WDT is not set
> > # CONFIG_SMSC37B787_WDT is not set
> > # CONFIG_VIA_WDT is not set
> > # CONFIG_W83627HF_WDT is not set
> > # CONFIG_W83877F_WDT is not set
> > # CONFIG_W83977F_WDT is not set
> > # CONFIG_MACHZ_WDT is not set
> > # CONFIG_SBC_EPX_C3_WATCHDOG is not set
> > # CONFIG_NI903X_WDT is not set
> > # CONFIG_NIC7018_WDT is not set
> > # CONFIG_XEN_WDT is not set
> >
> > #
> > # PCI-based Watchdog Cards
> > #
> > # CONFIG_PCIPCWATCHDOG is not set
> > # CONFIG_WDTPCI is not set
> >
> > #
> > # USB-based Watchdog Cards
> > #
> > # CONFIG_USBPCWATCHDOG is not set
> >
> > #
> > # Watchdog Pretimeout Governors
> > #
> > # CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
> > CONFIG_SSB_POSSIBLE=y
> > # CONFIG_SSB is not set
> > CONFIG_BCMA_POSSIBLE=y
> > # CONFIG_BCMA is not set
> >
> > #
> > # Multifunction device drivers
> > #
> > # CONFIG_MFD_CORE is not set
> > # CONFIG_MFD_AS3711 is not set
> > # CONFIG_PMIC_ADP5520 is not set
> > # CONFIG_MFD_BCM590XX is not set
> > # CONFIG_MFD_BD9571MWV is not set
> > # CONFIG_MFD_AXP20X_I2C is not set
> > # CONFIG_MFD_CROS_EC is not set
> > # CONFIG_PMIC_DA903X is not set
> > # CONFIG_MFD_DA9052_I2C is not set
> > # CONFIG_MFD_DA9055 is not set
> > # CONFIG_MFD_DA9062 is not set
> > # CONFIG_MFD_DA9063 is not set
> > # CONFIG_MFD_DA9150 is not set
> > # CONFIG_MFD_DLN2 is not set
> > # CONFIG_MFD_MC13XXX_I2C is not set
> > # CONFIG_HTC_PASIC3 is not set
> > # CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
> > # CONFIG_LPC_ICH is not set
> > # CONFIG_LPC_SCH is not set
> > # CONFIG_INTEL_SOC_PMIC_CHTWC is not set
> > # CONFIG_MFD_INTEL_LPSS_ACPI is not set
> > # CONFIG_MFD_INTEL_LPSS_PCI is not set
> > # CONFIG_MFD_JANZ_CMODIO is not set
> > # CONFIG_MFD_KEMPLD is not set
> > # CONFIG_MFD_88PM800 is not set
> > # CONFIG_MFD_88PM805 is not set
> > # CONFIG_MFD_88PM860X is not set
> > # CONFIG_MFD_MAX14577 is not set
> > # CONFIG_MFD_MAX77693 is not set
> > # CONFIG_MFD_MAX77843 is not set
> > # CONFIG_MFD_MAX8907 is not set
> > # CONFIG_MFD_MAX8925 is not set
> > # CONFIG_MFD_MAX8997 is not set
> > # CONFIG_MFD_MAX8998 is not set
> > # CONFIG_MFD_MT6397 is not set
> > # CONFIG_MFD_MENF21BMC is not set
> > # CONFIG_MFD_VIPERBOARD is not set
> > # CONFIG_MFD_RETU is not set
> > # CONFIG_MFD_PCF50633 is not set
> > # CONFIG_MFD_RDC321X is not set
> > # CONFIG_MFD_RT5033 is not set
> > # CONFIG_MFD_RC5T583 is not set
> > # CONFIG_MFD_SEC_CORE is not set
> > # CONFIG_MFD_SI476X_CORE is not set
> > # CONFIG_MFD_SM501 is not set
> > # CONFIG_MFD_SKY81452 is not set
> > # CONFIG_MFD_SMSC is not set
> > # CONFIG_ABX500_CORE is not set
> > # CONFIG_MFD_SYSCON is not set
> > # CONFIG_MFD_TI_AM335X_TSCADC is not set
> > # CONFIG_MFD_LP3943 is not set
> > # CONFIG_MFD_LP8788 is not set
> > # CONFIG_MFD_TI_LMU is not set
> > # CONFIG_MFD_PALMAS is not set
> > # CONFIG_TPS6105X is not set
> > # CONFIG_TPS6507X is not set
> > # CONFIG_MFD_TPS65086 is not set
> > # CONFIG_MFD_TPS65090 is not set
> > # CONFIG_MFD_TPS68470 is not set
> > # CONFIG_MFD_TI_LP873X is not set
> > # CONFIG_MFD_TPS6586X is not set
> > # CONFIG_MFD_TPS65912_I2C is not set
> > # CONFIG_MFD_TPS80031 is not set
> > # CONFIG_TWL4030_CORE is not set
> > # CONFIG_TWL6040_CORE is not set
> > # CONFIG_MFD_WL1273_CORE is not set
> > # CONFIG_MFD_LM3533 is not set
> > # CONFIG_MFD_TMIO is not set
> > # CONFIG_MFD_VX855 is not set
> > # CONFIG_MFD_ARIZONA_I2C is not set
> > # CONFIG_MFD_WM8400 is not set
> > # CONFIG_MFD_WM831X_I2C is not set
> > # CONFIG_MFD_WM8350_I2C is not set
> > # CONFIG_MFD_WM8994 is not set
> > # CONFIG_RAVE_SP_CORE is not set
> > # CONFIG_REGULATOR is not set
> > # CONFIG_RC_CORE is not set
> > # CONFIG_MEDIA_SUPPORT is not set
> >
> > #
> > # Graphics support
> > #
> > CONFIG_AGP=y
> > CONFIG_AGP_AMD64=y
> > CONFIG_AGP_INTEL=y
> > # CONFIG_AGP_SIS is not set
> > # CONFIG_AGP_VIA is not set
> > CONFIG_INTEL_GTT=y
> > CONFIG_VGA_ARB=y
> > CONFIG_VGA_ARB_MAX_GPUS=16
> > # CONFIG_VGA_SWITCHEROO is not set
> > CONFIG_DRM=y
> > CONFIG_DRM_MIPI_DSI=y
> > # CONFIG_DRM_DP_AUX_CHARDEV is not set
> > # CONFIG_DRM_DEBUG_MM is not set
> > # CONFIG_DRM_DEBUG_MM_SELFTEST is not set
> > CONFIG_DRM_KMS_HELPER=y
> > CONFIG_DRM_KMS_FB_HELPER=y
> > CONFIG_DRM_FBDEV_EMULATION=y
> > CONFIG_DRM_FBDEV_OVERALLOC=100
> > # CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
> > CONFIG_DRM_TTM=y
> > CONFIG_DRM_GEM_CMA_HELPER=y
> > CONFIG_DRM_KMS_CMA_HELPER=y
> > CONFIG_DRM_SCHED=y
> >
> > #
> > # I2C encoder or helper chips
> > #
> > # CONFIG_DRM_I2C_CH7006 is not set
> > # CONFIG_DRM_I2C_SIL164 is not set
> > # CONFIG_DRM_I2C_NXP_TDA998X is not set
> > CONFIG_DRM_RADEON=y
> > CONFIG_DRM_RADEON_USERPTR=y
> > CONFIG_DRM_AMDGPU=y
> > CONFIG_DRM_AMDGPU_SI=y
> > CONFIG_DRM_AMDGPU_CIK=y
> > CONFIG_DRM_AMDGPU_USERPTR=y
> > # CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set
> >
> > #
> > # ACP (Audio CoProcessor) Configuration
> > #
> > # CONFIG_DRM_AMD_ACP is not set
> >
> > #
> > # Display Engine Configuration
> > #
> > CONFIG_DRM_AMD_DC=y
> > # CONFIG_DRM_AMD_DC_PRE_VEGA is not set
> > # CONFIG_DRM_AMD_DC_FBC is not set
> > # CONFIG_DRM_AMD_DC_DCN1_0 is not set
> > # CONFIG_DEBUG_KERNEL_DC is not set
> >
> > #
> > # AMD Library routines
> > #
> > CONFIG_CHASH=y
> > # CONFIG_CHASH_STATS is not set
> > # CONFIG_CHASH_SELFTEST is not set
> > # CONFIG_DRM_NOUVEAU is not set
> > CONFIG_DRM_I915=y
> > CONFIG_DRM_I915_ALPHA_SUPPORT=y
> > CONFIG_DRM_I915_CAPTURE_ERROR=y
> > CONFIG_DRM_I915_COMPRESS_ERROR=y
> > CONFIG_DRM_I915_USERPTR=y
> > CONFIG_DRM_I915_GVT=y
> >
> > #
> > # drm/i915 Debugging
> > #
> > # CONFIG_DRM_I915_WERROR is not set
> > # CONFIG_DRM_I915_DEBUG is not set
> > # CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
> > # CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
> > # CONFIG_DRM_I915_SELFTEST is not set
> > # CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
> > # CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
> > # CONFIG_DRM_VGEM is not set
> > # CONFIG_DRM_VMWGFX is not set
> > # CONFIG_DRM_GMA500 is not set
> > # CONFIG_DRM_UDL is not set
> > # CONFIG_DRM_AST is not set
> > # CONFIG_DRM_MGAG200 is not set
> > CONFIG_DRM_CIRRUS_QEMU=y
> > CONFIG_DRM_QXL=y
> > # CONFIG_DRM_BOCHS is not set
> > CONFIG_DRM_VIRTIO_GPU=y
> > CONFIG_DRM_PANEL=y
> >
> > #
> > # Display Panels
> > #
> > # CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
> > CONFIG_DRM_BRIDGE=y
> > CONFIG_DRM_PANEL_BRIDGE=y
> >
> > #
> > # Display Interface Bridges
> > #
> > # CONFIG_DRM_ANALOGIX_ANX78XX is not set
> > # CONFIG_DRM_HISI_HIBMC is not set
> > CONFIG_DRM_TINYDRM=y
> > # CONFIG_DRM_LEGACY is not set
> > CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
> > # CONFIG_DRM_LIB_RANDOM is not set
> >
> > #
> > # Frame buffer Devices
> > #
> > CONFIG_FB=y
> > # CONFIG_FIRMWARE_EDID is not set
> > CONFIG_FB_CMDLINE=y
> > CONFIG_FB_NOTIFY=y
> > # CONFIG_FB_DDC is not set
> > # CONFIG_FB_BOOT_VESA_SUPPORT is not set
> > CONFIG_FB_CFB_FILLRECT=y
> > CONFIG_FB_CFB_COPYAREA=y
> > CONFIG_FB_CFB_IMAGEBLIT=y
> > # CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
> > CONFIG_FB_SYS_FILLRECT=y
> > CONFIG_FB_SYS_COPYAREA=y
> > CONFIG_FB_SYS_IMAGEBLIT=y
> > # CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
> > # CONFIG_FB_FOREIGN_ENDIAN is not set
> > CONFIG_FB_SYS_FOPS=y
> > CONFIG_FB_DEFERRED_IO=y
> > # CONFIG_FB_SVGALIB is not set
> > # CONFIG_FB_MACMODES is not set
> > # CONFIG_FB_BACKLIGHT is not set
> > CONFIG_FB_MODE_HELPERS=y
> > CONFIG_FB_TILEBLITTING=y
> >
> > #
> > # Frame buffer hardware drivers
> > #
> > # CONFIG_FB_CIRRUS is not set
> > # CONFIG_FB_PM2 is not set
> > # CONFIG_FB_CYBER2000 is not set
> > # CONFIG_FB_ARC is not set
> > # CONFIG_FB_ASILIANT is not set
> > # CONFIG_FB_IMSTT is not set
> > # CONFIG_FB_VGA16 is not set
> > # CONFIG_FB_UVESA is not set
> > # CONFIG_FB_VESA is not set
> > CONFIG_FB_EFI=y
> > # CONFIG_FB_N411 is not set
> > # CONFIG_FB_HGA is not set
> > # CONFIG_FB_OPENCORES is not set
> > # CONFIG_FB_S1D13XXX is not set
> > # CONFIG_FB_NVIDIA is not set
> > # CONFIG_FB_RIVA is not set
> > # CONFIG_FB_I740 is not set
> > # CONFIG_FB_LE80578 is not set
> > # CONFIG_FB_MATROX is not set
> > # CONFIG_FB_RADEON is not set
> > # CONFIG_FB_ATY128 is not set
> > # CONFIG_FB_ATY is not set
> > # CONFIG_FB_S3 is not set
> > # CONFIG_FB_SAVAGE is not set
> > # CONFIG_FB_SIS is not set
> > # CONFIG_FB_NEOMAGIC is not set
> > # CONFIG_FB_KYRO is not set
> > # CONFIG_FB_3DFX is not set
> > # CONFIG_FB_VOODOO1 is not set
> > # CONFIG_FB_VT8623 is not set
> > # CONFIG_FB_TRIDENT is not set
> > # CONFIG_FB_ARK is not set
> > # CONFIG_FB_PM3 is not set
> > # CONFIG_FB_CARMINE is not set
> > # CONFIG_FB_SMSCUFX is not set
> > # CONFIG_FB_UDL is not set
> > # CONFIG_FB_IBM_GXT4500 is not set
> > # CONFIG_FB_VIRTUAL is not set
> > CONFIG_XEN_FBDEV_FRONTEND=y
> > # CONFIG_FB_METRONOME is not set
> > # CONFIG_FB_MB862XX is not set
> > # CONFIG_FB_BROADSHEET is not set
> > # CONFIG_FB_AUO_K190X is not set
> > # CONFIG_FB_SIMPLE is not set
> > # CONFIG_FB_SM712 is not set
> > CONFIG_BACKLIGHT_LCD_SUPPORT=y
> > # CONFIG_LCD_CLASS_DEVICE is not set
> > CONFIG_BACKLIGHT_CLASS_DEVICE=y
> > CONFIG_BACKLIGHT_GENERIC=y
> > # CONFIG_BACKLIGHT_APPLE is not set
> > # CONFIG_BACKLIGHT_PM8941_WLED is not set
> > # CONFIG_BACKLIGHT_SAHARA is not set
> > # CONFIG_BACKLIGHT_ADP8860 is not set
> > # CONFIG_BACKLIGHT_ADP8870 is not set
> > # CONFIG_BACKLIGHT_LM3639 is not set
> > # CONFIG_BACKLIGHT_LV5207LP is not set
> > # CONFIG_BACKLIGHT_BD6107 is not set
> > # CONFIG_BACKLIGHT_ARCXCNN is not set
> > # CONFIG_VGASTATE is not set
> > CONFIG_HDMI=y
> >
> > #
> > # Console display driver support
> > #
> > CONFIG_VGA_CONSOLE=y
> > CONFIG_VGACON_SOFT_SCROLLBACK=y
> > CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
> > # CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
> > CONFIG_DUMMY_CONSOLE=y
> > CONFIG_DUMMY_CONSOLE_COLUMNS=80
> > CONFIG_DUMMY_CONSOLE_ROWS=25
> > CONFIG_FRAMEBUFFER_CONSOLE=y
> > CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
> > # CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
> > CONFIG_LOGO=y
> > # CONFIG_LOGO_LINUX_MONO is not set
> > # CONFIG_LOGO_LINUX_VGA16 is not set
> > CONFIG_LOGO_LINUX_CLUT224=y
> > CONFIG_SOUND=y
> > CONFIG_SOUND_OSS_CORE=y
> > CONFIG_SOUND_OSS_CORE_PRECLAIM=y
> > CONFIG_SND=y
> > CONFIG_SND_TIMER=y
> > CONFIG_SND_PCM=y
> > CONFIG_SND_HWDEP=y
> > CONFIG_SND_SEQ_DEVICE=y
> > CONFIG_SND_RAWMIDI=y
> > CONFIG_SND_JACK=y
> > CONFIG_SND_JACK_INPUT_DEV=y
> > CONFIG_SND_OSSEMUL=y
> > CONFIG_SND_MIXER_OSS=y
> > CONFIG_SND_PCM_OSS=y
> > CONFIG_SND_PCM_OSS_PLUGINS=y
> > CONFIG_SND_PCM_TIMER=y
> > CONFIG_SND_HRTIMER=y
> > CONFIG_SND_DYNAMIC_MINORS=y
> > CONFIG_SND_MAX_CARDS=32
> > CONFIG_SND_SUPPORT_OLD_API=y
> > CONFIG_SND_PROC_FS=y
> > CONFIG_SND_VERBOSE_PROCFS=y
> > # CONFIG_SND_VERBOSE_PRINTK is not set
> > CONFIG_SND_DEBUG=y
> > # CONFIG_SND_DEBUG_VERBOSE is not set
> > CONFIG_SND_PCM_XRUN_DEBUG=y
> > CONFIG_SND_VMASTER=y
> > CONFIG_SND_DMA_SGBUF=y
> > CONFIG_SND_SEQUENCER=y
> > CONFIG_SND_SEQ_DUMMY=y
> > CONFIG_SND_SEQUENCER_OSS=y
> > CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
> > CONFIG_SND_SEQ_MIDI_EVENT=y
> > CONFIG_SND_SEQ_MIDI=y
> > CONFIG_SND_SEQ_VIRMIDI=y
> > # CONFIG_SND_OPL3_LIB_SEQ is not set
> > # CONFIG_SND_OPL4_LIB_SEQ is not set
> > CONFIG_SND_DRIVERS=y
> > # CONFIG_SND_PCSP is not set
> > CONFIG_SND_DUMMY=y
> > CONFIG_SND_ALOOP=y
> > CONFIG_SND_VIRMIDI=y
> > # CONFIG_SND_MTPAV is not set
> > # CONFIG_SND_SERIAL_U16550 is not set
> > # CONFIG_SND_MPU401 is not set
> > CONFIG_SND_PCI=y
> > # CONFIG_SND_AD1889 is not set
> > # CONFIG_SND_ALS300 is not set
> > # CONFIG_SND_ALS4000 is not set
> > # CONFIG_SND_ALI5451 is not set
> > # CONFIG_SND_ASIHPI is not set
> > # CONFIG_SND_ATIIXP is not set
> > # CONFIG_SND_ATIIXP_MODEM is not set
> > # CONFIG_SND_AU8810 is not set
> > # CONFIG_SND_AU8820 is not set
> > # CONFIG_SND_AU8830 is not set
> > # CONFIG_SND_AW2 is not set
> > # CONFIG_SND_AZT3328 is not set
> > # CONFIG_SND_BT87X is not set
> > # CONFIG_SND_CA0106 is not set
> > # CONFIG_SND_CMIPCI is not set
> > # CONFIG_SND_OXYGEN is not set
> > # CONFIG_SND_CS4281 is not set
> > # CONFIG_SND_CS46XX is not set
> > # CONFIG_SND_CTXFI is not set
> > # CONFIG_SND_DARLA20 is not set
> > # CONFIG_SND_GINA20 is not set
> > # CONFIG_SND_LAYLA20 is not set
> > # CONFIG_SND_DARLA24 is not set
> > # CONFIG_SND_GINA24 is not set
> > # CONFIG_SND_LAYLA24 is not set
> > # CONFIG_SND_MONA is not set
> > # CONFIG_SND_MIA is not set
> > # CONFIG_SND_ECHO3G is not set
> > # CONFIG_SND_INDIGO is not set
> > # CONFIG_SND_INDIGOIO is not set
> > # CONFIG_SND_INDIGODJ is not set
> > # CONFIG_SND_INDIGOIOX is not set
> > # CONFIG_SND_INDIGODJX is not set
> > # CONFIG_SND_EMU10K1 is not set
> > # CONFIG_SND_EMU10K1_SEQ is not set
> > # CONFIG_SND_EMU10K1X is not set
> > # CONFIG_SND_ENS1370 is not set
> > # CONFIG_SND_ENS1371 is not set
> > # CONFIG_SND_ES1938 is not set
> > # CONFIG_SND_ES1968 is not set
> > # CONFIG_SND_FM801 is not set
> > # CONFIG_SND_HDSP is not set
> > # CONFIG_SND_HDSPM is not set
> > # CONFIG_SND_ICE1712 is not set
> > # CONFIG_SND_ICE1724 is not set
> > # CONFIG_SND_INTEL8X0 is not set
> > # CONFIG_SND_INTEL8X0M is not set
> > # CONFIG_SND_KORG1212 is not set
> > # CONFIG_SND_LOLA is not set
> > # CONFIG_SND_LX6464ES is not set
> > # CONFIG_SND_MAESTRO3 is not set
> > # CONFIG_SND_MIXART is not set
> > # CONFIG_SND_NM256 is not set
> > # CONFIG_SND_PCXHR is not set
> > # CONFIG_SND_RIPTIDE is not set
> > # CONFIG_SND_RME32 is not set
> > # CONFIG_SND_RME96 is not set
> > # CONFIG_SND_RME9652 is not set
> > # CONFIG_SND_SE6X is not set
> > # CONFIG_SND_SONICVIBES is not set
> > # CONFIG_SND_TRIDENT is not set
> > # CONFIG_SND_VIA82XX is not set
> > # CONFIG_SND_VIA82XX_MODEM is not set
> > # CONFIG_SND_VIRTUOSO is not set
> > # CONFIG_SND_VX222 is not set
> > # CONFIG_SND_YMFPCI is not set
> >
> > #
> > # HD-Audio
> > #
> > CONFIG_SND_HDA=y
> > CONFIG_SND_HDA_INTEL=y
> > CONFIG_SND_HDA_HWDEP=y
> > # CONFIG_SND_HDA_RECONFIG is not set
> > # CONFIG_SND_HDA_INPUT_BEEP is not set
> > # CONFIG_SND_HDA_PATCH_LOADER is not set
> > # CONFIG_SND_HDA_CODEC_REALTEK is not set
> > # CONFIG_SND_HDA_CODEC_ANALOG is not set
> > # CONFIG_SND_HDA_CODEC_SIGMATEL is not set
> > # CONFIG_SND_HDA_CODEC_VIA is not set
> > # CONFIG_SND_HDA_CODEC_HDMI is not set
> > # CONFIG_SND_HDA_CODEC_CIRRUS is not set
> > # CONFIG_SND_HDA_CODEC_CONEXANT is not set
> > # CONFIG_SND_HDA_CODEC_CA0110 is not set
> > # CONFIG_SND_HDA_CODEC_CA0132 is not set
> > # CONFIG_SND_HDA_CODEC_CMEDIA is not set
> > # CONFIG_SND_HDA_CODEC_SI3054 is not set
> > # CONFIG_SND_HDA_GENERIC is not set
> > CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
> > CONFIG_SND_HDA_CORE=y
> > CONFIG_SND_HDA_I915=y
> > CONFIG_SND_HDA_PREALLOC_SIZE=64
> > CONFIG_SND_USB=y
> > # CONFIG_SND_USB_AUDIO is not set
> > # CONFIG_SND_USB_UA101 is not set
> > # CONFIG_SND_USB_USX2Y is not set
> > # CONFIG_SND_USB_CAIAQ is not set
> > # CONFIG_SND_USB_US122L is not set
> > # CONFIG_SND_USB_6FIRE is not set
> > # CONFIG_SND_USB_HIFACE is not set
> > # CONFIG_SND_BCD2000 is not set
> > # CONFIG_SND_USB_POD is not set
> > # CONFIG_SND_USB_PODHD is not set
> > # CONFIG_SND_USB_TONEPORT is not set
> > # CONFIG_SND_USB_VARIAX is not set
> > CONFIG_SND_PCMCIA=y
> > # CONFIG_SND_VXPOCKET is not set
> > # CONFIG_SND_PDAUDIOCF is not set
> > # CONFIG_SND_SOC is not set
> > CONFIG_SND_X86=y
> > CONFIG_HDMI_LPE_AUDIO=y
> >
> > #
> > # HID support
> > #
> > CONFIG_HID=y
> > # CONFIG_HID_BATTERY_STRENGTH is not set
> > CONFIG_HIDRAW=y
> > # CONFIG_UHID is not set
> > CONFIG_HID_GENERIC=y
> >
> > #
> > # Special HID drivers
> > #
> > CONFIG_HID_A4TECH=y
> > # CONFIG_HID_ACCUTOUCH is not set
> > # CONFIG_HID_ACRUX is not set
> > CONFIG_HID_APPLE=y
> > # CONFIG_HID_APPLEIR is not set
> > # CONFIG_HID_ASUS is not set
> > # CONFIG_HID_AUREAL is not set
> > CONFIG_HID_BELKIN=y
> > # CONFIG_HID_BETOP_FF is not set
> > CONFIG_HID_CHERRY=y
> > CONFIG_HID_CHICONY=y
> > # CONFIG_HID_CORSAIR is not set
> > # CONFIG_HID_PRODIKEYS is not set
> > # CONFIG_HID_CMEDIA is not set
> > CONFIG_HID_CYPRESS=y
> > # CONFIG_HID_DRAGONRISE is not set
> > # CONFIG_HID_EMS_FF is not set
> > # CONFIG_HID_ELECOM is not set
> > # CONFIG_HID_ELO is not set
> > CONFIG_HID_EZKEY=y
> > # CONFIG_HID_GEMBIRD is not set
> > # CONFIG_HID_GFRM is not set
> > # CONFIG_HID_HOLTEK is not set
> > # CONFIG_HID_GT683R is not set
> > # CONFIG_HID_KEYTOUCH is not set
> > # CONFIG_HID_KYE is not set
> > # CONFIG_HID_UCLOGIC is not set
> > # CONFIG_HID_WALTOP is not set
> > CONFIG_HID_GYRATION=y
> > # CONFIG_HID_ICADE is not set
> > CONFIG_HID_ITE=y
> > # CONFIG_HID_JABRA is not set
> > # CONFIG_HID_TWINHAN is not set
> > CONFIG_HID_KENSINGTON=y
> > # CONFIG_HID_LCPOWER is not set
> > # CONFIG_HID_LED is not set
> > # CONFIG_HID_LENOVO is not set
> > CONFIG_HID_LOGITECH=y
> > # CONFIG_HID_LOGITECH_DJ is not set
> > # CONFIG_HID_LOGITECH_HIDPP is not set
> > CONFIG_LOGITECH_FF=y
> > # CONFIG_LOGIRUMBLEPAD2_FF is not set
> > # CONFIG_LOGIG940_FF is not set
> > CONFIG_LOGIWHEELS_FF=y
> > # CONFIG_HID_MAGICMOUSE is not set
> > # CONFIG_HID_MAYFLASH is not set
> > CONFIG_HID_MICROSOFT=y
> > CONFIG_HID_MONTEREY=y
> > # CONFIG_HID_MULTITOUCH is not set
> > # CONFIG_HID_NTI is not set
> > CONFIG_HID_NTRIG=y
> > # CONFIG_HID_ORTEK is not set
> > CONFIG_HID_PANTHERLORD=y
> > CONFIG_PANTHERLORD_FF=y
> > # CONFIG_HID_PENMOUNT is not set
> > CONFIG_HID_PETALYNX=y
> > # CONFIG_HID_PICOLCD is not set
> > # CONFIG_HID_PLANTRONICS is not set
> > # CONFIG_HID_PRIMAX is not set
> > # CONFIG_HID_RETRODE is not set
> > # CONFIG_HID_ROCCAT is not set
> > # CONFIG_HID_SAITEK is not set
> > CONFIG_HID_SAMSUNG=y
> > CONFIG_HID_SONY=y
> > # CONFIG_SONY_FF is not set
> > # CONFIG_HID_SPEEDLINK is not set
> > # CONFIG_HID_STEELSERIES is not set
> > CONFIG_HID_SUNPLUS=y
> > # CONFIG_HID_RMI is not set
> > # CONFIG_HID_GREENASIA is not set
> > # CONFIG_HID_SMARTJOYPLUS is not set
> > # CONFIG_HID_TIVO is not set
> > CONFIG_HID_TOPSEED=y
> > # CONFIG_HID_THINGM is not set
> > # CONFIG_HID_THRUSTMASTER is not set
> > # CONFIG_HID_UDRAW_PS3 is not set
> > # CONFIG_HID_WACOM is not set
> > # CONFIG_HID_WIIMOTE is not set
> > # CONFIG_HID_XINMO is not set
> > # CONFIG_HID_ZEROPLUS is not set
> > # CONFIG_HID_ZYDACRON is not set
> > # CONFIG_HID_SENSOR_HUB is not set
> > # CONFIG_HID_ALPS is not set
> >
> > #
> > # USB HID support
> > #
> > CONFIG_USB_HID=y
> > CONFIG_HID_PID=y
> > CONFIG_USB_HIDDEV=y
> >
> > #
> > # I2C HID support
> > #
> > # CONFIG_I2C_HID is not set
> >
> > #
> > # Intel ISH HID support
> > #
> > # CONFIG_INTEL_ISH_HID is not set
> > CONFIG_USB_OHCI_LITTLE_ENDIAN=y
> > CONFIG_USB_SUPPORT=y
> > CONFIG_USB_COMMON=y
> > CONFIG_USB_ARCH_HAS_HCD=y
> > CONFIG_USB=y
> > CONFIG_USB_PCI=y
> > CONFIG_USB_ANNOUNCE_NEW_DEVICES=y
> >
> > #
> > # Miscellaneous USB options
> > #
> > CONFIG_USB_DEFAULT_PERSIST=y
> > # CONFIG_USB_DYNAMIC_MINORS is not set
> > # CONFIG_USB_OTG is not set
> > # CONFIG_USB_OTG_WHITELIST is not set
> > # CONFIG_USB_OTG_BLACKLIST_HUB is not set
> > # CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
> > CONFIG_USB_MON=y
> > # CONFIG_USB_WUSB_CBAF is not set
> >
> > #
> > # USB Host Controller Drivers
> > #
> > # CONFIG_USB_C67X00_HCD is not set
> > # CONFIG_USB_XHCI_HCD is not set
> > CONFIG_USB_EHCI_HCD=y
> > # CONFIG_USB_EHCI_ROOT_HUB_TT is not set
> > CONFIG_USB_EHCI_TT_NEWSCHED=y
> > CONFIG_USB_EHCI_PCI=y
> > # CONFIG_USB_EHCI_HCD_PLATFORM is not set
> > # CONFIG_USB_OXU210HP_HCD is not set
> > # CONFIG_USB_ISP116X_HCD is not set
> > # CONFIG_USB_ISP1362_HCD is not set
> > # CONFIG_USB_FOTG210_HCD is not set
> > CONFIG_USB_OHCI_HCD=y
> > CONFIG_USB_OHCI_HCD_PCI=y
> > # CONFIG_USB_OHCI_HCD_PLATFORM is not set
> > CONFIG_USB_UHCI_HCD=y
> > # CONFIG_USB_SL811_HCD is not set
> > # CONFIG_USB_R8A66597_HCD is not set
> > # CONFIG_USB_HCD_TEST_MODE is not set
> >
> > #
> > # USB Device Class drivers
> > #
> > # CONFIG_USB_ACM is not set
> > CONFIG_USB_PRINTER=y
> > # CONFIG_USB_WDM is not set
> > # CONFIG_USB_TMC is not set
> >
> > #
> > # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
> > #
> >
> > #
> > # also be needed; see USB_STORAGE Help for more info
> > #
> > CONFIG_USB_STORAGE=y
> > # CONFIG_USB_STORAGE_DEBUG is not set
> > # CONFIG_USB_STORAGE_REALTEK is not set
> > # CONFIG_USB_STORAGE_DATAFAB is not set
> > # CONFIG_USB_STORAGE_FREECOM is not set
> > # CONFIG_USB_STORAGE_ISD200 is not set
> > # CONFIG_USB_STORAGE_USBAT is not set
> > # CONFIG_USB_STORAGE_SDDR09 is not set
> > # CONFIG_USB_STORAGE_SDDR55 is not set
> > # CONFIG_USB_STORAGE_JUMPSHOT is not set
> > # CONFIG_USB_STORAGE_ALAUDA is not set
> > # CONFIG_USB_STORAGE_ONETOUCH is not set
> > # CONFIG_USB_STORAGE_KARMA is not set
> > # CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
> > # CONFIG_USB_STORAGE_ENE_UB6250 is not set
> > # CONFIG_USB_UAS is not set
> >
> > #
> > # USB Imaging devices
> > #
> > # CONFIG_USB_MDC800 is not set
> > # CONFIG_USB_MICROTEK is not set
> > # CONFIG_USBIP_CORE is not set
> > # CONFIG_USB_MUSB_HDRC is not set
> > # CONFIG_USB_DWC3 is not set
> > # CONFIG_USB_DWC2 is not set
> > # CONFIG_USB_CHIPIDEA is not set
> > # CONFIG_USB_ISP1760 is not set
> >
> > #
> > # USB port drivers
> > #
> > # CONFIG_USB_SERIAL is not set
> >
> > #
> > # USB Miscellaneous drivers
> > #
> > # CONFIG_USB_EMI62 is not set
> > # CONFIG_USB_EMI26 is not set
> > # CONFIG_USB_ADUTUX is not set
> > # CONFIG_USB_SEVSEG is not set
> > # CONFIG_USB_RIO500 is not set
> > # CONFIG_USB_LEGOTOWER is not set
> > # CONFIG_USB_LCD is not set
> > # CONFIG_USB_CYPRESS_CY7C63 is not set
> > # CONFIG_USB_CYTHERM is not set
> > # CONFIG_USB_IDMOUSE is not set
> > # CONFIG_USB_FTDI_ELAN is not set
> > # CONFIG_USB_APPLEDISPLAY is not set
> > # CONFIG_USB_SISUSBVGA is not set
> > # CONFIG_USB_LD is not set
> > # CONFIG_USB_TRANCEVIBRATOR is not set
> > # CONFIG_USB_IOWARRIOR is not set
> > # CONFIG_USB_TEST is not set
> > # CONFIG_USB_EHSET_TEST_FIXTURE is not set
> > # CONFIG_USB_ISIGHTFW is not set
> > # CONFIG_USB_YUREX is not set
> > # CONFIG_USB_EZUSB_FX2 is not set
> > # CONFIG_USB_HUB_USB251XB is not set
> > # CONFIG_USB_HSIC_USB3503 is not set
> > # CONFIG_USB_HSIC_USB4604 is not set
> > # CONFIG_USB_LINK_LAYER_TEST is not set
> > # CONFIG_USB_CHAOSKEY is not set
> > CONFIG_USB_ATM=y
> > # CONFIG_USB_SPEEDTOUCH is not set
> > # CONFIG_USB_CXACRU is not set
> > # CONFIG_USB_UEAGLEATM is not set
> > # CONFIG_USB_XUSBATM is not set
> >
> > #
> > # USB Physical Layer drivers
> > #
> > # CONFIG_USB_PHY is not set
> > # CONFIG_NOP_USB_XCEIV is not set
> > # CONFIG_USB_ISP1301 is not set
> > # CONFIG_USB_GADGET is not set
> > CONFIG_TYPEC=y
> > CONFIG_TYPEC_TCPM=y
> > # CONFIG_TYPEC_FUSB302 is not set
> > CONFIG_TYPEC_UCSI=y
> > CONFIG_UCSI_ACPI=y
> > # CONFIG_TYPEC_TPS6598X is not set
> > # CONFIG_USB_LED_TRIG is not set
> > # CONFIG_USB_ULPI_BUS is not set
> > # CONFIG_UWB is not set
> > # CONFIG_MMC is not set
> > # CONFIG_MEMSTICK is not set
> > CONFIG_NEW_LEDS=y
> > CONFIG_LEDS_CLASS=y
> > # CONFIG_LEDS_CLASS_FLASH is not set
> > # CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set
> >
> > #
> > # LED drivers
> > #
> > # CONFIG_LEDS_APU is not set
> > # CONFIG_LEDS_LM3530 is not set
> > # CONFIG_LEDS_LM3642 is not set
> > # CONFIG_LEDS_PCA9532 is not set
> > # CONFIG_LEDS_LP3944 is not set
> > # CONFIG_LEDS_LP5521 is not set
> > # CONFIG_LEDS_LP5523 is not set
> > # CONFIG_LEDS_LP5562 is not set
> > # CONFIG_LEDS_LP8501 is not set
> > # CONFIG_LEDS_CLEVO_MAIL is not set
> > # CONFIG_LEDS_PCA955X is not set
> > # CONFIG_LEDS_PCA963X is not set
> > # CONFIG_LEDS_BD2802 is not set
> > # CONFIG_LEDS_INTEL_SS4200 is not set
> > # CONFIG_LEDS_TCA6507 is not set
> > # CONFIG_LEDS_TLC591XX is not set
> > # CONFIG_LEDS_LM355x is not set
> >
> > #
> > # LED driver for blink(1) USB RGB LED is under Special HID drivers
> (HID_THINGM)
> > #
> > # CONFIG_LEDS_BLINKM is not set
> > # CONFIG_LEDS_MLXCPLD is not set
> > # CONFIG_LEDS_USER is not set
> > # CONFIG_LEDS_NIC78BX is not set
> >
> > #
> > # LED Triggers
> > #
> > CONFIG_LEDS_TRIGGERS=y
> > # CONFIG_LEDS_TRIGGER_TIMER is not set
> > # CONFIG_LEDS_TRIGGER_ONESHOT is not set
> > # CONFIG_LEDS_TRIGGER_DISK is not set
> > # CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
> > # CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
> > # CONFIG_LEDS_TRIGGER_CPU is not set
> > # CONFIG_LEDS_TRIGGER_ACTIVITY is not set
> > # CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set
> >
> > #
> > # iptables trigger is under Netfilter config (LED target)
> > #
> > # CONFIG_LEDS_TRIGGER_TRANSIENT is not set
> > # CONFIG_LEDS_TRIGGER_CAMERA is not set
> > # CONFIG_LEDS_TRIGGER_PANIC is not set
> > # CONFIG_LEDS_TRIGGER_NETDEV is not set
> > # CONFIG_ACCESSIBILITY is not set
> > CONFIG_INFINIBAND=y
> > CONFIG_INFINIBAND_USER_MAD=y
> > CONFIG_INFINIBAND_USER_ACCESS=y
> > CONFIG_INFINIBAND_EXP_USER_ACCESS=y
> > CONFIG_INFINIBAND_USER_MEM=y
> > CONFIG_INFINIBAND_ON_DEMAND_PAGING=y
> > CONFIG_INFINIBAND_ADDR_TRANS=y
> > CONFIG_INFINIBAND_ADDR_TRANS_CONFIGFS=y
> > # CONFIG_INFINIBAND_MTHCA is not set
> > # CONFIG_INFINIBAND_QIB is not set
> > # CONFIG_MLX4_INFINIBAND is not set
> > # CONFIG_INFINIBAND_NES is not set
> > # CONFIG_INFINIBAND_OCRDMA is not set
> > CONFIG_INFINIBAND_USNIC=y
> > CONFIG_INFINIBAND_IPOIB=y
> > CONFIG_INFINIBAND_IPOIB_CM=y
> > CONFIG_INFINIBAND_IPOIB_DEBUG=y
> > # CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
> > CONFIG_INFINIBAND_SRP=y
> > CONFIG_INFINIBAND_ISER=y
> > CONFIG_INFINIBAND_OPA_VNIC=y
> > CONFIG_INFINIBAND_RDMAVT=y
> > CONFIG_RDMA_RXE=y
> > # CONFIG_INFINIBAND_HFI1 is not set
> > # CONFIG_INFINIBAND_BNXT_RE is not set
> > CONFIG_EDAC_ATOMIC_SCRUB=y
> > CONFIG_EDAC_SUPPORT=y
> > CONFIG_EDAC=y
> > CONFIG_EDAC_LEGACY_SYSFS=y
> > # CONFIG_EDAC_DEBUG is not set
> > CONFIG_EDAC_DECODE_MCE=y
> > # CONFIG_EDAC_AMD64 is not set
> > # CONFIG_EDAC_E752X is not set
> > # CONFIG_EDAC_I82975X is not set
> > # CONFIG_EDAC_I3000 is not set
> > # CONFIG_EDAC_I3200 is not set
> > # CONFIG_EDAC_IE31200 is not set
> > # CONFIG_EDAC_X38 is not set
> > # CONFIG_EDAC_I5400 is not set
> > # CONFIG_EDAC_I7CORE is not set
> > # CONFIG_EDAC_I5000 is not set
> > # CONFIG_EDAC_I5100 is not set
> > # CONFIG_EDAC_I7300 is not set
> > # CONFIG_EDAC_SBRIDGE is not set
> > # CONFIG_EDAC_SKX is not set
> > # CONFIG_EDAC_PND2 is not set
> > CONFIG_RTC_LIB=y
> > CONFIG_RTC_MC146818_LIB=y
> > CONFIG_RTC_CLASS=y
> > # CONFIG_RTC_HCTOSYS is not set
> > CONFIG_RTC_SYSTOHC=y
> > CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
> > # CONFIG_RTC_DEBUG is not set
> > # CONFIG_RTC_NVMEM is not set
> >
> > #
> > # RTC interfaces
> > #
> > CONFIG_RTC_INTF_SYSFS=y
> > CONFIG_RTC_INTF_PROC=y
> > CONFIG_RTC_INTF_DEV=y
> > # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
> > # CONFIG_RTC_DRV_TEST is not set
> >
> > #
> > # I2C RTC drivers
> > #
> > # CONFIG_RTC_DRV_ABB5ZES3 is not set
> > # CONFIG_RTC_DRV_ABX80X is not set
> > # CONFIG_RTC_DRV_DS1307 is not set
> > # CONFIG_RTC_DRV_DS1374 is not set
> > # CONFIG_RTC_DRV_DS1672 is not set
> > # CONFIG_RTC_DRV_MAX6900 is not set
> > # CONFIG_RTC_DRV_RS5C372 is not set
> > # CONFIG_RTC_DRV_ISL1208 is not set
> > # CONFIG_RTC_DRV_ISL12022 is not set
> > # CONFIG_RTC_DRV_X1205 is not set
> > # CONFIG_RTC_DRV_PCF8523 is not set
> > # CONFIG_RTC_DRV_PCF85063 is not set
> > # CONFIG_RTC_DRV_PCF85363 is not set
> > # CONFIG_RTC_DRV_PCF8563 is not set
> > # CONFIG_RTC_DRV_PCF8583 is not set
> > # CONFIG_RTC_DRV_M41T80 is not set
> > # CONFIG_RTC_DRV_BQ32K is not set
> > # CONFIG_RTC_DRV_S35390A is not set
> > # CONFIG_RTC_DRV_FM3130 is not set
> > # CONFIG_RTC_DRV_RX8010 is not set
> > # CONFIG_RTC_DRV_RX8581 is not set
> > # CONFIG_RTC_DRV_RX8025 is not set
> > # CONFIG_RTC_DRV_EM3027 is not set
> > # CONFIG_RTC_DRV_RV8803 is not set
> >
> > #
> > # SPI RTC drivers
> > #
> > CONFIG_RTC_I2C_AND_SPI=y
> >
> > #
> > # SPI and I2C RTC drivers
> > #
> > # CONFIG_RTC_DRV_DS3232 is not set
> > # CONFIG_RTC_DRV_PCF2127 is not set
> > # CONFIG_RTC_DRV_RV3029C2 is not set
> >
> > #
> > # Platform RTC drivers
> > #
> > CONFIG_RTC_DRV_CMOS=y
> > # CONFIG_RTC_DRV_DS1286 is not set
> > # CONFIG_RTC_DRV_DS1511 is not set
> > # CONFIG_RTC_DRV_DS1553 is not set
> > # CONFIG_RTC_DRV_DS1685_FAMILY is not set
> > # CONFIG_RTC_DRV_DS1742 is not set
> > # CONFIG_RTC_DRV_DS2404 is not set
> > # CONFIG_RTC_DRV_STK17TA8 is not set
> > # CONFIG_RTC_DRV_M48T86 is not set
> > # CONFIG_RTC_DRV_M48T35 is not set
> > # CONFIG_RTC_DRV_M48T59 is not set
> > # CONFIG_RTC_DRV_MSM6242 is not set
> > # CONFIG_RTC_DRV_BQ4802 is not set
> > # CONFIG_RTC_DRV_RP5C01 is not set
> > # CONFIG_RTC_DRV_V3020 is not set
> >
> > #
> > # on-CPU RTC drivers
> > #
> > # CONFIG_RTC_DRV_FTRTC010 is not set
> >
> > #
> > # HID Sensor RTC drivers
> > #
> > # CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
> > CONFIG_DMADEVICES=y
> > # CONFIG_DMADEVICES_DEBUG is not set
> >
> > #
> > # DMA Devices
> > #
> > CONFIG_DMA_ENGINE=y
> > CONFIG_DMA_VIRTUAL_CHANNELS=y
> > CONFIG_DMA_ACPI=y
> > # CONFIG_ALTERA_MSGDMA is not set
> > # CONFIG_INTEL_IDMA64 is not set
> > # CONFIG_INTEL_IOATDMA is not set
> > # CONFIG_QCOM_HIDMA_MGMT is not set
> > # CONFIG_QCOM_HIDMA is not set
> > CONFIG_DW_DMAC_CORE=y
> > # CONFIG_DW_DMAC is not set
> > # CONFIG_DW_DMAC_PCI is not set
> > CONFIG_HSU_DMA=y
> >
> > #
> > # DMA Clients
> > #
> > # CONFIG_ASYNC_TX_DMA is not set
> > # CONFIG_DMATEST is not set
> >
> > #
> > # DMABUF options
> > #
> > CONFIG_SYNC_FILE=y
> > # CONFIG_SW_SYNC is not set
> > # CONFIG_AUXDISPLAY is not set
> > # CONFIG_UIO is not set
> > # CONFIG_VFIO is not set
> > CONFIG_IRQ_BYPASS_MANAGER=y
> > # CONFIG_VIRT_DRIVERS is not set
> > CONFIG_VIRTIO=y
> > CONFIG_VIRTIO_MENU=y
> > CONFIG_VIRTIO_PCI=y
> > CONFIG_VIRTIO_PCI_LEGACY=y
> > CONFIG_VIRTIO_BALLOON=y
> > CONFIG_VIRTIO_INPUT=y
> > CONFIG_VIRTIO_MMIO=y
> > CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y
> >
> > #
> > # Microsoft Hyper-V guest support
> > #
> > # CONFIG_HYPERV is not set
> > # CONFIG_HYPERV_TSCPAGE is not set
> >
> > #
> > # Xen driver support
> > #
> > CONFIG_XEN_BALLOON=y
> > CONFIG_XEN_SCRUB_PAGES=y
> > CONFIG_XEN_DEV_EVTCHN=y
> > CONFIG_XEN_BACKEND=y
> > CONFIG_XENFS=y
> > CONFIG_XEN_COMPAT_XENFS=y
> > CONFIG_XEN_SYS_HYPERVISOR=y
> > CONFIG_XEN_XENBUS_FRONTEND=y
> > CONFIG_XEN_GNTDEV=y
> > CONFIG_XEN_GRANT_DEV_ALLOC=y
> > CONFIG_SWIOTLB_XEN=y
> > CONFIG_XEN_TMEM=m
> > CONFIG_XEN_PCIDEV_BACKEND=y
> > CONFIG_XEN_PVCALLS_FRONTEND=y
> > CONFIG_XEN_PVCALLS_BACKEND=y
> > CONFIG_XEN_PRIVCMD=y
> > CONFIG_XEN_ACPI_PROCESSOR=y
> > CONFIG_XEN_MCE_LOG=y
> > CONFIG_XEN_HAVE_PVMMU=y
> > CONFIG_XEN_EFI=y
> > CONFIG_XEN_AUTO_XLATE=y
> > CONFIG_XEN_ACPI=y
> > CONFIG_XEN_SYMS=y
> > CONFIG_XEN_HAVE_VPMU=y
> > CONFIG_STAGING=y
> > # CONFIG_IRDA is not set
> > # CONFIG_IPX is not set
> > # CONFIG_NCP_FS is not set
> > # CONFIG_PRISM2_USB is not set
> > # CONFIG_COMEDI is not set
> > # CONFIG_RTL8192U is not set
> > # CONFIG_RTLLIB is not set
> > # CONFIG_R8712U is not set
> > # CONFIG_R8188EU is not set
> > # CONFIG_R8822BE is not set
> > # CONFIG_RTS5208 is not set
> > # CONFIG_VT6655 is not set
> > # CONFIG_VT6656 is not set
> > # CONFIG_FB_SM750 is not set
> > # CONFIG_FB_XGI is not set
> >
> > #
> > # Speakup console speech
> > #
> > # CONFIG_SPEAKUP is not set
> > # CONFIG_STAGING_MEDIA is not set
> >
> > #
> > # Android
> > #
> > CONFIG_ASHMEM=y
> > CONFIG_ION=y
> > CONFIG_ION_SYSTEM_HEAP=y
> > CONFIG_ION_CARVEOUT_HEAP=y
> > CONFIG_ION_CHUNK_HEAP=y
> > # CONFIG_LTE_GDM724X is not set
> > # CONFIG_LNET is not set
> > # CONFIG_DGNC is not set
> > # CONFIG_GS_FPGABOOT is not set
> > # CONFIG_CRYPTO_SKEIN is not set
> > # CONFIG_UNISYSSPAR is not set
> > # CONFIG_MOST is not set
> > # CONFIG_GREYBUS is not set
> >
> > #
> > # USB Power Delivery and Type-C drivers
> > #
> > # CONFIG_TYPEC_TCPCI is not set
> > # CONFIG_DRM_VBOXVIDEO is not set
> > CONFIG_X86_PLATFORM_DEVICES=y
> > # CONFIG_ACER_WIRELESS is not set
> > # CONFIG_ACERHDF is not set
> > # CONFIG_ASUS_LAPTOP is not set
> > # CONFIG_DELL_LAPTOP is not set
> > # CONFIG_DELL_SMO8800 is not set
> > # CONFIG_DELL_RBTN is not set
> > # CONFIG_FUJITSU_LAPTOP is not set
> > # CONFIG_FUJITSU_TABLET is not set
> > # CONFIG_AMILO_RFKILL is not set
> > # CONFIG_GPD_POCKET_FAN is not set
> > # CONFIG_HP_ACCEL is not set
> > # CONFIG_HP_WIRELESS is not set
> > # CONFIG_MSI_LAPTOP is not set
> > # CONFIG_PANASONIC_LAPTOP is not set
> > # CONFIG_COMPAL_LAPTOP is not set
> > # CONFIG_SONY_LAPTOP is not set
> > # CONFIG_IDEAPAD_LAPTOP is not set
> > # CONFIG_THINKPAD_ACPI is not set
> > # CONFIG_SENSORS_HDAPS is not set
> > # CONFIG_INTEL_MENLOW is not set
> > CONFIG_EEEPC_LAPTOP=y
> > # CONFIG_ASUS_WIRELESS is not set
> > # CONFIG_ACPI_WMI is not set
> > # CONFIG_TOPSTAR_LAPTOP is not set
> > # CONFIG_TOSHIBA_BT_RFKILL is not set
> > # CONFIG_TOSHIBA_HAPS is not set
> > # CONFIG_ACPI_CMPC is not set
> > # CONFIG_INTEL_HID_EVENT is not set
> > # CONFIG_INTEL_VBTN is not set
> > # CONFIG_INTEL_IPS is not set
> > # CONFIG_INTEL_PMC_CORE is not set
> > # CONFIG_IBM_RTL is not set
> > # CONFIG_SAMSUNG_LAPTOP is not set
> > # CONFIG_INTEL_OAKTRAIL is not set
> > # CONFIG_SAMSUNG_Q10 is not set
> > # CONFIG_APPLE_GMUX is not set
> > # CONFIG_INTEL_RST is not set
> > # CONFIG_INTEL_SMARTCONNECT is not set
> > # CONFIG_PVPANIC is not set
> > # CONFIG_INTEL_PMC_IPC is not set
> > # CONFIG_SURFACE_PRO3_BUTTON is not set
> > # CONFIG_INTEL_PUNIT_IPC is not set
> > # CONFIG_MLX_PLATFORM is not set
> > # CONFIG_INTEL_TURBO_MAX_3 is not set
> > CONFIG_PMC_ATOM=y
> > # CONFIG_CHROME_PLATFORMS is not set
> > # CONFIG_MELLANOX_PLATFORM is not set
> > CONFIG_CLKDEV_LOOKUP=y
> > CONFIG_HAVE_CLK_PREPARE=y
> > CONFIG_COMMON_CLK=y
> >
> > #
> > # Common Clock Framework
> > #
> > # CONFIG_COMMON_CLK_SI5351 is not set
> > # CONFIG_COMMON_CLK_CDCE706 is not set
> > # CONFIG_COMMON_CLK_CS2000_CP is not set
> > # CONFIG_COMMON_CLK_NXP is not set
> > # CONFIG_COMMON_CLK_PXA is not set
> > # CONFIG_COMMON_CLK_PIC32 is not set
> > # CONFIG_HWSPINLOCK is not set
> >
> > #
> > # Clock Source drivers
> > #
> > CONFIG_CLKEVT_I8253=y
> > CONFIG_I8253_LOCK=y
> > CONFIG_CLKBLD_I8253=y
> > # CONFIG_ATMEL_PIT is not set
> > # CONFIG_SH_TIMER_CMT is not set
> > # CONFIG_SH_TIMER_MTU2 is not set
> > # CONFIG_SH_TIMER_TMU is not set
> > # CONFIG_EM_TIMER_STI is not set
> > CONFIG_MAILBOX=y
> > CONFIG_PCC=y
> > # CONFIG_ALTERA_MBOX is not set
> > CONFIG_IOMMU_API=y
> > CONFIG_IOMMU_SUPPORT=y
> >
> > #
> > # Generic IOMMU Pagetable Support
> > #
> > CONFIG_IOMMU_IOVA=y
> > CONFIG_AMD_IOMMU=y
> > # CONFIG_AMD_IOMMU_V2 is not set
> > CONFIG_DMAR_TABLE=y
> > CONFIG_INTEL_IOMMU=y
> > # CONFIG_INTEL_IOMMU_SVM is not set
> > # CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
> > CONFIG_INTEL_IOMMU_FLOPPY_WA=y
> > # CONFIG_IRQ_REMAP is not set
> >
> > #
> > # Remoteproc drivers
> > #
> > # CONFIG_REMOTEPROC is not set
> >
> > #
> > # Rpmsg drivers
> > #
> > # CONFIG_RPMSG_QCOM_GLINK_RPM is not set
> > # CONFIG_RPMSG_VIRTIO is not set
> > # CONFIG_SOUNDWIRE is not set
> >
> > #
> > # SOC (System On Chip) specific Drivers
> > #
> >
> > #
> > # Amlogic SoC drivers
> > #
> >
> > #
> > # Broadcom SoC drivers
> > #
> >
> > #
> > # i.MX SoC drivers
> > #
> >
> > #
> > # Qualcomm SoC drivers
> > #
> > # CONFIG_SUNXI_SRAM is not set
> > # CONFIG_SOC_TI is not set
> >
> > #
> > # Xilinx SoC drivers
> > #
> > # CONFIG_XILINX_VCU is not set
> > # CONFIG_PM_DEVFREQ is not set
> > # CONFIG_EXTCON is not set
> > # CONFIG_MEMORY is not set
> > # CONFIG_IIO is not set
> > # CONFIG_NTB is not set
> > # CONFIG_VME_BUS is not set
> > # CONFIG_PWM is not set
> >
> > #
> > # IRQ chip support
> > #
> > CONFIG_ARM_GIC_MAX_NR=1
> > # CONFIG_ARM_GIC_V3_ITS is not set
> > # CONFIG_IPACK_BUS is not set
> > # CONFIG_RESET_CONTROLLER is not set
> > # CONFIG_FMC is not set
> >
> > #
> > # PHY Subsystem
> > #
> > # CONFIG_GENERIC_PHY is not set
> > # CONFIG_BCM_KONA_USB2_PHY is not set
> > # CONFIG_PHY_PXA_28NM_HSIC is not set
> > # CONFIG_PHY_PXA_28NM_USB2 is not set
> > # CONFIG_POWERCAP is not set
> > # CONFIG_MCB is not set
> >
> > #
> > # Performance monitor support
> > #
> > CONFIG_RAS=y
> > # CONFIG_THUNDERBOLT is not set
> >
> > #
> > # Android
> > #
> > CONFIG_ANDROID=y
> > CONFIG_ANDROID_BINDER_IPC=y
> > CONFIG_ANDROID_BINDER_DEVICES="binder0,binder1,binder2,
> binder3,binder4,binder5,binder6,binder7,binder8,binder9,binder10,binder11,
> binder12,binder13,binder14,binder15,binder16,binder17,
> binder18,binder19,binder20,binder21,binder22,binder23,
> binder24,binder25,binder26,binder27,binder28,binder29,binder30,binder31"
> > # CONFIG_ANDROID_BINDER_IPC_SELFTEST is not set
> > # CONFIG_LIBNVDIMM is not set
> > CONFIG_DAX=y
> > # CONFIG_DEV_DAX is not set
> > # CONFIG_NVMEM is not set
> > # CONFIG_STM is not set
> > # CONFIG_INTEL_TH is not set
> > # CONFIG_FPGA is not set
> > # CONFIG_FSI is not set
> > # CONFIG_UNISYS_VISORBUS is not set
> > # CONFIG_SIOX is not set
> > # CONFIG_SLIMBUS is not set
> >
> > #
> > # Firmware Drivers
> > #
> > # CONFIG_EDD is not set
> > CONFIG_FIRMWARE_MEMMAP=y
> > # CONFIG_DELL_RBU is not set
> > # CONFIG_DCDBAS is not set
> > CONFIG_DMIID=y
> > # CONFIG_DMI_SYSFS is not set
> > CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
> > # CONFIG_ISCSI_IBFT_FIND is not set
> > # CONFIG_FW_CFG_SYSFS is not set
> > # CONFIG_GOOGLE_FIRMWARE is not set
> >
> > #
> > # EFI (Extensible Firmware Interface) Support
> > #
> > CONFIG_EFI_VARS=y
> > CONFIG_EFI_ESRT=y
> > CONFIG_EFI_RUNTIME_MAP=y
> > # CONFIG_EFI_FAKE_MEMMAP is not set
> > CONFIG_EFI_RUNTIME_WRAPPERS=y
> > # CONFIG_EFI_BOOTLOADER_CONTROL is not set
> > # CONFIG_EFI_CAPSULE_LOADER is not set
> > # CONFIG_EFI_TEST is not set
> > # CONFIG_EFI_DEV_PATH_PARSER is not set
> >
> > #
> > # Tegra firmware driver
> > #
> >
> > #
> > # File systems
> > #
> > CONFIG_DCACHE_WORD_ACCESS=y
> > CONFIG_FS_IOMAP=y
> > # CONFIG_EXT2_FS is not set
> > # CONFIG_EXT3_FS is not set
> > CONFIG_EXT4_FS=y
> > CONFIG_EXT4_USE_FOR_EXT2=y
> > CONFIG_EXT4_FS_POSIX_ACL=y
> > CONFIG_EXT4_FS_SECURITY=y
> > CONFIG_EXT4_ENCRYPTION=y
> > CONFIG_EXT4_FS_ENCRYPTION=y
> > # CONFIG_EXT4_DEBUG is not set
> > CONFIG_JBD2=y
> > # CONFIG_JBD2_DEBUG is not set
> > CONFIG_FS_MBCACHE=y
> > # CONFIG_REISERFS_FS is not set
> > # CONFIG_JFS_FS is not set
> > # CONFIG_XFS_FS is not set
> > # CONFIG_GFS2_FS is not set
> > # CONFIG_OCFS2_FS is not set
> > # CONFIG_BTRFS_FS is not set
> > # CONFIG_NILFS2_FS is not set
> > # CONFIG_F2FS_FS is not set
> > # CONFIG_FS_DAX is not set
> > CONFIG_FS_POSIX_ACL=y
> > CONFIG_EXPORTFS=y
> > # CONFIG_EXPORTFS_BLOCK_OPS is not set
> > CONFIG_FILE_LOCKING=y
> > CONFIG_MANDATORY_FILE_LOCKING=y
> > CONFIG_FS_ENCRYPTION=y
> > CONFIG_FSNOTIFY=y
> > CONFIG_DNOTIFY=y
> > CONFIG_INOTIFY_USER=y
> > CONFIG_FANOTIFY=y
> > CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
> > CONFIG_QUOTA=y
> > CONFIG_QUOTA_NETLINK_INTERFACE=y
> > # CONFIG_PRINT_QUOTA_WARNING is not set
> > # CONFIG_QUOTA_DEBUG is not set
> > CONFIG_QUOTA_TREE=y
> > # CONFIG_QFMT_V1 is not set
> > CONFIG_QFMT_V2=y
> > CONFIG_QUOTACTL=y
> > CONFIG_QUOTACTL_COMPAT=y
> > CONFIG_AUTOFS4_FS=y
> > CONFIG_FUSE_FS=y
> > CONFIG_CUSE=y
> > CONFIG_OVERLAY_FS=y
> > CONFIG_OVERLAY_FS_REDIRECT_DIR=y
> > CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
> > CONFIG_OVERLAY_FS_INDEX=y
> > # CONFIG_OVERLAY_FS_NFS_EXPORT is not set
> >
> > #
> > # Caches
> > #
> > CONFIG_FSCACHE=y
> > # CONFIG_FSCACHE_STATS is not set
> > # CONFIG_FSCACHE_HISTOGRAM is not set
> > # CONFIG_FSCACHE_DEBUG is not set
> > # CONFIG_FSCACHE_OBJECT_LIST is not set
> > # CONFIG_CACHEFILES is not set
> >
> > #
> > # CD-ROM/DVD Filesystems
> > #
> > CONFIG_ISO9660_FS=y
> > CONFIG_JOLIET=y
> > CONFIG_ZISOFS=y
> > # CONFIG_UDF_FS is not set
> >
> > #
> > # DOS/FAT/NT Filesystems
> > #
> > CONFIG_FAT_FS=y
> > CONFIG_MSDOS_FS=y
> > CONFIG_VFAT_FS=y
> > CONFIG_FAT_DEFAULT_CODEPAGE=437
> > CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
> > # CONFIG_FAT_DEFAULT_UTF8 is not set
> > # CONFIG_NTFS_FS is not set
> >
> > #
> > # Pseudo filesystems
> > #
> > CONFIG_PROC_FS=y
> > CONFIG_PROC_KCORE=y
> > CONFIG_PROC_VMCORE=y
> > CONFIG_PROC_SYSCTL=y
> > CONFIG_PROC_PAGE_MONITOR=y
> > CONFIG_PROC_CHILDREN=y
> > CONFIG_KERNFS=y
> > CONFIG_SYSFS=y
> > CONFIG_TMPFS=y
> > CONFIG_TMPFS_POSIX_ACL=y
> > CONFIG_TMPFS_XATTR=y
> > CONFIG_HUGETLBFS=y
> > CONFIG_HUGETLB_PAGE=y
> > CONFIG_CONFIGFS_FS=y
> > CONFIG_EFIVAR_FS=y
> > CONFIG_MISC_FILESYSTEMS=y
> > # CONFIG_ORANGEFS_FS is not set
> > # CONFIG_ADFS_FS is not set
> > # CONFIG_AFFS_FS is not set
> > # CONFIG_ECRYPT_FS is not set
> > # CONFIG_HFS_FS is not set
> > # CONFIG_HFSPLUS_FS is not set
> > # CONFIG_BEFS_FS is not set
> > # CONFIG_BFS_FS is not set
> > # CONFIG_EFS_FS is not set
> > # CONFIG_CRAMFS is not set
> > # CONFIG_SQUASHFS is not set
> > # CONFIG_VXFS_FS is not set
> > # CONFIG_MINIX_FS is not set
> > # CONFIG_OMFS_FS is not set
> > # CONFIG_HPFS_FS is not set
> > # CONFIG_QNX4FS_FS is not set
> > # CONFIG_QNX6FS_FS is not set
> > # CONFIG_ROMFS_FS is not set
> > # CONFIG_PSTORE is not set
> > # CONFIG_SYSV_FS is not set
> > # CONFIG_UFS_FS is not set
> > CONFIG_NETWORK_FILESYSTEMS=y
> > CONFIG_NFS_FS=y
> > CONFIG_NFS_V2=y
> > CONFIG_NFS_V3=y
> > CONFIG_NFS_V3_ACL=y
> > CONFIG_NFS_V4=y
> > # CONFIG_NFS_SWAP is not set
> > # CONFIG_NFS_V4_1 is not set
> > CONFIG_ROOT_NFS=y
> > # CONFIG_NFS_FSCACHE is not set
> > # CONFIG_NFS_USE_LEGACY_DNS is not set
> > CONFIG_NFS_USE_KERNEL_DNS=y
> > # CONFIG_NFSD is not set
> > CONFIG_GRACE_PERIOD=y
> > CONFIG_LOCKD=y
> > CONFIG_LOCKD_V4=y
> > CONFIG_NFS_ACL_SUPPORT=y
> > CONFIG_NFS_COMMON=y
> > CONFIG_SUNRPC=y
> > CONFIG_SUNRPC_GSS=y
> > CONFIG_RPCSEC_GSS_KRB5=y
> > # CONFIG_SUNRPC_DEBUG is not set
> > CONFIG_SUNRPC_XPRT_RDMA=y
> > # CONFIG_CEPH_FS is not set
> > # CONFIG_CIFS is not set
> > # CONFIG_CODA_FS is not set
> > # CONFIG_AFS_FS is not set
> > CONFIG_9P_FS=y
> > # CONFIG_9P_FSCACHE is not set
> > # CONFIG_9P_FS_POSIX_ACL is not set
> > # CONFIG_9P_FS_SECURITY is not set
> > CONFIG_NLS=y
> > CONFIG_NLS_DEFAULT="utf8"
> > CONFIG_NLS_CODEPAGE_437=y
> > # CONFIG_NLS_CODEPAGE_737 is not set
> > # CONFIG_NLS_CODEPAGE_775 is not set
> > # CONFIG_NLS_CODEPAGE_850 is not set
> > # CONFIG_NLS_CODEPAGE_852 is not set
> > # CONFIG_NLS_CODEPAGE_855 is not set
> > # CONFIG_NLS_CODEPAGE_857 is not set
> > # CONFIG_NLS_CODEPAGE_860 is not set
> > # CONFIG_NLS_CODEPAGE_861 is not set
> > # CONFIG_NLS_CODEPAGE_862 is not set
> > # CONFIG_NLS_CODEPAGE_863 is not set
> > # CONFIG_NLS_CODEPAGE_864 is not set
> > # CONFIG_NLS_CODEPAGE_865 is not set
> > # CONFIG_NLS_CODEPAGE_866 is not set
> > # CONFIG_NLS_CODEPAGE_869 is not set
> > # CONFIG_NLS_CODEPAGE_936 is not set
> > # CONFIG_NLS_CODEPAGE_950 is not set
> > # CONFIG_NLS_CODEPAGE_932 is not set
> > # CONFIG_NLS_CODEPAGE_949 is not set
> > # CONFIG_NLS_CODEPAGE_874 is not set
> > # CONFIG_NLS_ISO8859_8 is not set
> > # CONFIG_NLS_CODEPAGE_1250 is not set
> > # CONFIG_NLS_CODEPAGE_1251 is not set
> > CONFIG_NLS_ASCII=y
> > CONFIG_NLS_ISO8859_1=y
> > # CONFIG_NLS_ISO8859_2 is not set
> > # CONFIG_NLS_ISO8859_3 is not set
> > # CONFIG_NLS_ISO8859_4 is not set
> > # CONFIG_NLS_ISO8859_5 is not set
> > # CONFIG_NLS_ISO8859_6 is not set
> > # CONFIG_NLS_ISO8859_7 is not set
> > # CONFIG_NLS_ISO8859_9 is not set
> > # CONFIG_NLS_ISO8859_13 is not set
> > # CONFIG_NLS_ISO8859_14 is not set
> > # CONFIG_NLS_ISO8859_15 is not set
> > # CONFIG_NLS_KOI8_R is not set
> > # CONFIG_NLS_KOI8_U is not set
> > # CONFIG_NLS_MAC_ROMAN is not set
> > # CONFIG_NLS_MAC_CELTIC is not set
> > # CONFIG_NLS_MAC_CENTEURO is not set
> > # CONFIG_NLS_MAC_CROATIAN is not set
> > # CONFIG_NLS_MAC_CYRILLIC is not set
> > # CONFIG_NLS_MAC_GAELIC is not set
> > # CONFIG_NLS_MAC_GREEK is not set
> > # CONFIG_NLS_MAC_ICELAND is not set
> > # CONFIG_NLS_MAC_INUIT is not set
> > # CONFIG_NLS_MAC_ROMANIAN is not set
> > # CONFIG_NLS_MAC_TURKISH is not set
> > CONFIG_NLS_UTF8=y
> > # CONFIG_DLM is not set
> >
> > #
> > # Kernel hacking
> > #
> > CONFIG_TRACE_IRQFLAGS_SUPPORT=y
> >
> > #
> > # printk and dmesg options
> > #
> > CONFIG_PRINTK_TIME=y
> > CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
> > CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
> > # CONFIG_BOOT_PRINTK_DELAY is not set
> > # CONFIG_DYNAMIC_DEBUG is not set
> >
> > #
> > # Compile-time checks and compiler options
> > #
> > CONFIG_DEBUG_INFO=y
> > # CONFIG_DEBUG_INFO_REDUCED is not set
> > # CONFIG_DEBUG_INFO_SPLIT is not set
> > # CONFIG_DEBUG_INFO_DWARF4 is not set
> > # CONFIG_GDB_SCRIPTS is not set
> > # CONFIG_ENABLE_WARN_DEPRECATED is not set
> > CONFIG_ENABLE_MUST_CHECK=y
> > CONFIG_FRAME_WARN=2048
> > # CONFIG_STRIP_ASM_SYMS is not set
> > # CONFIG_READABLE_ASM is not set
> > # CONFIG_UNUSED_SYMBOLS is not set
> > # CONFIG_PAGE_OWNER is not set
> > CONFIG_DEBUG_FS=y
> > # CONFIG_HEADERS_CHECK is not set
> > # CONFIG_DEBUG_SECTION_MISMATCH is not set
> > CONFIG_SECTION_MISMATCH_WARN_ONLY=y
> > CONFIG_FRAME_POINTER=y
> > # CONFIG_STACK_VALIDATION is not set
> > # CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
> > CONFIG_MAGIC_SYSRQ=y
> > CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
> > CONFIG_MAGIC_SYSRQ_SERIAL=y
> > CONFIG_DEBUG_KERNEL=y
> >
> > #
> > # Memory Debugging
> > #
> > CONFIG_PAGE_EXTENSION=y
> > # CONFIG_DEBUG_PAGEALLOC is not set
> > CONFIG_PAGE_POISONING=y
> > CONFIG_PAGE_POISONING_NO_SANITY=y
> > # CONFIG_PAGE_POISONING_ZERO is not set
> > # CONFIG_DEBUG_PAGE_REF is not set
> > # CONFIG_DEBUG_RODATA_TEST is not set
> > CONFIG_DEBUG_OBJECTS=y
> > # CONFIG_DEBUG_OBJECTS_SELFTEST is not set
> > CONFIG_DEBUG_OBJECTS_FREE=y
> > CONFIG_DEBUG_OBJECTS_TIMERS=y
> > CONFIG_DEBUG_OBJECTS_WORK=y
> > CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
> > CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
> > CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
> > # CONFIG_DEBUG_SLAB is not set
> > CONFIG_HAVE_DEBUG_KMEMLEAK=y
> > # CONFIG_DEBUG_KMEMLEAK is not set
> > CONFIG_DEBUG_STACK_USAGE=y
> > CONFIG_DEBUG_VM=y
> > CONFIG_DEBUG_VM_VMACACHE=y
> > # CONFIG_DEBUG_VM_RB is not set
> > # CONFIG_DEBUG_VM_PGFLAGS is not set
> > CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
> > # CONFIG_DEBUG_VIRTUAL is not set
> > CONFIG_DEBUG_MEMORY_INIT=y
> > # CONFIG_DEBUG_PER_CPU_MAPS is not set
> > CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
> > CONFIG_DEBUG_STACKOVERFLOW=y
> > CONFIG_HAVE_ARCH_KASAN=y
> > CONFIG_KASAN=y
> > CONFIG_KASAN_EXTRA=y
> > # CONFIG_KASAN_OUTLINE is not set
> > CONFIG_KASAN_INLINE=y
> > # CONFIG_TEST_KASAN is not set
> > CONFIG_ARCH_HAS_KCOV=y
> > CONFIG_KCOV=y
> > CONFIG_KCOV_ENABLE_COMPARISONS=y
> > CONFIG_KCOV_INSTRUMENT_ALL=y
> > # CONFIG_DEBUG_SHIRQ is not set
> >
> > #
> > # Debug Lockups and Hangs
> > #
> > CONFIG_LOCKUP_DETECTOR=y
> > CONFIG_SOFTLOCKUP_DETECTOR=y
> > CONFIG_HARDLOCKUP_DETECTOR_PERF=y
> > CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
> > CONFIG_HARDLOCKUP_DETECTOR=y
> > CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
> > CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
> > CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
> > CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
> > CONFIG_DETECT_HUNG_TASK=y
> > CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
> > CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
> > CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
> > CONFIG_WQ_WATCHDOG=y
> > CONFIG_PANIC_ON_OOPS=y
> > CONFIG_PANIC_ON_OOPS_VALUE=1
> > CONFIG_PANIC_TIMEOUT=86400
> > # CONFIG_SCHED_DEBUG is not set
> > CONFIG_SCHED_INFO=y
> > CONFIG_SCHEDSTATS=y
> > CONFIG_SCHED_STACK_END_CHECK=y
> > # CONFIG_DEBUG_TIMEKEEPING is not set
> >
> > #
> > # Lock Debugging (spinlocks, mutexes, etc...)
> > #
> > CONFIG_DEBUG_RT_MUTEXES=y
> > CONFIG_DEBUG_SPINLOCK=y
> > CONFIG_DEBUG_MUTEXES=y
> > # CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
> > CONFIG_DEBUG_LOCK_ALLOC=y
> > CONFIG_PROVE_LOCKING=y
> > CONFIG_LOCKDEP=y
> > # CONFIG_LOCK_STAT is not set
> > # CONFIG_DEBUG_LOCKDEP is not set
> > CONFIG_DEBUG_ATOMIC_SLEEP=y
> > # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> > # CONFIG_LOCK_TORTURE_TEST is not set
> > # CONFIG_WW_MUTEX_SELFTEST is not set
> > CONFIG_TRACE_IRQFLAGS=y
> > CONFIG_STACKTRACE=y
> > # CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
> > # CONFIG_DEBUG_KOBJECT is not set
> > # CONFIG_DEBUG_KOBJECT_RELEASE is not set
> > CONFIG_DEBUG_BUGVERBOSE=y
> > CONFIG_DEBUG_LIST=y
> > CONFIG_DEBUG_PI_LIST=y
> > # CONFIG_DEBUG_SG is not set
> > CONFIG_DEBUG_NOTIFIERS=y
> > # CONFIG_DEBUG_CREDENTIALS is not set
> >
> > #
> > # RCU Debugging
> > #
> > CONFIG_PROVE_RCU=y
> > # CONFIG_TORTURE_TEST is not set
> > # CONFIG_RCU_PERF_TEST is not set
> > # CONFIG_RCU_TORTURE_TEST is not set
> > CONFIG_RCU_CPU_STALL_TIMEOUT=120
> > # CONFIG_RCU_TRACE is not set
> > # CONFIG_RCU_EQS_DEBUG is not set
> > # CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
> > # CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
> > # CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
> > # CONFIG_NOTIFIER_ERROR_INJECTION is not set
> > CONFIG_FAULT_INJECTION=y
> > CONFIG_FUNCTION_ERROR_INJECTION=y
> > CONFIG_FAILSLAB=y
> > CONFIG_FAIL_PAGE_ALLOC=y
> > CONFIG_FAIL_MAKE_REQUEST=y
> > CONFIG_FAIL_IO_TIMEOUT=y
> > CONFIG_FAIL_FUTEX=y
> > # CONFIG_FAIL_FUNCTION is not set
> > CONFIG_FAULT_INJECTION_DEBUG_FS=y
> > # CONFIG_LATENCYTOP is not set
> > CONFIG_USER_STACKTRACE_SUPPORT=y
> > CONFIG_NOP_TRACER=y
> > CONFIG_HAVE_FUNCTION_TRACER=y
> > CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
> > CONFIG_HAVE_DYNAMIC_FTRACE=y
> > CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
> > CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
> > CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
> > CONFIG_HAVE_FENTRY=y
> > CONFIG_HAVE_C_RECORDMCOUNT=y
> > CONFIG_TRACE_CLOCK=y
> > CONFIG_RING_BUFFER=y
> > CONFIG_EVENT_TRACING=y
> > CONFIG_CONTEXT_SWITCH_TRACER=y
> > CONFIG_TRACING=y
> > CONFIG_GENERIC_TRACER=y
> > CONFIG_TRACING_SUPPORT=y
> > CONFIG_FTRACE=y
> > # CONFIG_FUNCTION_TRACER is not set
> > # CONFIG_IRQSOFF_TRACER is not set
> > # CONFIG_SCHED_TRACER is not set
> > # CONFIG_HWLAT_TRACER is not set
> > # CONFIG_FTRACE_SYSCALLS is not set
> > # CONFIG_TRACER_SNAPSHOT is not set
> > CONFIG_BRANCH_PROFILE_NONE=y
> > # CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
> > # CONFIG_STACK_TRACER is not set
> > CONFIG_BLK_DEV_IO_TRACE=y
> > CONFIG_KPROBE_EVENTS=y
> > CONFIG_UPROBE_EVENTS=y
> > CONFIG_BPF_EVENTS=y
> > CONFIG_PROBE_EVENTS=y
> > # CONFIG_BPF_KPROBE_OVERRIDE is not set
> > # CONFIG_FTRACE_STARTUP_TEST is not set
> > # CONFIG_MMIOTRACE is not set
> > # CONFIG_HIST_TRIGGERS is not set
> > # CONFIG_TRACEPOINT_BENCHMARK is not set
> > # CONFIG_RING_BUFFER_BENCHMARK is not set
> > # CONFIG_RING_BUFFER_STARTUP_TEST is not set
> > # CONFIG_TRACE_EVAL_MAP_FILE is not set
> > CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
> > # CONFIG_DMA_API_DEBUG is not set
> > # CONFIG_RUNTIME_TESTING_MENU is not set
> > # CONFIG_MEMTEST is not set
> > CONFIG_BUG_ON_DATA_CORRUPTION=y
> > # CONFIG_SAMPLES is not set
> > CONFIG_HAVE_ARCH_KGDB=y
> > # CONFIG_KGDB is not set
> > CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
> > # CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
> > # CONFIG_UBSAN is not set
> > CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
> > # CONFIG_STRICT_DEVMEM is not set
> > CONFIG_EARLY_PRINTK_USB=y
> > CONFIG_X86_VERBOSE_BOOTUP=y
> > CONFIG_EARLY_PRINTK=y
> > CONFIG_EARLY_PRINTK_DBGP=y
> > # CONFIG_EARLY_PRINTK_EFI is not set
> > # CONFIG_EARLY_PRINTK_USB_XDBC is not set
> > # CONFIG_X86_PTDUMP_CORE is not set
> > # CONFIG_X86_PTDUMP is not set
> > # CONFIG_EFI_PGT_DUMP is not set
> > # CONFIG_DEBUG_WX is not set
> > CONFIG_DOUBLEFAULT=y
> > # CONFIG_DEBUG_TLBFLUSH is not set
> > CONFIG_HAVE_MMIOTRACE_SUPPORT=y
> > # CONFIG_X86_DECODER_SELFTEST is not set
> > CONFIG_IO_DELAY_TYPE_0X80=0
> > CONFIG_IO_DELAY_TYPE_0XED=1
> > CONFIG_IO_DELAY_TYPE_UDELAY=2
> > CONFIG_IO_DELAY_TYPE_NONE=3
> > CONFIG_IO_DELAY_0X80=y
> > # CONFIG_IO_DELAY_0XED is not set
> > # CONFIG_IO_DELAY_UDELAY is not set
> > # CONFIG_IO_DELAY_NONE is not set
> > CONFIG_DEFAULT_IO_DELAY_TYPE=0
> > CONFIG_DEBUG_BOOT_PARAMS=y
> > # CONFIG_CPA_DEBUG is not set
> > CONFIG_OPTIMIZE_INLINING=y
> > # CONFIG_DEBUG_ENTRY is not set
> > # CONFIG_DEBUG_NMI_SELFTEST is not set
> > CONFIG_X86_DEBUG_FPU=y
> > # CONFIG_PUNIT_ATOM_DEBUG is not set
> > # CONFIG_UNWINDER_ORC is not set
> > CONFIG_UNWINDER_FRAME_POINTER=y
> >
> > #
> > # Security options
> > #
> > CONFIG_KEYS=y
> > CONFIG_KEYS_COMPAT=y
> > CONFIG_PERSISTENT_KEYRINGS=y
> > CONFIG_BIG_KEYS=y
> > CONFIG_ENCRYPTED_KEYS=y
> > CONFIG_KEY_DH_OPERATIONS=y
> > # CONFIG_SECURITY_DMESG_RESTRICT is not set
> > CONFIG_SECURITY=y
> > CONFIG_SECURITY_WRITABLE_HOOKS=y
> > CONFIG_SECURITYFS=y
> > CONFIG_SECURITY_NETWORK=y
> > # CONFIG_PAGE_TABLE_ISOLATION is not set
> > CONFIG_SECURITY_INFINIBAND=y
> > CONFIG_SECURITY_NETWORK_XFRM=y
> > CONFIG_SECURITY_PATH=y
> > # CONFIG_INTEL_TXT is not set
> > CONFIG_LSM_MMAP_MIN_ADDR=65536
> > CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
> > CONFIG_HARDENED_USERCOPY=y
> > CONFIG_HARDENED_USERCOPY_FALLBACK=y
> > # CONFIG_HARDENED_USERCOPY_PAGESPAN is not set
> > CONFIG_FORTIFY_SOURCE=y
> > # CONFIG_STATIC_USERMODEHELPER is not set
> > CONFIG_SECURITY_SELINUX=y
> > CONFIG_SECURITY_SELINUX_BOOTPARAM=y
> > CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
> > CONFIG_SECURITY_SELINUX_DISABLE=y
> > CONFIG_SECURITY_SELINUX_DEVELOP=y
> > CONFIG_SECURITY_SELINUX_AVC_STATS=y
> > CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=0
> > # CONFIG_SECURITY_SMACK is not set
> > # CONFIG_SECURITY_TOMOYO is not set
> > CONFIG_SECURITY_APPARMOR=y
> > CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
> > CONFIG_SECURITY_APPARMOR_HASH=y
> > CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y
> > # CONFIG_SECURITY_APPARMOR_DEBUG is not set
> > # CONFIG_SECURITY_LOADPIN is not set
> > CONFIG_SECURITY_YAMA=y
> > CONFIG_INTEGRITY=y
> > # CONFIG_INTEGRITY_SIGNATURE is not set
> > CONFIG_INTEGRITY_AUDIT=y
> > # CONFIG_IMA is not set
> > # CONFIG_EVM is not set
> > CONFIG_DEFAULT_SECURITY_SELINUX=y
> > # CONFIG_DEFAULT_SECURITY_APPARMOR is not set
> > # CONFIG_DEFAULT_SECURITY_DAC is not set
> > CONFIG_DEFAULT_SECURITY="selinux"
> > CONFIG_CRYPTO=y
> >
> > #
> > # Crypto core or helper
> > #
> > CONFIG_CRYPTO_ALGAPI=y
> > CONFIG_CRYPTO_ALGAPI2=y
> > CONFIG_CRYPTO_AEAD=y
> > CONFIG_CRYPTO_AEAD2=y
> > CONFIG_CRYPTO_BLKCIPHER=y
> > CONFIG_CRYPTO_BLKCIPHER2=y
> > CONFIG_CRYPTO_HASH=y
> > CONFIG_CRYPTO_HASH2=y
> > CONFIG_CRYPTO_RNG=y
> > CONFIG_CRYPTO_RNG2=y
> > CONFIG_CRYPTO_RNG_DEFAULT=y
> > CONFIG_CRYPTO_AKCIPHER2=y
> > CONFIG_CRYPTO_AKCIPHER=y
> > CONFIG_CRYPTO_KPP2=y
> > CONFIG_CRYPTO_KPP=y
> > CONFIG_CRYPTO_ACOMP2=y
> > CONFIG_CRYPTO_RSA=y
> > CONFIG_CRYPTO_DH=y
> > CONFIG_CRYPTO_ECDH=y
> > CONFIG_CRYPTO_MANAGER=y
> > CONFIG_CRYPTO_MANAGER2=y
> > CONFIG_CRYPTO_USER=y
> > CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
> > CONFIG_CRYPTO_GF128MUL=y
> > CONFIG_CRYPTO_NULL=y
> > CONFIG_CRYPTO_NULL2=y
> > CONFIG_CRYPTO_PCRYPT=y
> > CONFIG_CRYPTO_WORKQUEUE=y
> > CONFIG_CRYPTO_CRYPTD=y
> > CONFIG_CRYPTO_MCRYPTD=y
> > CONFIG_CRYPTO_AUTHENC=y
> > # CONFIG_CRYPTO_TEST is not set
> > CONFIG_CRYPTO_ABLK_HELPER=y
> > CONFIG_CRYPTO_SIMD=y
> > CONFIG_CRYPTO_GLUE_HELPER_X86=y
> > CONFIG_CRYPTO_ENGINE=y
> >
> > #
> > # Authenticated Encryption with Associated Data
> > #
> > CONFIG_CRYPTO_CCM=y
> > CONFIG_CRYPTO_GCM=y
> > CONFIG_CRYPTO_CHACHA20POLY1305=y
> > CONFIG_CRYPTO_SEQIV=y
> > CONFIG_CRYPTO_ECHAINIV=y
> >
> > #
> > # Block modes
> > #
> > CONFIG_CRYPTO_CBC=y
> > CONFIG_CRYPTO_CTR=y
> > CONFIG_CRYPTO_CTS=y
> > CONFIG_CRYPTO_ECB=y
> > CONFIG_CRYPTO_LRW=y
> > CONFIG_CRYPTO_PCBC=y
> > CONFIG_CRYPTO_XTS=y
> > CONFIG_CRYPTO_KEYWRAP=y
> >
> > #
> > # Hash modes
> > #
> > CONFIG_CRYPTO_CMAC=y
> > CONFIG_CRYPTO_HMAC=y
> > CONFIG_CRYPTO_XCBC=y
> > CONFIG_CRYPTO_VMAC=y
> >
> > #
> > # Digest
> > #
> > CONFIG_CRYPTO_CRC32C=y
> > CONFIG_CRYPTO_CRC32C_INTEL=y
> > CONFIG_CRYPTO_CRC32=y
> > CONFIG_CRYPTO_CRC32_PCLMUL=y
> > CONFIG_CRYPTO_CRCT10DIF=y
> > CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
> > CONFIG_CRYPTO_GHASH=y
> > CONFIG_CRYPTO_POLY1305=y
> > CONFIG_CRYPTO_POLY1305_X86_64=y
> > CONFIG_CRYPTO_MD4=y
> > CONFIG_CRYPTO_MD5=y
> > CONFIG_CRYPTO_MICHAEL_MIC=y
> > CONFIG_CRYPTO_RMD128=y
> > CONFIG_CRYPTO_RMD160=y
> > CONFIG_CRYPTO_RMD256=y
> > CONFIG_CRYPTO_RMD320=y
> > CONFIG_CRYPTO_SHA1=y
> > CONFIG_CRYPTO_SHA1_SSSE3=y
> > CONFIG_CRYPTO_SHA256_SSSE3=y
> > CONFIG_CRYPTO_SHA512_SSSE3=y
> > CONFIG_CRYPTO_SHA1_MB=y
> > CONFIG_CRYPTO_SHA256_MB=y
> > CONFIG_CRYPTO_SHA512_MB=y
> > CONFIG_CRYPTO_SHA256=y
> > CONFIG_CRYPTO_SHA512=y
> > CONFIG_CRYPTO_SHA3=y
> > CONFIG_CRYPTO_SM3=y
> > CONFIG_CRYPTO_TGR192=y
> > CONFIG_CRYPTO_WP512=y
> > CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y
> >
> > #
> > # Ciphers
> > #
> > CONFIG_CRYPTO_AES=y
> > CONFIG_CRYPTO_AES_TI=y
> > CONFIG_CRYPTO_AES_X86_64=y
> > CONFIG_CRYPTO_AES_NI_INTEL=y
> > CONFIG_CRYPTO_ANUBIS=y
> > CONFIG_CRYPTO_ARC4=y
> > CONFIG_CRYPTO_BLOWFISH=y
> > CONFIG_CRYPTO_BLOWFISH_COMMON=y
> > CONFIG_CRYPTO_BLOWFISH_X86_64=y
> > CONFIG_CRYPTO_CAMELLIA=y
> > CONFIG_CRYPTO_CAMELLIA_X86_64=y
> > CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
> > CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
> > CONFIG_CRYPTO_CAST_COMMON=y
> > CONFIG_CRYPTO_CAST5=y
> > CONFIG_CRYPTO_CAST5_AVX_X86_64=y
> > CONFIG_CRYPTO_CAST6=y
> > CONFIG_CRYPTO_CAST6_AVX_X86_64=y
> > CONFIG_CRYPTO_DES=y
> > CONFIG_CRYPTO_DES3_EDE_X86_64=y
> > CONFIG_CRYPTO_FCRYPT=y
> > CONFIG_CRYPTO_KHAZAD=y
> > CONFIG_CRYPTO_SALSA20=y
> > CONFIG_CRYPTO_SALSA20_X86_64=y
> > CONFIG_CRYPTO_CHACHA20=y
> > CONFIG_CRYPTO_CHACHA20_X86_64=y
> > CONFIG_CRYPTO_SEED=y
> > CONFIG_CRYPTO_SERPENT=y
> > CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
> > CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
> > CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
> > CONFIG_CRYPTO_TEA=y
> > CONFIG_CRYPTO_TWOFISH=y
> > CONFIG_CRYPTO_TWOFISH_COMMON=y
> > CONFIG_CRYPTO_TWOFISH_X86_64=y
> > CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
> > CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y
> >
> > #
> > # Compression
> > #
> > CONFIG_CRYPTO_DEFLATE=y
> > CONFIG_CRYPTO_LZO=y
> > CONFIG_CRYPTO_842=y
> > CONFIG_CRYPTO_LZ4=y
> > CONFIG_CRYPTO_LZ4HC=y
> >
> > #
> > # Random Number Generation
> > #
> > CONFIG_CRYPTO_ANSI_CPRNG=y
> > CONFIG_CRYPTO_DRBG_MENU=y
> > CONFIG_CRYPTO_DRBG_HMAC=y
> > CONFIG_CRYPTO_DRBG_HASH=y
> > CONFIG_CRYPTO_DRBG_CTR=y
> > CONFIG_CRYPTO_DRBG=y
> > CONFIG_CRYPTO_JITTERENTROPY=y
> > CONFIG_CRYPTO_USER_API=y
> > CONFIG_CRYPTO_USER_API_HASH=y
> > CONFIG_CRYPTO_USER_API_SKCIPHER=y
> > CONFIG_CRYPTO_USER_API_RNG=y
> > CONFIG_CRYPTO_USER_API_AEAD=y
> > CONFIG_CRYPTO_HASH_INFO=y
> > CONFIG_CRYPTO_HW=y
> > CONFIG_CRYPTO_DEV_PADLOCK=y
> > CONFIG_CRYPTO_DEV_PADLOCK_AES=y
> > CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
> > # CONFIG_CRYPTO_DEV_FSL_CAAM_CRYPTO_API_DESC is not set
> > CONFIG_CRYPTO_DEV_CCP=y
> > CONFIG_CRYPTO_DEV_CCP_DD=y
> > # CONFIG_CRYPTO_DEV_SP_CCP is not set
> > # CONFIG_CRYPTO_DEV_SP_PSP is not set
> > CONFIG_CRYPTO_DEV_QAT=y
> > CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
> > CONFIG_CRYPTO_DEV_QAT_C3XXX=y
> > CONFIG_CRYPTO_DEV_QAT_C62X=y
> > CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=y
> > CONFIG_CRYPTO_DEV_QAT_C3XXXVF=y
> > CONFIG_CRYPTO_DEV_QAT_C62XVF=y
> > # CONFIG_CRYPTO_DEV_NITROX_CNN55XX is not set
> > CONFIG_CRYPTO_DEV_VIRTIO=y
> > CONFIG_ASYMMETRIC_KEY_TYPE=y
> > CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
> > CONFIG_X509_CERTIFICATE_PARSER=y
> > CONFIG_PKCS7_MESSAGE_PARSER=y
> > CONFIG_PKCS7_TEST_KEY=y
> > CONFIG_SIGNED_PE_FILE_VERIFICATION=y
> >
> > #
> > # Certificates for signature checking
> > #
> > CONFIG_SYSTEM_TRUSTED_KEYRING=y
> > CONFIG_SYSTEM_TRUSTED_KEYS=""
> > # CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
> > CONFIG_SECONDARY_TRUSTED_KEYRING=y
> > # CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
> > CONFIG_HAVE_KVM=y
> > CONFIG_HAVE_KVM_IRQCHIP=y
> > CONFIG_HAVE_KVM_IRQFD=y
> > CONFIG_HAVE_KVM_IRQ_ROUTING=y
> > CONFIG_HAVE_KVM_EVENTFD=y
> > CONFIG_KVM_MMIO=y
> > CONFIG_KVM_ASYNC_PF=y
> > CONFIG_HAVE_KVM_MSI=y
> > CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
> > CONFIG_KVM_VFIO=y
> > CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
> > CONFIG_KVM_COMPAT=y
> > CONFIG_HAVE_KVM_IRQ_BYPASS=y
> > CONFIG_VIRTUALIZATION=y
> > CONFIG_KVM=y
> > CONFIG_KVM_INTEL=y
> > CONFIG_KVM_AMD=y
> > # CONFIG_KVM_MMU_AUDIT is not set
> > CONFIG_VHOST_NET=y
> > CONFIG_VHOST_VSOCK=y
> > CONFIG_VHOST=y
> > CONFIG_VHOST_CROSS_ENDIAN_LEGACY=y
> > CONFIG_BINARY_PRINTF=y
> >
> > #
> > # Library routines
> > #
> > CONFIG_BITREVERSE=y
> > # CONFIG_HAVE_ARCH_BITREVERSE is not set
> > CONFIG_RATIONAL=y
> > CONFIG_GENERIC_STRNCPY_FROM_USER=y
> > CONFIG_GENERIC_STRNLEN_USER=y
> > CONFIG_GENERIC_NET_UTILS=y
> > CONFIG_GENERIC_FIND_FIRST_BIT=y
> > CONFIG_GENERIC_PCI_IOMAP=y
> > CONFIG_GENERIC_IOMAP=y
> > CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
> > CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
> > CONFIG_CRC_CCITT=y
> > CONFIG_CRC16=y
> > CONFIG_CRC_T10DIF=y
> > CONFIG_CRC_ITU_T=y
> > CONFIG_CRC32=y
> > # CONFIG_CRC32_SELFTEST is not set
> > CONFIG_CRC32_SLICEBY8=y
> > # CONFIG_CRC32_SLICEBY4 is not set
> > # CONFIG_CRC32_SARWATE is not set
> > # CONFIG_CRC32_BIT is not set
> > CONFIG_CRC4=y
> > # CONFIG_CRC7 is not set
> > CONFIG_LIBCRC32C=y
> > # CONFIG_CRC8 is not set
> > # CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
> > # CONFIG_RANDOM32_SELFTEST is not set
> > CONFIG_842_COMPRESS=y
> > CONFIG_842_DECOMPRESS=y
> > CONFIG_ZLIB_INFLATE=y
> > CONFIG_ZLIB_DEFLATE=y
> > CONFIG_LZO_COMPRESS=y
> > CONFIG_LZO_DECOMPRESS=y
> > CONFIG_LZ4_COMPRESS=y
> > CONFIG_LZ4HC_COMPRESS=y
> > CONFIG_LZ4_DECOMPRESS=y
> > CONFIG_XZ_DEC=y
> > CONFIG_XZ_DEC_X86=y
> > CONFIG_XZ_DEC_POWERPC=y
> > CONFIG_XZ_DEC_IA64=y
> > CONFIG_XZ_DEC_ARM=y
> > CONFIG_XZ_DEC_ARMTHUMB=y
> > CONFIG_XZ_DEC_SPARC=y
> > CONFIG_XZ_DEC_BCJ=y
> > # CONFIG_XZ_DEC_TEST is not set
> > CONFIG_DECOMPRESS_GZIP=y
> > CONFIG_DECOMPRESS_BZIP2=y
> > CONFIG_DECOMPRESS_LZMA=y
> > CONFIG_DECOMPRESS_XZ=y
> > CONFIG_DECOMPRESS_LZO=y
> > CONFIG_DECOMPRESS_LZ4=y
> > CONFIG_GENERIC_ALLOCATOR=y
> > CONFIG_TEXTSEARCH=y
> > CONFIG_TEXTSEARCH_KMP=y
> > CONFIG_TEXTSEARCH_BM=y
> > CONFIG_TEXTSEARCH_FSM=y
> > CONFIG_INTERVAL_TREE=y
> > CONFIG_RADIX_TREE_MULTIORDER=y
> > CONFIG_ASSOCIATIVE_ARRAY=y
> > CONFIG_HAS_IOMEM=y
> > CONFIG_HAS_IOPORT_MAP=y
> > CONFIG_HAS_DMA=y
> > CONFIG_SGL_ALLOC=y
> > # CONFIG_DMA_DIRECT_OPS is not set
> > CONFIG_DMA_VIRT_OPS=y
> > CONFIG_CHECK_SIGNATURE=y
> > CONFIG_CPU_RMAP=y
> > CONFIG_DQL=y
> > CONFIG_GLOB=y
> > # CONFIG_GLOB_SELFTEST is not set
> > CONFIG_NLATTR=y
> > CONFIG_CLZ_TAB=y
> > # CONFIG_CORDIC is not set
> > # CONFIG_DDR is not set
> > CONFIG_IRQ_POLL=y
> > CONFIG_MPILIB=y
> > CONFIG_OID_REGISTRY=y
> > CONFIG_UCS2_STRING=y
> > CONFIG_FONT_SUPPORT=y
> > # CONFIG_FONTS is not set
> > CONFIG_FONT_8x8=y
> > CONFIG_FONT_8x16=y
> > # CONFIG_SG_SPLIT is not set
> > CONFIG_SG_POOL=y
> > CONFIG_ARCH_HAS_SG_CHAIN=y
> > CONFIG_ARCH_HAS_PMEM_API=y
> > CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
> > CONFIG_STACKDEPOT=y
> > CONFIG_SBITMAP=y
> > # CONFIG_STRING_SELFTEST is not set
>
>
> --
> Michal Hocko
> SUSE Labs
>

--94eb2c07da3aeb84c40566491a3a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Joel- can you look into this one?<br><div class=3D"gmail_e=
xtra"><br><div class=3D"gmail_quote">On Tue, Feb 27, 2018 at 2:05 AM, Micha=
l Hocko <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@kernel.org" target=
=3D"_blank">mhocko@kernel.org</a>&gt;</span> wrote:<br><blockquote class=3D=
"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding=
-left:1ex">[Cc ashmem maintainers]<br>
<br>
this looks like an ashmem bug<br>
<br>
On Tue 27-02-18 01:59:01, syzbot wrote:<br>
&gt; Hello,<br>
&gt;<br>
&gt; syzbot hit the following crash on upstream commit<br>
&gt; c89be5242607d8aa08a6fa45a887c6<wbr>8b2d4a2a2c (Sun Feb 25 21:43:18 201=
8 +0000)<br>
&gt; Merge tag &#39;nfs-for-4.16-3&#39; of<br>
&gt; git://<a href=3D"http://git.linux-nfs.org/projects/trondmy/linux-nfs" =
rel=3D"noreferrer" target=3D"_blank">git.linux-nfs.org/<wbr>projects/trondm=
y/linux-nfs</a><br>
&gt;<br>
&gt; So far this crash happened 1820 times on upstream.<br>
&gt; C reproducer is attached.<br>
&gt; syzkaller reproducer is attached.<br>
&gt; Raw console output is attached.<br>
&gt; compiler: gcc (GCC) 7.1.1 20170620<br>
&gt; .config is attached.<br>
&gt;<br>
&gt; IMPORTANT: if you fix the bug, please add the following tag to the com=
mit:<br>
&gt; Reported-by: <a href=3D"mailto:syzbot%2Bd7a918a7a8e1c952bc36@syzkaller=
.appspotmail.com">syzbot+d7a918a7a8e1c952bc36@<wbr>syzkaller.appspotmail.co=
m</a><br>
&gt; It will help syzbot understand when the bug is fixed. See footer for<b=
r>
&gt; details.<br>
&gt; If you forward the report, please keep this part and the footer.<br>
&gt;<br>
&gt; audit: type=3D1400 audit(1519638766.030:7): avc:=C2=A0 denied=C2=A0 { =
map } for<br>
&gt; pid=3D4243 comm=3D&quot;syzkaller923784&quot; path=3D&quot;/root/<wbr>=
syzkaller923784171&quot; dev=3D&quot;sda1&quot;<br>
&gt; ino=3D16481 scontext=3Dunconfined_u:system_<wbr>r:insmod_t:s0-s0:c0.c1=
023<br>
&gt; tcontext=3Dunconfined_u:object_<wbr>r:user_home_t:s0 tclass=3Dfile per=
missive=3D1<br>
&gt;<br>
&gt; audit: type=3D1400 audit(1519638766.030:8): avc:=C2=A0 denied=C2=A0 { =
map } for<br>
&gt; pid=3D4243 comm=3D&quot;syzkaller923784&quot; path=3D&quot;/dev/ashmem=
&quot; dev=3D&quot;devtmpfs&quot; ino=3D9417<br>
&gt; scontext=3Dunconfined_u:system_<wbr>r:insmod_t:s0-s0:c0.c1023<br>
&gt; tcontext=3Dsystem_u:object_r:<wbr>device_t:s0 tclass=3Dchr_file permis=
sive=3D1<br>
&gt; =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; WARNING: possible circular locking dependency detected<br>
&gt; 4.16.0-rc2+ #329 Not tainted<br>
&gt; ------------------------------<wbr>------------------------<br>
&gt; syzkaller923784/4243 is trying to acquire lock:<br>
&gt;=C2=A0 (&amp;mm-&gt;mmap_sem){++++}, at: [&lt;0000000074c86253&gt;] __m=
ight_fault+0xe0/0x1d0<br>
&gt; mm/memory.c:4570<br>
&gt;<br>
&gt; but task is already holding lock:<br>
&gt;=C2=A0 (ashmem_mutex){+.+.}, at: [&lt;0000000024db7f7c&gt;] ashmem_pin_=
unpin<br>
&gt; drivers/staging/android/<wbr>ashmem.c:705 [inline]<br>
&gt;=C2=A0 (ashmem_mutex){+.+.}, at: [&lt;0000000024db7f7c&gt;] ashmem_ioct=
l+0x3db/0x11b0<br>
&gt; drivers/staging/android/<wbr>ashmem.c:782<br>
&gt;<br>
&gt; which lock already depends on the new lock.<br>
&gt;<br>
&gt;<br>
&gt; the existing dependency chain (in reverse order) is:<br>
&gt;<br>
&gt; -&gt; #1 (ashmem_mutex){+.+.}:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mutex_lock_common kernel/locking/mutex.c:=
756 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mutex_lock+0x16f/0x1a80 kernel/locking/mu=
tex.c:893<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock_nested+0x16/0x20 kernel/locking/=
mutex.c:908<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 ashmem_mmap+0x53/0x410 drivers/staging/andr=
oid/<wbr>ashmem.c:362<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 call_mmap include/linux/fs.h:1786 [inline]<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 mmap_region+0xa99/0x15a0 mm/mmap.c:1705<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_mmap+0x6c0/0xe00 mm/mmap.c:1483<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_mmap_pgoff include/linux/mm.h:2223 [inli=
ne]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 vm_mmap_pgoff+0x1de/0x280 mm/util.c:355<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SYSC_mmap_pgoff mm/mmap.c:1533 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_mmap_pgoff+0x462/0x5f0 mm/mmap.c:1491<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SYSC_mmap arch/x86/kernel/sys_x86_64.c:<wbr=
>100 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_mmap+0x16/0x20 arch/x86/kernel/sys_x86_=
64.c:<wbr>91<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_syscall_64+0x280/0x940 arch/x86/entry/co=
mmon.c:287<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 entry_SYSCALL_64_after_<wbr>hwframe+0x42/0x=
b7<br>
&gt;<br>
&gt; -&gt; #0 (&amp;mm-&gt;mmap_sem){++++}:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 lock_acquire+0x1d5/0x580 kernel/locking/loc=
kdep.c:3920<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 __might_fault+0x13a/0x1d0 mm/memory.c:4571<=
br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 _copy_from_user+0x2c/0x110 lib/usercopy.c:1=
0<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 copy_from_user include/linux/uaccess.h:147 =
[inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 ashmem_pin_unpin drivers/staging/android/<w=
br>ashmem.c:710 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 ashmem_ioctl+0x438/0x11b0 drivers/staging/a=
ndroid/<wbr>ashmem.c:782<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 vfs_ioctl fs/ioctl.c:46 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:686<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SYSC_ioctl fs/ioctl.c:701 [inline]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_syscall_64+0x280/0x940 arch/x86/entry/co=
mmon.c:287<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 entry_SYSCALL_64_after_<wbr>hwframe+0x42/0x=
b7<br>
&gt;<br>
&gt; other info that might help us debug this:<br>
&gt;<br>
&gt;=C2=A0 Possible unsafe locking scenario:<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU0=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU1<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 ----=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ----<br>
&gt;=C2=A0 =C2=A0lock(ashmem_mutex);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(&amp;mm-&gt;mmap_sem);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(ashmem_mutex);<br>
&gt;=C2=A0 =C2=A0lock(&amp;mm-&gt;mmap_sem);<br>
&gt;<br>
&gt;=C2=A0 *** DEADLOCK ***<br>
&gt;<br>
&gt; 1 lock held by syzkaller923784/4243:<br>
&gt;=C2=A0 #0:=C2=A0 (ashmem_mutex){+.+.}, at: [&lt;0000000024db7f7c&gt;] a=
shmem_pin_unpin<br>
&gt; drivers/staging/android/<wbr>ashmem.c:705 [inline]<br>
&gt;=C2=A0 #0:=C2=A0 (ashmem_mutex){+.+.}, at: [&lt;0000000024db7f7c&gt;]<b=
r>
&gt; ashmem_ioctl+0x3db/0x11b0 drivers/staging/android/<wbr>ashmem.c:782<br=
>
&gt;<br>
&gt; stack backtrace:<br>
&gt; CPU: 1 PID: 4243 Comm: syzkaller923784 Not tainted 4.16.0-rc2+ #329<br=
>
&gt; Hardware name: Google Google Compute Engine/Google Compute Engine, BIO=
S<br>
&gt; Google 01/01/2011<br>
&gt; Call Trace:<br>
&gt;=C2=A0 __dump_stack lib/dump_stack.c:17 [inline]<br>
&gt;=C2=A0 dump_stack+0x194/0x24d lib/dump_stack.c:53<br>
&gt;=C2=A0 print_circular_bug.isra.38+<wbr>0x2cd/0x2dc kernel/locking/lockd=
ep.c:1223<br>
&gt;=C2=A0 check_prev_add kernel/locking/lockdep.c:1863 [inline]<br>
&gt;=C2=A0 check_prevs_add kernel/locking/lockdep.c:1976 [inline]<br>
&gt;=C2=A0 validate_chain kernel/locking/lockdep.c:2417 [inline]<br>
&gt;=C2=A0 __lock_acquire+0x30a8/0x3e00 kernel/locking/lockdep.c:3431<br>
&gt;=C2=A0 lock_acquire+0x1d5/0x580 kernel/locking/lockdep.c:3920<br>
&gt;=C2=A0 __might_fault+0x13a/0x1d0 mm/memory.c:4571<br>
&gt;=C2=A0 _copy_from_user+0x2c/0x110 lib/usercopy.c:10<br>
&gt;=C2=A0 copy_from_user include/linux/uaccess.h:147 [inline]<br>
&gt;=C2=A0 ashmem_pin_unpin drivers/staging/android/<wbr>ashmem.c:710 [inli=
ne]<br>
&gt;=C2=A0 ashmem_ioctl+0x438/0x11b0 drivers/staging/android/<wbr>ashmem.c:=
782<br>
&gt;=C2=A0 vfs_ioctl fs/ioctl.c:46 [inline]<br>
&gt;=C2=A0 do_vfs_ioctl+0x1b1/0x1520 fs/ioctl.c:686<br>
&gt;=C2=A0 SYSC_ioctl fs/ioctl.c:701 [inline]<br>
&gt;=C2=A0 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:692<br>
&gt;=C2=A0 do_syscall_64+0x280/0x940 arch/x86/entry/common.c:287<br>
&gt;=C2=A0 entry_SYSCALL_64_after_<wbr>hwframe+0x42/0xb7<br>
&gt; RIP: 0033:0x43fd19<br>
&gt; RSP: 002b:00007ffe04d2fda8 EFLAGS: 00000217 ORIG_RAX: 0000000000000010=
<br>
&gt; RAX: ffffffffffffffda RBX: 00000000004002c8 RCX: 000000000043fd19<br>
&gt; RDX: 0000000000000000 RSI: 0000000000007709 RDI: 0000000000000003<br>
&gt; RBP: 000000<br>
&gt;<br>
&gt;<br>
&gt; ---<br>
&gt; This bug is generated by a dumb bot. It may contain errors.<br>
&gt; See <a href=3D"https://goo.gl/tpsmEJ" rel=3D"noreferrer" target=3D"_bl=
ank">https://goo.gl/tpsmEJ</a> for details.<br>
&gt; Direct all questions to <a href=3D"mailto:syzkaller@googlegroups.com">=
syzkaller@googlegroups.com</a>.<br>
&gt;<br>
&gt; syzbot will keep track of this bug report.<br>
&gt; If you forgot to add the Reported-by tag, once the fix for this bug is=
<br>
&gt; merged<br>
&gt; into any tree, please reply to this email with:<br>
&gt; #syz fix: exact-commit-title<br>
&gt; If you want to test a patch for this bug, please reply with:<br>
&gt; #syz test: git://repo/address.git branch<br>
&gt; and provide the patch inline or as an attachment.<br>
&gt; To mark this as a duplicate of another syzbot report, please reply wit=
h:<br>
&gt; #syz dup: exact-subject-of-another-<wbr>report<br>
&gt; If it&#39;s a one-off invalid bug report, please reply with:<br>
&gt; #syz invalid<br>
&gt; Note: if the crash happens again, it will cause creation of a new bug<=
br>
&gt; report.<br>
&gt; Note: all commands must start from beginning of the line in the email =
body.<br>
<br>
&gt; [....] Starting enhanced syslogd: rsyslogd[=C2=A0 =C2=A017.353603] aud=
it: type=3D1400 audit(1519638753.636:5): avc:=C2=A0 denied=C2=A0 { syslog }=
 for=C2=A0 pid=3D4089 comm=3D&quot;rsyslogd&quot; capability=3D34=C2=A0 sco=
ntext=3Dsystem_u:system_r:<wbr>kernel_t:s0 tcontext=3Dsystem_u:system_r:<wb=
r>kernel_t:s0 tclass=3Dcapability2 permissive=3D1<br>
&gt;=C2=A0 [?25l [?1c 7 [1G[ [32m ok=C2=A0 [39;49m 8 [?25h [?0c.<br>
&gt; [....] Starting periodic command scheduler: cron [?25l [?1c 7 [1G[ [32=
m ok=C2=A0 [39;49m 8 [?25h [?0c.<br>
&gt; Starting mcstransd:<br>
&gt; [....] Starting file context maintaining daemon: restorecond [?25l [?1=
c 7 [1G[ [32m ok=C2=A0 [39;49m 8 [?25h [?0c.<br>
&gt; [....] Starting OpenBSD Secure Shell server: sshd [?25l [?1c 7 [1G[ [3=
2m ok=C2=A0 [39;49m 8 [?25h [?0c.<br>
&gt;<br>
&gt; Debian GNU/Linux 7 syzkaller ttyS0<br>
&gt;<br>
&gt; syzkaller login: [=C2=A0 =C2=A023.429793] audit: type=3D1400 audit(151=
9638759.712:6): avc:=C2=A0 denied=C2=A0 { map } for=C2=A0 pid=3D4229 comm=
=3D&quot;bash&quot; path=3D&quot;/bin/bash&quot; dev=3D&quot;sda1&quot; ino=
=3D1457 scontext=3Dunconfined_u:system_<wbr>r:insmod_t:s0-s0:c0.c1023 tcont=
ext=3Dsystem_u:object_r:<wbr>file_t:s0 tclass=3Dfile permissive=3D1<br>
&gt; Warning: Permanently added &#39;10.128.0.58&#39; (ECDSA) to the list o=
f known hosts.<br>
&gt; executing program<br>
&gt; [=C2=A0 =C2=A029.747804] audit: type=3D1400 audit(1519638766.030:7): a=
vc:=C2=A0 denied=C2=A0 { map } for=C2=A0 pid=3D4243 comm=3D&quot;syzkaller9=
23784&quot; path=3D&quot;/root/<wbr>syzkaller923784171&quot; dev=3D&quot;sd=
a1&quot; ino=3D16481 scontext=3Dunconfined_u:system_<wbr>r:insmod_t:s0-s0:c=
0.c1023 tcontext=3Dunconfined_u:object_<wbr>r:user_home_t:s0 tclass=3Dfile =
permissive=3D1<br>
&gt; [=C2=A0 =C2=A029.750248]<br>
&gt; [=C2=A0 =C2=A029.773690] audit: type=3D1400 audit(1519638766.030:8): a=
vc:=C2=A0 denied=C2=A0 { map } for=C2=A0 pid=3D4243 comm=3D&quot;syzkaller9=
23784&quot; path=3D&quot;/dev/ashmem&quot; dev=3D&quot;devtmpfs&quot; ino=
=3D9417 scontext=3Dunconfined_u:system_<wbr>r:insmod_t:s0-s0:c0.c1023 tcont=
ext=3Dsystem_u:object_r:<wbr>device_t:s0 tclass=3Dchr_file permissive=3D1<b=
r>
&gt; [=C2=A0 =C2=A029.775275] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<wbr>=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
&gt; [=C2=A0 =C2=A029.775276] WARNING: possible circular locking dependency=
 detected<br>
&gt; [=C2=A0 =C2=A029.775280] 4.16.0-rc2+ #329 Not tainted<br>
&gt; [=C2=A0 =C2=A029.775281] ------------------------------<wbr>----------=
--------------<br>
&gt; [=C2=A0 =C2=A029.775283] syzkaller923784/4243 is trying to acquire loc=
k:<br>
&gt; [=C2=A0 =C2=A029.775284]=C2=A0 (&amp;mm-&gt;mmap_sem){++++}, at: [&lt;=
0000000074c86253&gt;] __might_fault+0xe0/0x1d0<br>
&gt; [=C2=A0 =C2=A029.775302]<br>
&gt; [=C2=A0 =C2=A029.775302] but task is already holding lock:<br>
&gt; [=C2=A0 =C2=A029.842391]=C2=A0 (ashmem_mutex){+.+.}, at: [&lt;00000000=
24db7f7c&gt;] ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A029.850331]<br>
&gt; [=C2=A0 =C2=A029.850331] which lock already depends on the new lock.<b=
r>
&gt; [=C2=A0 =C2=A029.850331]<br>
&gt; [=C2=A0 =C2=A029.858610]<br>
&gt; [=C2=A0 =C2=A029.858610] the existing dependency chain (in reverse ord=
er) is:<br>
&gt; [=C2=A0 =C2=A029.866195]<br>
&gt; [=C2=A0 =C2=A029.866195] -&gt; #1 (ashmem_mutex){+.+.}:<br>
&gt; [=C2=A0 =C2=A029.871618]=C2=A0 =C2=A0 =C2=A0 =C2=A0 __mutex_lock+0x16f=
/0x1a80<br>
&gt; [=C2=A0 =C2=A029.876003]=C2=A0 =C2=A0 =C2=A0 =C2=A0 mutex_lock_nested+=
0x16/0x20<br>
&gt; [=C2=A0 =C2=A029.880550]=C2=A0 =C2=A0 =C2=A0 =C2=A0 ashmem_mmap+0x53/0=
x410<br>
&gt; [=C2=A0 =C2=A029.884663]=C2=A0 =C2=A0 =C2=A0 =C2=A0 mmap_region+0xa99/=
0x15a0<br>
&gt; [=C2=A0 =C2=A029.888950]=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_mmap+0x6c0/0xe0=
0<br>
&gt; [=C2=A0 =C2=A029.892805]=C2=A0 =C2=A0 =C2=A0 =C2=A0 vm_mmap_pgoff+0x1d=
e/0x280<br>
&gt; [=C2=A0 =C2=A029.897183]=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_mmap_pgoff+0x4=
62/0x5f0<br>
&gt; [=C2=A0 =C2=A029.901647]=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_mmap+0x16/0x20=
<br>
&gt; [=C2=A0 =C2=A029.905416]=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_syscall_64+0x28=
0/0x940<br>
&gt; [=C2=A0 =C2=A029.909789]=C2=A0 =C2=A0 =C2=A0 =C2=A0 entry_SYSCALL_64_a=
fter_<wbr>hwframe+0x42/0xb7<br>
&gt; [=C2=A0 =C2=A029.915461]<br>
&gt; [=C2=A0 =C2=A029.915461] -&gt; #0 (&amp;mm-&gt;mmap_sem){++++}:<br>
&gt; [=C2=A0 =C2=A029.920974]=C2=A0 =C2=A0 =C2=A0 =C2=A0 lock_acquire+0x1d5=
/0x580<br>
&gt; [=C2=A0 =C2=A029.925263]=C2=A0 =C2=A0 =C2=A0 =C2=A0 __might_fault+0x13=
a/0x1d0<br>
&gt; [=C2=A0 =C2=A029.929638]=C2=A0 =C2=A0 =C2=A0 =C2=A0 _copy_from_user+0x=
2c/0x110<br>
&gt; [=C2=A0 =C2=A029.934101]=C2=A0 =C2=A0 =C2=A0 =C2=A0 ashmem_ioctl+0x438=
/0x11b0<br>
&gt; [=C2=A0 =C2=A029.938474]=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_vfs_ioctl+0x1b1=
/0x1520<br>
&gt; [=C2=A0 =C2=A029.942864]=C2=A0 =C2=A0 =C2=A0 =C2=A0 SyS_ioctl+0x8f/0xc=
0<br>
&gt; [=C2=A0 =C2=A029.946720]=C2=A0 =C2=A0 =C2=A0 =C2=A0 do_syscall_64+0x28=
0/0x940<br>
&gt; [=C2=A0 =C2=A029.951094]=C2=A0 =C2=A0 =C2=A0 =C2=A0 entry_SYSCALL_64_a=
fter_<wbr>hwframe+0x42/0xb7<br>
&gt; [=C2=A0 =C2=A029.956765]<br>
&gt; [=C2=A0 =C2=A029.956765] other info that might help us debug this:<br>
&gt; [=C2=A0 =C2=A029.956765]<br>
&gt; [=C2=A0 =C2=A029.964871]=C2=A0 Possible unsafe locking scenario:<br>
&gt; [=C2=A0 =C2=A029.964871]<br>
&gt; [=C2=A0 =C2=A029.970893]=C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU0=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU1<br>
&gt; [=C2=A0 =C2=A029.975526]=C2=A0 =C2=A0 =C2=A0 =C2=A0 ----=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ----<br>
&gt; [=C2=A0 =C2=A029.980157]=C2=A0 =C2=A0lock(ashmem_mutex);<br>
&gt; [=C2=A0 =C2=A029.983576]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(&am=
p;mm-&gt;mmap_sem);<br>
&gt; [=C2=A0 =C2=A029.989598]=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock(ash=
mem_mutex);<br>
&gt; [=C2=A0 =C2=A029.995535]=C2=A0 =C2=A0lock(&amp;mm-&gt;mmap_sem);<br>
&gt; [=C2=A0 =C2=A029.999051]<br>
&gt; [=C2=A0 =C2=A029.999051]=C2=A0 *** DEADLOCK ***<br>
&gt; [=C2=A0 =C2=A029.999051]<br>
&gt; [=C2=A0 =C2=A030.005079] 1 lock held by syzkaller923784/4243:<br>
&gt; [=C2=A0 =C2=A030.009799]=C2=A0 #0:=C2=A0 (ashmem_mutex){+.+.}, at: [&l=
t;0000000024db7f7c&gt;] ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A030.018176]<br>
&gt; [=C2=A0 =C2=A030.018176] stack backtrace:<br>
&gt; [=C2=A0 =C2=A030.022640] CPU: 1 PID: 4243 Comm: syzkaller923784 Not ta=
inted 4.16.0-rc2+ #329<br>
&gt; [=C2=A0 =C2=A030.030052] Hardware name: Google Google Compute Engine/G=
oogle Compute Engine, BIOS Google 01/01/2011<br>
&gt; [=C2=A0 =C2=A030.039371] Call Trace:<br>
&gt; [=C2=A0 =C2=A030.041927]=C2=A0 dump_stack+0x194/0x24d<br>
&gt; [=C2=A0 =C2=A030.045522]=C2=A0 ? arch_local_irq_restore+0x53/<wbr>0x53=
<br>
&gt; [=C2=A0 =C2=A030.050160]=C2=A0 print_circular_bug.isra.38+<wbr>0x2cd/0=
x2dc<br>
&gt; [=C2=A0 =C2=A030.055142]=C2=A0 ? save_trace+0xe0/0x2b0<br>
&gt; [=C2=A0 =C2=A030.058822]=C2=A0 __lock_acquire+0x30a8/0x3e00<br>
&gt; [=C2=A0 =C2=A030.062936]=C2=A0 ? ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A030.066966]=C2=A0 ? debug_check_no_locks_freed+<wbr>0x3c0=
/0x3c0<br>
&gt; [=C2=A0 =C2=A030.072132]=C2=A0 ? __might_sleep+0x95/0x190<br>
&gt; [=C2=A0 =C2=A030.076074]=C2=A0 ? ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A030.080102]=C2=A0 ? __mutex_lock+0x16f/0x1a80<br>
&gt; [=C2=A0 =C2=A030.084130]=C2=A0 ? ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A030.088160]=C2=A0 ? proc_nr_files+0x60/0x60<br>
&gt; [=C2=A0 =C2=A030.092015]=C2=A0 ? ashmem_ioctl+0x3db/0x11b0<br>
&gt; [=C2=A0 =C2=A030.096042]=C2=A0 ? find_held_lock+0x35/0x1d0<br>
&gt; [=C2=A0 =C2=A030.100071]=C2=A0 ? mutex_lock_io_nested+0x1900/<wbr>0x19=
00<br>
&gt; [=C2=A0 =C2=A030.104880]=C2=A0 ? lock_downgrade+0x980/0x980<br>
&gt; [=C2=A0 =C2=A030.108995]=C2=A0 ? __mutex_unlock_slowpath+0xe9/<wbr>0xa=
c0<br>
&gt; [=C2=A0 =C2=A030.113807]=C2=A0 ? find_held_lock+0x35/0x1d0<br>
&gt; [=C2=A0 =C2=A030.117834]=C2=A0 ? lock_downgrade+0x980/0x980<br>
&gt; [=C2=A0 =C2=A030.121949]=C2=A0 ? vma_set_page_prot+0x16b/0x230<br>
&gt; [=C2=A0 =C2=A030.126324]=C2=A0 lock_acquire+0x1d5/0x580<br>
&gt; [=C2=A0 =C2=A030.130094]=C2=A0 ? lock_acquire+0x1d5/0x580<br>
&gt; [=C2=A0 =C2=A030.134034]=C2=A0 ? __might_fault+0xe0/0x1d0<br>
&gt; [=C2=A0 =C2=A030.137976]=C2=A0 ? lock_release+0xa40/0xa40<br>
&gt; [=C2=A0 =C2=A030.141921]=C2=A0 ? trace_event_raw_event_sched_<wbr>swit=
ch+0x810/0x810<br>
&gt; [=C2=A0 =C2=A030.147774]=C2=A0 ? __might_sleep+0x95/0x190<br>
&gt; [=C2=A0 =C2=A030.151713]=C2=A0 __might_fault+0x13a/0x1d0<br>
&gt; [=C2=A0 =C2=A030.155566]=C2=A0 ? __might_fault+0xe0/0x1d0<br>
&gt; [=C2=A0 =C2=A030.159508]=C2=A0 _copy_from_user+0x2c/0x110<br>
&gt; [=C2=A0 =C2=A030.163447]=C2=A0 ashmem_ioctl+0x438/0x11b0<br>
&gt; [=C2=A0 =C2=A030.167302]=C2=A0 ? ashmem_release+0x190/0x190<br>
&gt; [=C2=A0 =C2=A030.171419]=C2=A0 ? trace_event_raw_event_sched_<wbr>swit=
ch+0x810/0x810<br>
&gt; [=C2=A0 =C2=A030.177272]=C2=A0 ? down_read_killable+0x180/0x180<br>
&gt; [=C2=A0 =C2=A030.181734]=C2=A0 ? rcu_note_context_switch+0x710/<wbr>0x=
710<br>
&gt; [=C2=A0 =C2=A030.186629]=C2=A0 ? ashmem_release+0x190/0x190<br>
&gt; [=C2=A0 =C2=A030.190742]=C2=A0 do_vfs_ioctl+0x1b1/0x1520<br>
&gt; [=C2=A0 =C2=A030.194597]=C2=A0 ? ioctl_preallocate+0x2b0/0x2b0<br>
&gt; [=C2=A0 =C2=A030.198975]=C2=A0 ? selinux_capable+0x40/0x40<br>
&gt; [=C2=A0 =C2=A030.203004]=C2=A0 ? putname+0xf3/0x130<br>
&gt; [=C2=A0 =C2=A030.206422]=C2=A0 ? fput+0xd2/0x140<br>
&gt; [=C2=A0 =C2=A030.209583]=C2=A0 ? SyS_mmap_pgoff+0x243/0x5f0<br>
&gt; [=C2=A0 =C2=A030.213700]=C2=A0 ? security_file_ioctl+0x7d/0xb0<br>
&gt; [=C2=A0 =C2=A030.218072]=C2=A0 ? security_file_ioctl+0x89/0xb0<br>
&gt; [=C2=A0 =C2=A030.222448]=C2=A0 SyS_ioctl+0x8f/0xc0<br>
&gt; [=C2=A0 =C2=A030.225781]=C2=A0 ? do_vfs_ioctl+0x1520/0x1520<br>
&gt; [=C2=A0 =C2=A030.229896]=C2=A0 do_syscall_64+0x280/0x940<br>
&gt; [=C2=A0 =C2=A030.233749]=C2=A0 ? __do_page_fault+0xc90/0xc90<br>
&gt; [=C2=A0 =C2=A030.237948]=C2=A0 ? trace_hardirqs_on_thunk+0x1a/<wbr>0x1=
c<br>
&gt; [=C2=A0 =C2=A030.242671]=C2=A0 ? syscall_return_slowpath+0x550/<wbr>0x=
550<br>
&gt; [=C2=A0 =C2=A030.247567]=C2=A0 ? syscall_return_slowpath+0x2ac/<wbr>0x=
550<br>
&gt; [=C2=A0 =C2=A030.252464]=C2=A0 ? prepare_exit_to_usermode+<wbr>0x350/0=
x350<br>
&gt; [=C2=A0 =C2=A030.257449]=C2=A0 ? entry_SYSCALL_64_after_<wbr>hwframe+0=
x52/0xb7<br>
&gt; [=C2=A0 =C2=A030.262779]=C2=A0 ? trace_hardirqs_off_thunk+0x1a/<wbr>0x=
1c<br>
&gt; [=C2=A0 =C2=A030.267590]=C2=A0 entry_SYSCALL_64_after_<wbr>hwframe+0x4=
2/0xb7<br>
&gt; [=C2=A0 =C2=A030.272743] RIP: 0033:0x43fd19<br>
&gt; [=C2=A0 =C2=A030.275903] RSP: 002b:00007ffe04d2fda8 EFLAGS: 00000217 O=
RIG_RAX: 0000000000000010<br>
&gt; [=C2=A0 =C2=A030.283575] RAX: ffffffffffffffda RBX: 00000000004002c8 R=
CX: 000000000043fd19<br>
&gt; [=C2=A0 =C2=A030.290809] RDX: 0000000000000000 RSI: 0000000000007709 R=
DI: 0000000000000003<br>
&gt; [=C2=A0 =C2=A030.298046] RBP: 000000<br>
<br>
&gt; # See <a href=3D"https://goo.gl/kgGztJ" rel=3D"noreferrer" target=3D"_=
blank">https://goo.gl/kgGztJ</a> for information about syzkaller reproducer=
s.<br>
&gt; #{Threaded:false Collide:false Repeat:false Procs:1 Sandbox: Fault:fal=
se FaultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:false HandleSegv:false=
 WaitRepeat:false Debug:false Repro:false}<br>
&gt; r0 =3D openat$ashmem(<wbr>0xffffffffffffff9c, &amp;(0x7f000059aff4)=3D=
&#39;/dev/<wbr>ashmem\x00&#39;, 0x0, 0x0)<br>
&gt; ioctl$ASHMEM_SET_SIZE(r0, 0x40087703, 0x2a)<br>
&gt; mmap(&amp;(0x7f00003f5000/0x2000)=3D<wbr>nil, 0x2000, 0x0, 0x1011, r0,=
 0x0)<br>
&gt; ioctl$ASHMEM_GET_PIN_STATUS(<wbr>r0, 0x7709, 0x0)<br>
<br>
&gt; // autogenerated by syzkaller (<a href=3D"http://github.com/google/syz=
kaller" rel=3D"noreferrer" target=3D"_blank">http://github.com/google/<wbr>=
syzkaller</a>)<br>
&gt;<br>
&gt; #define _GNU_SOURCE<br>
&gt; #include &lt;endian.h&gt;<br>
&gt; #include &lt;stdint.h&gt;<br>
&gt; #include &lt;string.h&gt;<br>
&gt; #include &lt;sys/syscall.h&gt;<br>
&gt; #include &lt;unistd.h&gt;<br>
&gt;<br>
&gt; long r[1];<br>
&gt; void loop()<br>
&gt; {<br>
&gt;=C2=A0 =C2=A0memset(r, -1, sizeof(r));<br>
&gt;=C2=A0 =C2=A0memcpy((void*)0x2059aff4, &quot;/dev/ashmem&quot;, 12);<br=
>
&gt;=C2=A0 =C2=A0r[0] =3D syscall(__NR_openat, 0xffffffffffffff9c, 0x2059af=
f4, 0, 0);<br>
&gt;=C2=A0 =C2=A0syscall(__NR_ioctl, r[0], 0x40087703, 0x2a);<br>
&gt;=C2=A0 =C2=A0syscall(__NR_mmap, 0x203f5000, 0x2000, 0, 0x1011, r[0], 0)=
;<br>
&gt;=C2=A0 =C2=A0syscall(__NR_ioctl, r[0], 0x7709, 0);<br>
&gt; }<br>
&gt;<br>
&gt; int main()<br>
&gt; {<br>
&gt;=C2=A0 =C2=A0syscall(__NR_mmap, 0x20000000, 0x1000000, 3, 0x32, -1, 0);=
<br>
&gt;=C2=A0 =C2=A0loop();<br>
&gt;=C2=A0 =C2=A0return 0;<br>
&gt; }<br>
<br>
&gt; #<br>
&gt; # Automatically generated file; DO NOT EDIT.<br>
&gt; # Linux/x86 4.16.0-rc2 Kernel Configuration<br>
&gt; #<br>
&gt; CONFIG_64BIT=3Dy<br>
&gt; CONFIG_X86_64=3Dy<br>
&gt; CONFIG_X86=3Dy<br>
&gt; CONFIG_INSTRUCTION_DECODER=3Dy<br>
&gt; CONFIG_OUTPUT_FORMAT=3D&quot;elf64-<wbr>x86-64&quot;<br>
&gt; CONFIG_ARCH_DEFCONFIG=3D&quot;arch/<wbr>x86/configs/x86_64_defconfig&q=
uot;<br>
&gt; CONFIG_LOCKDEP_SUPPORT=3Dy<br>
&gt; CONFIG_STACKTRACE_SUPPORT=3Dy<br>
&gt; CONFIG_MMU=3Dy<br>
&gt; CONFIG_ARCH_MMAP_RND_BITS_MIN=3D<wbr>28<br>
&gt; CONFIG_ARCH_MMAP_RND_BITS_MAX=3D<wbr>32<br>
&gt; CONFIG_ARCH_MMAP_RND_COMPAT_<wbr>BITS_MIN=3D8<br>
&gt; CONFIG_ARCH_MMAP_RND_COMPAT_<wbr>BITS_MAX=3D16<br>
&gt; CONFIG_NEED_DMA_MAP_STATE=3Dy<br>
&gt; CONFIG_NEED_SG_DMA_LENGTH=3Dy<br>
&gt; CONFIG_GENERIC_ISA_DMA=3Dy<br>
&gt; CONFIG_GENERIC_BUG=3Dy<br>
&gt; CONFIG_GENERIC_BUG_RELATIVE_<wbr>POINTERS=3Dy<br>
&gt; CONFIG_GENERIC_HWEIGHT=3Dy<br>
&gt; CONFIG_ARCH_MAY_HAVE_PC_FDC=3Dy<br>
&gt; CONFIG_RWSEM_XCHGADD_<wbr>ALGORITHM=3Dy<br>
&gt; CONFIG_GENERIC_CALIBRATE_<wbr>DELAY=3Dy<br>
&gt; CONFIG_ARCH_HAS_CPU_RELAX=3Dy<br>
&gt; CONFIG_ARCH_HAS_CACHE_LINE_<wbr>SIZE=3Dy<br>
&gt; CONFIG_HAVE_SETUP_PER_CPU_<wbr>AREA=3Dy<br>
&gt; CONFIG_NEED_PER_CPU_EMBED_<wbr>FIRST_CHUNK=3Dy<br>
&gt; CONFIG_NEED_PER_CPU_PAGE_<wbr>FIRST_CHUNK=3Dy<br>
&gt; CONFIG_ARCH_HIBERNATION_<wbr>POSSIBLE=3Dy<br>
&gt; CONFIG_ARCH_SUSPEND_POSSIBLE=3Dy<br>
&gt; CONFIG_ARCH_WANT_HUGE_PMD_<wbr>SHARE=3Dy<br>
&gt; CONFIG_ARCH_WANT_GENERAL_<wbr>HUGETLB=3Dy<br>
&gt; CONFIG_ZONE_DMA32=3Dy<br>
&gt; CONFIG_AUDIT_ARCH=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_<wbr>OPTIMIZED_INLINING=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_DEBUG_<wbr>PAGEALLOC=3Dy<br>
&gt; CONFIG_KASAN_SHADOW_OFFSET=3D<wbr>0xdffffc0000000000<br>
&gt; CONFIG_HAVE_INTEL_TXT=3Dy<br>
&gt; CONFIG_X86_64_SMP=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_UPROBES=3Dy<br>
&gt; CONFIG_FIX_EARLYCON_MEM=3Dy<br>
&gt; CONFIG_PGTABLE_LEVELS=3D4<br>
&gt; CONFIG_DEFCONFIG_LIST=3D&quot;/lib/<wbr>modules/$UNAME_RELEASE/.<wbr>c=
onfig&quot;<br>
&gt; CONFIG_CONSTRUCTORS=3Dy<br>
&gt; CONFIG_IRQ_WORK=3Dy<br>
&gt; CONFIG_BUILDTIME_EXTABLE_SORT=3D<wbr>y<br>
&gt; CONFIG_THREAD_INFO_IN_TASK=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # General setup<br>
&gt; #<br>
&gt; CONFIG_INIT_ENV_ARG_LIMIT=3D32<br>
&gt; CONFIG_CROSS_COMPILE=3D&quot;&quot;<br>
&gt; # CONFIG_COMPILE_TEST is not set<br>
&gt; CONFIG_LOCALVERSION=3D&quot;&quot;<br>
&gt; # CONFIG_LOCALVERSION_AUTO is not set<br>
&gt; CONFIG_HAVE_KERNEL_GZIP=3Dy<br>
&gt; CONFIG_HAVE_KERNEL_BZIP2=3Dy<br>
&gt; CONFIG_HAVE_KERNEL_LZMA=3Dy<br>
&gt; CONFIG_HAVE_KERNEL_XZ=3Dy<br>
&gt; CONFIG_HAVE_KERNEL_LZO=3Dy<br>
&gt; CONFIG_HAVE_KERNEL_LZ4=3Dy<br>
&gt; CONFIG_KERNEL_GZIP=3Dy<br>
&gt; # CONFIG_KERNEL_BZIP2 is not set<br>
&gt; # CONFIG_KERNEL_LZMA is not set<br>
&gt; # CONFIG_KERNEL_XZ is not set<br>
&gt; # CONFIG_KERNEL_LZO is not set<br>
&gt; # CONFIG_KERNEL_LZ4 is not set<br>
&gt; CONFIG_DEFAULT_HOSTNAME=3D&quot;(<wbr>none)&quot;<br>
&gt; CONFIG_SWAP=3Dy<br>
&gt; CONFIG_SYSVIPC=3Dy<br>
&gt; CONFIG_SYSVIPC_SYSCTL=3Dy<br>
&gt; CONFIG_POSIX_MQUEUE=3Dy<br>
&gt; CONFIG_POSIX_MQUEUE_SYSCTL=3Dy<br>
&gt; CONFIG_CROSS_MEMORY_ATTACH=3Dy<br>
&gt; CONFIG_USELIB=3Dy<br>
&gt; CONFIG_AUDIT=3Dy<br>
&gt; CONFIG_HAVE_ARCH_AUDITSYSCALL=3D<wbr>y<br>
&gt; CONFIG_AUDITSYSCALL=3Dy<br>
&gt; CONFIG_AUDIT_WATCH=3Dy<br>
&gt; CONFIG_AUDIT_TREE=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # IRQ subsystem<br>
&gt; #<br>
&gt; CONFIG_GENERIC_IRQ_PROBE=3Dy<br>
&gt; CONFIG_GENERIC_IRQ_SHOW=3Dy<br>
&gt; CONFIG_GENERIC_IRQ_EFFECTIVE_<wbr>AFF_MASK=3Dy<br>
&gt; CONFIG_GENERIC_PENDING_IRQ=3Dy<br>
&gt; CONFIG_GENERIC_IRQ_MIGRATION=3Dy<br>
&gt; CONFIG_IRQ_DOMAIN=3Dy<br>
&gt; CONFIG_IRQ_DOMAIN_HIERARCHY=3Dy<br>
&gt; CONFIG_GENERIC_MSI_IRQ=3Dy<br>
&gt; CONFIG_GENERIC_MSI_IRQ_DOMAIN=3D<wbr>y<br>
&gt; CONFIG_GENERIC_IRQ_MATRIX_<wbr>ALLOCATOR=3Dy<br>
&gt; CONFIG_GENERIC_IRQ_<wbr>RESERVATION_MODE=3Dy<br>
&gt; CONFIG_IRQ_FORCED_THREADING=3Dy<br>
&gt; CONFIG_SPARSE_IRQ=3Dy<br>
&gt; # CONFIG_GENERIC_IRQ_DEBUGFS is not set<br>
&gt; CONFIG_CLOCKSOURCE_WATCHDOG=3Dy<br>
&gt; CONFIG_ARCH_CLOCKSOURCE_DATA=3Dy<br>
&gt; CONFIG_CLOCKSOURCE_VALIDATE_<wbr>LAST_CYCLE=3Dy<br>
&gt; CONFIG_GENERIC_TIME_VSYSCALL=3Dy<br>
&gt; CONFIG_GENERIC_CLOCKEVENTS=3Dy<br>
&gt; CONFIG_GENERIC_CLOCKEVENTS_<wbr>BROADCAST=3Dy<br>
&gt; CONFIG_GENERIC_CLOCKEVENTS_<wbr>MIN_ADJUST=3Dy<br>
&gt; CONFIG_GENERIC_CMOS_UPDATE=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Timers subsystem<br>
&gt; #<br>
&gt; CONFIG_TICK_ONESHOT=3Dy<br>
&gt; CONFIG_NO_HZ_COMMON=3Dy<br>
&gt; # CONFIG_HZ_PERIODIC is not set<br>
&gt; CONFIG_NO_HZ_IDLE=3Dy<br>
&gt; # CONFIG_NO_HZ_FULL is not set<br>
&gt; CONFIG_NO_HZ=3Dy<br>
&gt; CONFIG_HIGH_RES_TIMERS=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # CPU/Task time and stats accounting<br>
&gt; #<br>
&gt; CONFIG_TICK_CPU_ACCOUNTING=3Dy<br>
&gt; # CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set<br>
&gt; # CONFIG_IRQ_TIME_ACCOUNTING is not set<br>
&gt; CONFIG_BSD_PROCESS_ACCT=3Dy<br>
&gt; # CONFIG_BSD_PROCESS_ACCT_V3 is not set<br>
&gt; CONFIG_TASKSTATS=3Dy<br>
&gt; CONFIG_TASK_DELAY_ACCT=3Dy<br>
&gt; CONFIG_TASK_XACCT=3Dy<br>
&gt; CONFIG_TASK_IO_ACCOUNTING=3Dy<br>
&gt; # CONFIG_CPU_ISOLATION is not set<br>
&gt;<br>
&gt; #<br>
&gt; # RCU Subsystem<br>
&gt; #<br>
&gt; CONFIG_TREE_RCU=3Dy<br>
&gt; # CONFIG_RCU_EXPERT is not set<br>
&gt; CONFIG_SRCU=3Dy<br>
&gt; CONFIG_TREE_SRCU=3Dy<br>
&gt; # CONFIG_TASKS_RCU is not set<br>
&gt; CONFIG_RCU_STALL_COMMON=3Dy<br>
&gt; CONFIG_RCU_NEED_SEGCBLIST=3Dy<br>
&gt; # CONFIG_BUILD_BIN2C is not set<br>
&gt; # CONFIG_IKCONFIG is not set<br>
&gt; CONFIG_LOG_BUF_SHIFT=3D18<br>
&gt; CONFIG_LOG_CPU_MAX_BUF_SHIFT=3D<wbr>12<br>
&gt; CONFIG_PRINTK_SAFE_LOG_BUF_<wbr>SHIFT=3D13<br>
&gt; CONFIG_HAVE_UNSTABLE_SCHED_<wbr>CLOCK=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_NUMA_<wbr>BALANCING=3Dy<br>
&gt; CONFIG_ARCH_WANT_BATCHED_<wbr>UNMAP_TLB_FLUSH=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_INT128=3Dy<br>
&gt; CONFIG_NUMA_BALANCING=3Dy<br>
&gt; CONFIG_NUMA_BALANCING_DEFAULT_<wbr>ENABLED=3Dy<br>
&gt; CONFIG_CGROUPS=3Dy<br>
&gt; CONFIG_PAGE_COUNTER=3Dy<br>
&gt; CONFIG_MEMCG=3Dy<br>
&gt; CONFIG_MEMCG_SWAP=3Dy<br>
&gt; CONFIG_MEMCG_SWAP_ENABLED=3Dy<br>
&gt; CONFIG_BLK_CGROUP=3Dy<br>
&gt; # CONFIG_DEBUG_BLK_CGROUP is not set<br>
&gt; CONFIG_CGROUP_WRITEBACK=3Dy<br>
&gt; CONFIG_CGROUP_SCHED=3Dy<br>
&gt; CONFIG_FAIR_GROUP_SCHED=3Dy<br>
&gt; # CONFIG_CFS_BANDWIDTH is not set<br>
&gt; # CONFIG_RT_GROUP_SCHED is not set<br>
&gt; CONFIG_CGROUP_PIDS=3Dy<br>
&gt; CONFIG_CGROUP_RDMA=3Dy<br>
&gt; CONFIG_CGROUP_FREEZER=3Dy<br>
&gt; CONFIG_CGROUP_HUGETLB=3Dy<br>
&gt; CONFIG_CPUSETS=3Dy<br>
&gt; CONFIG_PROC_PID_CPUSET=3Dy<br>
&gt; CONFIG_CGROUP_DEVICE=3Dy<br>
&gt; CONFIG_CGROUP_CPUACCT=3Dy<br>
&gt; CONFIG_CGROUP_PERF=3Dy<br>
&gt; CONFIG_CGROUP_BPF=3Dy<br>
&gt; # CONFIG_CGROUP_DEBUG is not set<br>
&gt; CONFIG_SOCK_CGROUP_DATA=3Dy<br>
&gt; CONFIG_NAMESPACES=3Dy<br>
&gt; CONFIG_UTS_NS=3Dy<br>
&gt; CONFIG_IPC_NS=3Dy<br>
&gt; CONFIG_USER_NS=3Dy<br>
&gt; CONFIG_PID_NS=3Dy<br>
&gt; CONFIG_NET_NS=3Dy<br>
&gt; # CONFIG_SCHED_AUTOGROUP is not set<br>
&gt; # CONFIG_SYSFS_DEPRECATED is not set<br>
&gt; CONFIG_RELAY=3Dy<br>
&gt; CONFIG_BLK_DEV_INITRD=3Dy<br>
&gt; CONFIG_INITRAMFS_SOURCE=3D&quot;&quot;<br>
&gt; CONFIG_RD_GZIP=3Dy<br>
&gt; CONFIG_RD_BZIP2=3Dy<br>
&gt; CONFIG_RD_LZMA=3Dy<br>
&gt; CONFIG_RD_XZ=3Dy<br>
&gt; CONFIG_RD_LZO=3Dy<br>
&gt; CONFIG_RD_LZ4=3Dy<br>
&gt; CONFIG_CC_OPTIMIZE_FOR_<wbr>PERFORMANCE=3Dy<br>
&gt; # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set<br>
&gt; CONFIG_SYSCTL=3Dy<br>
&gt; CONFIG_ANON_INODES=3Dy<br>
&gt; CONFIG_HAVE_UID16=3Dy<br>
&gt; CONFIG_SYSCTL_EXCEPTION_TRACE=3D<wbr>y<br>
&gt; CONFIG_HAVE_PCSPKR_PLATFORM=3Dy<br>
&gt; CONFIG_BPF=3Dy<br>
&gt; CONFIG_EXPERT=3Dy<br>
&gt; CONFIG_UID16=3Dy<br>
&gt; CONFIG_MULTIUSER=3Dy<br>
&gt; CONFIG_SGETMASK_SYSCALL=3Dy<br>
&gt; CONFIG_SYSFS_SYSCALL=3Dy<br>
&gt; CONFIG_SYSCTL_SYSCALL=3Dy<br>
&gt; CONFIG_FHANDLE=3Dy<br>
&gt; CONFIG_POSIX_TIMERS=3Dy<br>
&gt; CONFIG_PRINTK=3Dy<br>
&gt; CONFIG_PRINTK_NMI=3Dy<br>
&gt; CONFIG_BUG=3Dy<br>
&gt; CONFIG_ELF_CORE=3Dy<br>
&gt; CONFIG_PCSPKR_PLATFORM=3Dy<br>
&gt; CONFIG_BASE_FULL=3Dy<br>
&gt; CONFIG_FUTEX=3Dy<br>
&gt; CONFIG_FUTEX_PI=3Dy<br>
&gt; CONFIG_EPOLL=3Dy<br>
&gt; CONFIG_SIGNALFD=3Dy<br>
&gt; CONFIG_TIMERFD=3Dy<br>
&gt; CONFIG_EVENTFD=3Dy<br>
&gt; CONFIG_SHMEM=3Dy<br>
&gt; CONFIG_AIO=3Dy<br>
&gt; CONFIG_ADVISE_SYSCALLS=3Dy<br>
&gt; CONFIG_MEMBARRIER=3Dy<br>
&gt; CONFIG_CHECKPOINT_RESTORE=3Dy<br>
&gt; CONFIG_KALLSYMS=3Dy<br>
&gt; CONFIG_KALLSYMS_ALL=3Dy<br>
&gt; CONFIG_KALLSYMS_ABSOLUTE_<wbr>PERCPU=3Dy<br>
&gt; CONFIG_KALLSYMS_BASE_RELATIVE=3D<wbr>y<br>
&gt; CONFIG_BPF_SYSCALL=3Dy<br>
&gt; # CONFIG_BPF_JIT_ALWAYS_ON is not set<br>
&gt; CONFIG_USERFAULTFD=3Dy<br>
&gt; CONFIG_ARCH_HAS_MEMBARRIER_<wbr>SYNC_CORE=3Dy<br>
&gt; # CONFIG_EMBEDDED is not set<br>
&gt; CONFIG_HAVE_PERF_EVENTS=3Dy<br>
&gt; # CONFIG_PC104 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Kernel Performance Events And Counters<br>
&gt; #<br>
&gt; CONFIG_PERF_EVENTS=3Dy<br>
&gt; # CONFIG_DEBUG_PERF_USE_VMALLOC is not set<br>
&gt; CONFIG_VM_EVENT_COUNTERS=3Dy<br>
&gt; # CONFIG_COMPAT_BRK is not set<br>
&gt; CONFIG_SLAB=3Dy<br>
&gt; # CONFIG_SLUB is not set<br>
&gt; # CONFIG_SLOB is not set<br>
&gt; CONFIG_SLAB_MERGE_DEFAULT=3Dy<br>
&gt; # CONFIG_SLAB_FREELIST_RANDOM is not set<br>
&gt; CONFIG_SYSTEM_DATA_<wbr>VERIFICATION=3Dy<br>
&gt; CONFIG_PROFILING=3Dy<br>
&gt; CONFIG_TRACEPOINTS=3Dy<br>
&gt; CONFIG_CRASH_CORE=3Dy<br>
&gt; CONFIG_KEXEC_CORE=3Dy<br>
&gt; # CONFIG_OPROFILE is not set<br>
&gt; CONFIG_HAVE_OPROFILE=3Dy<br>
&gt; CONFIG_OPROFILE_NMI_TIMER=3Dy<br>
&gt; CONFIG_KPROBES=3Dy<br>
&gt; CONFIG_JUMP_LABEL=3Dy<br>
&gt; # CONFIG_STATIC_KEYS_SELFTEST is not set<br>
&gt; CONFIG_OPTPROBES=3Dy<br>
&gt; CONFIG_UPROBES=3Dy<br>
&gt; # CONFIG_HAVE_64BIT_ALIGNED_<wbr>ACCESS is not set<br>
&gt; CONFIG_HAVE_EFFICIENT_<wbr>UNALIGNED_ACCESS=3Dy<br>
&gt; CONFIG_ARCH_USE_BUILTIN_BSWAP=3D<wbr>y<br>
&gt; CONFIG_KRETPROBES=3Dy<br>
&gt; CONFIG_USER_RETURN_NOTIFIER=3Dy<br>
&gt; CONFIG_HAVE_IOREMAP_PROT=3Dy<br>
&gt; CONFIG_HAVE_KPROBES=3Dy<br>
&gt; CONFIG_HAVE_KRETPROBES=3Dy<br>
&gt; CONFIG_HAVE_OPTPROBES=3Dy<br>
&gt; CONFIG_HAVE_KPROBES_ON_FTRACE=3D<wbr>y<br>
&gt; CONFIG_HAVE_FUNCTION_ERROR_<wbr>INJECTION=3Dy<br>
&gt; CONFIG_HAVE_NMI=3Dy<br>
&gt; CONFIG_HAVE_ARCH_TRACEHOOK=3Dy<br>
&gt; CONFIG_HAVE_DMA_CONTIGUOUS=3Dy<br>
&gt; CONFIG_GENERIC_SMP_IDLE_<wbr>THREAD=3Dy<br>
&gt; CONFIG_ARCH_HAS_FORTIFY_<wbr>SOURCE=3Dy<br>
&gt; CONFIG_ARCH_HAS_SET_MEMORY=3Dy<br>
&gt; CONFIG_HAVE_ARCH_THREAD_<wbr>STRUCT_WHITELIST=3Dy<br>
&gt; CONFIG_ARCH_WANTS_DYNAMIC_<wbr>TASK_STRUCT=3Dy<br>
&gt; CONFIG_HAVE_REGS_AND_STACK_<wbr>ACCESS_API=3Dy<br>
&gt; CONFIG_HAVE_CLK=3Dy<br>
&gt; CONFIG_HAVE_DMA_API_DEBUG=3Dy<br>
&gt; CONFIG_HAVE_HW_BREAKPOINT=3Dy<br>
&gt; CONFIG_HAVE_MIXED_BREAKPOINTS_<wbr>REGS=3Dy<br>
&gt; CONFIG_HAVE_USER_RETURN_<wbr>NOTIFIER=3Dy<br>
&gt; CONFIG_HAVE_PERF_EVENTS_NMI=3Dy<br>
&gt; CONFIG_HAVE_HARDLOCKUP_<wbr>DETECTOR_PERF=3Dy<br>
&gt; CONFIG_HAVE_PERF_REGS=3Dy<br>
&gt; CONFIG_HAVE_PERF_USER_STACK_<wbr>DUMP=3Dy<br>
&gt; CONFIG_HAVE_ARCH_JUMP_LABEL=3Dy<br>
&gt; CONFIG_HAVE_RCU_TABLE_FREE=3Dy<br>
&gt; CONFIG_ARCH_HAVE_NMI_SAFE_<wbr>CMPXCHG=3Dy<br>
&gt; CONFIG_HAVE_CMPXCHG_LOCAL=3Dy<br>
&gt; CONFIG_HAVE_CMPXCHG_DOUBLE=3Dy<br>
&gt; CONFIG_ARCH_WANT_COMPAT_IPC_<wbr>PARSE_VERSION=3Dy<br>
&gt; CONFIG_ARCH_WANT_OLD_COMPAT_<wbr>IPC=3Dy<br>
&gt; CONFIG_HAVE_ARCH_SECCOMP_<wbr>FILTER=3Dy<br>
&gt; CONFIG_SECCOMP_FILTER=3Dy<br>
&gt; CONFIG_HAVE_GCC_PLUGINS=3Dy<br>
&gt; CONFIG_GCC_PLUGINS=3Dy<br>
&gt; # CONFIG_GCC_PLUGIN_CYC_<wbr>COMPLEXITY is not set<br>
&gt; CONFIG_GCC_PLUGIN_SANCOV=3Dy<br>
&gt; # CONFIG_GCC_PLUGIN_LATENT_<wbr>ENTROPY is not set<br>
&gt; # CONFIG_GCC_PLUGIN_STRUCTLEAK is not set<br>
&gt; # CONFIG_GCC_PLUGIN_RANDSTRUCT is not set<br>
&gt; CONFIG_HAVE_CC_STACKPROTECTOR=3D<wbr>y<br>
&gt; # CONFIG_CC_STACKPROTECTOR_NONE is not set<br>
&gt; CONFIG_CC_STACKPROTECTOR_<wbr>REGULAR=3Dy<br>
&gt; # CONFIG_CC_STACKPROTECTOR_<wbr>STRONG is not set<br>
&gt; # CONFIG_CC_STACKPROTECTOR_AUTO is not set<br>
&gt; CONFIG_THIN_ARCHIVES=3Dy<br>
&gt; CONFIG_HAVE_ARCH_WITHIN_STACK_<wbr>FRAMES=3Dy<br>
&gt; CONFIG_HAVE_CONTEXT_TRACKING=3Dy<br>
&gt; CONFIG_HAVE_VIRT_CPU_<wbr>ACCOUNTING_GEN=3Dy<br>
&gt; CONFIG_HAVE_IRQ_TIME_<wbr>ACCOUNTING=3Dy<br>
&gt; CONFIG_HAVE_ARCH_TRANSPARENT_<wbr>HUGEPAGE=3Dy<br>
&gt; CONFIG_HAVE_ARCH_TRANSPARENT_<wbr>HUGEPAGE_PUD=3Dy<br>
&gt; CONFIG_HAVE_ARCH_HUGE_VMAP=3Dy<br>
&gt; CONFIG_HAVE_ARCH_SOFT_DIRTY=3Dy<br>
&gt; CONFIG_HAVE_MOD_ARCH_SPECIFIC=3D<wbr>y<br>
&gt; CONFIG_MODULES_USE_ELF_RELA=3Dy<br>
&gt; CONFIG_HAVE_IRQ_EXIT_ON_IRQ_<wbr>STACK=3Dy<br>
&gt; CONFIG_ARCH_HAS_ELF_RANDOMIZE=3D<wbr>y<br>
&gt; CONFIG_HAVE_ARCH_MMAP_RND_<wbr>BITS=3Dy<br>
&gt; CONFIG_HAVE_EXIT_THREAD=3Dy<br>
&gt; CONFIG_ARCH_MMAP_RND_BITS=3D28<br>
&gt; CONFIG_HAVE_ARCH_MMAP_RND_<wbr>COMPAT_BITS=3Dy<br>
&gt; CONFIG_ARCH_MMAP_RND_COMPAT_<wbr>BITS=3D8<br>
&gt; CONFIG_HAVE_ARCH_COMPAT_MMAP_<wbr>BASES=3Dy<br>
&gt; CONFIG_HAVE_COPY_THREAD_TLS=3Dy<br>
&gt; CONFIG_HAVE_STACK_VALIDATION=3Dy<br>
&gt; # CONFIG_HAVE_ARCH_HASH is not set<br>
&gt; # CONFIG_ISA_BUS_API is not set<br>
&gt; CONFIG_OLD_SIGSUSPEND3=3Dy<br>
&gt; CONFIG_COMPAT_OLD_SIGACTION=3Dy<br>
&gt; # CONFIG_CPU_NO_EFFICIENT_FFS is not set<br>
&gt; CONFIG_HAVE_ARCH_VMAP_STACK=3Dy<br>
&gt; # CONFIG_ARCH_OPTIONAL_KERNEL_<wbr>RWX is not set<br>
&gt; # CONFIG_ARCH_OPTIONAL_KERNEL_<wbr>RWX_DEFAULT is not set<br>
&gt; CONFIG_ARCH_HAS_STRICT_KERNEL_<wbr>RWX=3Dy<br>
&gt; CONFIG_STRICT_KERNEL_RWX=3Dy<br>
&gt; CONFIG_ARCH_HAS_STRICT_MODULE_<wbr>RWX=3Dy<br>
&gt; CONFIG_STRICT_MODULE_RWX=3Dy<br>
&gt; CONFIG_ARCH_HAS_PHYS_TO_DMA=3Dy<br>
&gt; CONFIG_ARCH_HAS_REFCOUNT=3Dy<br>
&gt; CONFIG_REFCOUNT_FULL=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # GCOV-based kernel profiling<br>
&gt; #<br>
&gt; # CONFIG_GCOV_KERNEL is not set<br>
&gt; CONFIG_ARCH_HAS_GCOV_PROFILE_<wbr>ALL=3Dy<br>
&gt; # CONFIG_HAVE_GENERIC_DMA_<wbr>COHERENT is not set<br>
&gt; CONFIG_RT_MUTEXES=3Dy<br>
&gt; CONFIG_BASE_SMALL=3D0<br>
&gt; CONFIG_MODULES=3Dy<br>
&gt; # CONFIG_MODULE_FORCE_LOAD is not set<br>
&gt; CONFIG_MODULE_UNLOAD=3Dy<br>
&gt; CONFIG_MODULE_FORCE_UNLOAD=3Dy<br>
&gt; # CONFIG_MODVERSIONS is not set<br>
&gt; # CONFIG_MODULE_SRCVERSION_ALL is not set<br>
&gt; # CONFIG_MODULE_SIG is not set<br>
&gt; # CONFIG_MODULE_COMPRESS is not set<br>
&gt; # CONFIG_TRIM_UNUSED_KSYMS is not set<br>
&gt; CONFIG_MODULES_TREE_LOOKUP=3Dy<br>
&gt; CONFIG_BLOCK=3Dy<br>
&gt; CONFIG_BLK_SCSI_REQUEST=3Dy<br>
&gt; CONFIG_BLK_DEV_BSG=3Dy<br>
&gt; CONFIG_BLK_DEV_BSGLIB=3Dy<br>
&gt; CONFIG_BLK_DEV_INTEGRITY=3Dy<br>
&gt; CONFIG_BLK_DEV_ZONED=3Dy<br>
&gt; CONFIG_BLK_DEV_THROTTLING=3Dy<br>
&gt; # CONFIG_BLK_DEV_THROTTLING_LOW is not set<br>
&gt; # CONFIG_BLK_CMDLINE_PARSER is not set<br>
&gt; CONFIG_BLK_WBT=3Dy<br>
&gt; # CONFIG_BLK_WBT_SQ is not set<br>
&gt; CONFIG_BLK_WBT_MQ=3Dy<br>
&gt; # CONFIG_BLK_DEBUG_FS is not set<br>
&gt; # CONFIG_BLK_SED_OPAL is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Partition Types<br>
&gt; #<br>
&gt; CONFIG_PARTITION_ADVANCED=3Dy<br>
&gt; # CONFIG_ACORN_PARTITION is not set<br>
&gt; # CONFIG_AIX_PARTITION is not set<br>
&gt; CONFIG_OSF_PARTITION=3Dy<br>
&gt; CONFIG_AMIGA_PARTITION=3Dy<br>
&gt; # CONFIG_ATARI_PARTITION is not set<br>
&gt; CONFIG_MAC_PARTITION=3Dy<br>
&gt; CONFIG_MSDOS_PARTITION=3Dy<br>
&gt; CONFIG_BSD_DISKLABEL=3Dy<br>
&gt; CONFIG_MINIX_SUBPARTITION=3Dy<br>
&gt; CONFIG_SOLARIS_X86_PARTITION=3Dy<br>
&gt; CONFIG_UNIXWARE_DISKLABEL=3Dy<br>
&gt; # CONFIG_LDM_PARTITION is not set<br>
&gt; CONFIG_SGI_PARTITION=3Dy<br>
&gt; # CONFIG_ULTRIX_PARTITION is not set<br>
&gt; CONFIG_SUN_PARTITION=3Dy<br>
&gt; CONFIG_KARMA_PARTITION=3Dy<br>
&gt; CONFIG_EFI_PARTITION=3Dy<br>
&gt; # CONFIG_SYSV68_PARTITION is not set<br>
&gt; # CONFIG_CMDLINE_PARTITION is not set<br>
&gt; CONFIG_BLOCK_COMPAT=3Dy<br>
&gt; CONFIG_BLK_MQ_PCI=3Dy<br>
&gt; CONFIG_BLK_MQ_VIRTIO=3Dy<br>
&gt; CONFIG_BLK_MQ_RDMA=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # IO Schedulers<br>
&gt; #<br>
&gt; CONFIG_IOSCHED_NOOP=3Dy<br>
&gt; CONFIG_IOSCHED_DEADLINE=3Dy<br>
&gt; CONFIG_IOSCHED_CFQ=3Dy<br>
&gt; CONFIG_CFQ_GROUP_IOSCHED=3Dy<br>
&gt; # CONFIG_DEFAULT_DEADLINE is not set<br>
&gt; CONFIG_DEFAULT_CFQ=3Dy<br>
&gt; # CONFIG_DEFAULT_NOOP is not set<br>
&gt; CONFIG_DEFAULT_IOSCHED=3D&quot;cfq&quot;<br>
&gt; CONFIG_MQ_IOSCHED_DEADLINE=3Dy<br>
&gt; CONFIG_MQ_IOSCHED_KYBER=3Dy<br>
&gt; CONFIG_IOSCHED_BFQ=3Dy<br>
&gt; CONFIG_BFQ_GROUP_IOSCHED=3Dy<br>
&gt; CONFIG_PREEMPT_NOTIFIERS=3Dy<br>
&gt; CONFIG_PADATA=3Dy<br>
&gt; CONFIG_ASN1=3Dy<br>
&gt; CONFIG_UNINLINE_SPIN_UNLOCK=3Dy<br>
&gt; CONFIG_ARCH_SUPPORTS_ATOMIC_<wbr>RMW=3Dy<br>
&gt; CONFIG_MUTEX_SPIN_ON_OWNER=3Dy<br>
&gt; CONFIG_RWSEM_SPIN_ON_OWNER=3Dy<br>
&gt; CONFIG_LOCK_SPIN_ON_OWNER=3Dy<br>
&gt; CONFIG_ARCH_USE_QUEUED_<wbr>SPINLOCKS=3Dy<br>
&gt; CONFIG_QUEUED_SPINLOCKS=3Dy<br>
&gt; CONFIG_ARCH_USE_QUEUED_<wbr>RWLOCKS=3Dy<br>
&gt; CONFIG_QUEUED_RWLOCKS=3Dy<br>
&gt; CONFIG_ARCH_HAS_SYNC_CORE_<wbr>BEFORE_USERMODE=3Dy<br>
&gt; CONFIG_FREEZER=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Processor type and features<br>
&gt; #<br>
&gt; CONFIG_ZONE_DMA=3Dy<br>
&gt; CONFIG_SMP=3Dy<br>
&gt; CONFIG_X86_FEATURE_NAMES=3Dy<br>
&gt; CONFIG_X86_FAST_FEATURE_TESTS=3D<wbr>y<br>
&gt; CONFIG_X86_X2APIC=3Dy<br>
&gt; CONFIG_X86_MPPARSE=3Dy<br>
&gt; # CONFIG_GOLDFISH is not set<br>
&gt; CONFIG_RETPOLINE=3Dy<br>
&gt; # CONFIG_INTEL_RDT is not set<br>
&gt; CONFIG_X86_EXTENDED_PLATFORM=3Dy<br>
&gt; # CONFIG_X86_NUMACHIP is not set<br>
&gt; # CONFIG_X86_VSMP is not set<br>
&gt; # CONFIG_X86_UV is not set<br>
&gt; # CONFIG_X86_GOLDFISH is not set<br>
&gt; # CONFIG_X86_INTEL_MID is not set<br>
&gt; # CONFIG_X86_INTEL_LPSS is not set<br>
&gt; # CONFIG_X86_AMD_PLATFORM_DEVICE is not set<br>
&gt; CONFIG_IOSF_MBI=3Dy<br>
&gt; # CONFIG_IOSF_MBI_DEBUG is not set<br>
&gt; CONFIG_X86_SUPPORTS_MEMORY_<wbr>FAILURE=3Dy<br>
&gt; CONFIG_SCHED_OMIT_FRAME_<wbr>POINTER=3Dy<br>
&gt; CONFIG_HYPERVISOR_GUEST=3Dy<br>
&gt; CONFIG_PARAVIRT=3Dy<br>
&gt; CONFIG_PARAVIRT_DEBUG=3Dy<br>
&gt; CONFIG_PARAVIRT_SPINLOCKS=3Dy<br>
&gt; # CONFIG_QUEUED_LOCK_STAT is not set<br>
&gt; CONFIG_XEN=3Dy<br>
&gt; CONFIG_XEN_PV=3Dy<br>
&gt; CONFIG_XEN_PV_SMP=3Dy<br>
&gt; CONFIG_XEN_DOM0=3Dy<br>
&gt; CONFIG_XEN_PVHVM=3Dy<br>
&gt; CONFIG_XEN_PVHVM_SMP=3Dy<br>
&gt; CONFIG_XEN_512GB=3Dy<br>
&gt; CONFIG_XEN_SAVE_RESTORE=3Dy<br>
&gt; # CONFIG_XEN_DEBUG_FS is not set<br>
&gt; CONFIG_XEN_PVH=3Dy<br>
&gt; CONFIG_KVM_GUEST=3Dy<br>
&gt; # CONFIG_KVM_DEBUG_FS is not set<br>
&gt; # CONFIG_PARAVIRT_TIME_<wbr>ACCOUNTING is not set<br>
&gt; CONFIG_PARAVIRT_CLOCK=3Dy<br>
&gt; # CONFIG_JAILHOUSE_GUEST is not set<br>
&gt; CONFIG_NO_BOOTMEM=3Dy<br>
&gt; # CONFIG_MK8 is not set<br>
&gt; # CONFIG_MPSC is not set<br>
&gt; # CONFIG_MCORE2 is not set<br>
&gt; # CONFIG_MATOM is not set<br>
&gt; CONFIG_GENERIC_CPU=3Dy<br>
&gt; CONFIG_X86_INTERNODE_CACHE_<wbr>SHIFT=3D6<br>
&gt; CONFIG_X86_L1_CACHE_SHIFT=3D6<br>
&gt; CONFIG_X86_TSC=3Dy<br>
&gt; CONFIG_X86_CMPXCHG64=3Dy<br>
&gt; CONFIG_X86_CMOV=3Dy<br>
&gt; CONFIG_X86_MINIMUM_CPU_FAMILY=3D<wbr>64<br>
&gt; CONFIG_X86_DEBUGCTLMSR=3Dy<br>
&gt; # CONFIG_PROCESSOR_SELECT is not set<br>
&gt; CONFIG_CPU_SUP_INTEL=3Dy<br>
&gt; CONFIG_CPU_SUP_AMD=3Dy<br>
&gt; CONFIG_CPU_SUP_CENTAUR=3Dy<br>
&gt; CONFIG_HPET_TIMER=3Dy<br>
&gt; CONFIG_HPET_EMULATE_RTC=3Dy<br>
&gt; CONFIG_DMI=3Dy<br>
&gt; # CONFIG_GART_IOMMU is not set<br>
&gt; CONFIG_CALGARY_IOMMU=3Dy<br>
&gt; CONFIG_CALGARY_IOMMU_ENABLED_<wbr>BY_DEFAULT=3Dy<br>
&gt; CONFIG_SWIOTLB=3Dy<br>
&gt; CONFIG_IOMMU_HELPER=3Dy<br>
&gt; # CONFIG_MAXSMP is not set<br>
&gt; CONFIG_NR_CPUS_RANGE_BEGIN=3D2<br>
&gt; CONFIG_NR_CPUS_RANGE_END=3D512<br>
&gt; CONFIG_NR_CPUS_DEFAULT=3D64<br>
&gt; CONFIG_NR_CPUS=3D64<br>
&gt; CONFIG_SCHED_SMT=3Dy<br>
&gt; CONFIG_SCHED_MC=3Dy<br>
&gt; CONFIG_SCHED_MC_PRIO=3Dy<br>
&gt; # CONFIG_PREEMPT_NONE is not set<br>
&gt; CONFIG_PREEMPT_VOLUNTARY=3Dy<br>
&gt; # CONFIG_PREEMPT is not set<br>
&gt; CONFIG_PREEMPT_COUNT=3Dy<br>
&gt; CONFIG_X86_LOCAL_APIC=3Dy<br>
&gt; CONFIG_X86_IO_APIC=3Dy<br>
&gt; CONFIG_X86_REROUTE_FOR_BROKEN_<wbr>BOOT_IRQS=3Dy<br>
&gt; CONFIG_X86_MCE=3Dy<br>
&gt; # CONFIG_X86_MCELOG_LEGACY is not set<br>
&gt; CONFIG_X86_MCE_INTEL=3Dy<br>
&gt; CONFIG_X86_MCE_AMD=3Dy<br>
&gt; CONFIG_X86_MCE_THRESHOLD=3Dy<br>
&gt; CONFIG_X86_MCE_INJECT=3Dy<br>
&gt; CONFIG_X86_THERMAL_VECTOR=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Performance monitoring<br>
&gt; #<br>
&gt; CONFIG_PERF_EVENTS_INTEL_<wbr>UNCORE=3Dy<br>
&gt; CONFIG_PERF_EVENTS_INTEL_RAPL=3D<wbr>y<br>
&gt; CONFIG_PERF_EVENTS_INTEL_<wbr>CSTATE=3Dy<br>
&gt; # CONFIG_PERF_EVENTS_AMD_POWER is not set<br>
&gt; # CONFIG_VM86 is not set<br>
&gt; CONFIG_X86_16BIT=3Dy<br>
&gt; CONFIG_X86_ESPFIX64=3Dy<br>
&gt; CONFIG_X86_VSYSCALL_EMULATION=3D<wbr>y<br>
&gt; # CONFIG_I8K is not set<br>
&gt; CONFIG_MICROCODE=3Dy<br>
&gt; CONFIG_MICROCODE_INTEL=3Dy<br>
&gt; CONFIG_MICROCODE_AMD=3Dy<br>
&gt; CONFIG_MICROCODE_OLD_<wbr>INTERFACE=3Dy<br>
&gt; CONFIG_X86_MSR=3Dy<br>
&gt; CONFIG_X86_CPUID=3Dy<br>
&gt; # CONFIG_X86_5LEVEL is not set<br>
&gt; CONFIG_ARCH_PHYS_ADDR_T_64BIT=3D<wbr>y<br>
&gt; CONFIG_ARCH_DMA_ADDR_T_64BIT=3Dy<br>
&gt; CONFIG_X86_DIRECT_GBPAGES=3Dy<br>
&gt; CONFIG_ARCH_HAS_MEM_ENCRYPT=3Dy<br>
&gt; # CONFIG_AMD_MEM_ENCRYPT is not set<br>
&gt; CONFIG_NUMA=3Dy<br>
&gt; CONFIG_AMD_NUMA=3Dy<br>
&gt; CONFIG_X86_64_ACPI_NUMA=3Dy<br>
&gt; CONFIG_NODES_SPAN_OTHER_NODES=3D<wbr>y<br>
&gt; # CONFIG_NUMA_EMU is not set<br>
&gt; CONFIG_NODES_SHIFT=3D6<br>
&gt; CONFIG_ARCH_SPARSEMEM_ENABLE=3Dy<br>
&gt; CONFIG_ARCH_SPARSEMEM_DEFAULT=3D<wbr>y<br>
&gt; CONFIG_ARCH_SELECT_MEMORY_<wbr>MODEL=3Dy<br>
&gt; CONFIG_ARCH_PROC_KCORE_TEXT=3Dy<br>
&gt; CONFIG_ILLEGAL_POINTER_VALUE=3D<wbr>0xdead000000000000<br>
&gt; CONFIG_SELECT_MEMORY_MODEL=3Dy<br>
&gt; CONFIG_SPARSEMEM_MANUAL=3Dy<br>
&gt; CONFIG_SPARSEMEM=3Dy<br>
&gt; CONFIG_NEED_MULTIPLE_NODES=3Dy<br>
&gt; CONFIG_HAVE_MEMORY_PRESENT=3Dy<br>
&gt; CONFIG_SPARSEMEM_EXTREME=3Dy<br>
&gt; CONFIG_SPARSEMEM_VMEMMAP_<wbr>ENABLE=3Dy<br>
&gt; CONFIG_SPARSEMEM_ALLOC_MEM_<wbr>MAP_TOGETHER=3Dy<br>
&gt; CONFIG_SPARSEMEM_VMEMMAP=3Dy<br>
&gt; CONFIG_HAVE_MEMBLOCK=3Dy<br>
&gt; CONFIG_HAVE_MEMBLOCK_NODE_MAP=3D<wbr>y<br>
&gt; CONFIG_HAVE_GENERIC_GUP=3Dy<br>
&gt; CONFIG_ARCH_DISCARD_MEMBLOCK=3Dy<br>
&gt; # CONFIG_HAVE_BOOTMEM_INFO_NODE is not set<br>
&gt; # CONFIG_MEMORY_HOTPLUG is not set<br>
&gt; CONFIG_SPLIT_PTLOCK_CPUS=3D4<br>
&gt; CONFIG_ARCH_ENABLE_SPLIT_PMD_<wbr>PTLOCK=3Dy<br>
&gt; CONFIG_MEMORY_BALLOON=3Dy<br>
&gt; CONFIG_BALLOON_COMPACTION=3Dy<br>
&gt; CONFIG_COMPACTION=3Dy<br>
&gt; CONFIG_MIGRATION=3Dy<br>
&gt; CONFIG_ARCH_ENABLE_HUGEPAGE_<wbr>MIGRATION=3Dy<br>
&gt; CONFIG_ARCH_ENABLE_THP_<wbr>MIGRATION=3Dy<br>
&gt; CONFIG_PHYS_ADDR_T_64BIT=3Dy<br>
&gt; CONFIG_BOUNCE=3Dy<br>
&gt; CONFIG_VIRT_TO_BUS=3Dy<br>
&gt; CONFIG_MMU_NOTIFIER=3Dy<br>
&gt; CONFIG_KSM=3Dy<br>
&gt; CONFIG_DEFAULT_MMAP_MIN_ADDR=3D<wbr>4096<br>
&gt; CONFIG_ARCH_SUPPORTS_MEMORY_<wbr>FAILURE=3Dy<br>
&gt; # CONFIG_MEMORY_FAILURE is not set<br>
&gt; CONFIG_TRANSPARENT_HUGEPAGE=3Dy<br>
&gt; CONFIG_TRANSPARENT_HUGEPAGE_<wbr>ALWAYS=3Dy<br>
&gt; # CONFIG_TRANSPARENT_HUGEPAGE_<wbr>MADVISE is not set<br>
&gt; CONFIG_ARCH_WANTS_THP_SWAP=3Dy<br>
&gt; CONFIG_THP_SWAP=3Dy<br>
&gt; CONFIG_TRANSPARENT_HUGE_<wbr>PAGECACHE=3Dy<br>
&gt; # CONFIG_CLEANCACHE is not set<br>
&gt; CONFIG_FRONTSWAP=3Dy<br>
&gt; # CONFIG_CMA is not set<br>
&gt; # CONFIG_MEM_SOFT_DIRTY is not set<br>
&gt; CONFIG_ZSWAP=3Dy<br>
&gt; CONFIG_ZPOOL=3Dy<br>
&gt; # CONFIG_ZBUD is not set<br>
&gt; # CONFIG_Z3FOLD is not set<br>
&gt; CONFIG_ZSMALLOC=3Dy<br>
&gt; # CONFIG_PGTABLE_MAPPING is not set<br>
&gt; # CONFIG_ZSMALLOC_STAT is not set<br>
&gt; CONFIG_GENERIC_EARLY_IOREMAP=3Dy<br>
&gt; # CONFIG_DEFERRED_STRUCT_PAGE_<wbr>INIT is not set<br>
&gt; # CONFIG_IDLE_PAGE_TRACKING is not set<br>
&gt; CONFIG_ARCH_HAS_ZONE_DEVICE=3Dy<br>
&gt; CONFIG_ARCH_USES_HIGH_VMA_<wbr>FLAGS=3Dy<br>
&gt; CONFIG_ARCH_HAS_PKEYS=3Dy<br>
&gt; # CONFIG_PERCPU_STATS is not set<br>
&gt; # CONFIG_GUP_BENCHMARK is not set<br>
&gt; # CONFIG_X86_PMEM_LEGACY is not set<br>
&gt; CONFIG_X86_CHECK_BIOS_<wbr>CORRUPTION=3Dy<br>
&gt; CONFIG_X86_BOOTPARAM_MEMORY_<wbr>CORRUPTION_CHECK=3Dy<br>
&gt; CONFIG_X86_RESERVE_LOW=3D64<br>
&gt; CONFIG_MTRR=3Dy<br>
&gt; CONFIG_MTRR_SANITIZER=3Dy<br>
&gt; CONFIG_MTRR_SANITIZER_ENABLE_<wbr>DEFAULT=3D0<br>
&gt; CONFIG_MTRR_SANITIZER_SPARE_<wbr>REG_NR_DEFAULT=3D1<br>
&gt; CONFIG_X86_PAT=3Dy<br>
&gt; CONFIG_ARCH_USES_PG_UNCACHED=3Dy<br>
&gt; CONFIG_ARCH_RANDOM=3Dy<br>
&gt; CONFIG_X86_SMAP=3Dy<br>
&gt; # CONFIG_X86_INTEL_UMIP is not set<br>
&gt; CONFIG_X86_INTEL_MPX=3Dy<br>
&gt; CONFIG_X86_INTEL_MEMORY_<wbr>PROTECTION_KEYS=3Dy<br>
&gt; CONFIG_EFI=3Dy<br>
&gt; # CONFIG_EFI_STUB is not set<br>
&gt; CONFIG_SECCOMP=3Dy<br>
&gt; # CONFIG_HZ_100 is not set<br>
&gt; # CONFIG_HZ_250 is not set<br>
&gt; # CONFIG_HZ_300 is not set<br>
&gt; CONFIG_HZ_1000=3Dy<br>
&gt; CONFIG_HZ=3D1000<br>
&gt; CONFIG_SCHED_HRTICK=3Dy<br>
&gt; CONFIG_KEXEC=3Dy<br>
&gt; # CONFIG_KEXEC_FILE is not set<br>
&gt; CONFIG_CRASH_DUMP=3Dy<br>
&gt; # CONFIG_KEXEC_JUMP is not set<br>
&gt; CONFIG_PHYSICAL_START=3D<wbr>0x1000000<br>
&gt; CONFIG_RELOCATABLE=3Dy<br>
&gt; # CONFIG_RANDOMIZE_BASE is not set<br>
&gt; CONFIG_PHYSICAL_ALIGN=3D0x200000<br>
&gt; CONFIG_HOTPLUG_CPU=3Dy<br>
&gt; # CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set<br>
&gt; # CONFIG_DEBUG_HOTPLUG_CPU0 is not set<br>
&gt; # CONFIG_COMPAT_VDSO is not set<br>
&gt; # CONFIG_LEGACY_VSYSCALL_NATIVE is not set<br>
&gt; CONFIG_LEGACY_VSYSCALL_<wbr>EMULATE=3Dy<br>
&gt; # CONFIG_LEGACY_VSYSCALL_NONE is not set<br>
&gt; # CONFIG_CMDLINE_BOOL is not set<br>
&gt; CONFIG_MODIFY_LDT_SYSCALL=3Dy<br>
&gt; CONFIG_HAVE_LIVEPATCH=3Dy<br>
&gt; CONFIG_ARCH_HAS_ADD_PAGES=3Dy<br>
&gt; CONFIG_ARCH_ENABLE_MEMORY_<wbr>HOTPLUG=3Dy<br>
&gt; CONFIG_USE_PERCPU_NUMA_NODE_<wbr>ID=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Power management and ACPI options<br>
&gt; #<br>
&gt; CONFIG_ARCH_HIBERNATION_<wbr>HEADER=3Dy<br>
&gt; CONFIG_SUSPEND=3Dy<br>
&gt; CONFIG_SUSPEND_FREEZER=3Dy<br>
&gt; # CONFIG_SUSPEND_SKIP_SYNC is not set<br>
&gt; CONFIG_HIBERNATE_CALLBACKS=3Dy<br>
&gt; CONFIG_HIBERNATION=3Dy<br>
&gt; CONFIG_PM_STD_PARTITION=3D&quot;&quot;<br>
&gt; CONFIG_PM_SLEEP=3Dy<br>
&gt; CONFIG_PM_SLEEP_SMP=3Dy<br>
&gt; # CONFIG_PM_AUTOSLEEP is not set<br>
&gt; # CONFIG_PM_WAKELOCKS is not set<br>
&gt; CONFIG_PM=3Dy<br>
&gt; CONFIG_PM_DEBUG=3Dy<br>
&gt; # CONFIG_PM_ADVANCED_DEBUG is not set<br>
&gt; # CONFIG_PM_TEST_SUSPEND is not set<br>
&gt; CONFIG_PM_SLEEP_DEBUG=3Dy<br>
&gt; CONFIG_PM_TRACE=3Dy<br>
&gt; CONFIG_PM_TRACE_RTC=3Dy<br>
&gt; CONFIG_PM_CLK=3Dy<br>
&gt; # CONFIG_WQ_POWER_EFFICIENT_<wbr>DEFAULT is not set<br>
&gt; CONFIG_ACPI=3Dy<br>
&gt; CONFIG_ACPI_LEGACY_TABLES_<wbr>LOOKUP=3Dy<br>
&gt; CONFIG_ARCH_MIGHT_HAVE_ACPI_<wbr>PDC=3Dy<br>
&gt; CONFIG_ACPI_SYSTEM_POWER_<wbr>STATES_SUPPORT=3Dy<br>
&gt; # CONFIG_ACPI_DEBUGGER is not set<br>
&gt; CONFIG_ACPI_SPCR_TABLE=3Dy<br>
&gt; CONFIG_ACPI_LPIT=3Dy<br>
&gt; CONFIG_ACPI_SLEEP=3Dy<br>
&gt; # CONFIG_ACPI_PROCFS_POWER is not set<br>
&gt; CONFIG_ACPI_REV_OVERRIDE_<wbr>POSSIBLE=3Dy<br>
&gt; # CONFIG_ACPI_EC_DEBUGFS is not set<br>
&gt; CONFIG_ACPI_AC=3Dy<br>
&gt; CONFIG_ACPI_BATTERY=3Dy<br>
&gt; CONFIG_ACPI_BUTTON=3Dy<br>
&gt; CONFIG_ACPI_VIDEO=3Dy<br>
&gt; CONFIG_ACPI_FAN=3Dy<br>
&gt; CONFIG_ACPI_DOCK=3Dy<br>
&gt; CONFIG_ACPI_CPU_FREQ_PSS=3Dy<br>
&gt; CONFIG_ACPI_PROCESSOR_CSTATE=3Dy<br>
&gt; CONFIG_ACPI_PROCESSOR_IDLE=3Dy<br>
&gt; CONFIG_ACPI_CPPC_LIB=3Dy<br>
&gt; CONFIG_ACPI_PROCESSOR=3Dy<br>
&gt; CONFIG_ACPI_HOTPLUG_CPU=3Dy<br>
&gt; # CONFIG_ACPI_PROCESSOR_<wbr>AGGREGATOR is not set<br>
&gt; CONFIG_ACPI_THERMAL=3Dy<br>
&gt; CONFIG_ACPI_NUMA=3Dy<br>
&gt; # CONFIG_ACPI_CUSTOM_DSDT is not set<br>
&gt; CONFIG_ARCH_HAS_ACPI_TABLE_<wbr>UPGRADE=3Dy<br>
&gt; CONFIG_ACPI_TABLE_UPGRADE=3Dy<br>
&gt; # CONFIG_ACPI_DEBUG is not set<br>
&gt; # CONFIG_ACPI_PCI_SLOT is not set<br>
&gt; CONFIG_ACPI_CONTAINER=3Dy<br>
&gt; CONFIG_ACPI_HOTPLUG_IOAPIC=3Dy<br>
&gt; # CONFIG_ACPI_SBS is not set<br>
&gt; # CONFIG_ACPI_HED is not set<br>
&gt; # CONFIG_ACPI_CUSTOM_METHOD is not set<br>
&gt; # CONFIG_ACPI_BGRT is not set<br>
&gt; # CONFIG_ACPI_REDUCED_HARDWARE_<wbr>ONLY is not set<br>
&gt; # CONFIG_ACPI_NFIT is not set<br>
&gt; CONFIG_HAVE_ACPI_APEI=3Dy<br>
&gt; CONFIG_HAVE_ACPI_APEI_NMI=3Dy<br>
&gt; # CONFIG_ACPI_APEI is not set<br>
&gt; # CONFIG_DPTF_POWER is not set<br>
&gt; # CONFIG_ACPI_EXTLOG is not set<br>
&gt; # CONFIG_PMIC_OPREGION is not set<br>
&gt; # CONFIG_ACPI_CONFIGFS is not set<br>
&gt; CONFIG_X86_PM_TIMER=3Dy<br>
&gt; # CONFIG_SFI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CPU Frequency scaling<br>
&gt; #<br>
&gt; CONFIG_CPU_FREQ=3Dy<br>
&gt; CONFIG_CPU_FREQ_GOV_ATTR_SET=3Dy<br>
&gt; CONFIG_CPU_FREQ_GOV_COMMON=3Dy<br>
&gt; # CONFIG_CPU_FREQ_STAT is not set<br>
&gt; # CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>PERFORMANCE is not set<br>
&gt; # CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>POWERSAVE is not set<br>
&gt; CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>USERSPACE=3Dy<br>
&gt; # CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>ONDEMAND is not set<br>
&gt; # CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>CONSERVATIVE is not set<br>
&gt; # CONFIG_CPU_FREQ_DEFAULT_GOV_<wbr>SCHEDUTIL is not set<br>
&gt; CONFIG_CPU_FREQ_GOV_<wbr>PERFORMANCE=3Dy<br>
&gt; # CONFIG_CPU_FREQ_GOV_POWERSAVE is not set<br>
&gt; CONFIG_CPU_FREQ_GOV_USERSPACE=3D<wbr>y<br>
&gt; CONFIG_CPU_FREQ_GOV_ONDEMAND=3Dy<br>
&gt; # CONFIG_CPU_FREQ_GOV_<wbr>CONSERVATIVE is not set<br>
&gt; # CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CPU frequency scaling drivers<br>
&gt; #<br>
&gt; CONFIG_X86_INTEL_PSTATE=3Dy<br>
&gt; # CONFIG_X86_PCC_CPUFREQ is not set<br>
&gt; CONFIG_X86_ACPI_CPUFREQ=3Dy<br>
&gt; CONFIG_X86_ACPI_CPUFREQ_CPB=3Dy<br>
&gt; # CONFIG_X86_POWERNOW_K8 is not set<br>
&gt; # CONFIG_X86_AMD_FREQ_<wbr>SENSITIVITY is not set<br>
&gt; # CONFIG_X86_SPEEDSTEP_CENTRINO is not set<br>
&gt; # CONFIG_X86_P4_CLOCKMOD is not set<br>
&gt;<br>
&gt; #<br>
&gt; # shared options<br>
&gt; #<br>
&gt; # CONFIG_X86_SPEEDSTEP_LIB is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CPU Idle<br>
&gt; #<br>
&gt; CONFIG_CPU_IDLE=3Dy<br>
&gt; # CONFIG_CPU_IDLE_GOV_LADDER is not set<br>
&gt; CONFIG_CPU_IDLE_GOV_MENU=3Dy<br>
&gt; # CONFIG_ARCH_NEEDS_CPU_IDLE_<wbr>COUPLED is not set<br>
&gt; # CONFIG_INTEL_IDLE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Bus options (PCI etc.)<br>
&gt; #<br>
&gt; CONFIG_PCI=3Dy<br>
&gt; CONFIG_PCI_DIRECT=3Dy<br>
&gt; CONFIG_PCI_MMCONFIG=3Dy<br>
&gt; CONFIG_PCI_XEN=3Dy<br>
&gt; CONFIG_PCI_DOMAINS=3Dy<br>
&gt; # CONFIG_PCI_CNB20LE_QUIRK is not set<br>
&gt; CONFIG_PCIEPORTBUS=3Dy<br>
&gt; # CONFIG_HOTPLUG_PCI_PCIE is not set<br>
&gt; CONFIG_PCIEAER=3Dy<br>
&gt; # CONFIG_PCIE_ECRC is not set<br>
&gt; # CONFIG_PCIEAER_INJECT is not set<br>
&gt; CONFIG_PCIEASPM=3Dy<br>
&gt; # CONFIG_PCIEASPM_DEBUG is not set<br>
&gt; CONFIG_PCIEASPM_DEFAULT=3Dy<br>
&gt; # CONFIG_PCIEASPM_POWERSAVE is not set<br>
&gt; # CONFIG_PCIEASPM_POWER_<wbr>SUPERSAVE is not set<br>
&gt; # CONFIG_PCIEASPM_PERFORMANCE is not set<br>
&gt; CONFIG_PCIE_PME=3Dy<br>
&gt; # CONFIG_PCIE_DPC is not set<br>
&gt; # CONFIG_PCIE_PTM is not set<br>
&gt; CONFIG_PCI_BUS_ADDR_T_64BIT=3Dy<br>
&gt; CONFIG_PCI_MSI=3Dy<br>
&gt; CONFIG_PCI_MSI_IRQ_DOMAIN=3Dy<br>
&gt; CONFIG_PCI_QUIRKS=3Dy<br>
&gt; # CONFIG_PCI_DEBUG is not set<br>
&gt; # CONFIG_PCI_REALLOC_ENABLE_AUTO is not set<br>
&gt; # CONFIG_PCI_STUB is not set<br>
&gt; CONFIG_XEN_PCIDEV_FRONTEND=3Dy<br>
&gt; CONFIG_PCI_ATS=3Dy<br>
&gt; CONFIG_PCI_LOCKLESS_CONFIG=3Dy<br>
&gt; CONFIG_PCI_IOV=3Dy<br>
&gt; CONFIG_PCI_PRI=3Dy<br>
&gt; CONFIG_PCI_PASID=3Dy<br>
&gt; CONFIG_PCI_LABEL=3Dy<br>
&gt; CONFIG_HOTPLUG_PCI=3Dy<br>
&gt; # CONFIG_HOTPLUG_PCI_ACPI is not set<br>
&gt; # CONFIG_HOTPLUG_PCI_CPCI is not set<br>
&gt; # CONFIG_HOTPLUG_PCI_SHPC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Cadence PCIe controllers support<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # DesignWare PCI Core Support<br>
&gt; #<br>
&gt; # CONFIG_PCIE_DW_PLAT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PCI host controller drivers<br>
&gt; #<br>
&gt; # CONFIG_VMD is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PCI Endpoint<br>
&gt; #<br>
&gt; CONFIG_PCI_ENDPOINT=3Dy<br>
&gt; # CONFIG_PCI_ENDPOINT_CONFIGFS is not set<br>
&gt; # CONFIG_PCI_EPF_TEST is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PCI switch controller drivers<br>
&gt; #<br>
&gt; # CONFIG_PCI_SW_SWITCHTEC is not set<br>
&gt; # CONFIG_ISA_BUS is not set<br>
&gt; CONFIG_ISA_DMA_API=3Dy<br>
&gt; CONFIG_AMD_NB=3Dy<br>
&gt; CONFIG_PCCARD=3Dy<br>
&gt; CONFIG_PCMCIA=3Dy<br>
&gt; CONFIG_PCMCIA_LOAD_CIS=3Dy<br>
&gt; CONFIG_CARDBUS=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # PC-card bridges<br>
&gt; #<br>
&gt; CONFIG_YENTA=3Dy<br>
&gt; CONFIG_YENTA_O2=3Dy<br>
&gt; CONFIG_YENTA_RICOH=3Dy<br>
&gt; CONFIG_YENTA_TI=3Dy<br>
&gt; CONFIG_YENTA_ENE_TUNE=3Dy<br>
&gt; CONFIG_YENTA_TOSHIBA=3Dy<br>
&gt; # CONFIG_PD6729 is not set<br>
&gt; # CONFIG_I82092 is not set<br>
&gt; CONFIG_PCCARD_NONSTATIC=3Dy<br>
&gt; # CONFIG_RAPIDIO is not set<br>
&gt; # CONFIG_X86_SYSFB is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Executable file formats / Emulations<br>
&gt; #<br>
&gt; CONFIG_BINFMT_ELF=3Dy<br>
&gt; CONFIG_COMPAT_BINFMT_ELF=3Dy<br>
&gt; CONFIG_ELFCORE=3Dy<br>
&gt; CONFIG_CORE_DUMP_DEFAULT_ELF_<wbr>HEADERS=3Dy<br>
&gt; CONFIG_BINFMT_SCRIPT=3Dy<br>
&gt; # CONFIG_HAVE_AOUT is not set<br>
&gt; CONFIG_BINFMT_MISC=3Dy<br>
&gt; CONFIG_COREDUMP=3Dy<br>
&gt; CONFIG_IA32_EMULATION=3Dy<br>
&gt; # CONFIG_IA32_AOUT is not set<br>
&gt; CONFIG_X86_X32=3Dy<br>
&gt; CONFIG_COMPAT_32=3Dy<br>
&gt; CONFIG_COMPAT=3Dy<br>
&gt; CONFIG_COMPAT_FOR_U64_<wbr>ALIGNMENT=3Dy<br>
&gt; CONFIG_SYSVIPC_COMPAT=3Dy<br>
&gt; CONFIG_X86_DEV_DMA_OPS=3Dy<br>
&gt; CONFIG_NET=3Dy<br>
&gt; CONFIG_NET_INGRESS=3Dy<br>
&gt; CONFIG_NET_EGRESS=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Networking options<br>
&gt; #<br>
&gt; CONFIG_PACKET=3Dy<br>
&gt; # CONFIG_PACKET_DIAG is not set<br>
&gt; CONFIG_UNIX=3Dy<br>
&gt; # CONFIG_UNIX_DIAG is not set<br>
&gt; CONFIG_TLS=3Dy<br>
&gt; CONFIG_XFRM=3Dy<br>
&gt; CONFIG_XFRM_OFFLOAD=3Dy<br>
&gt; CONFIG_XFRM_ALGO=3Dy<br>
&gt; CONFIG_XFRM_USER=3Dy<br>
&gt; CONFIG_XFRM_SUB_POLICY=3Dy<br>
&gt; CONFIG_XFRM_MIGRATE=3Dy<br>
&gt; CONFIG_XFRM_STATISTICS=3Dy<br>
&gt; CONFIG_XFRM_IPCOMP=3Dy<br>
&gt; CONFIG_NET_KEY=3Dy<br>
&gt; CONFIG_NET_KEY_MIGRATE=3Dy<br>
&gt; CONFIG_SMC=3Dy<br>
&gt; # CONFIG_SMC_DIAG is not set<br>
&gt; CONFIG_INET=3Dy<br>
&gt; CONFIG_IP_MULTICAST=3Dy<br>
&gt; CONFIG_IP_ADVANCED_ROUTER=3Dy<br>
&gt; # CONFIG_IP_FIB_TRIE_STATS is not set<br>
&gt; CONFIG_IP_MULTIPLE_TABLES=3Dy<br>
&gt; CONFIG_IP_ROUTE_MULTIPATH=3Dy<br>
&gt; CONFIG_IP_ROUTE_VERBOSE=3Dy<br>
&gt; CONFIG_IP_ROUTE_CLASSID=3Dy<br>
&gt; CONFIG_IP_PNP=3Dy<br>
&gt; CONFIG_IP_PNP_DHCP=3Dy<br>
&gt; CONFIG_IP_PNP_BOOTP=3Dy<br>
&gt; CONFIG_IP_PNP_RARP=3Dy<br>
&gt; CONFIG_NET_IPIP=3Dy<br>
&gt; CONFIG_NET_IPGRE_DEMUX=3Dy<br>
&gt; CONFIG_NET_IP_TUNNEL=3Dy<br>
&gt; CONFIG_NET_IPGRE=3Dy<br>
&gt; CONFIG_NET_IPGRE_BROADCAST=3Dy<br>
&gt; CONFIG_IP_MROUTE=3Dy<br>
&gt; CONFIG_IP_MROUTE_MULTIPLE_<wbr>TABLES=3Dy<br>
&gt; CONFIG_IP_PIMSM_V1=3Dy<br>
&gt; CONFIG_IP_PIMSM_V2=3Dy<br>
&gt; CONFIG_SYN_COOKIES=3Dy<br>
&gt; CONFIG_NET_IPVTI=3Dy<br>
&gt; CONFIG_NET_UDP_TUNNEL=3Dy<br>
&gt; CONFIG_NET_FOU=3Dy<br>
&gt; CONFIG_NET_FOU_IP_TUNNELS=3Dy<br>
&gt; # CONFIG_INET_AH is not set<br>
&gt; # CONFIG_INET_ESP is not set<br>
&gt; CONFIG_INET_IPCOMP=3Dy<br>
&gt; CONFIG_INET_XFRM_TUNNEL=3Dy<br>
&gt; CONFIG_INET_TUNNEL=3Dy<br>
&gt; CONFIG_INET_XFRM_MODE_<wbr>TRANSPORT=3Dy<br>
&gt; CONFIG_INET_XFRM_MODE_TUNNEL=3Dy<br>
&gt; CONFIG_INET_XFRM_MODE_BEET=3Dy<br>
&gt; # CONFIG_INET_DIAG is not set<br>
&gt; CONFIG_TCP_CONG_ADVANCED=3Dy<br>
&gt; # CONFIG_TCP_CONG_BIC is not set<br>
&gt; CONFIG_TCP_CONG_CUBIC=3Dy<br>
&gt; # CONFIG_TCP_CONG_WESTWOOD is not set<br>
&gt; # CONFIG_TCP_CONG_HTCP is not set<br>
&gt; # CONFIG_TCP_CONG_HSTCP is not set<br>
&gt; # CONFIG_TCP_CONG_HYBLA is not set<br>
&gt; CONFIG_TCP_CONG_VEGAS=3Dy<br>
&gt; CONFIG_TCP_CONG_NV=3Dy<br>
&gt; CONFIG_TCP_CONG_SCALABLE=3Dy<br>
&gt; CONFIG_TCP_CONG_LP=3Dy<br>
&gt; CONFIG_TCP_CONG_VENO=3Dy<br>
&gt; CONFIG_TCP_CONG_YEAH=3Dy<br>
&gt; # CONFIG_TCP_CONG_ILLINOIS is not set<br>
&gt; # CONFIG_TCP_CONG_DCTCP is not set<br>
&gt; # CONFIG_TCP_CONG_CDG is not set<br>
&gt; # CONFIG_TCP_CONG_BBR is not set<br>
&gt; CONFIG_DEFAULT_CUBIC=3Dy<br>
&gt; # CONFIG_DEFAULT_VEGAS is not set<br>
&gt; # CONFIG_DEFAULT_VENO is not set<br>
&gt; # CONFIG_DEFAULT_RENO is not set<br>
&gt; CONFIG_DEFAULT_TCP_CONG=3D&quot;<wbr>cubic&quot;<br>
&gt; CONFIG_TCP_MD5SIG=3Dy<br>
&gt; CONFIG_IPV6=3Dy<br>
&gt; CONFIG_IPV6_ROUTER_PREF=3Dy<br>
&gt; CONFIG_IPV6_ROUTE_INFO=3Dy<br>
&gt; CONFIG_IPV6_OPTIMISTIC_DAD=3Dy<br>
&gt; CONFIG_INET6_AH=3Dy<br>
&gt; CONFIG_INET6_ESP=3Dy<br>
&gt; CONFIG_INET6_ESP_OFFLOAD=3Dy<br>
&gt; CONFIG_INET6_IPCOMP=3Dy<br>
&gt; CONFIG_IPV6_MIP6=3Dy<br>
&gt; CONFIG_IPV6_ILA=3Dy<br>
&gt; CONFIG_INET6_XFRM_TUNNEL=3Dy<br>
&gt; CONFIG_INET6_TUNNEL=3Dy<br>
&gt; CONFIG_INET6_XFRM_MODE_<wbr>TRANSPORT=3Dy<br>
&gt; CONFIG_INET6_XFRM_MODE_TUNNEL=3D<wbr>y<br>
&gt; CONFIG_INET6_XFRM_MODE_BEET=3Dy<br>
&gt; CONFIG_INET6_XFRM_MODE_<wbr>ROUTEOPTIMIZATION=3Dy<br>
&gt; CONFIG_IPV6_VTI=3Dy<br>
&gt; CONFIG_IPV6_SIT=3Dy<br>
&gt; CONFIG_IPV6_SIT_6RD=3Dy<br>
&gt; CONFIG_IPV6_NDISC_NODETYPE=3Dy<br>
&gt; CONFIG_IPV6_TUNNEL=3Dy<br>
&gt; CONFIG_IPV6_GRE=3Dy<br>
&gt; CONFIG_IPV6_FOU=3Dy<br>
&gt; CONFIG_IPV6_FOU_TUNNEL=3Dy<br>
&gt; CONFIG_IPV6_MULTIPLE_TABLES=3Dy<br>
&gt; CONFIG_IPV6_SUBTREES=3Dy<br>
&gt; CONFIG_IPV6_MROUTE=3Dy<br>
&gt; CONFIG_IPV6_MROUTE_MULTIPLE_<wbr>TABLES=3Dy<br>
&gt; CONFIG_IPV6_PIMSM_V2=3Dy<br>
&gt; CONFIG_IPV6_SEG6_LWTUNNEL=3Dy<br>
&gt; CONFIG_IPV6_SEG6_HMAC=3Dy<br>
&gt; CONFIG_NETLABEL=3Dy<br>
&gt; CONFIG_NETWORK_SECMARK=3Dy<br>
&gt; CONFIG_NET_PTP_CLASSIFY=3Dy<br>
&gt; # CONFIG_NETWORK_PHY_<wbr>TIMESTAMPING is not set<br>
&gt; CONFIG_NETFILTER=3Dy<br>
&gt; CONFIG_NETFILTER_ADVANCED=3Dy<br>
&gt; CONFIG_BRIDGE_NETFILTER=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Core Netfilter Configuration<br>
&gt; #<br>
&gt; CONFIG_NETFILTER_INGRESS=3Dy<br>
&gt; CONFIG_NETFILTER_NETLINK=3Dy<br>
&gt; CONFIG_NETFILTER_FAMILY_<wbr>BRIDGE=3Dy<br>
&gt; CONFIG_NETFILTER_FAMILY_ARP=3Dy<br>
&gt; CONFIG_NETFILTER_NETLINK_ACCT=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_NETLINK_<wbr>QUEUE=3Dy<br>
&gt; CONFIG_NETFILTER_NETLINK_LOG=3Dy<br>
&gt; CONFIG_NF_CONNTRACK=3Dy<br>
&gt; CONFIG_NF_LOG_COMMON=3Dy<br>
&gt; CONFIG_NF_LOG_NETDEV=3Dy<br>
&gt; CONFIG_NETFILTER_CONNCOUNT=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_MARK=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_SECMARK=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_ZONES=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_PROCFS=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_EVENTS=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_TIMEOUT=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_TIMESTAMP=3D<wbr>y<br>
&gt; CONFIG_NF_CONNTRACK_LABELS=3Dy<br>
&gt; CONFIG_NF_CT_PROTO_DCCP=3Dy<br>
&gt; CONFIG_NF_CT_PROTO_GRE=3Dy<br>
&gt; CONFIG_NF_CT_PROTO_SCTP=3Dy<br>
&gt; CONFIG_NF_CT_PROTO_UDPLITE=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_AMANDA=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_FTP=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_H323=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_IRC=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_BROADCAST=3D<wbr>y<br>
&gt; CONFIG_NF_CONNTRACK_NETBIOS_<wbr>NS=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_SNMP=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_PPTP=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_SANE=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_SIP=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_TFTP=3Dy<br>
&gt; CONFIG_NF_CT_NETLINK=3Dy<br>
&gt; CONFIG_NF_CT_NETLINK_TIMEOUT=3Dy<br>
&gt; CONFIG_NF_CT_NETLINK_HELPER=3Dy<br>
&gt; CONFIG_NETFILTER_NETLINK_GLUE_<wbr>CT=3Dy<br>
&gt; CONFIG_NF_NAT=3Dy<br>
&gt; CONFIG_NF_NAT_NEEDED=3Dy<br>
&gt; CONFIG_NF_NAT_PROTO_DCCP=3Dy<br>
&gt; CONFIG_NF_NAT_PROTO_UDPLITE=3Dy<br>
&gt; CONFIG_NF_NAT_PROTO_SCTP=3Dy<br>
&gt; CONFIG_NF_NAT_AMANDA=3Dy<br>
&gt; CONFIG_NF_NAT_FTP=3Dy<br>
&gt; CONFIG_NF_NAT_IRC=3Dy<br>
&gt; CONFIG_NF_NAT_SIP=3Dy<br>
&gt; CONFIG_NF_NAT_TFTP=3Dy<br>
&gt; CONFIG_NF_NAT_REDIRECT=3Dy<br>
&gt; CONFIG_NETFILTER_SYNPROXY=3Dy<br>
&gt; CONFIG_NF_TABLES=3Dy<br>
&gt; CONFIG_NF_TABLES_INET=3Dy<br>
&gt; CONFIG_NF_TABLES_NETDEV=3Dy<br>
&gt; CONFIG_NFT_EXTHDR=3Dy<br>
&gt; CONFIG_NFT_META=3Dy<br>
&gt; CONFIG_NFT_RT=3Dy<br>
&gt; CONFIG_NFT_NUMGEN=3Dy<br>
&gt; CONFIG_NFT_CT=3Dy<br>
&gt; CONFIG_NFT_FLOW_OFFLOAD=3Dy<br>
&gt; CONFIG_NFT_SET_RBTREE=3Dy<br>
&gt; CONFIG_NFT_SET_HASH=3Dy<br>
&gt; CONFIG_NFT_SET_BITMAP=3Dy<br>
&gt; CONFIG_NFT_COUNTER=3Dy<br>
&gt; CONFIG_NFT_LOG=3Dy<br>
&gt; CONFIG_NFT_LIMIT=3Dy<br>
&gt; CONFIG_NFT_MASQ=3Dy<br>
&gt; CONFIG_NFT_REDIR=3Dy<br>
&gt; CONFIG_NFT_NAT=3Dy<br>
&gt; CONFIG_NFT_OBJREF=3Dy<br>
&gt; CONFIG_NFT_QUEUE=3Dy<br>
&gt; CONFIG_NFT_QUOTA=3Dy<br>
&gt; CONFIG_NFT_REJECT=3Dy<br>
&gt; CONFIG_NFT_REJECT_INET=3Dy<br>
&gt; CONFIG_NFT_COMPAT=3Dy<br>
&gt; CONFIG_NFT_HASH=3Dy<br>
&gt; CONFIG_NFT_FIB=3Dy<br>
&gt; CONFIG_NFT_FIB_INET=3Dy<br>
&gt; CONFIG_NF_DUP_NETDEV=3Dy<br>
&gt; CONFIG_NFT_DUP_NETDEV=3Dy<br>
&gt; CONFIG_NFT_FWD_NETDEV=3Dy<br>
&gt; CONFIG_NFT_FIB_NETDEV=3Dy<br>
&gt; CONFIG_NF_FLOW_TABLE_INET=3Dy<br>
&gt; CONFIG_NF_FLOW_TABLE=3Dy<br>
&gt; CONFIG_NETFILTER_XTABLES=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Xtables combined modules<br>
&gt; #<br>
&gt; CONFIG_NETFILTER_XT_MARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_CONNMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_SET=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Xtables targets<br>
&gt; #<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>AUDIT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>CHECKSUM=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>CLASSIFY=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>CONNMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>CONNSECMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_CT=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>DSCP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_HL=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>HMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>IDLETIMER=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>LED=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>LOG=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>MARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_NAT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>NETMAP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>NFLOG=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>NFQUEUE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>NOTRACK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>RATEEST=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>REDIRECT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>TEE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>TPROXY=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>TRACE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>SECMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>TCPMSS=3Dy<br>
&gt; CONFIG_NETFILTER_XT_TARGET_<wbr>TCPOPTSTRIP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Xtables matches<br>
&gt; #<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>ADDRTYPE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_BPF=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CGROUP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CLUSTER=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>COMMENT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CONNBYTES=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CONNLABEL=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CONNLIMIT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CONNMARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>CONNTRACK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_CPU=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>DCCP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>DEVGROUP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>DSCP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_ECN=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_ESP=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>HASHLIMIT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>HELPER=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_HL=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>IPCOMP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>IPRANGE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>IPVS=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>L2TP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>LENGTH=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>LIMIT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_MAC=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>MARK=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>MULTIPORT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>NFACCT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_OSF=3D<wbr>y<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>OWNER=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>POLICY=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>PHYSDEV=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>PKTTYPE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>QUOTA=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>RATEEST=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>REALM=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>RECENT=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>SCTP=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>SOCKET=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>STATE=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>STATISTIC=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>STRING=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>TCPMSS=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_<wbr>TIME=3Dy<br>
&gt; CONFIG_NETFILTER_XT_MATCH_U32=3D<wbr>y<br>
&gt; CONFIG_IP_SET=3Dy<br>
&gt; CONFIG_IP_SET_MAX=3D256<br>
&gt; CONFIG_IP_SET_BITMAP_IP=3Dy<br>
&gt; CONFIG_IP_SET_BITMAP_IPMAC=3Dy<br>
&gt; CONFIG_IP_SET_BITMAP_PORT=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IP=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IPMARK=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IPPORT=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IPPORTIP=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IPPORTNET=3Dy<br>
&gt; CONFIG_IP_SET_HASH_IPMAC=3Dy<br>
&gt; CONFIG_IP_SET_HASH_MAC=3Dy<br>
&gt; CONFIG_IP_SET_HASH_NETPORTNET=3D<wbr>y<br>
&gt; CONFIG_IP_SET_HASH_NET=3Dy<br>
&gt; CONFIG_IP_SET_HASH_NETNET=3Dy<br>
&gt; CONFIG_IP_SET_HASH_NETPORT=3Dy<br>
&gt; CONFIG_IP_SET_HASH_NETIFACE=3Dy<br>
&gt; CONFIG_IP_SET_LIST_SET=3Dy<br>
&gt; CONFIG_IP_VS=3Dy<br>
&gt; CONFIG_IP_VS_IPV6=3Dy<br>
&gt; # CONFIG_IP_VS_DEBUG is not set<br>
&gt; CONFIG_IP_VS_TAB_BITS=3D12<br>
&gt;<br>
&gt; #<br>
&gt; # IPVS transport protocol load balancing support<br>
&gt; #<br>
&gt; CONFIG_IP_VS_PROTO_TCP=3Dy<br>
&gt; CONFIG_IP_VS_PROTO_UDP=3Dy<br>
&gt; CONFIG_IP_VS_PROTO_AH_ESP=3Dy<br>
&gt; CONFIG_IP_VS_PROTO_ESP=3Dy<br>
&gt; CONFIG_IP_VS_PROTO_AH=3Dy<br>
&gt; CONFIG_IP_VS_PROTO_SCTP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # IPVS scheduler<br>
&gt; #<br>
&gt; # CONFIG_IP_VS_RR is not set<br>
&gt; # CONFIG_IP_VS_WRR is not set<br>
&gt; # CONFIG_IP_VS_LC is not set<br>
&gt; CONFIG_IP_VS_WLC=3Dy<br>
&gt; # CONFIG_IP_VS_FO is not set<br>
&gt; # CONFIG_IP_VS_OVF is not set<br>
&gt; # CONFIG_IP_VS_LBLC is not set<br>
&gt; # CONFIG_IP_VS_LBLCR is not set<br>
&gt; # CONFIG_IP_VS_DH is not set<br>
&gt; # CONFIG_IP_VS_SH is not set<br>
&gt; # CONFIG_IP_VS_SED is not set<br>
&gt; # CONFIG_IP_VS_NQ is not set<br>
&gt;<br>
&gt; #<br>
&gt; # IPVS SH scheduler<br>
&gt; #<br>
&gt; CONFIG_IP_VS_SH_TAB_BITS=3D8<br>
&gt;<br>
&gt; #<br>
&gt; # IPVS application helper<br>
&gt; #<br>
&gt; CONFIG_IP_VS_FTP=3Dy<br>
&gt; CONFIG_IP_VS_NFCT=3Dy<br>
&gt; CONFIG_IP_VS_PE_SIP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # IP: Netfilter Configuration<br>
&gt; #<br>
&gt; CONFIG_NF_DEFRAG_IPV4=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_IPV4=3Dy<br>
&gt; CONFIG_NF_SOCKET_IPV4=3Dy<br>
&gt; CONFIG_NF_TABLES_IPV4=3Dy<br>
&gt; CONFIG_NFT_CHAIN_ROUTE_IPV4=3Dy<br>
&gt; CONFIG_NFT_REJECT_IPV4=3Dy<br>
&gt; CONFIG_NFT_DUP_IPV4=3Dy<br>
&gt; CONFIG_NFT_FIB_IPV4=3Dy<br>
&gt; CONFIG_NF_TABLES_ARP=3Dy<br>
&gt; CONFIG_NF_FLOW_TABLE_IPV4=3Dy<br>
&gt; CONFIG_NF_DUP_IPV4=3Dy<br>
&gt; CONFIG_NF_LOG_ARP=3Dy<br>
&gt; CONFIG_NF_LOG_IPV4=3Dy<br>
&gt; CONFIG_NF_REJECT_IPV4=3Dy<br>
&gt; CONFIG_NF_NAT_IPV4=3Dy<br>
&gt; CONFIG_NFT_CHAIN_NAT_IPV4=3Dy<br>
&gt; CONFIG_NF_NAT_MASQUERADE_IPV4=3D<wbr>y<br>
&gt; CONFIG_NFT_MASQ_IPV4=3Dy<br>
&gt; CONFIG_NFT_REDIR_IPV4=3Dy<br>
&gt; CONFIG_NF_NAT_SNMP_BASIC=3Dy<br>
&gt; CONFIG_NF_NAT_PROTO_GRE=3Dy<br>
&gt; CONFIG_NF_NAT_PPTP=3Dy<br>
&gt; CONFIG_NF_NAT_H323=3Dy<br>
&gt; CONFIG_IP_NF_IPTABLES=3Dy<br>
&gt; CONFIG_IP_NF_MATCH_AH=3Dy<br>
&gt; CONFIG_IP_NF_MATCH_ECN=3Dy<br>
&gt; CONFIG_IP_NF_MATCH_RPFILTER=3Dy<br>
&gt; CONFIG_IP_NF_MATCH_TTL=3Dy<br>
&gt; CONFIG_IP_NF_FILTER=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_REJECT=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_SYNPROXY=3Dy<br>
&gt; CONFIG_IP_NF_NAT=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_<wbr>MASQUERADE=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_NETMAP=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_REDIRECT=3Dy<br>
&gt; CONFIG_IP_NF_MANGLE=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_CLUSTERIP=3D<wbr>y<br>
&gt; CONFIG_IP_NF_TARGET_ECN=3Dy<br>
&gt; CONFIG_IP_NF_TARGET_TTL=3Dy<br>
&gt; CONFIG_IP_NF_RAW=3Dy<br>
&gt; CONFIG_IP_NF_SECURITY=3Dy<br>
&gt; CONFIG_IP_NF_ARPTABLES=3Dy<br>
&gt; CONFIG_IP_NF_ARPFILTER=3Dy<br>
&gt; CONFIG_IP_NF_ARP_MANGLE=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # IPv6: Netfilter Configuration<br>
&gt; #<br>
&gt; CONFIG_NF_DEFRAG_IPV6=3Dy<br>
&gt; CONFIG_NF_CONNTRACK_IPV6=3Dy<br>
&gt; CONFIG_NF_SOCKET_IPV6=3Dy<br>
&gt; CONFIG_NF_TABLES_IPV6=3Dy<br>
&gt; CONFIG_NFT_CHAIN_ROUTE_IPV6=3Dy<br>
&gt; CONFIG_NFT_REJECT_IPV6=3Dy<br>
&gt; CONFIG_NFT_DUP_IPV6=3Dy<br>
&gt; CONFIG_NFT_FIB_IPV6=3Dy<br>
&gt; CONFIG_NF_FLOW_TABLE_IPV6=3Dy<br>
&gt; CONFIG_NF_DUP_IPV6=3Dy<br>
&gt; CONFIG_NF_REJECT_IPV6=3Dy<br>
&gt; CONFIG_NF_LOG_IPV6=3Dy<br>
&gt; CONFIG_NF_NAT_IPV6=3Dy<br>
&gt; CONFIG_NFT_CHAIN_NAT_IPV6=3Dy<br>
&gt; CONFIG_NF_NAT_MASQUERADE_IPV6=3D<wbr>y<br>
&gt; CONFIG_NFT_MASQ_IPV6=3Dy<br>
&gt; CONFIG_NFT_REDIR_IPV6=3Dy<br>
&gt; CONFIG_IP6_NF_IPTABLES=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_AH=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_EUI64=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_FRAG=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_OPTS=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_HL=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_<wbr>IPV6HEADER=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_MH=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_RPFILTER=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_RT=3Dy<br>
&gt; CONFIG_IP6_NF_MATCH_SRH=3Dy<br>
&gt; CONFIG_IP6_NF_TARGET_HL=3Dy<br>
&gt; CONFIG_IP6_NF_FILTER=3Dy<br>
&gt; CONFIG_IP6_NF_TARGET_REJECT=3Dy<br>
&gt; CONFIG_IP6_NF_TARGET_SYNPROXY=3D<wbr>y<br>
&gt; CONFIG_IP6_NF_MANGLE=3Dy<br>
&gt; CONFIG_IP6_NF_RAW=3Dy<br>
&gt; CONFIG_IP6_NF_SECURITY=3Dy<br>
&gt; CONFIG_IP6_NF_NAT=3Dy<br>
&gt; CONFIG_IP6_NF_TARGET_<wbr>MASQUERADE=3Dy<br>
&gt; CONFIG_IP6_NF_TARGET_NPT=3Dy<br>
&gt; CONFIG_NF_TABLES_BRIDGE=3Dy<br>
&gt; CONFIG_NFT_BRIDGE_META=3Dy<br>
&gt; CONFIG_NFT_BRIDGE_REJECT=3Dy<br>
&gt; CONFIG_NF_LOG_BRIDGE=3Dy<br>
&gt; CONFIG_BRIDGE_NF_EBTABLES=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_BROUTE=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_T_FILTER=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_T_NAT=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_802_3=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_AMONG=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_ARP=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_IP=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_IP6=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_LIMIT=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_MARK=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_PKTTYPE=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_STP=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_VLAN=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_ARPREPLY=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_DNAT=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_MARK_T=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_REDIRECT=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_SNAT=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_LOG=3Dy<br>
&gt; CONFIG_BRIDGE_EBT_NFLOG=3Dy<br>
&gt; CONFIG_IP_DCCP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # DCCP CCIDs Configuration<br>
&gt; #<br>
&gt; # CONFIG_IP_DCCP_CCID2_DEBUG is not set<br>
&gt; CONFIG_IP_DCCP_CCID3=3Dy<br>
&gt; # CONFIG_IP_DCCP_CCID3_DEBUG is not set<br>
&gt; CONFIG_IP_DCCP_TFRC_LIB=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # DCCP Kernel Hacking<br>
&gt; #<br>
&gt; # CONFIG_IP_DCCP_DEBUG is not set<br>
&gt; CONFIG_IP_SCTP=3Dy<br>
&gt; # CONFIG_SCTP_DBG_OBJCNT is not set<br>
&gt; CONFIG_SCTP_DEFAULT_COOKIE_<wbr>HMAC_MD5=3Dy<br>
&gt; # CONFIG_SCTP_DEFAULT_COOKIE_<wbr>HMAC_SHA1 is not set<br>
&gt; # CONFIG_SCTP_DEFAULT_COOKIE_<wbr>HMAC_NONE is not set<br>
&gt; CONFIG_SCTP_COOKIE_HMAC_MD5=3Dy<br>
&gt; CONFIG_SCTP_COOKIE_HMAC_SHA1=3Dy<br>
&gt; CONFIG_RDS=3Dy<br>
&gt; CONFIG_RDS_RDMA=3Dy<br>
&gt; CONFIG_RDS_TCP=3Dy<br>
&gt; # CONFIG_RDS_DEBUG is not set<br>
&gt; CONFIG_TIPC=3Dy<br>
&gt; CONFIG_TIPC_MEDIA_IB=3Dy<br>
&gt; CONFIG_TIPC_MEDIA_UDP=3Dy<br>
&gt; CONFIG_ATM=3Dy<br>
&gt; CONFIG_ATM_CLIP=3Dy<br>
&gt; # CONFIG_ATM_CLIP_NO_ICMP is not set<br>
&gt; CONFIG_ATM_LANE=3Dy<br>
&gt; CONFIG_ATM_MPOA=3Dy<br>
&gt; CONFIG_ATM_BR2684=3Dy<br>
&gt; # CONFIG_ATM_BR2684_IPFILTER is not set<br>
&gt; CONFIG_L2TP=3Dy<br>
&gt; # CONFIG_L2TP_DEBUGFS is not set<br>
&gt; # CONFIG_L2TP_V3 is not set<br>
&gt; CONFIG_STP=3Dy<br>
&gt; CONFIG_GARP=3Dy<br>
&gt; CONFIG_MRP=3Dy<br>
&gt; CONFIG_BRIDGE=3Dy<br>
&gt; CONFIG_BRIDGE_IGMP_SNOOPING=3Dy<br>
&gt; CONFIG_BRIDGE_VLAN_FILTERING=3Dy<br>
&gt; CONFIG_HAVE_NET_DSA=3Dy<br>
&gt; CONFIG_NET_DSA=3Dy<br>
&gt; CONFIG_NET_DSA_LEGACY=3Dy<br>
&gt; CONFIG_VLAN_8021Q=3Dy<br>
&gt; CONFIG_VLAN_8021Q_GVRP=3Dy<br>
&gt; CONFIG_VLAN_8021Q_MVRP=3Dy<br>
&gt; # CONFIG_DECNET is not set<br>
&gt; CONFIG_LLC=3Dy<br>
&gt; CONFIG_LLC2=3Dy<br>
&gt; # CONFIG_ATALK is not set<br>
&gt; # CONFIG_X25 is not set<br>
&gt; # CONFIG_LAPB is not set<br>
&gt; # CONFIG_PHONET is not set<br>
&gt; CONFIG_6LOWPAN=3Dy<br>
&gt; # CONFIG_6LOWPAN_DEBUGFS is not set<br>
&gt; CONFIG_6LOWPAN_NHC=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_DEST=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_FRAGMENT=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_HOP=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_IPV6=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_MOBILITY=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_ROUTING=3Dy<br>
&gt; CONFIG_6LOWPAN_NHC_UDP=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_EXT_HDR_<wbr>HOP=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_UDP=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_ICMPV6=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_EXT_HDR_<wbr>DEST=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_EXT_HDR_<wbr>FRAG=3Dy<br>
&gt; CONFIG_6LOWPAN_GHC_EXT_HDR_<wbr>ROUTE=3Dy<br>
&gt; CONFIG_IEEE802154=3Dy<br>
&gt; CONFIG_IEEE802154_NL802154_<wbr>EXPERIMENTAL=3Dy<br>
&gt; CONFIG_IEEE802154_SOCKET=3Dy<br>
&gt; CONFIG_IEEE802154_6LOWPAN=3Dy<br>
&gt; CONFIG_MAC802154=3Dy<br>
&gt; CONFIG_NET_SCHED=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Queueing/Scheduling<br>
&gt; #<br>
&gt; CONFIG_NET_SCH_CBQ=3Dy<br>
&gt; CONFIG_NET_SCH_HTB=3Dy<br>
&gt; CONFIG_NET_SCH_HFSC=3Dy<br>
&gt; CONFIG_NET_SCH_ATM=3Dy<br>
&gt; CONFIG_NET_SCH_PRIO=3Dy<br>
&gt; CONFIG_NET_SCH_MULTIQ=3Dy<br>
&gt; CONFIG_NET_SCH_RED=3Dy<br>
&gt; CONFIG_NET_SCH_SFB=3Dy<br>
&gt; CONFIG_NET_SCH_SFQ=3Dy<br>
&gt; CONFIG_NET_SCH_TEQL=3Dy<br>
&gt; CONFIG_NET_SCH_TBF=3Dy<br>
&gt; CONFIG_NET_SCH_CBS=3Dy<br>
&gt; CONFIG_NET_SCH_GRED=3Dy<br>
&gt; CONFIG_NET_SCH_DSMARK=3Dy<br>
&gt; CONFIG_NET_SCH_NETEM=3Dy<br>
&gt; # CONFIG_NET_SCH_DRR is not set<br>
&gt; # CONFIG_NET_SCH_MQPRIO is not set<br>
&gt; # CONFIG_NET_SCH_CHOKE is not set<br>
&gt; # CONFIG_NET_SCH_QFQ is not set<br>
&gt; # CONFIG_NET_SCH_CODEL is not set<br>
&gt; # CONFIG_NET_SCH_FQ_CODEL is not set<br>
&gt; # CONFIG_NET_SCH_FQ is not set<br>
&gt; # CONFIG_NET_SCH_HHF is not set<br>
&gt; # CONFIG_NET_SCH_PIE is not set<br>
&gt; CONFIG_NET_SCH_INGRESS=3Dy<br>
&gt; # CONFIG_NET_SCH_PLUG is not set<br>
&gt; CONFIG_NET_SCH_DEFAULT=3Dy<br>
&gt; # CONFIG_DEFAULT_SFQ is not set<br>
&gt; CONFIG_DEFAULT_PFIFO_FAST=3Dy<br>
&gt; CONFIG_DEFAULT_NET_SCH=3D&quot;pfifo_<wbr>fast&quot;<br>
&gt;<br>
&gt; #<br>
&gt; # Classification<br>
&gt; #<br>
&gt; CONFIG_NET_CLS=3Dy<br>
&gt; CONFIG_NET_CLS_BASIC=3Dy<br>
&gt; CONFIG_NET_CLS_TCINDEX=3Dy<br>
&gt; CONFIG_NET_CLS_ROUTE4=3Dy<br>
&gt; CONFIG_NET_CLS_FW=3Dy<br>
&gt; CONFIG_NET_CLS_U32=3Dy<br>
&gt; # CONFIG_CLS_U32_PERF is not set<br>
&gt; CONFIG_CLS_U32_MARK=3Dy<br>
&gt; CONFIG_NET_CLS_RSVP=3Dy<br>
&gt; CONFIG_NET_CLS_RSVP6=3Dy<br>
&gt; CONFIG_NET_CLS_FLOW=3Dy<br>
&gt; # CONFIG_NET_CLS_CGROUP is not set<br>
&gt; CONFIG_NET_CLS_BPF=3Dy<br>
&gt; CONFIG_NET_CLS_FLOWER=3Dy<br>
&gt; # CONFIG_NET_CLS_MATCHALL is not set<br>
&gt; CONFIG_NET_EMATCH=3Dy<br>
&gt; CONFIG_NET_EMATCH_STACK=3D32<br>
&gt; CONFIG_NET_EMATCH_CMP=3Dy<br>
&gt; CONFIG_NET_EMATCH_NBYTE=3Dy<br>
&gt; CONFIG_NET_EMATCH_U32=3Dy<br>
&gt; CONFIG_NET_EMATCH_META=3Dy<br>
&gt; CONFIG_NET_EMATCH_TEXT=3Dy<br>
&gt; # CONFIG_NET_EMATCH_CANID is not set<br>
&gt; CONFIG_NET_EMATCH_IPSET=3Dy<br>
&gt; CONFIG_NET_CLS_ACT=3Dy<br>
&gt; CONFIG_NET_ACT_POLICE=3Dy<br>
&gt; # CONFIG_NET_ACT_GACT is not set<br>
&gt; # CONFIG_NET_ACT_MIRRED is not set<br>
&gt; CONFIG_NET_ACT_SAMPLE=3Dy<br>
&gt; # CONFIG_NET_ACT_IPT is not set<br>
&gt; CONFIG_NET_ACT_NAT=3Dy<br>
&gt; CONFIG_NET_ACT_PEDIT=3Dy<br>
&gt; CONFIG_NET_ACT_SIMP=3Dy<br>
&gt; # CONFIG_NET_ACT_SKBEDIT is not set<br>
&gt; # CONFIG_NET_ACT_CSUM is not set<br>
&gt; # CONFIG_NET_ACT_VLAN is not set<br>
&gt; CONFIG_NET_ACT_BPF=3Dy<br>
&gt; # CONFIG_NET_ACT_CONNMARK is not set<br>
&gt; # CONFIG_NET_ACT_SKBMOD is not set<br>
&gt; # CONFIG_NET_ACT_IFE is not set<br>
&gt; # CONFIG_NET_ACT_TUNNEL_KEY is not set<br>
&gt; # CONFIG_NET_CLS_IND is not set<br>
&gt; CONFIG_NET_SCH_FIFO=3Dy<br>
&gt; CONFIG_DCB=3Dy<br>
&gt; CONFIG_DNS_RESOLVER=3Dy<br>
&gt; # CONFIG_BATMAN_ADV is not set<br>
&gt; CONFIG_OPENVSWITCH=3Dy<br>
&gt; CONFIG_OPENVSWITCH_GRE=3Dy<br>
&gt; CONFIG_VSOCKETS=3Dy<br>
&gt; CONFIG_VSOCKETS_DIAG=3Dy<br>
&gt; CONFIG_VIRTIO_VSOCKETS=3Dy<br>
&gt; CONFIG_VIRTIO_VSOCKETS_COMMON=3D<wbr>y<br>
&gt; # CONFIG_NETLINK_DIAG is not set<br>
&gt; CONFIG_MPLS=3Dy<br>
&gt; CONFIG_NET_MPLS_GSO=3Dy<br>
&gt; CONFIG_MPLS_ROUTING=3Dy<br>
&gt; CONFIG_MPLS_IPTUNNEL=3Dy<br>
&gt; CONFIG_NET_NSH=3Dy<br>
&gt; # CONFIG_HSR is not set<br>
&gt; CONFIG_NET_SWITCHDEV=3Dy<br>
&gt; CONFIG_NET_L3_MASTER_DEV=3Dy<br>
&gt; CONFIG_NET_NCSI=3Dy<br>
&gt; CONFIG_RPS=3Dy<br>
&gt; CONFIG_RFS_ACCEL=3Dy<br>
&gt; CONFIG_XPS=3Dy<br>
&gt; CONFIG_CGROUP_NET_PRIO=3Dy<br>
&gt; CONFIG_CGROUP_NET_CLASSID=3Dy<br>
&gt; CONFIG_NET_RX_BUSY_POLL=3Dy<br>
&gt; CONFIG_BQL=3Dy<br>
&gt; CONFIG_BPF_JIT=3Dy<br>
&gt; CONFIG_BPF_STREAM_PARSER=3Dy<br>
&gt; CONFIG_NET_FLOW_LIMIT=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Network testing<br>
&gt; #<br>
&gt; # CONFIG_NET_PKTGEN is not set<br>
&gt; # CONFIG_NET_DROP_MONITOR is not set<br>
&gt; CONFIG_HAMRADIO=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Packet Radio protocols<br>
&gt; #<br>
&gt; # CONFIG_AX25 is not set<br>
&gt; CONFIG_CAN=3Dy<br>
&gt; CONFIG_CAN_RAW=3Dy<br>
&gt; CONFIG_CAN_BCM=3Dy<br>
&gt; CONFIG_CAN_GW=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # CAN Device Drivers<br>
&gt; #<br>
&gt; CONFIG_CAN_VCAN=3Dy<br>
&gt; CONFIG_CAN_VXCAN=3Dy<br>
&gt; CONFIG_CAN_SLCAN=3Dy<br>
&gt; CONFIG_CAN_DEV=3Dy<br>
&gt; CONFIG_CAN_CALC_BITTIMING=3Dy<br>
&gt; # CONFIG_CAN_LEDS is not set<br>
&gt; # CONFIG_CAN_C_CAN is not set<br>
&gt; # CONFIG_CAN_CC770 is not set<br>
&gt; CONFIG_CAN_IFI_CANFD=3Dy<br>
&gt; # CONFIG_CAN_M_CAN is not set<br>
&gt; # CONFIG_CAN_PEAK_PCIEFD is not set<br>
&gt; # CONFIG_CAN_SJA1000 is not set<br>
&gt; # CONFIG_CAN_SOFTING is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CAN USB interfaces<br>
&gt; #<br>
&gt; # CONFIG_CAN_EMS_USB is not set<br>
&gt; # CONFIG_CAN_ESD_USB2 is not set<br>
&gt; # CONFIG_CAN_GS_USB is not set<br>
&gt; # CONFIG_CAN_KVASER_USB is not set<br>
&gt; # CONFIG_CAN_PEAK_USB is not set<br>
&gt; # CONFIG_CAN_8DEV_USB is not set<br>
&gt; # CONFIG_CAN_MCBA_USB is not set<br>
&gt; # CONFIG_CAN_DEBUG_DEVICES is not set<br>
&gt; CONFIG_BT=3Dy<br>
&gt; CONFIG_BT_BREDR=3Dy<br>
&gt; CONFIG_BT_RFCOMM=3Dy<br>
&gt; CONFIG_BT_RFCOMM_TTY=3Dy<br>
&gt; CONFIG_BT_BNEP=3Dy<br>
&gt; CONFIG_BT_BNEP_MC_FILTER=3Dy<br>
&gt; CONFIG_BT_BNEP_PROTO_FILTER=3Dy<br>
&gt; CONFIG_BT_HIDP=3Dy<br>
&gt; CONFIG_BT_HS=3Dy<br>
&gt; CONFIG_BT_LE=3Dy<br>
&gt; # CONFIG_BT_6LOWPAN is not set<br>
&gt; CONFIG_BT_LEDS=3Dy<br>
&gt; # CONFIG_BT_SELFTEST is not set<br>
&gt; # CONFIG_BT_DEBUGFS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Bluetooth device drivers<br>
&gt; #<br>
&gt; CONFIG_BT_INTEL=3Dy<br>
&gt; CONFIG_BT_RTL=3Dy<br>
&gt; CONFIG_BT_HCIBTUSB=3Dy<br>
&gt; # CONFIG_BT_HCIBTUSB_AUTOSUSPEND is not set<br>
&gt; # CONFIG_BT_HCIBTUSB_BCM is not set<br>
&gt; CONFIG_BT_HCIBTUSB_RTL=3Dy<br>
&gt; # CONFIG_BT_HCIUART is not set<br>
&gt; # CONFIG_BT_HCIBCM203X is not set<br>
&gt; # CONFIG_BT_HCIBFUSB is not set<br>
&gt; # CONFIG_BT_HCIDTL1 is not set<br>
&gt; # CONFIG_BT_HCIBT3C is not set<br>
&gt; # CONFIG_BT_HCIBLUECARD is not set<br>
&gt; # CONFIG_BT_HCIBTUART is not set<br>
&gt; # CONFIG_BT_HCIVHCI is not set<br>
&gt; # CONFIG_BT_MRVL is not set<br>
&gt; # CONFIG_BT_ATH3K is not set<br>
&gt; # CONFIG_AF_RXRPC is not set<br>
&gt; CONFIG_AF_KCM=3Dy<br>
&gt; CONFIG_STREAM_PARSER=3Dy<br>
&gt; CONFIG_FIB_RULES=3Dy<br>
&gt; CONFIG_WIRELESS=3Dy<br>
&gt; CONFIG_CFG80211=3Dy<br>
&gt; # CONFIG_NL80211_TESTMODE is not set<br>
&gt; # CONFIG_CFG80211_DEVELOPER_<wbr>WARNINGS is not set<br>
&gt; # CONFIG_CFG80211_CERTIFICATION_<wbr>ONUS is not set<br>
&gt; CONFIG_CFG80211_REQUIRE_<wbr>SIGNED_REGDB=3Dy<br>
&gt; CONFIG_CFG80211_USE_KERNEL_<wbr>REGDB_KEYS=3Dy<br>
&gt; CONFIG_CFG80211_DEFAULT_PS=3Dy<br>
&gt; # CONFIG_CFG80211_DEBUGFS is not set<br>
&gt; CONFIG_CFG80211_CRDA_SUPPORT=3Dy<br>
&gt; # CONFIG_CFG80211_WEXT is not set<br>
&gt; # CONFIG_LIB80211 is not set<br>
&gt; CONFIG_MAC80211=3Dy<br>
&gt; CONFIG_MAC80211_HAS_RC=3Dy<br>
&gt; CONFIG_MAC80211_RC_MINSTREL=3Dy<br>
&gt; CONFIG_MAC80211_RC_MINSTREL_<wbr>HT=3Dy<br>
&gt; # CONFIG_MAC80211_RC_MINSTREL_<wbr>VHT is not set<br>
&gt; CONFIG_MAC80211_RC_DEFAULT_<wbr>MINSTREL=3Dy<br>
&gt; CONFIG_MAC80211_RC_DEFAULT=3D&quot;<wbr>minstrel_ht&quot;<br>
&gt; # CONFIG_MAC80211_MESH is not set<br>
&gt; CONFIG_MAC80211_LEDS=3Dy<br>
&gt; # CONFIG_MAC80211_DEBUGFS is not set<br>
&gt; # CONFIG_MAC80211_MESSAGE_<wbr>TRACING is not set<br>
&gt; # CONFIG_MAC80211_DEBUG_MENU is not set<br>
&gt; CONFIG_MAC80211_STA_HASH_MAX_<wbr>SIZE=3D0<br>
&gt; CONFIG_WIMAX=3Dy<br>
&gt; CONFIG_WIMAX_DEBUG_LEVEL=3D8<br>
&gt; CONFIG_RFKILL=3Dy<br>
&gt; CONFIG_RFKILL_LEDS=3Dy<br>
&gt; CONFIG_RFKILL_INPUT=3Dy<br>
&gt; CONFIG_NET_9P=3Dy<br>
&gt; CONFIG_NET_9P_VIRTIO=3Dy<br>
&gt; CONFIG_NET_9P_XEN=3Dy<br>
&gt; CONFIG_NET_9P_RDMA=3Dy<br>
&gt; # CONFIG_NET_9P_DEBUG is not set<br>
&gt; # CONFIG_CAIF is not set<br>
&gt; # CONFIG_CEPH_LIB is not set<br>
&gt; CONFIG_NFC=3Dy<br>
&gt; CONFIG_NFC_DIGITAL=3Dy<br>
&gt; CONFIG_NFC_NCI=3Dy<br>
&gt; CONFIG_NFC_NCI_UART=3Dy<br>
&gt; CONFIG_NFC_HCI=3Dy<br>
&gt; CONFIG_NFC_SHDLC=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Near Field Communication (NFC) devices<br>
&gt; #<br>
&gt; CONFIG_NFC_SIM=3Dy<br>
&gt; # CONFIG_NFC_PORT100 is not set<br>
&gt; CONFIG_NFC_FDP=3Dy<br>
&gt; # CONFIG_NFC_FDP_I2C is not set<br>
&gt; # CONFIG_NFC_PN544_I2C is not set<br>
&gt; # CONFIG_NFC_PN533_USB is not set<br>
&gt; # CONFIG_NFC_PN533_I2C is not set<br>
&gt; # CONFIG_NFC_MICROREAD_I2C is not set<br>
&gt; # CONFIG_NFC_MRVL_USB is not set<br>
&gt; # CONFIG_NFC_MRVL_UART is not set<br>
&gt; # CONFIG_NFC_ST21NFCA_I2C is not set<br>
&gt; # CONFIG_NFC_ST_NCI_I2C is not set<br>
&gt; # CONFIG_NFC_NXP_NCI is not set<br>
&gt; # CONFIG_NFC_S3FWRN5_I2C is not set<br>
&gt; CONFIG_PSAMPLE=3Dy<br>
&gt; # CONFIG_NET_IFE is not set<br>
&gt; CONFIG_LWTUNNEL=3Dy<br>
&gt; CONFIG_LWTUNNEL_BPF=3Dy<br>
&gt; CONFIG_DST_CACHE=3Dy<br>
&gt; CONFIG_GRO_CELLS=3Dy<br>
&gt; # CONFIG_NET_DEVLINK is not set<br>
&gt; CONFIG_MAY_USE_DEVLINK=3Dy<br>
&gt; CONFIG_HAVE_EBPF_JIT=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Device Drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Generic Driver Options<br>
&gt; #<br>
&gt; CONFIG_UEVENT_HELPER=3Dy<br>
&gt; CONFIG_UEVENT_HELPER_PATH=3D&quot;/<wbr>sbin/hotplug&quot;<br>
&gt; CONFIG_DEVTMPFS=3Dy<br>
&gt; CONFIG_DEVTMPFS_MOUNT=3Dy<br>
&gt; CONFIG_STANDALONE=3Dy<br>
&gt; CONFIG_PREVENT_FIRMWARE_BUILD=3D<wbr>y<br>
&gt; CONFIG_FW_LOADER=3Dy<br>
&gt; CONFIG_EXTRA_FIRMWARE=3D&quot;&quot;<br>
&gt; # CONFIG_FW_LOADER_USER_HELPER_<wbr>FALLBACK is not set<br>
&gt; CONFIG_ALLOW_DEV_COREDUMP=3Dy<br>
&gt; # CONFIG_DEBUG_DRIVER is not set<br>
&gt; CONFIG_DEBUG_DEVRES=3Dy<br>
&gt; # CONFIG_DEBUG_TEST_DRIVER_<wbr>REMOVE is not set<br>
&gt; # CONFIG_TEST_ASYNC_DRIVER_PROBE is not set<br>
&gt; CONFIG_SYS_HYPERVISOR=3Dy<br>
&gt; # CONFIG_GENERIC_CPU_DEVICES is not set<br>
&gt; CONFIG_GENERIC_CPU_AUTOPROBE=3Dy<br>
&gt; CONFIG_GENERIC_CPU_<wbr>VULNERABILITIES=3Dy<br>
&gt; CONFIG_REGMAP=3Dy<br>
&gt; CONFIG_REGMAP_I2C=3Dy<br>
&gt; CONFIG_DMA_SHARED_BUFFER=3Dy<br>
&gt; # CONFIG_DMA_FENCE_TRACE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Bus devices<br>
&gt; #<br>
&gt; CONFIG_CONNECTOR=3Dy<br>
&gt; CONFIG_PROC_EVENTS=3Dy<br>
&gt; # CONFIG_MTD is not set<br>
&gt; # CONFIG_OF is not set<br>
&gt; CONFIG_ARCH_MIGHT_HAVE_PC_<wbr>PARPORT=3Dy<br>
&gt; # CONFIG_PARPORT is not set<br>
&gt; CONFIG_PNP=3Dy<br>
&gt; CONFIG_PNP_DEBUG_MESSAGES=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Protocols<br>
&gt; #<br>
&gt; CONFIG_PNPACPI=3Dy<br>
&gt; CONFIG_BLK_DEV=3Dy<br>
&gt; CONFIG_BLK_DEV_NULL_BLK=3Dy<br>
&gt; CONFIG_BLK_DEV_NULL_BLK_FAULT_<wbr>INJECTION=3Dy<br>
&gt; # CONFIG_BLK_DEV_FD is not set<br>
&gt; CONFIG_CDROM=3Dy<br>
&gt; # CONFIG_BLK_DEV_PCIESSD_<wbr>MTIP32XX is not set<br>
&gt; # CONFIG_ZRAM is not set<br>
&gt; # CONFIG_BLK_DEV_DAC960 is not set<br>
&gt; # CONFIG_BLK_DEV_UMEM is not set<br>
&gt; # CONFIG_BLK_DEV_COW_COMMON is not set<br>
&gt; CONFIG_BLK_DEV_LOOP=3Dy<br>
&gt; CONFIG_BLK_DEV_LOOP_MIN_COUNT=3D<wbr>8<br>
&gt; # CONFIG_BLK_DEV_CRYPTOLOOP is not set<br>
&gt; # CONFIG_BLK_DEV_DRBD is not set<br>
&gt; # CONFIG_BLK_DEV_NBD is not set<br>
&gt; # CONFIG_BLK_DEV_SKD is not set<br>
&gt; # CONFIG_BLK_DEV_SX8 is not set<br>
&gt; # CONFIG_BLK_DEV_RAM is not set<br>
&gt; # CONFIG_CDROM_PKTCDVD is not set<br>
&gt; # CONFIG_ATA_OVER_ETH is not set<br>
&gt; CONFIG_XEN_BLKDEV_FRONTEND=3Dy<br>
&gt; # CONFIG_XEN_BLKDEV_BACKEND is not set<br>
&gt; CONFIG_VIRTIO_BLK=3Dy<br>
&gt; CONFIG_VIRTIO_BLK_SCSI=3Dy<br>
&gt; # CONFIG_BLK_DEV_RBD is not set<br>
&gt; # CONFIG_BLK_DEV_RSXX is not set<br>
&gt;<br>
&gt; #<br>
&gt; # NVME Support<br>
&gt; #<br>
&gt; # CONFIG_BLK_DEV_NVME is not set<br>
&gt; # CONFIG_NVME_RDMA is not set<br>
&gt; # CONFIG_NVME_FC is not set<br>
&gt; # CONFIG_NVME_TARGET is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Misc devices<br>
&gt; #<br>
&gt; # CONFIG_SENSORS_LIS3LV02D is not set<br>
&gt; # CONFIG_AD525X_DPOT is not set<br>
&gt; # CONFIG_DUMMY_IRQ is not set<br>
&gt; # CONFIG_IBM_ASM is not set<br>
&gt; # CONFIG_PHANTOM is not set<br>
&gt; # CONFIG_SGI_IOC4 is not set<br>
&gt; # CONFIG_TIFM_CORE is not set<br>
&gt; # CONFIG_ICS932S401 is not set<br>
&gt; # CONFIG_ENCLOSURE_SERVICES is not set<br>
&gt; # CONFIG_HP_ILO is not set<br>
&gt; # CONFIG_APDS9802ALS is not set<br>
&gt; # CONFIG_ISL29003 is not set<br>
&gt; # CONFIG_ISL29020 is not set<br>
&gt; # CONFIG_SENSORS_TSL2550 is not set<br>
&gt; # CONFIG_SENSORS_BH1770 is not set<br>
&gt; # CONFIG_SENSORS_APDS990X is not set<br>
&gt; # CONFIG_HMC6352 is not set<br>
&gt; # CONFIG_DS1682 is not set<br>
&gt; # CONFIG_USB_SWITCH_FSA9480 is not set<br>
&gt; # CONFIG_SRAM is not set<br>
&gt; # CONFIG_PCI_ENDPOINT_TEST is not set<br>
&gt; # CONFIG_MISC_RTSX is not set<br>
&gt; # CONFIG_C2PORT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # EEPROM support<br>
&gt; #<br>
&gt; # CONFIG_EEPROM_AT24 is not set<br>
&gt; # CONFIG_EEPROM_LEGACY is not set<br>
&gt; # CONFIG_EEPROM_MAX6875 is not set<br>
&gt; # CONFIG_EEPROM_93CX6 is not set<br>
&gt; # CONFIG_EEPROM_IDT_89HPESX is not set<br>
&gt; # CONFIG_CB710_CORE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Texas Instruments shared transport line discipline<br>
&gt; #<br>
&gt; # CONFIG_SENSORS_LIS3_I2C is not set<br>
&gt; # CONFIG_ALTERA_STAPL is not set<br>
&gt; # CONFIG_INTEL_MEI is not set<br>
&gt; # CONFIG_INTEL_MEI_ME is not set<br>
&gt; # CONFIG_INTEL_MEI_TXE is not set<br>
&gt; # CONFIG_VMWARE_VMCI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Intel MIC &amp; related support<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Intel MIC Bus Driver<br>
&gt; #<br>
&gt; # CONFIG_INTEL_MIC_BUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # SCIF Bus Driver<br>
&gt; #<br>
&gt; # CONFIG_SCIF_BUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # VOP Bus Driver<br>
&gt; #<br>
&gt; # CONFIG_VOP_BUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Intel MIC Host Driver<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Intel MIC Card Driver<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # SCIF Driver<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Intel MIC Coprocessor State Management (COSM) Drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # VOP Driver<br>
&gt; #<br>
&gt; # CONFIG_GENWQE is not set<br>
&gt; # CONFIG_ECHO is not set<br>
&gt; # CONFIG_CXL_BASE is not set<br>
&gt; # CONFIG_CXL_AFU_DRIVER_OPS is not set<br>
&gt; # CONFIG_CXL_LIB is not set<br>
&gt; # CONFIG_OCXL_BASE is not set<br>
&gt; # CONFIG_MISC_RTSX_PCI is not set<br>
&gt; # CONFIG_MISC_RTSX_USB is not set<br>
&gt; CONFIG_HAVE_IDE=3Dy<br>
&gt; # CONFIG_IDE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # SCSI device support<br>
&gt; #<br>
&gt; CONFIG_SCSI_MOD=3Dy<br>
&gt; # CONFIG_RAID_ATTRS is not set<br>
&gt; CONFIG_SCSI=3Dy<br>
&gt; CONFIG_SCSI_DMA=3Dy<br>
&gt; # CONFIG_SCSI_NETLINK is not set<br>
&gt; # CONFIG_SCSI_MQ_DEFAULT is not set<br>
&gt; CONFIG_SCSI_PROC_FS=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # SCSI support type (disk, tape, CD-ROM)<br>
&gt; #<br>
&gt; CONFIG_BLK_DEV_SD=3Dy<br>
&gt; # CONFIG_CHR_DEV_ST is not set<br>
&gt; # CONFIG_CHR_DEV_OSST is not set<br>
&gt; CONFIG_BLK_DEV_SR=3Dy<br>
&gt; CONFIG_BLK_DEV_SR_VENDOR=3Dy<br>
&gt; CONFIG_CHR_DEV_SG=3Dy<br>
&gt; # CONFIG_CHR_DEV_SCH is not set<br>
&gt; CONFIG_SCSI_CONSTANTS=3Dy<br>
&gt; # CONFIG_SCSI_LOGGING is not set<br>
&gt; # CONFIG_SCSI_SCAN_ASYNC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # SCSI Transports<br>
&gt; #<br>
&gt; CONFIG_SCSI_SPI_ATTRS=3Dy<br>
&gt; # CONFIG_SCSI_FC_ATTRS is not set<br>
&gt; CONFIG_SCSI_ISCSI_ATTRS=3Dy<br>
&gt; # CONFIG_SCSI_SAS_ATTRS is not set<br>
&gt; # CONFIG_SCSI_SAS_LIBSAS is not set<br>
&gt; CONFIG_SCSI_SRP_ATTRS=3Dy<br>
&gt; CONFIG_SCSI_LOWLEVEL=3Dy<br>
&gt; # CONFIG_ISCSI_TCP is not set<br>
&gt; # CONFIG_ISCSI_BOOT_SYSFS is not set<br>
&gt; # CONFIG_SCSI_CXGB3_ISCSI is not set<br>
&gt; # CONFIG_SCSI_CXGB4_ISCSI is not set<br>
&gt; # CONFIG_SCSI_BNX2_ISCSI is not set<br>
&gt; # CONFIG_BE2ISCSI is not set<br>
&gt; # CONFIG_BLK_DEV_3W_XXXX_RAID is not set<br>
&gt; # CONFIG_SCSI_HPSA is not set<br>
&gt; # CONFIG_SCSI_3W_9XXX is not set<br>
&gt; # CONFIG_SCSI_3W_SAS is not set<br>
&gt; # CONFIG_SCSI_ACARD is not set<br>
&gt; # CONFIG_SCSI_AACRAID is not set<br>
&gt; # CONFIG_SCSI_AIC7XXX is not set<br>
&gt; # CONFIG_SCSI_AIC79XX is not set<br>
&gt; # CONFIG_SCSI_AIC94XX is not set<br>
&gt; # CONFIG_SCSI_MVSAS is not set<br>
&gt; # CONFIG_SCSI_MVUMI is not set<br>
&gt; # CONFIG_SCSI_DPT_I2O is not set<br>
&gt; # CONFIG_SCSI_ADVANSYS is not set<br>
&gt; # CONFIG_SCSI_ARCMSR is not set<br>
&gt; # CONFIG_SCSI_ESAS2R is not set<br>
&gt; # CONFIG_MEGARAID_NEWGEN is not set<br>
&gt; # CONFIG_MEGARAID_LEGACY is not set<br>
&gt; # CONFIG_MEGARAID_SAS is not set<br>
&gt; # CONFIG_SCSI_MPT3SAS is not set<br>
&gt; # CONFIG_SCSI_MPT2SAS is not set<br>
&gt; # CONFIG_SCSI_SMARTPQI is not set<br>
&gt; # CONFIG_SCSI_UFSHCD is not set<br>
&gt; # CONFIG_SCSI_HPTIOP is not set<br>
&gt; # CONFIG_SCSI_BUSLOGIC is not set<br>
&gt; # CONFIG_VMWARE_PVSCSI is not set<br>
&gt; # CONFIG_XEN_SCSI_FRONTEND is not set<br>
&gt; # CONFIG_SCSI_SNIC is not set<br>
&gt; # CONFIG_SCSI_DMX3191D is not set<br>
&gt; # CONFIG_SCSI_EATA is not set<br>
&gt; # CONFIG_SCSI_FUTURE_DOMAIN is not set<br>
&gt; # CONFIG_SCSI_GDTH is not set<br>
&gt; # CONFIG_SCSI_ISCI is not set<br>
&gt; # CONFIG_SCSI_IPS is not set<br>
&gt; # CONFIG_SCSI_INITIO is not set<br>
&gt; # CONFIG_SCSI_INIA100 is not set<br>
&gt; # CONFIG_SCSI_STEX is not set<br>
&gt; # CONFIG_SCSI_SYM53C8XX_2 is not set<br>
&gt; # CONFIG_SCSI_IPR is not set<br>
&gt; # CONFIG_SCSI_QLOGIC_1280 is not set<br>
&gt; # CONFIG_SCSI_QLA_ISCSI is not set<br>
&gt; # CONFIG_SCSI_DC395x is not set<br>
&gt; # CONFIG_SCSI_AM53C974 is not set<br>
&gt; # CONFIG_SCSI_WD719X is not set<br>
&gt; # CONFIG_SCSI_DEBUG is not set<br>
&gt; # CONFIG_SCSI_PMCRAID is not set<br>
&gt; # CONFIG_SCSI_PM8001 is not set<br>
&gt; CONFIG_SCSI_VIRTIO=3Dy<br>
&gt; # CONFIG_SCSI_LOWLEVEL_PCMCIA is not set<br>
&gt; # CONFIG_SCSI_DH is not set<br>
&gt; # CONFIG_SCSI_OSD_INITIATOR is not set<br>
&gt; CONFIG_ATA=3Dy<br>
&gt; # CONFIG_ATA_NONSTANDARD is not set<br>
&gt; CONFIG_ATA_VERBOSE_ERROR=3Dy<br>
&gt; CONFIG_ATA_ACPI=3Dy<br>
&gt; # CONFIG_SATA_ZPODD is not set<br>
&gt; CONFIG_SATA_PMP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Controllers with non-SFF native interface<br>
&gt; #<br>
&gt; CONFIG_SATA_AHCI=3Dy<br>
&gt; CONFIG_SATA_MOBILE_LPM_POLICY=3D<wbr>0<br>
&gt; # CONFIG_SATA_AHCI_PLATFORM is not set<br>
&gt; # CONFIG_SATA_INIC162X is not set<br>
&gt; # CONFIG_SATA_ACARD_AHCI is not set<br>
&gt; # CONFIG_SATA_SIL24 is not set<br>
&gt; CONFIG_ATA_SFF=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # SFF controllers with custom DMA interface<br>
&gt; #<br>
&gt; # CONFIG_PDC_ADMA is not set<br>
&gt; # CONFIG_SATA_QSTOR is not set<br>
&gt; # CONFIG_SATA_SX4 is not set<br>
&gt; CONFIG_ATA_BMDMA=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # SATA SFF controllers with BMDMA<br>
&gt; #<br>
&gt; CONFIG_ATA_PIIX=3Dy<br>
&gt; # CONFIG_SATA_DWC is not set<br>
&gt; # CONFIG_SATA_MV is not set<br>
&gt; # CONFIG_SATA_NV is not set<br>
&gt; # CONFIG_SATA_PROMISE is not set<br>
&gt; # CONFIG_SATA_SIL is not set<br>
&gt; # CONFIG_SATA_SIS is not set<br>
&gt; # CONFIG_SATA_SVW is not set<br>
&gt; # CONFIG_SATA_ULI is not set<br>
&gt; # CONFIG_SATA_VIA is not set<br>
&gt; # CONFIG_SATA_VITESSE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PATA SFF controllers with BMDMA<br>
&gt; #<br>
&gt; # CONFIG_PATA_ALI is not set<br>
&gt; CONFIG_PATA_AMD=3Dy<br>
&gt; # CONFIG_PATA_ARTOP is not set<br>
&gt; # CONFIG_PATA_ATIIXP is not set<br>
&gt; # CONFIG_PATA_ATP867X is not set<br>
&gt; # CONFIG_PATA_CMD64X is not set<br>
&gt; # CONFIG_PATA_CYPRESS is not set<br>
&gt; # CONFIG_PATA_EFAR is not set<br>
&gt; # CONFIG_PATA_HPT366 is not set<br>
&gt; # CONFIG_PATA_HPT37X is not set<br>
&gt; # CONFIG_PATA_HPT3X2N is not set<br>
&gt; # CONFIG_PATA_HPT3X3 is not set<br>
&gt; # CONFIG_PATA_IT8213 is not set<br>
&gt; # CONFIG_PATA_IT821X is not set<br>
&gt; # CONFIG_PATA_JMICRON is not set<br>
&gt; # CONFIG_PATA_MARVELL is not set<br>
&gt; # CONFIG_PATA_NETCELL is not set<br>
&gt; # CONFIG_PATA_NINJA32 is not set<br>
&gt; # CONFIG_PATA_NS87415 is not set<br>
&gt; CONFIG_PATA_OLDPIIX=3Dy<br>
&gt; # CONFIG_PATA_OPTIDMA is not set<br>
&gt; # CONFIG_PATA_PDC2027X is not set<br>
&gt; # CONFIG_PATA_PDC_OLD is not set<br>
&gt; # CONFIG_PATA_RADISYS is not set<br>
&gt; # CONFIG_PATA_RDC is not set<br>
&gt; CONFIG_PATA_SCH=3Dy<br>
&gt; # CONFIG_PATA_SERVERWORKS is not set<br>
&gt; # CONFIG_PATA_SIL680 is not set<br>
&gt; # CONFIG_PATA_SIS is not set<br>
&gt; # CONFIG_PATA_TOSHIBA is not set<br>
&gt; # CONFIG_PATA_TRIFLEX is not set<br>
&gt; # CONFIG_PATA_VIA is not set<br>
&gt; # CONFIG_PATA_WINBOND is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PIO-only SFF controllers<br>
&gt; #<br>
&gt; # CONFIG_PATA_CMD640_PCI is not set<br>
&gt; # CONFIG_PATA_MPIIX is not set<br>
&gt; # CONFIG_PATA_NS87410 is not set<br>
&gt; # CONFIG_PATA_OPTI is not set<br>
&gt; # CONFIG_PATA_PCMCIA is not set<br>
&gt; # CONFIG_PATA_PLATFORM is not set<br>
&gt; # CONFIG_PATA_RZ1000 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Generic fallback / legacy drivers<br>
&gt; #<br>
&gt; # CONFIG_PATA_ACPI is not set<br>
&gt; # CONFIG_ATA_GENERIC is not set<br>
&gt; # CONFIG_PATA_LEGACY is not set<br>
&gt; CONFIG_MD=3Dy<br>
&gt; CONFIG_BLK_DEV_MD=3Dy<br>
&gt; CONFIG_MD_AUTODETECT=3Dy<br>
&gt; # CONFIG_MD_LINEAR is not set<br>
&gt; # CONFIG_MD_RAID0 is not set<br>
&gt; # CONFIG_MD_RAID1 is not set<br>
&gt; # CONFIG_MD_RAID10 is not set<br>
&gt; # CONFIG_MD_RAID456 is not set<br>
&gt; # CONFIG_MD_MULTIPATH is not set<br>
&gt; # CONFIG_MD_FAULTY is not set<br>
&gt; # CONFIG_BCACHE is not set<br>
&gt; CONFIG_BLK_DEV_DM_BUILTIN=3Dy<br>
&gt; CONFIG_BLK_DEV_DM=3Dy<br>
&gt; # CONFIG_DM_MQ_DEFAULT is not set<br>
&gt; # CONFIG_DM_DEBUG is not set<br>
&gt; # CONFIG_DM_UNSTRIPED is not set<br>
&gt; # CONFIG_DM_CRYPT is not set<br>
&gt; # CONFIG_DM_SNAPSHOT is not set<br>
&gt; # CONFIG_DM_THIN_PROVISIONING is not set<br>
&gt; # CONFIG_DM_CACHE is not set<br>
&gt; # CONFIG_DM_ERA is not set<br>
&gt; CONFIG_DM_MIRROR=3Dy<br>
&gt; # CONFIG_DM_LOG_USERSPACE is not set<br>
&gt; # CONFIG_DM_RAID is not set<br>
&gt; CONFIG_DM_ZERO=3Dy<br>
&gt; # CONFIG_DM_MULTIPATH is not set<br>
&gt; # CONFIG_DM_DELAY is not set<br>
&gt; # CONFIG_DM_UEVENT is not set<br>
&gt; # CONFIG_DM_FLAKEY is not set<br>
&gt; # CONFIG_DM_VERITY is not set<br>
&gt; # CONFIG_DM_SWITCH is not set<br>
&gt; # CONFIG_DM_LOG_WRITES is not set<br>
&gt; # CONFIG_DM_INTEGRITY is not set<br>
&gt; # CONFIG_DM_ZONED is not set<br>
&gt; # CONFIG_TARGET_CORE is not set<br>
&gt; # CONFIG_FUSION is not set<br>
&gt;<br>
&gt; #<br>
&gt; # IEEE 1394 (FireWire) support<br>
&gt; #<br>
&gt; # CONFIG_FIREWIRE is not set<br>
&gt; # CONFIG_FIREWIRE_NOSY is not set<br>
&gt; CONFIG_MACINTOSH_DRIVERS=3Dy<br>
&gt; CONFIG_MAC_EMUMOUSEBTN=3Dy<br>
&gt; CONFIG_NETDEVICES=3Dy<br>
&gt; CONFIG_MII=3Dy<br>
&gt; CONFIG_NET_CORE=3Dy<br>
&gt; CONFIG_BONDING=3Dy<br>
&gt; # CONFIG_DUMMY is not set<br>
&gt; CONFIG_EQUALIZER=3Dy<br>
&gt; # CONFIG_NET_FC is not set<br>
&gt; # CONFIG_IFB is not set<br>
&gt; # CONFIG_NET_TEAM is not set<br>
&gt; # CONFIG_MACVLAN is not set<br>
&gt; # CONFIG_IPVLAN is not set<br>
&gt; # CONFIG_VXLAN is not set<br>
&gt; # CONFIG_GENEVE is not set<br>
&gt; # CONFIG_GTP is not set<br>
&gt; # CONFIG_MACSEC is not set<br>
&gt; CONFIG_NETCONSOLE=3Dy<br>
&gt; # CONFIG_NETCONSOLE_DYNAMIC is not set<br>
&gt; CONFIG_NETPOLL=3Dy<br>
&gt; CONFIG_NET_POLL_CONTROLLER=3Dy<br>
&gt; CONFIG_TUN=3Dy<br>
&gt; # CONFIG_TUN_VNET_CROSS_LE is not set<br>
&gt; CONFIG_VETH=3Dy<br>
&gt; CONFIG_VIRTIO_NET=3Dy<br>
&gt; # CONFIG_NLMON is not set<br>
&gt; # CONFIG_NET_VRF is not set<br>
&gt; # CONFIG_VSOCKMON is not set<br>
&gt; # CONFIG_ARCNET is not set<br>
&gt; CONFIG_ATM_DRIVERS=3Dy<br>
&gt; # CONFIG_ATM_DUMMY is not set<br>
&gt; CONFIG_ATM_TCP=3Dy<br>
&gt; # CONFIG_ATM_LANAI is not set<br>
&gt; # CONFIG_ATM_ENI is not set<br>
&gt; # CONFIG_ATM_FIRESTREAM is not set<br>
&gt; # CONFIG_ATM_ZATM is not set<br>
&gt; # CONFIG_ATM_NICSTAR is not set<br>
&gt; # CONFIG_ATM_IDT77252 is not set<br>
&gt; # CONFIG_ATM_AMBASSADOR is not set<br>
&gt; # CONFIG_ATM_HORIZON is not set<br>
&gt; # CONFIG_ATM_IA is not set<br>
&gt; # CONFIG_ATM_FORE200E is not set<br>
&gt; # CONFIG_ATM_HE is not set<br>
&gt; # CONFIG_ATM_SOLOS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CAIF transport drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Distributed Switch Architecture drivers<br>
&gt; #<br>
&gt; # CONFIG_B53 is not set<br>
&gt; # CONFIG_NET_DSA_LOOP is not set<br>
&gt; # CONFIG_NET_DSA_MT7530 is not set<br>
&gt; # CONFIG_NET_DSA_MV88E6060 is not set<br>
&gt; # CONFIG_MICROCHIP_KSZ is not set<br>
&gt; # CONFIG_NET_DSA_MV88E6XXX is not set<br>
&gt; # CONFIG_NET_DSA_QCA8K is not set<br>
&gt; # CONFIG_NET_DSA_SMSC_LAN9303_<wbr>I2C is not set<br>
&gt; # CONFIG_NET_DSA_SMSC_LAN9303_<wbr>MDIO is not set<br>
&gt; CONFIG_ETHERNET=3Dy<br>
&gt; CONFIG_NET_VENDOR_3COM=3Dy<br>
&gt; # CONFIG_PCMCIA_3C574 is not set<br>
&gt; # CONFIG_PCMCIA_3C589 is not set<br>
&gt; # CONFIG_VORTEX is not set<br>
&gt; # CONFIG_TYPHOON is not set<br>
&gt; CONFIG_NET_VENDOR_ADAPTEC=3Dy<br>
&gt; # CONFIG_ADAPTEC_STARFIRE is not set<br>
&gt; CONFIG_NET_VENDOR_AGERE=3Dy<br>
&gt; # CONFIG_ET131X is not set<br>
&gt; CONFIG_NET_VENDOR_ALACRITECH=3Dy<br>
&gt; # CONFIG_SLICOSS is not set<br>
&gt; CONFIG_NET_VENDOR_ALTEON=3Dy<br>
&gt; # CONFIG_ACENIC is not set<br>
&gt; # CONFIG_ALTERA_TSE is not set<br>
&gt; CONFIG_NET_VENDOR_AMAZON=3Dy<br>
&gt; # CONFIG_ENA_ETHERNET is not set<br>
&gt; CONFIG_NET_VENDOR_AMD=3Dy<br>
&gt; # CONFIG_AMD8111_ETH is not set<br>
&gt; # CONFIG_PCNET32 is not set<br>
&gt; # CONFIG_PCMCIA_NMCLAN is not set<br>
&gt; # CONFIG_AMD_XGBE is not set<br>
&gt; # CONFIG_AMD_XGBE_HAVE_ECC is not set<br>
&gt; # CONFIG_NET_VENDOR_AQUANTIA is not set<br>
&gt; CONFIG_NET_VENDOR_ARC=3Dy<br>
&gt; CONFIG_NET_VENDOR_ATHEROS=3Dy<br>
&gt; # CONFIG_ATL2 is not set<br>
&gt; # CONFIG_ATL1 is not set<br>
&gt; # CONFIG_ATL1E is not set<br>
&gt; # CONFIG_ATL1C is not set<br>
&gt; # CONFIG_ALX is not set<br>
&gt; # CONFIG_NET_VENDOR_AURORA is not set<br>
&gt; CONFIG_NET_CADENCE=3Dy<br>
&gt; # CONFIG_MACB is not set<br>
&gt; CONFIG_NET_VENDOR_BROADCOM=3Dy<br>
&gt; # CONFIG_B44 is not set<br>
&gt; # CONFIG_BNX2 is not set<br>
&gt; # CONFIG_CNIC is not set<br>
&gt; CONFIG_TIGON3=3Dy<br>
&gt; CONFIG_TIGON3_HWMON=3Dy<br>
&gt; # CONFIG_BNX2X is not set<br>
&gt; # CONFIG_BNXT is not set<br>
&gt; CONFIG_NET_VENDOR_BROCADE=3Dy<br>
&gt; # CONFIG_BNA is not set<br>
&gt; CONFIG_NET_VENDOR_CAVIUM=3Dy<br>
&gt; # CONFIG_THUNDER_NIC_PF is not set<br>
&gt; # CONFIG_THUNDER_NIC_VF is not set<br>
&gt; # CONFIG_THUNDER_NIC_BGX is not set<br>
&gt; # CONFIG_THUNDER_NIC_RGX is not set<br>
&gt; # CONFIG_CAVIUM_PTP is not set<br>
&gt; # CONFIG_LIQUIDIO is not set<br>
&gt; # CONFIG_LIQUIDIO_VF is not set<br>
&gt; CONFIG_NET_VENDOR_CHELSIO=3Dy<br>
&gt; # CONFIG_CHELSIO_T1 is not set<br>
&gt; # CONFIG_CHELSIO_T3 is not set<br>
&gt; # CONFIG_CHELSIO_T4 is not set<br>
&gt; # CONFIG_CHELSIO_T4VF is not set<br>
&gt; CONFIG_NET_VENDOR_CISCO=3Dy<br>
&gt; CONFIG_ENIC=3Dy<br>
&gt; # CONFIG_NET_VENDOR_CORTINA is not set<br>
&gt; # CONFIG_CX_ECAT is not set<br>
&gt; # CONFIG_DNET is not set<br>
&gt; CONFIG_NET_VENDOR_DEC=3Dy<br>
&gt; CONFIG_NET_TULIP=3Dy<br>
&gt; # CONFIG_DE2104X is not set<br>
&gt; # CONFIG_TULIP is not set<br>
&gt; # CONFIG_DE4X5 is not set<br>
&gt; # CONFIG_WINBOND_840 is not set<br>
&gt; # CONFIG_DM9102 is not set<br>
&gt; # CONFIG_ULI526X is not set<br>
&gt; # CONFIG_PCMCIA_XIRCOM is not set<br>
&gt; CONFIG_NET_VENDOR_DLINK=3Dy<br>
&gt; # CONFIG_DL2K is not set<br>
&gt; # CONFIG_SUNDANCE is not set<br>
&gt; CONFIG_NET_VENDOR_EMULEX=3Dy<br>
&gt; # CONFIG_BE2NET is not set<br>
&gt; CONFIG_NET_VENDOR_EZCHIP=3Dy<br>
&gt; CONFIG_NET_VENDOR_EXAR=3Dy<br>
&gt; # CONFIG_S2IO is not set<br>
&gt; # CONFIG_VXGE is not set<br>
&gt; CONFIG_NET_VENDOR_FUJITSU=3Dy<br>
&gt; # CONFIG_PCMCIA_FMVJ18X is not set<br>
&gt; CONFIG_NET_VENDOR_HP=3Dy<br>
&gt; # CONFIG_HP100 is not set<br>
&gt; # CONFIG_NET_VENDOR_HUAWEI is not set<br>
&gt; CONFIG_NET_VENDOR_INTEL=3Dy<br>
&gt; CONFIG_E100=3Dy<br>
&gt; CONFIG_E1000=3Dy<br>
&gt; CONFIG_E1000E=3Dy<br>
&gt; CONFIG_E1000E_HWTS=3Dy<br>
&gt; # CONFIG_IGB is not set<br>
&gt; # CONFIG_IGBVF is not set<br>
&gt; # CONFIG_IXGB is not set<br>
&gt; # CONFIG_IXGBE is not set<br>
&gt; # CONFIG_IXGBEVF is not set<br>
&gt; # CONFIG_I40E is not set<br>
&gt; # CONFIG_I40EVF is not set<br>
&gt; # CONFIG_FM10K is not set<br>
&gt; CONFIG_NET_VENDOR_I825XX=3Dy<br>
&gt; # CONFIG_JME is not set<br>
&gt; CONFIG_NET_VENDOR_MARVELL=3Dy<br>
&gt; # CONFIG_MVMDIO is not set<br>
&gt; # CONFIG_SKGE is not set<br>
&gt; CONFIG_SKY2=3Dy<br>
&gt; # CONFIG_SKY2_DEBUG is not set<br>
&gt; CONFIG_NET_VENDOR_MELLANOX=3Dy<br>
&gt; # CONFIG_MLX4_EN is not set<br>
&gt; # CONFIG_MLX4_CORE is not set<br>
&gt; # CONFIG_MLX5_CORE is not set<br>
&gt; # CONFIG_MLXSW_CORE is not set<br>
&gt; # CONFIG_MLXFW is not set<br>
&gt; CONFIG_NET_VENDOR_MICREL=3Dy<br>
&gt; # CONFIG_KS8842 is not set<br>
&gt; # CONFIG_KS8851_MLL is not set<br>
&gt; # CONFIG_KSZ884X_PCI is not set<br>
&gt; CONFIG_NET_VENDOR_MYRI=3Dy<br>
&gt; # CONFIG_MYRI10GE is not set<br>
&gt; # CONFIG_FEALNX is not set<br>
&gt; CONFIG_NET_VENDOR_NATSEMI=3Dy<br>
&gt; # CONFIG_NATSEMI is not set<br>
&gt; # CONFIG_NS83820 is not set<br>
&gt; CONFIG_NET_VENDOR_NETRONOME=3Dy<br>
&gt; # CONFIG_NFP is not set<br>
&gt; CONFIG_NET_VENDOR_8390=3Dy<br>
&gt; # CONFIG_PCMCIA_AXNET is not set<br>
&gt; # CONFIG_NE2K_PCI is not set<br>
&gt; # CONFIG_PCMCIA_PCNET is not set<br>
&gt; CONFIG_NET_VENDOR_NVIDIA=3Dy<br>
&gt; CONFIG_FORCEDETH=3Dy<br>
&gt; CONFIG_NET_VENDOR_OKI=3Dy<br>
&gt; # CONFIG_ETHOC is not set<br>
&gt; CONFIG_NET_PACKET_ENGINE=3Dy<br>
&gt; # CONFIG_HAMACHI is not set<br>
&gt; # CONFIG_YELLOWFIN is not set<br>
&gt; CONFIG_NET_VENDOR_QLOGIC=3Dy<br>
&gt; # CONFIG_QLA3XXX is not set<br>
&gt; # CONFIG_QLCNIC is not set<br>
&gt; # CONFIG_QLGE is not set<br>
&gt; # CONFIG_NETXEN_NIC is not set<br>
&gt; # CONFIG_QED is not set<br>
&gt; CONFIG_NET_VENDOR_QUALCOMM=3Dy<br>
&gt; # CONFIG_QCOM_EMAC is not set<br>
&gt; # CONFIG_RMNET is not set<br>
&gt; CONFIG_NET_VENDOR_REALTEK=3Dy<br>
&gt; # CONFIG_8139CP is not set<br>
&gt; CONFIG_8139TOO=3Dy<br>
&gt; CONFIG_8139TOO_PIO=3Dy<br>
&gt; # CONFIG_8139TOO_TUNE_TWISTER is not set<br>
&gt; # CONFIG_8139TOO_8129 is not set<br>
&gt; # CONFIG_8139_OLD_RX_RESET is not set<br>
&gt; # CONFIG_R8169 is not set<br>
&gt; CONFIG_NET_VENDOR_RENESAS=3Dy<br>
&gt; CONFIG_NET_VENDOR_RDC=3Dy<br>
&gt; # CONFIG_R6040 is not set<br>
&gt; CONFIG_NET_VENDOR_ROCKER=3Dy<br>
&gt; # CONFIG_ROCKER is not set<br>
&gt; CONFIG_NET_VENDOR_SAMSUNG=3Dy<br>
&gt; # CONFIG_SXGBE_ETH is not set<br>
&gt; CONFIG_NET_VENDOR_SEEQ=3Dy<br>
&gt; CONFIG_NET_VENDOR_SILAN=3Dy<br>
&gt; # CONFIG_SC92031 is not set<br>
&gt; CONFIG_NET_VENDOR_SIS=3Dy<br>
&gt; # CONFIG_SIS900 is not set<br>
&gt; # CONFIG_SIS190 is not set<br>
&gt; # CONFIG_NET_VENDOR_SOLARFLARE is not set<br>
&gt; CONFIG_NET_VENDOR_SMSC=3Dy<br>
&gt; # CONFIG_PCMCIA_SMC91C92 is not set<br>
&gt; # CONFIG_EPIC100 is not set<br>
&gt; # CONFIG_SMSC911X is not set<br>
&gt; # CONFIG_SMSC9420 is not set<br>
&gt; # CONFIG_NET_VENDOR_SOCIONEXT is not set<br>
&gt; CONFIG_NET_VENDOR_STMICRO=3Dy<br>
&gt; # CONFIG_STMMAC_ETH is not set<br>
&gt; CONFIG_NET_VENDOR_SUN=3Dy<br>
&gt; # CONFIG_HAPPYMEAL is not set<br>
&gt; # CONFIG_SUNGEM is not set<br>
&gt; # CONFIG_CASSINI is not set<br>
&gt; # CONFIG_NIU is not set<br>
&gt; CONFIG_NET_VENDOR_TEHUTI=3Dy<br>
&gt; # CONFIG_TEHUTI is not set<br>
&gt; CONFIG_NET_VENDOR_TI=3Dy<br>
&gt; # CONFIG_TI_CPSW_ALE is not set<br>
&gt; # CONFIG_TLAN is not set<br>
&gt; CONFIG_NET_VENDOR_VIA=3Dy<br>
&gt; # CONFIG_VIA_RHINE is not set<br>
&gt; # CONFIG_VIA_VELOCITY is not set<br>
&gt; CONFIG_NET_VENDOR_WIZNET=3Dy<br>
&gt; # CONFIG_WIZNET_W5100 is not set<br>
&gt; # CONFIG_WIZNET_W5300 is not set<br>
&gt; CONFIG_NET_VENDOR_XIRCOM=3Dy<br>
&gt; # CONFIG_PCMCIA_XIRC2PS is not set<br>
&gt; CONFIG_NET_VENDOR_SYNOPSYS=3Dy<br>
&gt; # CONFIG_DWC_XLGMAC is not set<br>
&gt; CONFIG_FDDI=3Dy<br>
&gt; # CONFIG_DEFXX is not set<br>
&gt; # CONFIG_SKFP is not set<br>
&gt; # CONFIG_HIPPI is not set<br>
&gt; # CONFIG_NET_SB1000 is not set<br>
&gt; CONFIG_MDIO_DEVICE=3Dy<br>
&gt; CONFIG_MDIO_BUS=3Dy<br>
&gt; # CONFIG_MDIO_BITBANG is not set<br>
&gt; # CONFIG_MDIO_THUNDER is not set<br>
&gt; CONFIG_PHYLIB=3Dy<br>
&gt; # CONFIG_LED_TRIGGER_PHY is not set<br>
&gt;<br>
&gt; #<br>
&gt; # MII PHY device drivers<br>
&gt; #<br>
&gt; # CONFIG_AMD_PHY is not set<br>
&gt; # CONFIG_AQUANTIA_PHY is not set<br>
&gt; # CONFIG_AT803X_PHY is not set<br>
&gt; # CONFIG_BCM7XXX_PHY is not set<br>
&gt; # CONFIG_BCM87XX_PHY is not set<br>
&gt; # CONFIG_BROADCOM_PHY is not set<br>
&gt; # CONFIG_CICADA_PHY is not set<br>
&gt; # CONFIG_CORTINA_PHY is not set<br>
&gt; # CONFIG_DAVICOM_PHY is not set<br>
&gt; # CONFIG_DP83822_PHY is not set<br>
&gt; # CONFIG_DP83848_PHY is not set<br>
&gt; # CONFIG_DP83867_PHY is not set<br>
&gt; # CONFIG_FIXED_PHY is not set<br>
&gt; # CONFIG_ICPLUS_PHY is not set<br>
&gt; # CONFIG_INTEL_XWAY_PHY is not set<br>
&gt; # CONFIG_LSI_ET1011C_PHY is not set<br>
&gt; # CONFIG_LXT_PHY is not set<br>
&gt; # CONFIG_MARVELL_PHY is not set<br>
&gt; # CONFIG_MARVELL_10G_PHY is not set<br>
&gt; # CONFIG_MICREL_PHY is not set<br>
&gt; # CONFIG_MICROCHIP_PHY is not set<br>
&gt; # CONFIG_MICROSEMI_PHY is not set<br>
&gt; # CONFIG_NATIONAL_PHY is not set<br>
&gt; # CONFIG_QSEMI_PHY is not set<br>
&gt; # CONFIG_REALTEK_PHY is not set<br>
&gt; # CONFIG_RENESAS_PHY is not set<br>
&gt; # CONFIG_ROCKCHIP_PHY is not set<br>
&gt; # CONFIG_SMSC_PHY is not set<br>
&gt; # CONFIG_STE10XP is not set<br>
&gt; # CONFIG_TERANETICS_PHY is not set<br>
&gt; # CONFIG_VITESSE_PHY is not set<br>
&gt; # CONFIG_XILINX_GMII2RGMII is not set<br>
&gt; CONFIG_PPP=3Dy<br>
&gt; CONFIG_PPP_BSDCOMP=3Dy<br>
&gt; CONFIG_PPP_DEFLATE=3Dy<br>
&gt; CONFIG_PPP_FILTER=3Dy<br>
&gt; # CONFIG_PPP_MPPE is not set<br>
&gt; # CONFIG_PPP_MULTILINK is not set<br>
&gt; # CONFIG_PPPOATM is not set<br>
&gt; CONFIG_PPPOE=3Dy<br>
&gt; CONFIG_PPTP=3Dy<br>
&gt; CONFIG_PPPOL2TP=3Dy<br>
&gt; CONFIG_PPP_ASYNC=3Dy<br>
&gt; # CONFIG_PPP_SYNC_TTY is not set<br>
&gt; # CONFIG_SLIP is not set<br>
&gt; CONFIG_SLHC=3Dy<br>
&gt; CONFIG_USB_NET_DRIVERS=3Dy<br>
&gt; # CONFIG_USB_CATC is not set<br>
&gt; # CONFIG_USB_KAWETH is not set<br>
&gt; # CONFIG_USB_PEGASUS is not set<br>
&gt; # CONFIG_USB_RTL8150 is not set<br>
&gt; # CONFIG_USB_RTL8152 is not set<br>
&gt; # CONFIG_USB_LAN78XX is not set<br>
&gt; # CONFIG_USB_USBNET is not set<br>
&gt; # CONFIG_USB_HSO is not set<br>
&gt; # CONFIG_USB_IPHETH is not set<br>
&gt; CONFIG_WLAN=3Dy<br>
&gt; # CONFIG_WIRELESS_WDS is not set<br>
&gt; CONFIG_WLAN_VENDOR_ADMTEK=3Dy<br>
&gt; # CONFIG_ADM8211 is not set<br>
&gt; CONFIG_WLAN_VENDOR_ATH=3Dy<br>
&gt; # CONFIG_ATH_DEBUG is not set<br>
&gt; # CONFIG_ATH5K is not set<br>
&gt; # CONFIG_ATH5K_PCI is not set<br>
&gt; # CONFIG_ATH9K is not set<br>
&gt; # CONFIG_ATH9K_HTC is not set<br>
&gt; # CONFIG_CARL9170 is not set<br>
&gt; # CONFIG_ATH6KL is not set<br>
&gt; # CONFIG_AR5523 is not set<br>
&gt; # CONFIG_WIL6210 is not set<br>
&gt; # CONFIG_ATH10K is not set<br>
&gt; # CONFIG_WCN36XX is not set<br>
&gt; CONFIG_WLAN_VENDOR_ATMEL=3Dy<br>
&gt; # CONFIG_ATMEL is not set<br>
&gt; # CONFIG_AT76C50X_USB is not set<br>
&gt; CONFIG_WLAN_VENDOR_BROADCOM=3Dy<br>
&gt; # CONFIG_B43 is not set<br>
&gt; # CONFIG_B43LEGACY is not set<br>
&gt; # CONFIG_BRCMSMAC is not set<br>
&gt; # CONFIG_BRCMFMAC is not set<br>
&gt; CONFIG_WLAN_VENDOR_CISCO=3Dy<br>
&gt; # CONFIG_AIRO is not set<br>
&gt; # CONFIG_AIRO_CS is not set<br>
&gt; CONFIG_WLAN_VENDOR_INTEL=3Dy<br>
&gt; # CONFIG_IPW2100 is not set<br>
&gt; # CONFIG_IPW2200 is not set<br>
&gt; # CONFIG_IWL4965 is not set<br>
&gt; # CONFIG_IWL3945 is not set<br>
&gt; # CONFIG_IWLWIFI is not set<br>
&gt; CONFIG_WLAN_VENDOR_INTERSIL=3Dy<br>
&gt; # CONFIG_HOSTAP is not set<br>
&gt; # CONFIG_HERMES is not set<br>
&gt; # CONFIG_P54_COMMON is not set<br>
&gt; # CONFIG_PRISM54 is not set<br>
&gt; CONFIG_WLAN_VENDOR_MARVELL=3Dy<br>
&gt; # CONFIG_LIBERTAS is not set<br>
&gt; # CONFIG_LIBERTAS_THINFIRM is not set<br>
&gt; # CONFIG_MWIFIEX is not set<br>
&gt; # CONFIG_MWL8K is not set<br>
&gt; CONFIG_WLAN_VENDOR_MEDIATEK=3Dy<br>
&gt; # CONFIG_MT7601U is not set<br>
&gt; # CONFIG_MT76x2E is not set<br>
&gt; CONFIG_WLAN_VENDOR_RALINK=3Dy<br>
&gt; # CONFIG_RT2X00 is not set<br>
&gt; CONFIG_WLAN_VENDOR_REALTEK=3Dy<br>
&gt; # CONFIG_RTL8180 is not set<br>
&gt; # CONFIG_RTL8187 is not set<br>
&gt; CONFIG_RTL_CARDS=3Dy<br>
&gt; # CONFIG_RTL8192CE is not set<br>
&gt; # CONFIG_RTL8192SE is not set<br>
&gt; # CONFIG_RTL8192DE is not set<br>
&gt; # CONFIG_RTL8723AE is not set<br>
&gt; # CONFIG_RTL8723BE is not set<br>
&gt; # CONFIG_RTL8188EE is not set<br>
&gt; # CONFIG_RTL8192EE is not set<br>
&gt; # CONFIG_RTL8821AE is not set<br>
&gt; # CONFIG_RTL8192CU is not set<br>
&gt; # CONFIG_RTL8XXXU is not set<br>
&gt; CONFIG_WLAN_VENDOR_RSI=3Dy<br>
&gt; # CONFIG_RSI_91X is not set<br>
&gt; CONFIG_WLAN_VENDOR_ST=3Dy<br>
&gt; # CONFIG_CW1200 is not set<br>
&gt; CONFIG_WLAN_VENDOR_TI=3Dy<br>
&gt; # CONFIG_WL1251 is not set<br>
&gt; # CONFIG_WL12XX is not set<br>
&gt; # CONFIG_WL18XX is not set<br>
&gt; # CONFIG_WLCORE is not set<br>
&gt; CONFIG_WLAN_VENDOR_ZYDAS=3Dy<br>
&gt; # CONFIG_USB_ZD1201 is not set<br>
&gt; # CONFIG_ZD1211RW is not set<br>
&gt; # CONFIG_WLAN_VENDOR_QUANTENNA is not set<br>
&gt; # CONFIG_PCMCIA_RAYCS is not set<br>
&gt; # CONFIG_PCMCIA_WL3501 is not set<br>
&gt; CONFIG_MAC80211_HWSIM=3Dy<br>
&gt; # CONFIG_USB_NET_RNDIS_WLAN is not set<br>
&gt;<br>
&gt; #<br>
&gt; # WiMAX Wireless Broadband devices<br>
&gt; #<br>
&gt; # CONFIG_WIMAX_I2400M_USB is not set<br>
&gt; # CONFIG_WAN is not set<br>
&gt; CONFIG_IEEE802154_DRIVERS=3Dy<br>
&gt; # CONFIG_IEEE802154_FAKELB is not set<br>
&gt; # CONFIG_IEEE802154_ATUSB is not set<br>
&gt; CONFIG_XEN_NETDEV_FRONTEND=3Dy<br>
&gt; # CONFIG_XEN_NETDEV_BACKEND is not set<br>
&gt; # CONFIG_VMXNET3 is not set<br>
&gt; # CONFIG_FUJITSU_ES is not set<br>
&gt; # CONFIG_NETDEVSIM is not set<br>
&gt; # CONFIG_ISDN is not set<br>
&gt; # CONFIG_NVM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Input device support<br>
&gt; #<br>
&gt; CONFIG_INPUT=3Dy<br>
&gt; CONFIG_INPUT_LEDS=3Dy<br>
&gt; CONFIG_INPUT_FF_MEMLESS=3Dy<br>
&gt; CONFIG_INPUT_POLLDEV=3Dy<br>
&gt; CONFIG_INPUT_SPARSEKMAP=3Dy<br>
&gt; # CONFIG_INPUT_MATRIXKMAP is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Userland interfaces<br>
&gt; #<br>
&gt; CONFIG_INPUT_MOUSEDEV=3Dy<br>
&gt; # CONFIG_INPUT_MOUSEDEV_PSAUX is not set<br>
&gt; CONFIG_INPUT_MOUSEDEV_SCREEN_<wbr>X=3D1024<br>
&gt; CONFIG_INPUT_MOUSEDEV_SCREEN_<wbr>Y=3D768<br>
&gt; # CONFIG_INPUT_JOYDEV is not set<br>
&gt; CONFIG_INPUT_EVDEV=3Dy<br>
&gt; # CONFIG_INPUT_EVBUG is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Input Device Drivers<br>
&gt; #<br>
&gt; CONFIG_INPUT_KEYBOARD=3Dy<br>
&gt; # CONFIG_KEYBOARD_ADP5588 is not set<br>
&gt; # CONFIG_KEYBOARD_ADP5589 is not set<br>
&gt; CONFIG_KEYBOARD_ATKBD=3Dy<br>
&gt; # CONFIG_KEYBOARD_QT1070 is not set<br>
&gt; # CONFIG_KEYBOARD_QT2160 is not set<br>
&gt; # CONFIG_KEYBOARD_DLINK_DIR685 is not set<br>
&gt; # CONFIG_KEYBOARD_LKKBD is not set<br>
&gt; # CONFIG_KEYBOARD_TCA6416 is not set<br>
&gt; # CONFIG_KEYBOARD_TCA8418 is not set<br>
&gt; # CONFIG_KEYBOARD_LM8323 is not set<br>
&gt; # CONFIG_KEYBOARD_LM8333 is not set<br>
&gt; # CONFIG_KEYBOARD_MAX7359 is not set<br>
&gt; # CONFIG_KEYBOARD_MCS is not set<br>
&gt; # CONFIG_KEYBOARD_MPR121 is not set<br>
&gt; # CONFIG_KEYBOARD_NEWTON is not set<br>
&gt; # CONFIG_KEYBOARD_OPENCORES is not set<br>
&gt; # CONFIG_KEYBOARD_SAMSUNG is not set<br>
&gt; # CONFIG_KEYBOARD_STOWAWAY is not set<br>
&gt; # CONFIG_KEYBOARD_SUNKBD is not set<br>
&gt; # CONFIG_KEYBOARD_TM2_TOUCHKEY is not set<br>
&gt; # CONFIG_KEYBOARD_XTKBD is not set<br>
&gt; CONFIG_INPUT_MOUSE=3Dy<br>
&gt; CONFIG_MOUSE_PS2=3Dy<br>
&gt; CONFIG_MOUSE_PS2_ALPS=3Dy<br>
&gt; CONFIG_MOUSE_PS2_BYD=3Dy<br>
&gt; CONFIG_MOUSE_PS2_LOGIPS2PP=3Dy<br>
&gt; CONFIG_MOUSE_PS2_SYNAPTICS=3Dy<br>
&gt; CONFIG_MOUSE_PS2_SYNAPTICS_<wbr>SMBUS=3Dy<br>
&gt; CONFIG_MOUSE_PS2_CYPRESS=3Dy<br>
&gt; CONFIG_MOUSE_PS2_LIFEBOOK=3Dy<br>
&gt; CONFIG_MOUSE_PS2_TRACKPOINT=3Dy<br>
&gt; # CONFIG_MOUSE_PS2_ELANTECH is not set<br>
&gt; # CONFIG_MOUSE_PS2_SENTELIC is not set<br>
&gt; # CONFIG_MOUSE_PS2_TOUCHKIT is not set<br>
&gt; CONFIG_MOUSE_PS2_FOCALTECH=3Dy<br>
&gt; # CONFIG_MOUSE_PS2_VMMOUSE is not set<br>
&gt; CONFIG_MOUSE_PS2_SMBUS=3Dy<br>
&gt; # CONFIG_MOUSE_SERIAL is not set<br>
&gt; # CONFIG_MOUSE_APPLETOUCH is not set<br>
&gt; # CONFIG_MOUSE_BCM5974 is not set<br>
&gt; # CONFIG_MOUSE_CYAPA is not set<br>
&gt; # CONFIG_MOUSE_ELAN_I2C is not set<br>
&gt; # CONFIG_MOUSE_VSXXXAA is not set<br>
&gt; # CONFIG_MOUSE_SYNAPTICS_I2C is not set<br>
&gt; # CONFIG_MOUSE_SYNAPTICS_USB is not set<br>
&gt; CONFIG_INPUT_JOYSTICK=3Dy<br>
&gt; # CONFIG_JOYSTICK_ANALOG is not set<br>
&gt; # CONFIG_JOYSTICK_A3D is not set<br>
&gt; # CONFIG_JOYSTICK_ADI is not set<br>
&gt; # CONFIG_JOYSTICK_COBRA is not set<br>
&gt; # CONFIG_JOYSTICK_GF2K is not set<br>
&gt; # CONFIG_JOYSTICK_GRIP is not set<br>
&gt; # CONFIG_JOYSTICK_GRIP_MP is not set<br>
&gt; # CONFIG_JOYSTICK_GUILLEMOT is not set<br>
&gt; # CONFIG_JOYSTICK_INTERACT is not set<br>
&gt; # CONFIG_JOYSTICK_SIDEWINDER is not set<br>
&gt; # CONFIG_JOYSTICK_TMDC is not set<br>
&gt; # CONFIG_JOYSTICK_IFORCE is not set<br>
&gt; # CONFIG_JOYSTICK_WARRIOR is not set<br>
&gt; # CONFIG_JOYSTICK_MAGELLAN is not set<br>
&gt; # CONFIG_JOYSTICK_SPACEORB is not set<br>
&gt; # CONFIG_JOYSTICK_SPACEBALL is not set<br>
&gt; # CONFIG_JOYSTICK_STINGER is not set<br>
&gt; # CONFIG_JOYSTICK_TWIDJOY is not set<br>
&gt; # CONFIG_JOYSTICK_ZHENHUA is not set<br>
&gt; # CONFIG_JOYSTICK_AS5011 is not set<br>
&gt; # CONFIG_JOYSTICK_JOYDUMP is not set<br>
&gt; # CONFIG_JOYSTICK_XPAD is not set<br>
&gt; CONFIG_INPUT_TABLET=3Dy<br>
&gt; # CONFIG_TABLET_USB_ACECAD is not set<br>
&gt; # CONFIG_TABLET_USB_AIPTEK is not set<br>
&gt; # CONFIG_TABLET_USB_GTCO is not set<br>
&gt; # CONFIG_TABLET_USB_HANWANG is not set<br>
&gt; # CONFIG_TABLET_USB_KBTAB is not set<br>
&gt; # CONFIG_TABLET_USB_PEGASUS is not set<br>
&gt; # CONFIG_TABLET_SERIAL_WACOM4 is not set<br>
&gt; CONFIG_INPUT_TOUCHSCREEN=3Dy<br>
&gt; CONFIG_TOUCHSCREEN_PROPERTIES=3D<wbr>y<br>
&gt; # CONFIG_TOUCHSCREEN_AD7879 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ATMEL_MXT is not set<br>
&gt; # CONFIG_TOUCHSCREEN_BU21013 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set<br>
&gt; # CONFIG_TOUCHSCREEN_CYTTSP4_<wbr>CORE is not set<br>
&gt; # CONFIG_TOUCHSCREEN_DYNAPRO is not set<br>
&gt; # CONFIG_TOUCHSCREEN_HAMPSHIRE is not set<br>
&gt; # CONFIG_TOUCHSCREEN_EETI is not set<br>
&gt; # CONFIG_TOUCHSCREEN_EGALAX_<wbr>SERIAL is not set<br>
&gt; # CONFIG_TOUCHSCREEN_EXC3000 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_FUJITSU is not set<br>
&gt; # CONFIG_TOUCHSCREEN_HIDEEP is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ILI210X is not set<br>
&gt; # CONFIG_TOUCHSCREEN_S6SY761 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_GUNZE is not set<br>
&gt; # CONFIG_TOUCHSCREEN_EKTF2127 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ELAN is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ELO is not set<br>
&gt; # CONFIG_TOUCHSCREEN_WACOM_W8001 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_WACOM_I2C is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MAX11801 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MCS5000 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MMS114 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MTOUCH is not set<br>
&gt; # CONFIG_TOUCHSCREEN_INEXIO is not set<br>
&gt; # CONFIG_TOUCHSCREEN_MK712 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_PENMOUNT is not set<br>
&gt; # CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TOUCHWIN is not set<br>
&gt; # CONFIG_TOUCHSCREEN_PIXCIR is not set<br>
&gt; # CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set<br>
&gt; # CONFIG_TOUCHSCREEN_USB_<wbr>COMPOSITE is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TOUCHIT213 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TSC_SERIO is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TSC2004 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TSC2007 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_SILEAD is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ST1232 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_STMFTS is not set<br>
&gt; # CONFIG_TOUCHSCREEN_SX8654 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_TPS6507X is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ZET6223 is not set<br>
&gt; # CONFIG_TOUCHSCREEN_ROHM_<wbr>BU21023 is not set<br>
&gt; CONFIG_INPUT_MISC=3Dy<br>
&gt; # CONFIG_INPUT_AD714X is not set<br>
&gt; # CONFIG_INPUT_BMA150 is not set<br>
&gt; # CONFIG_INPUT_E3X0_BUTTON is not set<br>
&gt; # CONFIG_INPUT_PCSPKR is not set<br>
&gt; # CONFIG_INPUT_MMA8450 is not set<br>
&gt; # CONFIG_INPUT_APANEL is not set<br>
&gt; # CONFIG_INPUT_ATLAS_BTNS is not set<br>
&gt; # CONFIG_INPUT_ATI_REMOTE2 is not set<br>
&gt; # CONFIG_INPUT_KEYSPAN_REMOTE is not set<br>
&gt; # CONFIG_INPUT_KXTJ9 is not set<br>
&gt; # CONFIG_INPUT_POWERMATE is not set<br>
&gt; # CONFIG_INPUT_YEALINK is not set<br>
&gt; # CONFIG_INPUT_CM109 is not set<br>
&gt; # CONFIG_INPUT_UINPUT is not set<br>
&gt; # CONFIG_INPUT_PCF8574 is not set<br>
&gt; # CONFIG_INPUT_ADXL34X is not set<br>
&gt; # CONFIG_INPUT_IMS_PCU is not set<br>
&gt; # CONFIG_INPUT_CMA3000 is not set<br>
&gt; CONFIG_INPUT_XEN_KBDDEV_<wbr>FRONTEND=3Dy<br>
&gt; # CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set<br>
&gt; # CONFIG_INPUT_DRV2665_HAPTICS is not set<br>
&gt; # CONFIG_INPUT_DRV2667_HAPTICS is not set<br>
&gt; # CONFIG_RMI4_CORE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Hardware I/O ports<br>
&gt; #<br>
&gt; CONFIG_SERIO=3Dy<br>
&gt; CONFIG_ARCH_MIGHT_HAVE_PC_<wbr>SERIO=3Dy<br>
&gt; CONFIG_SERIO_I8042=3Dy<br>
&gt; CONFIG_SERIO_SERPORT=3Dy<br>
&gt; # CONFIG_SERIO_CT82C710 is not set<br>
&gt; # CONFIG_SERIO_PCIPS2 is not set<br>
&gt; CONFIG_SERIO_LIBPS2=3Dy<br>
&gt; # CONFIG_SERIO_RAW is not set<br>
&gt; # CONFIG_SERIO_ALTERA_PS2 is not set<br>
&gt; # CONFIG_SERIO_PS2MULT is not set<br>
&gt; # CONFIG_SERIO_ARC_PS2 is not set<br>
&gt; # CONFIG_USERIO is not set<br>
&gt; # CONFIG_GAMEPORT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Character devices<br>
&gt; #<br>
&gt; CONFIG_TTY=3Dy<br>
&gt; CONFIG_VT=3Dy<br>
&gt; CONFIG_CONSOLE_TRANSLATIONS=3Dy<br>
&gt; CONFIG_VT_CONSOLE=3Dy<br>
&gt; CONFIG_VT_CONSOLE_SLEEP=3Dy<br>
&gt; CONFIG_HW_CONSOLE=3Dy<br>
&gt; CONFIG_VT_HW_CONSOLE_BINDING=3Dy<br>
&gt; CONFIG_UNIX98_PTYS=3Dy<br>
&gt; # CONFIG_LEGACY_PTYS is not set<br>
&gt; CONFIG_SERIAL_NONSTANDARD=3Dy<br>
&gt; # CONFIG_ROCKETPORT is not set<br>
&gt; # CONFIG_CYCLADES is not set<br>
&gt; # CONFIG_MOXA_INTELLIO is not set<br>
&gt; # CONFIG_MOXA_SMARTIO is not set<br>
&gt; # CONFIG_SYNCLINK is not set<br>
&gt; # CONFIG_SYNCLINKMP is not set<br>
&gt; # CONFIG_SYNCLINK_GT is not set<br>
&gt; # CONFIG_NOZOMI is not set<br>
&gt; # CONFIG_ISI is not set<br>
&gt; # CONFIG_N_HDLC is not set<br>
&gt; # CONFIG_N_GSM is not set<br>
&gt; # CONFIG_TRACE_SINK is not set<br>
&gt; CONFIG_DEVMEM=3Dy<br>
&gt; # CONFIG_DEVKMEM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Serial drivers<br>
&gt; #<br>
&gt; CONFIG_SERIAL_EARLYCON=3Dy<br>
&gt; CONFIG_SERIAL_8250=3Dy<br>
&gt; CONFIG_SERIAL_8250_DEPRECATED_<wbr>OPTIONS=3Dy<br>
&gt; CONFIG_SERIAL_8250_PNP=3Dy<br>
&gt; # CONFIG_SERIAL_8250_FINTEK is not set<br>
&gt; CONFIG_SERIAL_8250_CONSOLE=3Dy<br>
&gt; CONFIG_SERIAL_8250_DMA=3Dy<br>
&gt; CONFIG_SERIAL_8250_PCI=3Dy<br>
&gt; # CONFIG_SERIAL_8250_EXAR is not set<br>
&gt; # CONFIG_SERIAL_8250_CS is not set<br>
&gt; CONFIG_SERIAL_8250_NR_UARTS=3D32<br>
&gt; CONFIG_SERIAL_8250_RUNTIME_<wbr>UARTS=3D4<br>
&gt; CONFIG_SERIAL_8250_EXTENDED=3Dy<br>
&gt; CONFIG_SERIAL_8250_MANY_PORTS=3D<wbr>y<br>
&gt; CONFIG_SERIAL_8250_SHARE_IRQ=3Dy<br>
&gt; CONFIG_SERIAL_8250_DETECT_IRQ=3D<wbr>y<br>
&gt; CONFIG_SERIAL_8250_RSA=3Dy<br>
&gt; # CONFIG_SERIAL_8250_FSL is not set<br>
&gt; # CONFIG_SERIAL_8250_DW is not set<br>
&gt; # CONFIG_SERIAL_8250_RT288X is not set<br>
&gt; CONFIG_SERIAL_8250_LPSS=3Dy<br>
&gt; CONFIG_SERIAL_8250_MID=3Dy<br>
&gt; # CONFIG_SERIAL_8250_MOXA is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Non-8250 serial port support<br>
&gt; #<br>
&gt; # CONFIG_SERIAL_UARTLITE is not set<br>
&gt; CONFIG_SERIAL_CORE=3Dy<br>
&gt; CONFIG_SERIAL_CORE_CONSOLE=3Dy<br>
&gt; # CONFIG_SERIAL_JSM is not set<br>
&gt; # CONFIG_SERIAL_SCCNXP is not set<br>
&gt; # CONFIG_SERIAL_SC16IS7XX is not set<br>
&gt; # CONFIG_SERIAL_ALTERA_JTAGUART is not set<br>
&gt; # CONFIG_SERIAL_ALTERA_UART is not set<br>
&gt; # CONFIG_SERIAL_ARC is not set<br>
&gt; # CONFIG_SERIAL_RP2 is not set<br>
&gt; # CONFIG_SERIAL_FSL_LPUART is not set<br>
&gt; CONFIG_SERIAL_DEV_BUS=3Dy<br>
&gt; CONFIG_SERIAL_DEV_CTRL_<wbr>TTYPORT=3Dy<br>
&gt; # CONFIG_TTY_PRINTK is not set<br>
&gt; CONFIG_HVC_DRIVER=3Dy<br>
&gt; CONFIG_HVC_IRQ=3Dy<br>
&gt; CONFIG_HVC_XEN=3Dy<br>
&gt; CONFIG_HVC_XEN_FRONTEND=3Dy<br>
&gt; CONFIG_VIRTIO_CONSOLE=3Dy<br>
&gt; # CONFIG_IPMI_HANDLER is not set<br>
&gt; CONFIG_HW_RANDOM=3Dy<br>
&gt; # CONFIG_HW_RANDOM_TIMERIOMEM is not set<br>
&gt; # CONFIG_HW_RANDOM_INTEL is not set<br>
&gt; # CONFIG_HW_RANDOM_AMD is not set<br>
&gt; CONFIG_HW_RANDOM_VIA=3Dy<br>
&gt; # CONFIG_HW_RANDOM_VIRTIO is not set<br>
&gt; CONFIG_NVRAM=3Dy<br>
&gt; # CONFIG_R3964 is not set<br>
&gt; # CONFIG_APPLICOM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PCMCIA character devices<br>
&gt; #<br>
&gt; # CONFIG_SYNCLINK_CS is not set<br>
&gt; # CONFIG_CARDMAN_4000 is not set<br>
&gt; # CONFIG_CARDMAN_4040 is not set<br>
&gt; # CONFIG_SCR24X is not set<br>
&gt; # CONFIG_IPWIRELESS is not set<br>
&gt; # CONFIG_MWAVE is not set<br>
&gt; # CONFIG_RAW_DRIVER is not set<br>
&gt; CONFIG_HPET=3Dy<br>
&gt; # CONFIG_HPET_MMAP is not set<br>
&gt; # CONFIG_HANGCHECK_TIMER is not set<br>
&gt; # CONFIG_TCG_TPM is not set<br>
&gt; # CONFIG_TELCLOCK is not set<br>
&gt; CONFIG_DEVPORT=3Dy<br>
&gt; # CONFIG_XILLYBUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # I2C support<br>
&gt; #<br>
&gt; CONFIG_I2C=3Dy<br>
&gt; CONFIG_ACPI_I2C_OPREGION=3Dy<br>
&gt; CONFIG_I2C_BOARDINFO=3Dy<br>
&gt; CONFIG_I2C_COMPAT=3Dy<br>
&gt; # CONFIG_I2C_CHARDEV is not set<br>
&gt; # CONFIG_I2C_MUX is not set<br>
&gt; CONFIG_I2C_HELPER_AUTO=3Dy<br>
&gt; CONFIG_I2C_SMBUS=3Dy<br>
&gt; CONFIG_I2C_ALGOBIT=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # I2C Hardware Bus support<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # PC SMBus host controller drivers<br>
&gt; #<br>
&gt; # CONFIG_I2C_ALI1535 is not set<br>
&gt; # CONFIG_I2C_ALI1563 is not set<br>
&gt; # CONFIG_I2C_ALI15X3 is not set<br>
&gt; # CONFIG_I2C_AMD756 is not set<br>
&gt; # CONFIG_I2C_AMD8111 is not set<br>
&gt; CONFIG_I2C_I801=3Dy<br>
&gt; # CONFIG_I2C_ISCH is not set<br>
&gt; # CONFIG_I2C_ISMT is not set<br>
&gt; # CONFIG_I2C_PIIX4 is not set<br>
&gt; # CONFIG_I2C_NFORCE2 is not set<br>
&gt; # CONFIG_I2C_SIS5595 is not set<br>
&gt; # CONFIG_I2C_SIS630 is not set<br>
&gt; # CONFIG_I2C_SIS96X is not set<br>
&gt; # CONFIG_I2C_VIA is not set<br>
&gt; # CONFIG_I2C_VIAPRO is not set<br>
&gt;<br>
&gt; #<br>
&gt; # ACPI drivers<br>
&gt; #<br>
&gt; # CONFIG_I2C_SCMI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # I2C system bus drivers (mostly embedded / system-on-chip)<br>
&gt; #<br>
&gt; # CONFIG_I2C_DESIGNWARE_PLATFORM is not set<br>
&gt; # CONFIG_I2C_DESIGNWARE_PCI is not set<br>
&gt; # CONFIG_I2C_EMEV2 is not set<br>
&gt; # CONFIG_I2C_OCORES is not set<br>
&gt; # CONFIG_I2C_PCA_PLATFORM is not set<br>
&gt; # CONFIG_I2C_PXA_PCI is not set<br>
&gt; # CONFIG_I2C_SIMTEC is not set<br>
&gt; # CONFIG_I2C_XILINX is not set<br>
&gt;<br>
&gt; #<br>
&gt; # External I2C/SMBus adapter drivers<br>
&gt; #<br>
&gt; # CONFIG_I2C_DIOLAN_U2C is not set<br>
&gt; # CONFIG_I2C_PARPORT_LIGHT is not set<br>
&gt; # CONFIG_I2C_ROBOTFUZZ_OSIF is not set<br>
&gt; # CONFIG_I2C_TAOS_EVM is not set<br>
&gt; # CONFIG_I2C_TINY_USB is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Other I2C/SMBus bus drivers<br>
&gt; #<br>
&gt; # CONFIG_I2C_MLXCPLD is not set<br>
&gt; # CONFIG_I2C_STUB is not set<br>
&gt; # CONFIG_I2C_SLAVE is not set<br>
&gt; # CONFIG_I2C_DEBUG_CORE is not set<br>
&gt; # CONFIG_I2C_DEBUG_ALGO is not set<br>
&gt; # CONFIG_I2C_DEBUG_BUS is not set<br>
&gt; # CONFIG_SPI is not set<br>
&gt; # CONFIG_SPMI is not set<br>
&gt; # CONFIG_HSI is not set<br>
&gt; CONFIG_PPS=3Dy<br>
&gt; # CONFIG_PPS_DEBUG is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PPS clients support<br>
&gt; #<br>
&gt; # CONFIG_PPS_CLIENT_KTIMER is not set<br>
&gt; # CONFIG_PPS_CLIENT_LDISC is not set<br>
&gt; # CONFIG_PPS_CLIENT_GPIO is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PPS generators support<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # PTP clock support<br>
&gt; #<br>
&gt; CONFIG_PTP_1588_CLOCK=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clo=
cks.<br>
&gt; #<br>
&gt; CONFIG_PTP_1588_CLOCK_KVM=3Dy<br>
&gt; # CONFIG_PINCTRL is not set<br>
&gt; # CONFIG_GPIOLIB is not set<br>
&gt; # CONFIG_W1 is not set<br>
&gt; # CONFIG_POWER_AVS is not set<br>
&gt; # CONFIG_POWER_RESET is not set<br>
&gt; CONFIG_POWER_SUPPLY=3Dy<br>
&gt; # CONFIG_POWER_SUPPLY_DEBUG is not set<br>
&gt; # CONFIG_PDA_POWER is not set<br>
&gt; # CONFIG_TEST_POWER is not set<br>
&gt; # CONFIG_BATTERY_DS2780 is not set<br>
&gt; # CONFIG_BATTERY_DS2781 is not set<br>
&gt; # CONFIG_BATTERY_DS2782 is not set<br>
&gt; # CONFIG_BATTERY_SBS is not set<br>
&gt; # CONFIG_CHARGER_SBS is not set<br>
&gt; # CONFIG_BATTERY_BQ27XXX is not set<br>
&gt; # CONFIG_BATTERY_MAX17040 is not set<br>
&gt; # CONFIG_BATTERY_MAX17042 is not set<br>
&gt; # CONFIG_CHARGER_MAX8903 is not set<br>
&gt; # CONFIG_CHARGER_LP8727 is not set<br>
&gt; # CONFIG_CHARGER_BQ2415X is not set<br>
&gt; # CONFIG_CHARGER_SMB347 is not set<br>
&gt; # CONFIG_BATTERY_GAUGE_LTC2941 is not set<br>
&gt; CONFIG_HWMON=3Dy<br>
&gt; # CONFIG_HWMON_DEBUG_CHIP is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Native drivers<br>
&gt; #<br>
&gt; # CONFIG_SENSORS_ABITUGURU is not set<br>
&gt; # CONFIG_SENSORS_ABITUGURU3 is not set<br>
&gt; # CONFIG_SENSORS_AD7414 is not set<br>
&gt; # CONFIG_SENSORS_AD7418 is not set<br>
&gt; # CONFIG_SENSORS_ADM1021 is not set<br>
&gt; # CONFIG_SENSORS_ADM1025 is not set<br>
&gt; # CONFIG_SENSORS_ADM1026 is not set<br>
&gt; # CONFIG_SENSORS_ADM1029 is not set<br>
&gt; # CONFIG_SENSORS_ADM1031 is not set<br>
&gt; # CONFIG_SENSORS_ADM9240 is not set<br>
&gt; # CONFIG_SENSORS_ADT7410 is not set<br>
&gt; # CONFIG_SENSORS_ADT7411 is not set<br>
&gt; # CONFIG_SENSORS_ADT7462 is not set<br>
&gt; # CONFIG_SENSORS_ADT7470 is not set<br>
&gt; # CONFIG_SENSORS_ADT7475 is not set<br>
&gt; # CONFIG_SENSORS_ASC7621 is not set<br>
&gt; # CONFIG_SENSORS_K8TEMP is not set<br>
&gt; # CONFIG_SENSORS_K10TEMP is not set<br>
&gt; # CONFIG_SENSORS_FAM15H_POWER is not set<br>
&gt; # CONFIG_SENSORS_APPLESMC is not set<br>
&gt; # CONFIG_SENSORS_ASB100 is not set<br>
&gt; # CONFIG_SENSORS_ASPEED is not set<br>
&gt; # CONFIG_SENSORS_ATXP1 is not set<br>
&gt; # CONFIG_SENSORS_DS620 is not set<br>
&gt; # CONFIG_SENSORS_DS1621 is not set<br>
&gt; # CONFIG_SENSORS_DELL_SMM is not set<br>
&gt; # CONFIG_SENSORS_I5K_AMB is not set<br>
&gt; # CONFIG_SENSORS_F71805F is not set<br>
&gt; # CONFIG_SENSORS_F71882FG is not set<br>
&gt; # CONFIG_SENSORS_F75375S is not set<br>
&gt; # CONFIG_SENSORS_FSCHMD is not set<br>
&gt; # CONFIG_SENSORS_FTSTEUTATES is not set<br>
&gt; # CONFIG_SENSORS_GL518SM is not set<br>
&gt; # CONFIG_SENSORS_GL520SM is not set<br>
&gt; # CONFIG_SENSORS_G760A is not set<br>
&gt; # CONFIG_SENSORS_G762 is not set<br>
&gt; # CONFIG_SENSORS_HIH6130 is not set<br>
&gt; # CONFIG_SENSORS_I5500 is not set<br>
&gt; # CONFIG_SENSORS_CORETEMP is not set<br>
&gt; # CONFIG_SENSORS_IT87 is not set<br>
&gt; # CONFIG_SENSORS_JC42 is not set<br>
&gt; # CONFIG_SENSORS_POWR1220 is not set<br>
&gt; # CONFIG_SENSORS_LINEAGE is not set<br>
&gt; # CONFIG_SENSORS_LTC2945 is not set<br>
&gt; # CONFIG_SENSORS_LTC2990 is not set<br>
&gt; # CONFIG_SENSORS_LTC4151 is not set<br>
&gt; # CONFIG_SENSORS_LTC4215 is not set<br>
&gt; # CONFIG_SENSORS_LTC4222 is not set<br>
&gt; # CONFIG_SENSORS_LTC4245 is not set<br>
&gt; # CONFIG_SENSORS_LTC4260 is not set<br>
&gt; # CONFIG_SENSORS_LTC4261 is not set<br>
&gt; # CONFIG_SENSORS_MAX16065 is not set<br>
&gt; # CONFIG_SENSORS_MAX1619 is not set<br>
&gt; # CONFIG_SENSORS_MAX1668 is not set<br>
&gt; # CONFIG_SENSORS_MAX197 is not set<br>
&gt; # CONFIG_SENSORS_MAX6621 is not set<br>
&gt; # CONFIG_SENSORS_MAX6639 is not set<br>
&gt; # CONFIG_SENSORS_MAX6642 is not set<br>
&gt; # CONFIG_SENSORS_MAX6650 is not set<br>
&gt; # CONFIG_SENSORS_MAX6697 is not set<br>
&gt; # CONFIG_SENSORS_MAX31790 is not set<br>
&gt; # CONFIG_SENSORS_MCP3021 is not set<br>
&gt; # CONFIG_SENSORS_TC654 is not set<br>
&gt; # CONFIG_SENSORS_LM63 is not set<br>
&gt; # CONFIG_SENSORS_LM73 is not set<br>
&gt; # CONFIG_SENSORS_LM75 is not set<br>
&gt; # CONFIG_SENSORS_LM77 is not set<br>
&gt; # CONFIG_SENSORS_LM78 is not set<br>
&gt; # CONFIG_SENSORS_LM80 is not set<br>
&gt; # CONFIG_SENSORS_LM83 is not set<br>
&gt; # CONFIG_SENSORS_LM85 is not set<br>
&gt; # CONFIG_SENSORS_LM87 is not set<br>
&gt; # CONFIG_SENSORS_LM90 is not set<br>
&gt; # CONFIG_SENSORS_LM92 is not set<br>
&gt; # CONFIG_SENSORS_LM93 is not set<br>
&gt; # CONFIG_SENSORS_LM95234 is not set<br>
&gt; # CONFIG_SENSORS_LM95241 is not set<br>
&gt; # CONFIG_SENSORS_LM95245 is not set<br>
&gt; # CONFIG_SENSORS_PC87360 is not set<br>
&gt; # CONFIG_SENSORS_PC87427 is not set<br>
&gt; # CONFIG_SENSORS_NTC_THERMISTOR is not set<br>
&gt; # CONFIG_SENSORS_NCT6683 is not set<br>
&gt; # CONFIG_SENSORS_NCT6775 is not set<br>
&gt; # CONFIG_SENSORS_NCT7802 is not set<br>
&gt; # CONFIG_SENSORS_NCT7904 is not set<br>
&gt; # CONFIG_SENSORS_PCF8591 is not set<br>
&gt; # CONFIG_PMBUS is not set<br>
&gt; # CONFIG_SENSORS_SHT21 is not set<br>
&gt; # CONFIG_SENSORS_SHT3x is not set<br>
&gt; # CONFIG_SENSORS_SHTC1 is not set<br>
&gt; # CONFIG_SENSORS_SIS5595 is not set<br>
&gt; # CONFIG_SENSORS_DME1737 is not set<br>
&gt; # CONFIG_SENSORS_EMC1403 is not set<br>
&gt; # CONFIG_SENSORS_EMC2103 is not set<br>
&gt; # CONFIG_SENSORS_EMC6W201 is not set<br>
&gt; # CONFIG_SENSORS_SMSC47M1 is not set<br>
&gt; # CONFIG_SENSORS_SMSC47M192 is not set<br>
&gt; # CONFIG_SENSORS_SMSC47B397 is not set<br>
&gt; # CONFIG_SENSORS_SCH5627 is not set<br>
&gt; # CONFIG_SENSORS_SCH5636 is not set<br>
&gt; # CONFIG_SENSORS_STTS751 is not set<br>
&gt; # CONFIG_SENSORS_SMM665 is not set<br>
&gt; # CONFIG_SENSORS_ADC128D818 is not set<br>
&gt; # CONFIG_SENSORS_ADS1015 is not set<br>
&gt; # CONFIG_SENSORS_ADS7828 is not set<br>
&gt; # CONFIG_SENSORS_AMC6821 is not set<br>
&gt; # CONFIG_SENSORS_INA209 is not set<br>
&gt; # CONFIG_SENSORS_INA2XX is not set<br>
&gt; # CONFIG_SENSORS_INA3221 is not set<br>
&gt; # CONFIG_SENSORS_TC74 is not set<br>
&gt; # CONFIG_SENSORS_THMC50 is not set<br>
&gt; # CONFIG_SENSORS_TMP102 is not set<br>
&gt; # CONFIG_SENSORS_TMP103 is not set<br>
&gt; # CONFIG_SENSORS_TMP108 is not set<br>
&gt; # CONFIG_SENSORS_TMP401 is not set<br>
&gt; # CONFIG_SENSORS_TMP421 is not set<br>
&gt; # CONFIG_SENSORS_VIA_CPUTEMP is not set<br>
&gt; # CONFIG_SENSORS_VIA686A is not set<br>
&gt; # CONFIG_SENSORS_VT1211 is not set<br>
&gt; # CONFIG_SENSORS_VT8231 is not set<br>
&gt; # CONFIG_SENSORS_W83773G is not set<br>
&gt; # CONFIG_SENSORS_W83781D is not set<br>
&gt; # CONFIG_SENSORS_W83791D is not set<br>
&gt; # CONFIG_SENSORS_W83792D is not set<br>
&gt; # CONFIG_SENSORS_W83793 is not set<br>
&gt; # CONFIG_SENSORS_W83795 is not set<br>
&gt; # CONFIG_SENSORS_W83L785TS is not set<br>
&gt; # CONFIG_SENSORS_W83L786NG is not set<br>
&gt; # CONFIG_SENSORS_W83627HF is not set<br>
&gt; # CONFIG_SENSORS_W83627EHF is not set<br>
&gt; # CONFIG_SENSORS_XGENE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # ACPI drivers<br>
&gt; #<br>
&gt; # CONFIG_SENSORS_ACPI_POWER is not set<br>
&gt; # CONFIG_SENSORS_ATK0110 is not set<br>
&gt; CONFIG_THERMAL=3Dy<br>
&gt; CONFIG_THERMAL_EMERGENCY_<wbr>POWEROFF_DELAY_MS=3D0<br>
&gt; CONFIG_THERMAL_HWMON=3Dy<br>
&gt; CONFIG_THERMAL_WRITABLE_TRIPS=3D<wbr>y<br>
&gt; CONFIG_THERMAL_DEFAULT_GOV_<wbr>STEP_WISE=3Dy<br>
&gt; # CONFIG_THERMAL_DEFAULT_GOV_<wbr>FAIR_SHARE is not set<br>
&gt; # CONFIG_THERMAL_DEFAULT_GOV_<wbr>USER_SPACE is not set<br>
&gt; # CONFIG_THERMAL_DEFAULT_GOV_<wbr>POWER_ALLOCATOR is not set<br>
&gt; # CONFIG_THERMAL_GOV_FAIR_SHARE is not set<br>
&gt; CONFIG_THERMAL_GOV_STEP_WISE=3Dy<br>
&gt; # CONFIG_THERMAL_GOV_BANG_BANG is not set<br>
&gt; CONFIG_THERMAL_GOV_USER_SPACE=3D<wbr>y<br>
&gt; # CONFIG_THERMAL_GOV_POWER_<wbr>ALLOCATOR is not set<br>
&gt; # CONFIG_THERMAL_EMULATION is not set<br>
&gt; # CONFIG_INTEL_POWERCLAMP is not set<br>
&gt; CONFIG_X86_PKG_TEMP_THERMAL=3Dy<br>
&gt; # CONFIG_INTEL_SOC_DTS_THERMAL is not set<br>
&gt;<br>
&gt; #<br>
&gt; # ACPI INT340X thermal drivers<br>
&gt; #<br>
&gt; # CONFIG_INT340X_THERMAL is not set<br>
&gt; # CONFIG_INTEL_PCH_THERMAL is not set<br>
&gt; CONFIG_WATCHDOG=3Dy<br>
&gt; # CONFIG_WATCHDOG_CORE is not set<br>
&gt; # CONFIG_WATCHDOG_NOWAYOUT is not set<br>
&gt; CONFIG_WATCHDOG_HANDLE_BOOT_<wbr>ENABLED=3Dy<br>
&gt; # CONFIG_WATCHDOG_SYSFS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Watchdog Device Drivers<br>
&gt; #<br>
&gt; # CONFIG_SOFT_WATCHDOG is not set<br>
&gt; # CONFIG_WDAT_WDT is not set<br>
&gt; # CONFIG_XILINX_WATCHDOG is not set<br>
&gt; # CONFIG_ZIIRAVE_WATCHDOG is not set<br>
&gt; # CONFIG_CADENCE_WATCHDOG is not set<br>
&gt; # CONFIG_DW_WATCHDOG is not set<br>
&gt; # CONFIG_MAX63XX_WATCHDOG is not set<br>
&gt; # CONFIG_ACQUIRE_WDT is not set<br>
&gt; # CONFIG_ADVANTECH_WDT is not set<br>
&gt; # CONFIG_ALIM1535_WDT is not set<br>
&gt; # CONFIG_ALIM7101_WDT is not set<br>
&gt; # CONFIG_F71808E_WDT is not set<br>
&gt; # CONFIG_SP5100_TCO is not set<br>
&gt; # CONFIG_SBC_FITPC2_WATCHDOG is not set<br>
&gt; # CONFIG_EUROTECH_WDT is not set<br>
&gt; # CONFIG_IB700_WDT is not set<br>
&gt; # CONFIG_IBMASR is not set<br>
&gt; # CONFIG_WAFER_WDT is not set<br>
&gt; # CONFIG_I6300ESB_WDT is not set<br>
&gt; # CONFIG_IE6XX_WDT is not set<br>
&gt; # CONFIG_ITCO_WDT is not set<br>
&gt; # CONFIG_IT8712F_WDT is not set<br>
&gt; # CONFIG_IT87_WDT is not set<br>
&gt; # CONFIG_HP_WATCHDOG is not set<br>
&gt; # CONFIG_SC1200_WDT is not set<br>
&gt; # CONFIG_PC87413_WDT is not set<br>
&gt; # CONFIG_NV_TCO is not set<br>
&gt; # CONFIG_60XX_WDT is not set<br>
&gt; # CONFIG_CPU5_WDT is not set<br>
&gt; # CONFIG_SMSC_SCH311X_WDT is not set<br>
&gt; # CONFIG_SMSC37B787_WDT is not set<br>
&gt; # CONFIG_VIA_WDT is not set<br>
&gt; # CONFIG_W83627HF_WDT is not set<br>
&gt; # CONFIG_W83877F_WDT is not set<br>
&gt; # CONFIG_W83977F_WDT is not set<br>
&gt; # CONFIG_MACHZ_WDT is not set<br>
&gt; # CONFIG_SBC_EPX_C3_WATCHDOG is not set<br>
&gt; # CONFIG_NI903X_WDT is not set<br>
&gt; # CONFIG_NIC7018_WDT is not set<br>
&gt; # CONFIG_XEN_WDT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PCI-based Watchdog Cards<br>
&gt; #<br>
&gt; # CONFIG_PCIPCWATCHDOG is not set<br>
&gt; # CONFIG_WDTPCI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB-based Watchdog Cards<br>
&gt; #<br>
&gt; # CONFIG_USBPCWATCHDOG is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Watchdog Pretimeout Governors<br>
&gt; #<br>
&gt; # CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set<br>
&gt; CONFIG_SSB_POSSIBLE=3Dy<br>
&gt; # CONFIG_SSB is not set<br>
&gt; CONFIG_BCMA_POSSIBLE=3Dy<br>
&gt; # CONFIG_BCMA is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Multifunction device drivers<br>
&gt; #<br>
&gt; # CONFIG_MFD_CORE is not set<br>
&gt; # CONFIG_MFD_AS3711 is not set<br>
&gt; # CONFIG_PMIC_ADP5520 is not set<br>
&gt; # CONFIG_MFD_BCM590XX is not set<br>
&gt; # CONFIG_MFD_BD9571MWV is not set<br>
&gt; # CONFIG_MFD_AXP20X_I2C is not set<br>
&gt; # CONFIG_MFD_CROS_EC is not set<br>
&gt; # CONFIG_PMIC_DA903X is not set<br>
&gt; # CONFIG_MFD_DA9052_I2C is not set<br>
&gt; # CONFIG_MFD_DA9055 is not set<br>
&gt; # CONFIG_MFD_DA9062 is not set<br>
&gt; # CONFIG_MFD_DA9063 is not set<br>
&gt; # CONFIG_MFD_DA9150 is not set<br>
&gt; # CONFIG_MFD_DLN2 is not set<br>
&gt; # CONFIG_MFD_MC13XXX_I2C is not set<br>
&gt; # CONFIG_HTC_PASIC3 is not set<br>
&gt; # CONFIG_MFD_INTEL_QUARK_I2C_<wbr>GPIO is not set<br>
&gt; # CONFIG_LPC_ICH is not set<br>
&gt; # CONFIG_LPC_SCH is not set<br>
&gt; # CONFIG_INTEL_SOC_PMIC_CHTWC is not set<br>
&gt; # CONFIG_MFD_INTEL_LPSS_ACPI is not set<br>
&gt; # CONFIG_MFD_INTEL_LPSS_PCI is not set<br>
&gt; # CONFIG_MFD_JANZ_CMODIO is not set<br>
&gt; # CONFIG_MFD_KEMPLD is not set<br>
&gt; # CONFIG_MFD_88PM800 is not set<br>
&gt; # CONFIG_MFD_88PM805 is not set<br>
&gt; # CONFIG_MFD_88PM860X is not set<br>
&gt; # CONFIG_MFD_MAX14577 is not set<br>
&gt; # CONFIG_MFD_MAX77693 is not set<br>
&gt; # CONFIG_MFD_MAX77843 is not set<br>
&gt; # CONFIG_MFD_MAX8907 is not set<br>
&gt; # CONFIG_MFD_MAX8925 is not set<br>
&gt; # CONFIG_MFD_MAX8997 is not set<br>
&gt; # CONFIG_MFD_MAX8998 is not set<br>
&gt; # CONFIG_MFD_MT6397 is not set<br>
&gt; # CONFIG_MFD_MENF21BMC is not set<br>
&gt; # CONFIG_MFD_VIPERBOARD is not set<br>
&gt; # CONFIG_MFD_RETU is not set<br>
&gt; # CONFIG_MFD_PCF50633 is not set<br>
&gt; # CONFIG_MFD_RDC321X is not set<br>
&gt; # CONFIG_MFD_RT5033 is not set<br>
&gt; # CONFIG_MFD_RC5T583 is not set<br>
&gt; # CONFIG_MFD_SEC_CORE is not set<br>
&gt; # CONFIG_MFD_SI476X_CORE is not set<br>
&gt; # CONFIG_MFD_SM501 is not set<br>
&gt; # CONFIG_MFD_SKY81452 is not set<br>
&gt; # CONFIG_MFD_SMSC is not set<br>
&gt; # CONFIG_ABX500_CORE is not set<br>
&gt; # CONFIG_MFD_SYSCON is not set<br>
&gt; # CONFIG_MFD_TI_AM335X_TSCADC is not set<br>
&gt; # CONFIG_MFD_LP3943 is not set<br>
&gt; # CONFIG_MFD_LP8788 is not set<br>
&gt; # CONFIG_MFD_TI_LMU is not set<br>
&gt; # CONFIG_MFD_PALMAS is not set<br>
&gt; # CONFIG_TPS6105X is not set<br>
&gt; # CONFIG_TPS6507X is not set<br>
&gt; # CONFIG_MFD_TPS65086 is not set<br>
&gt; # CONFIG_MFD_TPS65090 is not set<br>
&gt; # CONFIG_MFD_TPS68470 is not set<br>
&gt; # CONFIG_MFD_TI_LP873X is not set<br>
&gt; # CONFIG_MFD_TPS6586X is not set<br>
&gt; # CONFIG_MFD_TPS65912_I2C is not set<br>
&gt; # CONFIG_MFD_TPS80031 is not set<br>
&gt; # CONFIG_TWL4030_CORE is not set<br>
&gt; # CONFIG_TWL6040_CORE is not set<br>
&gt; # CONFIG_MFD_WL1273_CORE is not set<br>
&gt; # CONFIG_MFD_LM3533 is not set<br>
&gt; # CONFIG_MFD_TMIO is not set<br>
&gt; # CONFIG_MFD_VX855 is not set<br>
&gt; # CONFIG_MFD_ARIZONA_I2C is not set<br>
&gt; # CONFIG_MFD_WM8400 is not set<br>
&gt; # CONFIG_MFD_WM831X_I2C is not set<br>
&gt; # CONFIG_MFD_WM8350_I2C is not set<br>
&gt; # CONFIG_MFD_WM8994 is not set<br>
&gt; # CONFIG_RAVE_SP_CORE is not set<br>
&gt; # CONFIG_REGULATOR is not set<br>
&gt; # CONFIG_RC_CORE is not set<br>
&gt; # CONFIG_MEDIA_SUPPORT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Graphics support<br>
&gt; #<br>
&gt; CONFIG_AGP=3Dy<br>
&gt; CONFIG_AGP_AMD64=3Dy<br>
&gt; CONFIG_AGP_INTEL=3Dy<br>
&gt; # CONFIG_AGP_SIS is not set<br>
&gt; # CONFIG_AGP_VIA is not set<br>
&gt; CONFIG_INTEL_GTT=3Dy<br>
&gt; CONFIG_VGA_ARB=3Dy<br>
&gt; CONFIG_VGA_ARB_MAX_GPUS=3D16<br>
&gt; # CONFIG_VGA_SWITCHEROO is not set<br>
&gt; CONFIG_DRM=3Dy<br>
&gt; CONFIG_DRM_MIPI_DSI=3Dy<br>
&gt; # CONFIG_DRM_DP_AUX_CHARDEV is not set<br>
&gt; # CONFIG_DRM_DEBUG_MM is not set<br>
&gt; # CONFIG_DRM_DEBUG_MM_SELFTEST is not set<br>
&gt; CONFIG_DRM_KMS_HELPER=3Dy<br>
&gt; CONFIG_DRM_KMS_FB_HELPER=3Dy<br>
&gt; CONFIG_DRM_FBDEV_EMULATION=3Dy<br>
&gt; CONFIG_DRM_FBDEV_OVERALLOC=3D100<br>
&gt; # CONFIG_DRM_LOAD_EDID_FIRMWARE is not set<br>
&gt; CONFIG_DRM_TTM=3Dy<br>
&gt; CONFIG_DRM_GEM_CMA_HELPER=3Dy<br>
&gt; CONFIG_DRM_KMS_CMA_HELPER=3Dy<br>
&gt; CONFIG_DRM_SCHED=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # I2C encoder or helper chips<br>
&gt; #<br>
&gt; # CONFIG_DRM_I2C_CH7006 is not set<br>
&gt; # CONFIG_DRM_I2C_SIL164 is not set<br>
&gt; # CONFIG_DRM_I2C_NXP_TDA998X is not set<br>
&gt; CONFIG_DRM_RADEON=3Dy<br>
&gt; CONFIG_DRM_RADEON_USERPTR=3Dy<br>
&gt; CONFIG_DRM_AMDGPU=3Dy<br>
&gt; CONFIG_DRM_AMDGPU_SI=3Dy<br>
&gt; CONFIG_DRM_AMDGPU_CIK=3Dy<br>
&gt; CONFIG_DRM_AMDGPU_USERPTR=3Dy<br>
&gt; # CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # ACP (Audio CoProcessor) Configuration<br>
&gt; #<br>
&gt; # CONFIG_DRM_AMD_ACP is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Display Engine Configuration<br>
&gt; #<br>
&gt; CONFIG_DRM_AMD_DC=3Dy<br>
&gt; # CONFIG_DRM_AMD_DC_PRE_VEGA is not set<br>
&gt; # CONFIG_DRM_AMD_DC_FBC is not set<br>
&gt; # CONFIG_DRM_AMD_DC_DCN1_0 is not set<br>
&gt; # CONFIG_DEBUG_KERNEL_DC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # AMD Library routines<br>
&gt; #<br>
&gt; CONFIG_CHASH=3Dy<br>
&gt; # CONFIG_CHASH_STATS is not set<br>
&gt; # CONFIG_CHASH_SELFTEST is not set<br>
&gt; # CONFIG_DRM_NOUVEAU is not set<br>
&gt; CONFIG_DRM_I915=3Dy<br>
&gt; CONFIG_DRM_I915_ALPHA_SUPPORT=3D<wbr>y<br>
&gt; CONFIG_DRM_I915_CAPTURE_ERROR=3D<wbr>y<br>
&gt; CONFIG_DRM_I915_COMPRESS_<wbr>ERROR=3Dy<br>
&gt; CONFIG_DRM_I915_USERPTR=3Dy<br>
&gt; CONFIG_DRM_I915_GVT=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # drm/i915 Debugging<br>
&gt; #<br>
&gt; # CONFIG_DRM_I915_WERROR is not set<br>
&gt; # CONFIG_DRM_I915_DEBUG is not set<br>
&gt; # CONFIG_DRM_I915_SW_FENCE_<wbr>DEBUG_OBJECTS is not set<br>
&gt; # CONFIG_DRM_I915_SW_FENCE_<wbr>CHECK_DAG is not set<br>
&gt; # CONFIG_DRM_I915_SELFTEST is not set<br>
&gt; # CONFIG_DRM_I915_LOW_LEVEL_<wbr>TRACEPOINTS is not set<br>
&gt; # CONFIG_DRM_I915_DEBUG_VBLANK_<wbr>EVADE is not set<br>
&gt; # CONFIG_DRM_VGEM is not set<br>
&gt; # CONFIG_DRM_VMWGFX is not set<br>
&gt; # CONFIG_DRM_GMA500 is not set<br>
&gt; # CONFIG_DRM_UDL is not set<br>
&gt; # CONFIG_DRM_AST is not set<br>
&gt; # CONFIG_DRM_MGAG200 is not set<br>
&gt; CONFIG_DRM_CIRRUS_QEMU=3Dy<br>
&gt; CONFIG_DRM_QXL=3Dy<br>
&gt; # CONFIG_DRM_BOCHS is not set<br>
&gt; CONFIG_DRM_VIRTIO_GPU=3Dy<br>
&gt; CONFIG_DRM_PANEL=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Display Panels<br>
&gt; #<br>
&gt; # CONFIG_DRM_PANEL_RASPBERRYPI_<wbr>TOUCHSCREEN is not set<br>
&gt; CONFIG_DRM_BRIDGE=3Dy<br>
&gt; CONFIG_DRM_PANEL_BRIDGE=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Display Interface Bridges<br>
&gt; #<br>
&gt; # CONFIG_DRM_ANALOGIX_ANX78XX is not set<br>
&gt; # CONFIG_DRM_HISI_HIBMC is not set<br>
&gt; CONFIG_DRM_TINYDRM=3Dy<br>
&gt; # CONFIG_DRM_LEGACY is not set<br>
&gt; CONFIG_DRM_PANEL_ORIENTATION_<wbr>QUIRKS=3Dy<br>
&gt; # CONFIG_DRM_LIB_RANDOM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Frame buffer Devices<br>
&gt; #<br>
&gt; CONFIG_FB=3Dy<br>
&gt; # CONFIG_FIRMWARE_EDID is not set<br>
&gt; CONFIG_FB_CMDLINE=3Dy<br>
&gt; CONFIG_FB_NOTIFY=3Dy<br>
&gt; # CONFIG_FB_DDC is not set<br>
&gt; # CONFIG_FB_BOOT_VESA_SUPPORT is not set<br>
&gt; CONFIG_FB_CFB_FILLRECT=3Dy<br>
&gt; CONFIG_FB_CFB_COPYAREA=3Dy<br>
&gt; CONFIG_FB_CFB_IMAGEBLIT=3Dy<br>
&gt; # CONFIG_FB_CFB_REV_PIXELS_IN_<wbr>BYTE is not set<br>
&gt; CONFIG_FB_SYS_FILLRECT=3Dy<br>
&gt; CONFIG_FB_SYS_COPYAREA=3Dy<br>
&gt; CONFIG_FB_SYS_IMAGEBLIT=3Dy<br>
&gt; # CONFIG_FB_PROVIDE_GET_FB_<wbr>UNMAPPED_AREA is not set<br>
&gt; # CONFIG_FB_FOREIGN_ENDIAN is not set<br>
&gt; CONFIG_FB_SYS_FOPS=3Dy<br>
&gt; CONFIG_FB_DEFERRED_IO=3Dy<br>
&gt; # CONFIG_FB_SVGALIB is not set<br>
&gt; # CONFIG_FB_MACMODES is not set<br>
&gt; # CONFIG_FB_BACKLIGHT is not set<br>
&gt; CONFIG_FB_MODE_HELPERS=3Dy<br>
&gt; CONFIG_FB_TILEBLITTING=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Frame buffer hardware drivers<br>
&gt; #<br>
&gt; # CONFIG_FB_CIRRUS is not set<br>
&gt; # CONFIG_FB_PM2 is not set<br>
&gt; # CONFIG_FB_CYBER2000 is not set<br>
&gt; # CONFIG_FB_ARC is not set<br>
&gt; # CONFIG_FB_ASILIANT is not set<br>
&gt; # CONFIG_FB_IMSTT is not set<br>
&gt; # CONFIG_FB_VGA16 is not set<br>
&gt; # CONFIG_FB_UVESA is not set<br>
&gt; # CONFIG_FB_VESA is not set<br>
&gt; CONFIG_FB_EFI=3Dy<br>
&gt; # CONFIG_FB_N411 is not set<br>
&gt; # CONFIG_FB_HGA is not set<br>
&gt; # CONFIG_FB_OPENCORES is not set<br>
&gt; # CONFIG_FB_S1D13XXX is not set<br>
&gt; # CONFIG_FB_NVIDIA is not set<br>
&gt; # CONFIG_FB_RIVA is not set<br>
&gt; # CONFIG_FB_I740 is not set<br>
&gt; # CONFIG_FB_LE80578 is not set<br>
&gt; # CONFIG_FB_MATROX is not set<br>
&gt; # CONFIG_FB_RADEON is not set<br>
&gt; # CONFIG_FB_ATY128 is not set<br>
&gt; # CONFIG_FB_ATY is not set<br>
&gt; # CONFIG_FB_S3 is not set<br>
&gt; # CONFIG_FB_SAVAGE is not set<br>
&gt; # CONFIG_FB_SIS is not set<br>
&gt; # CONFIG_FB_NEOMAGIC is not set<br>
&gt; # CONFIG_FB_KYRO is not set<br>
&gt; # CONFIG_FB_3DFX is not set<br>
&gt; # CONFIG_FB_VOODOO1 is not set<br>
&gt; # CONFIG_FB_VT8623 is not set<br>
&gt; # CONFIG_FB_TRIDENT is not set<br>
&gt; # CONFIG_FB_ARK is not set<br>
&gt; # CONFIG_FB_PM3 is not set<br>
&gt; # CONFIG_FB_CARMINE is not set<br>
&gt; # CONFIG_FB_SMSCUFX is not set<br>
&gt; # CONFIG_FB_UDL is not set<br>
&gt; # CONFIG_FB_IBM_GXT4500 is not set<br>
&gt; # CONFIG_FB_VIRTUAL is not set<br>
&gt; CONFIG_XEN_FBDEV_FRONTEND=3Dy<br>
&gt; # CONFIG_FB_METRONOME is not set<br>
&gt; # CONFIG_FB_MB862XX is not set<br>
&gt; # CONFIG_FB_BROADSHEET is not set<br>
&gt; # CONFIG_FB_AUO_K190X is not set<br>
&gt; # CONFIG_FB_SIMPLE is not set<br>
&gt; # CONFIG_FB_SM712 is not set<br>
&gt; CONFIG_BACKLIGHT_LCD_SUPPORT=3Dy<br>
&gt; # CONFIG_LCD_CLASS_DEVICE is not set<br>
&gt; CONFIG_BACKLIGHT_CLASS_DEVICE=3D<wbr>y<br>
&gt; CONFIG_BACKLIGHT_GENERIC=3Dy<br>
&gt; # CONFIG_BACKLIGHT_APPLE is not set<br>
&gt; # CONFIG_BACKLIGHT_PM8941_WLED is not set<br>
&gt; # CONFIG_BACKLIGHT_SAHARA is not set<br>
&gt; # CONFIG_BACKLIGHT_ADP8860 is not set<br>
&gt; # CONFIG_BACKLIGHT_ADP8870 is not set<br>
&gt; # CONFIG_BACKLIGHT_LM3639 is not set<br>
&gt; # CONFIG_BACKLIGHT_LV5207LP is not set<br>
&gt; # CONFIG_BACKLIGHT_BD6107 is not set<br>
&gt; # CONFIG_BACKLIGHT_ARCXCNN is not set<br>
&gt; # CONFIG_VGASTATE is not set<br>
&gt; CONFIG_HDMI=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Console display driver support<br>
&gt; #<br>
&gt; CONFIG_VGA_CONSOLE=3Dy<br>
&gt; CONFIG_VGACON_SOFT_SCROLLBACK=3D<wbr>y<br>
&gt; CONFIG_VGACON_SOFT_SCROLLBACK_<wbr>SIZE=3D64<br>
&gt; # CONFIG_VGACON_SOFT_SCROLLBACK_<wbr>PERSISTENT_ENABLE_BY_DEFAULT is n=
ot set<br>
&gt; CONFIG_DUMMY_CONSOLE=3Dy<br>
&gt; CONFIG_DUMMY_CONSOLE_COLUMNS=3D<wbr>80<br>
&gt; CONFIG_DUMMY_CONSOLE_ROWS=3D25<br>
&gt; CONFIG_FRAMEBUFFER_CONSOLE=3Dy<br>
&gt; CONFIG_FRAMEBUFFER_CONSOLE_<wbr>DETECT_PRIMARY=3Dy<br>
&gt; # CONFIG_FRAMEBUFFER_CONSOLE_<wbr>ROTATION is not set<br>
&gt; CONFIG_LOGO=3Dy<br>
&gt; # CONFIG_LOGO_LINUX_MONO is not set<br>
&gt; # CONFIG_LOGO_LINUX_VGA16 is not set<br>
&gt; CONFIG_LOGO_LINUX_CLUT224=3Dy<br>
&gt; CONFIG_SOUND=3Dy<br>
&gt; CONFIG_SOUND_OSS_CORE=3Dy<br>
&gt; CONFIG_SOUND_OSS_CORE_<wbr>PRECLAIM=3Dy<br>
&gt; CONFIG_SND=3Dy<br>
&gt; CONFIG_SND_TIMER=3Dy<br>
&gt; CONFIG_SND_PCM=3Dy<br>
&gt; CONFIG_SND_HWDEP=3Dy<br>
&gt; CONFIG_SND_SEQ_DEVICE=3Dy<br>
&gt; CONFIG_SND_RAWMIDI=3Dy<br>
&gt; CONFIG_SND_JACK=3Dy<br>
&gt; CONFIG_SND_JACK_INPUT_DEV=3Dy<br>
&gt; CONFIG_SND_OSSEMUL=3Dy<br>
&gt; CONFIG_SND_MIXER_OSS=3Dy<br>
&gt; CONFIG_SND_PCM_OSS=3Dy<br>
&gt; CONFIG_SND_PCM_OSS_PLUGINS=3Dy<br>
&gt; CONFIG_SND_PCM_TIMER=3Dy<br>
&gt; CONFIG_SND_HRTIMER=3Dy<br>
&gt; CONFIG_SND_DYNAMIC_MINORS=3Dy<br>
&gt; CONFIG_SND_MAX_CARDS=3D32<br>
&gt; CONFIG_SND_SUPPORT_OLD_API=3Dy<br>
&gt; CONFIG_SND_PROC_FS=3Dy<br>
&gt; CONFIG_SND_VERBOSE_PROCFS=3Dy<br>
&gt; # CONFIG_SND_VERBOSE_PRINTK is not set<br>
&gt; CONFIG_SND_DEBUG=3Dy<br>
&gt; # CONFIG_SND_DEBUG_VERBOSE is not set<br>
&gt; CONFIG_SND_PCM_XRUN_DEBUG=3Dy<br>
&gt; CONFIG_SND_VMASTER=3Dy<br>
&gt; CONFIG_SND_DMA_SGBUF=3Dy<br>
&gt; CONFIG_SND_SEQUENCER=3Dy<br>
&gt; CONFIG_SND_SEQ_DUMMY=3Dy<br>
&gt; CONFIG_SND_SEQUENCER_OSS=3Dy<br>
&gt; CONFIG_SND_SEQ_HRTIMER_<wbr>DEFAULT=3Dy<br>
&gt; CONFIG_SND_SEQ_MIDI_EVENT=3Dy<br>
&gt; CONFIG_SND_SEQ_MIDI=3Dy<br>
&gt; CONFIG_SND_SEQ_VIRMIDI=3Dy<br>
&gt; # CONFIG_SND_OPL3_LIB_SEQ is not set<br>
&gt; # CONFIG_SND_OPL4_LIB_SEQ is not set<br>
&gt; CONFIG_SND_DRIVERS=3Dy<br>
&gt; # CONFIG_SND_PCSP is not set<br>
&gt; CONFIG_SND_DUMMY=3Dy<br>
&gt; CONFIG_SND_ALOOP=3Dy<br>
&gt; CONFIG_SND_VIRMIDI=3Dy<br>
&gt; # CONFIG_SND_MTPAV is not set<br>
&gt; # CONFIG_SND_SERIAL_U16550 is not set<br>
&gt; # CONFIG_SND_MPU401 is not set<br>
&gt; CONFIG_SND_PCI=3Dy<br>
&gt; # CONFIG_SND_AD1889 is not set<br>
&gt; # CONFIG_SND_ALS300 is not set<br>
&gt; # CONFIG_SND_ALS4000 is not set<br>
&gt; # CONFIG_SND_ALI5451 is not set<br>
&gt; # CONFIG_SND_ASIHPI is not set<br>
&gt; # CONFIG_SND_ATIIXP is not set<br>
&gt; # CONFIG_SND_ATIIXP_MODEM is not set<br>
&gt; # CONFIG_SND_AU8810 is not set<br>
&gt; # CONFIG_SND_AU8820 is not set<br>
&gt; # CONFIG_SND_AU8830 is not set<br>
&gt; # CONFIG_SND_AW2 is not set<br>
&gt; # CONFIG_SND_AZT3328 is not set<br>
&gt; # CONFIG_SND_BT87X is not set<br>
&gt; # CONFIG_SND_CA0106 is not set<br>
&gt; # CONFIG_SND_CMIPCI is not set<br>
&gt; # CONFIG_SND_OXYGEN is not set<br>
&gt; # CONFIG_SND_CS4281 is not set<br>
&gt; # CONFIG_SND_CS46XX is not set<br>
&gt; # CONFIG_SND_CTXFI is not set<br>
&gt; # CONFIG_SND_DARLA20 is not set<br>
&gt; # CONFIG_SND_GINA20 is not set<br>
&gt; # CONFIG_SND_LAYLA20 is not set<br>
&gt; # CONFIG_SND_DARLA24 is not set<br>
&gt; # CONFIG_SND_GINA24 is not set<br>
&gt; # CONFIG_SND_LAYLA24 is not set<br>
&gt; # CONFIG_SND_MONA is not set<br>
&gt; # CONFIG_SND_MIA is not set<br>
&gt; # CONFIG_SND_ECHO3G is not set<br>
&gt; # CONFIG_SND_INDIGO is not set<br>
&gt; # CONFIG_SND_INDIGOIO is not set<br>
&gt; # CONFIG_SND_INDIGODJ is not set<br>
&gt; # CONFIG_SND_INDIGOIOX is not set<br>
&gt; # CONFIG_SND_INDIGODJX is not set<br>
&gt; # CONFIG_SND_EMU10K1 is not set<br>
&gt; # CONFIG_SND_EMU10K1_SEQ is not set<br>
&gt; # CONFIG_SND_EMU10K1X is not set<br>
&gt; # CONFIG_SND_ENS1370 is not set<br>
&gt; # CONFIG_SND_ENS1371 is not set<br>
&gt; # CONFIG_SND_ES1938 is not set<br>
&gt; # CONFIG_SND_ES1968 is not set<br>
&gt; # CONFIG_SND_FM801 is not set<br>
&gt; # CONFIG_SND_HDSP is not set<br>
&gt; # CONFIG_SND_HDSPM is not set<br>
&gt; # CONFIG_SND_ICE1712 is not set<br>
&gt; # CONFIG_SND_ICE1724 is not set<br>
&gt; # CONFIG_SND_INTEL8X0 is not set<br>
&gt; # CONFIG_SND_INTEL8X0M is not set<br>
&gt; # CONFIG_SND_KORG1212 is not set<br>
&gt; # CONFIG_SND_LOLA is not set<br>
&gt; # CONFIG_SND_LX6464ES is not set<br>
&gt; # CONFIG_SND_MAESTRO3 is not set<br>
&gt; # CONFIG_SND_MIXART is not set<br>
&gt; # CONFIG_SND_NM256 is not set<br>
&gt; # CONFIG_SND_PCXHR is not set<br>
&gt; # CONFIG_SND_RIPTIDE is not set<br>
&gt; # CONFIG_SND_RME32 is not set<br>
&gt; # CONFIG_SND_RME96 is not set<br>
&gt; # CONFIG_SND_RME9652 is not set<br>
&gt; # CONFIG_SND_SE6X is not set<br>
&gt; # CONFIG_SND_SONICVIBES is not set<br>
&gt; # CONFIG_SND_TRIDENT is not set<br>
&gt; # CONFIG_SND_VIA82XX is not set<br>
&gt; # CONFIG_SND_VIA82XX_MODEM is not set<br>
&gt; # CONFIG_SND_VIRTUOSO is not set<br>
&gt; # CONFIG_SND_VX222 is not set<br>
&gt; # CONFIG_SND_YMFPCI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # HD-Audio<br>
&gt; #<br>
&gt; CONFIG_SND_HDA=3Dy<br>
&gt; CONFIG_SND_HDA_INTEL=3Dy<br>
&gt; CONFIG_SND_HDA_HWDEP=3Dy<br>
&gt; # CONFIG_SND_HDA_RECONFIG is not set<br>
&gt; # CONFIG_SND_HDA_INPUT_BEEP is not set<br>
&gt; # CONFIG_SND_HDA_PATCH_LOADER is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_REALTEK is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_ANALOG is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_SIGMATEL is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_VIA is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_HDMI is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_CIRRUS is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_CONEXANT is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_CA0110 is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_CA0132 is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_CMEDIA is not set<br>
&gt; # CONFIG_SND_HDA_CODEC_SI3054 is not set<br>
&gt; # CONFIG_SND_HDA_GENERIC is not set<br>
&gt; CONFIG_SND_HDA_POWER_SAVE_<wbr>DEFAULT=3D0<br>
&gt; CONFIG_SND_HDA_CORE=3Dy<br>
&gt; CONFIG_SND_HDA_I915=3Dy<br>
&gt; CONFIG_SND_HDA_PREALLOC_SIZE=3D<wbr>64<br>
&gt; CONFIG_SND_USB=3Dy<br>
&gt; # CONFIG_SND_USB_AUDIO is not set<br>
&gt; # CONFIG_SND_USB_UA101 is not set<br>
&gt; # CONFIG_SND_USB_USX2Y is not set<br>
&gt; # CONFIG_SND_USB_CAIAQ is not set<br>
&gt; # CONFIG_SND_USB_US122L is not set<br>
&gt; # CONFIG_SND_USB_6FIRE is not set<br>
&gt; # CONFIG_SND_USB_HIFACE is not set<br>
&gt; # CONFIG_SND_BCD2000 is not set<br>
&gt; # CONFIG_SND_USB_POD is not set<br>
&gt; # CONFIG_SND_USB_PODHD is not set<br>
&gt; # CONFIG_SND_USB_TONEPORT is not set<br>
&gt; # CONFIG_SND_USB_VARIAX is not set<br>
&gt; CONFIG_SND_PCMCIA=3Dy<br>
&gt; # CONFIG_SND_VXPOCKET is not set<br>
&gt; # CONFIG_SND_PDAUDIOCF is not set<br>
&gt; # CONFIG_SND_SOC is not set<br>
&gt; CONFIG_SND_X86=3Dy<br>
&gt; CONFIG_HDMI_LPE_AUDIO=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # HID support<br>
&gt; #<br>
&gt; CONFIG_HID=3Dy<br>
&gt; # CONFIG_HID_BATTERY_STRENGTH is not set<br>
&gt; CONFIG_HIDRAW=3Dy<br>
&gt; # CONFIG_UHID is not set<br>
&gt; CONFIG_HID_GENERIC=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Special HID drivers<br>
&gt; #<br>
&gt; CONFIG_HID_A4TECH=3Dy<br>
&gt; # CONFIG_HID_ACCUTOUCH is not set<br>
&gt; # CONFIG_HID_ACRUX is not set<br>
&gt; CONFIG_HID_APPLE=3Dy<br>
&gt; # CONFIG_HID_APPLEIR is not set<br>
&gt; # CONFIG_HID_ASUS is not set<br>
&gt; # CONFIG_HID_AUREAL is not set<br>
&gt; CONFIG_HID_BELKIN=3Dy<br>
&gt; # CONFIG_HID_BETOP_FF is not set<br>
&gt; CONFIG_HID_CHERRY=3Dy<br>
&gt; CONFIG_HID_CHICONY=3Dy<br>
&gt; # CONFIG_HID_CORSAIR is not set<br>
&gt; # CONFIG_HID_PRODIKEYS is not set<br>
&gt; # CONFIG_HID_CMEDIA is not set<br>
&gt; CONFIG_HID_CYPRESS=3Dy<br>
&gt; # CONFIG_HID_DRAGONRISE is not set<br>
&gt; # CONFIG_HID_EMS_FF is not set<br>
&gt; # CONFIG_HID_ELECOM is not set<br>
&gt; # CONFIG_HID_ELO is not set<br>
&gt; CONFIG_HID_EZKEY=3Dy<br>
&gt; # CONFIG_HID_GEMBIRD is not set<br>
&gt; # CONFIG_HID_GFRM is not set<br>
&gt; # CONFIG_HID_HOLTEK is not set<br>
&gt; # CONFIG_HID_GT683R is not set<br>
&gt; # CONFIG_HID_KEYTOUCH is not set<br>
&gt; # CONFIG_HID_KYE is not set<br>
&gt; # CONFIG_HID_UCLOGIC is not set<br>
&gt; # CONFIG_HID_WALTOP is not set<br>
&gt; CONFIG_HID_GYRATION=3Dy<br>
&gt; # CONFIG_HID_ICADE is not set<br>
&gt; CONFIG_HID_ITE=3Dy<br>
&gt; # CONFIG_HID_JABRA is not set<br>
&gt; # CONFIG_HID_TWINHAN is not set<br>
&gt; CONFIG_HID_KENSINGTON=3Dy<br>
&gt; # CONFIG_HID_LCPOWER is not set<br>
&gt; # CONFIG_HID_LED is not set<br>
&gt; # CONFIG_HID_LENOVO is not set<br>
&gt; CONFIG_HID_LOGITECH=3Dy<br>
&gt; # CONFIG_HID_LOGITECH_DJ is not set<br>
&gt; # CONFIG_HID_LOGITECH_HIDPP is not set<br>
&gt; CONFIG_LOGITECH_FF=3Dy<br>
&gt; # CONFIG_LOGIRUMBLEPAD2_FF is not set<br>
&gt; # CONFIG_LOGIG940_FF is not set<br>
&gt; CONFIG_LOGIWHEELS_FF=3Dy<br>
&gt; # CONFIG_HID_MAGICMOUSE is not set<br>
&gt; # CONFIG_HID_MAYFLASH is not set<br>
&gt; CONFIG_HID_MICROSOFT=3Dy<br>
&gt; CONFIG_HID_MONTEREY=3Dy<br>
&gt; # CONFIG_HID_MULTITOUCH is not set<br>
&gt; # CONFIG_HID_NTI is not set<br>
&gt; CONFIG_HID_NTRIG=3Dy<br>
&gt; # CONFIG_HID_ORTEK is not set<br>
&gt; CONFIG_HID_PANTHERLORD=3Dy<br>
&gt; CONFIG_PANTHERLORD_FF=3Dy<br>
&gt; # CONFIG_HID_PENMOUNT is not set<br>
&gt; CONFIG_HID_PETALYNX=3Dy<br>
&gt; # CONFIG_HID_PICOLCD is not set<br>
&gt; # CONFIG_HID_PLANTRONICS is not set<br>
&gt; # CONFIG_HID_PRIMAX is not set<br>
&gt; # CONFIG_HID_RETRODE is not set<br>
&gt; # CONFIG_HID_ROCCAT is not set<br>
&gt; # CONFIG_HID_SAITEK is not set<br>
&gt; CONFIG_HID_SAMSUNG=3Dy<br>
&gt; CONFIG_HID_SONY=3Dy<br>
&gt; # CONFIG_SONY_FF is not set<br>
&gt; # CONFIG_HID_SPEEDLINK is not set<br>
&gt; # CONFIG_HID_STEELSERIES is not set<br>
&gt; CONFIG_HID_SUNPLUS=3Dy<br>
&gt; # CONFIG_HID_RMI is not set<br>
&gt; # CONFIG_HID_GREENASIA is not set<br>
&gt; # CONFIG_HID_SMARTJOYPLUS is not set<br>
&gt; # CONFIG_HID_TIVO is not set<br>
&gt; CONFIG_HID_TOPSEED=3Dy<br>
&gt; # CONFIG_HID_THINGM is not set<br>
&gt; # CONFIG_HID_THRUSTMASTER is not set<br>
&gt; # CONFIG_HID_UDRAW_PS3 is not set<br>
&gt; # CONFIG_HID_WACOM is not set<br>
&gt; # CONFIG_HID_WIIMOTE is not set<br>
&gt; # CONFIG_HID_XINMO is not set<br>
&gt; # CONFIG_HID_ZEROPLUS is not set<br>
&gt; # CONFIG_HID_ZYDACRON is not set<br>
&gt; # CONFIG_HID_SENSOR_HUB is not set<br>
&gt; # CONFIG_HID_ALPS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB HID support<br>
&gt; #<br>
&gt; CONFIG_USB_HID=3Dy<br>
&gt; CONFIG_HID_PID=3Dy<br>
&gt; CONFIG_USB_HIDDEV=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # I2C HID support<br>
&gt; #<br>
&gt; # CONFIG_I2C_HID is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Intel ISH HID support<br>
&gt; #<br>
&gt; # CONFIG_INTEL_ISH_HID is not set<br>
&gt; CONFIG_USB_OHCI_LITTLE_ENDIAN=3D<wbr>y<br>
&gt; CONFIG_USB_SUPPORT=3Dy<br>
&gt; CONFIG_USB_COMMON=3Dy<br>
&gt; CONFIG_USB_ARCH_HAS_HCD=3Dy<br>
&gt; CONFIG_USB=3Dy<br>
&gt; CONFIG_USB_PCI=3Dy<br>
&gt; CONFIG_USB_ANNOUNCE_NEW_<wbr>DEVICES=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Miscellaneous USB options<br>
&gt; #<br>
&gt; CONFIG_USB_DEFAULT_PERSIST=3Dy<br>
&gt; # CONFIG_USB_DYNAMIC_MINORS is not set<br>
&gt; # CONFIG_USB_OTG is not set<br>
&gt; # CONFIG_USB_OTG_WHITELIST is not set<br>
&gt; # CONFIG_USB_OTG_BLACKLIST_HUB is not set<br>
&gt; # CONFIG_USB_LEDS_TRIGGER_<wbr>USBPORT is not set<br>
&gt; CONFIG_USB_MON=3Dy<br>
&gt; # CONFIG_USB_WUSB_CBAF is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Host Controller Drivers<br>
&gt; #<br>
&gt; # CONFIG_USB_C67X00_HCD is not set<br>
&gt; # CONFIG_USB_XHCI_HCD is not set<br>
&gt; CONFIG_USB_EHCI_HCD=3Dy<br>
&gt; # CONFIG_USB_EHCI_ROOT_HUB_TT is not set<br>
&gt; CONFIG_USB_EHCI_TT_NEWSCHED=3Dy<br>
&gt; CONFIG_USB_EHCI_PCI=3Dy<br>
&gt; # CONFIG_USB_EHCI_HCD_PLATFORM is not set<br>
&gt; # CONFIG_USB_OXU210HP_HCD is not set<br>
&gt; # CONFIG_USB_ISP116X_HCD is not set<br>
&gt; # CONFIG_USB_ISP1362_HCD is not set<br>
&gt; # CONFIG_USB_FOTG210_HCD is not set<br>
&gt; CONFIG_USB_OHCI_HCD=3Dy<br>
&gt; CONFIG_USB_OHCI_HCD_PCI=3Dy<br>
&gt; # CONFIG_USB_OHCI_HCD_PLATFORM is not set<br>
&gt; CONFIG_USB_UHCI_HCD=3Dy<br>
&gt; # CONFIG_USB_SL811_HCD is not set<br>
&gt; # CONFIG_USB_R8A66597_HCD is not set<br>
&gt; # CONFIG_USB_HCD_TEST_MODE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Device Class drivers<br>
&gt; #<br>
&gt; # CONFIG_USB_ACM is not set<br>
&gt; CONFIG_USB_PRINTER=3Dy<br>
&gt; # CONFIG_USB_WDM is not set<br>
&gt; # CONFIG_USB_TMC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # also be needed; see USB_STORAGE Help for more info<br>
&gt; #<br>
&gt; CONFIG_USB_STORAGE=3Dy<br>
&gt; # CONFIG_USB_STORAGE_DEBUG is not set<br>
&gt; # CONFIG_USB_STORAGE_REALTEK is not set<br>
&gt; # CONFIG_USB_STORAGE_DATAFAB is not set<br>
&gt; # CONFIG_USB_STORAGE_FREECOM is not set<br>
&gt; # CONFIG_USB_STORAGE_ISD200 is not set<br>
&gt; # CONFIG_USB_STORAGE_USBAT is not set<br>
&gt; # CONFIG_USB_STORAGE_SDDR09 is not set<br>
&gt; # CONFIG_USB_STORAGE_SDDR55 is not set<br>
&gt; # CONFIG_USB_STORAGE_JUMPSHOT is not set<br>
&gt; # CONFIG_USB_STORAGE_ALAUDA is not set<br>
&gt; # CONFIG_USB_STORAGE_ONETOUCH is not set<br>
&gt; # CONFIG_USB_STORAGE_KARMA is not set<br>
&gt; # CONFIG_USB_STORAGE_CYPRESS_<wbr>ATACB is not set<br>
&gt; # CONFIG_USB_STORAGE_ENE_UB6250 is not set<br>
&gt; # CONFIG_USB_UAS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Imaging devices<br>
&gt; #<br>
&gt; # CONFIG_USB_MDC800 is not set<br>
&gt; # CONFIG_USB_MICROTEK is not set<br>
&gt; # CONFIG_USBIP_CORE is not set<br>
&gt; # CONFIG_USB_MUSB_HDRC is not set<br>
&gt; # CONFIG_USB_DWC3 is not set<br>
&gt; # CONFIG_USB_DWC2 is not set<br>
&gt; # CONFIG_USB_CHIPIDEA is not set<br>
&gt; # CONFIG_USB_ISP1760 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB port drivers<br>
&gt; #<br>
&gt; # CONFIG_USB_SERIAL is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Miscellaneous drivers<br>
&gt; #<br>
&gt; # CONFIG_USB_EMI62 is not set<br>
&gt; # CONFIG_USB_EMI26 is not set<br>
&gt; # CONFIG_USB_ADUTUX is not set<br>
&gt; # CONFIG_USB_SEVSEG is not set<br>
&gt; # CONFIG_USB_RIO500 is not set<br>
&gt; # CONFIG_USB_LEGOTOWER is not set<br>
&gt; # CONFIG_USB_LCD is not set<br>
&gt; # CONFIG_USB_CYPRESS_CY7C63 is not set<br>
&gt; # CONFIG_USB_CYTHERM is not set<br>
&gt; # CONFIG_USB_IDMOUSE is not set<br>
&gt; # CONFIG_USB_FTDI_ELAN is not set<br>
&gt; # CONFIG_USB_APPLEDISPLAY is not set<br>
&gt; # CONFIG_USB_SISUSBVGA is not set<br>
&gt; # CONFIG_USB_LD is not set<br>
&gt; # CONFIG_USB_TRANCEVIBRATOR is not set<br>
&gt; # CONFIG_USB_IOWARRIOR is not set<br>
&gt; # CONFIG_USB_TEST is not set<br>
&gt; # CONFIG_USB_EHSET_TEST_FIXTURE is not set<br>
&gt; # CONFIG_USB_ISIGHTFW is not set<br>
&gt; # CONFIG_USB_YUREX is not set<br>
&gt; # CONFIG_USB_EZUSB_FX2 is not set<br>
&gt; # CONFIG_USB_HUB_USB251XB is not set<br>
&gt; # CONFIG_USB_HSIC_USB3503 is not set<br>
&gt; # CONFIG_USB_HSIC_USB4604 is not set<br>
&gt; # CONFIG_USB_LINK_LAYER_TEST is not set<br>
&gt; # CONFIG_USB_CHAOSKEY is not set<br>
&gt; CONFIG_USB_ATM=3Dy<br>
&gt; # CONFIG_USB_SPEEDTOUCH is not set<br>
&gt; # CONFIG_USB_CXACRU is not set<br>
&gt; # CONFIG_USB_UEAGLEATM is not set<br>
&gt; # CONFIG_USB_XUSBATM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Physical Layer drivers<br>
&gt; #<br>
&gt; # CONFIG_USB_PHY is not set<br>
&gt; # CONFIG_NOP_USB_XCEIV is not set<br>
&gt; # CONFIG_USB_ISP1301 is not set<br>
&gt; # CONFIG_USB_GADGET is not set<br>
&gt; CONFIG_TYPEC=3Dy<br>
&gt; CONFIG_TYPEC_TCPM=3Dy<br>
&gt; # CONFIG_TYPEC_FUSB302 is not set<br>
&gt; CONFIG_TYPEC_UCSI=3Dy<br>
&gt; CONFIG_UCSI_ACPI=3Dy<br>
&gt; # CONFIG_TYPEC_TPS6598X is not set<br>
&gt; # CONFIG_USB_LED_TRIG is not set<br>
&gt; # CONFIG_USB_ULPI_BUS is not set<br>
&gt; # CONFIG_UWB is not set<br>
&gt; # CONFIG_MMC is not set<br>
&gt; # CONFIG_MEMSTICK is not set<br>
&gt; CONFIG_NEW_LEDS=3Dy<br>
&gt; CONFIG_LEDS_CLASS=3Dy<br>
&gt; # CONFIG_LEDS_CLASS_FLASH is not set<br>
&gt; # CONFIG_LEDS_BRIGHTNESS_HW_<wbr>CHANGED is not set<br>
&gt;<br>
&gt; #<br>
&gt; # LED drivers<br>
&gt; #<br>
&gt; # CONFIG_LEDS_APU is not set<br>
&gt; # CONFIG_LEDS_LM3530 is not set<br>
&gt; # CONFIG_LEDS_LM3642 is not set<br>
&gt; # CONFIG_LEDS_PCA9532 is not set<br>
&gt; # CONFIG_LEDS_LP3944 is not set<br>
&gt; # CONFIG_LEDS_LP5521 is not set<br>
&gt; # CONFIG_LEDS_LP5523 is not set<br>
&gt; # CONFIG_LEDS_LP5562 is not set<br>
&gt; # CONFIG_LEDS_LP8501 is not set<br>
&gt; # CONFIG_LEDS_CLEVO_MAIL is not set<br>
&gt; # CONFIG_LEDS_PCA955X is not set<br>
&gt; # CONFIG_LEDS_PCA963X is not set<br>
&gt; # CONFIG_LEDS_BD2802 is not set<br>
&gt; # CONFIG_LEDS_INTEL_SS4200 is not set<br>
&gt; # CONFIG_LEDS_TCA6507 is not set<br>
&gt; # CONFIG_LEDS_TLC591XX is not set<br>
&gt; # CONFIG_LEDS_LM355x is not set<br>
&gt;<br>
&gt; #<br>
&gt; # LED driver for blink(1) USB RGB LED is under Special HID drivers (HI=
D_THINGM)<br>
&gt; #<br>
&gt; # CONFIG_LEDS_BLINKM is not set<br>
&gt; # CONFIG_LEDS_MLXCPLD is not set<br>
&gt; # CONFIG_LEDS_USER is not set<br>
&gt; # CONFIG_LEDS_NIC78BX is not set<br>
&gt;<br>
&gt; #<br>
&gt; # LED Triggers<br>
&gt; #<br>
&gt; CONFIG_LEDS_TRIGGERS=3Dy<br>
&gt; # CONFIG_LEDS_TRIGGER_TIMER is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_ONESHOT is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_DISK is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_HEARTBEAT is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_BACKLIGHT is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_CPU is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_ACTIVITY is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_DEFAULT_ON is not set<br>
&gt;<br>
&gt; #<br>
&gt; # iptables trigger is under Netfilter config (LED target)<br>
&gt; #<br>
&gt; # CONFIG_LEDS_TRIGGER_TRANSIENT is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_CAMERA is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_PANIC is not set<br>
&gt; # CONFIG_LEDS_TRIGGER_NETDEV is not set<br>
&gt; # CONFIG_ACCESSIBILITY is not set<br>
&gt; CONFIG_INFINIBAND=3Dy<br>
&gt; CONFIG_INFINIBAND_USER_MAD=3Dy<br>
&gt; CONFIG_INFINIBAND_USER_ACCESS=3D<wbr>y<br>
&gt; CONFIG_INFINIBAND_EXP_USER_<wbr>ACCESS=3Dy<br>
&gt; CONFIG_INFINIBAND_USER_MEM=3Dy<br>
&gt; CONFIG_INFINIBAND_ON_DEMAND_<wbr>PAGING=3Dy<br>
&gt; CONFIG_INFINIBAND_ADDR_TRANS=3Dy<br>
&gt; CONFIG_INFINIBAND_ADDR_TRANS_<wbr>CONFIGFS=3Dy<br>
&gt; # CONFIG_INFINIBAND_MTHCA is not set<br>
&gt; # CONFIG_INFINIBAND_QIB is not set<br>
&gt; # CONFIG_MLX4_INFINIBAND is not set<br>
&gt; # CONFIG_INFINIBAND_NES is not set<br>
&gt; # CONFIG_INFINIBAND_OCRDMA is not set<br>
&gt; CONFIG_INFINIBAND_USNIC=3Dy<br>
&gt; CONFIG_INFINIBAND_IPOIB=3Dy<br>
&gt; CONFIG_INFINIBAND_IPOIB_CM=3Dy<br>
&gt; CONFIG_INFINIBAND_IPOIB_DEBUG=3D<wbr>y<br>
&gt; # CONFIG_INFINIBAND_IPOIB_DEBUG_<wbr>DATA is not set<br>
&gt; CONFIG_INFINIBAND_SRP=3Dy<br>
&gt; CONFIG_INFINIBAND_ISER=3Dy<br>
&gt; CONFIG_INFINIBAND_OPA_VNIC=3Dy<br>
&gt; CONFIG_INFINIBAND_RDMAVT=3Dy<br>
&gt; CONFIG_RDMA_RXE=3Dy<br>
&gt; # CONFIG_INFINIBAND_HFI1 is not set<br>
&gt; # CONFIG_INFINIBAND_BNXT_RE is not set<br>
&gt; CONFIG_EDAC_ATOMIC_SCRUB=3Dy<br>
&gt; CONFIG_EDAC_SUPPORT=3Dy<br>
&gt; CONFIG_EDAC=3Dy<br>
&gt; CONFIG_EDAC_LEGACY_SYSFS=3Dy<br>
&gt; # CONFIG_EDAC_DEBUG is not set<br>
&gt; CONFIG_EDAC_DECODE_MCE=3Dy<br>
&gt; # CONFIG_EDAC_AMD64 is not set<br>
&gt; # CONFIG_EDAC_E752X is not set<br>
&gt; # CONFIG_EDAC_I82975X is not set<br>
&gt; # CONFIG_EDAC_I3000 is not set<br>
&gt; # CONFIG_EDAC_I3200 is not set<br>
&gt; # CONFIG_EDAC_IE31200 is not set<br>
&gt; # CONFIG_EDAC_X38 is not set<br>
&gt; # CONFIG_EDAC_I5400 is not set<br>
&gt; # CONFIG_EDAC_I7CORE is not set<br>
&gt; # CONFIG_EDAC_I5000 is not set<br>
&gt; # CONFIG_EDAC_I5100 is not set<br>
&gt; # CONFIG_EDAC_I7300 is not set<br>
&gt; # CONFIG_EDAC_SBRIDGE is not set<br>
&gt; # CONFIG_EDAC_SKX is not set<br>
&gt; # CONFIG_EDAC_PND2 is not set<br>
&gt; CONFIG_RTC_LIB=3Dy<br>
&gt; CONFIG_RTC_MC146818_LIB=3Dy<br>
&gt; CONFIG_RTC_CLASS=3Dy<br>
&gt; # CONFIG_RTC_HCTOSYS is not set<br>
&gt; CONFIG_RTC_SYSTOHC=3Dy<br>
&gt; CONFIG_RTC_SYSTOHC_DEVICE=3D&quot;<wbr>rtc0&quot;<br>
&gt; # CONFIG_RTC_DEBUG is not set<br>
&gt; # CONFIG_RTC_NVMEM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # RTC interfaces<br>
&gt; #<br>
&gt; CONFIG_RTC_INTF_SYSFS=3Dy<br>
&gt; CONFIG_RTC_INTF_PROC=3Dy<br>
&gt; CONFIG_RTC_INTF_DEV=3Dy<br>
&gt; # CONFIG_RTC_INTF_DEV_UIE_EMUL is not set<br>
&gt; # CONFIG_RTC_DRV_TEST is not set<br>
&gt;<br>
&gt; #<br>
&gt; # I2C RTC drivers<br>
&gt; #<br>
&gt; # CONFIG_RTC_DRV_ABB5ZES3 is not set<br>
&gt; # CONFIG_RTC_DRV_ABX80X is not set<br>
&gt; # CONFIG_RTC_DRV_DS1307 is not set<br>
&gt; # CONFIG_RTC_DRV_DS1374 is not set<br>
&gt; # CONFIG_RTC_DRV_DS1672 is not set<br>
&gt; # CONFIG_RTC_DRV_MAX6900 is not set<br>
&gt; # CONFIG_RTC_DRV_RS5C372 is not set<br>
&gt; # CONFIG_RTC_DRV_ISL1208 is not set<br>
&gt; # CONFIG_RTC_DRV_ISL12022 is not set<br>
&gt; # CONFIG_RTC_DRV_X1205 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF8523 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF85063 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF85363 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF8563 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF8583 is not set<br>
&gt; # CONFIG_RTC_DRV_M41T80 is not set<br>
&gt; # CONFIG_RTC_DRV_BQ32K is not set<br>
&gt; # CONFIG_RTC_DRV_S35390A is not set<br>
&gt; # CONFIG_RTC_DRV_FM3130 is not set<br>
&gt; # CONFIG_RTC_DRV_RX8010 is not set<br>
&gt; # CONFIG_RTC_DRV_RX8581 is not set<br>
&gt; # CONFIG_RTC_DRV_RX8025 is not set<br>
&gt; # CONFIG_RTC_DRV_EM3027 is not set<br>
&gt; # CONFIG_RTC_DRV_RV8803 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # SPI RTC drivers<br>
&gt; #<br>
&gt; CONFIG_RTC_I2C_AND_SPI=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # SPI and I2C RTC drivers<br>
&gt; #<br>
&gt; # CONFIG_RTC_DRV_DS3232 is not set<br>
&gt; # CONFIG_RTC_DRV_PCF2127 is not set<br>
&gt; # CONFIG_RTC_DRV_RV3029C2 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Platform RTC drivers<br>
&gt; #<br>
&gt; CONFIG_RTC_DRV_CMOS=3Dy<br>
&gt; # CONFIG_RTC_DRV_DS1286 is not set<br>
&gt; # CONFIG_RTC_DRV_DS1511 is not set<br>
&gt; # CONFIG_RTC_DRV_DS1553 is not set<br>
&gt; # CONFIG_RTC_DRV_DS1685_FAMILY is not set<br>
&gt; # CONFIG_RTC_DRV_DS1742 is not set<br>
&gt; # CONFIG_RTC_DRV_DS2404 is not set<br>
&gt; # CONFIG_RTC_DRV_STK17TA8 is not set<br>
&gt; # CONFIG_RTC_DRV_M48T86 is not set<br>
&gt; # CONFIG_RTC_DRV_M48T35 is not set<br>
&gt; # CONFIG_RTC_DRV_M48T59 is not set<br>
&gt; # CONFIG_RTC_DRV_MSM6242 is not set<br>
&gt; # CONFIG_RTC_DRV_BQ4802 is not set<br>
&gt; # CONFIG_RTC_DRV_RP5C01 is not set<br>
&gt; # CONFIG_RTC_DRV_V3020 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # on-CPU RTC drivers<br>
&gt; #<br>
&gt; # CONFIG_RTC_DRV_FTRTC010 is not set<br>
&gt;<br>
&gt; #<br>
&gt; # HID Sensor RTC drivers<br>
&gt; #<br>
&gt; # CONFIG_RTC_DRV_HID_SENSOR_TIME is not set<br>
&gt; CONFIG_DMADEVICES=3Dy<br>
&gt; # CONFIG_DMADEVICES_DEBUG is not set<br>
&gt;<br>
&gt; #<br>
&gt; # DMA Devices<br>
&gt; #<br>
&gt; CONFIG_DMA_ENGINE=3Dy<br>
&gt; CONFIG_DMA_VIRTUAL_CHANNELS=3Dy<br>
&gt; CONFIG_DMA_ACPI=3Dy<br>
&gt; # CONFIG_ALTERA_MSGDMA is not set<br>
&gt; # CONFIG_INTEL_IDMA64 is not set<br>
&gt; # CONFIG_INTEL_IOATDMA is not set<br>
&gt; # CONFIG_QCOM_HIDMA_MGMT is not set<br>
&gt; # CONFIG_QCOM_HIDMA is not set<br>
&gt; CONFIG_DW_DMAC_CORE=3Dy<br>
&gt; # CONFIG_DW_DMAC is not set<br>
&gt; # CONFIG_DW_DMAC_PCI is not set<br>
&gt; CONFIG_HSU_DMA=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # DMA Clients<br>
&gt; #<br>
&gt; # CONFIG_ASYNC_TX_DMA is not set<br>
&gt; # CONFIG_DMATEST is not set<br>
&gt;<br>
&gt; #<br>
&gt; # DMABUF options<br>
&gt; #<br>
&gt; CONFIG_SYNC_FILE=3Dy<br>
&gt; # CONFIG_SW_SYNC is not set<br>
&gt; # CONFIG_AUXDISPLAY is not set<br>
&gt; # CONFIG_UIO is not set<br>
&gt; # CONFIG_VFIO is not set<br>
&gt; CONFIG_IRQ_BYPASS_MANAGER=3Dy<br>
&gt; # CONFIG_VIRT_DRIVERS is not set<br>
&gt; CONFIG_VIRTIO=3Dy<br>
&gt; CONFIG_VIRTIO_MENU=3Dy<br>
&gt; CONFIG_VIRTIO_PCI=3Dy<br>
&gt; CONFIG_VIRTIO_PCI_LEGACY=3Dy<br>
&gt; CONFIG_VIRTIO_BALLOON=3Dy<br>
&gt; CONFIG_VIRTIO_INPUT=3Dy<br>
&gt; CONFIG_VIRTIO_MMIO=3Dy<br>
&gt; CONFIG_VIRTIO_MMIO_CMDLINE_<wbr>DEVICES=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Microsoft Hyper-V guest support<br>
&gt; #<br>
&gt; # CONFIG_HYPERV is not set<br>
&gt; # CONFIG_HYPERV_TSCPAGE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Xen driver support<br>
&gt; #<br>
&gt; CONFIG_XEN_BALLOON=3Dy<br>
&gt; CONFIG_XEN_SCRUB_PAGES=3Dy<br>
&gt; CONFIG_XEN_DEV_EVTCHN=3Dy<br>
&gt; CONFIG_XEN_BACKEND=3Dy<br>
&gt; CONFIG_XENFS=3Dy<br>
&gt; CONFIG_XEN_COMPAT_XENFS=3Dy<br>
&gt; CONFIG_XEN_SYS_HYPERVISOR=3Dy<br>
&gt; CONFIG_XEN_XENBUS_FRONTEND=3Dy<br>
&gt; CONFIG_XEN_GNTDEV=3Dy<br>
&gt; CONFIG_XEN_GRANT_DEV_ALLOC=3Dy<br>
&gt; CONFIG_SWIOTLB_XEN=3Dy<br>
&gt; CONFIG_XEN_TMEM=3Dm<br>
&gt; CONFIG_XEN_PCIDEV_BACKEND=3Dy<br>
&gt; CONFIG_XEN_PVCALLS_FRONTEND=3Dy<br>
&gt; CONFIG_XEN_PVCALLS_BACKEND=3Dy<br>
&gt; CONFIG_XEN_PRIVCMD=3Dy<br>
&gt; CONFIG_XEN_ACPI_PROCESSOR=3Dy<br>
&gt; CONFIG_XEN_MCE_LOG=3Dy<br>
&gt; CONFIG_XEN_HAVE_PVMMU=3Dy<br>
&gt; CONFIG_XEN_EFI=3Dy<br>
&gt; CONFIG_XEN_AUTO_XLATE=3Dy<br>
&gt; CONFIG_XEN_ACPI=3Dy<br>
&gt; CONFIG_XEN_SYMS=3Dy<br>
&gt; CONFIG_XEN_HAVE_VPMU=3Dy<br>
&gt; CONFIG_STAGING=3Dy<br>
&gt; # CONFIG_IRDA is not set<br>
&gt; # CONFIG_IPX is not set<br>
&gt; # CONFIG_NCP_FS is not set<br>
&gt; # CONFIG_PRISM2_USB is not set<br>
&gt; # CONFIG_COMEDI is not set<br>
&gt; # CONFIG_RTL8192U is not set<br>
&gt; # CONFIG_RTLLIB is not set<br>
&gt; # CONFIG_R8712U is not set<br>
&gt; # CONFIG_R8188EU is not set<br>
&gt; # CONFIG_R8822BE is not set<br>
&gt; # CONFIG_RTS5208 is not set<br>
&gt; # CONFIG_VT6655 is not set<br>
&gt; # CONFIG_VT6656 is not set<br>
&gt; # CONFIG_FB_SM750 is not set<br>
&gt; # CONFIG_FB_XGI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Speakup console speech<br>
&gt; #<br>
&gt; # CONFIG_SPEAKUP is not set<br>
&gt; # CONFIG_STAGING_MEDIA is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Android<br>
&gt; #<br>
&gt; CONFIG_ASHMEM=3Dy<br>
&gt; CONFIG_ION=3Dy<br>
&gt; CONFIG_ION_SYSTEM_HEAP=3Dy<br>
&gt; CONFIG_ION_CARVEOUT_HEAP=3Dy<br>
&gt; CONFIG_ION_CHUNK_HEAP=3Dy<br>
&gt; # CONFIG_LTE_GDM724X is not set<br>
&gt; # CONFIG_LNET is not set<br>
&gt; # CONFIG_DGNC is not set<br>
&gt; # CONFIG_GS_FPGABOOT is not set<br>
&gt; # CONFIG_CRYPTO_SKEIN is not set<br>
&gt; # CONFIG_UNISYSSPAR is not set<br>
&gt; # CONFIG_MOST is not set<br>
&gt; # CONFIG_GREYBUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # USB Power Delivery and Type-C drivers<br>
&gt; #<br>
&gt; # CONFIG_TYPEC_TCPCI is not set<br>
&gt; # CONFIG_DRM_VBOXVIDEO is not set<br>
&gt; CONFIG_X86_PLATFORM_DEVICES=3Dy<br>
&gt; # CONFIG_ACER_WIRELESS is not set<br>
&gt; # CONFIG_ACERHDF is not set<br>
&gt; # CONFIG_ASUS_LAPTOP is not set<br>
&gt; # CONFIG_DELL_LAPTOP is not set<br>
&gt; # CONFIG_DELL_SMO8800 is not set<br>
&gt; # CONFIG_DELL_RBTN is not set<br>
&gt; # CONFIG_FUJITSU_LAPTOP is not set<br>
&gt; # CONFIG_FUJITSU_TABLET is not set<br>
&gt; # CONFIG_AMILO_RFKILL is not set<br>
&gt; # CONFIG_GPD_POCKET_FAN is not set<br>
&gt; # CONFIG_HP_ACCEL is not set<br>
&gt; # CONFIG_HP_WIRELESS is not set<br>
&gt; # CONFIG_MSI_LAPTOP is not set<br>
&gt; # CONFIG_PANASONIC_LAPTOP is not set<br>
&gt; # CONFIG_COMPAL_LAPTOP is not set<br>
&gt; # CONFIG_SONY_LAPTOP is not set<br>
&gt; # CONFIG_IDEAPAD_LAPTOP is not set<br>
&gt; # CONFIG_THINKPAD_ACPI is not set<br>
&gt; # CONFIG_SENSORS_HDAPS is not set<br>
&gt; # CONFIG_INTEL_MENLOW is not set<br>
&gt; CONFIG_EEEPC_LAPTOP=3Dy<br>
&gt; # CONFIG_ASUS_WIRELESS is not set<br>
&gt; # CONFIG_ACPI_WMI is not set<br>
&gt; # CONFIG_TOPSTAR_LAPTOP is not set<br>
&gt; # CONFIG_TOSHIBA_BT_RFKILL is not set<br>
&gt; # CONFIG_TOSHIBA_HAPS is not set<br>
&gt; # CONFIG_ACPI_CMPC is not set<br>
&gt; # CONFIG_INTEL_HID_EVENT is not set<br>
&gt; # CONFIG_INTEL_VBTN is not set<br>
&gt; # CONFIG_INTEL_IPS is not set<br>
&gt; # CONFIG_INTEL_PMC_CORE is not set<br>
&gt; # CONFIG_IBM_RTL is not set<br>
&gt; # CONFIG_SAMSUNG_LAPTOP is not set<br>
&gt; # CONFIG_INTEL_OAKTRAIL is not set<br>
&gt; # CONFIG_SAMSUNG_Q10 is not set<br>
&gt; # CONFIG_APPLE_GMUX is not set<br>
&gt; # CONFIG_INTEL_RST is not set<br>
&gt; # CONFIG_INTEL_SMARTCONNECT is not set<br>
&gt; # CONFIG_PVPANIC is not set<br>
&gt; # CONFIG_INTEL_PMC_IPC is not set<br>
&gt; # CONFIG_SURFACE_PRO3_BUTTON is not set<br>
&gt; # CONFIG_INTEL_PUNIT_IPC is not set<br>
&gt; # CONFIG_MLX_PLATFORM is not set<br>
&gt; # CONFIG_INTEL_TURBO_MAX_3 is not set<br>
&gt; CONFIG_PMC_ATOM=3Dy<br>
&gt; # CONFIG_CHROME_PLATFORMS is not set<br>
&gt; # CONFIG_MELLANOX_PLATFORM is not set<br>
&gt; CONFIG_CLKDEV_LOOKUP=3Dy<br>
&gt; CONFIG_HAVE_CLK_PREPARE=3Dy<br>
&gt; CONFIG_COMMON_CLK=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Common Clock Framework<br>
&gt; #<br>
&gt; # CONFIG_COMMON_CLK_SI5351 is not set<br>
&gt; # CONFIG_COMMON_CLK_CDCE706 is not set<br>
&gt; # CONFIG_COMMON_CLK_CS2000_CP is not set<br>
&gt; # CONFIG_COMMON_CLK_NXP is not set<br>
&gt; # CONFIG_COMMON_CLK_PXA is not set<br>
&gt; # CONFIG_COMMON_CLK_PIC32 is not set<br>
&gt; # CONFIG_HWSPINLOCK is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Clock Source drivers<br>
&gt; #<br>
&gt; CONFIG_CLKEVT_I8253=3Dy<br>
&gt; CONFIG_I8253_LOCK=3Dy<br>
&gt; CONFIG_CLKBLD_I8253=3Dy<br>
&gt; # CONFIG_ATMEL_PIT is not set<br>
&gt; # CONFIG_SH_TIMER_CMT is not set<br>
&gt; # CONFIG_SH_TIMER_MTU2 is not set<br>
&gt; # CONFIG_SH_TIMER_TMU is not set<br>
&gt; # CONFIG_EM_TIMER_STI is not set<br>
&gt; CONFIG_MAILBOX=3Dy<br>
&gt; CONFIG_PCC=3Dy<br>
&gt; # CONFIG_ALTERA_MBOX is not set<br>
&gt; CONFIG_IOMMU_API=3Dy<br>
&gt; CONFIG_IOMMU_SUPPORT=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Generic IOMMU Pagetable Support<br>
&gt; #<br>
&gt; CONFIG_IOMMU_IOVA=3Dy<br>
&gt; CONFIG_AMD_IOMMU=3Dy<br>
&gt; # CONFIG_AMD_IOMMU_V2 is not set<br>
&gt; CONFIG_DMAR_TABLE=3Dy<br>
&gt; CONFIG_INTEL_IOMMU=3Dy<br>
&gt; # CONFIG_INTEL_IOMMU_SVM is not set<br>
&gt; # CONFIG_INTEL_IOMMU_DEFAULT_ON is not set<br>
&gt; CONFIG_INTEL_IOMMU_FLOPPY_WA=3Dy<br>
&gt; # CONFIG_IRQ_REMAP is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Remoteproc drivers<br>
&gt; #<br>
&gt; # CONFIG_REMOTEPROC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Rpmsg drivers<br>
&gt; #<br>
&gt; # CONFIG_RPMSG_QCOM_GLINK_RPM is not set<br>
&gt; # CONFIG_RPMSG_VIRTIO is not set<br>
&gt; # CONFIG_SOUNDWIRE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # SOC (System On Chip) specific Drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Amlogic SoC drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Broadcom SoC drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # i.MX SoC drivers<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # Qualcomm SoC drivers<br>
&gt; #<br>
&gt; # CONFIG_SUNXI_SRAM is not set<br>
&gt; # CONFIG_SOC_TI is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Xilinx SoC drivers<br>
&gt; #<br>
&gt; # CONFIG_XILINX_VCU is not set<br>
&gt; # CONFIG_PM_DEVFREQ is not set<br>
&gt; # CONFIG_EXTCON is not set<br>
&gt; # CONFIG_MEMORY is not set<br>
&gt; # CONFIG_IIO is not set<br>
&gt; # CONFIG_NTB is not set<br>
&gt; # CONFIG_VME_BUS is not set<br>
&gt; # CONFIG_PWM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # IRQ chip support<br>
&gt; #<br>
&gt; CONFIG_ARM_GIC_MAX_NR=3D1<br>
&gt; # CONFIG_ARM_GIC_V3_ITS is not set<br>
&gt; # CONFIG_IPACK_BUS is not set<br>
&gt; # CONFIG_RESET_CONTROLLER is not set<br>
&gt; # CONFIG_FMC is not set<br>
&gt;<br>
&gt; #<br>
&gt; # PHY Subsystem<br>
&gt; #<br>
&gt; # CONFIG_GENERIC_PHY is not set<br>
&gt; # CONFIG_BCM_KONA_USB2_PHY is not set<br>
&gt; # CONFIG_PHY_PXA_28NM_HSIC is not set<br>
&gt; # CONFIG_PHY_PXA_28NM_USB2 is not set<br>
&gt; # CONFIG_POWERCAP is not set<br>
&gt; # CONFIG_MCB is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Performance monitor support<br>
&gt; #<br>
&gt; CONFIG_RAS=3Dy<br>
&gt; # CONFIG_THUNDERBOLT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Android<br>
&gt; #<br>
&gt; CONFIG_ANDROID=3Dy<br>
&gt; CONFIG_ANDROID_BINDER_IPC=3Dy<br>
&gt; CONFIG_ANDROID_BINDER_DEVICES=3D<wbr>&quot;binder0,binder1,binder2,<wb=
r>binder3,binder4,binder5,<wbr>binder6,binder7,binder8,<wbr>binder9,binder1=
0,binder11,<wbr>binder12,binder13,binder14,<wbr>binder15,binder16,binder17,=
<wbr>binder18,binder19,binder20,<wbr>binder21,binder22,binder23,<wbr>binder=
24,binder25,binder26,<wbr>binder27,binder28,binder29,<wbr>binder30,binder31=
&quot;<br>
&gt; # CONFIG_ANDROID_BINDER_IPC_<wbr>SELFTEST is not set<br>
&gt; # CONFIG_LIBNVDIMM is not set<br>
&gt; CONFIG_DAX=3Dy<br>
&gt; # CONFIG_DEV_DAX is not set<br>
&gt; # CONFIG_NVMEM is not set<br>
&gt; # CONFIG_STM is not set<br>
&gt; # CONFIG_INTEL_TH is not set<br>
&gt; # CONFIG_FPGA is not set<br>
&gt; # CONFIG_FSI is not set<br>
&gt; # CONFIG_UNISYS_VISORBUS is not set<br>
&gt; # CONFIG_SIOX is not set<br>
&gt; # CONFIG_SLIMBUS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Firmware Drivers<br>
&gt; #<br>
&gt; # CONFIG_EDD is not set<br>
&gt; CONFIG_FIRMWARE_MEMMAP=3Dy<br>
&gt; # CONFIG_DELL_RBU is not set<br>
&gt; # CONFIG_DCDBAS is not set<br>
&gt; CONFIG_DMIID=3Dy<br>
&gt; # CONFIG_DMI_SYSFS is not set<br>
&gt; CONFIG_DMI_SCAN_MACHINE_NON_<wbr>EFI_FALLBACK=3Dy<br>
&gt; # CONFIG_ISCSI_IBFT_FIND is not set<br>
&gt; # CONFIG_FW_CFG_SYSFS is not set<br>
&gt; # CONFIG_GOOGLE_FIRMWARE is not set<br>
&gt;<br>
&gt; #<br>
&gt; # EFI (Extensible Firmware Interface) Support<br>
&gt; #<br>
&gt; CONFIG_EFI_VARS=3Dy<br>
&gt; CONFIG_EFI_ESRT=3Dy<br>
&gt; CONFIG_EFI_RUNTIME_MAP=3Dy<br>
&gt; # CONFIG_EFI_FAKE_MEMMAP is not set<br>
&gt; CONFIG_EFI_RUNTIME_WRAPPERS=3Dy<br>
&gt; # CONFIG_EFI_BOOTLOADER_CONTROL is not set<br>
&gt; # CONFIG_EFI_CAPSULE_LOADER is not set<br>
&gt; # CONFIG_EFI_TEST is not set<br>
&gt; # CONFIG_EFI_DEV_PATH_PARSER is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Tegra firmware driver<br>
&gt; #<br>
&gt;<br>
&gt; #<br>
&gt; # File systems<br>
&gt; #<br>
&gt; CONFIG_DCACHE_WORD_ACCESS=3Dy<br>
&gt; CONFIG_FS_IOMAP=3Dy<br>
&gt; # CONFIG_EXT2_FS is not set<br>
&gt; # CONFIG_EXT3_FS is not set<br>
&gt; CONFIG_EXT4_FS=3Dy<br>
&gt; CONFIG_EXT4_USE_FOR_EXT2=3Dy<br>
&gt; CONFIG_EXT4_FS_POSIX_ACL=3Dy<br>
&gt; CONFIG_EXT4_FS_SECURITY=3Dy<br>
&gt; CONFIG_EXT4_ENCRYPTION=3Dy<br>
&gt; CONFIG_EXT4_FS_ENCRYPTION=3Dy<br>
&gt; # CONFIG_EXT4_DEBUG is not set<br>
&gt; CONFIG_JBD2=3Dy<br>
&gt; # CONFIG_JBD2_DEBUG is not set<br>
&gt; CONFIG_FS_MBCACHE=3Dy<br>
&gt; # CONFIG_REISERFS_FS is not set<br>
&gt; # CONFIG_JFS_FS is not set<br>
&gt; # CONFIG_XFS_FS is not set<br>
&gt; # CONFIG_GFS2_FS is not set<br>
&gt; # CONFIG_OCFS2_FS is not set<br>
&gt; # CONFIG_BTRFS_FS is not set<br>
&gt; # CONFIG_NILFS2_FS is not set<br>
&gt; # CONFIG_F2FS_FS is not set<br>
&gt; # CONFIG_FS_DAX is not set<br>
&gt; CONFIG_FS_POSIX_ACL=3Dy<br>
&gt; CONFIG_EXPORTFS=3Dy<br>
&gt; # CONFIG_EXPORTFS_BLOCK_OPS is not set<br>
&gt; CONFIG_FILE_LOCKING=3Dy<br>
&gt; CONFIG_MANDATORY_FILE_LOCKING=3D<wbr>y<br>
&gt; CONFIG_FS_ENCRYPTION=3Dy<br>
&gt; CONFIG_FSNOTIFY=3Dy<br>
&gt; CONFIG_DNOTIFY=3Dy<br>
&gt; CONFIG_INOTIFY_USER=3Dy<br>
&gt; CONFIG_FANOTIFY=3Dy<br>
&gt; CONFIG_FANOTIFY_ACCESS_<wbr>PERMISSIONS=3Dy<br>
&gt; CONFIG_QUOTA=3Dy<br>
&gt; CONFIG_QUOTA_NETLINK_<wbr>INTERFACE=3Dy<br>
&gt; # CONFIG_PRINT_QUOTA_WARNING is not set<br>
&gt; # CONFIG_QUOTA_DEBUG is not set<br>
&gt; CONFIG_QUOTA_TREE=3Dy<br>
&gt; # CONFIG_QFMT_V1 is not set<br>
&gt; CONFIG_QFMT_V2=3Dy<br>
&gt; CONFIG_QUOTACTL=3Dy<br>
&gt; CONFIG_QUOTACTL_COMPAT=3Dy<br>
&gt; CONFIG_AUTOFS4_FS=3Dy<br>
&gt; CONFIG_FUSE_FS=3Dy<br>
&gt; CONFIG_CUSE=3Dy<br>
&gt; CONFIG_OVERLAY_FS=3Dy<br>
&gt; CONFIG_OVERLAY_FS_REDIRECT_<wbr>DIR=3Dy<br>
&gt; CONFIG_OVERLAY_FS_REDIRECT_<wbr>ALWAYS_FOLLOW=3Dy<br>
&gt; CONFIG_OVERLAY_FS_INDEX=3Dy<br>
&gt; # CONFIG_OVERLAY_FS_NFS_EXPORT is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Caches<br>
&gt; #<br>
&gt; CONFIG_FSCACHE=3Dy<br>
&gt; # CONFIG_FSCACHE_STATS is not set<br>
&gt; # CONFIG_FSCACHE_HISTOGRAM is not set<br>
&gt; # CONFIG_FSCACHE_DEBUG is not set<br>
&gt; # CONFIG_FSCACHE_OBJECT_LIST is not set<br>
&gt; # CONFIG_CACHEFILES is not set<br>
&gt;<br>
&gt; #<br>
&gt; # CD-ROM/DVD Filesystems<br>
&gt; #<br>
&gt; CONFIG_ISO9660_FS=3Dy<br>
&gt; CONFIG_JOLIET=3Dy<br>
&gt; CONFIG_ZISOFS=3Dy<br>
&gt; # CONFIG_UDF_FS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # DOS/FAT/NT Filesystems<br>
&gt; #<br>
&gt; CONFIG_FAT_FS=3Dy<br>
&gt; CONFIG_MSDOS_FS=3Dy<br>
&gt; CONFIG_VFAT_FS=3Dy<br>
&gt; CONFIG_FAT_DEFAULT_CODEPAGE=3D<wbr>437<br>
&gt; CONFIG_FAT_DEFAULT_IOCHARSET=3D&quot;<wbr>iso8859-1&quot;<br>
&gt; # CONFIG_FAT_DEFAULT_UTF8 is not set<br>
&gt; # CONFIG_NTFS_FS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Pseudo filesystems<br>
&gt; #<br>
&gt; CONFIG_PROC_FS=3Dy<br>
&gt; CONFIG_PROC_KCORE=3Dy<br>
&gt; CONFIG_PROC_VMCORE=3Dy<br>
&gt; CONFIG_PROC_SYSCTL=3Dy<br>
&gt; CONFIG_PROC_PAGE_MONITOR=3Dy<br>
&gt; CONFIG_PROC_CHILDREN=3Dy<br>
&gt; CONFIG_KERNFS=3Dy<br>
&gt; CONFIG_SYSFS=3Dy<br>
&gt; CONFIG_TMPFS=3Dy<br>
&gt; CONFIG_TMPFS_POSIX_ACL=3Dy<br>
&gt; CONFIG_TMPFS_XATTR=3Dy<br>
&gt; CONFIG_HUGETLBFS=3Dy<br>
&gt; CONFIG_HUGETLB_PAGE=3Dy<br>
&gt; CONFIG_CONFIGFS_FS=3Dy<br>
&gt; CONFIG_EFIVAR_FS=3Dy<br>
&gt; CONFIG_MISC_FILESYSTEMS=3Dy<br>
&gt; # CONFIG_ORANGEFS_FS is not set<br>
&gt; # CONFIG_ADFS_FS is not set<br>
&gt; # CONFIG_AFFS_FS is not set<br>
&gt; # CONFIG_ECRYPT_FS is not set<br>
&gt; # CONFIG_HFS_FS is not set<br>
&gt; # CONFIG_HFSPLUS_FS is not set<br>
&gt; # CONFIG_BEFS_FS is not set<br>
&gt; # CONFIG_BFS_FS is not set<br>
&gt; # CONFIG_EFS_FS is not set<br>
&gt; # CONFIG_CRAMFS is not set<br>
&gt; # CONFIG_SQUASHFS is not set<br>
&gt; # CONFIG_VXFS_FS is not set<br>
&gt; # CONFIG_MINIX_FS is not set<br>
&gt; # CONFIG_OMFS_FS is not set<br>
&gt; # CONFIG_HPFS_FS is not set<br>
&gt; # CONFIG_QNX4FS_FS is not set<br>
&gt; # CONFIG_QNX6FS_FS is not set<br>
&gt; # CONFIG_ROMFS_FS is not set<br>
&gt; # CONFIG_PSTORE is not set<br>
&gt; # CONFIG_SYSV_FS is not set<br>
&gt; # CONFIG_UFS_FS is not set<br>
&gt; CONFIG_NETWORK_FILESYSTEMS=3Dy<br>
&gt; CONFIG_NFS_FS=3Dy<br>
&gt; CONFIG_NFS_V2=3Dy<br>
&gt; CONFIG_NFS_V3=3Dy<br>
&gt; CONFIG_NFS_V3_ACL=3Dy<br>
&gt; CONFIG_NFS_V4=3Dy<br>
&gt; # CONFIG_NFS_SWAP is not set<br>
&gt; # CONFIG_NFS_V4_1 is not set<br>
&gt; CONFIG_ROOT_NFS=3Dy<br>
&gt; # CONFIG_NFS_FSCACHE is not set<br>
&gt; # CONFIG_NFS_USE_LEGACY_DNS is not set<br>
&gt; CONFIG_NFS_USE_KERNEL_DNS=3Dy<br>
&gt; # CONFIG_NFSD is not set<br>
&gt; CONFIG_GRACE_PERIOD=3Dy<br>
&gt; CONFIG_LOCKD=3Dy<br>
&gt; CONFIG_LOCKD_V4=3Dy<br>
&gt; CONFIG_NFS_ACL_SUPPORT=3Dy<br>
&gt; CONFIG_NFS_COMMON=3Dy<br>
&gt; CONFIG_SUNRPC=3Dy<br>
&gt; CONFIG_SUNRPC_GSS=3Dy<br>
&gt; CONFIG_RPCSEC_GSS_KRB5=3Dy<br>
&gt; # CONFIG_SUNRPC_DEBUG is not set<br>
&gt; CONFIG_SUNRPC_XPRT_RDMA=3Dy<br>
&gt; # CONFIG_CEPH_FS is not set<br>
&gt; # CONFIG_CIFS is not set<br>
&gt; # CONFIG_CODA_FS is not set<br>
&gt; # CONFIG_AFS_FS is not set<br>
&gt; CONFIG_9P_FS=3Dy<br>
&gt; # CONFIG_9P_FSCACHE is not set<br>
&gt; # CONFIG_9P_FS_POSIX_ACL is not set<br>
&gt; # CONFIG_9P_FS_SECURITY is not set<br>
&gt; CONFIG_NLS=3Dy<br>
&gt; CONFIG_NLS_DEFAULT=3D&quot;utf8&quot;<br>
&gt; CONFIG_NLS_CODEPAGE_437=3Dy<br>
&gt; # CONFIG_NLS_CODEPAGE_737 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_775 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_850 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_852 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_855 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_857 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_860 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_861 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_862 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_863 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_864 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_865 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_866 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_869 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_936 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_950 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_932 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_949 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_874 is not set<br>
&gt; # CONFIG_NLS_ISO8859_8 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_1250 is not set<br>
&gt; # CONFIG_NLS_CODEPAGE_1251 is not set<br>
&gt; CONFIG_NLS_ASCII=3Dy<br>
&gt; CONFIG_NLS_ISO8859_1=3Dy<br>
&gt; # CONFIG_NLS_ISO8859_2 is not set<br>
&gt; # CONFIG_NLS_ISO8859_3 is not set<br>
&gt; # CONFIG_NLS_ISO8859_4 is not set<br>
&gt; # CONFIG_NLS_ISO8859_5 is not set<br>
&gt; # CONFIG_NLS_ISO8859_6 is not set<br>
&gt; # CONFIG_NLS_ISO8859_7 is not set<br>
&gt; # CONFIG_NLS_ISO8859_9 is not set<br>
&gt; # CONFIG_NLS_ISO8859_13 is not set<br>
&gt; # CONFIG_NLS_ISO8859_14 is not set<br>
&gt; # CONFIG_NLS_ISO8859_15 is not set<br>
&gt; # CONFIG_NLS_KOI8_R is not set<br>
&gt; # CONFIG_NLS_KOI8_U is not set<br>
&gt; # CONFIG_NLS_MAC_ROMAN is not set<br>
&gt; # CONFIG_NLS_MAC_CELTIC is not set<br>
&gt; # CONFIG_NLS_MAC_CENTEURO is not set<br>
&gt; # CONFIG_NLS_MAC_CROATIAN is not set<br>
&gt; # CONFIG_NLS_MAC_CYRILLIC is not set<br>
&gt; # CONFIG_NLS_MAC_GAELIC is not set<br>
&gt; # CONFIG_NLS_MAC_GREEK is not set<br>
&gt; # CONFIG_NLS_MAC_ICELAND is not set<br>
&gt; # CONFIG_NLS_MAC_INUIT is not set<br>
&gt; # CONFIG_NLS_MAC_ROMANIAN is not set<br>
&gt; # CONFIG_NLS_MAC_TURKISH is not set<br>
&gt; CONFIG_NLS_UTF8=3Dy<br>
&gt; # CONFIG_DLM is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Kernel hacking<br>
&gt; #<br>
&gt; CONFIG_TRACE_IRQFLAGS_SUPPORT=3D<wbr>y<br>
&gt;<br>
&gt; #<br>
&gt; # printk and dmesg options<br>
&gt; #<br>
&gt; CONFIG_PRINTK_TIME=3Dy<br>
&gt; CONFIG_CONSOLE_LOGLEVEL_<wbr>DEFAULT=3D7<br>
&gt; CONFIG_MESSAGE_LOGLEVEL_<wbr>DEFAULT=3D4<br>
&gt; # CONFIG_BOOT_PRINTK_DELAY is not set<br>
&gt; # CONFIG_DYNAMIC_DEBUG is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Compile-time checks and compiler options<br>
&gt; #<br>
&gt; CONFIG_DEBUG_INFO=3Dy<br>
&gt; # CONFIG_DEBUG_INFO_REDUCED is not set<br>
&gt; # CONFIG_DEBUG_INFO_SPLIT is not set<br>
&gt; # CONFIG_DEBUG_INFO_DWARF4 is not set<br>
&gt; # CONFIG_GDB_SCRIPTS is not set<br>
&gt; # CONFIG_ENABLE_WARN_DEPRECATED is not set<br>
&gt; CONFIG_ENABLE_MUST_CHECK=3Dy<br>
&gt; CONFIG_FRAME_WARN=3D2048<br>
&gt; # CONFIG_STRIP_ASM_SYMS is not set<br>
&gt; # CONFIG_READABLE_ASM is not set<br>
&gt; # CONFIG_UNUSED_SYMBOLS is not set<br>
&gt; # CONFIG_PAGE_OWNER is not set<br>
&gt; CONFIG_DEBUG_FS=3Dy<br>
&gt; # CONFIG_HEADERS_CHECK is not set<br>
&gt; # CONFIG_DEBUG_SECTION_MISMATCH is not set<br>
&gt; CONFIG_SECTION_MISMATCH_WARN_<wbr>ONLY=3Dy<br>
&gt; CONFIG_FRAME_POINTER=3Dy<br>
&gt; # CONFIG_STACK_VALIDATION is not set<br>
&gt; # CONFIG_DEBUG_FORCE_WEAK_PER_<wbr>CPU is not set<br>
&gt; CONFIG_MAGIC_SYSRQ=3Dy<br>
&gt; CONFIG_MAGIC_SYSRQ_DEFAULT_<wbr>ENABLE=3D0x1<br>
&gt; CONFIG_MAGIC_SYSRQ_SERIAL=3Dy<br>
&gt; CONFIG_DEBUG_KERNEL=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Memory Debugging<br>
&gt; #<br>
&gt; CONFIG_PAGE_EXTENSION=3Dy<br>
&gt; # CONFIG_DEBUG_PAGEALLOC is not set<br>
&gt; CONFIG_PAGE_POISONING=3Dy<br>
&gt; CONFIG_PAGE_POISONING_NO_<wbr>SANITY=3Dy<br>
&gt; # CONFIG_PAGE_POISONING_ZERO is not set<br>
&gt; # CONFIG_DEBUG_PAGE_REF is not set<br>
&gt; # CONFIG_DEBUG_RODATA_TEST is not set<br>
&gt; CONFIG_DEBUG_OBJECTS=3Dy<br>
&gt; # CONFIG_DEBUG_OBJECTS_SELFTEST is not set<br>
&gt; CONFIG_DEBUG_OBJECTS_FREE=3Dy<br>
&gt; CONFIG_DEBUG_OBJECTS_TIMERS=3Dy<br>
&gt; CONFIG_DEBUG_OBJECTS_WORK=3Dy<br>
&gt; CONFIG_DEBUG_OBJECTS_RCU_HEAD=3D<wbr>y<br>
&gt; CONFIG_DEBUG_OBJECTS_PERCPU_<wbr>COUNTER=3Dy<br>
&gt; CONFIG_DEBUG_OBJECTS_ENABLE_<wbr>DEFAULT=3D1<br>
&gt; # CONFIG_DEBUG_SLAB is not set<br>
&gt; CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy<br>
&gt; # CONFIG_DEBUG_KMEMLEAK is not set<br>
&gt; CONFIG_DEBUG_STACK_USAGE=3Dy<br>
&gt; CONFIG_DEBUG_VM=3Dy<br>
&gt; CONFIG_DEBUG_VM_VMACACHE=3Dy<br>
&gt; # CONFIG_DEBUG_VM_RB is not set<br>
&gt; # CONFIG_DEBUG_VM_PGFLAGS is not set<br>
&gt; CONFIG_ARCH_HAS_DEBUG_VIRTUAL=3D<wbr>y<br>
&gt; # CONFIG_DEBUG_VIRTUAL is not set<br>
&gt; CONFIG_DEBUG_MEMORY_INIT=3Dy<br>
&gt; # CONFIG_DEBUG_PER_CPU_MAPS is not set<br>
&gt; CONFIG_HAVE_DEBUG_<wbr>STACKOVERFLOW=3Dy<br>
&gt; CONFIG_DEBUG_STACKOVERFLOW=3Dy<br>
&gt; CONFIG_HAVE_ARCH_KASAN=3Dy<br>
&gt; CONFIG_KASAN=3Dy<br>
&gt; CONFIG_KASAN_EXTRA=3Dy<br>
&gt; # CONFIG_KASAN_OUTLINE is not set<br>
&gt; CONFIG_KASAN_INLINE=3Dy<br>
&gt; # CONFIG_TEST_KASAN is not set<br>
&gt; CONFIG_ARCH_HAS_KCOV=3Dy<br>
&gt; CONFIG_KCOV=3Dy<br>
&gt; CONFIG_KCOV_ENABLE_<wbr>COMPARISONS=3Dy<br>
&gt; CONFIG_KCOV_INSTRUMENT_ALL=3Dy<br>
&gt; # CONFIG_DEBUG_SHIRQ is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Debug Lockups and Hangs<br>
&gt; #<br>
&gt; CONFIG_LOCKUP_DETECTOR=3Dy<br>
&gt; CONFIG_SOFTLOCKUP_DETECTOR=3Dy<br>
&gt; CONFIG_HARDLOCKUP_DETECTOR_<wbr>PERF=3Dy<br>
&gt; CONFIG_HARDLOCKUP_CHECK_<wbr>TIMESTAMP=3Dy<br>
&gt; CONFIG_HARDLOCKUP_DETECTOR=3Dy<br>
&gt; CONFIG_BOOTPARAM_HARDLOCKUP_<wbr>PANIC=3Dy<br>
&gt; CONFIG_BOOTPARAM_HARDLOCKUP_<wbr>PANIC_VALUE=3D1<br>
&gt; CONFIG_BOOTPARAM_SOFTLOCKUP_<wbr>PANIC=3Dy<br>
&gt; CONFIG_BOOTPARAM_SOFTLOCKUP_<wbr>PANIC_VALUE=3D1<br>
&gt; CONFIG_DETECT_HUNG_TASK=3Dy<br>
&gt; CONFIG_DEFAULT_HUNG_TASK_<wbr>TIMEOUT=3D120<br>
&gt; CONFIG_BOOTPARAM_HUNG_TASK_<wbr>PANIC=3Dy<br>
&gt; CONFIG_BOOTPARAM_HUNG_TASK_<wbr>PANIC_VALUE=3D1<br>
&gt; CONFIG_WQ_WATCHDOG=3Dy<br>
&gt; CONFIG_PANIC_ON_OOPS=3Dy<br>
&gt; CONFIG_PANIC_ON_OOPS_VALUE=3D1<br>
&gt; CONFIG_PANIC_TIMEOUT=3D86400<br>
&gt; # CONFIG_SCHED_DEBUG is not set<br>
&gt; CONFIG_SCHED_INFO=3Dy<br>
&gt; CONFIG_SCHEDSTATS=3Dy<br>
&gt; CONFIG_SCHED_STACK_END_CHECK=3Dy<br>
&gt; # CONFIG_DEBUG_TIMEKEEPING is not set<br>
&gt;<br>
&gt; #<br>
&gt; # Lock Debugging (spinlocks, mutexes, etc...)<br>
&gt; #<br>
&gt; CONFIG_DEBUG_RT_MUTEXES=3Dy<br>
&gt; CONFIG_DEBUG_SPINLOCK=3Dy<br>
&gt; CONFIG_DEBUG_MUTEXES=3Dy<br>
&gt; # CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set<br>
&gt; CONFIG_DEBUG_LOCK_ALLOC=3Dy<br>
&gt; CONFIG_PROVE_LOCKING=3Dy<br>
&gt; CONFIG_LOCKDEP=3Dy<br>
&gt; # CONFIG_LOCK_STAT is not set<br>
&gt; # CONFIG_DEBUG_LOCKDEP is not set<br>
&gt; CONFIG_DEBUG_ATOMIC_SLEEP=3Dy<br>
&gt; # CONFIG_DEBUG_LOCKING_API_<wbr>SELFTESTS is not set<br>
&gt; # CONFIG_LOCK_TORTURE_TEST is not set<br>
&gt; # CONFIG_WW_MUTEX_SELFTEST is not set<br>
&gt; CONFIG_TRACE_IRQFLAGS=3Dy<br>
&gt; CONFIG_STACKTRACE=3Dy<br>
&gt; # CONFIG_WARN_ALL_UNSEEDED_<wbr>RANDOM is not set<br>
&gt; # CONFIG_DEBUG_KOBJECT is not set<br>
&gt; # CONFIG_DEBUG_KOBJECT_RELEASE is not set<br>
&gt; CONFIG_DEBUG_BUGVERBOSE=3Dy<br>
&gt; CONFIG_DEBUG_LIST=3Dy<br>
&gt; CONFIG_DEBUG_PI_LIST=3Dy<br>
&gt; # CONFIG_DEBUG_SG is not set<br>
&gt; CONFIG_DEBUG_NOTIFIERS=3Dy<br>
&gt; # CONFIG_DEBUG_CREDENTIALS is not set<br>
&gt;<br>
&gt; #<br>
&gt; # RCU Debugging<br>
&gt; #<br>
&gt; CONFIG_PROVE_RCU=3Dy<br>
&gt; # CONFIG_TORTURE_TEST is not set<br>
&gt; # CONFIG_RCU_PERF_TEST is not set<br>
&gt; # CONFIG_RCU_TORTURE_TEST is not set<br>
&gt; CONFIG_RCU_CPU_STALL_TIMEOUT=3D<wbr>120<br>
&gt; # CONFIG_RCU_TRACE is not set<br>
&gt; # CONFIG_RCU_EQS_DEBUG is not set<br>
&gt; # CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set<br>
&gt; # CONFIG_DEBUG_BLOCK_EXT_DEVT is not set<br>
&gt; # CONFIG_CPU_HOTPLUG_STATE_<wbr>CONTROL is not set<br>
&gt; # CONFIG_NOTIFIER_ERROR_<wbr>INJECTION is not set<br>
&gt; CONFIG_FAULT_INJECTION=3Dy<br>
&gt; CONFIG_FUNCTION_ERROR_<wbr>INJECTION=3Dy<br>
&gt; CONFIG_FAILSLAB=3Dy<br>
&gt; CONFIG_FAIL_PAGE_ALLOC=3Dy<br>
&gt; CONFIG_FAIL_MAKE_REQUEST=3Dy<br>
&gt; CONFIG_FAIL_IO_TIMEOUT=3Dy<br>
&gt; CONFIG_FAIL_FUTEX=3Dy<br>
&gt; # CONFIG_FAIL_FUNCTION is not set<br>
&gt; CONFIG_FAULT_INJECTION_DEBUG_<wbr>FS=3Dy<br>
&gt; # CONFIG_LATENCYTOP is not set<br>
&gt; CONFIG_USER_STACKTRACE_<wbr>SUPPORT=3Dy<br>
&gt; CONFIG_NOP_TRACER=3Dy<br>
&gt; CONFIG_HAVE_FUNCTION_TRACER=3Dy<br>
&gt; CONFIG_HAVE_FUNCTION_GRAPH_<wbr>TRACER=3Dy<br>
&gt; CONFIG_HAVE_DYNAMIC_FTRACE=3Dy<br>
&gt; CONFIG_HAVE_DYNAMIC_FTRACE_<wbr>WITH_REGS=3Dy<br>
&gt; CONFIG_HAVE_FTRACE_MCOUNT_<wbr>RECORD=3Dy<br>
&gt; CONFIG_HAVE_SYSCALL_<wbr>TRACEPOINTS=3Dy<br>
&gt; CONFIG_HAVE_FENTRY=3Dy<br>
&gt; CONFIG_HAVE_C_RECORDMCOUNT=3Dy<br>
&gt; CONFIG_TRACE_CLOCK=3Dy<br>
&gt; CONFIG_RING_BUFFER=3Dy<br>
&gt; CONFIG_EVENT_TRACING=3Dy<br>
&gt; CONFIG_CONTEXT_SWITCH_TRACER=3Dy<br>
&gt; CONFIG_TRACING=3Dy<br>
&gt; CONFIG_GENERIC_TRACER=3Dy<br>
&gt; CONFIG_TRACING_SUPPORT=3Dy<br>
&gt; CONFIG_FTRACE=3Dy<br>
&gt; # CONFIG_FUNCTION_TRACER is not set<br>
&gt; # CONFIG_IRQSOFF_TRACER is not set<br>
&gt; # CONFIG_SCHED_TRACER is not set<br>
&gt; # CONFIG_HWLAT_TRACER is not set<br>
&gt; # CONFIG_FTRACE_SYSCALLS is not set<br>
&gt; # CONFIG_TRACER_SNAPSHOT is not set<br>
&gt; CONFIG_BRANCH_PROFILE_NONE=3Dy<br>
&gt; # CONFIG_PROFILE_ANNOTATED_<wbr>BRANCHES is not set<br>
&gt; # CONFIG_STACK_TRACER is not set<br>
&gt; CONFIG_BLK_DEV_IO_TRACE=3Dy<br>
&gt; CONFIG_KPROBE_EVENTS=3Dy<br>
&gt; CONFIG_UPROBE_EVENTS=3Dy<br>
&gt; CONFIG_BPF_EVENTS=3Dy<br>
&gt; CONFIG_PROBE_EVENTS=3Dy<br>
&gt; # CONFIG_BPF_KPROBE_OVERRIDE is not set<br>
&gt; # CONFIG_FTRACE_STARTUP_TEST is not set<br>
&gt; # CONFIG_MMIOTRACE is not set<br>
&gt; # CONFIG_HIST_TRIGGERS is not set<br>
&gt; # CONFIG_TRACEPOINT_BENCHMARK is not set<br>
&gt; # CONFIG_RING_BUFFER_BENCHMARK is not set<br>
&gt; # CONFIG_RING_BUFFER_STARTUP_<wbr>TEST is not set<br>
&gt; # CONFIG_TRACE_EVAL_MAP_FILE is not set<br>
&gt; CONFIG_PROVIDE_OHCI1394_DMA_<wbr>INIT=3Dy<br>
&gt; # CONFIG_DMA_API_DEBUG is not set<br>
&gt; # CONFIG_RUNTIME_TESTING_MENU is not set<br>
&gt; # CONFIG_MEMTEST is not set<br>
&gt; CONFIG_BUG_ON_DATA_CORRUPTION=3D<wbr>y<br>
&gt; # CONFIG_SAMPLES is not set<br>
&gt; CONFIG_HAVE_ARCH_KGDB=3Dy<br>
&gt; # CONFIG_KGDB is not set<br>
&gt; CONFIG_ARCH_HAS_UBSAN_<wbr>SANITIZE_ALL=3Dy<br>
&gt; # CONFIG_ARCH_WANTS_UBSAN_NO_<wbr>NULL is not set<br>
&gt; # CONFIG_UBSAN is not set<br>
&gt; CONFIG_ARCH_HAS_DEVMEM_IS_<wbr>ALLOWED=3Dy<br>
&gt; # CONFIG_STRICT_DEVMEM is not set<br>
&gt; CONFIG_EARLY_PRINTK_USB=3Dy<br>
&gt; CONFIG_X86_VERBOSE_BOOTUP=3Dy<br>
&gt; CONFIG_EARLY_PRINTK=3Dy<br>
&gt; CONFIG_EARLY_PRINTK_DBGP=3Dy<br>
&gt; # CONFIG_EARLY_PRINTK_EFI is not set<br>
&gt; # CONFIG_EARLY_PRINTK_USB_XDBC is not set<br>
&gt; # CONFIG_X86_PTDUMP_CORE is not set<br>
&gt; # CONFIG_X86_PTDUMP is not set<br>
&gt; # CONFIG_EFI_PGT_DUMP is not set<br>
&gt; # CONFIG_DEBUG_WX is not set<br>
&gt; CONFIG_DOUBLEFAULT=3Dy<br>
&gt; # CONFIG_DEBUG_TLBFLUSH is not set<br>
&gt; CONFIG_HAVE_MMIOTRACE_SUPPORT=3D<wbr>y<br>
&gt; # CONFIG_X86_DECODER_SELFTEST is not set<br>
&gt; CONFIG_IO_DELAY_TYPE_0X80=3D0<br>
&gt; CONFIG_IO_DELAY_TYPE_0XED=3D1<br>
&gt; CONFIG_IO_DELAY_TYPE_UDELAY=3D2<br>
&gt; CONFIG_IO_DELAY_TYPE_NONE=3D3<br>
&gt; CONFIG_IO_DELAY_0X80=3Dy<br>
&gt; # CONFIG_IO_DELAY_0XED is not set<br>
&gt; # CONFIG_IO_DELAY_UDELAY is not set<br>
&gt; # CONFIG_IO_DELAY_NONE is not set<br>
&gt; CONFIG_DEFAULT_IO_DELAY_TYPE=3D0<br>
&gt; CONFIG_DEBUG_BOOT_PARAMS=3Dy<br>
&gt; # CONFIG_CPA_DEBUG is not set<br>
&gt; CONFIG_OPTIMIZE_INLINING=3Dy<br>
&gt; # CONFIG_DEBUG_ENTRY is not set<br>
&gt; # CONFIG_DEBUG_NMI_SELFTEST is not set<br>
&gt; CONFIG_X86_DEBUG_FPU=3Dy<br>
&gt; # CONFIG_PUNIT_ATOM_DEBUG is not set<br>
&gt; # CONFIG_UNWINDER_ORC is not set<br>
&gt; CONFIG_UNWINDER_FRAME_POINTER=3D<wbr>y<br>
&gt;<br>
&gt; #<br>
&gt; # Security options<br>
&gt; #<br>
&gt; CONFIG_KEYS=3Dy<br>
&gt; CONFIG_KEYS_COMPAT=3Dy<br>
&gt; CONFIG_PERSISTENT_KEYRINGS=3Dy<br>
&gt; CONFIG_BIG_KEYS=3Dy<br>
&gt; CONFIG_ENCRYPTED_KEYS=3Dy<br>
&gt; CONFIG_KEY_DH_OPERATIONS=3Dy<br>
&gt; # CONFIG_SECURITY_DMESG_RESTRICT is not set<br>
&gt; CONFIG_SECURITY=3Dy<br>
&gt; CONFIG_SECURITY_WRITABLE_<wbr>HOOKS=3Dy<br>
&gt; CONFIG_SECURITYFS=3Dy<br>
&gt; CONFIG_SECURITY_NETWORK=3Dy<br>
&gt; # CONFIG_PAGE_TABLE_ISOLATION is not set<br>
&gt; CONFIG_SECURITY_INFINIBAND=3Dy<br>
&gt; CONFIG_SECURITY_NETWORK_XFRM=3Dy<br>
&gt; CONFIG_SECURITY_PATH=3Dy<br>
&gt; # CONFIG_INTEL_TXT is not set<br>
&gt; CONFIG_LSM_MMAP_MIN_ADDR=3D65536<br>
&gt; CONFIG_HAVE_HARDENED_USERCOPY_<wbr>ALLOCATOR=3Dy<br>
&gt; CONFIG_HARDENED_USERCOPY=3Dy<br>
&gt; CONFIG_HARDENED_USERCOPY_<wbr>FALLBACK=3Dy<br>
&gt; # CONFIG_HARDENED_USERCOPY_<wbr>PAGESPAN is not set<br>
&gt; CONFIG_FORTIFY_SOURCE=3Dy<br>
&gt; # CONFIG_STATIC_USERMODEHELPER is not set<br>
&gt; CONFIG_SECURITY_SELINUX=3Dy<br>
&gt; CONFIG_SECURITY_SELINUX_<wbr>BOOTPARAM=3Dy<br>
&gt; CONFIG_SECURITY_SELINUX_<wbr>BOOTPARAM_VALUE=3D1<br>
&gt; CONFIG_SECURITY_SELINUX_<wbr>DISABLE=3Dy<br>
&gt; CONFIG_SECURITY_SELINUX_<wbr>DEVELOP=3Dy<br>
&gt; CONFIG_SECURITY_SELINUX_AVC_<wbr>STATS=3Dy<br>
&gt; CONFIG_SECURITY_SELINUX_<wbr>CHECKREQPROT_VALUE=3D0<br>
&gt; # CONFIG_SECURITY_SMACK is not set<br>
&gt; # CONFIG_SECURITY_TOMOYO is not set<br>
&gt; CONFIG_SECURITY_APPARMOR=3Dy<br>
&gt; CONFIG_SECURITY_APPARMOR_<wbr>BOOTPARAM_VALUE=3D1<br>
&gt; CONFIG_SECURITY_APPARMOR_HASH=3D<wbr>y<br>
&gt; CONFIG_SECURITY_APPARMOR_HASH_<wbr>DEFAULT=3Dy<br>
&gt; # CONFIG_SECURITY_APPARMOR_DEBUG is not set<br>
&gt; # CONFIG_SECURITY_LOADPIN is not set<br>
&gt; CONFIG_SECURITY_YAMA=3Dy<br>
&gt; CONFIG_INTEGRITY=3Dy<br>
&gt; # CONFIG_INTEGRITY_SIGNATURE is not set<br>
&gt; CONFIG_INTEGRITY_AUDIT=3Dy<br>
&gt; # CONFIG_IMA is not set<br>
&gt; # CONFIG_EVM is not set<br>
&gt; CONFIG_DEFAULT_SECURITY_<wbr>SELINUX=3Dy<br>
&gt; # CONFIG_DEFAULT_SECURITY_<wbr>APPARMOR is not set<br>
&gt; # CONFIG_DEFAULT_SECURITY_DAC is not set<br>
&gt; CONFIG_DEFAULT_SECURITY=3D&quot;<wbr>selinux&quot;<br>
&gt; CONFIG_CRYPTO=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Crypto core or helper<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_ALGAPI=3Dy<br>
&gt; CONFIG_CRYPTO_ALGAPI2=3Dy<br>
&gt; CONFIG_CRYPTO_AEAD=3Dy<br>
&gt; CONFIG_CRYPTO_AEAD2=3Dy<br>
&gt; CONFIG_CRYPTO_BLKCIPHER=3Dy<br>
&gt; CONFIG_CRYPTO_BLKCIPHER2=3Dy<br>
&gt; CONFIG_CRYPTO_HASH=3Dy<br>
&gt; CONFIG_CRYPTO_HASH2=3Dy<br>
&gt; CONFIG_CRYPTO_RNG=3Dy<br>
&gt; CONFIG_CRYPTO_RNG2=3Dy<br>
&gt; CONFIG_CRYPTO_RNG_DEFAULT=3Dy<br>
&gt; CONFIG_CRYPTO_AKCIPHER2=3Dy<br>
&gt; CONFIG_CRYPTO_AKCIPHER=3Dy<br>
&gt; CONFIG_CRYPTO_KPP2=3Dy<br>
&gt; CONFIG_CRYPTO_KPP=3Dy<br>
&gt; CONFIG_CRYPTO_ACOMP2=3Dy<br>
&gt; CONFIG_CRYPTO_RSA=3Dy<br>
&gt; CONFIG_CRYPTO_DH=3Dy<br>
&gt; CONFIG_CRYPTO_ECDH=3Dy<br>
&gt; CONFIG_CRYPTO_MANAGER=3Dy<br>
&gt; CONFIG_CRYPTO_MANAGER2=3Dy<br>
&gt; CONFIG_CRYPTO_USER=3Dy<br>
&gt; CONFIG_CRYPTO_MANAGER_DISABLE_<wbr>TESTS=3Dy<br>
&gt; CONFIG_CRYPTO_GF128MUL=3Dy<br>
&gt; CONFIG_CRYPTO_NULL=3Dy<br>
&gt; CONFIG_CRYPTO_NULL2=3Dy<br>
&gt; CONFIG_CRYPTO_PCRYPT=3Dy<br>
&gt; CONFIG_CRYPTO_WORKQUEUE=3Dy<br>
&gt; CONFIG_CRYPTO_CRYPTD=3Dy<br>
&gt; CONFIG_CRYPTO_MCRYPTD=3Dy<br>
&gt; CONFIG_CRYPTO_AUTHENC=3Dy<br>
&gt; # CONFIG_CRYPTO_TEST is not set<br>
&gt; CONFIG_CRYPTO_ABLK_HELPER=3Dy<br>
&gt; CONFIG_CRYPTO_SIMD=3Dy<br>
&gt; CONFIG_CRYPTO_GLUE_HELPER_X86=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_ENGINE=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Authenticated Encryption with Associated Data<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_CCM=3Dy<br>
&gt; CONFIG_CRYPTO_GCM=3Dy<br>
&gt; CONFIG_CRYPTO_<wbr>CHACHA20POLY1305=3Dy<br>
&gt; CONFIG_CRYPTO_SEQIV=3Dy<br>
&gt; CONFIG_CRYPTO_ECHAINIV=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Block modes<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_CBC=3Dy<br>
&gt; CONFIG_CRYPTO_CTR=3Dy<br>
&gt; CONFIG_CRYPTO_CTS=3Dy<br>
&gt; CONFIG_CRYPTO_ECB=3Dy<br>
&gt; CONFIG_CRYPTO_LRW=3Dy<br>
&gt; CONFIG_CRYPTO_PCBC=3Dy<br>
&gt; CONFIG_CRYPTO_XTS=3Dy<br>
&gt; CONFIG_CRYPTO_KEYWRAP=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Hash modes<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_CMAC=3Dy<br>
&gt; CONFIG_CRYPTO_HMAC=3Dy<br>
&gt; CONFIG_CRYPTO_XCBC=3Dy<br>
&gt; CONFIG_CRYPTO_VMAC=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Digest<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_CRC32C=3Dy<br>
&gt; CONFIG_CRYPTO_CRC32C_INTEL=3Dy<br>
&gt; CONFIG_CRYPTO_CRC32=3Dy<br>
&gt; CONFIG_CRYPTO_CRC32_PCLMUL=3Dy<br>
&gt; CONFIG_CRYPTO_CRCT10DIF=3Dy<br>
&gt; CONFIG_CRYPTO_CRCT10DIF_<wbr>PCLMUL=3Dy<br>
&gt; CONFIG_CRYPTO_GHASH=3Dy<br>
&gt; CONFIG_CRYPTO_POLY1305=3Dy<br>
&gt; CONFIG_CRYPTO_POLY1305_X86_64=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_MD4=3Dy<br>
&gt; CONFIG_CRYPTO_MD5=3Dy<br>
&gt; CONFIG_CRYPTO_MICHAEL_MIC=3Dy<br>
&gt; CONFIG_CRYPTO_RMD128=3Dy<br>
&gt; CONFIG_CRYPTO_RMD160=3Dy<br>
&gt; CONFIG_CRYPTO_RMD256=3Dy<br>
&gt; CONFIG_CRYPTO_RMD320=3Dy<br>
&gt; CONFIG_CRYPTO_SHA1=3Dy<br>
&gt; CONFIG_CRYPTO_SHA1_SSSE3=3Dy<br>
&gt; CONFIG_CRYPTO_SHA256_SSSE3=3Dy<br>
&gt; CONFIG_CRYPTO_SHA512_SSSE3=3Dy<br>
&gt; CONFIG_CRYPTO_SHA1_MB=3Dy<br>
&gt; CONFIG_CRYPTO_SHA256_MB=3Dy<br>
&gt; CONFIG_CRYPTO_SHA512_MB=3Dy<br>
&gt; CONFIG_CRYPTO_SHA256=3Dy<br>
&gt; CONFIG_CRYPTO_SHA512=3Dy<br>
&gt; CONFIG_CRYPTO_SHA3=3Dy<br>
&gt; CONFIG_CRYPTO_SM3=3Dy<br>
&gt; CONFIG_CRYPTO_TGR192=3Dy<br>
&gt; CONFIG_CRYPTO_WP512=3Dy<br>
&gt; CONFIG_CRYPTO_GHASH_CLMUL_NI_<wbr>INTEL=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Ciphers<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_AES=3Dy<br>
&gt; CONFIG_CRYPTO_AES_TI=3Dy<br>
&gt; CONFIG_CRYPTO_AES_X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_AES_NI_INTEL=3Dy<br>
&gt; CONFIG_CRYPTO_ANUBIS=3Dy<br>
&gt; CONFIG_CRYPTO_ARC4=3Dy<br>
&gt; CONFIG_CRYPTO_BLOWFISH=3Dy<br>
&gt; CONFIG_CRYPTO_BLOWFISH_COMMON=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_BLOWFISH_X86_64=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_CAMELLIA=3Dy<br>
&gt; CONFIG_CRYPTO_CAMELLIA_X86_64=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_CAMELLIA_AESNI_<wbr>AVX_X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_CAMELLIA_AESNI_<wbr>AVX2_X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_CAST_COMMON=3Dy<br>
&gt; CONFIG_CRYPTO_CAST5=3Dy<br>
&gt; CONFIG_CRYPTO_CAST5_AVX_X86_<wbr>64=3Dy<br>
&gt; CONFIG_CRYPTO_CAST6=3Dy<br>
&gt; CONFIG_CRYPTO_CAST6_AVX_X86_<wbr>64=3Dy<br>
&gt; CONFIG_CRYPTO_DES=3Dy<br>
&gt; CONFIG_CRYPTO_DES3_EDE_X86_64=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_FCRYPT=3Dy<br>
&gt; CONFIG_CRYPTO_KHAZAD=3Dy<br>
&gt; CONFIG_CRYPTO_SALSA20=3Dy<br>
&gt; CONFIG_CRYPTO_SALSA20_X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_CHACHA20=3Dy<br>
&gt; CONFIG_CRYPTO_CHACHA20_X86_64=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_SEED=3Dy<br>
&gt; CONFIG_CRYPTO_SERPENT=3Dy<br>
&gt; CONFIG_CRYPTO_SERPENT_SSE2_<wbr>X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_SERPENT_AVX_X86_<wbr>64=3Dy<br>
&gt; CONFIG_CRYPTO_SERPENT_AVX2_<wbr>X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_TEA=3Dy<br>
&gt; CONFIG_CRYPTO_TWOFISH=3Dy<br>
&gt; CONFIG_CRYPTO_TWOFISH_COMMON=3Dy<br>
&gt; CONFIG_CRYPTO_TWOFISH_X86_64=3Dy<br>
&gt; CONFIG_CRYPTO_TWOFISH_X86_64_<wbr>3WAY=3Dy<br>
&gt; CONFIG_CRYPTO_TWOFISH_AVX_X86_<wbr>64=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Compression<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_DEFLATE=3Dy<br>
&gt; CONFIG_CRYPTO_LZO=3Dy<br>
&gt; CONFIG_CRYPTO_842=3Dy<br>
&gt; CONFIG_CRYPTO_LZ4=3Dy<br>
&gt; CONFIG_CRYPTO_LZ4HC=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Random Number Generation<br>
&gt; #<br>
&gt; CONFIG_CRYPTO_ANSI_CPRNG=3Dy<br>
&gt; CONFIG_CRYPTO_DRBG_MENU=3Dy<br>
&gt; CONFIG_CRYPTO_DRBG_HMAC=3Dy<br>
&gt; CONFIG_CRYPTO_DRBG_HASH=3Dy<br>
&gt; CONFIG_CRYPTO_DRBG_CTR=3Dy<br>
&gt; CONFIG_CRYPTO_DRBG=3Dy<br>
&gt; CONFIG_CRYPTO_JITTERENTROPY=3Dy<br>
&gt; CONFIG_CRYPTO_USER_API=3Dy<br>
&gt; CONFIG_CRYPTO_USER_API_HASH=3Dy<br>
&gt; CONFIG_CRYPTO_USER_API_<wbr>SKCIPHER=3Dy<br>
&gt; CONFIG_CRYPTO_USER_API_RNG=3Dy<br>
&gt; CONFIG_CRYPTO_USER_API_AEAD=3Dy<br>
&gt; CONFIG_CRYPTO_HASH_INFO=3Dy<br>
&gt; CONFIG_CRYPTO_HW=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_PADLOCK=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_PADLOCK_AES=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_DEV_PADLOCK_SHA=3D<wbr>y<br>
&gt; # CONFIG_CRYPTO_DEV_FSL_CAAM_<wbr>CRYPTO_API_DESC is not set<br>
&gt; CONFIG_CRYPTO_DEV_CCP=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_CCP_DD=3Dy<br>
&gt; # CONFIG_CRYPTO_DEV_SP_CCP is not set<br>
&gt; # CONFIG_CRYPTO_DEV_SP_PSP is not set<br>
&gt; CONFIG_CRYPTO_DEV_QAT=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_QAT_<wbr>DH895xCC=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_QAT_C3XXX=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_QAT_C62X=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_QAT_<wbr>DH895xCCVF=3Dy<br>
&gt; CONFIG_CRYPTO_DEV_QAT_C3XXXVF=3D<wbr>y<br>
&gt; CONFIG_CRYPTO_DEV_QAT_C62XVF=3Dy<br>
&gt; # CONFIG_CRYPTO_DEV_NITROX_<wbr>CNN55XX is not set<br>
&gt; CONFIG_CRYPTO_DEV_VIRTIO=3Dy<br>
&gt; CONFIG_ASYMMETRIC_KEY_TYPE=3Dy<br>
&gt; CONFIG_ASYMMETRIC_PUBLIC_KEY_<wbr>SUBTYPE=3Dy<br>
&gt; CONFIG_X509_CERTIFICATE_<wbr>PARSER=3Dy<br>
&gt; CONFIG_PKCS7_MESSAGE_PARSER=3Dy<br>
&gt; CONFIG_PKCS7_TEST_KEY=3Dy<br>
&gt; CONFIG_SIGNED_PE_FILE_<wbr>VERIFICATION=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Certificates for signature checking<br>
&gt; #<br>
&gt; CONFIG_SYSTEM_TRUSTED_KEYRING=3D<wbr>y<br>
&gt; CONFIG_SYSTEM_TRUSTED_KEYS=3D&quot;&quot;<br>
&gt; # CONFIG_SYSTEM_EXTRA_<wbr>CERTIFICATE is not set<br>
&gt; CONFIG_SECONDARY_TRUSTED_<wbr>KEYRING=3Dy<br>
&gt; # CONFIG_SYSTEM_BLACKLIST_<wbr>KEYRING is not set<br>
&gt; CONFIG_HAVE_KVM=3Dy<br>
&gt; CONFIG_HAVE_KVM_IRQCHIP=3Dy<br>
&gt; CONFIG_HAVE_KVM_IRQFD=3Dy<br>
&gt; CONFIG_HAVE_KVM_IRQ_ROUTING=3Dy<br>
&gt; CONFIG_HAVE_KVM_EVENTFD=3Dy<br>
&gt; CONFIG_KVM_MMIO=3Dy<br>
&gt; CONFIG_KVM_ASYNC_PF=3Dy<br>
&gt; CONFIG_HAVE_KVM_MSI=3Dy<br>
&gt; CONFIG_HAVE_KVM_CPU_RELAX_<wbr>INTERCEPT=3Dy<br>
&gt; CONFIG_KVM_VFIO=3Dy<br>
&gt; CONFIG_KVM_GENERIC_DIRTYLOG_<wbr>READ_PROTECT=3Dy<br>
&gt; CONFIG_KVM_COMPAT=3Dy<br>
&gt; CONFIG_HAVE_KVM_IRQ_BYPASS=3Dy<br>
&gt; CONFIG_VIRTUALIZATION=3Dy<br>
&gt; CONFIG_KVM=3Dy<br>
&gt; CONFIG_KVM_INTEL=3Dy<br>
&gt; CONFIG_KVM_AMD=3Dy<br>
&gt; # CONFIG_KVM_MMU_AUDIT is not set<br>
&gt; CONFIG_VHOST_NET=3Dy<br>
&gt; CONFIG_VHOST_VSOCK=3Dy<br>
&gt; CONFIG_VHOST=3Dy<br>
&gt; CONFIG_VHOST_CROSS_ENDIAN_<wbr>LEGACY=3Dy<br>
&gt; CONFIG_BINARY_PRINTF=3Dy<br>
&gt;<br>
&gt; #<br>
&gt; # Library routines<br>
&gt; #<br>
&gt; CONFIG_BITREVERSE=3Dy<br>
&gt; # CONFIG_HAVE_ARCH_BITREVERSE is not set<br>
&gt; CONFIG_RATIONAL=3Dy<br>
&gt; CONFIG_GENERIC_STRNCPY_FROM_<wbr>USER=3Dy<br>
&gt; CONFIG_GENERIC_STRNLEN_USER=3Dy<br>
&gt; CONFIG_GENERIC_NET_UTILS=3Dy<br>
&gt; CONFIG_GENERIC_FIND_FIRST_BIT=3D<wbr>y<br>
&gt; CONFIG_GENERIC_PCI_IOMAP=3Dy<br>
&gt; CONFIG_GENERIC_IOMAP=3Dy<br>
&gt; CONFIG_ARCH_USE_CMPXCHG_<wbr>LOCKREF=3Dy<br>
&gt; CONFIG_ARCH_HAS_FAST_<wbr>MULTIPLIER=3Dy<br>
&gt; CONFIG_CRC_CCITT=3Dy<br>
&gt; CONFIG_CRC16=3Dy<br>
&gt; CONFIG_CRC_T10DIF=3Dy<br>
&gt; CONFIG_CRC_ITU_T=3Dy<br>
&gt; CONFIG_CRC32=3Dy<br>
&gt; # CONFIG_CRC32_SELFTEST is not set<br>
&gt; CONFIG_CRC32_SLICEBY8=3Dy<br>
&gt; # CONFIG_CRC32_SLICEBY4 is not set<br>
&gt; # CONFIG_CRC32_SARWATE is not set<br>
&gt; # CONFIG_CRC32_BIT is not set<br>
&gt; CONFIG_CRC4=3Dy<br>
&gt; # CONFIG_CRC7 is not set<br>
&gt; CONFIG_LIBCRC32C=3Dy<br>
&gt; # CONFIG_CRC8 is not set<br>
&gt; # CONFIG_AUDIT_ARCH_COMPAT_<wbr>GENERIC is not set<br>
&gt; # CONFIG_RANDOM32_SELFTEST is not set<br>
&gt; CONFIG_842_COMPRESS=3Dy<br>
&gt; CONFIG_842_DECOMPRESS=3Dy<br>
&gt; CONFIG_ZLIB_INFLATE=3Dy<br>
&gt; CONFIG_ZLIB_DEFLATE=3Dy<br>
&gt; CONFIG_LZO_COMPRESS=3Dy<br>
&gt; CONFIG_LZO_DECOMPRESS=3Dy<br>
&gt; CONFIG_LZ4_COMPRESS=3Dy<br>
&gt; CONFIG_LZ4HC_COMPRESS=3Dy<br>
&gt; CONFIG_LZ4_DECOMPRESS=3Dy<br>
&gt; CONFIG_XZ_DEC=3Dy<br>
&gt; CONFIG_XZ_DEC_X86=3Dy<br>
&gt; CONFIG_XZ_DEC_POWERPC=3Dy<br>
&gt; CONFIG_XZ_DEC_IA64=3Dy<br>
&gt; CONFIG_XZ_DEC_ARM=3Dy<br>
&gt; CONFIG_XZ_DEC_ARMTHUMB=3Dy<br>
&gt; CONFIG_XZ_DEC_SPARC=3Dy<br>
&gt; CONFIG_XZ_DEC_BCJ=3Dy<br>
&gt; # CONFIG_XZ_DEC_TEST is not set<br>
&gt; CONFIG_DECOMPRESS_GZIP=3Dy<br>
&gt; CONFIG_DECOMPRESS_BZIP2=3Dy<br>
&gt; CONFIG_DECOMPRESS_LZMA=3Dy<br>
&gt; CONFIG_DECOMPRESS_XZ=3Dy<br>
&gt; CONFIG_DECOMPRESS_LZO=3Dy<br>
&gt; CONFIG_DECOMPRESS_LZ4=3Dy<br>
&gt; CONFIG_GENERIC_ALLOCATOR=3Dy<br>
&gt; CONFIG_TEXTSEARCH=3Dy<br>
&gt; CONFIG_TEXTSEARCH_KMP=3Dy<br>
&gt; CONFIG_TEXTSEARCH_BM=3Dy<br>
&gt; CONFIG_TEXTSEARCH_FSM=3Dy<br>
&gt; CONFIG_INTERVAL_TREE=3Dy<br>
&gt; CONFIG_RADIX_TREE_MULTIORDER=3Dy<br>
&gt; CONFIG_ASSOCIATIVE_ARRAY=3Dy<br>
&gt; CONFIG_HAS_IOMEM=3Dy<br>
&gt; CONFIG_HAS_IOPORT_MAP=3Dy<br>
&gt; CONFIG_HAS_DMA=3Dy<br>
&gt; CONFIG_SGL_ALLOC=3Dy<br>
&gt; # CONFIG_DMA_DIRECT_OPS is not set<br>
&gt; CONFIG_DMA_VIRT_OPS=3Dy<br>
&gt; CONFIG_CHECK_SIGNATURE=3Dy<br>
&gt; CONFIG_CPU_RMAP=3Dy<br>
&gt; CONFIG_DQL=3Dy<br>
&gt; CONFIG_GLOB=3Dy<br>
&gt; # CONFIG_GLOB_SELFTEST is not set<br>
&gt; CONFIG_NLATTR=3Dy<br>
&gt; CONFIG_CLZ_TAB=3Dy<br>
&gt; # CONFIG_CORDIC is not set<br>
&gt; # CONFIG_DDR is not set<br>
&gt; CONFIG_IRQ_POLL=3Dy<br>
&gt; CONFIG_MPILIB=3Dy<br>
&gt; CONFIG_OID_REGISTRY=3Dy<br>
&gt; CONFIG_UCS2_STRING=3Dy<br>
&gt; CONFIG_FONT_SUPPORT=3Dy<br>
&gt; # CONFIG_FONTS is not set<br>
&gt; CONFIG_FONT_8x8=3Dy<br>
&gt; CONFIG_FONT_8x16=3Dy<br>
&gt; # CONFIG_SG_SPLIT is not set<br>
&gt; CONFIG_SG_POOL=3Dy<br>
&gt; CONFIG_ARCH_HAS_SG_CHAIN=3Dy<br>
&gt; CONFIG_ARCH_HAS_PMEM_API=3Dy<br>
&gt; CONFIG_ARCH_HAS_UACCESS_<wbr>FLUSHCACHE=3Dy<br>
&gt; CONFIG_STACKDEPOT=3Dy<br>
&gt; CONFIG_SBITMAP=3Dy<br>
&gt; # CONFIG_STRING_SELFTEST is not set<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
<br>
--<br>
Michal Hocko<br>
SUSE Labs<br>
</font></span></blockquote></div><br></div></div>

--94eb2c07da3aeb84c40566491a3a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
